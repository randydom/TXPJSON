unit Form_Main;

interface

uses
  XPJSON,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFormMain = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.Button1Click(Sender: TObject);
var
  k0, k1, k2, k3, k4, k5, k6, k7, k8, k9: TXPJson;
begin
  k1 := 56;
  k2 := 78.901 - k1;
  k3[5] := 'Delphi' + k2;
  k4['ID'] := nil;
  k5 := JsonArrayOf([1, 2, 3, 4, 5.5, 'abc', True, False, nil]);
  k6 := k5;
  k6['7'] := 'A';
  k6['9'] := 'B';
  k7 := k6;
  k7['flag'] := 'end';
  k8.Text := k6.Text;
  k8['members'] := JsonArrayOf(['continue', 111.999]);
  k9.Text := Memo2.Text;
  Memo1.Lines.Add(Format('k0: %s', [k0.Text]));
  Memo1.Lines.Add(Format('k1: %s', [k1.Text]));
  Memo1.Lines.Add(Format('k2: %s', [k2.Text]));
  Memo1.Lines.Add(Format('k3: %s', [k3.Text]));
  Memo1.Lines.Add(Format('k4: %s', [k4.Text]));
  Memo1.Lines.Add(Format('k5: %s', [k5.Text]));
  Memo1.Lines.Add(Format('k6: %s', [k6.Text]));
  Memo1.Lines.Add(Format('k7: %s', [k7.Text]));
  Memo1.Lines.Add(Format('k8: %s', [k8.Text]));
  Memo1.Lines.Add(Format('k9: %s', [k9.TextPretty]));
end;

end.
