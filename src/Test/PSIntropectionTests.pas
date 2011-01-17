unit PSIntropectionTests;

interface

uses
  TestFramework, Classes, SysUtils, PSInstrospection;

type

  TIntrospectionHelperTest = class(TTestCase)
  private
    FObj: TObject;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure SetPropValue;
    procedure SetFieldValue;
    procedure SetActionScriptObjectAsValue;
  end;

  TActivatorTest = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckRegister;
    procedure EnsureCreation;
  end;

implementation

uses
  PSCommonTypes;

type

  TTempClass = class
  private
    FPropInt: Integer;
    FPropStr: string;
    procedure SetPropInt(const Value: Integer);
    procedure SetPropStr(const Value: string);
  public
    FieldDouble: Double;
    property PropInt: Integer read FPropInt write SetPropInt;
    property PropStr: string read FPropStr write SetPropStr;
  end;

{ TMockClass }

procedure TTempClass.SetPropInt(const Value: Integer);
begin
  FPropInt := Value;
end;

procedure TTempClass.SetPropStr(const Value: string);
begin
  FPropStr := Value;
end;

{ TIntrospectionHelperTest }

procedure TIntrospectionHelperTest.SetUp;
begin
  inherited;
  FObj := TTempClass.Create;
end;

procedure TIntrospectionHelperTest.TearDown;
begin
  inherited;
  FreeAndNil(FObj);
end;

procedure TIntrospectionHelperTest.SetActionScriptObjectAsValue;
var
  ASObject: TActionScriptObject;
  IntValue: Integer;
begin
  ASObject := TActionScriptObject.Create;
  try
    IntValue := 200;
    TInstrospectionHelper.SetValue(ASObject, 'Dummy', TAMFObject.Create(TIntegerObject.Create(IntValue)));
    CheckEquals(IntValue, TIntegerObject(ASObject['Dummy'].Value).PrimitiveValue);
  finally
    FreeAndNil(ASObject);
  end;
end;

procedure TIntrospectionHelperTest.SetFieldValue;
var
  DoubleValue: Double;
begin
  DoubleValue := 1.11;
  TInstrospectionHelper.SetValue(FObj, 'FieldDouble', TAMFObject.Create(TDoubleObject.Create(DoubleValue)));
  CheckEquals(DoubleValue, TTempClass(FObj).FieldDouble);
end;

procedure TIntrospectionHelperTest.SetPropValue;
var
  IntValue: Integer;
  StrValue: string;
begin
  IntValue := 15;
  TInstrospectionHelper.SetValue(FObj, 'PropInt', TAMFObject.Create(TIntegerObject.Create(IntValue)));
  CheckEquals(IntValue, TTempClass(FObj).PropInt);

  StrValue := 'Perseus';
  TInstrospectionHelper.SetValue(FObj, 'PropStr', TAMFObject.Create(TStringObject.Create(StrValue)));
  CheckEquals(StrValue, TTempClass(FObj).PropStr);
end;

{ TActivatorTest }

procedure TActivatorTest.CheckRegister;
begin
  CheckEquals(TTempClass, TClassManager.GetClass(TTempClass.ClassName));
end;

procedure TActivatorTest.EnsureCreation;
var
  Obj: TTempClass;
begin
  Obj := TTempClass(TClassManager.CreateInstance(TTempClass.ClassName));
  try
    CheckNotNull(Obj);
  finally
    FreeAndNil(Obj);
  end;
end;

procedure TActivatorTest.SetUp;
begin
  inherited;
  TClassManager.RegisterClass(TTempClass);
end;

procedure TActivatorTest.TearDown;
begin
  inherited;
  TClassManager.UnregisterClass(TTempClass);
end;

initialization
  RegisterTests('Introspection tests', [TActivatorTest.Suite, TIntrospectionHelperTest.Suite]);

end.
