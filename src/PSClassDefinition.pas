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

unit PSClassDefinition;

interface

uses
  Classes, SysUtils, Generics.Collections;

type

  TClassDefinition = class sealed
  private
    FName: string;
    FIsExternalizable: Boolean;
    FIsDynamic: Boolean;
    FMembers: TList<string>;
    function GetIsDynamic: Boolean;
    function GetIsExternalizable: Boolean;
    function GetName: string;
    function GetMembers: TList<string>;
  public
    constructor Create(const AName: string; AIsExternalizable, AIsDynamic: Boolean);
    procedure AfterConstruction; override;
    destructor Destroy; override;
    property Name: string read GetName;
    property IsExternalizable: Boolean read GetIsExternalizable;
    property IsDynamic: Boolean read GetIsDynamic;
    property Members: TList<string> read GetMembers;
  end;

implementation

{ TClassDefinition }

procedure TClassDefinition.AfterConstruction;
begin
  inherited;
  FMembers := TList<string>.Create;
end;

constructor TClassDefinition.Create(const AName: string; AIsExternalizable,
  AIsDynamic: Boolean);
begin
  FName := AName;
  FIsExternalizable := AIsExternalizable;
  FIsDynamic := AIsDynamic;
end;

destructor TClassDefinition.Destroy;
begin
  FreeAndNil(FMembers);
  inherited;
end;

function TClassDefinition.GetIsDynamic: Boolean;
begin
  Result := FIsDynamic;
end;

function TClassDefinition.GetIsExternalizable: Boolean;
begin
  Result := FIsExternalizable;
end;

function TClassDefinition.GetMembers: TList<string>;
begin
  Result := FMembers;
end;

function TClassDefinition.GetName: string;
begin
  result := FName;
end;

end.
