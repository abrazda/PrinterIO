unit PrinterIO;

interface

uses
  Winapi.Windows, Winapi.WinSpool, Winapi.Messages,
  System.Variants, System.Classes,
  System.SysUtils;

type
  TPrinterIO=class
  private
    FHandle: THandle;   //Printer Handle
    FJobId: THandle;    //

    FTitle  : String;
    FEncoding: TEncoding;
//    FCopies : Integer;
    function GetVersion():Integer;
  public
    property Title : String read FTitle write FTitle;
//    property Copies:Integer read FCopies write FCopies;

    constructor Create(const APrinterName:String;AEncoding:TEncoding=nil);
    destructor Destroy();override;

    procedure BeginDoc() overload;
    procedure BeginDoc(const ATitle:String) overload;
    procedure EndDoc();
    procedure Abort();

    function Write(const AValue:String):TPrinterIO;
    function WriteLn():TPrinterIO overload;
    function WriteLn(const AValue:String):TPrinterIO overload;

    procedure PrintFile(const AFileName:String);
  end;

implementation

uses
  System.IOUtils;

constructor TPrinterIO.Create(const APrinterName:String;AEncoding:TEncoding);
begin
  inherited Create();

  if not OpenPrinter(pChar(APrinterName),FHandle,nil) then
    RaiseLastOSError(); // Exception.Create('OpenPrinter('+APrinterName+')');

  if Assigned(AEncoding) then
    FEncoding:=AEncoding.Clone()
  else
    FEncoding:=TEncoding.GetEncoding(850);
end;

destructor TPrinterIO.Destroy();
begin
  inherited;

  ClosePrinter(FHandle);
  FreeAndNil(FEncoding);
end;

procedure TPrinterIO.BeginDoc();
var
  DOC_INFO : DOC_INFO_1;
begin
  DOC_INFO.pDocName:=pChar(FTitle);
  DOC_INFO.pOutputFile:=nil;
  DOC_INFO.pDatatype:='RAW';

  FJobId:=StartDocPrinter(FHandle,1,@DOC_INFO);

  if (FJobId=0) and (GetVersion()=4) then
  begin
    DOC_INFO.pDatatype:='XPS_PASS';
    FJobId:=StartDocPrinter(FHandle,1,@DOC_INFO);
  end;

  if FJobId=0 then
    RaiseLastOSError();

  if not StartPagePrinter(FHandle) then
    RaiseLastOSError();
end;

procedure TPrinterIO.BeginDoc(const ATitle: String);
begin
  FTitle:=ATitle;
  BeginDoc();
end;

procedure TPrinterIO.EndDoc();
begin
  EndPagePrinter(FHandle);
  EndDocPrinter(FHandle);
end;

function TPrinterIO.GetVersion(): Integer;
var
  Buffer: PByte;
  BufferSize: DWORD;
begin
  GetPrinterDriver(FHandle, nil, 2, nil, 0, BufferSize);

  if GetLastError() <> ERROR_INSUFFICIENT_BUFFER then
    exit(-1);

  Buffer:=GetMemory(BufferSize);
  if not GetPrinterDriver(FHandle, nil, 2, Buffer, BufferSize, BufferSize) then
    RaiseLastOSError();

  Result:=PDriverInfo2(Buffer).cVersion;
end;

procedure TPrinterIO.PrintFile(const AFileName: String);
var
  Written : Cardinal;
  Buffer: TBytes;
begin
  BeginDoc(TPath.GetFileNameWithoutExtension(AFileName));
    Buffer:=TFile.ReadAllBytes(AFileName);
    WritePrinter(FHandle,pByte(Buffer),Length(Buffer),Written);
  EndDoc();
end;

procedure TPrinterIO.Abort();
begin
  AbortPrinter(FHandle);
end;

function TPrinterIO.Write(const AValue:String):TPrinterIO;
var
  Written : Cardinal;
  Buffer: TBytes;
begin
  Buffer:=FEncoding.GetBytes(AValue);
  WritePrinter(FHandle,pByte(Buffer),Length(Buffer),Written);
  Result:=Self;
end;

function TPrinterIO.WriteLn(const AValue:String):TPrinterIO;
begin
  Write(AValue);
  WriteLn;
  Result:=Self;
end;

function TPrinterIO.WriteLn():TPrinterIO;
begin
  Write(#13#10);
  Result:=Self;
end;

end.

