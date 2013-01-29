unit logform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Site, Global, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.Buttons;

type
  TformLog = class(TForm)
    memoLog: TMemo;
    tbar: TToolBar;
    btnTheadCount: TToolButton;
    IconCrystalLog: TImageList;
    btnShowHTTPLogs: TSpeedButton;
    btnShowFTPLogs: TSpeedButton;
    procedure btnTheadCountClick(Sender: TObject);
    procedure btnShowFTPLogsClick(Sender: TObject);
    procedure btnShowHTTPLogsClick(Sender: TObject);
  private
    { Private declarations }
    flog : String;
    procedure AddLog(msg: String);
  public
    { Public declarations }
    property Log : String
      read flog
      write AddLog;
  end;

var
  formLog: TformLog;

implementation

{$R *.dfm}

procedure TformLog.AddLog(msg: String);
begin
  flog := msg;
  formLog.memoLog.Lines.add(flog);
end;

procedure TformLog.btnShowFTPLogsClick(Sender: TObject);
begin
  if btnShowFTPLogs.Down = True then Log := 'Now Showing FTP Logs';
end;

procedure TformLog.btnShowHTTPLogsClick(Sender: TObject);
begin
  if btnShowHTTPLogs.Down = True then Log := 'Now Showing HTTP Logs';

end;

procedure TformLog.btnTheadCountClick(Sender: TObject);
begin
  Log := 'Current Thread Count: '+inttostr(threads.Count);
end;

end.
