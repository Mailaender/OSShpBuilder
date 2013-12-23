program SHP_Builder;


uses
  Windows,
  Messages,
  Forms,
  SysUtils,
  Dialogs,
  ShellAPI,
  FormMain in 'FormMain.pas' {SHPBuilderFrmMain},
  Shp_Engine in 'Shp_Engine.pas',
  Shp_File in 'Shp_File.pas',
  Palette in 'Palette.pas',
  FormAbout in 'FormAbout.pas' {FrmAbout},
  FormNew in 'FormNew.pas' {FrmNew},
  FormPreview in 'FormPreview.pas' {FrmPreview},
  FormReplaceColour in 'FormReplaceColour.pas' {frmReplaceColour},
  FormDarkenLightenTool in 'FormDarkenLightenTool.pas' {frmdarkenlightentool},
  FormPreferences in 'FormPreferences.pas' {FrmPreferences},
  FormAutoShadows in 'FormAutoShadows.pas' {FrmAutoShadows},
  FormResize in 'FormResize.pas' {FrmResize},
  Mouse in 'Mouse.pas',
  FormImportImageAsSHP in 'FormImportImageAsSHP.pas' {FrmImportImageAsSHP},
  FormSequence in 'FormSequence.pas' {FrmSequence},
  BS_Dialogs in 'BS_Dialogs.pas',
  Undo_Redo in 'Undo_Redo.pas',
  FormCameoGenerator in 'FormCameoGenerator.pas' {FrmCameoGenerator},
  PCXCtrl in 'PCXCtrl.pas',
  SHP_Colour_Bank in 'SHP_Colour_Bank.pas',
  SHP_Canvas in 'SHP_Canvas.pas',
  Colour_list in 'Colour_list.pas',
  SHP_Engine_CCMs in 'SHP_Engine_CCMs.pas',
  SHP_Engine_Resize in 'SHP_Engine_Resize.pas',
  SHP_Frame in 'SHP_Frame.pas',
  SHP_Shadows in 'SHP_Shadows.pas',
  SHP_Image_Save_Load in 'SHP_Image_Save_Load.pas',
  SHP_Image in 'SHP_Image.pas',
  SHP_Cameo in 'SHP_Cameo.pas',
  FormBatchConversion in 'FormBatchConversion.pas' {FrmBatchConversion},
  FormPalettePackAbout in 'FormPalettePackAbout.pas' {FrmPalettePackAbout},
  FormSHPImage in 'FormSHPImage.pas' {FrmSHPImage},
  FormPreferences_Anim in 'FormPreferences_Anim.pas' {FrmPreferences_Anim},
  SHP_DataMatrix in 'SHP_DataMatrix.pas',
  FormPaletteSelection in 'FormPaletteSelection.pas' {FrmPaletteSelection},
  OS_SHP_Tools in 'OS_SHP_Tools.pas',
  SHP_Sequence_Animation in 'SHP_Sequence_Animation.pas',
  FormCanvasResize in 'FormCanvasResize.pas' {FrmCanvasResize},
  CommunityLinks in 'CommunityLinks.pas',
  SHP_Image_Effects in 'SHP_Image_Effects.pas',
  Miscelaneous in 'Miscelaneous.pas',
  Tmp_File in 'Tmp_File.pas',
  FormRange in 'FormRange.pas' {FrmRange},
  SHP_ColourNumber_List in 'SHP_ColourNumber_List.pas',
  FormFrameSplitter in 'FormFrameSplitter.pas' {FrmFrameSplitter},
  SHP_RA_File in 'SHP_RA_File.pas',
  SHP_RA_Code in 'SHP_RA_Code.pas',
  gifimage in 'gifimage.pas',
  OSExtDlgs in 'OSExtDlgs.pas',
  FormGifOptions in 'FormGifOptions.pas' {FrmGifOptions},
  FormCopyFrames in 'FormCopyFrames.pas' {FrmCopyFrames},
  FormReverseFrames in 'FormReverseFrames.pas' {FrmReverseFrames},
  FormMoveFrames in 'FormMoveFrames.pas' {FrmMoveFrames},
  FormDeleteFrames in 'FormDeleteFrames.pas' {FrmDeleteFrames},
  FormQuickNewSHP in 'FormQuickNewSHP.pas' {FrmQuickNewSHP},
  FormSpriteSheetExport in 'FormSpriteSheetExport.pas' {FrmSpriteSheetExport},
  Shp_Engine_Image in 'Shp_Engine_Image.pas',
  ClassGIFCache in 'ClassGIFCache.pas',
  ClassGIFCacheManager in 'ClassGIFCacheManager.pas',
  FormExportFramesAsImage in 'FormExportFramesAsImage.pas' {FrmExportFramesAsImage},
  FormMirrorSHP in 'FormMirrorSHP.pas' {FrmMirrorSHP},
  FormInstall in 'FormInstall.pas' {FrmRepairAssistant},
  Internet in 'Internet.pas',
  AutoUpdater in 'AutoUpdater.pas',
  FormSelectDirectoryInstall in 'FormSelectDirectoryInstall.pas' {FrmSelectDirectoryInstall},
  FormUninstall in 'FormUninstall.pas' {FrmUninstall};

{$R *.res}
type
   PHWND = ^HWND;

// Note:
// Code copied and adapted from the book:
// Mastering Delphi 3 for Windows 95/NT
// from Cantú, Marco.
// Published by Makron Books and purchased by me (Banshee). R$105,00 (very expensive, but worth :P)

//---------------------------------------------
// checks if the window choosen by EnumWindows
// is another SHP Builder opened.
//---------------------------------------------
function EnumWndProc (Hwnd : THandle; FoundWnd : PHWND):Bool ; stdcall;
var
   ClassName, ModuleName, WinModuleName : string;
   WinInstance : THandle;
begin
   Result := true;
   SetLength(ClassName,100);
   GetClassName(Hwnd,PChar(ClassName),Length(ClassName));
   ClassName := PChar(ClassName);
   if ClassName = 'TSHPBuilderFrmMain' then
   begin
      SetLength(ModuleName,200);
      SetLength(WinModuleName,200);
      GetModuleFilename(HInstance,PChar(ModuleName),Length(ModuleName));
      ModuleName := PChar(ModuleName);
      WinInstance := GetWindowLong(hwnd,gwl_hInstance);
      GetModuleFilename(WinInstance,PChar(WinModuleName),Length(WinModuleName));
      WinModuleName := PChar(WinModuleName);
      If ModuleName = WinModuleName then
      begin
         FoundWnd^ := Hwnd;
         Result := false;
      end;
   end;
end;


//---------------------------------------------
// Main
//---------------------------------------------
var
   Hwnd : THandle;
   x : word;
   parameter_string : pchar;
   exeName : string;
   F: System.Text;
   cd: TCOPYDATASTRUCT;
begin
   // AutoUpdate directives start here.
   exeName := ExtractFileName(ParamStr(0));
   if CompareStr(exeName, 'SHP_BuilderUp.exe') = 0 then
   begin
      if not FileExists('update.bat') then
      begin
         // Build update.bat
         AssignFile(F, 'update.bat');
         ReWrite(F);
         if FileExists(ExtractFilePath(ParamStr(0)) + 'SHP_Builder.exe') then
            WriteLn(F, 'del SHP_Builder.exe');
         Writeln(F, 'ren SHP_BuilderUp.exe SHP_Builder.exe');
         Writeln(F, 'SHP_Builder.exe');
         Writeln(F, 'del update.bat');
         CloseFile(F);
         ShellExecute (0, 'open', pChar ('update.bat'), pChar (''), pChar (ExtractFileDir(ParamStr(0))), SW_HIDE);
      end;
      exit;
   end
   else
   begin
      if FileExists(ExtractFilePath(ParamStr(0)) + 'SHP_BuilderUp.exe') then
      begin
         ShellExecute (0, 'open', pChar (ExtractFilePath(ParamStr(0)) + 'SHP_BuilderUp.exe'), pChar (''), pChar (ExtractFileDir(ParamStr(0))), sw_ShowNormal);
         exit;
      end;
      if FileExists(ExtractFilePath(ParamStr(0)) + 'update.bat') then
      begin
         DeleteFile(ExtractFilePath(ParamStr(0)) + 'update.bat');
      end;
   end;

   // Reset Handler
   Hwnd := 0;
   // Check if there is another SHP Builder opened
   EnumWindows(@EnumWndProc,Longint(@Hwnd));

   // First Instance
   if Hwnd = 0 then
   begin
      Application.Initialize;
      Application.Title := 'SHP Builder';
      Application.CreateForm(TSHPBuilderFrmMain, FrmMain);
      Application.Run;
   end
   // Instance already exists.
   else 
   begin
      parameter_string := '';
      // extract current parameters
      if ParamCount > 0 then
         for x := 1 to ParamCount do
         begin
            if parameter_string = '' then
               parameter_string := pchar(ParamStr(x))
            else
               parameter_string := pchar(parameter_string + ' ' + ParamStr(x));
         end;
      if ParamCount = 1 then
      begin
         if CompareStr(ParamStr(1),'-multiview') = 0 then
         begin
            Application.Initialize;
            Application.Title := 'SHP Builder';
            Application.CreateForm(TSHPBuilderFrmMain, FrmMain);
            Application.Run;
         end
         else
         begin
           // Send size of string (parameter)
{           PostMessage(Hwnd,wm_User+19,Length(parameter_string),-1);
           // Send the string (char by char)
            for x := 0 to Length(parameter_string) do          }

            cd.dwData:= 12345234;
            cd.cbData:= length(parameter_string)+1;
            cd.lpData:= parameter_string;
//  showmessage(inttostr(HWND));
            SendMessage(Hwnd,wm_copydata,3,integer(@cd));

           {

            SendMessage(HWND_BROADCAST, WM_OURMESSAGE, pchar(parameter_string), integer(p));
            PostMessage(Hwnd,wm_copydata,Integer(pchar(parameter_string)),Length(parameter_string));}
            // Set the other shp builder as active window
            SetForegroundWindow(Hwnd);

         end;
      end
      else
      begin
         cd.dwData:= 12345234;
         cd.cbData:= length(parameter_string)+1;
         cd.lpData:= parameter_string;

         SendMessage(Hwnd,wm_copydata,3,integer(@cd));
         SetForegroundWindow(Hwnd);
      end;
      {Application.Initialize;
      Application.Run;     }
   end;
end.
