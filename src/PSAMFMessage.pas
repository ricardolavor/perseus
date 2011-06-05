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

  IAMFMessage = interface
    ['{45DCCD8E-550C-4D61-BF83-4D8D02B6400E}']
    function GetBodies(AIndex: Integer): IAMFBody;
    function GetBodyCount: Integer;
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
    property Bodies[AIndex: Integer]: IAMFBody read GetBodies;
    property BodyCount: Integer read GetBodyCount;
  end;

  TAMFMessage = class abstract(TInterfacedObject, IAMFMessage)
  private
    FClientId: string;
    FDestination: string;
    FId: string;
    FTimeStamp: Integer;
    FTimeToLive: Integer;
    FHeaders: TInterfaceList;
    FVersion: UInt16;
    FBodies: TInterfaceList;
    function GetBodies(AIndex: Integer): IAMFBody;
    function GetBodyCount: Integer;
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
    procedure AddBody(const ABody: IAMFBody);
    property Bodies[AIndex: Integer]: IAMFBody read GetBodies;
    property BodyCount: Integer read GetBodyCount;
  end;

implementation

uses
  Windows, StrUtils;

{ TAMFMessage }

procedure TAMFMessage.AddBody(const ABody: IAMFBody);
begin
  FBodies.Add(ABody);
end;

procedure TAMFMessage.AddHeader(const AHeader: IAMFHeader);
begin
  FHeaders.Add(AHeader);
end;

procedure TAMFMessage.AfterConstruction;
begin
  inherited;
  FHeaders := TInterfaceList.Create;
  FBodies := TInterfaceList.Create;
end;

destructor TAMFMessage.Destroy;
begin
  FreeAndNil(FHeaders);
  FreeAndNil(FBodies);
  inherited;
end;

function TAMFMessage.GetBodies(AIndex: Integer): IAMFBody;
begin
  Result := IAMFBody(FBodies[AIndex]);
end;

function TAMFMessage.GetBodyCount: Integer;
begin
  Result := FBodies.Count;
end;

function TAMFMessage.GetClientId: string;
begin
  Result := FClientId;
end;

function TAMFMessage.GetDestination: string;
begin
  Result := FDestination;
end;

function TAMFMessage.GetHeaderCount: Integer;
begin
  Result := FHeaders.Count;
end;

function TAMFMessage.GetHeaders(AIndex: Integer): IAMFHeader;
begin
  Result := IAMFHeader(FHeaders[AIndex]);
end;

function TAMFMessage.GetId: string;
begin
  Result := FId;
end;

function TAMFMessage.GetTimeStamp: Integer;
begin
  Result := FTimeStamp;
end;

function TAMFMessage.GetTimeToLive: Integer;
begin
  Result := FTimeToLive;
end;

function TAMFMessage.GetVersion: UInt16;
begin
  Result := FVersion;
end;

procedure TAMFMessage.SetClientId(const Value: string);
begin
  FClientId := Value;
end;

procedure TAMFMessage.SetDestination(const Value: string);
begin
  FDestination := Value;
end;

procedure TAMFMessage.SetId(const Value: string);
begin
  FId := Value;
end;

procedure TAMFMessage.SetTimeStamp(const Value: Integer);
begin
  FTimeStamp := Value;
end;

procedure TAMFMessage.SetTimeToLive(const Value: Integer);
begin
  FTimeToLive := Value;
end;

procedure TAMFMessage.SetVersion(const Value: UInt16);
begin
  FVersion := Value;
end;

end.
