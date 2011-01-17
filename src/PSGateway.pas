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

unit PSGateway;

interface

uses
  Classes, SysUtils, PSFilters;

type

  IPerseusGateway = interface
    ['{C4FC8247-FE7B-4164-898A-2550E57CA1F0}']
    procedure Service(ARawData: TStream);
  end;

  TPerseusGateway = class(TInterfacedObject, IPerseusGateway)
  strict private
    FChain: TFilterChain;
    procedure Configure(AChain: TFilterChain);
  public
    procedure Service(ARawData: TStream);
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;

implementation

uses
  PSContext;

{ TPerseusGateway }

procedure TPerseusGateway.AfterConstruction;
begin
  inherited;
  FChain := TFilterChain.Create;
  Configure(FChain);
end;

procedure TPerseusGateway.Configure(AChain: TFilterChain);
begin
  AChain.Filters.Add(TAMFDeserializerFilter.Create);
  AChain.Filters.Add(TAMFResponseGeneratorFilter.Create);
  AChain.Filters.Add(TAMFSerializeFilter.Create);
end;

destructor TPerseusGateway.Destroy;
begin
  FreeAndNil(FChain);
  inherited;
end;

procedure TPerseusGateway.Service(ARawData: TStream);
var
  Context: TAMFContext;
begin
  Context := TAMFContext.Create(ARawData);
  try
    FChain.Run(Context);
  finally
    FreeAndNil(Context);
  end;
end;

end.
