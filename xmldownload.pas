unit xmldownload;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls,unit2, ExtCtrls, StdCtrls, xmldom, XMLIntf, msxmldom,
  XMLDoc, gfxstuff, Site, Global;

type
   TString = class(TObject)
   private
     fStr: String;
   public
     constructor Create(const AStr: String) ;
     property Str: String read FStr write FStr;
   end;

function DownloadURLFile(const ADPXMLBLOG, ADPLocalFile : TFileName) : boolean;

implementation

uses ExtActns;

constructor TString.Create(const AStr: String) ;
begin
  inherited Create;
  FStr := AStr;
end;

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

end.
 