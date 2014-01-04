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
      PageControl: TPageControl;
      TabOptions: TTabSheet;
      TabProgress: TTabSheet;
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
      XPManifest: TXPManifest;
      GbxDeleteOptions: TGroupBox;
      RbDeleteAllFiles: TRadioButton;
      RbDeleteInstalledFiles: TRadioButton;
      GbxOtherOptions: TGroupBox;
      CbRegistry: TCheckBox;
      CbDeleteIcons: TCheckBox;
      procedure RbDeleteAllFilesClick(Sender: TObject);
      procedure BtNextFinishedClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure ImgDonateClick(Sender: TObject);
      procedure ImgDonateMouseEnter(Sender: TObject);
      procedure ImgDonateMouseLeave(Sender: TObject);
      procedure FormShow(Sender: TObject);
      procedure TimerTimer(Sender: TObject);
      procedure FormDestroy(Sender: TObject);
      procedure MmReportChange(Sender: TObject);
      procedure FormCreate(Sender: TObject);
   private
      { Private declarations }
      procedure DeleteDirectory(const _DirName: string);
      function DeleteInstalledFiles: boolean;
      function IsFileInUse(const _FileName: string): Boolean;
   public
      { Public declarations }
      UninstallationCompleted, ForceInstall: boolean;
      InstallLocation: string;
      procedure Execute;
   end;

implementation

{$R *.dfm}
uses FormMain, ShellAPI;

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
   TabProgress.Visible := false;
   TabProgress.Enabled := false;
   PageControl.ActivePageIndex := 0;
   PageControl.Pages[1].TabVisible := false;
end;

procedure TFrmUninstall.ImgDonateClick(Sender: TObject);
begin
   // Add link to Donation.
   FrmMain.OpenHyperlink('https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X9AVHA3TJW584');
end;

procedure TFrmUninstall.ImgDonateMouseEnter(Sender: TObject);
begin
   Screen.Cursor := crHandPoint;
end;

procedure TFrmUninstall.ImgDonateMouseLeave(Sender: TObject);
begin
   Screen.Cursor := crDefault;
end;

procedure TFrmUninstall.MmReportChange(Sender: TObject);
begin
   MmReport.Perform(EM_LineScroll, 0, MmReport.Lines.Count);
   LbFilename.Refresh;
end;

procedure TFrmUninstall.RbDeleteAllFilesClick(Sender: TObject);
begin
   (Sender as TRadioButton).Checked := true;
end;

procedure TFrmUninstall.BtNextFinishedClick(Sender: TObject);
var
   ExecutableLocation: string;
   F: System.Text;
   Buffer : Array[0..255] of Char;
begin
   if CompareStr(BtNextFinished.Caption,'Next') = 0 then
   begin
      // Tabsheet 1 UI
      CbRegistry.Enabled := false;
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
   end
   else if CompareStr(BtNextFinished.Caption,'Finished') = 0 then
   begin
      if UninstallationCompleted then
      begin
         // First we do the final bomb: a .bat file that either delete OS SHP
         // Builder executable alone or the whole directory... and itself.
         AssignFile(F, 'uninstall.bat');
         ReWrite(F);
         // Write ping to make it sleep and give time to OS SHP Builder to close.
         GetSystemDirectory(Buffer,255);
         WriteLn(F, IncludeTrailingBackSlash(StrPas(Buffer)) + 'ping 1.0.0.0 -n 1 -w 3000');
         // Delete the executable
         WriteLn(F, 'del SHP_Builder.exe');
         // Write dir deletion if necessary.
         if RbDeleteAllFiles.Checked then
         begin
            // Delete the whole directory.
            WriteLn(F, 'RD /S /Q "' + ExtractFileDir(ParamStr(0)) + '"');
         end;
         // self kill goes here if necessary.
         Writeln(F, 'del uninstall.bat');
         CloseFile(F);
         ShellExecute (0, 'open', pChar ('uninstall.bat'), pChar (''), pChar (ExtractFileDir(ParamStr(0))), SW_HIDE);
         Application.Terminate;
         Close;
      end;
   end;
end;

procedure TFrmUninstall.Execute;
var
   Reg: TRegistry;
   DesktopLocation,StartMenuLocation: string;
   IObject: IUnknown;
   ISLink: IShellLink;
   IPFile: IPersistFile;
   WFileName: WideString;
begin
   isMultiThread := true;
   Sleep(200);
   MMReport.Lines.Clear;
   if RbDeleteAllFiles.Checked then
   begin
      DeleteDirectory(ExtractFileDir(ParamStr(0)));
   end
   else
   begin
      DeleteInstalledFiles;
      if FileExists(ExtractFilePath(ParamStr(0)) + 'SHP_Builder.dat') then
         if DeleteFile(ExtractFilePath(ParamStr(0)) + 'SHP_Builder.dat') then
         begin
            MMReport.Lines.Add('SHP_Builder.dat has been deleted.');
         end
         else
         begin
            MMReport.Lines.Add('SHP_Builder.dat has been skipped.');
         end;
   end;

   if CBDeleteIcons.Checked then
   begin
      // Uninstall shortcuts.
      try
         Reg := TRegistry.Create;
         // Try deleting it for all users.
         Reg.RootKey := HKEY_LOCAL_MACHINE;
         if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', False) then
         begin
            // Delete start menu shortcuts
            StartMenuLocation := IncludeTrailingPathDelimiter(reg.ReadString('Programs'));
            if DirectoryExists(StartMenuLocation + 'CnC Tools\OS SHP Builder') then
               DeleteDirectory(StartMenuLocation + 'CnC Tools\OS SHP Builder\');
            MMReport.Lines.Add('OS SHP Builder start menu shortcuts from all users no longer exists.');
            DesktopLocation := IncludeTrailingPathDelimiter(reg.ReadString('Desktop'));
            // Delete desktop shortcut
            if FileExists(DesktopLocation +  'OS SHP Builder.lnk') then
               DeleteFile(DesktopLocation +  'OS SHP Builder.lnk');
            MMReport.Lines.Add('OS SHP Builder desktop icon from all users no longer exists.');
         end;
         // Try deleting it for current user.
         Reg.CloseKey;
         Reg.RootKey := HKEY_CURRENT_USER;
         if Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', False) then
         begin
            // Delete start menu shortcuts
            StartMenuLocation := IncludeTrailingPathDelimiter(reg.ReadString('Programs'));
            if DirectoryExists(StartMenuLocation + 'CnC Tools\OS SHP Builder') then
               DeleteDirectory(StartMenuLocation + 'CnC Tools\OS SHP Builder\');
            MMReport.Lines.Add('OS SHP Builder start menu shortcuts from current user no longer exists.');
            DesktopLocation := IncludeTrailingPathDelimiter(reg.ReadString('Desktop'));
            // Delete desktop shortcut
            if FileExists(DesktopLocation +  'OS SHP Builder.lnk') then
               DeleteFile(DesktopLocation +  'OS SHP Builder.lnk');
            MMReport.Lines.Add('OS SHP Builder desktop icon from current user no longer exists.');
         end;
         Reg.CloseKey;
      finally
         Reg.Free;
      end;
   end;
   if CbRegistry.Checked then
   begin
      // Remove registry entries and file association.
      try
         Reg := TRegistry.Create;
         Reg.RootKey := HKEY_LOCAL_MACHINE;
         if (Reg.KeyExists('Software\CnC Tools\OS SHP Builder\')) then
            Reg.DeleteKey('Software\CnC Tools\OS SHP Builder\');
         Reg.CloseKey;
         // Remove file association
         Reg.RootKey := HKEY_CLASSES_ROOT;
         if (Reg.KeyExists('.shp')) then
            Reg.DeleteKey('.shp');
         if Reg.KeyExists('\OS_SHP_BUILDER\') then
            Reg.DeleteKey('\OS_SHP_BUILDER\');
         Reg.CloseKey;
         Reg.RootKey := HKEY_CURRENT_USER;
         if Reg.KeyExists('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.shp\') then
            Reg.DeleteKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.shp\');
         Reg.CloseKey;
         MMReport.Lines.Add('OS SHP Builder registry content has been deleted.');
      finally
         Reg.Free;
      end;
   end;
   MMReport.Lines.Add('OS SHP Builder uninstallation procedure has been almost concluded. Click Finished to exit.');
   isMultiThread := false;
   BtNextFinished.Enabled := true;
   UninstallationCompleted := true;
end;

procedure TFrmUninstall.TimerTimer(Sender: TObject);
begin
   Timer.Enabled := false;
   Execute;
end;

procedure TFrmUninstall.DeleteDirectory(const _DirName: string);
var
   f: TSearchRec;
   path,Name: String;
begin
   if not DirectoryExists(IncludeTrailingPathDelimiter(_DirName)) then
      exit;

   Path := IncludeTrailingPathDelimiter(_DirName) + '*.*';
   // Delete all files.
   if FindFirst(path,faAnyFile + faHidden,f) = 0 then
   begin
      repeat
         Name := IncludeTrailingPathDelimiter(_DirName) + f.Name;
         if FileExists(Name) and (not IsFileInUse(Name)) then
         begin
            LbFilename.Caption := Name;
            if DeleteFile(Name) then
            begin
               MMReport.Lines.Add(Name + ' has been deleted.');
            end
            else
            begin
               MMReport.Lines.Add(Name + ' has been skipped.');
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
   // Delete all subdirectories.
   Path := IncludeTrailingPathDelimiter(_DirName) + '*';
   if FindFirst(path,faDirectory,f) = 0 then
   begin
      repeat
         if (CompareStr(f.Name,'.') <> 0) and (CompareStr(f.Name, '..') <> 0) and (CompareStr(f.Name, 'SHP_Builder.exe') <> 0) then
         begin
            Name := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(_DirName) + f.Name);
            if DirectoryExists(Name) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
            begin
               DeleteDirectory(Name);
               MMReport.Lines.Add(Name + ' has been cleaned.');
            end;
         end;
      until FindNext(f) <> 0;
   end;
   FindClose(f);
   try
      RmDir(_DirName);
   except
      // do nothing. Does it silence down the program on I/O error 32?
   end;
   if DirectoryExists(_DirName) then // It sounds unnecessary, but for some reason, it may catch some weird dirs sometimes.
   begin
      MMReport.Lines.Add(_DirName + ' has been skipped for now.');
   end
   else
   begin
      MMReport.Lines.Add(_DirName + ' has been cleaned.');
   end;
end;

function TFrmUninstall.DeleteInstalledFiles: boolean;
var
   FileStructureString : string;
   StructureFile: System.Text;
   StructureFilename,BaseDir,Filename: string;
   XMLDocument: IXMLDocument;
   Node: IXMLNode;
begin
   Result := false;
   // Grab file list
   MMReport.Lines.Clear;
   LbFilename.Caption := 'Loading File Structure';
   try
      FileStructureString := GetWebContent('http://shpbuilder.ppmsite.com/structure.xml');
   except
      ShowMessage('Warning: Internet Connection Failed. Try again later.');
      exit;
   end;
   if Length(FileStructureString) = 0 then
   begin
      exit;
   end;
   LbFilename.Caption := 'File Structure Downloaded';
   // Write XML file to disk
   BaseDir := ExtractFilePath(ParamStr(0));
   StructureFilename := BaseDir + 'structure.xml';
   AssignFile(StructureFile,StructureFilename);
   Rewrite(StructureFile);
   Write(StructureFile,FileStructureString);
   CloseFile(StructureFile);
   MMReport.Lines.Add('File structure data acquired. Starting procedure to install the program.');
   MMReport.Refresh;
   // Read XML file.
   CoInitialize(nil);
   XMLDocument := TXMLDocument.Create(nil);
   XMLDocument.Active := true;
   XMLDocument.LoadFromFile(StructureFilename);

   // File deletion for everyone! All hail!
   // check each item
   Node := XMLDocument.DocumentElement.ChildNodes.FindNode('file');
   repeat
      Filename := BaseDir + Node.Attributes['in'];
      LbFilename.Caption := Filename;
      if FileExists(Filename) then
      begin
         if DeleteFile(Filename) then
         begin
            MMReport.Lines.Add(Filename + ' has been deleted.');
         end
         else
         begin
            MMReport.Lines.Add(Filename + ' has been skipped.');
         end;
      end;
      Node := Node.NextSibling;
   until Node = nil;
   XMLDocument.Active := false;
   DeleteFile(StructureFilename);
   MMReport.Lines.Add('Uninstallation file deletion procedure has been finished.');
   MMReport.Refresh;
   Result := true;
end;

// copied from: http://stackoverflow.com/questions/16287983/why-do-i-get-i-o-error-32-even-though-the-file-isnt-open-in-any-other-program
function TFrmUninstall.IsFileInUse(const _FileName: string): Boolean;
var
   HFileRes: HFILE;
begin
   Result := False;
   if not FileExists(_FileName) then Exit;
   HFileRes := CreateFile(PChar(_FileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   Result := (HFileRes = INVALID_HANDLE_VALUE);
   if not Result then
      CloseHandle(HFileRes);
end;

end.
