unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls,unit2, ExtCtrls, StdCtrls, xmldom, XMLIntf, msxmldom,
  XMLDoc,ShellAPI,
  xmldownload,gfxstuff,KUtil, ImgList, Buttons, Base64,
  Site, Global, IniFiles, OverbyteIcsWndControl, OverbyteIcsFtpCli;

type
  TformMain = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Login1: TMenuItem;
    N1: TMenuItem;
    statusBar: TStatusBar;
    panelButtons: TPanel;
    panelMain: TPanel;
    listUploads: TListView;
    lblProject: TLabel;
    comboProjectList: TComboBox;
    lblColumn: TLabel;
    comboColumnList: TComboBox;
    XMLDocument1: TXMLDocument;
    lblNatNum: TLabel;
    comboNatNum: TComboBox;
    timerMain: TTimer;
    progMain: TProgressBar;
    N2: TMenuItem;
    ConvertStatus1: TMenuItem;
    MenuIcons: TImageList;
    btnGo: TBitBtn;
    btnRemoveSel: TBitBtn;
    btnRemoveAll: TBitBtn;
    IconsSimplicio: TImageList;
    IconCrystal16: TImageList;
    Settings1: TMenuItem;
    pmQueueContextMenu: TPopupMenu;
    AbortUpload1: TMenuItem;
    RestartUpload1: TMenuItem;
    Remove1: TMenuItem;
    procedure About1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Login1Click(Sender: TObject);
    procedure comboProjectListChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ConvertStatus1Click(Sender: TObject);
    procedure timerMainTimer(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure btnRemoveSelClick(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure pmQueueContextMenuPopup(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure Debug1Click(Sender: TObject);
    procedure AbortUpload1Click(Sender: TObject);
    procedure RestartUpload1Click(Sender: TObject);
  private
    { Private declarations }
    flog : String;
    procedure AddLog(msg: String);
    procedure RemoveSelected;
    function threadsComplete : Boolean;
    procedure StartUpload(Item: TListItem);

  public
    siteID : string;
    userID : string;
    maxThreads : Integer;
    loggedIn: boolean;
    utility : TKUtil;
    { Public declarations }
    procedure Login(username:string;password:string;website:integer);
    procedure DownloadProjects();
    procedure DownloadColumns();
    procedure DownloadStores();
    procedure WMDropFiles(var message: TMessage); message WM_DROPFILES;

    property Log : String
      read flog
      write AddLog;
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}
uses ExtActns, Unit3, logform, Unit4;

{
----------------------------------------------------------------------------
               AddLog
----------------------------------------------------------------------------
}
procedure TformMain.AddLog(msg: String);
begin
  flog := msg;
  formLog.memoLog.Lines.add(flog);
end;

{
----------------------------------------------------------------------------
               DownloadProjects
----------------------------------------------------------------------------
}
procedure TformMain.DownloadProjects();
var
  ADPLocalFile : TFileName;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  Total : string;
  siteUrl: string;
begin
  ADPLocalFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'temp.projectlist.xml';

  //siteUrl:=PROJECT_SITE+'&s='+siteID+'&sessionid='+sessionid;
  siteUrl:=mySite.URL+PROJECT_SITE+'&sessionid='+sessionid;
  Log := 'siteUrl: '+siteUrl;

  Screen.Cursor:=crHourglass;
  try
    if not DownloadURLFile(siteUrl, ADPLocalFile)  then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to download project list.  Please check your network connection.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to download project list.  Please check your network connection.';
      Exit;
    end;

    if not FileExists(ADPLocalFile) then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to locate project list temporary file.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to locate project list temporary file.';
      Exit;
    end;

    xmldocument1.FileName := ADPLocalFile;
    xmldocument1.Active := true;

    ftpDir := mySite.FTP.Dir;
    uploadPHP := mySite.UploadPHP;
    ftpHost := mySite.FTP.Host;

    Total := xmldocument1.documentelement.ChildNodes.FindNode('totalprojects').Text;
    Log := 'Total Projects: '+Total;
    if (Total <> '0') then
    begin
      StartItemNode := xmldocument1.DocumentElement.ChildNodes.FindNode('project');
      ANode := StartItemNode;
      comboProjectList.Items.Clear;
      comboProjectList.AddItem('Choose...',Pointer(0));
      repeat
        comboProjectList.AddItem(ANode.ChildNodes['prjname'].Text,TString.create(ANode.ChildNodes['prjcode'].Text));
        ANode := Anode.NextSibling;
      until ANode = nil;
      comboProjectList.ItemIndex := 0;
      Log := 'Project List Downloaded Successfully.';
      Log := END_LOG;
    end;
  finally
    DeleteFile(ADPLocalFile);
    Screen.Cursor:=crDefault;
    xmldocument1.Active := false;
  end;
end;

{
----------------------------------------------------------------------------
               Debug1Click
----------------------------------------------------------------------------
}
procedure TformMain.Debug1Click(Sender: TObject);
var
  I : Integer;
  complete : Boolean;
begin
  complete := True;
  if threads.Count > 0 then begin
    for I := 0 to threads.Count-1 do begin
      if not TConvertThread(threads[i]).Finished then complete := False;
    end;

    if complete then Log := 'ALL THREADS HAVE COMPLETED'
    else Log := 'SOME THREADS ARE STILL ACTIVE';
  end;

end;

procedure TformMain.DownloadColumns;
var
  ADPLocalFile : TFileName;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  Total : string;
  siteUrl: string;
begin
  ADPLocalFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'temp.tasklist.xml';
  //ShowMessage(TString(cbProject.Items.Objects[cbProject.itemindex]).str);
  //ShowMessage(TASK_SITE+'&s='+inttostr(integer(cbSite.Items.Objects[cbSite.itemindex]))+'&prjcode='+TString(cbProject.Items.Objects[cbProject.itemindex]).str);

  try
    //siteUrl:=TASK_SITE+'&s='+siteID+'&uid='+userID+'&tt=16&prjcode='+TString(comboProjectList.Items.Objects[comboProjectList.itemindex]).str;
    siteUrl:=mySite.URL+TASK_SITE+'&sessionid='+sessionid+'&task=16&prjcode='+TString(comboProjectList.Items.Objects[comboProjectList.itemindex]).str;
    Log := 'siteUrl: '+siteUrl;
  except
    Application.MessageBox('Please select a valid project from the project code drop down.','Error',MB_OK Or MB_ICONERROR);
    exit;
  end;

  Screen.Cursor:=crHourglass;
  comboColumnList.Clear;
  try
    if not DownloadURLFile(siteUrl, ADPLocalFile)  then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to download column list.  Please check your network connection.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to download column list.  Please check your network connection.';
      Exit;
    end;

    if not FileExists(ADPLocalFile) then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to locate column list temporary file.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to locate column list temporary file.';
      Exit;
    end;

    xmldocument1.FileName := ADPLocalFile;
    xmldocument1.Active := true;
    Total := xmldocument1.documentelement.ChildNodes.FindNode('totaltasks').Text;
    Log := 'Total Columns: '+Total;
    if (Total <> '0') then
    begin
      StartItemNode := xmldocument1.DocumentElement.ChildNodes.FindNode('task');
      ANode := StartItemNode;
      comboColumnList.Items.Clear;
      comboColumnList.AddItem('Choose...',Pointer(0));
      repeat
        comboColumnList.AddItem(ANode.ChildNodes['taskName'].Text,TString.create(ANode.ChildNodes['taskID'].Text));
        ANode := Anode.NextSibling;
      until ANode = nil;
      comboColumnList.ItemIndex := 0;
      Log := 'Column List Downloaded Successfully.';
      Log := END_LOG;
    end;
  finally
    DeleteFile(ADPLocalFile);
    Screen.Cursor:=crDefault;
    xmldocument1.Active := false;
  end;
  Log := 'Starting Store List Download';
  DownloadStores;
end;

{
----------------------------------------------------------------------------
               DownloadStores
----------------------------------------------------------------------------
}
procedure TformMain.DownloadStores;
var
  ADPLocalFile : TFileName;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  Total : string;
  siteUrl: string;
begin
  //siteUrl:=STORE_SITE+'&s='+siteID+'&uid='+userID+'&prjcode='+TString(comboProjectList.Items.Objects[comboProjectList.itemindex]).str;
  siteUrl:=mySite.URL+STORE_SITE+'&sessionid='+sessionid+'&prjcode='+TString(comboProjectList.Items.Objects[comboProjectList.itemindex]).str;
  Log := 'siteUrl: '+siteUrl;

  ADPLocalFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'temp.storelist.xml';
  Screen.Cursor:=crHourglass;
  try
    if not DownloadURLFile(siteUrl, ADPLocalFile)  then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to download store list.  Please check your network connection.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to store project list.  Please check your network connection.';
      Exit;
    end;

    if not FileExists(ADPLocalFile) then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to locate store list temporary file.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to locate store list temporary file.';
      Exit;
    end;

    xmldocument1.FileName := ADPLocalFile;
    xmldocument1.Active := true;

    Total := xmldocument1.documentelement.ChildNodes.FindNode('totalstores').Text;
    Log := 'Total Stores: '+Total;
    if (Total <> '0') then
    begin
      StartItemNode := xmldocument1.DocumentElement.ChildNodes.FindNode('store');
      ANode := StartItemNode;
      comboNatNum.Items.Clear;
      comboNatNum.AddItem('Choose...',Pointer(0));
      repeat
        comboNatNum.AddItem(ANode.ChildNodes['storeNum'].Text,Pointer(strtoint(ANode.ChildNodes['storeID'].Text)));
        ANode := Anode.NextSibling;
      until ANode = nil;
      comboNatNum.ItemIndex := 0;
      Log := 'Store List Downloaded Successfully.';
      Log := END_LOG;
    end;
  finally
    DeleteFile(ADPLocalFile);
    Screen.Cursor:=crDefault;
    xmldocument1.Active := false;
  end;
end;

{
----------------------------------------------------------------------------
               DateTimeToUNIXTime
----------------------------------------------------------------------------
}
function DateTimeToUNIXTime(DelphiTime : TDateTime): LongWord;
var
  MyTimeZoneInformation: TTimeZoneInformation;
begin
  GetTimeZoneInformation(MyTimeZoneInformation);
  Result := round(DelphiTime - StrToDate('01/01/1970') + ((MyTimeZoneInformation.Bias) / (24 * 60))) * (24 * 3600);
end;

{
----------------------------------------------------------------------------
               Login
----------------------------------------------------------------------------
}
procedure TformMain.Login(username:string;password:string;website:integer);
var
  ADPLocalFile : TFileName;
  StartItemNode : IXMLNode;
  ANode : IXMLNode;
  siteUrl: string;
begin
  siteID := inttostr(integer(formLogin.comboSiteList.Items.Objects[formLogin.comboSiteList.itemindex]));
  mySite := siteList[strtoint(siteID)];

  siteUrl:=mySite.URL+LOGIN_SITE+'&username='+Base64Encode(formLogin.editUsername.text)+'&password='+Base64Encode(formLogin.editPassword.text);
  Log := 'siteUrl: '+siteUrl;

  ADPLocalFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'temp.login.xml';

  Screen.Cursor:=crHourglass;
  formMain.comboProjectList.Clear;
  try
    if not DownloadURLFile(siteUrl, ADPLocalFile)  then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to download project list.  Please check your network connection.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to download project list.  Please check your network connection.';
      Exit;
    end;

    if not FileExists(ADPLocalFile) then
    begin
      Screen.Cursor:=crDefault;
      Application.MessageBox('Unable to located login temporary file.','Error',MB_OK Or MB_ICONERROR);
      Log := 'Unable to located login temporary file.';
      Exit;
    end;

    xmldocument1.FileName := ADPLocalFile;
    xmldocument1.Active := true;

    StartItemNode := xmldocument1.DocumentElement.ChildNodes.FindNode('logininfo');
    ANode := StartItemNode;
    if (ANode <> Nil) then
    begin
      case strtoint(Anode.ChildNodes['loginCode'].Text) of
        0: begin
          ShowMessage(Anode.ChildNodes['loginMsg'].Text);
          loggedIn := false;
        end;
        1: begin
          userID := Anode.ChildNodes['userID'].Text;
          sessionid := Anode.ChildNodes['sessionid'].Text;
          loggedIn := true;
          panelMain.Enabled := true;
          panelButtons.Enabled := true;
          StatusBar.Panels[SBAR_MESSAGE].text := Anode.ChildNodes['loginMsg'].Text;
          StatusBar.Panels[SBAR_PROJECT].text := mySite.Name+' ('+mySite.Version+')';
          Log := 'Logged In Successfull';
          Log := 'Site ID: '+siteID;
          Log := 'User ID: '+userID;
          Log := 'Session ID: '+sessionid;
          with mySite do
          begin
            Log := 'Site Name: '+Name;
            Log := 'Site Version: '+Version;
            Log := 'Site URL: '+URL;
            Log := 'Site FTP Host: '+FTP.Host;
            Log := 'Site FTP User: '+FTP.User;
            Log := 'Site FTP Pass: '+FTP.Pass;
            Log := 'Site FTP Port: '+FTP.Port;
          end;
          Log := END_LOG;
          Log := 'Starting Project List Download';
          DownloadProjects;
        end;
      end;
    end;
  finally
    DeleteFile(ADPLocalFile);
    Screen.Cursor:=crDefault;
    xmldocument1.Active := false;
  end;
  comboColumnList.Clear;
  comboNatNum.Clear;
end;

{
----------------------------------------------------------------------------
               DownloadURLFile
----------------------------------------------------------------------------
}
function DownloadURLFile(const ADPXMLBLOG, ADPLocalFile : TFileName) : boolean;
begin
  Result:=True;

  with TDownLoadURL.Create(nil) do
  try
    URL:=ADPXMLBLOG;
    Filename:=ADPLocalFile;
    try
      ExecuteTarget(nil);
    except
      Result:=False;
    end;
  finally
    Free;
  end;
end;

{
----------------------------------------------------------------------------
               About1Click
----------------------------------------------------------------------------
}
procedure TformMain.AbortUpload1Click(Sender: TObject);
var
  i: Integer;
  Item: TListItem;
begin
  if threads.Count > 0 then begin
    Item := listUploads.Selected;
    while Item <> nil do begin
      if
        (Item.SubItems[SUBITEM_STATUS] <> 'Queued') or
        (Item.SubItems[SUBITEM_STATUS] <> 'Aborted') or
        (Item.SubItems[SUBITEM_STATUS] <> 'Upload Failed') or
        (Item.SubItems[SUBITEM_STATUS] <> 'Complete')
      then begin
        Log := 'Aborting '+Item.SubItems[SUBITEM_FILENAME]+' (Thead '+Item.SubItems[SUBITEM_THREAD]+')';
        for i := 0 to threads.Count-1 do begin
          if not TConvertThread(threads[i]).Finished then
          begin
            if TConvertThread(threads[i]).ThreadID = StrToInt(Item.SubItems[SUBITEM_THREAD]) then
            begin TConvertThread(threads[i]).Cancel; end;
          end;
        end;
        Item := listUploads.GetNextItem(Item, sdAll, [isSelected]);
      end
      else Item := listUploads.GetNextItem(Item, sdAll, [isSelected]);
    end;
  end;

end;

procedure TformMain.About1Click(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

{
----------------------------------------------------------------------------
               Exit1Click
----------------------------------------------------------------------------
}
procedure TformMain.Exit1Click(Sender: TObject);
begin
  PostQuitMessage(0);
end;

{
----------------------------------------------------------------------------
               Login1Click
----------------------------------------------------------------------------
}
procedure TformMain.Login1Click(Sender: TObject);
begin
  formLogin.ShowModal;
end;

{
----------------------------------------------------------------------------
               Queue ContextMenu Popup
----------------------------------------------------------------------------
}
procedure TformMain.pmQueueContextMenuPopup(Sender: TObject);
begin
  if (listUploads.Items.Count > 0) then begin
    //Log := 'Nothing selected on context popup';
  end;

end;

{
----------------------------------------------------------------------------
               comboProjectListChange
----------------------------------------------------------------------------
}
procedure TformMain.comboProjectListChange(Sender: TObject);
begin
  Log := 'Starting Column List Download';
  DownloadColumns;
end;

{
----------------------------------------------------------------------------
               WMDropFiles
----------------------------------------------------------------------------
}
procedure TformMain.WMDropFiles(var message: TMessage);
var FileName: String;
    NameLen, Count, i: Integer;
    acFileName : array [0..255] of char;
    ListItem : TListItem;
    splitFile: TStringList;
    ErrorMsg : PAnsiChar;
begin
  splitFile := TStringList.Create;
  { Now, get the number of files dropped... }
  Count := DragQueryFile(message.WParam, $FFFFFFFF, acFileName, 255);
  //progMain.position := 0;
  { .. and for each of them... }
  if (comboNatNum.ItemIndex > 0) then
  if (integer(comboNatNum.Items.objects[comboNatNum.ItemIndex]) > 0) then
  begin
    statusBar.Panels[SBAR_STATUS].Text := 'Adding Files';
    Application.ProcessMessages;
    for i := 0 to Count-1 do begin
      //if count > 1 then progMain.position := round((i/(count-1))*100);
      //if count = 1 then progMain.position := 100;
      FileName := #00;
      { get the name's lenght of file[i] }
      NameLen := DragQueryFile(message.WParam, i, acFileName, 255);
      Inc(NameLen); { +1 to include the trailing #00 }
      SetLength(FileName, NameLen);

      { and finally get the filename }

      DragQueryFile(message.WParam, i, PChar(FileName), NameLen);

      Log := 'Dropped File: '+ExtractFileName(FileName);
      utility.Text := FileName;
      utility.Split('.',splitFile);

      if (FileName <> '') and (lowercase(splitFile[splitFile.Count-1]) = 'jpg') then begin
        listUploads.Items.BeginUpdate;
        ListItem := listUploads.Items.add();
        ListItem.ImageIndex := 86;
        ListItem.caption := comboNatNum.text; {Store #}
        ListItem.SubItems.Add(TString(comboProjectList.Items.objects[comboProjectList.ItemIndex]).str); {Project Code}
        ListItem.SubItems.Add(comboColumnList.Text); {Column Name}
        ListItem.SubItems.Add(ExtractFileName(FileName)); {File Name}
        ListItem.SubItems.Add('Queued'); {Status}
        ListItem.SubItems.Add('OK'); {Error Message}
        ListItem.SubItems.Add(FileName); {File Path}
        ListItem.SubItems.Add(Base64Decode(ftpDir)); {FTP Directory}
        ListItem.SubItems.Add(Base64Decode(ftpHost)); {FTP Host}
        ListItem.SubItems.Add(uploadPHP); {Upload PHP}
        ListItem.SubItems.Add(tstring(comboColumnList.Items.objects[comboColumnList.ItemIndex]).str); {Task ID}
        ListItem.SubItems.Add('0'); {Thread Index}
        ListItem.SubItems.Add(inttostr(integer(comboNatNum.Items.Objects[comboNatNum.itemindex]))); {RestID}

        if not (DirectoryExists(exePath+'\'+Settings.convertPath+'\'+comboNatNum.text)) then MkDir(exePath+'\'+Settings.convertPath+'\'+comboNatNum.text);
        CopyFile(pchar(FileName),pchar(exePath+'\'+Settings.convertPath+'\'+comboNatNum.text+'\'+ExtractFileName(FileName)),false);
        listUploads.Items.EndUpdate;
      end
      else
      begin
        ErrorMsg := PAnsiChar('Only files with the extension JPG can be uploaded.  Could not add file '+ExtractFileName(FileName));
        Application.MessageBox(PWideChar(ErrorMsg),'Error',MB_OK Or MB_ICONERROR);
      end;
      Application.ProcessMessages;
    end;
    statusBar.Panels[SBAR_STATUS].Text := 'Idle.';
    Log := END_LOG;
  end else
  begin
    ShowMessage('No NationalNum Selected!');
  end;
  DragFinish(message.WParam);
  message.Result := 0;
end;


{
----------------------------------------------------------------------------
               FormCreate
----------------------------------------------------------------------------
}
procedure TformMain.FormCreate(Sender: TObject);
begin
  maxThreads := 10;
  utility := TKUtil.Create('');
  DragAcceptFiles(Handle, LongBool(True));
  exePath := ExtractFilePath(ParamStr(0));
  //Application.MessageBox(PChar('Settings.convertPath: '+Settings.convertPath),'Error',MB_OK Or MB_ICONERROR);
  if not DirectoryExists(exePath+'\'+Settings.convertPath) then MkDir(exePath+'\'+Settings.convertPath);
end;

procedure TformMain.Remove1Click(Sender: TObject);
begin
  RemoveSelected;
end;

{
----------------------------------------------------------------------------
               RemoveSelected
----------------------------------------------------------------------------
}
procedure TformMain.RemoveSelected;
var
  Item: TListItem;
  TmpItem: TListItem;
  msgShown: Boolean;
begin
  msgShown := False;
  Item := listUploads.Selected;
  while Item <> nil do
  begin
    if
      (Item.SubItems[SUBITEM_STATUS] = 'Queued') or
      (Item.SubItems[SUBITEM_STATUS] = 'Aborted') or
      (Item.SubItems[SUBITEM_STATUS] = 'Upload Failed') or
      (Item.SubItems[SUBITEM_STATUS] = 'Complete')
    then begin
      Log := 'Removing File: '+Item.SubItems[SUBITEM_FILENAME];
      TmpItem := listUploads.GetNextItem(Item, sdAll, [isSelected]);
      Item.Delete;
      Item := TmpItem;
    end
    else
    begin
      if not msgShown then
      begin
        Application.MessageBox('Some selected files are still processing and cannot removed until they have completed.','Error',MB_OK Or MB_ICONERROR);
        msgShown := True;
      end;
      Item := listUploads.GetNextItem(Item, sdAll, [isSelected]);
    end;
  end;
  Log := END_LOG;
end;

procedure TformMain.RestartUpload1Click(Sender: TObject);
var
  Item: TListItem;
  msgShown: Boolean;
begin
  msgShown := False;
  Item := listUploads.Selected;
  while Item <> nil do begin
    if
      (Item.SubItems[SUBITEM_STATUS] = 'Aborted') or
      (Item.SubItems[SUBITEM_STATUS] = 'Queued') or
      (Item.SubItems[SUBITEM_STATUS] = 'Complete') or
      (Item.SubItems[SUBITEM_STATUS] = 'Upload Failed')
    then begin
      Log := 'Queing '+Item.SubItems[SUBITEM_FILENAME]+' (Thead '+Item.SubItems[SUBITEM_THREAD]+')';
      Item.SubItems[SUBITEM_STATUS] := 'Queued';
      Item.SubItems[SUBITEM_ERRORMSG] := 'OK';
      StartUpload(Item);
      Item := listUploads.GetNextItem(Item, sdAll, [isSelected]);
    end
    else
    begin
      if (msgShown = False) and
        (Item.SubItems[SUBITEM_STATUS] <> 'Queued') and
        (Item.SubItems[SUBITEM_STATUS] <> 'Complete')
       then begin
        Application.MessageBox('Some selected files are still processing and cannot restarted until they have completed.','Error',MB_OK Or MB_ICONERROR);
        msgShown := True;
      end;
      Item := listUploads.GetNextItem(Item, sdAll, [isSelected]);
    end;
  end;
end;

{
----------------------------------------------------------------------------
               btnRemoveAllClick
----------------------------------------------------------------------------
}
procedure TformMain.btnRemoveAllClick(Sender: TObject);
begin

  listUploads.SelectAll;
  RemoveSelected;
end;

{
----------------------------------------------------------------------------
               btnRemoveSelClick
----------------------------------------------------------------------------
}
procedure TformMain.btnRemoveSelClick(Sender: TObject);
begin
  RemoveSelected;
end;

{
----------------------------------------------------------------------------
               ConvertStatus1Click
----------------------------------------------------------------------------
}
procedure TformMain.ConvertStatus1Click(Sender: TObject);
begin
  formLog.Show;
end;

{
----------------------------------------------------------------------------
               btnGoClick
----------------------------------------------------------------------------
}
procedure TformMain.btnGoClick(Sender: TObject);
begin
  //panelMain.Enabled := false;
  //panelButtons.Enabled := false;
  btnGo.Enabled := False;
  listCount := 0;
  if (listUploads.Items.Count > 0) then begin
    progMain.Position := 0;
    progMain.Max := listUploads.Items.Count;
    progMain.Step := 1;
    timerMain.Enabled := true;
    statusBar.Panels[SBAR_STATUS].Text := 'Processing';
  end else Application.MessageBox('There are no files added to the queue.','Notice',MB_OK Or MB_ICONINFORMATION);;
end;

{
----------------------------------------------------------------------------
               threadsActive
----------------------------------------------------------------------------
}
function TformMain.threadsComplete;
var
  I : Integer;
  complete : Boolean;
begin
  complete := True;
  if threads.Count > 0 then begin
    for I := 0 to threads.Count-1 do begin
      if not TConvertThread(threads[i]).Finished then complete := False;
    end;

    if complete then Log := 'ALL THREADS HAVE COMPLETED';
    //else Log := 'SOME THREADS ARE STILL ACTIVE';
  end;

  Result := complete;

end;

procedure TformMain.StartUpload(Item: TListItem);
var
  convThread : TConvertThread;
  fileData : TFileData;
  tmpString : String;
begin
  tmpString := userid;
  with fileData do
  begin
    userID    := tmpString;                                                {Field: User ID      }
    taskID    := Item.subitems[SUBITEM_TASKID];    {Field: Task ID      }
    storenum  := Item.caption;                     {Field: Store #      }
    project   := Item.subitems[SUBITEM_PROJECT];   {Field: Project      }
    column    := Item.subitems[SUBITEM_COLNAME];   {Field: Column Name  }
    name      := Item.subitems[SUBITEM_FILENAME];  {Field: File Name    }
    path      := Item.subitems[SUBITEM_FILEPATH];  {Field: File Path    }
    status    := Item.subitems[SUBITEM_STATUS];    {Field: Status       }
    index     := listcount;                                                {Field: Upload Index }
    listItem  := Item;                             {Field: List Item    }
    uploadPHP := Item.subitems[SUBITEM_UPLOADPHP]; {Field: Upload PHP   }
    errorMsg  := Item.subitems[SUBITEM_ERRORMSG];  {Field: Error Message}
    restID    := Item.subitems[SUBITEM_RESTID];    {Field: RestID       }
  end;
  Log := 'Processing File: '+fileData.taskID;
  convThread := TConvertThread.Create(true);
  convThread.ItemCount := listUploads.Items.Count;
  convThread.ProgressBar := progMain;
  convThread.StatusBar := statusBar;
  convThread.FTPConn := mySite.FTP;
  convThread.FileData := fileData;
  convThread.Start;
  statusBar.Panels[SBAR_CONN].Text := 'Thread Connected';
  Item.subitems[SUBITEM_THREAD] := IntToStr(convThread.ThreadID);
  Item.SubItems[SUBITEM_STATUS] := 'Processing';
  Log := END_LOG;

end;

{
----------------------------------------------------------------------------
               timerMainTimer
----------------------------------------------------------------------------
}
procedure TformMain.timerMainTimer(Sender: TObject);
begin
  if listCount < listUploads.Items.Count then
  begin
    if (globalThreadCount < Settings.threadLimit) then
    begin
      if
        (listUploads.Items[listCount].SubItems[SUBITEM_STATUS] = 'Queued') or
        (listUploads.Items[listCount].SubItems[SUBITEM_STATUS] = 'Upload Failed')
      then StartUpload(listUploads.items[listcount])
      else progMain.StepIt;
      listcount := listcount + 1;
    end;
  end else
  begin
    if threadsComplete then begin
      Log := 'ALL FILES PROCESSED!';
      timerMain.Enabled := false;
      statusBar.Panels[SBAR_STATUS].Text := 'Idle.';
      panelMain.Enabled := true;
      panelButtons.Enabled := true;
      btnGo.Enabled := True;
      threads.Clear;
      Log := 'ALL THREADS COMPLETED AND CLEARD';
      statusBar.Panels[SBAR_CONN].Text := 'Not Connected';
    end;
  end;
end;


procedure TformMain.Settings1Click(Sender: TObject);
begin
  formSettings.ShowModal;
end;

end.


