unit FormBatchConversion;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ImgList, ComCtrls, ExtDlgs, shp_file,shp_engine,palette,
  Shp_Engine_Image, SHP_FRAME, Shp_image_save_load, SHP_DataMatrix, math,
  OSExtDlgs, SHP_RA_File, FormGifOptions, SHP_Image, XPMan;

type
  TFrmBatchConversion = class(TForm)
    Filelist: TListView;
    FileImages: TImageList;
    Label3: TLabel;
    Bevel1: TBevel;
    OpenPictureDialog: TOpenPictureDialog;
    OpenSHPDialog: TOpenDialog;
    BtAddImage: TButton;
    BtAddSHP: TButton;
    BtDeleteFile: TButton;
    BatchOutputDirectory: TEdit;
    BtBrowseOutput: TButton;
    BtCancel: TButton;
    BtOK: TButton;
    Label1: TLabel;
    imageext: TComboBox;
    Label2: TLabel;
    ProgressBar1: TProgressBar;
    XPManifest: TXPManifest;
    procedure BtCancelClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure BtBrowseOutputClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtAddImageClick(Sender: TObject);
    procedure BtDeleteFileClick(Sender: TObject);
    procedure FilelistSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure BtAddSHPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    FileItemList : Array of tlistitem;
    FileItemList_no : integer;
    SHP : TSHP;
    procedure ProcessSHP(f,ext : string);
    procedure ProcessGIF(f,ext : string);
    procedure ProcessOthers(f,ext : string);
  end;

implementation

uses FormSelectDirectory, FormMain;

{$R *.dfm}

procedure TFrmBatchConversion.BtCancelClick(Sender: TObject);
begin
   close;
end;

procedure TFrmBatchConversion.ProcessOthers(f,ext : string);
var
   Bitmap : TBitmap;
begin
   Bitmap := TBitmap.Create;

   Bitmap.Free;
end;

procedure TFrmBatchConversion.ProcessGIF(f,ext : string);
var
   Bitmap : TBitmap;
   filename,dir{,ext},temp : string;
   x,Max : integer;
begin
   Bitmap := TBitmap.Create;

   dir := BatchOutputDirectory.Text;
   filename := copy(extractfilename(F),0,length(extractfilename(F))-length(ExtractFileExt(F)));
   //ext := extractfileext(F);

   if not (copy(dir,length(dir),1) = '\') then
      filename := '\' + filename + ' ';

   if CompareStr(ext,'.gif') <> 0 then
   begin
      Max := GetNumberOfFramesFromGif(F);
      for x := 1 to Max do
      begin
         Bitmap := GetBMPFromImageFile(F,x);

         temp := inttostr(x-1);
         if length(temp) < 4 then
            repeat
               temp := '0' + temp;
            until length(temp) = 4;
         SaveImageFileFromBMP(dir+filename+temp+ext,Bitmap);
      end;
   end;
   Bitmap.Free;
end;

procedure TFrmBatchConversion.ProcessSHP(f,ext : string);
var
   Bitmap : TBitmap;
   x,FrameLength : integer;
   filename,dir{,ext},temp : string;
   IsValid : boolean;
   SHPTD : C_SHPTD;
   BmpArray : array of TBitmap;
   FrmGifOptions : TFrmGifOptions;
   ColourPalette : TPalette;
begin
   Bitmap := TBitmap.Create;

   // 3.35: SHP (TD) support.
   try
      IsValid := LoadSHP(F,SHP); // Load the shp (TS)
   except
      exit;
   end;
   if not IsValid then
   begin // try SHP (TD)
      SHPTD := C_SHPTD.Create;
      try
         SHPTD.Load(F);
      except
         ShowMessage('Warning: ' + f + ' is an invalid SHP file for OS SHP Builder');
         exit;
      end;
      if SHPTD.IsValid then
      begin
         SHP := SHPTD.getSHP;
      end
      else
         exit;
      SHPTD.Free;
   end
   else
      CreateFrameImages(SHP); // Create frame images out of the databuffer

   dir := BatchOutputDirectory.Text;
   filename := copy(extractfilename(F),0,length(extractfilename(F))-length(ExtractFileExt(F)));
   //ext := extractfileext(F);

   if not (copy(dir,length(dir),1) = '\') then
      filename := '\' + filename + ' ';

   // 3.35: Now, let's switch here for GIF support.
   if CompareStr(ext,'.gif') = 0 then
   begin // Copy and Paste from Export code of Form Main
      FrmGifOptions := TFrmGifOptions.Create(self);
      FrmGifOptions.ShowModal;
      if FrmGifOptions.Changed then
      begin
         // Get memory for the bitmap array.
         SetLength(BmpArray,SHP.Header.NumImages);
         // Get ammount of frames and build bitmap array
         GetPaletteForGif(MainData^.SHPPalette,ColourPalette);
         FrameLength := CreateBmpArray(BmpArray,SHP,FrmGifOptions.Shadows.ItemIndex,False,0,0,MainData^.Shadow_Match,ColourPalette,FrmGifOptions.Zoom_Factor.Value);
         // Update bitmap array size
         SetLength(BmpArray,FrameLength);
         // Now, save the stuff
         SaveBMPToGIFImageFile(BmpArray,dir + filename + ext,FrmGifOptions.LoopType.ItemIndex = 1,FrmGifOptions.CbUseTransparency.Checked,ColourPalette);
         // Finally, get rid of the stuff.
         for x := Low(BmpArray) to High(BmpArray) do
         begin
            BmpArray[x].Free;
         end;
      end
      else
      begin
         FrmGifOptions.Release;
         exit;
      end;
      FrmGifOptions.Release;
   end
   else
   begin
      for x := 1 to SHP.Header.NumImages do
      begin
         Bitmap := GetBMPOfFrameImage(SHP,X,MainData^.SHPPalette);

         temp := inttostr(x-1);
         if length(temp) < 4 then
            repeat
               temp := '0' + temp;
            until length(temp) = 4;
         SaveImageFileFromBMP(dir+filename+temp+ext,Bitmap);
      end;
   end;

   Bitmap.Free;
end;

procedure TFrmBatchConversion.BtOKClick(Sender: TObject);
var
   x : integer;
begin
   // Set Progress Bar
   ProgressBar1.Max := max(Filelist.Items.Count-1,0);
   ProgressBar1.Position := 0;

   // Make destination dir if it doesn't exist!
   //MkDir(BatchOutputDirectory.Text); // causes error when dir exists....

   // Go through each file and apply the approperate process
   for x := 0 to Filelist.Items.Count - 1 do
   begin
      // show progress
      ProgressBar1.Position := x;
      label2.Caption := 'Progress - File ' + inttostr(x+1) + ' of ' + inttostr(Filelist.Items.Count);
      label2.Refresh;
      ProgressBar1.Refresh;

      // If its a shp then apply the process to make it into images!
      if ansilowercase(extractfileext(Filelist.Items.Item[x].SubItems.Strings[0])) = '.shp' then
         ProcessSHP(Filelist.Items.Item[x].SubItems.Strings[0],imageext.Items.Strings[imageext.itemindex]);
      if ansilowercase(extractfileext(Filelist.Items.Item[x].SubItems.Strings[0])) = '.gif' then
         ProcessGIF(Filelist.Items.Item[x].SubItems.Strings[0],imageext.Items.Strings[imageext.itemindex]);
   end;

   label2.Caption := 'Progress';
   Messagebox(0,'Mission Accomplished!','Batch Tool',0);

   close;
end;

procedure TFrmBatchConversion.BtBrowseOutputClick(Sender: TObject);
begin
   FrmSelectDirectory.ShellTreeView1.Path := BatchOutputDirectory.Text;
   FrmSelectDirectory.ShowModal;
   BatchOutputDirectory.Text := FrmSelectDirectory.ShellTreeView1.Path;
end;

procedure TFrmBatchConversion.FormShow(Sender: TObject);
begin
   if BatchOutputDirectory.Text = '' then
      BatchOutputDirectory.Text := extractfiledir(ParamStr(0)); // Update Path

   Filelist.Clear;
   FileItemList_no := 0;
   setlength(FileItemList,0);

   ProgressBar1.Position := 0;
end;

procedure TFrmBatchConversion.BtAddImageClick(Sender: TObject);
var
   x : integer;
begin
   //if Conversion_type.ItemIndex = 0 then
   if OpenPictureDialog.Execute then
   begin
      inc(FileItemList_no);
      setlength(FileItemList,FileItemList_no+1);

      if OpenPictureDialog.Files.Count = 1 then
      begin
         FileItemList[FileItemList_no] := TListItem.Create(Filelist.Items);
         Filelist.items.AddItem(FileItemList[FileItemList_no]);
         Filelist.items.Item[Filelist.Items.Count-1].Caption := extractfilename(OpenPictureDialog.FileName);
         Filelist.items.Item[Filelist.Items.Count-1].SubItems.Add(OpenPictureDialog.FileName);

         if ansilowercase(ExtractFileExt(OpenPictureDialog.FileName)) = '.bmp' then
            Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 1
         else if ansilowercase(ExtractFileExt(OpenPictureDialog.FileName)) = '.pcx' then
            Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 2
         else if (ansilowercase(ExtractFileExt(OpenPictureDialog.FileName)) = '.jpg') or (ansilowercase(ExtractFileExt(OpenPictureDialog.FileName)) = '.jpeg') then
            Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 3
         else
            Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 0;
      end
      else if OpenPictureDialog.Files.Count > 0 then
         for x := 0 to OpenPictureDialog.Files.Count-1 do
         begin
            FileItemList[FileItemList_no] := TListItem.Create(Filelist.Items);
            Filelist.items.AddItem(FileItemList[FileItemList_no]);
            Filelist.items.Item[Filelist.Items.Count-1].Caption := extractfilename(OpenPictureDialog.Files.Strings[x]);
            Filelist.items.Item[Filelist.Items.Count-1].SubItems.Add(OpenPictureDialog.Files.Strings[x]);

            if ansilowercase(ExtractFileExt(OpenPictureDialog.Files.Strings[x])) = '.bmp' then
               Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 1
            else if ansilowercase(ExtractFileExt(OpenPictureDialog.Files.Strings[x])) = '.pcx' then
               Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 2
            else if (ansilowercase(ExtractFileExt(OpenPictureDialog.Files.Strings[x])) = '.jpg') or (ansilowercase(ExtractFileExt(OpenPictureDialog.Files.Strings[x])) = '.jpeg') then
               Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 3
            else
               Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 0;
         end;

   end;
end;

procedure TFrmBatchConversion.BtDeleteFileClick(Sender: TObject);
begin
   if Filelist.SelCount < 1 then exit;
   Filelist.DeleteSelected;
end;

procedure TFrmBatchConversion.FilelistSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
   BtDeleteFile.Enabled := selected;
end;

procedure TFrmBatchConversion.BtAddSHPClick(Sender: TObject);
var
   x : integer;
begin
   if OpenSHPDialog.Execute then
   begin
      inc(FileItemList_no);
      setlength(FileItemList,FileItemList_no+1);

      if OpenSHPDialog.Files.Count = 1 then
      begin
         FileItemList[FileItemList_no] := TListItem.Create(Filelist.Items);
         Filelist.items.AddItem(FileItemList[FileItemList_no]);
         Filelist.items.Item[Filelist.Items.Count-1].Caption := extractfilename(OpenSHPDialog.FileName);
         Filelist.items.Item[Filelist.Items.Count-1].SubItems.Add(OpenSHPDialog.FileName);

         Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 4;
      end
      else if OpenSHPDialog.Files.Count > 0 then
         for x := 0 to OpenSHPDialog.Files.Count-1 do
         begin
            FileItemList[FileItemList_no] := TListItem.Create(Filelist.Items);
            Filelist.items.AddItem(FileItemList[FileItemList_no]);
            Filelist.items.Item[Filelist.Items.Count-1].Caption := extractfilename(OpenSHPDialog.Files.Strings[x]);
            Filelist.items.Item[Filelist.Items.Count-1].SubItems.Add(OpenSHPDialog.Files.Strings[x]);
            Filelist.items.Item[Filelist.Items.Count-1].ImageIndex := 4;
         end;
   end;
end;

procedure TFrmBatchConversion.FormCreate(Sender: TObject);
begin
   imageext.ItemIndex := 0;
end;

end.
