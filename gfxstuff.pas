unit gfxstuff;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ComCtrls, Grids, JPEG, logform,OverbyteIcsFtpCli, ExtCtrls,
  OverbyteIcsUrl,dateutils, KUtil, EncdDecd, Base64, Site, Global, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, Data.DBXJSON, System.IOUtils, IdGlobalProtocols;

const
  FTP_STATUS_OPENCONN        = 150; {File OK, opening data connection}
  FTP_STATUS_COMMANDOK       = 200; {Command returned no errors}
  FTP_STATUS_LOGINREADY      = 220; {Service ready for new user}
  FTP_STATUS_CLOSESERV       = 221; {Service closing control connection}
  FTP_STATUS_CLOSECONN       = 226; {Closing data connection, File action successfull}
  FTP_STATUS_LOGGEDON        = 230; {User Logged on successfully}
  FTP_STATUS_PASREQUIRED     = 331; {User name OK, need password}
  FTP_STATUS_UNAVAILABLE     = 421; {Service not available; closing control connection}
  FTP_STATUS_CANTCONNECT     = 425; {Cant Open data connection}
  FTP_STATUS_ABORTED         = 426; {Connection closed; transfer aborted}
  FTP_STATUS_BADLOGIN        = 430; {Invalid username or password}
  FTP_STATUS_BADHOST         = 434; {Requested host unavailable}
  FTP_STATUS_BADACTION       = 450; {Requested action not taken}
  FTP_STATUS_LOCALERROR      = 451; {Requested action aborted. Local error in processing}
  FTP_STATUS_FILEERROR       = 452; {Action not taken. Insufficient storage space. File unavailable (file busy)}
  FTP_STATUS_SYNTAX1         = 500; {Syntax error, command unrecognized}
  FTP_STATUS_SYNTAX2         = 501; {Syntax error in parameters or arguments}
  FTP_STATUS_BADCMD_NOTUSED  = 502; {Command not implimented (ex CHMOD on Windows does nothing)}
  FTP_STATUS_BADCMD_BADPARAM = 504; {Command not implimented for that parameter}
  FTP_STATUS_NOTLOGGEDIN     = 530; {Not logged in}
  FTP_STATUS_BADACTION_FILE  = 550; {Requested action not taken (ex File unavailble, Dir Exists)}
  FTP_STATUS_DIRSTORAGELIMIT = 552; {Requested file action aborted. Exceeded storage allocation (for current directory)}
  FTP_STATUS_BADFILENAME     = 553; {Requested action not taken. File name not allowed}

  HTTP_STATUS_OK             = 200; {Standard response for successfull HTTP requests}
  HTTP_STATUS_BADREQ         = 400; {Bad Request}
  HTTP_STATUS_UNAUTHORIZED   = 401; {Unauthorized}
  HTTP_STATUS_FORBIDDEN      = 403; {Forbidden}
  HTTP_STATUS_NOTFOUND       = 404; {Not Found}
  HTTP_STATUS_SERVERERROR    = 500; {Internal Server Error}
  HTTP_STATUS_BADGATEWAY     = 502; {Bad Gateway}
  HTTP_STATUS_UNAVAILABLE    = 503; {Service Unavailable}

type
  TThreadStatus = (
    INIT,
    CONVERT,
    UPLOADICON,
    UPLOADTHUMB,
    UPLOADSDIMG,
    UPLOADHDIMG,
    UPDATELIST,
    CANCELED,
    FAILED,
    COMPLETE
  );

  TFileData = record
    restID   : String;
    userID   : String;
    taskID   : string;
    storenum : String;
    project  : String;
    column   : String;
    name     : String;
    errorMsg : string;
    newName  : String;
    path     : String;
    status   : String;
    index    : Integer;
    listItem : TListItem;
    uploadPHP: String;
  end;


  TConvertThread = class(TThread)
  private
    listitem : TListItem;
    listUploadsIndex : integer;
    ftpclient : TFtpClient;
    httpclient : THttpCli;
    sendinghttp : boolean;
    sendinghttpcomplete : boolean;
    status : TThreadStatus;
    fstatus : string;
    ferror : string;
    flog : String;
    uploading : boolean;
    uploadcomplete : boolean;
    utility : TKUtil;
    postTimer: TTimer;
    TimeOutCounter : Integer;

    ftpDefaults_Host : String;
    ftpDefaults_Port : String;
    ftpDefaults_UserName : String;
    ftpDefaults_Password : String;

    FTP_HOST : String;
    FTP_PORT : String;
    FTP_USER : String;
    FTP_PASS : String;
    FTP_DIR  : String;
    ftpRec  : TFTPRec;

    FTP_STATUS_DESC : array[100..633] of string;

    file_data : TFileData;
    FILE_PATH : String;
    FILE_MAIN : String;
    FILE_ICON : String;
    FILE_THUMB : String;
    FILE_SDRES : String;
    FILE_HDRES : string;

    progMain: TProgressBar;
    sBar: TStatusBar;
    totalCount: Integer;
    uploadParams : TUploadParams;

    procedure InitFtpClient;
    procedure InitHttpClient;

    procedure FTPUpdate(sender:TObject;var msg:string);
    procedure FTPFileReqDone(Sender: TObject; RqType: TFtpRequest; ErrCode: Word);
    procedure FTPProgress(Sender: TObject; Count: Int64; var Abort: Boolean);
    procedure HTTPReqDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);

    procedure InitProcess;
    procedure PrepareFiles;
    procedure UploadImageIcon;
    procedure UploadThumbnail;
    procedure UploadStandard;
    procedure UploadHiDef;
    procedure UpdateSite;

    procedure UpdateProgress;
    procedure SetConnectionData(data: TFTPRec);
    procedure SetProgress(pbar: TProgressBar);
    procedure SetSBar(bar: TStatusBar);
    procedure SetStatus(fStat: TThreadStatus);
    procedure SetError(msg: String);
    procedure AddLog(msg: String);
    procedure SetData(data: TFileData);
    procedure OnThreadTerminate(Sender: TObject);
    procedure OnPostTimer(Sender: TObject);
    procedure PopulateStatusList;
    procedure InitPostTimer;
    procedure StartTimeout;
    procedure StopTimeout;

  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean);
    procedure DebugData;
    procedure Cancel;

    property ProgressBar: TProgressBar
      read progMain
      write SetProgress;

    property StatusBar: TStatusBar
      read sBar
      write SetSBar;

    property ItemCount: Integer
      read totalCount
      write totalCount;

    property FTPConn : TFTPRec
      read ftpRec
      write SetConnectionData;

    property FileData : TFileData
      read file_data
      write SetData;

    property FileStatus : TThreadStatus
      read status
      write SetStatus;

    property FileError : String
      read ferror
      write SetError;

    property Log : String
      read flog
      write AddLog;

  end;

  TRGBArray = array[Word] of TRGBTriple;
  pRGBArray = ^TRGBArray;

procedure SmoothResize(Src, Dst: TBitmap);
function LoadJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string): Boolean;
function SaveJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string; Quality: Integer): Boolean;
procedure ResizeImage(FileName: string; NewFileName: string; MaxWidth: Integer);
function JPEGDimensions(Filename : string; var X, Y : Word) : boolean;

var
  globalThreadCount : integer;
  exePath : string;
  ftpDir : string;
  ftpHost : string;
  uploadPHP : string;
  userID : string;
  taskID : string;
  listCount : integer;
implementation

procedure TConvertThread.AddLog(msg: String);
begin
  flog := msg;
  formLog.memoLog.Lines.add(flog);
end;

procedure TConvertThread.SetError(msg: string);
begin
  ferror := msg;
  listitem.SubItems[SUBITEM_ERRORMSG] := ferror;
end;

{**
 * Fires after the FTP Client has completed a request from the server
 * @param (TThreadStatus) fStat Thread status code
 *}
procedure TConvertThread.SetStatus(fStat: TThreadStatus);
var
  msg : String;
  icon : Integer;
begin
  case fStat of
    INIT       : begin msg := 'Processing';       icon := 79; end;
    CONVERT    : begin msg := 'Converting';       icon := 87; end;
    UPLOADICON : begin msg := 'Uploading Icon';   icon := 79; end;
    UPLOADTHUMB: begin msg := 'Uploading Thumb';  icon := 79; end;
    UPLOADSDIMG: begin msg := 'Uploading LowRes'; icon := 79; end;
    UPLOADHDIMG: begin msg := 'Uploading HiRes';  icon := 79; end;
    UPDATELIST : begin msg := 'Posting File';     icon := 79; end;
    CANCELED   : begin msg := 'Aborted';          icon := 11; end;
    COMPLETE   : begin msg := 'Complete';         icon := 0;  end;
    FAILED     : begin msg := 'Upload Failed';    icon := 1;  end;
  end;

  fstatus := msg;
  if (fStat = CANCELED) or (fStat = FAILED) then status := COMPLETE
  else status := fStat;
  listitem.ImageIndex := icon;
  listitem.SubItems[SUBITEM_STATUS] := fstatus;
end;

{**
 * Upload has been canceled
 *}
procedure TConvertThread.Cancel;
begin
  FileStatus := CANCELED;
  FileError := 'Upload Aborted';
  //self.DoTerminate;
end;

{**
 * @private
 * Setter for storing the ftp configuration data
 * @param (TFTPRec) data FTP data record storing the ftp configuration
 *}
procedure TConvertThread.SetConnectionData(data: TFTPRec);
var
  TempArray : TBytes;
begin
  ftpRec := data;

  FTP_HOST := Base64Decode(data.Host);
  FTP_USER := Base64Decode(data.User);
  FTP_PASS := Base64Decode(data.Pass);
  FTP_PORT := Base64Decode(data.Port);
  FTP_DIR  := Base64Decode(data.Dir);

  ftpclient.Port := FTP_PORT;
  ftpclient.UserName := FTP_USER;
  ftpclient.PassWord := FTP_PASS;
  ftpclient.HostName := FTP_HOST;
end;

{**
 * Outputs basic debug information
 *}
procedure TConvertThread.DebugData;
begin
  Log := 'File Debug Data';
  Log := 'User ID...........: '+file_data.userID;
  Log := 'Column ID.........: '+file_data.taskID;
  Log := 'Store Number......: '+file_data.storenum;
  Log := 'Project Code......: '+file_data.project;
  Log := 'Column Name.......: '+file_data.column;
  Log := 'Local File Name...: '+file_data.name;
  //Log := 'Local FIle Path...: '+file_data.path;
  Log := 'Dest File Name....: '+file_data.newName;
  Log := 'File Status.......: '+file_data.status;
  Log := 'UploadPHP (Legacy): '+file_data.uploadPHP;
  Log := END_LOG;
end;

{**
 * Initializes local directory structure
 *}
procedure TConvertThread.InitProcess;
begin
  DebugData;
  FILE_PATH := exePath+'\'+Settings.convertPath+'\'+file_data.storenum;
  if not (DirectoryExists(FILE_PATH+'\icon')) then MkDir(FILE_PATH+'\icon');
  if not (DirectoryExists(FILE_PATH+'\thumbs')) then MkDir(FILE_PATH+'\thumbs');
  if not (DirectoryExists(FILE_PATH+'\standard')) then MkDir(FILE_PATH+'\standard');
  if not (DirectoryExists(FILE_PATH+'\highdef')) then MkDir(FILE_PATH+'\highdef');
  if status <> COMPLETE then FileStatus := CONVERT;
end;

{**
 * Prepares file uploads by resizing the images and connecting to the server
 *}
procedure TConvertThread.PrepareFiles;
begin
  FILE_MAIN  := FILE_PATH+'\'+file_data.name;
  FILE_ICON  := FILE_PATH+'\icon\'+file_data.name;
  FILE_THUMB := FILE_PATH+'\thumbs\'+file_data.name;
  FILE_SDRES := FILE_PATH+'\standard\'+file_data.name;
  FILE_HDRES := FILE_PATH+'\highdef\'+file_data.name;
  if not fileexists(FILE_ICON)  then ResizeImage(FILE_MAIN,FILE_ICON,16);
  if not fileexists(FILE_THUMB) then ResizeImage(FILE_MAIN,FILE_THUMB,120);
  if not fileexists(FILE_SDRES) then ResizeImage(FILE_MAIN,FILE_SDRES,800);
  if not fileexists(FILE_HDRES) then CopyFile(pchar(FILE_MAIN),pchar(FILE_HDRES),false);

  if not ftpclient.Connect then begin
    status := COMPLETE;
    Log := 'Cannot connect to server at '+FTP_HOST+':'+FTP_PORT;
  end; // else Log := 'Connected to Server '+FTP_HOST+':'+FTP_PORT+', YAY!';

  if status <> COMPLETE then FileStatus := UPLOADICON;
end;

{**
 * Uploads image icon and creates store root directory
 *}
procedure TConvertThread.UploadImageIcon;
begin;
  if not (uploading) and not (uploadcomplete) then
  begin
    uploading := true;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum;
    ftpclient.Mkd;
    ftpclient.LocalFileName := 'site chmod 777 '+FTP_DIR+'/'+file_data.storenum;
    ftpclient.Quote;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/icon';
    ftpclient.Mkd;
    ftpclient.LocalFileName := 'site chmod 777 '+FTP_DIR+'/'+file_data.storenum+'/icon';
    ftpclient.Quote;
    ftpclient.LocalFileName := FILE_ICON;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/icon/'+file_data.newName;
    ftpclient.Put;
  end;

  if (uploadcomplete) then
  begin
    //status := UPLOADTHUMB;
    if status <> COMPLETE then FileStatus := UPLOADTHUMB;
    uploading := false;
    uploadcomplete := false;
  end;
end;

{**
 * Uploads the image thumbnail through the FTP client
 *}
procedure TConvertThread.UploadThumbnail;
begin
  if not (uploading) and not (uploadcomplete) then
  begin
    uploading := true;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/thumbs';
    ftpclient.Mkd;
    ftpclient.LocalFileName := 'site chmod 777 '+FTP_DIR+'/'+file_data.storenum+'/thumbs';
    ftpclient.Quote;
    ftpclient.LocalFileName := FILE_THUMB;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/thumbs/'+file_data.newName;
    ftpclient.Put;
  end;

  if (uploadcomplete) then
  begin
    //status := UPLOADSDIMG;
    if status <> COMPLETE then FileStatus := UPLOADSDIMG;
    uploading := false;
    uploadcomplete := false;
  end;
end;

{**
 * Uploads the low resolution image using the FTP client
 *}
procedure TConvertThread.UploadStandard;
begin
  if not (uploading) and not (uploadcomplete) then
  begin
    uploading := true;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/standard';
    ftpclient.Mkd;
    ftpclient.LocalFileName := 'site chmod 777 '+FTP_DIR+'/'+file_data.storenum+'/standard';
    ftpclient.Quote;
    ftpclient.LocalFileName := FILE_SDRES;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/standard/'+file_data.newName;
    ftpclient.Put;
  end;

  if (uploadcomplete) then
  begin
    //status := UPLOADHDIMG;
    if status <> COMPLETE then FileStatus := UPLOADHDIMG;
    uploading := false;
    uploadcomplete := false;
  end;
end;

{**
 * Uploads the hi resolution image using the FTP client
 *}
procedure TConvertThread.UploadHiDef;
begin
  if not (uploading) and not (uploadcomplete) then
  begin
    uploading := true;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/highdef';
    ftpclient.Mkd;
    ftpclient.LocalFileName := 'site chmod 777 '+FTP_DIR+'/'+file_data.storenum+'/highdef';
    ftpclient.Quote;
    ftpclient.LocalFileName := FILE_HDRES;
    ftpclient.HostFileName := FTP_DIR+'/'+file_data.storenum+'/highdef/'+file_data.newName;
    ftpclient.Put;
  end;

  if (uploadcomplete) then
  begin
    //status := UPDATELIST;
    if status <> COMPLETE then FileStatus := UPDATELIST;
    uploading := false;
    uploadcomplete := false;
  end;
end;

{**
 * Updates the website with the uploaded file data
 *}
procedure TConvertThread.UpdateSite;
var
  Buffer: TBytes;
  Encoding: TEncoding;
  tempStream : TMemoryStream;
  tmpStrStream: TStringStream;
  postData : TStringList;
  RcvdString: String;
  pos : Integer;
  postHttp : THttpCli;

begin;
  {if not (sendinghttp) and not (sendinghttpcomplete) then
  begin
    FileStatus := 'Posting File';
    sendinghttp := true;
    Log := 'Posting to website:'+file_data.uploadPHP;
    sendinghttpcomplete := false;
    httpdata := 'submitform=1' + '&' +
      'userid=' + Trim(file_data.userID) + '&' +
      'taskid=' + Trim(file_data.taskID) + '&' +
      'natnum=' + Trim(file_data.storenum) + '&' +
      'prjcode=' + Trim(file_data.project) + '&' +
      'filename=' + UrlEncode(Trim(file_data.newName)) + '&' +
      'Submit=Submit';
    Log := 'Posting to website:'+httpdata;
    httpclient.SendStream := TMemoryStream.Create;
    httpclient.SendStream.Write(httpdata[1], Length(httpdata));
    httpclient.SendStream.Seek(0, 0);
    httpclient.RcvdStream := TMemoryStream.Create;
    httpclient.URL := Trim(file_data.uploadPHP);
    httpclient.PostAsync;
  end;}

  if not (sendinghttp) and not (sendinghttpcomplete) then
  begin
    StartTimeout;
    sendinghttp := true;
    sendinghttpcomplete := false;
    Log := 'POSTING FILE '+listItem.SubItems[SUBITEM_FILENAME];
    try
      postData := TStringList.Create;
      postData.Append('&restid='+Trim(file_data.restID));
      postData.Append('&userid='+Trim(file_data.userID));
      postData.Append('&tasklistid='+Trim(file_data.taskID));
      postData.Append('&taskid='+Trim(file_data.taskID));
      postData.Append('&natnum='+Trim(file_data.storenum));
      postData.Append('&prjcode='+Trim(file_data.project));
      postData.Append('&value='+UrlEncode(Trim(file_data.newName)));
      postData.Append('&Filename='+UrlEncode(Trim(file_data.newName)));
      postData.Append('&filelist='+UrlEncode(Trim(file_data.newName))); {Backwards Compatibility with v1.5.x}
      postData.Append('&prjtype='+Trim(uploadParams.prjtype));
      postData.Append('&prjsubtype='+Trim(uploadParams.prjsubtype));
      postData.Append('&clickedevent='+Trim(uploadParams.clickedevent));
      postData.Append('&virtual='+Trim(uploadParams.virtual));
      postData.Append('&uploader='+Trim(uploadParams.uploader));
      postData.Append('&notes='+UrlEncode(Trim(uploadParams.notes)));
      postData.Append('&innotes='+UrlEncode(Trim(uploadParams.notes))); {Backwards Compatibility with v1.5.x}
      postData.Append('&sendemail='+Trim(uploadParams.sendemail));
      postData.Append('&insendemail='+Trim(uploadParams.sendemail)); {Backwards Compatibility with v1.5.x}
      postData.Append('&sessionid='+Trim(sessionid));
      RcvdString := StringReplace(postData.Text,#13,'',[rfReplaceAll]);
      RcvdString := StringReplace(RcvdString,#10,'',[rfReplaceAll]);

      if formLog.btnShowHTTPLogs.Down = True then
      begin
        Log := 'Website URL: '+mySite.URL+POST_SITE;
        Log := 'URL Params : '+RcvdString;
        Log := 'Full URL   : '+mySite.URL+POST_SITE+RcvdString;
      end;

      httpclient.SendStream := TMemoryStream.Create;
      httpclient.SendStream.Write(RcvdString[1], Length(RcvdString));
      httpclient.SendStream.Seek(0, 0);
      httpclient.RcvdStream := TMemoryStream.Create;
      httpclient.ContentTypePost := 'application/x-www-form-urlencoded';
      httpclient.URL := (mySite.URL+POST_SITE+RcvdString);
      httpclient.PostAsync;
    except
      on E : Exception do begin
        Log := END_LOG;
        Log := 'Thread ID: '+IntToStr(self.ThreadID);
        Log := 'FAILED TO POST FILE '+listItem.SubItems[SUBITEM_FILENAME];
        Log := E.ClassName+' error raised with message: '+E.Message;
        Log := END_LOG;
        StopTimeout;
        FileStatus := FAILED;
        status := COMPLETE;
        FileError := 'Failed to post file, please manually restart upload';
      end;
    end;
  end;

  if (sendinghttpcomplete) then
  begin
    DeleteFile(FILE_MAIN);
    DeleteFile(FILE_ICON);
    DeleteFile(FILE_THUMB);
    DeleteFile(FILE_SDRES);
    DeleteFile(FILE_HDRES);
    //status := COMPLETE;
    FileStatus := COMPLETE;
    updateProgress;
  end;
end;

{**
 * @private
 * Setter function for setting the progress bar
 *}
procedure TConvertThread.SetProgress(pbar: TProgressBar);
begin
  progMain := pbar;
end;

{**
 * @private
 * Setter function for setting the status bar
 *}
procedure TConvertThread.SetSBar(bar: TStatusBar);
begin
  sBar := bar;
end;

{**
 * @private
 * Updates the progress bar as needed
 *}
procedure TConvertThread.UpdateProgress;
begin
  if (totalCount <> listUploadsIndex) then progMain.StepIt
  else progMain.Position := totalCount;
end;

{**
 * @event FTPUpdate
 * Fires after the FTP Client has completed a request from the server
 * @param (TObject) Sender this FTP Client.
 * @param (String) Msg FTP Response message.
 *}
procedure TConvertThread.FTPUpdate(sender:TObject;var Msg: String);
var
  msgString: String;
  ftpCode : Integer;
begin
  //FTP_STATUS_OPENCONN        = 150; {File OK, opening data connection}
  //FTP_STATUS_COMMANDOK       = 200; {Command returned no errors}
  //FTP_STATUS_LOGINREADY      = 220; {Service ready for new user}
  //FTP_STATUS_CLOSESERV       = 221; {Service closing control connection}
  //FTP_STATUS_CLOSECONN       = 226; {Closing data connection, File action successfull}
  //FTP_STATUS_LOGGEDON        = 230; {User Logged on successfully}
  //FTP_STATUS_PASREQUIRED     = 331; {User name OK, need password}
  //FTP_STATUS_UNAVAILABLE     = 421; {Service not available; closing control connection}
  //FTP_STATUS_CANTCONNECT     = 425; {Cant Open data connection}
  //FTP_STATUS_ABORTED         = 426; {Connection closed; transfer aborted}
  //FTP_STATUS_BADLOGIN        = 430; {Invalid username or password}
  //FTP_STATUS_BADHOST         = 434; {Requested host unavailable}
  //FTP_STATUS_BADACTION       = 450; {Requested action not taken}
  //FTP_STATUS_LOCALERROR      = 451; {Requested action aborted. Local error in processing}
  //FTP_STATUS_FILEERROR       = 452; {Action not taken. Insufficient storage space. File unavailable (file busy)}
  //FTP_STATUS_SYNTAX1         = 500; {Syntax error, command unrecognized}
  //FTP_STATUS_SYNTAX2         = 501; {Syntax error in parameters or arguments}
  //FTP_STATUS_BADCMD_NOTUSED  = 502; {Command not implimented (ex CHMOD on Windows does nothing)}
  //FTP_STATUS_BADCMD_BADPARAM = 504; {Command not implimented for that parameter}
  //FTP_STATUS_NOTLOGGEDIN     = 530; {Not logged in}
  //FTP_STATUS_BADACTION_FILE  = 550; {Requested action not taken (ex File unavailble, Dir Exists)}
  //FTP_STATUS_DIRSTORAGELIMIT = 552; {Requested file action aborted. Exceeded storage allocation (for current directory)}
  //FTP_STATUS_BADFILENAME     = 553; {Requested action not taken. File name not allowed}

  msgString := Copy(msg,3);
  if formLog.btnShowFTPLogs.Down = True then Log := '(FTP): ['+IntToStr(ftpclient.StatusCode)+'] '+msg;

  case ftpclient.StatusCode of
    //FTP_STATUS_CLOSECONN: begin FileError := 'OK'; end;
    FTP_STATUS_CANTCONNECT,
    FTP_STATUS_BADHOST,
    FTP_STATUS_LOCALERROR,
    FTP_STATUS_SYNTAX1,
    FTP_STATUS_SYNTAX2,
    //FTP_STATUS_BADACTION_FILE,
    FTP_STATUS_DIRSTORAGELIMIT,
    FTP_STATUS_BADFILENAME,
    FTP_STATUS_BADLOGIN: begin
      FileStatus := FAILED;
      FileError  := FTP_STATUS_DESC[ftpclient.StatusCode]+'. '+msgString;
    end;
    FTP_STATUS_NOTLOGGEDIN: begin
      if (UpperCase(msgString) <> 'ABOR') then begin
        FileStatus := FAILED;
        FileError := FTP_STATUS_DESC[ftpclient.StatusCode]+'. '+msgString;
      end;
    end;
    FTP_STATUS_ABORTED, FTP_STATUS_UNAVAILABLE : begin
      if (UpperCase(msgString) <> 'QUIT') then begin
        FileStatus := FAILED;
        FileError := FTP_STATUS_DESC[ftpclient.StatusCode]+'. '+msgString;
      end;
    end;
  end;

  if (ftpclient.Connected <> True) and (ftpclient.StatusCode = 500) then begin
    listitem.SubItems[SUBITEM_STATUS] := 'Upload Failed';
    FileError := 'Cannot connect to server at '+FTP_HOST+':'+FTP_PORT;
  end;


end;

{**
 * @event FTPFileReqDone
 * Fires after the FTP Client has completed a request from the server
 * @param (TObject) Sender this FTP Client.
 * @param (TFtpRequest) RqType FTP Request Object.
 * @param (Word) ErrCode the Error code reported back from the server
 *}
procedure TConvertThread.FTPFileReqDone(Sender: TObject; RqType: TFtpRequest; ErrCode: Word);
begin
  if (uploading = true) then
  begin
    if (ftpclient.StatusCode = 226) then
    begin
      uploadcomplete := true;
      uploading := false;
    end;
  end;
end;

procedure TConvertThread.FTPProgress(Sender: TObject; Count: Int64; var Abort: Boolean);
var
  filesize : Int64;
  progress : Integer;
begin
  try
    filesize := FileSizeByName(ftpclient.LocalFileName);
    progress := Round((Count/filesize)*100);
    if status <> COMPLETE then FileError := 'Upload Progress: '+IntToStr(progress)+'%; Bytes: '+IntToStr(Count)+' of '+IntToStr(filesize);
  except
  end;
end;

{**
 * @event HTTPReqDone
 * Fires after the HTTP Client has received a response from the server
 * @param (TObject) Sender this HTTP Client.
 * @param (THttpRequest) RqType HTTP Request Object.
 * @param (Word) ErrCode the Error code reported back from the server
 *}
procedure TConvertThread.HTTPReqDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  SL : TStringStream;
  RcvdString: String;
  RcvdBytes : TBytes;
  JSON : TJSONObject;
  success : Boolean;
  msg : String;
  LSuccess: TJSONValue;
begin
  //HTTP_STATUS_OK             = 200; {Standard response for successfull HTTP requests}
  //HTTP_STATUS_BADREQ         = 400; {Bad Request}
  //HTTP_STATUS_UNAUTHORIZED   = 401; {Unauthorized}
  //HTTP_STATUS_FORBIDDEN      = 403; {Forbidden}
  //HTTP_STATUS_NOTFOUND       = 404; {Not Found}
  //HTTP_STATUS_SERVERERROR    = 500; {Internal Server Error}
  //HTTP_STATUS_BADGATEWAY     = 502; {Bad Gateway}
  //HTTP_STATUS_UNAVAILABLE    = 503; {Service Unavailable}

  if (sendinghttp = true) then
  begin

    if (httpclient.StatusCode >= 200) and (httpclient.StatusCode <= 299) then
    begin
      {READ FROM THE HTTP RECEIVED STREAM}
      SL := TStringStream.Create('');
      SL.CopyFrom(httpclient.RcvdStream,0);
      RcvdString := SL.DataString;
      if formLog.btnShowHTTPLogs.Down = True then Log := 'RAW SERVER OUTPUT: '+RcvdString;

      {PARSE SERVER JSON OUTPUT}
      RcvdBytes := TEncoding.ASCII.GetBytes(RcvdString);
      JSON := TJSONObject.ParseJSONValue(RcvdBytes,0) as TJSONObject;
      try
        LSuccess := JSON.Get('success').JsonValue;
        if LSuccess is TJSONTrue then success := True else success := False;
        msg := JSON.Get('message').JsonValue.Value;
      except
        success := True;
        msg := 'Server response was unrecognized.  File may not have been posted.';
      end;
      JSON.Free;

      if not success then FileStatus := FAILED;
      FileError := msg;
    end
    else begin
      case httpclient.StatusCode of
        400..499 : begin
          case httpclient.StatusCode of
            HTTP_STATUS_BADREQ       : begin FileError := 'Web Response: Bad Request'; end;
            HTTP_STATUS_UNAUTHORIZED : begin FileError := 'Web Response: Authorization Required by Service'; end;
            HTTP_STATUS_FORBIDDEN    : begin FileError := 'Web Response: Websever refuses to respond to request (Forbidden)'; end;
            HTTP_STATUS_NOTFOUND     : begin FileError := 'Web Response: Page/service not found'; end;
            else FileError := 'Web Response: Unknown client error';
          end;
        end;
        500..599 : begin
          case httpclient.StatusCode of
            HTTP_STATUS_SERVERERROR : begin FileError := 'Web Response: Internal Server Error'; end;
            HTTP_STATUS_BADGATEWAY  : begin FileError := 'Web Response: Bad Gateway'; end;
            HTTP_STATUS_UNAVAILABLE : begin FileError := 'Web Response: The server is currently unavailable (because it is overloaded or down for maintenance)'; end;
            else FileError := 'Web Response: Unknown server error';
          end;
        end;
      end;
      FileStatus := FAILED;
      status := COMPLETE;
    end;
    StopTimeout;
    sendinghttpcomplete := true;
    sendinghttp := false;
    httpclient.Close;
    httpclient.Destroy;
  end;
end;

{**
 * @private
 * Polutating FTP status description array
 *}
procedure TConvertThread.PopulateStatusList;
begin
  FTP_STATUS_DESC[FTP_STATUS_OPENCONN]        := 'File OK, opening data connection';
  FTP_STATUS_DESC[FTP_STATUS_COMMANDOK]       := 'Command returned no errors';
  FTP_STATUS_DESC[FTP_STATUS_LOGINREADY]      := 'Service ready for new user';
  FTP_STATUS_DESC[FTP_STATUS_CLOSESERV]       := 'Service closing control connection';
  FTP_STATUS_DESC[FTP_STATUS_CLOSECONN]       := 'Closing data connection, File action successfull';
  FTP_STATUS_DESC[FTP_STATUS_LOGGEDON]        := 'User Logged on successfully';
  FTP_STATUS_DESC[FTP_STATUS_PASREQUIRED]     := 'User name OK, need password';
  FTP_STATUS_DESC[FTP_STATUS_UNAVAILABLE]     := 'Service not available; closing control connection';
  FTP_STATUS_DESC[FTP_STATUS_CANTCONNECT]     := 'Cant Open data connection';
  FTP_STATUS_DESC[FTP_STATUS_ABORTED]         := 'Connection closed; transfer aborted';
  FTP_STATUS_DESC[FTP_STATUS_BADLOGIN]        := 'Invalid username or password';
  FTP_STATUS_DESC[FTP_STATUS_BADHOST]         := 'Requested host unavailable';
  FTP_STATUS_DESC[FTP_STATUS_BADACTION]       := 'Requested action not taken';
  FTP_STATUS_DESC[FTP_STATUS_LOCALERROR]      := 'Requested action aborted. Local error in processing';
  FTP_STATUS_DESC[FTP_STATUS_FILEERROR]       := 'Action not taken. Insufficient storage space. File unavailable (file busy)';
  FTP_STATUS_DESC[FTP_STATUS_SYNTAX1]         := 'Syntax error, command unrecognized';
  FTP_STATUS_DESC[FTP_STATUS_SYNTAX2]         := 'Syntax error in parameters or arguments';
  FTP_STATUS_DESC[FTP_STATUS_BADCMD_NOTUSED]  := 'Command not implimented (ex CHMOD on Windows does nothing)';
  FTP_STATUS_DESC[FTP_STATUS_BADCMD_BADPARAM] := 'Command not implimented for that parameter';
  FTP_STATUS_DESC[FTP_STATUS_NOTLOGGEDIN]     := 'Not logged in';
  FTP_STATUS_DESC[FTP_STATUS_BADACTION_FILE]  := 'Requested action not taken (ex File unavailble, Dir Exists)';
  FTP_STATUS_DESC[FTP_STATUS_DIRSTORAGELIMIT] := 'Requested file action aborted. Exceeded storage allocation (for current directory)';
  FTP_STATUS_DESC[FTP_STATUS_BADFILENAME]     := 'Requested action not taken. File name not allowed';
end;

{**
 * Creates an instance of this convert thread object.
 *}
constructor TConvertThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  utility := TKUtil.Create('');
  Self.OnTerminate := self.OnThreadTerminate;
  globalThreadCount := globalThreadCount + 1;
  Log := '(start) Thread Count: '+inttostr(globalThreadCount);

  PopulateStatusList;

  ftpDefaults_Host := '1.1.1.90';
  ftpDefaults_Port := '21';
  ftpDefaults_UserName := 'dfadmin';
  ftpDefaults_Password := 'dfmaster';

  with uploadParams do
  begin
    prjtype := 'store';
    prjsubtype := 'store';
    clickedevent := 'icon-task-edit-imageupload';
    virtual := '0';
    uploader := 'app';
    notes := 'Image added through the IPM MultiUploader XE2 application';
    sendemail := '0';
  end;

  InitFtpClient;
  InitHttpClient;
  InitPostTimer;

  status := INIT;
  //FileStatus := INIT;
end;

procedure TConvertThread.InitPostTimer;
begin
  TimeOutCounter := 0;
  postTimer := TTimer.Create(nil);
  postTimer.Enabled := False;
  postTimer.Interval := 1000;
  postTimer.OnTimer := OnPostTimer;
end;

procedure TConvertThread.StartTimeout;
begin
  TimeOutCounter := 0;
  postTimer.Enabled := True;
end;

procedure TConvertThread.StopTimeout;
begin
  postTimer.Enabled := False;
end;

{**
 * Initializes the FTP Client used to upload files to the IPM
 *}
procedure TConvertThread.InitFtpClient;
begin
  ftpclient := TFtpClient.Create(nil);
  ftpclient.Port := ftpDefaults_Port;
  ftpclient.UserName := ftpDefaults_UserName;
  ftpclient.PassWord := ftpDefaults_Password;
  ftpclient.OnDisplay := FTPUpdate;
  ftpclient.OnRequestDone := FTPFileReqDone;
  ftpclient.OnProgress64 := FTPProgress;
end;

{**
 * Initializes the HTTP Client used to post file data to the IPM
 *}
procedure TConvertThread.InitHttpClient;
begin
  httpclient := THttpCli.Create(nil);
  httpclient.OnRequestDone := HTTPReqDone;
end;

{**
 * Provides an abstract or pure virtual method to contain the code which executes when the thread is run.
 *}
procedure TConvertThread.Execute;
begin
  FreeOnTerminate := True;
  while status <> COMPLETE do
  begin
    case status of
      INIT  : begin InitProcess;     end;
      CONVERT: begin PrepareFiles;    end;
      UPLOADICON: begin UploadImageIcon;      end;
      UPLOADTHUMB: begin UploadThumbnail; end;
      UPLOADSDIMG: begin UploadStandard;  end;
      UPLOADHDIMG: begin UploadHiDef;     end;
      UPDATELIST: begin UpdateSite;   end;
    end;
    Application.ProcessMessages;
  end;
  globalThreadCount := globalThreadCount - 1;
  Log := '(finish) Thread Count: '+inttostr(globalThreadCount);
end;

{**
 * @event OnThreadTerminate
 * Fires after the thread's Execute method has returned and before the thread is destroyed
 * @param (TObject) Sender this TThread Object.
 *}
procedure TConvertThread.OnThreadTerminate(Sender: TObject);
var
  index : Integer;
  pos : Integer;
  temp : TConvertThread;
begin
  Log := 'Thread '+IntToStr(self.ThreadID)+' Terminating...';
  if ftpclient.Connected then begin
    ftpclient.Abort;
    ftpclient.AbortXfer;
  end;
  ftpclient.Quit;
  ftpclient.Destroy;

  //FileStatus := COMPLETE;
  {index := StrToInt(listitem.SubItems[SUBITEM_THREAD]);
  for pos := 0 to threads.Count do begin
    temp := threads[pos];
    if temp.ThreadID = self.ThreadID then begin
      Log := 'FOUND THREAD AT THREADS(TLIST) INDEX: '+inttostr(index);
      threads.Delete(pos);
    end;
  end;}

end;

procedure TConvertThread.SetData(data: TFileData);
begin
  file_data := data;

  listUploadsIndex := data.index;
  listitem := data.listItem;

  file_data.newName := stringReplace(inttostr(DateTimeToUnix(now))+data.name,'#','num',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'<','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'>','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'%','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'{','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'}','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'[','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,']','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'|','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'\','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'/','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'^','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'~','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'`','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'$','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'&','and',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'+','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,',','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,':','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,';','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'=','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'?','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,'@','',[rfReplaceAll]);
  file_data.newName := stringReplace(file_data.newName,' ','_',[rfReplaceAll]);

end;

procedure TConvertThread.OnPostTimer(Sender: TObject);
begin
  TimeOutCounter := TimeOutCounter + 1;
  Log := 'TimeOutCounter (Thread '+IntToStr(self.ThreadID)+'): '+IntToStr(TimeOutCounter);
  if TimeOutCounter >= 60 then begin
    if ftpclient.Connect then ftpclient.Abort;
    //httpclient.Abort;
    FileStatus := FAILED;
    status := COMPLETE;
    FileError:= 'Upload timedout, please manually restart upload';
    postTimer.Enabled := False;
  end;

end;

procedure SmoothResize(Src, Dst: TBitmap);
var
  x, y: Integer;
  xP, yP: Integer;
  xP2, yP2: Integer;
  SrcLine1, SrcLine2: pRGBArray;
  t3: Integer;
  z, z2, iz2: Integer;
  DstLine: pRGBArray;
  DstGap: Integer;
  w1, w2, w3, w4: Integer;
begin
  Src.PixelFormat := pf24Bit;
  Dst.PixelFormat := pf24Bit;

  if (Src.Width = Dst.Width) and (Src.Height = Dst.Height) then
    Dst.Assign(Src)
  else
  begin
    DstLine := Dst.ScanLine[0];
    DstGap  := Integer(Dst.ScanLine[1]) - Integer(DstLine);

    xP2 := MulDiv(pred(Src.Width), $10000, Dst.Width);
    yP2 := MulDiv(pred(Src.Height), $10000, Dst.Height);
    yP  := 0;

    for y := 0 to pred(Dst.Height) do
    begin
      xP := 0;

      SrcLine1 := Src.ScanLine[yP shr 16];

      if (yP shr 16 < pred(Src.Height)) then
        SrcLine2 := Src.ScanLine[succ(yP shr 16)]
      else
        SrcLine2 := Src.ScanLine[yP shr 16];

      z2  := succ(yP and $FFFF);
      iz2 := succ((not yp) and $FFFF);
      for x := 0 to pred(Dst.Width) do
      begin
        t3 := xP shr 16;
        z  := xP and $FFFF;
        w2 := MulDiv(z, iz2, $10000);
        w1 := iz2 - w2;
        w4 := MulDiv(z, z2, $10000);
        w3 := z2 - w4;
        DstLine[x].rgbtRed := (SrcLine1[t3].rgbtRed * w1 +
          SrcLine1[t3 + 1].rgbtRed * w2 +
          SrcLine2[t3].rgbtRed * w3 + SrcLine2[t3 + 1].rgbtRed * w4) shr 16;
        DstLine[x].rgbtGreen :=
          (SrcLine1[t3].rgbtGreen * w1 + SrcLine1[t3 + 1].rgbtGreen * w2 +

          SrcLine2[t3].rgbtGreen * w3 + SrcLine2[t3 + 1].rgbtGreen * w4) shr 16;
        DstLine[x].rgbtBlue := (SrcLine1[t3].rgbtBlue * w1 +
          SrcLine1[t3 + 1].rgbtBlue * w2 +
          SrcLine2[t3].rgbtBlue * w3 +
          SrcLine2[t3 + 1].rgbtBlue * w4) shr 16;
        Inc(xP, xP2);
      end; {for}
      Inc(yP, yP2);
      DstLine := pRGBArray(Integer(DstLine) + DstGap);
    end; {for}
  end; {if}
end; {SmoothResize}

{---------------------------------------------------------------------------
-----------------------}

function LoadJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string): Boolean;
var
  JPEGImage: TJPEGImage;
begin
  if (FileName = '') then    // No FileName so nothing
    Result := False  //to load - return False...
  else
  begin
    try  // Start of try except
      JPEGImage := TJPEGImage.Create;  // Create the JPEG image... try  // now
      try  // to load the file but
        JPEGImage.LoadFromFile(FilePath + FileName);
        // might fail...with an Exception.
        Bitmap.Assign(JPEGImage);
        // Assign the image to our bitmap.Result := True;
        // Got it so return True.
      finally
        JPEGImage.Free;  // ...must get rid of the JPEG image. finally
      end; {try}
    except
      Result := False; // Oops...never Loaded, so return False.
    end; {try}
  end; {if}
  Result := True;
end; {LoadJPEGPictureFile}


{---------------------------------------------------------------------------
-----------------------}


function SaveJPEGPictureFile(Bitmap: TBitmap; FilePath, FileName: string;
  Quality: Integer): Boolean;
begin
  Result := True;
  try
    if ForceDirectories(FilePath) then
    begin
      with TJPegImage.Create do
      begin
        try
          Assign(Bitmap);
          CompressionQuality := Quality;
          SaveToFile(FilePath + FileName);
        finally
          Free;
        end; {try}
      end; {with}
    end; {if}
  except
    raise;
    Result := False;
  end; {try}
end; {SaveJPEGPictureFile}


{---------------------------------------------------------------------------
-----------------------}


procedure ResizeImage(FileName: string; NewFileName: string; MaxWidth: Integer);
var
  OldBitmap: TBitmap;
  NewBitmap: TBitmap;
  aWidth: Integer;
begin
  OldBitmap := TBitmap.Create;
  try
    LoadJPEGPictureFile(OldBitmap, '', FileName);
    begin
      //showMessage(FileName);
      aWidth := OldBitmap.Width;
      if (OldBitmap.Width > MaxWidth) then
      begin
        aWidth    := MaxWidth;
        NewBitmap := TBitmap.Create;
        try
          NewBitmap.Width  := MaxWidth;
          NewBitmap.Height := MulDiv(MaxWidth, OldBitmap.Height, OldBitmap.Width);
          SmoothResize(OldBitmap, NewBitmap);
          SaveJPEGPictureFile(NewBitmap, ExtractFilePath(NewFileName), ExtractFileName(NewFileName), 75);
        finally
          NewBitmap.Free;
        end; {try}
      end else
      begin
        SaveJPEGPictureFile(OldBitmap, ExtractFilePath(NewFileName), ExtractFileName(NewFileName), 75);
      end; {if}
    end; {if}
  finally
    OldBitmap.Free;
  end; {try}
end;


{---------------------------------------------------------------------------
-----------------------}

function JPEGDimensions(Filename : string; var X, Y : Word) : boolean;
var
  SegmentPos : Integer;
  SOIcount : Integer;
  b : byte;
begin
  Result  := False;
  with TFileStream.Create(Filename, fmOpenRead or fmShareDenyNone) do
  begin
    try
      Position := 0;
      Read(X, 2);
      if (X <> $D8FF) then
        exit;
      SOIcount  := 0;
      Position  := 0;
      while (Position + 7 < Size) do
      begin
        Read(b, 1);
        if (b = $FF) then begin
          Read(b, 1);
          if (b = $D8) then
            inc(SOIcount);
          if (b = $DA) then
            break;
        end; {if}
      end; {while}
      if (b <> $DA) then
        exit;
      SegmentPos  := -1;
      Position    := 0;
      while (Position + 7 < Size) do
      begin
        Read(b, 1);
        if (b = $FF) then
        begin
          Read(b, 1);
          if (b in [$C0, $C1, $C2]) then
          begin
            SegmentPos  := Position;
            dec(SOIcount);
            if (SOIcount = 0) then
              break;
          end; {if}
        end; {if}
      end; {while}
      if (SegmentPos = -1) then
        exit;
      if (Position + 7 > Size) then
        exit;
      Position := SegmentPos + 3;
      Read(Y, 2);
      Read(X, 2);
      X := Swap(X);
      Y := Swap(Y);
      Result  := true;
    finally
      Free;
    end; {try}
  end; {with}
end; {JPEGDimensions}

end.
