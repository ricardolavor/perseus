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

unit PSFilters;

interface

uses
  Classes, SysUtils, PSContext, PSAMFIO, PSAMFMessage, Generics.Collections;

type

  IFilter = interface
    ['{9C81D02E-083F-41E0-B000-D54A43FAF250}']
    procedure Run(AContext: TAMFContext);
  end;

  TAMFDeserializerFilter = class(TInterfacedObject, IFilter)
  strict private
    FReader: TAMFReader;
    procedure ReadHeaders(AMessage: TAMFInputMessage);
    procedure ReadBodies(AMessage: TAMFInputMessage);
  public
    procedure Run(AContext: TAMFContext);
  end;

  TAMFResponseGeneratorFilter = class(TInterfacedObject, IFilter)
  strict private
  public
    procedure Run(AContext: TAMFContext);
  end;

  TAMFSerializeFilter = class(TInterfacedObject, IFilter)
  public
    procedure Run(AContext: TAMFContext);
  end;

  TFilterChain = class(TInterfacedObject, IFilter)
  strict private
    FFilters: TList<IFilter>;
  public
    procedure AfterConstruction; override;
    procedure Run(AContext: TAMFContext);
    destructor Destroy; override;
    property Filters: TList<IFilter> read FFilters;
  end;

implementation

uses
  PSCommonTypes, StrUtils, PSAMFBody;

{ TAMFDeserializeFilter }

procedure TAMFDeserializerFilter.ReadBodies(AMessage: TAMFInputMessage);
var
  I,
  BodyCount: Integer;
begin
  BodyCount := FReader.ReadUInt16;
  for I := 0 to Pred(BodyCount) do
    AMessage.AddBody(FReader.ReadBody);
end;

procedure TAMFDeserializerFilter.ReadHeaders(AMessage: TAMFInputMessage);
var
  I,
  HeaderCount: Integer;
begin
  HeaderCount := FReader.ReadUInt16;
  for I := 0 to Pred(HeaderCount) do
    AMessage.AddHeader(FReader.ReadHeader);
end;

procedure TAMFDeserializerFilter.Run(AContext: TAMFContext);
var
  Version: UInt16;
  AMFMessage: TAMFInputMessage;
begin
  FReader := TAMFReader.Create(AContext.InputStream);
  try
    Version := FReader.ReadUInt16;
    AMFMessage := TAMFInputMessage.Create;
    try
      AMFMessage.Version := Version;
      ReadHeaders(AMFMessage);
      ReadBodies(AMFMessage);
    except
      FreeAndNil(AMFMessage);
      raise;
    end;
    AContext.InputMessage := AMFMessage;
  finally
    FreeAndNil(FReader);
  end;
end;

{ TFilterChain }

procedure TFilterChain.AfterConstruction;
begin
  inherited;
  FFilters := TList<IFilter>.Create;
end;

destructor TFilterChain.Destroy;
begin
  FreeAndNil(FFilters);
  inherited;
end;

procedure TFilterChain.Run(AContext: TAMFContext);
var
  Filter: IFilter;
begin
  for Filter in Filters do
    Filter.Run(AContext);
end;

{ TAMFReponseGeneratorFilter }

procedure TAMFResponseGeneratorFilter.Run(AContext: TAMFContext);
var
  I: Integer;
  ASObject: TActionScriptObject;
  Body: IAMFBody;
  Content,
  Operation,
  ClientId: IAMFObject;
  AckMessage: TAcknowledgeMessage;
begin
  for I := 0 to Pred(AContext.InputMessage.BodyCount) do
  begin
    Body := AContext.InputMessage.Bodies[0];
    Content := Body.Content;
    if Content.Value is TList<IAMFObject> then
      Content := TList<IAMFObject>(Content.Value)[0];
    if Content.Value is TActionScriptObject then
    begin
      ASObject := TActionScriptObject(Content.Value);
      case IndexText(ASObject.TypeName,
         ['flex.messaging.messages.RemotingMessage',
         'flex.messaging.messages.CommandMessage']) of
        0:
        begin

        end;
        1:
        begin
          Operation := ASObject['operation'];
          if Assigned(Operation) and
            (Operation.Value.ToString = '5')  then
          begin
            AckMessage := TAcknowledgeMessage.Create;
            AckMessage.Version := AContext.InputMessage.Version;
            ClientId := ASObject['clientId'];
            if Assigned(ClientId) then
              AckMessage.ClientId := ClientId.Value.ToString;
            AckMessage.CorrelationId := ASObject['messageId'].Value.ToString;
            AckMessage.Confirm(Body.ResponseURI);
            AContext.AddResponse(AckMessage);
          end;
          Exit;
        end;
      end;
    end;
  end;
end;

{ TAMFSerializeFilter }

procedure TAMFSerializeFilter.Run(AContext: TAMFContext);
begin

end;

end.
