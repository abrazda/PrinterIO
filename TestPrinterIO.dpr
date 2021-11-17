program TestPrinterIO;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,PrinterIO;

procedure Test(const AName:String);
var
  Printer: TPrinterIO;
begin
  Printer:=TPrinterIO.Create(AName);
  Printer.BeginDoc('Test');
  Printer.WriteLn('Hello world');
  Printer.EndDoc();
  FreeAndNil(Printer);
end;

begin
  try
//    Test('Godex EZ-1200 Plus');
    Test('Microsoft XPS Document Writer');

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
