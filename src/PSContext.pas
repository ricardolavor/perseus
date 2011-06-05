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

unit PSContext;

interface

uses
  Classes, SysUtils, PSAMFMessage, Generics.Collections;

type

  TAMFContext = class
  strict private
    FInputStream: TStream;
    FMessage: IAMFMessage;
    FOutputStream: TStream;
    procedure SetMessage(const Value: IAMFMessage);
    procedure SetOutputStream(const Value: TStream);
  public
    constructor Create(AInputStream: TStream);
    destructor Destroy; override;
    property Message: IAMFMessage read FMessage write SetMessage;
    property OutputStream: TStream read FOutputStream write SetOutputStream;
    property InputStream: TStream read FInputStream;
  end;

implementation

{ TAMFContext }

constructor TAMFContext.Create(AInputStream: TStream);
begin
  FInputStream := AInputStream;
  OutputStream := TMemoryStream.Create;
end;

destructor TAMFContext.Destroy;
begin
  FreeAndNil(FOutputStream);
  inherited;
end;

procedure TAMFContext.SetMessage(const Value: IAMFMessage);
begin
  FMessage := Value;
end;

procedure TAMFContext.SetOutputStream(const Value: TStream);
begin
  if Value <> FOutputStream then
  begin
    FreeAndNil(FOutputStream);
    FOutputStream := Value;
  end;
end;

end.
