unit Unit2;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Global, Vcl.Imaging.pngimage;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    lblVersion: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    Label1: TLabel;
    btnOK: TBitBtn;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.dfm}

procedure TAboutBox.FormShow(Sender: TObject);
begin
  //Application.MessageBox(PWideChar('Application Version: '+AppVersion),'Notice',MB_OK Or MB_ICONINFORMATION);
  lblVersion.Caption := 'Version: '+AppVersion;
end;

end.

