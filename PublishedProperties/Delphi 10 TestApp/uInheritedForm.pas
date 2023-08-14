unit uInheritedForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCommonForm, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmInheritedForm = class(TfrmCommonForm)
    Panel2: TPanel;
    mmoLog: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

var
  frmInheritedForm: TfrmInheritedForm;

implementation

{$R *.dfm}

{ TfrmInheritedForm }

constructor TfrmInheritedForm.Create(aOwner: TComponent);
begin
  inherited;
  mmoLog.Lines.Add('constructor TfrmInheritedForm.Create(aOwner: TComponent); Is called');
end;

procedure TfrmInheritedForm.FormCreate(Sender: TObject);
begin
  inherited;
  mmoLog.Lines.Add('Eventhandler procedure TfrmInheritedForm.FormCreate(Sender: TObject); Is called');
end;

end.
