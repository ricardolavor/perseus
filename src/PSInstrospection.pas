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
unit PSInstrospection;

interface

uses
  Classes, SysUtils, TypInfo, Generics.Collections, Rtti, PSCommonTypes;

type

  TClassManager = class
  private
    class var FRegister: TList<TClass>;
    class function FindClass(const AClassName: string): TClass;
  public
    class procedure RegisterClass(AClass: TClass);
    class procedure UnregisterClass(AClass: TClass);
    class function GetClass(const AClassName: string): TClass;
    class function CreateInstance(const AClassName: string): TObject;
  end;

  TInstrospectionHelper = class
  public
    class procedure SetValue(AInstance: TObject;
      const AMemberName: string; AObject: IAMFObject);
  end;

implementation

{ TActivator }

class function TClassManager.FindClass(const AClassName: string): TClass;
var
  &Class: TClass;
begin
  for &Class in FRegister do
    if SameText(&Class.ClassName, AClassName) then
      Exit(&Class);
  Result := nil;
end;

class function TClassManager.GetClass(const AClassName: string): TClass;
begin
  Result := FindClass(AClassName);
  if Result = nil then
    raise Exception.CreateFmt('"%s" is not a registered class', [AClassName]);
end;

class procedure TClassManager.RegisterClass(AClass: TClass);
begin
  if FindClass(AClass.ClassName) = nil then
    FRegister.Add(AClass)
  else
    raise Exception.CreateFmt('"%s" is already registered', [AClass.ClassName]);
end;

class procedure TClassManager.UnregisterClass(AClass: TClass);
begin
  FRegister.Remove(AClass);
end;

class function TClassManager.CreateInstance(const AClassName: string): TObject;
var
  &Class: TClass;
begin
  &Class := FindClass(AClassName);
  if &Class = nil then
    Result := nil
  else
    Result := &Class.Create;
end;

{ TInstrospectionHelper }

class procedure TInstrospectionHelper.SetValue(AInstance: TObject;
  const AMemberName: string; AObject: IAMFObject);
var
  Context: TRttiContext;
  &Type: TRttiType;
  &Property: TRttiProperty;
  Value: TValue;
  Field: TRttiField;
begin
  if AInstance is TActionScriptObject then
    TActionScriptObject(AInstance)[AMemberName] := AObject
  else
  begin
    Context := TRttiContext.Create;
    try
      if AObject.Value is TIntegerObject then
        Value := TIntegerObject(AObject.Value).PrimitiveValue
      else if AObject.Value is TDateTimeObject then
        Value := TDateTimeObject(AObject.Value).PrimitiveValue
      else if AObject.Value is TDoubleObject then
        Value := TDoubleObject(AObject.Value).PrimitiveValue
      else if AObject.Value is TBooleanObject then
        Value := TBooleanObject(AObject.Value).PrimitiveValue
      else if AObject.Value is TStringObject then
        Value := TStringObject(AObject.Value).PrimitiveValue
      else
        Value := AObject.Value;

      &Type := Context.GetType(AInstance.ClassType);
      &Property := &Type.GetProperty(AMemberName);
      if &Property = nil then
      begin
        Field := &Type.GetField(AMemberName);
        if Field = nil then
          raise Exception.CreateFmt('Member "%s" was not found', [AMemberName]);
        Field.SetValue(AInstance, Value);
      end
      else
        &Property.SetValue(AInstance, Value);
    finally
      Context.Free;
    end;
  end;
end;

initialization
  TClassManager.FRegister := TList<TClass>.Create;
finalization
  FreeAndNil(TClassManager.FRegister);
end.
