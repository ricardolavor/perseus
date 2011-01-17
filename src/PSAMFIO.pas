{
  [perseus project]

  Copyright (C) 2010 Ricardo Lavor (riccesar@gmail.com)

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 3 of the License, or (at your option)
  any later version.

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/licenses/gpl-3.0.txt>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
}

unit PSAMFIO;

interface

uses
  Classes, SysUtils, PSAMFBody, PSAMFHeader, PSAMFMessage, PSCommonTypes,
  Contnrs, Generics.Collections, XMLDoc, PSClassDefinition;

type

  TAMFReader = class;

  TAMFWriter = class
  end;

  IExternalizable = interface
    ['{AC4F4C66-D1AB-4747-847C-2659AA2A4275}']
    procedure ReadData(AReader: TAMFReader);
    procedure WriteData(AWriter: TAMFWriter);
  end;

  IAMFSerializer = interface
    ['{D8EBB32C-F57E-469E-9631-82909FE6BF25}']
  end;

  TAMF0TypeMarkers = class sealed
    const
      NUMBER = $00;
      BOOLEAN = $01;
      STR = $02;
      AS_OBJECT = $03;
      MOVIECLIP = $04; //reserved, not supported
      NULL = $05;
      UNDEFINED = $06;
      REFERENCE = $07;
      ECMA_ARRAY = $08;
      OBJECT_END = $09;
      STRICT_ARRAY = $0A;
      DATE = $0B;
      LONG_STRING = $0C;
      UNSUPPORTED = $0D;
      RECORDSET = $0E; //reserved, not supported
      XML_DOCUMENT = $0F;
      TYPED_OBJECT = $10;
      AVM_PLUS = $11;
  end;

  TAMF3TypeMarkers = class sealed
    const
      UNDEFINED = $00;
      NULL = $01;
      FALSE = $02;
      TRUE = $03;
      INTEGER = $04;
      DOUBLE = $05;
      STR = $06;
      XML_DOCUMENT = $07;
      DATE = $08;
      AMF3_ARRAY = $09;
      AS_OBJECT = $0A;
      XML = $0B;
  end;

  TAMFReader = class(TBinaryReader)
  strict private
    FAMF3References,
    FDefReferences,
    FReferences: TList<IAMFObject>;
    FStringReferences: TList<string>;
    procedure ClearReferences;
    function GetStringReference(AIndex: Integer): string;
    function GetReference(AList: TList<IAMFObject>; AIndex: Integer): IAMFObject;
    function ReadObject(ATypeMarker: Byte): IAMFObject; overload;
    function ReadObject: IAMFObject; overload;
    function ReadString(ALength: Integer): string; reintroduce; overload;
    function ReadAMF3Integer: Integer;
    function ReadAMF3Object(ATypeMarker: Byte): IAMFObject; overload;
    function ReadAMF3Object: IAMFObject; overload;
    function ReadAMF3ClassDefinition: IAMFObject;
    function ReadAMF3String: string;
    function ReadAMF3Date: TDateTime;
    function ReadAMF3Array: IAMFObject;
    function ReadLongString: string;
    function ReadActionScriptObject: IAMFObject;
    function ReadECMAArray: IAMFObject;
    function ReadStrictArray: IAMFObject;
    function ReadReference: IAMFObject;
    function ReadDateTime: TDateTime;
    function ReadXMLDocument: IAMFObject;
  public
    function ReadString: string; overload; override;
    function ReadWord: Word; override;
    function ReadInteger: Integer; override;
    function ReadHeader: IAMFHeader;
    function ReadBody: IAMFBody;
    function ReadDouble: Double; override;
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;

implementation

uses
  DateUtils, PSInstrospection;

{ TAMFReader }

procedure TAMFReader.AfterConstruction;
begin
  inherited;
  FReferences := TList<IAMFObject>.Create;
  FAMF3References := TList<IAMFObject>.Create;
  FStringReferences := TList<string>.Create;
  FDefReferences := TList<IAMFObject>.Create;
end;

procedure TAMFReader.ClearReferences;
begin
  FAMF3References.Clear;
  FReferences.Clear;
  FStringReferences.Clear;
  FDefReferences.Clear;
end;

destructor TAMFReader.Destroy;
begin
  FreeAndNil(FReferences);
  FreeAndNil(FAMF3References);
  FreeAndNil(FStringReferences);
  FreeAndNil(FDefReferences);
  inherited;
end;

function TAMFReader.GetReference(AList: TList<IAMFObject>; AIndex: Integer): IAMFObject;
begin
  if (AIndex >= 0) and (AIndex < AList.Count) then
    Result := AList[AIndex]
  else
    raise Exception.Create('Reference index is out of bounds');
end;

function TAMFReader.GetStringReference(AIndex: Integer): string;
begin
  if (AIndex >= 0) and (AIndex < FStringReferences.Count) then
    Result := FStringReferences[AIndex]
  else
    raise Exception.Create('String reference index is out of bounds');
end;

function TAMFReader.ReadActionScriptObject: IAMFObject;
var
  Key: string;
  TypeMarker: Byte;
  ASObject: TActionScriptObject;
begin
  ASObject := TActionScriptObject.Create;
  Result := TAMFObject.Create(ASObject);
  FReferences.Add(Result);
  while True do
  begin
    Key := ReadString;
    TypeMarker := ReadByte;
    if TypeMarker = TAMF0TypeMarkers.OBJECT_END then
      Exit;
    ASObject[Key] := ReadObject(TypeMarker);
  end;
end;

function TAMFReader.ReadAMF3Object(ATypeMarker: Byte): IAMFObject;
begin
  case ATypeMarker of
    TAMF3TypeMarkers.UNDEFINED,
    TAMF3TypeMarkers.NULL:
      Result := nil;
    TAMF3TypeMarkers.TRUE:
      Result := TAMFObject.Create(TBooleanObject.Create(True));
    TAMF3TypeMarkers.FALSE:
      Result := TAMFObject.Create(TBooleanObject.Create(False));
    TAMF3TypeMarkers.INTEGER:
      Result := TAMFObject.Create(TIntegerObject.Create(ReadAMF3Integer));
    TAMF3TypeMarkers.DOUBLE:
      Result := TAMFObject.Create(TDoubleObject.Create(ReadDouble));
    TAMF3TypeMarkers.STR:
      Result := TAMFObject.Create(TStringObject.Create(ReadAMF3String));
    TAMF3TypeMarkers.DATE:
      Result := TAMFObject.Create(TDateTimeObject.Create(ReadAMF3Date));
    TAMF3TypeMarkers.AMF3_ARRAY:
      Result := ReadAMF3Array;
    TAMF3TypeMarkers.AS_OBJECT:
      Result := ReadAMF3ClassDefinition;
  end;
end;

function TAMFReader.ReadAMF3Array: IAMFObject;
var
  I,
  &Type,
  ReferenceLength: Integer;
  IsReference: Boolean;
  AssociativeArray: TDictionary<string, IAMFObject>;
  StrictArray: TList<IAMFObject>;
  Key: string;
begin
  &Type := ReadAMF3Integer;
  IsReference := (&Type and 1) = 0;
  if IsReference then
    Result := GetReference(FAMF3References, &Type shr 1)
  else
  begin
    ReferenceLength := &Type shr 1;
    Key := ReadAMF3String;
    if Key <> '' then
    begin
      AssociativeArray := TDictionary<string, IAMFObject>.Create;
      Result := TAMFObject.Create(AssociativeArray);
      FAMF3References.Add(Result);
      repeat
        AssociativeArray.Add(Key, ReadAMF3Object);
        Key := ReadAMF3String;
      until Key = '';
      for I := 0 to Pred(ReferenceLength) do
        AssociativeArray.Add(InttoStr(I), ReadAMF3Object);
    end
    else
    begin
      StrictArray := TList<IAMFObject>.Create;
      Result := TAMFObject.Create(StrictArray);
      FAMF3References.Add(Result);
      for I := 0 to Pred(ReferenceLength) do
        StrictArray.Add(ReadAMF3Object);
    end;
  end;
end;

function TAMFReader.ReadAMF3Date: TDateTime;
var
  &Type: Integer;
  IsReference: Boolean;
begin
  &Type := ReadAMF3Integer;
  IsReference := (&Type and 1) = 0;
  if IsReference then
    Result := TDateTimeObject(GetReference(FAMF3References, &Type shr 1).Value).PrimitiveValue
  else
  begin
    Result := IncMilliSecond(EncodeDate(1970, 1, 1), Trunc(ReadDouble));
    FAMF3References.Add(TAMFObject.Create(TDateTimeObject.Create(Result)));
  end;
end;

function TAMFReader.ReadAMF3ClassDefinition: IAMFObject;

  function ExtractObject(ADefinition: TClassDefinition): IAMFObject;
  var
    Obj: TObject;
    I: Integer;
    MemberName: string;
  begin
    if ADefinition.Name <> '' then
    begin
      Obj :=  TClassManager.CreateInstance(ADefinition.Name);
      if Obj = nil then
        Obj := TActionScriptObject.Create(ADefinition.Name);
    end
    else
      Obj := TActionScriptObject.Create;
    Result := TAMFObject.Create(Obj);
    FAMF3References.Add(Result);
    if ADefinition.IsExternalizable then
    begin
      { TODO -oRcardo : Externalizable treatment}
    end
    else
    begin
      for I := 0 to Pred(ADefinition.Members.Count) do
        TInstrospectionHelper.SetValue(Obj, ADefinition.Members[I], ReadAMF3Object);
      if ADefinition.IsDynamic then
      begin
        MemberName := ReadAMF3String;
        while MemberName <> '' do
        begin
          TInstrospectionHelper.SetValue(Obj, MemberName, ReadAMF3Object);
          MemberName := ReadAMF3String;
        end;
      end;
    end;
  end;

var
  &Type,
  I,
  ClassType,
  AttributeCount: Integer;
  ClassIsReference,
  IsExternalizable,
  IsDynamic,
  IsReference: Boolean;
  ClassName: string;
  Definition: TClassDefinition;
begin
  &Type := ReadAMF3Integer;
  IsReference := (&Type and 1) = 0;
  if IsReference then
    Result := GetReference(FAMF3References, &Type shr 1)
  else
  begin
    ClassType := &Type shr 1;
    ClassIsReference := (ClassType and 1) = 0;
    if ClassIsReference then
      Result := GetReference(FDefReferences, ClassType shr 1)
    else
    begin
      ClassName := ReadAMF3String;
      IsExternalizable := (ClassType and 2) <> 0;
      IsDynamic := (ClassType and 4) <> 0;
      AttributeCount := ClassType shr 3;
      Definition := TClassDefinition.Create(ClassName, IsExternalizable, IsDynamic);
      try
        for I := 0 to Pred(AttributeCount) do
          Definition.Members.Add(ReadAMF3String);
      except
        FreeAndNil(Definition);
        raise;
      end;
      FDefReferences.Add(TAMFObject.Create(Definition));
      Result := ExtractObject(Definition);
    end;
  end;
end;

function TAMFReader.ReadAMF3Integer: Integer;
var
  B: Byte;
begin
  B := ReadByte;
  if B < 128 then
    Exit(B);
  Result := (B and $7F) shl 7;
  B := ReadByte;
  if B < 128 then
    Result := Result or B
  else
  begin
    Result := (Result or (B and $7F)) shl 7;
    B := ReadByte;
    if B < 128 then
      Result := Result or B
    else
    begin
      Result := (Result or (B and $7F)) shl 8;
      B := ReadByte;
      Result := Result or B;
    end;
  end;
  Result := -(Result and $10000000) or Result;
end;

function TAMFReader.ReadAMF3Object: IAMFObject;
var
  TypeMarker: Byte;
begin
  TypeMarker := ReadByte;
  Result := ReadAMF3Object(TypeMarker);
end;

function TAMFReader.ReadAMF3String: string;
var
  &Type,
  ReferenceLength: Integer;
  IsReference: Boolean;
begin
  &Type := ReadAMF3Integer;
  IsReference := (&Type and 1) = 0;
  if IsReference then
    Result := GetStringReference(&Type shr 1)
  else
  begin
    ReferenceLength := &Type shr 1;
    if ReferenceLength > 0 then
    begin
      Result := ReadString(ReferenceLength);
      FStringReferences.Add(Result);
    end
    else
      Result := '';
  end;
end;

function TAMFReader.ReadBody: IAMFBody;
var
  AMFBody: TAMFBody;
begin
  ClearReferences;
  AMFBody := TAMFBody.Create;
  try
    AMFBody.TargetURI := ReadString;
    AMFBody.ResponseURI := ReadString;
    ReadInt32; //Length
    AMFBody.Content := ReadObject;
  except
    FreeAndNil(AMFBody);
    raise;
  end;
  Result := AMFBody;
end;

function TAMFReader.ReadDateTime: TDateTime;
var
  TimeZone: Integer;
begin
  Result := IncMilliSecond(EncodeDate(1970, 1, 1) + Trunc(ReadDouble));
  TimeZone := ReadUInt16;
  if TimeZone > 720 then
    TimeZone := 64816; // 65536 - 720;
  TimeZone := TimeZone div 60;
  Result := Result + TimeZone;
end;

function TAMFReader.ReadDouble: Double;
var
  DoubleBytes,
  ReversedBytes: TBytes;
  I: Integer;
begin
  DoubleBytes := ReadBytes(8);
  SetLength(ReversedBytes, 8);
  for I := 0 to 7 do
    ReversedBytes[7 - I] := DoubleBytes[I];
  Result := PDouble(@ReversedBytes[0])^;
end;

function TAMFReader.ReadECMAArray: IAMFObject;
var
  Key: string;
  TypeMarker: Byte;
  ECMAArray: TDictionary<string, IAMFObject>;
begin
  ECMAArray := TDictionary<string, IAMFObject>.Create(ReadInt32);
  Result := TAMFObject.Create(ECMAArray);
  FReferences.Add(Result);
  while True do
  begin
    Key := ReadString;
    TypeMarker := ReadByte;
    if TypeMarker = TAMF0TypeMarkers.OBJECT_END then
      Exit;
    ECMAArray.Add(Key, ReadObject(TypeMarker));
  end;
end;

function TAMFReader.ReadHeader: IAMFHeader;
var
  AMFHeader: TAMFHeader;
begin
  ClearReferences;
  AMFHeader := TAMFHeader.Create;
  try
    AMFHeader.Name := ReadString;
    AMFHeader.MustUnderstand := ReadBoolean;
    AMFHeader.Length := ReadInt32;
    AMFHeader.Content := ReadObject;
  except
    FreeAndNil(AMFHeader);
    raise;
  end;
  Result := AMFHeader;
end;

function TAMFReader.ReadInteger: Integer;
var
  IntegerBytes: TBytes;
begin
  IntegerBytes := ReadBytes(4);
  Result :=
    (IntegerBytes[0] shl 24) or
    (IntegerBytes[1] shl 16) or
    (IntegerBytes[2] shl 8) or
    IntegerBytes[3];
end;

function TAMFReader.ReadLongString: string;
begin
  Result := ReadString(ReadInt32);
end;

function TAMFReader.ReadObject(ATypeMarker: Byte): IAMFObject;
begin
  Result := nil;

  case ATypeMarker of
    TAMF0TypeMarkers.NUMBER:
      Result := TAMFObject.Create(TDoubleObject.Create(ReadDouble));
    TAMF0TypeMarkers.BOOLEAN:
      Result := TAMFObject.Create(TBooleanObject.Create(ReadBoolean));
    TAMF0TypeMarkers.STR:
      Result := TAMFObject.Create(TStringObject.Create(ReadString));
    TAMF0TypeMarkers.AS_OBJECT:
      Result := ReadActionScriptObject;
    TAMF0TypeMarkers.NULL,
    TAMF0TypeMarkers.UNDEFINED:;
    TAMF0TypeMarkers.REFERENCE:
      Result := ReadReference;
    TAMF0TypeMarkers.ECMA_ARRAY:
      Result := ReadECMAArray;
    TAMF0TypeMarkers.STRICT_ARRAY:
      Result := ReadStrictArray;
    TAMF0TypeMarkers.DATE:
      Result := TAMFObject.Create(TDateTimeObject.Create(ReadDateTime));
    TAMF0TypeMarkers.LONG_STRING:
      Result := TAMFObject.Create(TStringObject.Create(ReadLongString));
    TAMF0TypeMarkers.XML_DOCUMENT:
      Result := ReadXMLDocument;
    TAMF0TypeMarkers.AVM_PLUS:
      Result := ReadAMF3Object;
    else
      raise Exception.Create('Type is not supported');
  end;
end;

function TAMFReader.ReadObject: IAMFObject;
var
  TypeMarker: Byte;
begin
  TypeMarker := ReadByte;
  Result := ReadObject(TypeMarker);
end;

function TAMFReader.ReadReference: IAMFObject;
begin
  Result := FReferences[ReadUInt16];
end;

function TAMFReader.ReadStrictArray: IAMFObject;
var
  I,
  Length: Integer;
  List: TList<IAMFObject>;
begin
  Length := ReadInt32;
  List := TList<IAMFObject>.Create;
  Result := TAMFObject.Create(List);
  FReferences.Add(Result);
  for I := 0 to Length - 1 do
    List.Add(ReadObject);
end;

function TAMFReader.ReadString(ALength: Integer): string;
var
  StringBytes: TBytes;
begin
  StringBytes := ReadBytes(ALength);
  Result := TEncoding.UTF8.GetString(StringBytes);
end;

function TAMFReader.ReadString: string;
begin
  Result := ReadString(ReadUInt16);
end;

function TAMFReader.ReadWord: Word;
var
  WordBytes: TBytes;
begin
  WordBytes := ReadBytes(2);
  Result := (WordBytes[0] shl 8) or WordBytes[1];
end;

function TAMFReader.ReadXMLDocument: IAMFObject;
var
  Content: string;
  Doc: TXMLDocument;
begin
  Content := ReadLongString;
  Doc := TXMLDocument.Create(nil);
  Result := TAMFObject.Create(Doc);
  if Trim(Content) <> '' then
    Doc.LoadFromXML(Content);
end;

end.
