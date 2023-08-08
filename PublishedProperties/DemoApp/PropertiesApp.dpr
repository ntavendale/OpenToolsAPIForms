program PropertiesApp;

uses
  Vcl.Forms,
  Main in 'Main.pas' {Form1},
  CustomFrm in 'CustomFrm.pas' {fmNewCustom: TMyCustomForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfmNewCustom, fmNewCustom);
  Application.Run;
end.
