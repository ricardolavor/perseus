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

unit PSAMFMessage;

interface

uses
  SysUtils, Classes, PSAMFBody, PSAMFHeader, PSCommonTypes;

type

  IAMFSimpleMessage = interface
    ['{7B50F20B-8AAC-4747-AAC9-9909E1C9FB73}']
    function GetClientId: string;
    function GetDestination: string;
    function GetId: string;
    function GetTimeStamp: Integer;
    function GetTimeToLive: Integer;
    function GetHeaders(AIndex: Integer): IAMFHeader;
    function GetVersion: UInt16;
    function GetHeaderCount: Integer;
    property Version: UInt16 read GetVersion;
    property ClientId: string read GetClientId;
    property Destination: string read GetDestination;
    property Id: string read GetId;
    property TimeStamp: Integer read GetTimeStamp;
    property TimeToLive: Integer read GetTimeToLive;
    property Headers[AIndex: Integer]: IAMFHeader read GetHeaders;
    property HeaderCount: Integer read GetHeaderCount;
  end;

  IAMFInputMessage = interface(IAMFSimpleMessage)
    ['{45DCCD8E-550C-4D61-BF83-4D8D02B6400E}']
    function GetBodies(AIndex: Integer): IAMFBody;
    function GetBodyCount: Integer;
    property Bodies[AIndex: Integer]: IAMFBody read GetBodies;
    property BodyCount: Integer read GetBodyCount;
  end;

  IAMFResponse = interface(IAMFSimpleMessage)
    function GetResult: IAMFObject;
    function GetCorrelationId: string;
    function GetResponse: string;
    procedure SetResult(AValue: IAMFObject);
    procedure SetCorrelationId(const AValue: string);
    procedure Confirm(const AResponseURI: string);
    procedure Fail(const AResponseURI: string);
    property Result: IAMFObject read GetResult write SetResult;
    property CorrelationId: string read GetCorrelationId write SetCorrelationId;
    property Response: string read GetResponse;
  end;

  TAMFSimpleMessage = class abstract(TInterfacedObject, IAMFSimpleMessage)
  private
    FClientId: string;
    FDestination: string;
    FId: string;
    FTimeStamp: Integer;
    FTimeToLive: Integer;
    FHeaders: TInterfaceList;
    FVersion: UInt16;
    function GetClientId: string;
    function GetDestination: string;
    function GetHeaders(AIndex: Integer): IAMFHeader;
    function GetId: string;
    function GetTimeStamp: Integer;
    function GetTimeToLive: Integer;
    procedure SetId(const Value: string);
    procedure SetTimeStamp(const Value: Integer);
    procedure SetTimeToLive(const Value: Integer);
    procedure SetDestination(const Value: string);
    procedure SetVersion(const Value: UInt16);
    function GetVersion: UInt16;
    function GetHeaderCount: Integer;
  strict protected
    procedure SetClientId(const Value: string); virtual;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure AddHeader(const AHeader: IAMFHeader);
    property ClientId: string read GetClientId write SetClientId;
    property Destination: string read GetDestination write SetDestination;
    property Id: string read GetId write SetId;
    property TimeStamp: Integer read GetTimeStamp write SetTimeStamp;
    property TimeToLive: Integer read GetTimeToLive write SetTimeToLive;
    property Version: UInt16 read GetVersion write SetVersion;
    property Headers[AIndex: Integer]: IAMFHeader read GetHeaders;
    property HeaderCount: Integer read GetHeaderCount;
  end;

  TAMFInputMessage = class(TAMFSimpleMessage, IAMFInputMessage)
  private
    FBodies: TInterfaceList;
    function GetBodies(AIndex: Integer): IAMFBody;
    function GetBodyCount: Integer;
  public
    procedure AfterConstruction; override;
    destructor Destroy; override;
    procedure AddBody(const ABody: IAMFBody);
    property Bodies[AIndex: Integer]: IAMFBody read GetBodies;
    property BodyCount: Integer read GetBodyCount;
  end;

  TAMFResponse = class(TAMFSimpleMessage, IAMFResponse)
  strict private
    FResult: IAMFObject;
    FCorrelationId: string;
    FResponse: string;
    function GetCorrelationId: string;
    procedure SetResult(AValue: IAMFObject);
    function GetResult: IAMFObject;
    function GetResponse: string;
    procedure SetCorrelationId(const AValue: string);
  public
    procedure AfterConstruction; override;
    procedure Confirm(const AResponseURI: string);
    procedure Fail(const AResponseURI: string);
    property Response: string read GetResponse;
    property Result: IAMFObject read GetResult write SetResult;
    property CorrelationId: string read GetCorrelationId write SetCorrelationId;
  end;

  TAcknowledgeMessage = class(TAMFResponse)
  strict protected
    procedure SetClientId(const Value: string); override;
  public
    procedure AfterConstruction; override;
  end;


implementation

uses
  Windows, StrUtils;

function NewGUID: string;
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  Result := GUIDToString(GUID);
  Result := Copy(Result, 2, Length(Result) - 2);
end;

{ TAMFInputMessage }

procedure TAMFInputMessage.AddBody(const ABody: IAMFBody);
begin
  FBodies.Add(ABody);
end;

procedure TAMFInputMessage.AfterConstruction;
begin
  inherited;
  FBodies := TInterfaceList.Create;
end;

destructor TAMFInputMessage.Destroy;
begin
  FreeAndNil(FBodies);
  inherited;
end;

function TAMFInputMessage.GetBodies(AIndex: Integer): IAMFBody;
begin
  Result := IAMFBody(FBodies[AIndex]);
end;

function TAMFInputMessage.GetBodyCount: Integer;
begin
  Result := FBodies.Count;
end;

{ TAMFResponse }

procedure TAMFResponse.AfterConstruction;
begin
  inherited;
  TimeStamp := GetTickCount;
  TimeToLive := 0;
end;

procedure TAMFResponse.Confirm(const AResponseURI: string);
begin
  FResponse := AResponseURI + '/onResult';
end;

procedure TAMFResponse.Fail(const AResponseURI: string);
begin
  FResponse := AResponseURI + '/onStatus';
end;

function TAMFResponse.GetCorrelationId: string;
begin
  Result := FCorrelationId;
end;

function TAMFResponse.GetResponse: string;
begin
  Result := FResponse;
end;

function TAMFResponse.GetResult: IAMFObject;
begin
  Result := FResult;
end;

procedure TAMFResponse.SetCorrelationId(const AValue: string);
begin
  FCorrelationId := AValue;
end;

procedure TAMFResponse.SetResult(AValue: IAMFObject);
begin
  FResult := AValue;
end;

{ TAMFSimpleMessage }

procedure TAMFSimpleMessage.AddHeader(const AHeader: IAMFHeader);
begin
  FHeaders.Add(AHeader);
end;

procedure TAMFSimpleMessage.AfterConstruction;
begin
  inherited;
  FHeaders := TInterfaceList.Create;
end;

destructor TAMFSimpleMessage.Destroy;
begin
  FreeAndNil(FHeaders);
  inherited;
end;

function TAMFSimpleMessage.GetClientId: string;
begin
  Result := FClientId;
end;

function TAMFSimpleMessage.GetDestination: string;
begin
  Result := FDestination;
end;

function TAMFSimpleMessage.GetHeaderCount: Integer;
begin
  Result := FHeaders.Count;
end;

function TAMFSimpleMessage.GetHeaders(AIndex: Integer): IAMFHeader;
begin
  Result := IAMFHeader(FHeaders[AIndex]);
end;

function TAMFSimpleMessage.GetId: string;
begin
  Result := FId;
end;

function TAMFSimpleMessage.GetTimeStamp: Integer;
begin
  Result := FTimeStamp;
end;

function TAMFSimpleMessage.GetTimeToLive: Integer;
begin
  Result := FTimeToLive;
end;

function TAMFSimpleMessage.GetVersion: UInt16;
begin
  Result := FVersion;
end;

procedure TAMFSimpleMessage.SetClientId(const Value: string);
begin
  FClientId := Value;
end;

procedure TAMFSimpleMessage.SetDestination(const Value: string);
begin
  FDestination := Value;
end;

procedure TAMFSimpleMessage.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TAMFSimpleMessage.SetTimeStamp(const Value: Integer);
begin
  FTimeStamp := Value;
end;

procedure TAMFSimpleMessage.SetTimeToLive(const Value: Integer);
begin
  FTimeToLive := Value;
end;

procedure TAMFSimpleMessage.SetVersion(const Value: UInt16);
begin
  FVersion := Value;
end;

{ TAcknowledgeMessage }

procedure TAcknowledgeMessage.AfterConstruction;
begin
  inherited;
  Id := NewGUID;
  ClientId := NewGUID;
end;

procedure TAcknowledgeMessage.SetClientId(const Value: string);
begin
  if Value = '' then
    inherited SetClientId(NewGUID)
  else
    inherited SetClientId(Value);
end;

end.
