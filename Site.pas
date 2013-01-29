unit Site;

interface

type
  TFTPRec = record
    Host : String;
    User : String;
    Pass : String;
    Port : String;
    Dir : String;
  end;

  TSite = record
    ID : Integer;
    SecName: String;
    Name : String;
    DBIP : String;
    DB : String;
    Desc : String;
    Version : String;
    URL : String;
    Path : String;
    Added : String;
    UploadPHP: String;
    FTP: TFTPRec;

    {constructor Create(
      cID : Integer;
      cSecName: String;
      cName : String;
      cDBIP : String;
      cDB : String;
      cDesc : String;
      cVersion : String;
      cURL : String;
      cPath : String;
      cAdded : String;
      cHost : String;
      cUser : String;
      cPass : String;
      cPort : String;
      cDir : String;
    );}
  end;

  TUploadParams = record
    restid       : String;
    value        : String;
    prjcode      : String;
    prjtype      : String;
    prjsubtype   : String;
    tasklistid   : String;
    taskid       : String;
    clickedevent : String;
    virtual      : String;
    natnum       : String;
    uploader     : String;
    Filename     : String;
    notes        : String;
    sendemail    : String;
  end;

implementation

{constructor TSite.Create(
  cID : Integer;
  cSecName: String;
  cName : String;
  cDBIP : String;
  cDB : String;
  cDesc : String;
  cVersion : String;
  cURL : String;
  cPath : String;
  cAdded : String;
  cHost : String;
  cUser : String;
  cPass : String;
  cPort : String;
  cDir : String;);
begin
  ID      := cID;
  SecName := cSecName;
  Name    := cName
  DBIP    := cDBIP
  DB      := cDB;
  Desc    := cDesc;
  Version := cVersion;
  URL     := cURL;
  Path    := cPath;
  Added   := cAdded;
  FTP.Host:= cHost;
  FTP.User:= cUser;
  FTP.Pass:= cPass;
  FTP.Port:= cPort;
  FTP.Dir := cDir;
end;}


end.
