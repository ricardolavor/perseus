unit AMFIOTest;

interface

uses
  TestFramework, Classes, SysUtils, PSAMFIO, PSAMFMessage, PSFilters, PSContext,
  PSGateway;

type

  TSerializationTest = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
  end;

  TDeserializationTest = class(TTestCase)
  strict private
    FGateway: TPerseusGateway;
    FRawInput: TStream;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure vai;
  end;

  TAMFMessageTest = class(TTestCase)
  private
    FMessage: TAMFMessage;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure AssignmentTest;
//    procedure HeaderAssignmentTest;
  end;



implementation

procedure TSerializationTest.SetUp;
begin
end;

procedure TSerializationTest.TearDown;
begin
end;

{ TDeserializationTest }

procedure TDeserializationTest.SetUp;

  function HexToByte(const AValue: AnsiString): Byte;
  const
    HEXDIGITS : array[1..16] of AnsiChar = '0123456789ABCDEF';
  begin
    Result:= (Pos(UpCase(AValue[1]), HEXDIGITS) - 1) * 16 +
      Pos(UpCase(AValue[2]), HEXDIGITS) - 1;
  end;

var
  RawData: AnsiString;
  I: Integer;
  b: Byte;
begin
  inherited;
  RawData :=
//    '00030000000100046E756C6C00022F32000001210A00000001110A81134F666C65782E6D6' +
//    '573736167696E672E6D657373616765732E52656D6F74696E674D6573736167650D736F75' +
//    '726365136F7065726174696F6E09626F64791574696D65546F4C69766511636C69656E744' +
//    '9641374696D657374616D701764657374696E6174696F6E136D65737361676549640F6865' +
//    '61646572730631536572766963654C6962726172792E4D795365727669636506194765744' +
//    '37573746F6D65727309010104000104000611666C756F72696E6506493435363734453739' +
//    '2D453534352D373830312D373543412D4134413745453344374132320A0B01154453456E6' +
//    '4706F696E74060D6D792D616D660944534964064137306361313739326164646534663532' +
//    '3831343538633163666263393334616501';
    '00030000000100046E756C6C00022F31000000CB0A00000001110A81134D666C65782E6' +
    'D6573736167696E672E6D657373616765732E436F6D6D616E644D657373616765136F70' +
    '65726174696F6E1B636F7272656C6174696F6E49641764657374696E6174696F6E11636' +
    'C69656E7449640F6865616465727309626F64791574696D65546F4C6976651374696D65' +
    '7374616D70136D6573736167654964040506010601010A0B01094453496406076E696C0' +
    '10A050104000400064930463239443134302D364634362D393045322D324232342D3946' +
    '43324643393437454243';

//    '00030000000100046E756C6C00022F31000000E00A00000001110A81134D666C65782E6' +
//    'D6573736167696E672E6D657373616765732E436F6D6D616E644D657373616765136F70' +
//    '65726174696F6E1B636F7272656C6174696F6E496411636C69656E7449641374696D657' +
//    '374616D701574696D65546F4C6976650F686561646572731764657374696E6174696F6E' +
//    '136D657373616765496409626F64790405060101040004000A0B012544534D657373616' +
//    '7696E6756657273696F6E0401094453496406076E696C01060106494544364133383742' +
//    '2D414335432D333445372D423939452D4243463939423630444432360A0501';
  FRawInput := TMemoryStream.Create;
  I := 1;
  while I <= Length(RawData) do
  begin
    b := HexToByte(Copy(RawData, I, 2));
    FRawInput.Write(b, SizeOf(b));
    Inc(I, 2);
  end;
  FRawInput.Position := 0;
  FGateway := TPerseusGateway.Create;
end;

procedure TDeserializationTest.TearDown;
begin
  inherited;
  FreeAndNil(FGateway);
  FreeAndNil(FRawInput);
end;

procedure TDeserializationTest.vai;
begin
  FGateway.Service(FRawInput);
end;

{ TAMFMessageTest }

procedure TAMFMessageTest.AssignmentTest;
var
  ClientId,
  Destination,
  Id: string;
  TimeStamp,
  TimeToLive: Integer;
  //Body: IAMFBody;
  Version: UInt16;
begin
  ClientId := '11';
  Destination := 'DST';
  Id := '1';
  TimeStamp := 1;
  TimeToLive := 2;
  Version := 3;
  //Body := TObject.Create;
  try
    FMessage.ClientId := ClientId;
    FMessage.Destination := Destination;
    FMessage.Id := Id;
    FMessage.TimeStamp := TimeStamp;
    FMessage.TimeToLive := TimeToLive;
    //FMessage.Body := Body;
    FMessage.Version := Version;

    CheckEquals(ClientId, FMessage.ClientId);
    CheckEquals(Destination, FMessage.Destination);
    CheckEquals(Id, FMessage.Id);
    CheckEquals(TimeStamp, FMessage.TimeStamp);
    CheckEquals(TimeToLive, FMessage.TimeToLive);
    //CheckSame(Body, FMessage.Body);
    CheckEquals(Version, FMessage.Version);
  finally
    //FreeAndNil(Body);
  end;
end;

//procedure TAMFMessageTest.HeaderAssignmentTest;
//var
//  Header1,
//  Header2: TObject;
//begin
//  Header1 := TObject.Create;
//  Header2 := TObject.Create;
//  try
//    FMessage.Headers['Header1'] := Header1;
//    FMessage.Headers['Header2'] := Header2;
//
//    CheckSame(Header1, FMessage.Headers['Header1']);
//    CheckSame(Header2, FMessage.Headers['Header2']);
//    try
//      FMessage.Headers['Header3'];
//      Check(False, 'Exception expected');
//    except
//    end;
//  finally
//    FreeAndNil(Header1);
//    FreeAndNil(Header2);
//  end;
//end;

procedure TAMFMessageTest.SetUp;
begin
  inherited;
  FMessage := TAMFMessage.Create;
end;

procedure TAMFMessageTest.TearDown;
begin
  inherited;
  FreeAndNil(FMessage);
end;

initialization
  RegisterTest(TAMFMessageTest.Suite);
  RegisterTest(TDeserializationTest.Suite);
end.

