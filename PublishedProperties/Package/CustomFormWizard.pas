unit CustomFormWizard;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Dialogs, WinApi.Windows,
  ToolsAPI, // Open Tools API Interface definitions
  MyCustomForm;

type
  // To Create tghe form the IDE must create both a Pascal Unit File (*.pas)
  // and a Form file (*.dfm). To do this we need to implement the IOTAFile
  // interface seperately for each one.
  TBaseFile = class(TInterfacedObject)
  protected
    FModuleName: string;
    FFormName: string;
    FAncestorName: string;
  public
    constructor Create(const ModuleName, FormName, AncestorName: string);
  end;

  TUnitFile = class(TBaseFile, IOTAFile)
  protected
    function GetSource: string;
    function GetAge: TDateTime;
  end;

  TFormFile = class(TBaseFile, IOTAFile)
  protected
    function GetSource: string;
    function GetAge: TDateTime;
  end;

  // We want our Own Gallery Category Called "Our Custom Forms"
  // Under Delphi in the File->New->Other. To do this we implement
  // IOTAGalleryCategory with the correct Parent Gallery.
  TCustomGalleryCategory = class(TInterfacedObject, IOTAGalleryCategory)
  public
    function GetDisplayName: string;
    function GetIDString: string;
    function GetParent: IOTAGalleryCategory;
  end;

  TMyCustomFormWizardWizard = class(TInterfacedObject,
                                    IOTANotifier,
                                    IOTAWizard,
                                    IOTARepositoryWizard,
                                    // IOTARepositoryWizard60 & IOTARepositoryWizard80
                                    // *must both* be implemnted in later versions of Delphi
                                    // that support multiple OS/Platforms.
                                    IOTARepositoryWizard60,
                                    IOTARepositoryWizard80,
                                    // IOTAFormWizard does nothing but must be present
                                    // to let the IDE Services know tghis is a form wizard.
                                    // All the methods we implement are on the IOTARepositoryWizard
                                    IOTAFormWizard,
                                    IOTACreator,
                                    IOTAModuleCreator)
   private
    FUnitIdent: string;
    FClassName: string;
    FFileName: string;
   public
     { IOTNotifier implementation }
     procedure AfterSave;
     procedure BeforeSave;
     procedure Destroyed;
     procedure Modified;

     { IOTAWizard implementation}
     function GetIDString: string;
     function GetName: string;
     function GetState: TWizardState;
     procedure Execute;

     { IOTARepositoryWizard implementation }
     function GetAuthor: string;
     function GetComment: string;
     function GetPage: string;
     function GetGlyph: Cardinal;

     { IOTARepositoryWizard60  implementation }
     function GetDesigner: String;

     { IOTARepositoryWizard80  implementation }
     function GetGalleryCategory: IOTAGalleryCategory;
     function GetPersonality: String;

     { IOTACreator implementation }
     function GetCreatorType: String;
     function GetExisting: Boolean;
     function GetFileSystem: String;
     function GetOwner: IOTAModule;
     function GetUnnamed: Boolean;

     { IOTAModuleCreator implementation }
     function GetAncestorName: string;
     function GetImplFileName: string;
     function GetIntfFileName: string;
     function GetFormName: string;
     function GetMainForm: Boolean;
     function GetShowForm: Boolean;
     function GetShowSource: Boolean;
     function NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
     function NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
     function NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
     procedure FormCreated(const FormEditor: IOTAFormEditor);
   end;

procedure AddCategory;
procedure RemoveCategory;

// There only neds to be ioone instance of our IOTAGalleryCategory category implemntation
// so we use a global variable which we add and remove through the Gallery Manager.
// We will add it at registrion time and remove it in the finalization (when IDE
// Closes or pacjage is uninstalled)
var
  FCategory: IOTAGalleryCategory = nil;

implementation

procedure AddCategory;
begin
  FCategory := TCustomGalleryCategory.Create;
  (BorlandIDEServices as IOTAGalleryCategoryManager).AddCategory(FCategory.Parent, FCategory.IDString, FCategory.DisplayName, 0);
end;

procedure RemoveCategory;
begin
  (BorlandIDEServices as IOTAGalleryCategoryManager).DeleteCategory(FCategory);
end;

{$REGION 'TBaseFile'}
constructor TBaseFile.Create(const ModuleName, FormName, AncestorName: string);
begin
  inherited Create;
  FModuleName := ModuleName;
  FFormName := FormName;
  FAncestorName := AncestorName;
end;
{$ENDREGION}

{$REGION 'TUnitFile'}
function TUnitFile.GetSource: string;
var
  LPasFileText: String;
begin
  LPasFileText := GetMyCustomFormPasFileText;
  try
    LPasFileText := String.Format(LPasFileText, [FModuleName, FFormName, FAncestorName]);
  except
    on E:Exception do
    begin
      OutputDebugString(PChar(E.Message +  ' ModuleName:' + FModuleName + ', FormName: ' + FFormName +', AncestorName' + FAncestorName +' ' + GetMyCustomFormDfmFileText));
      raise;
    end;
  end;
  Result := LPasFileText;
end;

function TUnitFile.GetAge: TDateTime;
begin
  // Wee're crerating it brand new...
  Result := -1;
end;
{$ENDREGION}

{$REGION 'TFormFile'}
function TFormFile.GetSource: string;
var
  LDfmText: String;
begin
  LDfmText := GetMyCustomFormDfmFileText;
  try
    LDfmText := String.Format(LDfmText, [FFormName]);
  except
    on E:Exception do
    begin
      OutputDebugString(PChar(E.Message +  ' FFormName:' + FFormName + ' ' + GetMyCustomFormDfmFileText));
      raise;
    end;
  end;
  Result := LDfmText;
end;

function TFormFile.GetAge: TDateTime;
begin
  // Wee're crerating it brand new...
  Result := -1;
end;
{$ENDREGION}

{$REGION 'TCustomGalleryCategory'}
function TCustomGalleryCategory.GetDisplayName: String;
begin
  Result := 'Our Custom Forms';
end;

{$REGION 'TGalleryCategory'}
function TCustomGalleryCategory.GetIDString: String;
begin
  Result := 'Borland.Delphi.OurCustomForms';
end;

function TCustomGalleryCategory.GetParent: IOTAGalleryCategory;
var
  LParent: IOTAGalleryCategory;
begin
   OutputDebugString(PChar('Find Parent ' + sCategoryDelphiWindows));
  // There is not a constant for "InheritableItems" in ToolsApi.pas
  LParent := (BorlandIDEServices as IOTAGalleryCategoryManager).FindCategory(sCategoryDelphiWindows);
  if (nil = LParent) then
  begin
    OutputDebugString(PChar('Error Getting Parent ' + sCategoryRoot));
    LParent := (BorlandIDEServices as IOTAGalleryCategoryManager).FindCategory(sCategoryDelphiNew);
  end;
  Result := LParent;
end;
{$ENDREGION}

{ TMyCustomFormWizardWizard.IOTANotifier }
procedure TMyCustomFormWizardWizard.AfterSave;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizardWizard.BeforeSave;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizardWizard.Destroyed;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizardWizard.Modified;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

{ TMyCustomFormWizardWizard.IOTAWizard }
function TMyCustomFormWizardWizard.GetIDString: string;
begin
  Result := 'MyCustomFormWizard';
end;

function TMyCustomFormWizardWizard.GetName: string;
begin
  Result := 'fmMyCustomForm';
end;

function TMyCustomFormWizardWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TMyCustomFormWizardWizard.Execute;
var
  LUnitIdent, LClassName, LFileName : String;
begin
  (BorlandIDEServices as IOTAModuleServices).GetNewModuleAndClassName('fmMyCustomForm', LUnitIdent, LClassName, LFileName);
  OutputDebugString(PChar('GetNewModuleAndClassName: ModuleName: ' + LUnitIdent + ', FormName:' + LClassName + ', ' + 'FileName: ' + LFileName));

  // It l;ooks like theres a bug in GetNewModuleAndClassName. It's supposed to
  // fill in ClasName, FileName etc based on wht we feed it, but the strings
  // come back empty. Add checking.
  if String.IsNullOrWhitespace(LUnitIdent) then
    LUnitIdent := String.Format('Unit%d', [(BorlandIDEServices as IOTAModuleServices).ModuleCount]);
  if String.IsNullOrWhitespace(LClassName) then
    LClassName := 'fmMyCustomForm';

  if String.IsNullOrWhitespace(LFileName) then
    LFileName := 'MyCustomForm';

  FUnitIdent := LUnitIdent;
  FClassName := LClassName;
  FFileName := LFileName;

  OutputDebugString(PChar('GetNewModuleAndClassName: ModuleName: ' + FUnitIdent + ', FormName:' + FClassName + ', ' + 'FileName: ' + FFileName));

  (BorlandIDEServices as IOTAModuleServices).CreateModule(Self);
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard / TMyCustomFormWizardWizard.IOTAFormWizard }
function TMyCustomFormWizardWizard.GetAuthor: string;
begin
  Result := 'Me';
end;

function TMyCustomFormWizardWizard.GetComment: string;
begin
  Result := 'The author is such a handsome fellow!';
end;

function TMyCustomFormWizardWizard.GetPage: string;
begin
  // Seems to be an issue with just implmenting IOTARepositoryWizard
  // GetPage is called but nothjing appears in the gallery.
  // Need to implement IOTARepositoryWizard60 & IOTARepositoryWizard80
  // If IOTARepositoryWizard80 implemented this method should never run.
  OutputDebugString(PChar('Getting Page'));
  Result := String.Empty;
end;

function TMyCustomFormWizardWizard.GetGlyph: Cardinal;
begin
  Result := 0;
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard60 }
function TMyCustomFormWizardWizard.GetDesigner: String;
begin
  Result := dVCL;
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard80 }
function TMyCustomFormWizardWizard.GetGalleryCategory: IOTAGalleryCategory;
begin
  if nil = FCategory then
    FCategory := TCustomGalleryCategory.Create;
  var LMsg := String.Format('Getting Gallery Category: %s. ID: %s', [FCategory.DisplayName, FCategory.IDString]);
  OutputDebugString(PChar(LMsg));
  Result := FCategory;
end;

function TMyCustomFormWizardWizard.GetPersonality: String;
begin
  Result := sDelphiPersonality;
end;

{ TMyCustomFormWizardWizard.IOTACreator }
function TMyCustomFormWizardWizard.GetCreatorType: String;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizardWizard.GetExisting: Boolean;
begin
  Result := False;
end;

function TMyCustomFormWizardWizard.GetFileSystem: String;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizardWizard.GetOwner: IOTAModule;
var
  i: Integer;
  ModServ: IOTAModuleServices;
  Module: IOTAModule;
  ProjGrp: IOTAProjectGroup;
begin
  Result := nil;
  ModServ := BorlandIDEServices as IOTAModuleServices;

  // ModServ.ModuleCount is the total count of modules across the *entire* project gropup
  // We need to fund the active project
  for i := 0 to ModServ.ModuleCount - 1 do
  begin
    Module := ModSErv.Modules[I];
    // find current project group
    if (0 = CompareText(ExtractFileExt(Module.FileName), '.bpg')) and (S_OK = Module.QueryInterface(IOTAProjectGroup, ProjGrp)) then
    begin
      // return active project of group
      // which will be the owner of the newly created form
      Result := ProjGrp.GetActiveProject;
      Exit;
    end;
  end;
end;

function TMyCustomFormWizardWizard.GetUnnamed: Boolean;
begin
  Result := True;
end;

{ TAppBarWizard.IOTAModuleCreator }
function TMyCustomFormWizardWizard.GetAncestorName: string;
begin
  Result := 'TfmMyCustomForm';
end;

function TMyCustomFormWizardWizard.GetImplFileName: string;
var
  CurrDir: array[0..MAX_PATH] of char;
  LImplFileName: String;
begin
  // Note: full path name required!
  GetCurrentDirectory(SizeOf(CurrDir), CurrDir);
  LImplFileName := String.Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
  OutputDebugString(PChar('ImplFileName: ' + LImplFileName));
  Result := LImplFileName;
end;

function TMyCustomFormWizardWizard.GetIntfFileName: string;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizardWizard.GetFormName: string;
begin
  Result := FClassName;
end;

function TMyCustomFormWizardWizard.GetMainForm: Boolean;
begin
  Result := False;
end;

function TMyCustomFormWizardWizard.GetShowForm: Boolean;
begin
  Result := True;
end;

function TMyCustomFormWizardWizard.GetShowSource: Boolean;
begin
  Result := True;
end;

function TMyCustomFormWizardWizard.NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := TFormFile.Create('', FormIdent, AncestorIdent);
end;

function TMyCustomFormWizardWizard.NewImplSource(const ModuleIdent, FormIdent,
AncestorIdent: string): IOTAFile;
begin
  Result := TUnitFile.Create(ModuleIdent, FormIdent, AncestorIdent);
end;

function TMyCustomFormWizardWizard.NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

procedure TMyCustomFormWizardWizard.FormCreated(const FormEditor: IOTAFormEditor);
begin
  // do nothing
end;

end.
