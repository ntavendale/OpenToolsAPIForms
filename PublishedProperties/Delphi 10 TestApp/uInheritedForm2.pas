unit uInheritedForm2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCommonForm, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmInheritedForm2 = class(TfrmCommonForm)
    Panel2: TPanel;
    mmoLog: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor create(aOwner: TComponent); override;
  end;

var
  frmInheritedForm2: TfrmInheritedForm2;

implementation

{$R *.dfm}

{ TfrmInheritedForm2 }

constructor TfrmInheritedForm2.create(aOwner: TComponent);
begin
  inherited;
  mmoLog.Lines.Add('constructor TfrmInheritedForm.Create(aOwner: TComponent); Is called');
end;

procedure TfrmInheritedForm2.FormCreate(Sender: TObject);
begin
  inherited;
  mmoLog.Lines.Add('Eventhandler procedure TfrmInheritedForm.FormCreate(Sender: TObject); Is called');
end;

end.
