unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xmldownload, xmldom, XMLIntf, msxmldom,
  XMLDoc,gfxstuff, Base64, Site, Global, IniFiles;

type
  TformLogin = class(TForm)
    lblUsername: TLabel;
    editUsername: TEdit;
    lblPassword: TLabel;
    editPassword: TEdit;
    btnLogin: TButton;
    btnCancel: TButton;
    lblSiteList: TLabel;
    comboSiteList: TComboBox;
    cbSaveLogin: TCheckBox;
    XMLDocument1: TXMLDocument;
    procedure btnCancelClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure AddSite(pos: Integer; data:TSite);
  public
    { Public declarations }
  end;

var
  formLogin: TformLogin;

implementation

uses Unit1, logform;

{$R *.dfm}

procedure TformLogin.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TformLogin.btnLoginClick(Sender: TObject);
var
  Ini: TIniFile;
  I : Integer;
  MyClass: TObject;
  tmpSID : Integer;
  siteName : String;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.ini' ) );
  if cbSaveLogin.Checked then begin
    try
      tmpSID := integer(formLogin.comboSiteList.Items.Objects[formLogin.comboSiteList.itemindex]);
      Ini.WriteString( 'General', 'username', Base64Encode(editUsername.Text));
      Ini.WriteString( 'General', 'password', Base64Encode(editPassword.Text));
      Ini.WriteString( 'Site', 'defaultSite', siteList[tmpSID].Name);
      Ini.WriteInteger( 'Site', 'defaultSiteID', tmpSID);
    finally
      Ini.Free;
    end;
  end else begin
    try Ini.EraseSection('General');
    finally Ini.Free; end;
  end;

  if (comboSiteList.itemindex > 0) then
  begin
    formMain.Login(editUsername.text,editPassword.text,integer(comboSiteList.Items.Objects[comboSiteList.itemindex]));
    if (formMain.loggedin = true) then Close;
  end else
  begin
    ShowMessage('Please Select a Website to Login to');
  end;
end;

procedure TformLogin.AddSite(pos: Integer; data: TSite);
begin
  if (pos >= Length(siteList)) then SetLength(siteList,pos+1);
  siteList[pos] := data;
end;

procedure TformLogin.FormCreate(Sender: TObject);
var
  ADPLocalFile : TFileName;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  siteData : TSite;
begin
  ADPLocalFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'temp.sitelist.xml';

  Screen.Cursor:=crHourglass;
  try
    if not DownloadURLFile(SITE_SITE, ADPLocalFile)  then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to retreive sites list. From Site '+SITE_SITE,'Error',MB_OK Or MB_ICONERROR);
      //formLog.memoLog.Lines.add('Unable to retreive sites list. Site: '+SITE_SITE);
      Exit;
    end;

    if not FileExists(ADPLocalFile) then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to site project list temporary file.','Error',MB_OK Or MB_ICONERROR);
      //formLog.memoLog.Lines.add('Unable to locate site list temporary file.');
      Exit;
    end;

    xmldocument1.FileName := ADPLocalFile;
    xmldocument1.Active := true;

    StartItemNode := xmldocument1.DocumentElement.ChildNodes.FindNode('site');
    ANode := StartItemNode;
    comboSiteList.Items.Clear;
    comboSiteList.AddItem('Choose...',Pointer(0));
    repeat
      comboSiteList.AddItem(ANode.ChildNodes['siteName'].Text,Pointer(strtoint(ANode.ChildNodes['siteID'].Text)));
      with siteData do
      begin
        ID := strtoint(ANode.ChildNodes['siteID'].Text);
        SecName := ANode.ChildNodes['siteSecName'].Text;
        Name := ANode.ChildNodes['siteName'].Text;
        DBIP := ANode.ChildNodes['siteDBIP'].Text;
        DB := ANode.ChildNodes['siteDB'].Text;
        Desc := ANode.ChildNodes['siteDesc'].Text;
        Version := ANode.ChildNodes['siteVersion'].Text;
        URL := ANode.ChildNodes['siteURL'].Text;
        Path := ANode.ChildNodes['sitePath'].Text;
        Added := ANode.ChildNodes['siteAdded'].Text;
        UploadPHP := ANode.ChildNodes['siteUploadPHP'].Text;
        FTP.Host := ANode.ChildNodes['siteFTPHost'].Text;
        FTP.User := ANode.ChildNodes['siteFTPUser'].Text;
        FTP.Pass := ANode.ChildNodes['siteFTPPass'].Text;
        FTP.Port := ANode.ChildNodes['siteFTPPort'].Text;
        FTP.Dir := ANode.ChildNodes['siteFTPDir'].Text;
      end;
      AddSite(strtoint(ANode.ChildNodes['siteID'].Text),siteData);

      ANode := Anode.NextSibling;
    until ANode = nil;
    comboSiteList.ItemIndex := 0;
  finally
    DeleteFile(ADPLocalFile);
    Screen.Cursor:=crDefault;
    xmldocument1.Active := false;
  end;

end;

procedure TformLogin.FormShow(Sender: TObject);
var
  I : Integer;
begin
  if (Settings.UserName <> '') or (Settings.Password <> '') then cbSaveLogin.Checked := True;
  
  editUsername.Text := Base64Decode(Settings.UserName);  
  editPassword.Text := Base64Decode(Settings.Password);  
  if (Settings.defaultSiteID > 0) then begin
    comboSiteList.ItemIndex := Settings.defaultSiteID;
    for I := 0 to comboSiteList.Items.Count-1 do begin
      if comboSiteList.Items[I] = Settings.defaultSite then begin
        comboSiteList.ItemIndex := I;
      end;
    end;
  end;
end;

end.
