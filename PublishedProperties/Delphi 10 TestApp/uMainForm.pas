unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uInheritedForm, uInheritedForm2;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not assigned(frmInheritedForm) then
    frmInheritedForm := TfrmInheritedForm.Create(Application);
  frmInheritedForm.Show;
  if not assigned(frmInheritedForm2) then
    frmInheritedForm2 := TfrmInheritedForm2.Create(Application);
  frmInheritedForm2.Show;
end;

end.
