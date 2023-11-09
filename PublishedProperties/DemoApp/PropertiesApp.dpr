program PropertiesApp;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  AppCustomForm in 'AppCustomForm.pas' {fmAppCustomForm: TMyCustomForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfmAppCustomForm, fmAppCustomForm);
  Application.Run;
end.
