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

unit PSCommonTypes;

interface

uses
  Classes, SysUtils, Generics.Collections, PSPrimitiveObject;

type

  IAMFObject = interface
    ['{DCB358D3-9954-4C59-A449-E67D588F6835}']
    function GetValue: TObject;
    function GetClassName: string;
    function GetClassType: TClass;
    property Value: TObject read GetValue;
    property ClassName: string read GetClassName;
    property ClassType: TClass read GetClassType;
  end;

  TAMFObject = class(TInterfacedObject, IAMFObject)
  private
    FValue: TObject;
    function GetValue: TObject;
    function GetClassType: TClass;
    function GetClassName: string;
  public
    constructor Create(AObject: TObject);
    destructor Destroy; override;
    property Value: TObject read GetValue;
  end;

  TStringObject = class(TPrimitive<string>)
  public
    function ToString: string; override;
  end;

  TIntegerObject = class(TPrimitive<Integer>)
  public
    function ToString: string; override;
  end;

  TDoubleObject = class(TPrimitive<Double>)
  public
    function ToString: string; override;
  end;

  TBooleanObject = class(TPrimitive<Boolean>)
  public
    function ToString: string; override;
  end;

  TDateTimeObject = class(TPrimitive<TDateTime>)
  public
    function ToString: string; override;
  end;

  TActionScriptObject = class
  private
    FTypeName: string;
    FProperties: TDictionary<string, IAMFObject>;
    function GetProperties(const AName: string): IAMFObject;
    procedure SetProperties(const AName: string; const AValue: IAMFObject);
  public
    constructor Create(const ATypeName: string); overload;
    procedure AfterConstruction; override;
    destructor Destroy; override;
    property Properties[const AName: string]: IAMFObject read GetProperties write SetProperties; default;
    property TypeName: string read FTypeName;
  end;

implementation

{ TStringObject }

function TStringObject.ToString: string;
begin
  Result := PrimitiveValue;
end;

{ TActionScriptObject }

procedure TActionScriptObject.AfterConstruction;
begin
  inherited;
  FProperties := TDictionary<string, IAMFObject>.Create;
end;

constructor TActionScriptObject.Create(const ATypeName: string);
begin
  FTypeName := ATypeName;
  Create;
end;

destructor TActionScriptObject.Destroy;
begin
  FreeAndNil(FProperties);
  inherited;
end;

function TActionScriptObject.GetProperties(const AName: string): IAMFObject;
begin
  Result := nil;
  FProperties.TryGetValue(AName, Result);
end;

procedure TActionScriptObject.SetProperties(const AName: string;
  const AValue: IAMFObject);
begin
  FProperties.AddOrSetValue(AName, AValue);
end;

{ TAMFObject }

constructor TAMFObject.Create(AObject: TObject);
begin
  FValue := AObject;
end;

destructor TAMFObject.Destroy;
begin
  FreeAndNil(FValue);
  inherited;
end;

function TAMFObject.GetClassName: string;
begin
  if Assigned(FValue) then
    Result := FValue.ClassName
  else
    Result := inherited ClassName;
end;

function TAMFObject.GetClassType: TClass;
begin
  if Assigned(FValue) then
    Result := FValue.ClassType
  else
    Result := inherited ClassType;
end;

function TAMFObject.GetValue: TObject;
begin
  Result := FValue;
end;

{ TIntegerObject }

function TIntegerObject.ToString: string;
begin
  Result := InttoStr(PrimitiveValue);
end;

{ TDoubleObject }

function TDoubleObject.ToString: string;
begin
  Result := FloatToStr(PrimitiveValue);
end;

{ TBooleanObject }

function TBooleanObject.ToString: string;
begin
  if PrimitiveValue then
    Result := 'true'
  else
    Result := 'false';
end;

{ TDateTimeObject }

function TDateTimeObject.ToString: string;
begin
  Result := FormatDateTime('dd-mm-yyyy hh:nn:ss.zzz', PrimitiveValue);
end;

end.
