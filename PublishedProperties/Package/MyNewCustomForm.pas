unit MyNewCustomForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, MyCustomForm,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfmMyCustomForm1 = class(TfmMyCustomForm)
  private
  { Private declarations }
  public
  { Public declarations }
  end;

var

fmMyCustomForm1: TfmMyCustomForm1;

implementation

{$R *.DFM}

end.
