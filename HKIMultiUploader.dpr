program HKIMultiUploader;

uses
  Forms,
  Unit1 in 'Unit1.pas' {formMain},
  Unit2 in 'Unit2.pas' {AboutBox},
  Unit3 in 'Unit3.pas' {formLogin},
  xmldownload in 'xmldownload.pas',
  gfxstuff in 'gfxstuff.pas',
  logform in 'logform.pas' {formLog},
  KUtil in 'KUtil.pas',
  Base64 in 'Base64.pas',
  Tools in 'Tools.pas',
  Site in 'Site.pas',
  Global in 'Global.pas',
  Unit4 in 'Unit4.pas' {formSettings};

{$R *.res}

begin
  {Initialize Application}
  G := TGlobal.Create;
  Application.Initialize;
  Application.Title := 'IPM MultiUploader';

  {Load Application Settings}
  G.LoadSettings;

  {Create All Forms}
  Application.CreateForm(TformMain, formMain);
  Application.CreateForm(TformLog, formLog);
  Application.CreateForm(TformSettings, formSettings);
  Application.CreateForm(TformLogin, formLogin);
  Application.CreateForm(TAboutBox, AboutBox);
  {Run the Application}
  Application.Run;
end.
