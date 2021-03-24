# TXPJSON
 Easy JSON object for Delphi

```Delphi
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
  k8['flag'] := 'continue';
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
```

>k0: null
>k1: 56
>k2: 22.901
>k3: { "5": "Delphi23" }
>k4: { "ID": null }
>k5: [ 1, 2, 3, 4, 5.5, "abc", true, false, null ]
>k6: [ 1, 2, 3, 4, 5.5, "abc", true, "A", null, "B" ]
>k7: { "0": 1, "1": 2, "2": 3, "3": 4, "4": 5.5, "5": "abc", "6": true, "7": "A", "8": null, "9": "B", "flag": "end" }
>k8: { "0": 1, "1": 2, "2": 3, "3": 4, "4": 5.5, "5": "abc", "6": true, "7": "A", "8": null, "9": "B", "flag": "continue" }
>k9: { ... }
