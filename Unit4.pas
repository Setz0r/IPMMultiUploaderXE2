unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons, Spin, Global, Site, Base64, logform,
  KUtil, IniFiles, Vcl.ImgList;

type
  TformSettings = class(TForm)
    btnCancel: TBitBtn;
    btnSave: TBitBtn;
    grpBasic: TGroupBox;
    cbbDefaultSite: TComboBox;
    txtConvertPath: TLabeledEdit;
    txtThreadLimit: TSpinEdit;
    lblThreadLimit: TLabel;
    lblDefaultSite: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
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
  formSettings: TformSettings;

implementation

{$R *.dfm}

{
----------------------------------------------------------------------------
               AddLog
----------------------------------------------------------------------------
}
procedure TformSettings.AddLog(msg: String);
begin
  flog := msg;
  formLog.memoLog.Lines.add(flog);
end;

{
----------------------------------------------------------------------------
               FormShow
----------------------------------------------------------------------------
}
procedure TformSettings.FormShow(Sender: TObject);
var
  pos : Integer;
begin
  cbbDefaultSite.Clear;
  for pos := 0 to Length(siteList) do begin
    if (siteList[pos].ID > 0) and (siteList[pos].ID < 300) then begin
      //Log := 'Site at Index '+inttostr(pos)+'/'+inttostr(siteList[pos].ID)+': '+siteList[pos].Name;
      cbbDefaultSite.AddItem(siteList[pos].Name,TObject(siteList[pos].ID));
    end;
  end;
  if (Settings.defaultSiteID > 0) then cbbDefaultSite.Text := Settings.defaultSite;
  Log := Settings.convertPath;
  Log := IntToStr(Settings.threadLimit);
  txtConvertPath.Text := Settings.convertPath;
  txtThreadLimit.Value := Settings.threadLimit;
  Log := END_LOG;
end;

procedure TformSettings.btnSaveClick(Sender: TObject);
var
  Ini: TIniFile;
  I : Integer;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.ini' ) );
  try
    Ini.WriteInteger( 'Threads', 'threadLimit', txtThreadLimit.Value);
    Ini.WriteString( 'Files', 'convertPath', txtConvertPath.Text);
    Ini.WriteString( 'Site', 'defaultSite', cbbDefaultSite.Text);
    for I := 0 to Length(siteList)-1 do begin
      if siteList[I].Name = cbbDefaultSite.Items[cbbDefaultSite.ItemIndex] then begin
    Ini.WriteString( 'Site', 'defaultSite', cbbDefaultSite.Text);
        Ini.WriteInteger( 'Site', 'defaultSiteID', siteList[I].ID);
      end;
    end;
    //Ini.WriteBool( 'Form', 'InitMax', WindowState = wsMaximized );
  finally
    Ini.Free;
  end;

  Application.MessageBox('You must restart the application for the changes to take affect.','Notice',MB_OK Or MB_ICONINFORMATION);

  formSettings.Close;

end;

end.
