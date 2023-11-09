unit CustomFormWizard;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Dialogs, WinApi.Windows,
  ToolsAPI, // Open Tools API Interface definitions
  DesignWindows,
  MyCustomForm;

type
  // To Create the form the IDE must create both a Pascal Unit File (*.pas)
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

  TMyCustomFormWizard = class(TInterfacedObject,
                                    IOTANotifier,
                                    IOTAWizard,
                                    IOTARepositoryWizard,
                                    // IOTARepositoryWizard60 & IOTARepositoryWizard80
                                    // *must both* be implemnted in later versions of Delphi
                                    // that support multiple OS/Platforms.
                                    IOTARepositoryWizard60,
                                    IOTARepositoryWizard80,
                                    // IOTAFormWizard does nothing but must be present
                                    // to let the IDE Services know tgis is a form wizard.
                                    // All the methods we implement are on the IOTARepositoryWizard
                                    IOTAFormWizard,
                                    IOTACreator,
                                    IOTAModuleCreator)
   private
    FUnitIdent: string;
    FClassName: string;
    FFileName: string;
    // Use this to get current project
    function GetCurrentActiveProject: IOTAProject;
   public
     { IOTNotifier implementation                                              }
     { NOTE: ToolsAPI.pas contains a decalration for a TNotifierObject, which  }
     {       provides a do nothing stub for these methods, so you could just   }
     {       inherit from that instead of inheriting directly from             }
     {       TInterfacedObject and implementing the IOTANotifier stub methods  }
     {       yourself.                                                         }
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

implementation


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
    OutputDebugString(PChar('TUnitFile.GetSource: ModuleName:' + FModuleName + ', FormName: ' + FFormName +', AncestorName' + FAncestorName));
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

{$REGION 'TMyCustomFormWizard'}
function TMyCustomFormWizard.GetCurrentActiveProject: IOTAProject;
var
  i: Integer;
  ModServ: IOTAModuleServices;
  ProjGrp: IOTAProjectGroup;
begin
  Result := nil;

  if Supports(BorlandIDEServices, IOTAModuleServices, ModServ) then
  begin
    // ModServ.ModuleCount is the total count of modules across the *entire* project gropup
    // We need to fund the active project
    for i := 0 to ModServ.ModuleCount - 1 do
    begin
      ModSErv.Modules[i];
      // find current project group
      if S_OK = ModSErv.Modules[i].QueryInterface(IOTAProjectGroup, ProjGrp) then
      begin
        // Return the active project
        Result := ProjGrp.GetActiveProject;
        Exit;
      end;
    end;
  end;
end;

{ TMyCustomFormWizardWizard.IOTANotifier }
procedure TMyCustomFormWizard.AfterSave;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizard.BeforeSave;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizard.Destroyed;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

procedure TMyCustomFormWizard.Modified;
begin
  // Do Nothing. Not called on Wizards.
  // We just need to have it since the interface
  // defines it.
end;

{ TMyCustomFormWizardWizard.IOTAWizard }
function TMyCustomFormWizard.GetIDString: string;
begin
  Result := 'MyCustomFormWizard';
end;

function TMyCustomFormWizard.GetName: string;
begin
  Result := 'New Custom Form';
end;

function TMyCustomFormWizard.GetState: TWizardState;
begin
  Result := [wsEnabled];
end;

procedure TMyCustomFormWizard.Execute;
var
  LUnitIdent, LClassName, LFileName : String;
  ModSvc: IOTAModuleServices;
begin
  if Supports(BorlandIDEServices, IOTAModuleServices, ModSvc) then
  begin
    ModSvc.GetNewModuleAndClassName('fmMyCustomForm', LUnitIdent, LClassName, LFileName);
    OutputDebugString(PChar('GetNewModuleAndClassName: ModuleName: ' + LUnitIdent + ', FormName:' + LClassName + ', ' + 'FileName: ' + LFileName));

    // It looks like theres a bug in GetNewModuleAndClassName. It's supposed to
    // fill in ClasName, FileName etc based on what we feed it, but the strings
    // come back empty. Add checking.

    if String.IsNullOrWhitespace(LUnitIdent) then
      LUnitIdent := 'Unit1';
    if String.IsNullOrWhitespace(LClassName) then
      LClassName := 'fmMyCustomForm1';

    if String.IsNullOrWhitespace(LFileName) then
      LFileName := 'MyCustomForm1';

    FUnitIdent := LUnitIdent;
    FClassName := LClassName;
    FFileName := LFileName;

    OutputDebugString(PChar('GetNewModuleAndClassName: ModuleName: ' + FUnitIdent + ', FormName:' + FClassName + ', ' + 'FileName: ' + FFileName));

    ModSvc.CreateModule(Self);
  end;
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard / TMyCustomFormWizardWizard.IOTAFormWizard }
function TMyCustomFormWizard.GetAuthor: String;
begin
  Result := 'Me';
end;

function TMyCustomFormWizard.GetComment: String;
begin
  Result := 'The author is such a handsome fellow!';
end;

function TMyCustomFormWizard.GetPage: String;
begin
  // Need to implement IOTARepositoryWizard60 & IOTARepositoryWizard80!
  // If implementation iof IOTARepositoryWizard80.GetGalleryCategory (below)
  // returns a value this method won't be called.
  // If it returns nil however, then the IDE will fall back on this method
  // as a backup.
  OutputDebugString(PChar('Getting Page'));
  Result := 'New';
end;

function TMyCustomFormWizard.GetGlyph: Cardinal;
begin
  Result := 0;
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard60 }
function TMyCustomFormWizard.GetDesigner: String;
begin
  Result := dVCL;
end;

{ TMyCustomFormWizardWizard.IOTARepositoryWizard80 }
function TMyCustomFormWizard.GetGalleryCategory: IOTAGalleryCategory;
var
  ACategoryManager: IOTAGalleryCategoryManager;
begin
  // The comments in ToolsAPI.pas say that the Gallery Categories will (probably)
  // exist, so they also might not. If sCategoryDelphiNewFiles doesn't exist in
  // the IDE we are running under or the IOTAGalleryCategoryManager is not supported
  // this method will return nil.
  //
  // In that event it will fall back to the GetPage method above which is part of
  // the IOTARepositoryWizard60 interface implmentation.
  // NOTE: We still must implemnt *both* interfaces for it to work in modern IDEs.

  OutputDebugString(PChar('Get Gallery Category ' + sCategoryDelphiNewFiles));
  if Supports(BorlandIDEServices, IOTAGalleryCategoryManager, ACategoryManager) then
    Result := ACategoryManager.FindCategory(sCategoryDelphiNewFiles)
  else
    Result := nil;

  if nil = Result then
    OutputDebugString(PChar('Error Getting Gallery Category ' + sCategoryDelphiNewFiles));
end;

function TMyCustomFormWizard.GetPersonality: String;
begin
  Result := sDelphiPersonality;
end;

{ TMyCustomFormWizardWizard.IOTACreator }
function TMyCustomFormWizard.GetCreatorType: String;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizard.GetExisting: Boolean;
begin
  Result := False;
end;

function TMyCustomFormWizard.GetFileSystem: String;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizard.GetOwner: IOTAModule;
begin
  Result := GetCurrentActiveProject;
end;

function TMyCustomFormWizard.GetUnnamed: Boolean;
begin
  Result := TRUE;
end;

{ TAppBarWizard.IOTAModuleCreator }
function TMyCustomFormWizard.GetAncestorName: string;
begin
  Result := 'TMyCustomForm';
end;

function TMyCustomFormWizard.GetImplFileName: string;
var
  CurrDir: array[0..MAX_PATH] of char;
  LImplFileName: String;
  LCurrentProject: IOTAProject;
begin
  LCurrentProject := GetCurrentActiveProject;
  if (nil <> LCurrentProject) and (LCurrentProject.ModuleFileCount > 0) then
  begin
    LImplFileName := String.Format('%s\%s.pas', [ExcludeTrailingPathDelimiter(ExtractFileDir(LCurrentProject.FileName)), FUnitIdent]);
    OutputDebugString(PChar('ImplFileName: ' + LImplFileName));
  end else
  begin
    // Note: full path name required!
    LImplFileName := '';//String.Format('%s\%s.pas', [CurrDir, FUnitIdent, '.pas']);
    //OutputDebugString(PChar('ImplFileName: ' + LImplFileName));
  end;
  //Result := String.Empty;
  Result := LImplFileName;
end;

function TMyCustomFormWizard.GetIntfFileName: string;
begin
  Result := String.Empty;
end;

function TMyCustomFormWizard.GetFormName: string;
begin
  OutputDebugString(PChar('GetFormName: ' + FClassName));
  Result := FClassName;
end;

function TMyCustomFormWizard.GetMainForm: Boolean;
begin
  Result := False;
end;

function TMyCustomFormWizard.GetShowForm: Boolean;
begin
  Result := True;
end;

function TMyCustomFormWizard.GetShowSource: Boolean;
begin
  Result := True;
end;

function TMyCustomFormWizard.NewFormFile(const FormIdent, AncestorIdent: string): IOTAFile;
begin
  OutputDebugString( PChar('TFormFile.Create('''', ''' + FormIdent +''', ''' + AncestorIdent + ''')') );
  Result := TFormFile.Create('', FormIdent, AncestorIdent);
end;

function TMyCustomFormWizard.NewImplSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
var
  LModule: String;
begin
  if String.IsNullorWhitespace(ModuleIdent) then
    OutputDebugString( PChar('TUnitFile.Create(String.Empty, ''' + FormIdent +''', ''' + AncestorIdent + ''')') )
  else
    OutputDebugString( PChar('TUnitFile.Create(''' + ModuleIdent + ''', ''' + FormIdent +''', ''' + AncestorIdent + ''')') );
  Result := TUnitFile.Create(ModuleIdent, FormIdent, AncestorIdent);
end;

function TMyCustomFormWizard.NewIntfSource(const ModuleIdent, FormIdent, AncestorIdent: string): IOTAFile;
begin
  Result := nil;
end;

procedure TMyCustomFormWizard.FormCreated(const FormEditor: IOTAFormEditor);
begin
  // do nothing
end;

end.
