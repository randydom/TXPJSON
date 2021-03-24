unit XPJSON;

interface

uses
  StrUtils, SysUtils, Math;

type
  TXPJsonType = (
    JSON_UNDEFINED  = 0,
    JSON_NULL       = 1,
    JSON_INTEGER    = 2,
    JSON_BOOLEAN    = 3,
    JSON_FLOAT      = 4,
    JSON_STRING     = 5,
    JSON_ARRAY      = 6
  );

  TXPJsonNull = class(TInterfacedObject, IInterface)
  end;

  TXPJsonInteger = class(TInterfacedObject, IInterface)
  public
    Value: Integer;
    constructor Create(AValue: Integer = 0);
  end;

  TXPJsonBoolean = class(TInterfacedObject, IInterface)
  public
    Value: Boolean;
    constructor Create(AValue: Boolean = False);
  end;

  TXPJsonFloat = class(TInterfacedObject, IInterface)
  public
    Value: Double;
    constructor Create(AValue: Double = 0.0);
  end;

  TXPJsonString = class(TInterfacedObject, IInterface)
  public
    Value: string;
    constructor Create(AValue: string = '');
  end;

  TXPJsonArray = class;
  IXPJsonArray = interface;

  TXPJson = record
  private
    FInterface: IInterface;
    FType: TXPJsonType;
    procedure SetType(AType: TXPJsonType);
    function GetValueOfInt(AKey: Integer): TXPJson;
    procedure SetValueOfInt(AKey: Integer; AValue: TXPJson);
    function GetValueOfBool(AKey: Boolean): TXPJson;
    procedure SetValueOfBool(AKey: Boolean; AValue: TXPJson);
    function GetValues(AKey: string): TXPJson;
    procedure SetValues(AKey: string; AValue: TXPJson);
    function GetText: string;
    procedure SetText(AValue: string);
    function GetAsInteger: Integer;
    function GetAsBoolean: Boolean;
    function GetAsFloat: Double;
    function GetAsString: string;
    function GetAsArray: TXPJsonArray;
    procedure SetAsInteger(AValue: Integer);
    procedure SetAsBoolean(AValue: Boolean);
    procedure SetAsFloat(AValue: Double);
    procedure SetAsString(AValue: string);
    function GetTextPretty: string;
    function EncodeText(AIndent: Integer = -1): string;
  public
    procedure Clear;
    function EscapeString(AString: string): string;

    class operator Implicit(AValue: Pointer): TXPJson;
    class operator Implicit(AValue: Boolean): TXPJson;
    class operator Implicit(AValue: Integer): TXPJson;
    class operator Implicit(AValue: Double): TXPJson;
    class operator Implicit(AValue: string): TXPJson;
    class operator Implicit(AValue: TXPJsonArray): TXPJson;

    class operator Implicit(AValue: TXPJson): Boolean;
    class operator Implicit(AValue: TXPJson): Integer;
    class operator Implicit(AValue: TXPJson): Double;
    class operator Implicit(AValue: TXPJson): string;

    class operator Negative(AValue: TXPJson): TXPJson;

    class operator Add(A: TXPJson; B: Integer): TXPJson;
    class operator Subtract(A: TXPJson; B: Integer): TXPJson;

    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsString: string read GetAsString write SetAsString;
    property AsArray: TXPJsonArray read GetAsArray;

    property Text: string read GetText write SetText;
    property TextPretty: string read GetTextPretty write SetText;
    property ValueType: TXPJsonType read FType write SetType;
    property Values[AKey: Integer]: TXPJson read GetValueOfInt write SetValueOfInt; default;
    property Values[AKey: Boolean]: TXPJson read GetValueOfBool write SetValueOfBool; default;
    property Values[AKey: string]: TXPJson read GetValues write SetValues; default;
  end;

  TXPJsonCodec = record
  private
    FPos, FMaxPos: Integer;
    FText: string;
    function GetChar: Char;
    function GetTrim: Char;
    function GetNumber: TXPJson;
    function GetString: string;
    function GetValue: TXPJson;
  public
    function Decode(AText: string): TXPJson;
  end;

  TXPJsonItem = record
    Key: string;
    Value: TXPJson;
  end;

  IXPJsonArray = interface
    function GetValues(AKey: string): TXPJson;
    procedure SetValues(AKey: string; AValue: TXPJson);
    function GetAssociated: Boolean;
    procedure SetAssociated(AValue: Boolean);
    function GetKeys(AIndex: Integer): string;
    function GetItems(AIndex: Integer): TXPJsonItem;
    procedure Clear;
    function Count: Integer;
    function IndexOf(AKey: string; AStart: Integer = -1; AStop: Integer = -1): Integer;
    procedure Assign(AArray: TXPJsonArray);
    function Push(AValue: TXPJson): Integer;
    property Associated: Boolean read GetAssociated write SetAssociated;
    property Keys[AIndex: Integer]: string read GetKeys;
    property Items[AIndex: Integer]: TXPJsonItem read GetItems;
    property Values[AKey: string]: TXPJson read GetValues write SetValues; default;
  end;

  TXPJsonArray = class(TInterfacedObject, IXPJsonArray)
  private
    FIndex: Integer;
    FAssociated: Boolean;
    FItems: array of TXPJsonItem;
    function GetValues(AKey: string): TXPJson;
    procedure SetValues(AKey: string; AValue: TXPJson);
    function GetAssociated: Boolean;
    procedure SetAssociated(AValue: Boolean);
    function GetKeys(AIndex: Integer): string;
    function GetItems(AIndex: Integer): TXPJsonItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Count: Integer;
    function IndexOf(AKey: string; AStart: Integer = -1; AStop: Integer = -1): Integer;
    procedure Assign(AArray: TXPJsonArray);
    function Push(AValue: TXPJson): Integer;
    property Associated: Boolean read GetAssociated write SetAssociated;
    property Keys[AIndex: Integer]: string read GetKeys;
    property Items[AIndex: Integer]: TXPJsonItem read GetItems;
    property Values[AKey: string]: TXPJson read GetValues write SetValues; default;
  end;

function JsonArrayOf(AValues: array of TXPJson): TXPJson;
function JsonNull: TXPJson;

implementation

function JsonArrayOf(AValues: array of TXPJson): TXPJson;
var
  arr: TXPJsonArray;
  n: Integer;
begin
  Result.SetType(JSON_ARRAY);
  arr := Result.AsArray;
  for n := 0 to High(AValues) do
  begin
    arr.Push(AValues[n]);
  end;
end;

function JsonNull: TXPJson;
begin
  Result.SetType(JSON_NULL);
end;

{ TXPJson }

procedure TXPJson.SetAsBoolean(AValue: Boolean);
begin
  FInterface := TXPJsonBoolean.Create(AValue);
  FType := JSON_BOOLEAN;
end;

procedure TXPJson.SetAsFloat(AValue: Double);
begin
  FInterface := TXPJsonFloat.Create(AValue);
  FType := JSON_FLOAT;
end;

procedure TXPJson.SetAsInteger(AValue: Integer);
begin
  FInterface := TXPJsonInteger.Create(AValue);
  FType := JSON_INTEGER;
end;

procedure TXPJson.SetAsString(AValue: string);
begin
  FInterface := TXPJsonString.Create(AValue);
  FType := JSON_STRING;
end;

procedure TXPJson.SetText(AValue: string);
var
  codec: TXPJsonCodec;
begin
  Clear;
  Self := codec.Decode(AValue);
end;

procedure TXPJson.SetType(AType: TXPJsonType);
begin
  case AType of
    JSON_NULL     : FInterface := TXPJsonNull.Create;
    JSON_INTEGER  : FInterface := TXPJsonInteger.Create;
    JSON_BOOLEAN  : FInterface := TXPJsonBoolean.Create;
    JSON_FLOAT    : FInterface := TXPJsonFloat.Create;
    JSON_STRING   : FInterface := TXPJsonString.Create;
    JSON_ARRAY    : FInterface := TXPJsonArray.Create;
  else
    FInterface := nil;
  end;
  FType := AType;
end;

procedure TXPJson.SetValueOfBool(AKey: Boolean; AValue: TXPJson);
begin
  SetValues(IfThen(Akey, '1', '0'), AValue);
end;

procedure TXPJson.SetValueOfInt(AKey: Integer; AValue: TXPJson);
begin
  SetValues(IntToStr(AKey), AValue);
end;

procedure TXPJson.SetValues(AKey: string; AValue: TXPJson);
begin
  case FType of
    JSON_UNDEFINED, JSON_NULL, JSON_ARRAY:
      AsArray[AKey] := AValue;
  else
    raise Exception.Create('Can not set array member of other JSON type');
  end;
end;

class operator TXPJson.Subtract(A: TXPJson; B: Integer): TXPJson;
begin
  case A.FType of
    JSON_INTEGER: Result := A.AsInteger - B;
    JSON_BOOLEAN: Result := IfThen(A.AsBoolean, 1, 0) - B;
    JSON_FLOAT: Result := A.AsFloat - Double(B);
    JSON_STRING: Result := A.AsString + IntToStr(B);
    JSON_ARRAY:
    begin
      Result := A;
      Result.AsArray.Push(B);
    end;
  else
    Result := -B;
  end;
end;

class operator TXPJson.Add(A: TXPJson; B: Integer): TXPJson;
begin
  case A.FType of
    JSON_INTEGER: Result.AsInteger := A.AsInteger + B;
    JSON_BOOLEAN: Result.AsInteger := A.AsInteger + B;
    JSON_FLOAT: Result.AsFloat := A.AsFloat + B;
    JSON_STRING: Result.AsString := A.AsString + IntToStr(B);
    JSON_ARRAY:
    begin
      Result := A.AsArray;
      Result.AsArray.Push(B);
    end
  else
    Result.AsInteger := B;
  end;
end;

procedure TXPJson.Clear;
begin
  SetType(JSON_UNDEFINED);
end;

function TXPJson.EncodeText(AIndent: Integer): string;
var
  arr: TXPJsonArray;
  n: Integer;
  spc, spc2, ret: string;
begin
  Result := '';
  if AIndent >= 0 then
  begin
    spc := DupeString(' ', AIndent);
    spc2 := spc + '  ';
    ret := #13#10;
  end
  else
  begin
    spc := '';
    spc2 := '';
    ret := ' ';
  end;
  case FType of
    JSON_UNDEFINED, JSON_NULL: Result := 'null';
    JSON_INTEGER: Result := IntToStr(AsInteger);
    JSON_BOOLEAN: Result := IfThen(AsBoolean, 'true', 'false');
    JSON_FLOAT: Result := FloatToStr(AsFloat);
    JSON_STRING: Result := '"' + EscapeString(AsString) + '"';
    JSON_ARRAY:
    begin
      arr := AsArray;
      for n := 0 to arr.Count - 1 do
      begin
        if Result <> '' then Result := Result + ',' + ret;
        Result := Result + spc2;
        if arr.Associated then Result := Result + '"' + EscapeString(arr.Items[n].Key) + '": ';
        Result := Result + arr.Items[n].Value.EncodeText(IfThen(AIndent >= 0, AIndent + 2, -1));
      end;
      if arr.Associated then
        Result := '{' + ret + Result + ret + spc + '}'
      else Result := '[' + ret + Result + ret + spc + ']';
    end;
  end;
end;

function TXPJson.EscapeString(AString: string): string;
var
  n, nmax: Integer;
  c, d: Char;
begin
  Result := '';
  nmax := Length(AString);
  n := 1;
  while n <= nmax do
  begin
    c := ASTring[n];
    if n < nmax then
      d := AString[n + 1]
    else d := #0;
    case c of
      #9: Result := Result + '\t';
      #10: Result := Result + '\n';
      #13:
      begin
        if d = #10 then
        begin
          Result := Result + '\n';
          Inc(n);
        end
        else Result := Result + '\r';
      end;
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
    else
      Result := Result + c;
    end;
    Inc(n);
  end;
end;

function TXPJson.GetAsArray: TXPJsonArray;
begin
  if FType = JSON_ARRAY then
    if TXPJsonArray(FInterface).FRefCount > 1 then
    begin
      Result := TXPJsonArray.Create;
      Result.Assign(TXPJsonArray(FInterface));
      FInterface := Result;
    end
    else Result := TXPJsonArray(FInterface)
  else
  begin
    Result := TXPJsonArray.Create;
    case FType of
      JSON_INTEGER: TXPJsonArray(Result).Push(AsInteger);
      JSON_BOOLEAN: TXPJsonArray(Result).Push(AsBoolean);
      JSON_FLOAT: TXPJsonArray(Result).Push(AsFloat);
      JSON_STRING: TXPJsonArray(Result).Push(AsString);
    end;
    FInterface := Result;
    FType := JSON_ARRAY;
  end;
end;

function TXPJson.GetAsBoolean: Boolean;
var
  s: string;
begin
  case FType of
    JSON_INTEGER: Result := TXPJsonInteger(FInterface).Value <> 0;
    JSON_BOOLEAN: Result := TXPJsonBoolean(FInterface).Value;
    JSON_FLOAT: Result := TXPJsonFloat(FInterface).Value <> 0.0;
    JSON_STRING:
    begin
      s := UpperCase(TXPJsonString(FInterface).Value);
      Result := (s = 'TRUE') or (StrToFloatDef(s, 0.0) <> 0.0);
    end;
    JSON_ARRAY: Result := False;
  else
    Result := False;
  end;
end;

function TXPJson.GetAsFloat: Double;
begin
  case FType of
    JSON_INTEGER: Result := TXPJsonInteger(FInterface).Value;
    JSON_BOOLEAN: Result := IfThen(TXPJsonBoolean(FInterface).Value, 1.0, 0.0);
    JSON_FLOAT: Result := TXPJsonFloat(FInterface).Value;
    JSON_STRING: Result := StrToFloatDef(TXPJsonString(FInterface).Value, 0.0);
    JSON_ARRAY: Result := 0.0;
  else
    Result := 0.0;
  end;
end;

function TXPJson.GetAsInteger: Integer;
begin
  case FType of
    JSON_INTEGER: Result := TXPJsonInteger(FInterface).Value;
    JSON_BOOLEAN: Result := IfThen(TXPJsonBoolean(FInterface).Value, 1, 0);
    JSON_FLOAT: Result := Round(TXPJsonFloat(FInterface).Value);
    JSON_STRING: Result := StrToIntDef(TXPJsonString(FInterface).Value, 0);
    JSON_ARRAY: Result := 0;
  else
    Result := 0;
  end;
end;

function TXPJson.GetAsString: string;
begin
  case FType of
    JSON_INTEGER: Result := IntToStr(TXPJsonInteger(FInterface).Value);
    JSON_BOOLEAN: Result := IfThen(TXPJsonBoolean(FInterface).Value, '1', '0');
    JSON_FLOAT: Result := FloatToStr(TXPJsonFloat(FInterface).Value);
    JSON_STRING: Result := TXPJsonString(FInterface).Value;
    JSON_ARRAY: Result := 'Array';
  else
    Result := '';
  end;
end;

function TXPJson.GetText: string;
begin
  Result := EncodeText;
end;

function TXPJson.GetTextPretty: string;
begin
  Result := EncodeText(0);
end;

function TXPJson.GetValueOfBool(AKey: Boolean): TXPJson;
begin
  Result := GetValues(IfThen(AKey, '1', '0'));
end;

function TXPJson.GetValueOfInt(AKey: Integer): TXPJson;
begin
  Result := GetValues(IntToStr(AKey));
end;

function TXPJson.GetValues(AKey: string): TXPJson;
begin
  if FType = JSON_ARRAY then
    Result := AsArray[AKey]
  else raise Exception.Create('Can not get array member on other JSON type');
end;

class operator TXPJson.Implicit(AValue: Pointer): TXPJson;
begin
  if (AValue <> nil) then raise Exception.Create('Can non assign pointer to JSON');
  Result.Clear;
end;

class operator TXPJson.Implicit(AValue: Double): TXPJson;
begin
  Result.AsFloat := AValue;
end;

class operator TXPJson.Implicit(AValue: Integer): TXPJson;
begin
  Result.AsInteger := AValue;
end;

class operator TXPJson.Implicit(AValue: Boolean): TXPJson;
begin
  Result.AsBoolean := AValue;
end;

class operator TXPJson.Implicit(AValue: string): TXPJson;
begin
  Result.AsString := AValue;
end;

class operator TXPJson.Implicit(AValue: TXPJson): string;
begin
  Result := AValue.AsString;
end;

class operator TXPJson.Negative(AValue: TXPJson): TXPJson;
begin
  case AValue.ValueType of
    JSON_INTEGER: Result := -AValue.AsInteger;
    JSON_BOOLEAN: Result := not AValue.AsBoolean;
    JSON_FLOAT: Result := -AValue.AsFloat;
    JSON_STRING: Result := ReverseString(AValue.AsString);
  else
    Result := AValue;
  end;
end;

class operator TXPJson.Implicit(AValue: TXPJsonArray): TXPJson;
begin
  Result.Clear;
  Result.AsArray.Assign(TXPJsonArray(AValue));
end;

class operator TXPJson.Implicit(AValue: TXPJson): Double;
begin
  Result := AValue.AsFloat;
end;

class operator TXPJson.Implicit(AValue: TXPJson): Integer;
begin
  Result := AValue.AsInteger;
end;

class operator TXPJson.Implicit(AValue: TXPJson): Boolean;
begin
  Result := AValue.AsBoolean;
end;

{ TXPJsonArray }

procedure TXPJsonArray.Assign(AArray: TXPJsonArray);
var
  n: Integer;
begin
  SetLength(FItems, Length(AArray.FItems));
  for n := 0 to Length(AArray.FItems) - 1 do
  begin
    FItems[n] := AArray.FItems[n];
  end;
  FIndex := AArray.FIndex;
  FAssociated := AArray.FAssociated;
end;

procedure TXPJsonArray.Clear;
var
  n: Integer;
begin
  n := Length(FItems);
  while n > 0 do
  begin
    Dec(n);
    FItems[n].Value.SetType(JSON_UNDEFINED);
  end;
  FItems := nil;
end;

function TXPJsonArray.Count: Integer;
begin
  Result := Length(FItems);
end;

constructor TXPJsonArray.Create;
begin
  FItems := nil;
  FIndex := 0;
  FAssociated := False;
end;

destructor TXPJsonArray.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TXPJsonArray.GetAssociated: Boolean;
begin
  Result := FAssociated;
end;

function TXPJsonArray.GetItems(AIndex: Integer): TXPJsonItem;
begin
  Result := FItems[AIndex];
end;

function TXPJsonArray.GetKeys(AIndex: Integer): string;
begin
  Result := FItems[AIndex].Key;
end;

function TXPJsonArray.GetValues(AKey: string): TXPJson;
var
  n: Integer;
begin
  n := IndexOf(AKey);
  if n >= 0 then
    Result := FItems[n].Value
  else Result := nil;
end;

function TXPJsonArray.IndexOf(AKey: string; AStart, AStop: Integer): Integer;
var
  n: integer;
begin
  Result := -1;
  n := Length(FItems);
  while (Result < 0) and (n > 0) do
  begin
    Dec(n);
    if FItems[n].Key = AKey then Result := n;
  end;
end;

function TXPJsonArray.Push(AValue: TXPJson): Integer;
begin
  Result := FIndex;
  SetValues(IntToStr(Result), AValue);
end;

procedure TXPJsonArray.SetAssociated(AValue: Boolean);
begin
  FAssociated := AValue;
end;

procedure TXPJsonArray.SetValues(AKey: string; AValue: TXPJson);
var
  v: TXPJsonItem;
  n: Integer;
begin
  n := IndexOf(AKey);
  if n >= 0 then
    FItems[n].Value := AValue
  else
  begin
    n := Length(FItems);
    v.Key := AKey;
    v.Value := AValue;
    Insert(v, FItems, n);
    if IntToStr(FIndex) = AKey then
      Inc(FIndex)
    else FAssociated := True;
  end;
end;

{ TXPJsonString }

constructor TXPJsonString.Create(AValue: string);
begin
  Value := AValue;
end;

{ TXPJsonInteger }

constructor TXPJsonInteger.Create(AValue: Integer);
begin
  Value := AValue;
end;

{ TXPJsonBoolean }

constructor TXPJsonBoolean.Create(AValue: Boolean);
begin
  Value := AValue;
end;

{ TXPJsonFloat }

constructor TXPJsonFloat.Create(AValue: Double);
begin
  Value := AValue;
end;

{ TXPJsonCodec }

function TXPJsonCodec.Decode(AText: string): TXPJson;
begin
  FText := AText;
  FPos := 1;
  FMaxPos := Length(FText);
  Result := GetValue;
end;

function TXPJsonCodec.GetChar: Char;
begin
  if FPos <= FMaxPos then
    Result := FText[FPos]
  else Result := #26;
end;

function TXPJsonCodec.GetNumber: TXPJson;
var
  apos: Integer;
  s: string;
  dm: Boolean;
  c: Char;
begin
  apos := FPos;
  c := GetChar;
  while (c >= '0') and (c <= '9') do
  begin
    Inc(FPos);
    c := GetChar;
  end;
  dm := c = '.';
  if dm then
  begin
    Inc(FPos);
    c := GetChar;
    while (c >= '0') and (c <= '9') do
    begin
      Inc(FPos);
      c := GetChar;
    end;
  end;
  s := Copy(FText, apos, FPos - apos);
  if dm then
    Result := StrToFloatDef(s, 0.0)
  else Result := StrToIntDef(s, 0);
end;

function TXPJsonCodec.GetString: string;
var
  c: Char;
begin
  Result := '';
  if GetTrim <> '"' then raise Exception.Create('Invalid JSON string.');
  Inc(FPos);
  c := GetTrim;
  while (c <> '"') and (c <> #26) do
  begin
    case c of
      '\':
      begin
        Inc(FPos);
        c := GetChar;
        case c of
          '\': Result := Result + '\';
          '/': Result := Result + '/';
          '"': Result := Result + '"';
          'b': Result := Result + #8;
          'f': Result := Result + #12;
          'n': Result := Result + #10;
          'r': Result := Result + #13;
          't': Result := Result + #9;
          'u':
          begin
            Result := Result + Copy(FText, FPos + 1, 4);
            Inc(FPos, 5);
          end
        else
          Result := Result + c;
        end;
      end;
    else
      Result := Result + c;
    end;
    Inc(FPos);
    c := GetChar;
  end;
  if GetChar <> '"' then raise Exception.Create('Invalid JSON string.');
  Inc(FPos);
end;

function TXPJsonCodec.GetTrim: Char;
begin
  Result := GetChar;
  while ((Result = ' ') or (Result = #13) or (Result = #10) or (Result = #9)) do
  begin
    Inc(FPos);
    Result := GetChar;
  end;
end;

function TXPJsonCodec.GetValue: TXPJson;
var
  arr: TXPJsonArray;
  v: TXPJson;
  s: string;
  c: Char;
begin
  Result := nil;
  c := UpCase(GetTrim);
  case c of
    'N':
      if UpperCase(Copy(FText, FPos, 4)) = 'NULL' then
      begin
        Result := JsonNull;
        Inc(FPos, 4);
      end
      else raise Exception.Create('Invalid JSON value.');
    'T':
      if UpperCase(Copy(FText, FPos, 4)) = 'TRUE' then
      begin
        Result := True;
        Inc(FPos, 4);
      end
      else raise Exception.Create('Invalid JSON value.');
    'F':
      if UpperCase(Copy(FText, FPos, 5)) = 'FALSE' then
      begin
        Result := False;
        Inc(FPos, 5);
      end
      else raise Exception.Create('Invalid JSON value.');
    '[':
    begin
      Inc(FPos);
      arr := Result.AsArray;
      v := GetValue;
      while v.ValueType <> JSON_UNDEFINED do
      begin
        arr.Push(v);
        c := GetTrim;
        if c = ',' then
        begin
          Inc(FPos);
          v := GetValue;
        end
        else v := nil;
      end;
      c := GetTrim;
      if c = ']' then
        Inc(FPos)
      else raise Exception.Create('Invalid JSON array.');
    end;
    '{':
    begin
      Inc(FPos);
      arr := Result.AsArray;
      c := GetTrim;
      while (c <> '}') and (c <> #26) do
      begin
        s := GetString;
        if GetTrim <> ':' then raise Exception.Create('Invalid JSON object.');
        Inc(FPos);
        v := GetValue;
        arr[s] := v;
        c := GetTrim;
        if c = ',' then
        begin
          Inc(FPos);
          c := GetTrim;
        end
        else c := '}';
      end;
      if GetTrim <> '}' then raise Exception.Create('Invalid JSON object');
      Inc(FPos);
    end;
    '0'..'9','.': Result := GetNumber;
    '+':
    begin
      Inc(FPos);
      Result := GetNumber;
    end;
    '-':
    begin
      Inc(FPos);
      Result := -GetNumber;
    end;
    '"': Result := GetString;
  else
    raise Exception.Create('Invalid JSON data.');
  end;
end;

end.
