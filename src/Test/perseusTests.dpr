program perseusTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  AMFIOTest in 'AMFIOTest.pas',
  PSAMFIO in '..\PSAMFIO.pas',
  PSAMFBody in '..\PSAMFBody.pas',
  PSAMFHeader in '..\PSAMFHeader.pas',
  PSAMFMessage in '..\PSAMFMessage.pas',
  PSCommonTypes in '..\PSCommonTypes.pas',
  PSClassDefinition in '..\PSClassDefinition.pas',
  PSInstrospection in '..\PSInstrospection.pas',
  PSPrimitiveObject in '..\PSPrimitiveObject.pas',
  PSIntropectionTests in 'PSIntropectionTests.pas',
  PSContext in '..\PSContext.pas',
  PSFilters in '..\PSFilters.pas',
  PSGateway in '..\PSGateway.pas';

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

