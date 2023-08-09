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
  iWizard : Integer;

function InitialiseWizard(BIDES : IBorlandIDEServices) : TMyCustomFormWizard;
begin
  Result := TMyCustomFormWizard.Create;
  Application.Handle := (BIDES As IOTAServices).GetParentHandle;
end;

// In the package .bpl project options there is a Description secion.
// Under Description it says "A Basic Form Example". This is how it will appear
// in the Package manager when it is installed.
procedure Register;
var
  LWizard : TMyCustomFormWizard;
begin
  RegisterNoIcon([TMyCustomForm]);
  RegisterCustomModule(TMyCustomForm , TCustomModule);

  // BorlandIDEServices is a global variable inmitilaized bu the Delphi/C++ builder IDE
  LWizard := InitialiseWizard(BorlandIDEServices);
  iWizard := (BorlandIDEServices As IOTAWizardServices).AddWizard(LWizard);
end;

initialization

finalization
  // This code run when IDE Closes or package is uninstalled
  if iWizard > 0 Then
    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iWizard);
end.
