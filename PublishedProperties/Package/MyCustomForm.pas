unit MyCustomForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TMyCustomForm = class(TForm)
  private
    { Private declarations }
    FMyPublishedStringProperty: String;
    FOldCreateOrder: Boolean;
  public
    { Public declarations }
    ///<Summery>
    /// We override the Constructor, because we in the constructor want to call "DoCreate" if
    /// OldCreateOrder is true
    /// We also override the "AfterConstruction" method, as we don't want to call "DoCreate" if it's
    /// called in the Constructor
    ///</Summary>
     Constructor Create(aOwner: TComponent); override;

      ///<Summary>
      ///If we want OldCreateOrder back
      ///we need to override the AfterConstruction
      ///But we don't want to call the inherited method
    ///</Summary>
     procedure AfterConstruction; override;

      ///<Summary>
      ///If we want OldCreateOrder back
      ///we need to override the BeforeDestruction
      ///</Summary>
     procedure BeforeDestruction; override;

     ///<Summary>
     /// The destructor is a copy of TCustomForm.Destroy.
     /// I Delphi 10 OldCreateOrder was checked inside Destroy
     /// So we cannot just call DoDestroy before or after the parent Destroy
     /// So We make a copy, and adjust
     ///</Summary>
     destructor Destroy; override;

     ///<Summary>
     /// CallAncestorDestroy is called in stead of Inherited Destroy
     ///  Inherited destroy would call TCustomForm.Destroy but we want to call the
     ///  Ancestor to that (TScrollingWinControl.destroy)
     ///</Summary>
     procedure CallAncestorDestroy;



  published
    // The publised property. When you create a new instance of this form It will
    // show in the object inspector.
    property MyPublishedStringProperty: String read FMyPublishedStringProperty write FMyPublishedStringProperty;
    ///<Summary>
    ///  OldCreateOrder has been removed from TForm in Delphi 11
    ///  Want to put it back
    ///</Summary>
    Property OldCreateOrder: Boolean read FOldCreateOrder write FOldCreateOrder;
  end;

  ///<Summary>
  ///In the destructora bunch of private methods from  TCustomForm are called
  ///We cannot access private methods
  ///The methods we want to call have the following signatures
  ///And to TypeCast a methodPointer I need the class for it
  ///</Summary>
  TCustomFormPrivateMergeMenu = procedure (aMergeState: Boolean) of Object;
  TCustomFormPrivateGetRecreateChildren = function : TList of Object;
  TCustomFormAcestorDestroy = procedure of Object;

  ///<Summary>
  /// To be able to call a private method as if we had normal access (inside the Object)
  /// I need a Classhelper
  /// The methods will be marked with inline
  /// which basically copies the code rather than calling a method
  ///</Summary>
  TCustomFormHelper = class Helper for TCustomForm
  public
    ///<Summary>
    ///  CallMergeMenu calls the private TCustomForm.MergeMenu
    ///</Summary>
    procedure CallMergeMenu; inline;
    ///<Summary>
    ///  CallRecreateChildren calls the private method TCustomForm.RecreateChildren
    ///  Returning a TList
    ///</Summary>
    function CallRecreateChildren : TList; inline;
  end;


  ///<Summary>
  ///In the destructor from TCustomForm we also have calls to a TScreen private method
  ///We cannot access private methods
  ///The method we want to call has the following signature
  ///And to TypeCast a methodPointer I need the class for it
  ///</Summary>
  TScreenRemoveForm = procedure (aForm: TCustomForm) of Object;

  ///<Summary>
  /// To be able to call a private method as if we had normal access (inside the Object)
  /// I need a Classhelper
  /// The methods will be marked with inline
  /// which basically copies the code rather than calling a method
  ///</Summary>
  TScreenHelper = class Helper for TScreen
  public
    procedure CallRemoveForm(aForm: TCustomForm); inline;
  end;


//-----------------------------------------------------------------------------------------
// Everything above here has to do with the custom form, it's property OldCreateOrder and the
//Construction and Destruction of the form
//-----------------------------------------------------------------------------------------

//The Two methods are for creating the actual files to create the bare minimun of a  TMyCustomForm

// When the IDE creates a new form it needs to fill the dfm file with the basic code.
// This is where it gets that code.
function GetMyCustomFormDfmFileText: String;

// When the IDE creates a new form it needs to fill the pas file with the basic code.
// This is where it gets that code.
function GetMyCustomFormPasFileText: String;

implementation

{$R *.dfm}

function GetMyCustomFormDfmFileText: String;
begin
  // Bare minimum .dfm text
  Result := 'object %0:s: T%0:s'#13#10'end';
end;

function GetMyCustomFormPasFileText: String;
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.Add('unit %0:s;');
    LStrings.Add('');
    LStrings.Add('interface');
    LStrings.Add('');
    LStrings.Add('uses');
    LStrings.Add('  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, MyCustomForm, ');
    LStrings.Add('  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;');
    LStrings.Add('');
    LStrings.Add('type');
    LStrings.Add('  T%1:s = class(%2:s)');
    LStrings.Add('  private');
    LStrings.Add('  { Private declarations }');
    LStrings.Add('  public');
    LStrings.Add('  { Public declarations }');
    LStrings.Add('  end;');
    LStrings.Add('');
    LStrings.Add('var');
    LStrings.Add('  %1:s: T%1:s;');
    LStrings.Add('');
    LStrings.Add('implementation');
    LStrings.Add('');
    LStrings.Add('{$R *.DFM}');
    LStrings.Add('');
    LStrings.Add('end.');
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

{ TMyCustomForm }

procedure TMyCustomForm.AfterConstruction;
begin
  //  inherited; <----  remove this call
  if not OldCreateOrder then DoCreate;
  if fsActivated in FFormState then
  begin
    Activate;
    Exclude(FFormState, fsActivated);
  end;


end;

procedure TMyCustomForm.BeforeDestruction;
begin
  //inherited; <----- remove this call

  GlobalNameSpace.BeginWrite;
  Destroying;
  Screen.SaveFocusedList.Remove(Self);
  RemoveFixupReferences(Self, '');
  if OleFormObject <> nil then OleFormObject.OnDestroy;
  if (FormStyle <> fsMDIChild) and not (fsShowing in FFormState) then Hide;
  //Only call DoDestroy if not OldCreateOrder
  if not OldCreateOrder then
    DoDestroy;
  //else it is called in TMyCustomForm.Destroy
end;

procedure TMyCustomForm.CallAncestorDestroy;
begin
  //create a methodpointer, point to TScrollingWinControl.Destroy;
  var vMethod: TMethod;
  vMethod.Code := @TScrollingWinControl.Destroy;
  vMethod.Data := self;
  TCustomFormAcestorDestroy(vMethod);
end;

constructor TMyCustomForm.Create(aOwner: TComponent);
begin
  inherited;
  if OldCreateOrder then
    DoCreate;
end;

destructor TMyCustomForm.Destroy;
begin
    Application.RemovePopupForm(Self);
  if not (csDestroying in ComponentState) then GlobalNameSpace.BeginWrite;
  try
    //I added the DoDestroy here if  OldCreateOrder is true
    if OldCreateOrder then
      DoDestroy;

    //MergeMenu is a private method from the ancestor, so I'll have to hack this with a class helper
    self.CallMergeMenu;

    if HandleAllocated then DestroyWindowHandle;

    //TScreen has also a private method, so another class helper
    //Screen.RemoveForm(self);
    Screen.CallRemoveForm(self);

    FreeAndNil(Canvas);
    FreeAndNil(Icon);
    FreeAndNil(PopupChildren);
    //RecreateChildren is a method returning a TList, it's private on
    //TCustomForm, som we'll use the class helper once again
    FreeAndNil(self.CallRecreateChildren);
    FreeAndNil(GlassFrame);
    FreeAndNil(CustomTitleBar);
    //IMPORTANT: We have here a copy of the destructor from TCustomForm
    //So we cannot call inherited, as this would call the destructor we
    //are trying to get rid of
    //We will have to call the destructor from TScrollingWinControl.Destroy
    //TScrollingWinControl is the ancestor of TCustomForm
    //Like the class helpers we will need the inline methodpointer
    self.CallAncestorDestroy;
  finally
    GlobalNameSpace.EndWrite;
  end;

 // inherited;  <--- remove this
 end;

{ TCustomFormHelper }

procedure TCustomFormHelper.CallMergeMenu;
begin
  //Calling the private method through a pointer
  var vMethod: TMethod;
  vMethod.Code := @TCustomForm.MergeMenu;
  vMethod.Data := Self;
  TCustomFormPrivateMergeMenu(vMethod)(False);
end;

function TCustomFormHelper.CallRecreateChildren: TList;
begin
  //Calling the private method through a pointer
  var vMethod: TMethod;
  vMethod.Code := @TCustomForm.GetRecreateChildren;
  vMethod.Data := Self;
  Result := TCustomFormPrivateGetRecreateChildren(vMethod);
end;

{ TScreenHelper }

procedure TScreenHelper.CallRemoveForm(aForm: TCustomForm);
begin
  var vMethod: TMethod;
  vMethod.Code := @TScreen.RemoveForm;
  vMethod.Data := self;
  TScreenRemoveForm(vMethod)(aForm);
end;

end.
