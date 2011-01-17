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

unit PSAMFBody;

interface

uses
  SysUtils, Classes, PSCommonTypes, Generics.Collections;

type

  IAMFBody = interface
    ['{88962D77-14C2-4983-AB2D-03E5561C5B81}']
    function GetTargetURI: string;
    function GetResponseURI: string;
    function GetMethod: string;
    function GetContent: IAMFObject;
    property TargetURI: string read GetTargetURI;
    property ResponseURI: string read GetResponseURI;
    property Method: string read GetMethod;
    property Content: IAMFObject read GetContent;
  end;

  TAMFBody = class(TInterfacedObject, IAMFBody)
  private
    FResponseURI: string;
    FMethod: string;
    FTargetURI: string;
    FContent: IAMFObject;
    procedure SetContent(const Value: IAMFObject);
    procedure SetMethod(const Value: string);
    procedure SetResponseURI(const Value: string);
    procedure SetTargetURI(const Value: string);
    function GetContent: IAMFObject;
    function GetMethod: string;
    function GetResponseURI: string;
    function GetTargetURI: string;
  public
    property TargetURI: string read GetTargetURI write SetTargetURI;
    property ResponseURI: string read GetResponseURI write SetResponseURI;
    property Method: string read GetMethod write SetMethod;
    property Content: IAMFObject read GetContent write SetContent;
  end;

implementation

{ TAMFBody }

function TAMFBody.GetContent: IAMFObject;
begin
  Result := FContent;
end;

function TAMFBody.GetMethod: string;
begin
  Result := FMethod;
end;

function TAMFBody.GetResponseURI: string;
begin
  Result := FResponseURI;
end;

function TAMFBody.GetTargetURI: string;
begin
  result := FTargetURI;
end;

procedure TAMFBody.SetContent(const Value: IAMFObject);
begin
  FContent := Value;
end;

procedure TAMFBody.SetMethod(const Value: string);
begin
  FMethod := Value;
end;

procedure TAMFBody.SetResponseURI(const Value: string);
begin
  FResponseURI := Value;
end;

procedure TAMFBody.SetTargetURI(const Value: string);
begin
  FTargetURI := Value;
end;

end.
