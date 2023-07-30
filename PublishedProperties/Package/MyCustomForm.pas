unit MyCustomForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfmMyCustomForm = class(TForm)
  private
    { Private declarations }
    FMyPublishedStringProperty: String;
  public
    { Public declarations }
  published
    // The publised property. When you create a new instance of this form It will
    // show in the object inspector.
    property MyPublishedStringProperty: String read FMyPublishedStringProperty write FMyPublishedStringProperty;
  end;

// When the IDE creates a new form it needs to fill the dfm file with the basic code.
// This is where it gets that code.
function GetMyCustomFormDfmFileText: String;

// When the IDE creates a new form it needs to fill the pas file with the basic code.
// This is where it gets that code.
function GetMyCustomFormPasFileText: String;

implementation

{$R *.dfm}

function GetMyCustomFormDfmFileText: String;
begin
  // Bare minimum .dfm text
  Result := 'object %0:s: T%0:s'#13#10'end';
end;

function GetMyCustomFormPasFileText: String;
var
  LStrings: TStrings;
begin
  LStrings := TStringList.Create;
  try
    LStrings.Add('unit %0:s;');
    LStrings.Add('');
    LStrings.Add('interface');
    LStrings.Add('');
    LStrings.Add('uses');
    LStrings.Add('  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, MyCustomForm, ');
    LStrings.Add('  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;');
    LStrings.Add('');
    LStrings.Add('type');
    LStrings.Add('  T%1:s = class(%2:s)');
    LStrings.Add('  private');
    LStrings.Add('  { Private declarations }');
    LStrings.Add('  public');
    LStrings.Add('  { Public declarations }');
    LStrings.Add('  end;');
    LStrings.Add('');
    LStrings.Add('var');
    LStrings.Add('');
    LStrings.Add('%1:s: T%1:s;');
    LStrings.Add('');
    LStrings.Add('implementation');
    LStrings.Add('');
    LStrings.Add('{$R *.DFM}');
    LStrings.Add('');
    LStrings.Add('end.');
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

end.
