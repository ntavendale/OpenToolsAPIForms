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

function InitialiseWizard(BIDES : IBorlandIDEServices) : TMyCustomFormWizardWizard;
begin
  Result := TMyCustomFormWizardWizard.Create;
  Application.Handle := (BIDES As IOTAServices).GetParentHandle;
end;

procedure Register;
var
  LWizard : TMyCustomFormWizardWizard;
begin
  RegisterNoIcon([TfmMyCustomForm]);
  RegisterCustomModule(TfmMyCustomForm , TCustomModule);

  // BorlandIDEServices is a global variable inmitilaized bu the Delphi/C++ builder IDE
  LWizard := InitialiseWizard(BorlandIDEServices);
  iWizard := (BorlandIDEServices As IOTAWizardServices).AddWizard(LWizard);
  AddCategory;
end;

initialization

finalization
  if iWizard > 0 Then
    (BorlandIDEServices As IOTAWizardServices).RemoveWizard(iWizard);
  if nil <> FCategory then
    RemoveCategory;

end.
