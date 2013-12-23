unit FormUninstall;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, ExtCtrls,
  Internet, AutoUpdater, Registry, ComCtrls, jpeg, ComObj, ShlObj,
  FormSelectDirectoryInstall, XPMan;

type
   TFrmUninstall = class(TForm)
      LbWelcome: TLabel;
      PageControl1: TPageControl;
      TabSheet1: TTabSheet;
      TabSheet2: TTabSheet;
      MmReport: TMemo;
      LbInstall2: TLabel;
      LbFilename: TLabel;
      LbCurrentFile: TLabel;
      Timer: TTimer;
      LbProgress: TLabel;
      RbgUninstallOptions: TRadioGroup;
      Bevel1: TBevel;
      BtNextFinished: TButton;
      ImgDonate: TImage;
      LbDonate: TLabel;
      RbgDeleteOptions: TRadioGroup;
      RbgOtherOptions: TRadioGroup;
      CbDesktop: TCheckBox;
      RbDeleteAllFiles: TRadioButton;
      RbDeleteInstalledFiles: TRadioButton;
      CbDeleteIcons: TCheckBox;
    XPManifest: TXPManifest;
      procedure BtBrowseClick(Sender: TObject);
      procedure BtNextFinishedClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure ImgDonateClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure TimerTimer(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure MmReportChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      UninstallationCompleted, ForceInstall: boolean;
      InstallLocation: string;
      procedure Execute;
   end;

implementation

{$R *.dfm}
uses FormMain;

procedure TFrmUninstall.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if not UninstallationCompleted then
   begin
      if MessageDlg('Open Source SHP Builder Uninstallation' +#13#13+
        'Are you sure you want to cancel the uninstallation? If you do, click OK.',
        mtWarning,mbOKCancel,0) = mrOK then
      begin
         Close;
      end
      else
      begin
         Action := caNone;
      end;
   end;
end;

procedure TFrmUninstall.FormCreate(Sender: TObject);
begin
   UninstallationCompleted := false;
   ForceInstall := false;
end;

procedure TFrmUninstall.FormDestroy(Sender: TObject);
begin
   MMReport.Lines.Clear;
end;

procedure TFrmUninstall.FormShow(Sender: TObject);
begin
   MMReport.Visible := false;
   LbCurrentFile.Visible := false;
   LbFilename.Visible := false;
   TabSheet2.Visible := false;
   TabSheet2.Enabled := false;
   PageControl1.ActivePageIndex := 0;
   PageControl1.Pages[1].TabVisible := false;
end;

procedure TFrmUninstall.ImgDonateClick(Sender: TObject);
begin
   // Add link to Donation.
   FrmMain.OpenHyperlink('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X9AVHA3TJW584');
end;

procedure TFrmUninstall.MmReportChange(Sender: TObject);
begin
   MmReport.Perform(EM_LineScroll, 0, MmReport.Lines.Count);
   LbFilename.Refresh;
end;

procedure TFrmUninstall.BtBrowseClick(Sender: TObject);
var
   Form: TFrmSelectDirectoryInstall;
begin
   Form := TFrmSelectDirectoryInstall.Create(self);

   Form.ShowModal;
   if Form.OK then
   begin

   end;
   Form.Release;
end;

procedure TFrmUninstall.BtNextFinishedClick(Sender: TObject);
var
   ExecutableLocation: string;
begin
   if CompareStr(BtNextFinished.Caption,'Next') = 0 then
   begin
      // Tabsheet 1 UI
      CbDesktop.Enabled := false;
      // Rest
      BtNextFinished.Enabled := false;
      BtNextFinished.Caption := 'Finished';
      TabSheet2.Visible := true;
      TabSheet2.Enabled := true;
      PageControl1.Pages[1].TabVisible := true;
      PageControl1.ActivePageIndex := 1;
      MMReport.Visible := true;
      LbCurrentFile.Visible := true;
      LbFilename.Visible := true;
      Timer.Enabled := true;
   end
   else if CompareStr(BtNextFinished.Caption,'Finished') = 0 then
   begin
      if UninstallationCompleted then
      begin
         ExecutableLocation := InstallLocation + 'SHP_Builder.exe';
         if CompareStr(paramstr(0),ExecutableLocation) = 0 then
         begin
            Close;
         end
         else
         begin
            FrmMain.RunAProgram(ExecutableLocation,'',InstallLocation);
            Sleep(3000);
            Application.Terminate;
         end;
      end
      else
      begin
         ShowMessage('Attention: Unfortunately the OS SHP Builder installation has failed. Make sure you are connected to the internet and try again later.');
         Application.Terminate;
      end;
   end;
end;

procedure TFrmUninstall.Execute;
var
   Updater: TAutoUpdater;
   Reg: TRegistry;
   DesktopLocation,StartMenuLocation: string;
   IObject: IUnknown;
   ISLink: IShellLink;
   IPFile: IPersistFile;
   WFileName: WideString;
begin
   isMultiThread := true;
   Sleep(200);
   Updater := TAutoUpdater.Create(InstallLocation,MMReport,LbFilename,ForceInstall);
   if Updater.WaitFor > 0 then
   begin
      UninstallationCompleted := Updater.RepairDone;
   end;
   if UninstallationCompleted then
   begin
      // Uninstall shortcuts.
   end;
   Updater.Free;
   isMultiThread := false;
   BtNextFinished.Enabled := true;
end;

procedure TFrmUninstall.TimerTimer(Sender: TObject);
begin
   Timer.Enabled := false;
   Execute;
end;

end.
