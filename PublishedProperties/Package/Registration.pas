unit Registration;

interface

uses
  System.SysUtils, System.Classes, Vcl.Forms, Vcl.Dialogs,
  DesignIntf, // RegisterCustomModule lives here
  DesignEditors, // Supplies the TCustomModuleClass
  WinApi.Windows,
  MyCustomForm,
  CustomFormWizard,
  ToolsAPI; // IDEServices

Procedure Register;

implementation

var
  FWizardIndex : Integer = -1;

function InitialiseWizard(BIDES : IBorlandIDEServices) : TMyCustomFormWizard;
var
  Svc: IOTAServices;
begin
  Result := nil;
  if Supports(BIDES, IOTAServices, Svc) then
  begin
    Result := TMyCustomFormWizard.Create;
    Application.Handle := Svc.GetParentHandle;
  end;
end;

// In the package .bpl project options there is a Description secion.
// Under Description it says "A Basic Form Example". This is how it will appear
// in the Package manager when it is installed.
procedure Register;
var
  LWizard : TMyCustomFormWizard;
  WizardSvc: IOTAWizardServices;
begin
  RegisterNoIcon([TMyCustomForm]);
  RegisterCustomModule(TMyCustomForm , TCustomModule);

  // BorlandIDEServices is a global variable inmitilaized bu the Delphi/C++ builder IDE
  if Supports(BorlandIDEServices, IOTAWizardServices, WizardSvc) then
  begin
    LWizard := InitialiseWizard(BorlandIDEServices);
    if nil <> LWizard then
      FWizardIndex := WizardSvc.AddWizard(LWizard);
  end;
end;

initialization

finalization
  // This code run when IDE Closes or package is uninstalled
  if FWizardIndex > 0 then
    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(FWizardIndex);
end.
