program TestPrinterIO;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,PrinterIO;

var
  PrinterName:String;

procedure Test1();
var
  Printer: TPrinterIO;
begin
  Printer:=TPrinterIO.Create(PrinterName);
  Printer.BeginDoc('Test');

  //Send commands and text to printer
  //Use escape caracter secuences like #27'A'#1, each character would be encoded using codepage 850
  Printer.WriteLn('Hello world');
  Printer.Write(#12);
  Printer.EndDoc();
  FreeAndNil(Printer);
end;

procedure Test2(const AFileName:String);
var
  Printer: TPrinterIO;
begin
  Printer:=TPrinterIO.Create(PrinterName);
    Printer.PrintFile(AFileName);
  FreeAndNil(Printer);
end;

begin
  try
    PrinterName:='Godex EZ-1200 Plus';  //Replace with your printer name

    Test1();
    Test2('midata.bin');  //Replace this filename with the file to print

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
