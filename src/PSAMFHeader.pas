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

unit PSAMFHeader;

interface

uses
  SysUtils, Classes, PSCommonTypes;

type

  IAMFHeader = interface
    ['{8C018A05-DEB3-4EA2-977A-6685F237D1CC}']
    function GetName: string;
    function GetMustUnderstand: Boolean;
    function GetContent: IAMFObject;
    function GetLength: Integer;
    property Name: string read GetName;
    property MustUnderstand: Boolean read GetMustUnderstand;
    property Content: IAMFObject read GetContent;
    property Length: Integer read GetLength;
  end;

  TAMFHeader = class(TInterfacedObject, IAMFHeader)
  private
    FName: string;
    FContent: IAMFObject;
    FMustUnderstand: Boolean;
    FLength: Integer;
    procedure SetName(const Value: string);
    function GetName: string;
    procedure SetContent(const Value: IAMFObject);
    procedure SetMustUnderstand(const Value: Boolean);
    function GetContent: IAMFObject;
    function GetMustUnderstand: Boolean;
    procedure SetLength(const Value: Integer);
    function GetLength: Integer;
  public
    property Name: string read GetName write SetName;
    property MustUnderstand: Boolean read GetMustUnderstand write SetMustUnderstand;
    property Content: IAMFObject read GetContent write SetContent;
    property Length: Integer read GetLength write SetLength;
  end;

implementation

{ TAMFHeader }

function TAMFHeader.GetContent: IAMFObject;
begin
  Result := FContent;
end;

function TAMFHeader.GetLength: Integer;
begin
  Result := FLength;
end;

function TAMFHeader.GetMustUnderstand: Boolean;
begin
  Result := FMustUnderstand;
end;

function TAMFHeader.GetName: string;
begin
  Result := FName;
end;

procedure TAMFHeader.SetContent(const Value: IAMFObject);
begin
  FContent := Value;
end;

procedure TAMFHeader.SetLength(const Value: Integer);
begin
  FLength := Value;
end;

procedure TAMFHeader.SetMustUnderstand(const Value: Boolean);
begin
  FMustUnderstand := Value;
end;

procedure TAMFHeader.SetName(const Value: string);
begin
  FName := Value;
end;

end.
