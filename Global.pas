unit Global;

interface

uses Windows, SysUtils, Variants, Classes, Site, IniFiles, Messages,  Controls, Forms;

const
  SITE_SITE         = 'http://www.hkipm.com/modules/sites/handlers/ajax/sites.ajax.php?command=listsites&output=xml&ipm=1';
  LOGIN_SITE        = '/interfaces/core/handlers/ajax/core.ajax.php?command=login&output=xml';
  PROJECT_SITE      = '/modules/projectpanel/handlers/ajax/projectpanel.ajax.php?command=getprojectlist&output=xml';
  TASK_SITE         = '/modules/projectpanel/handlers/ajax/projectpanel.ajax.php?command=getcolumnlist&output=xml';
  STORE_SITE        = '/modules/projectpanel/handlers/ajax/projectpanel.ajax.php?command=getstorelist&output=xml';
  POST_SITE         = '/modules/projectpanel/handlers/ajax/projectpanel.ajax.php?command=editcolumnset';

  END_LOG = '--------------------------------------------------------------------------------';
  SUBITEM_PROJECT   = 0;
  SUBITEM_COLNAME   = 1;
  SUBITEM_FILENAME  = 2;
  SUBITEM_STATUS    = 3;
  SUBITEM_ERRORMSG  = 4;
  SUBITEM_FILEPATH  = 5;
  SUBITEM_FTPDIR    = 6;
  SUBITEM_FTPHOST   = 7;
  SUBITEM_UPLOADPHP = 8;
  SUBITEM_TASKID    = 9;
  SUBITEM_THREAD    = 10;
  SUBITEM_RESTID    = 11;

  SBAR_MESSAGE      = 0;
  SBAR_PROJECT      = 1;
  SBAR_CONN         = 2;
  SBAR_STATUS       = 3;

type
  TGlobalSettings = record
    convertPath : String;
    threadLimit : Integer;
    defaultSite : String;
    defaultSiteID : Integer;
    UserName : String;
    Password : String;
  end;

  TGlobal = Class

  public
    constructor Create;
    procedure LoadSettings;
    function GetVersion : String;
    function CaseString(Selector : String; CaseList: array of string) : Integer;
    procedure SaveSetting(name: string; value: Variant);

  end;

var
  G : TGlobal;
  Settings : TGlobalSettings;
  siteItem : TSite;
  siteList : array of TSite;
  mySite : TSite;
  AppVersion : String;
  threads : TList;
  sessionid : String;
  {convertPath : String;
  threadLimit : Integer;}

implementation

constructor TGlobal.Create;
begin
  {Empty Constructor}
  AppVersion := GetVersion;
  threads := TList.Create;
end;

procedure TGlobal.LoadSettings;
var
  Ini : TIniFile;
begin
  Ini := TIniFile.Create( ChangeFileExt( Application.ExeName, '.ini' ) );
  try
    Settings.threadLimit := Ini.ReadInteger( 'Threads', 'threadLimit', 10 );
    Settings.convertPath := Ini.ReadString( 'Files', 'convertPath', 'imgtmp' );
    Settings.defaultSite := Ini.ReadString( 'Site', 'defaultSite', '' );
    Settings.defaultSiteID := Ini.ReadInteger( 'Site', 'defaultSiteID', 0 );
    Settings.UserName := Ini.ReadString( 'General', 'username', '' );
    Settings.Password := Ini.ReadString( 'General', 'password', '' );
    {if Ini.ReadBool( 'Form', 'InitMax', false ) then
      WindowState = wsMaximized
    else
      WindowState = wsNormal;}
  finally
    Ini.Free;
  end;
end;

function TGlobal.GetVersion : String;
var
  verblock:PVSFIXEDFILEINFO;
  versionMS,versionLS:cardinal;
  verlen:cardinal;
  rs:TResourceStream;
  m:TMemoryStream;
  p:pointer;
  s:cardinal;
  AppVersionString: String;
begin
  m:=TMemoryStream.Create;
  try
    rs:=TResourceStream.CreateFromID(HInstance,1,RT_VERSION);
    try
      m.CopyFrom(rs,rs.Size);
    finally
      rs.Free;
    end;
    m.Position:=0;
    if VerQueryValue(m.Memory,'\',pointer(verblock),verlen) then
      begin
        VersionMS:=verblock.dwFileVersionMS;
        VersionLS:=verblock.dwFileVersionLS;
        AppVersionString:={Application.Title+' '+}
          IntToStr(versionMS shr 16)+'.'+
          IntToStr(versionMS and $FFFF)+'.'+
          IntToStr(VersionLS shr 16)+'.'+
          IntToStr(VersionLS and $FFFF);
      end;
      {if VerQueryValue(m.Memory,PChar('\\StringFileInfo\\'+
        IntToHex(GetThreadLocale,4)+IntToHex(GetACP,4)+'\\FileDescription'),p,s) or
          VerQueryValue(m.Memory,'\\StringFileInfo\\040904E4\\FileDescription',p,s) then //en-us
            AppVersionString:=PChar(p)+' '+AppVersionString;}

    Result := AppVersionString;
  finally
    m.Free;
  end;
end;

function TGlobal.CaseString(Selector: string; CaseList: array of string) : Integer;
var
  cnt: integer;
begin
  Result:=-1;
  for cnt:=0 to Length(CaseList)-1 do begin
    if CompareText(Selector, CaseList[cnt]) = 0 then begin
      Result:=cnt;
      Break;
    end;
  end;
end;

procedure TGlobal.SaveSetting(name: string; value: Variant);
var
  temp : String;

begin
  //temp := Settings['defaultSite'];
end;

end.
