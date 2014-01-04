unit FormInstall;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, xmldom, XMLIntf, msxmldom, XMLDoc, ActiveX, ExtCtrls,
  Internet, AutoUpdater, Registry, ComCtrls, jpeg, ComObj, ShlObj,
  FormSelectDirectoryInstall, XPMan;

type
   TFrmRepairAssistant = class(TForm)
      LbWelcome: TLabel;
      PageControl: TPageControl;
      TabOptions: TTabSheet;
      TabProgress: TTabSheet;
      MmReport: TMemo;
      LbInstall1: TLabel;
      EdInstallLocation: TEdit;
      BtBrowse: TButton;
      LbInstall2: TLabel;
      LbSVNPPMLink: TLabel;
      LbFilename: TLabel;
      LbCurrentFile: TLabel;
      Timer: TTimer;
      LbProgress: TLabel;
      Bevel1: TBevel;
      BtNextFinished: TButton;
      ImgDonate: TImage;
      LbDonate: TLabel;
      XPManifest: TXPManifest;
      GbxOtherOptions: TGroupBox;
      CbOverrideFiles: TCheckBox;
      GbXInstallationType: TGroupBox;
      CbAllUsers: TCheckBox;
      CbDesktop: TCheckBox;
      RbStartMenu: TRadioButton;
      RbPortable: TRadioButton;
      procedure ImgDonateMouseLeave(Sender: TObject);
      procedure ImgDonateMouseEnter(Sender: TObject);
      procedure BtBrowseClick(Sender: TObject);
      procedure EdInstallLocationChange(Sender: TObject);
      procedure RbStartMenuClick(Sender: TObject);
      procedure RbPortableClick(Sender: TObject);
      procedure BtNextFinishedClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure ImgDonateClick(Sender: TObject);
      procedure LbSVNPPMLinkClick(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure TimerTimer(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure MmReportChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
   public
      { Public declarations }
      InstallationCompleted, ForceInstall, ForceClose, IsUpdating: boolean;
      InstallLocation, ProgramFilesLocation: string;
      function RequestAuthorization(const _Filename: string): boolean;
      procedure SetAutoUpdateMode;
      procedure Execute;
   end;

implementation

{$R *.dfm}
uses FormMain;

procedure TFrmRepairAssistant.FormClose(Sender: TObject; var Action: TCloseAction);
var
   MyName,MyAction: string;
begin
   if not IsUpdating then
   begin
      MyName := 'Installation';
      MyAction := 'installation';
   end
   else
   begin
      MyName := 'Updater';
      MyAction := 'update';
   end;

   if not InstallationCompleted then
   begin
      if MessageDlg('Open Source SHP Builder ' + MyName + #13#13 +
         'Are you sure you want to cancel the ' + MyAction + '? If you do, click OK.',
         mtWarning,mbOKCancel,0) = mrOK then
      begin
         Application.Terminate;
      end
      else
      begin
         Action := caNone;
      end;
   end;
   if ForceClose then
   begin
      Application.Terminate;
   end;
end;

procedure TFrmRepairAssistant.FormCreate(Sender: TObject);
begin
   IsUpdating := false;
   InstallationCompleted := false;
   ForceInstall := false;
end;

procedure TFrmRepairAssistant.FormDestroy(Sender: TObject);
begin
   MMReport.Lines.Clear;
end;

procedure TFrmRepairAssistant.FormShow(Sender: TObject);
var
   Reg: TRegistry;
begin
   if not IsUpdating then
   begin
      ProgramFilesLocation := '';
      try
         Reg := TRegistry.Create;
         Reg.RootKey := HKEY_LOCAL_MACHINE;
         if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion', False) then
         begin
            ProgramFilesLocation := IncludeTrailingPathDelimiter(reg.ReadString('ProgramFilesDir'));
            EdInstallLocation.Text := ProgramFilesLocation + 'CnCTools\OS SHP Builder';
         end
         else
         begin
            EdInstallLocation.Text := IncludeTrailingPathDelimiter(ExtractFileDir(paramstr(0))) + 'CnCTools\OS SHP Builder';
         end;
      finally
         Reg.Free;
      end;
      if Length(EdInstallLocation.Text) = 0 then
      begin
         EdInstallLocation.Text := IncludeTrailingPathDelimiter(ExtractFileDir(paramstr(0))) + 'CnCTools\OS SHP Builder';
      end;
   end;
   MMReport.Visible := false;
   LbCurrentFile.Visible := false;
   LbFilename.Visible := false;
   TabProgress.Visible := false;
   TabProgress.Enabled := false;
   PageControl.ActivePageIndex := 0;
   PageControl.Pages[1].TabVisible := false;
end;

procedure TFrmRepairAssistant.ImgDonateClick(Sender: TObject);
begin
   // Add link to Donation.
   FrmMain.OpenHyperlink('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X9AVHA3TJW584');
end;

procedure TFrmRepairAssistant.ImgDonateMouseEnter(Sender: TObject);
begin
   Screen.Cursor := crHandPoint;
end;

procedure TFrmRepairAssistant.ImgDonateMouseLeave(Sender: TObject);
begin
   Screen.Cursor := crDefault;
end;

procedure TFrmRepairAssistant.LbSVNPPMLinkClick(Sender: TObject);
begin
   // Add link to PPM SVN here.
   FrmMain.OpenHyperlink('http://svn.ppmsite.com/listing.php?repname=OS+SHP+Builder');
end;

procedure TFrmRepairAssistant.MmReportChange(Sender: TObject);
begin
   MmReport.Perform(EM_LineScroll, 0, MmReport.Lines.Count);
   LbFilename.Refresh;
end;

procedure TFrmRepairAssistant.BtBrowseClick(Sender: TObject);
var
   Form: TFrmSelectDirectoryInstall;
begin
   Form := TFrmSelectDirectoryInstall.Create(self);
   if DirectoryExists(EdInstallLocation.Text) then
   begin
      Form.Directory.Directory := EdInstallLocation.Text;
   end;

   Form.ShowModal;
   if Form.OK then
   begin
      EdInstallLocation.Text := Form.SelectedDir;

      if Length(ProgramFilesLocation) > 0 then
      begin
         if (SysUtils.Win32MajorVersion >= 6) and (AnsiPos(ProgramFilesLocation,EdInstallLocation.Text) > 0) then
         begin
            ShowMessage('Warning: make sure this program is running as administrator in order to be installed in ProgramFiles on Windows Vista or higher or just change the destination.');
         end;
      end;
   end;
   Form.Release;
end;

procedure TFrmRepairAssistant.BtNextFinishedClick(Sender: TObject);
var
   ExecutableLocation: string;
begin
   if CompareStr(BtNextFinished.Caption,'Next') = 0 then
   begin
      InstallLocation := IncludeTrailingPathDelimiter(EdInstallLocation.Text);

      if not ForceDirectories(InstallLocation) then
      begin
         ShowMessage('Error! The directory ' + InstallLocation + ' could not be created. Change the destination directory or re-run the program with admin priviledges. Sorry for any inconvenience.');
      end
      else
      begin
         // Tabsheet 1 UI
         BtBrowse.Enabled := false;
         EdInstallLocation.Enabled := false;
         RbStartMenu.Enabled := false;
         RbPortable.Enabled := false;
         CbAllUsers.Enabled := false;
         CbDesktop.Enabled := false;
         CbOverrideFiles.Enabled := false;
         // Rest
         BtNextFinished.Enabled := false;
         BtNextFinished.Caption := 'Finished';
         TabProgress.Visible := true;
         TabProgress.Enabled := true;
         PageControl.Pages[1].TabVisible := true;
         PageControl.ActivePageIndex := 1;
         MMReport.Visible := true;
         LbCurrentFile.Visible := true;
         LbFilename.Visible := true;
         Timer.Enabled := true;
         // Important variables
         ForceInstall := CbOverrideFiles.Checked;
      end;
   end
   else if CompareStr(BtNextFinished.Caption,'Finished') = 0 then
   begin
      if InstallationCompleted then
      begin
         if IsUpdating then
         begin
            if MessageDlg('Open Source SHP Builder Updater' + #13#13 +
               'You will need to restart the program to use the latest version. If you agree with it, click OK and you will loose all unsaved documents.',
               mtWarning,mbOKCancel,0) = mrOK then
            begin
               ExecutableLocation := ExtractFilePath(ParamStr(0)) + 'SHP_BuilderUp.exe';
               FrmMain.RunAProgram(ExecutableLocation,'-multiview',InstallLocation);
               ForceClose := true;
               Close;
               Application.Terminate;
            end
            else
            begin
               Close;
            end;
         end
         else
         begin
            ExecutableLocation := InstallLocation + 'SHP_Builder.exe';
            if (not FileExists(InstallLocation + 'SHP_BuilderUp.exe')) and (CompareStr(paramstr(0),ExecutableLocation) = 0) then
            begin
               Close;
            end
            else
            begin
               FrmMain.RunAProgram(ExecutableLocation,'-multiview',InstallLocation);
               //FrmMain.Free;
               ForceClose := true;
               Close;
               Application.Terminate;
            end;
         end;
      end
      else
      begin
         if not IsUpdating then
         begin
            ShowMessage('Attention: Unfortunately the OS SHP Builder installation has failed. Make sure you are connected to the internet and try again later.');
         end
         else
         begin
            ShowMessage('Attention: Unfortunately the OS SHP Builder update has failed. Make sure you are connected to the internet and try again later.');
         end;
         ForceClose := true;
         Close;
         Application.Terminate;
      end;
   end;
end;

procedure TFrmRepairAssistant.EdInstallLocationChange(Sender: TObject);
begin
   if EdInstallLocation.Text = '' then
   begin
      BtNextFinished.Enabled := false;
   end
   else
   begin
      BtNextFinished.Enabled := true;
   end;
end;

procedure TFrmRepairAssistant.Execute;
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
      InstallationCompleted := Updater.RepairDone;
   end;
   if InstallationCompleted then
   begin
      // Install shortcuts.
      if RbStartMenu.Checked then
      begin
         try
            Reg := TRegistry.Create;
            if CbAllUsers.Checked then
            begin
               Reg.RootKey := HKEY_LOCAL_MACHINE;
            end
            else
            begin
               Reg.RootKey := HKEY_CURRENT_USER;
            end;
            if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', False) then
            begin
               StartMenuLocation := IncludeTrailingPathDelimiter(reg.ReadString('Programs'));
               ForceDirectories(StartMenuLocation + 'CnC Tools\OS SHP Builder\');
               // Create executable link
               IObject := CreateComObject(CLSID_ShellLink) ;
               ISLink := IObject as IShellLink;
               IPFile := IObject as IPersistFile;
               ISLink.SetPath(PChar(InstallLocation + 'SHP_Builder.exe'));
               ISLink.SetWorkingDirectory(PChar(InstallLocation));
               WFilename := StartMenuLocation + 'CnC Tools\OS SHP Builder\OS SHP Builder.lnk';
               if IPFile.Save(PWChar(WFilename), False) = S_OK then
               begin
                  Updater.WriteString('OS SHP Builder executable link has been created at the Start Menu.');
               end
               else
               begin
                  Updater.WriteString('OS SHP Builder executable link was not created at the Start Menu.');
               end;
               // Create Help
               IObject := CreateComObject(CLSID_ShellLink) ;
               ISLink := IObject as IShellLink;
               IPFile := IObject as IPersistFile;
               ISLink.SetPath(PChar(InstallLocation + 'os_shp_builder_help.chm'));
               ISLink.SetWorkingDirectory(PChar(InstallLocation));
               WFileName := StartMenuLocation + 'CnC Tools\OS SHP Builder\OS SHP Builder Help.lnk';
               if IPFile.Save(PWChar(WFilename), False) = S_OK then
               begin
                  Updater.WriteString('OS SHP Builder help link has been created at the Start Menu.');
               end
               else
               begin
                  Updater.WriteString('OS SHP Builder help link was not created at the Start Menu.');
               end;
               // Create ReadMe
               IObject := CreateComObject(CLSID_ShellLink) ;
               ISLink := IObject as IShellLink;
               IPFile := IObject as IPersistFile;
               ISLink.SetPath(PChar(InstallLocation + 'Docs\SHPBuilderReadme.rtf'));
               ISLink.SetWorkingDirectory(PChar(InstallLocation + 'Docs\'));
               ForceDirectories(StartMenuLocation + 'CnC Tools\');
               WFileName := StartMenuLocation + 'CnC Tools\OS SHP Builder\OS SHP Builder ReadMe.lnk';
               if IPFile.Save(PWChar(WFileName), False) = S_OK then
               begin
                  Updater.WriteString('OS SHP Builder read me link has been created at the Start Menu.');
               end
               else
               begin
                  Updater.WriteString('OS SHP Builder read me link was not created at the Start Menu.');
               end;
               // Create Uninstall program link.
               StartMenuLocation := IncludeTrailingPathDelimiter(reg.ReadString('Programs'));
               ForceDirectories(StartMenuLocation + 'CnC Tools\OS SHP Builder\');
               IObject := CreateComObject(CLSID_ShellLink) ;
               ISLink := IObject as IShellLink;
               IPFile := IObject as IPersistFile;
               ISLink.SetPath(PChar('"' + InstallLocation + 'SHP_Builder.exe" -uninstall'));
               ISLink.SetWorkingDirectory(PChar(InstallLocation));
               WFilename := StartMenuLocation + 'CnC Tools\OS SHP Builder\Uninstall OS SHP Builder.lnk';
               if IPFile.Save(PWChar(WFilename), False) = S_OK then
               begin
                  Updater.WriteString('OS SHP Builder uninstall link has been created at the Start Menu.');
               end
               else
               begin
                  Updater.WriteString('OS SHP Builder uninstall link was not created at the Start Menu.');
               end;
               if CbDesktop.Checked then
               begin
                  // Create Desktop executable link
                  DesktopLocation := IncludeTrailingPathDelimiter(reg.ReadString('Desktop'));
                  IObject := CreateComObject(CLSID_ShellLink) ;
                  ISLink := IObject as IShellLink;
                  IPFile := IObject as IPersistFile;
                  ISLink.SetPath(PChar(InstallLocation + 'SHP_Builder.exe'));
                  ISLink.SetWorkingDirectory(PChar(InstallLocation));
                  WFilename := DesktopLocation + 'OS SHP Builder.lnk';
                  if IPFile.Save(PWChar(WFilename), False) = S_OK then
                  begin
                     Updater.WriteString('OS SHP Builder executable link has ben created at the Desktop.');
                  end
                  else
                  begin
                     Updater.WriteString('OS SHP Builder executable link was not created at the Desktop.');
                  end;
               end;
            end;
         finally
            Reg.Free;
         end;
      end;
   end;
   Updater.Free;
   isMultiThread := false;
   Timer.Enabled := false;
   BtNextFinished.Enabled := true;
end;

procedure TFrmRepairAssistant.RbPortableClick(Sender: TObject);
begin
   RbStartMenu.Checked := false;
   RbPortable.Checked := true;
   CbDesktop.Checked := false;
   CbAllUsers.Checked := false;
   CbDesktop.Enabled := false;
   CbAllUsers.Enabled := false;
end;

procedure TFrmRepairAssistant.RbStartMenuClick(Sender: TObject);
begin
   RbStartMenu.Checked := true;
   RbPortable.Checked := false;
   CbDesktop.Enabled := true;
   CbAllUsers.Enabled := true;
end;

function TFrmRepairAssistant.RequestAuthorization(const _Filename: string): boolean;
begin
   if MessageDlg('Open Source SHP Builder Installation' +#13#13+
        'The program has detected that the required file below is missing:' + #13+#13 +
        _Filename + #13+#13 +
        'The Open Source SHP Builder Repair Assistant is able to retrieve this ' + #13 +
        'and required other files from the internet automatically. In order to run it, ' + #13 +
        'make sure you are online and click OK. If you refuse to run it, click Cancel.',
        mtWarning,mbOKCancel,0) = mrCancel then
        begin
           ForceClose := true;
           Application.Terminate;
        end;
   Result := true;
end;

procedure TFrmRepairAssistant.TimerTimer(Sender: TObject);
begin
   Timer.Enabled := false;
   Execute;
end;

procedure TFrmRepairAssistant.SetAutoUpdateMode;
begin
   IsUpdating := true;
   Caption := 'Open Source SHP Builder Online Update Wizard';
   LbWelcome.Caption := 'Welcome to the Open Source SHP Builder Update Wizard.';
   LbInstall1.Visible := false;
   EdINstallLocation.Visible := false;
   EdInstallLocation.Text := IncludeTrailingPathDelimiter(ExtractFileDir(paramstr(0)));
   BtBrowse.Visible := false;
   GbxInstallationType.Visible := false;
   RbStartMenu.Checked := false;
   RbPortable.Checked := true;
   CbDesktop.Checked := false;
   CbAllUsers.Checked := false;
   GbxOtherOptions.Visible := false;
   CbOverrideFiles.Checked := true;
   LbProgress.Caption := 'Open Source SHP Builder is being updated. Please, wait while the files are being downloaded:';
end;

end.
