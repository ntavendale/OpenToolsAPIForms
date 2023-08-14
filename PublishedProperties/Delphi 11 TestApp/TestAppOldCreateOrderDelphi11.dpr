program TestAppOldCreateOrderDelphi11;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {Form1},
  uCommonForm in 'uCommonForm.pas' {frmCommonForm},
  uInheritedForm in 'uInheritedForm.pas' {frmInheritedForm},
  uInheritedForm2 in 'uInheritedForm2.pas' {frmInheritedForm2};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
