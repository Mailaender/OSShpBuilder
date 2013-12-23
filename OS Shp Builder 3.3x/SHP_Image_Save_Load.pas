unit SHP_Image_Save_Load;

interface

uses
   Graphics, Jpeg, PCXCtrl, SysUtils, GifImage, PNGImage, TARGA, Dialogs, SHP_File,
   Palette, ClassGIFCacheManager, ClassGIFCache;

function GetBMPFromImageFile(filename: string): TBitmap; overload;
function GetBMPFromImageFile(filename: string; Frame: integer): TBitmap; overload;
function SaveImageFileFromBMP(filename: string; Bmp: TBitmap): boolean;
function GetBMPFromJPGImageFile(filename: string): TBitmap;
function GetBMPFromPCXImageFile(filename: string): TBitmap;
function GetBMPFromGIFImageFile(filename: string; Frame: integer): TBitmap;
function GetBMPFromPNGImageFile(filename: string): TBitmap;
function GetBMPFromTGAImageFile(filename: string): TBitmap;
procedure SaveBMPToJpegImageFile(const Bmp: TBitmap; JpgFileName: string);
function SaveBMPToGIFImageFile(const Bmp: array of TBitmap; FileName: string;
   Loop: boolean; Transparency: boolean; Colour0: TColor): boolean; overload;
procedure SaveBMPToGIFImageFile(const Bmp: TBitmap; FileName: string); overload;
function SaveBMPToGIFImageFile(const Bmp: array of TBitmap; FileName: string;
   Loop: boolean; Transparency: boolean; Palette: TPalette): boolean; overload;
procedure SaveBMPToPngImageFile(const Bmp: TBitmap; FileName: string);
procedure SaveBMPToTGAImageFile(const Bmp: TBitmap; FileName: string);
function GetNumberOfFramesFromGif(filename: string): integer;
function GetTransparentFromGIFFile(const Filename: string): TColor;
function GetTransparentFromPNGFile(const Filename: string): TColor;
function GetTransparentFromBMP(const Filename: string): TColor; overload;
function GetTransparentFromBMP(const Filename: string; Frame : integer): TColor; overload;

implementation

uses FormMain;

function GetBMPFromTGAImageFile(filename: string): TBitmap;
var
   Bitmap: TBitmap;
begin
   Bitmap := TBitmap.Create;
   Result := TBitmap.Create;

   LoadFromFileX(Filename, Bitmap);

   Result.Assign(Bitmap);
   Bitmap.Free;
end;

function GetBMPFromPNGImageFile(filename: string): TBitmap;
var
   PNGImage: TPNGObject;
   Bitmap:   TBitmap;
begin
   Bitmap   := TBitmap.Create;
   PNGImage := TPNGObject.Create;

   PNGImage.LoadFromFile(Filename);
   Bitmap.Assign(PNGImage);

   PNGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromGIFImageFile(filename: string; Frame: integer): TBitmap;
var
   GIFImage: TGIFImage;
   Bitmap,FrameBitmap, MaskBitmap:   TBitmap;
   x,y,MyFrame : integer;
   GIFCache : CGIFCache;
begin
   Bitmap   := TBitmap.Create;
   if Frame = 0 then
   begin
      GIFImage := TGIFImage.Create;
      GIFImage.AspectRatio := 0;
      GIFImage.LoadFromFile(Filename);
      Bitmap.Width  := GIFImage.Header.Width;
      Bitmap.Height := GIFImage.Header.Height;
      Bitmap.Canvas.Brush.Color := GIFImage.BackgroundColor;
      Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);
      Bitmap.Assign(GIFImage.Bitmap);
      GIFImage.Free;
   end
   else
   begin
      GIFCache := FrmMain.GIFCacheManager.GetFile(Filename);
      // If there is no cache, we will create it.
      if GIFCache = nil then
      begin
         // get the file.
         GIFImage := TGIFImage.Create;
         GIFImage.AspectRatio := 0;
         GIFImage.LoadFromFile(Filename);
         // Gets the first frame
         Bitmap.Width  := GIFImage.Header.Width;
         Bitmap.Height := GIFImage.Header.Height;
         Bitmap.Canvas.Brush.Color := GIFImage.BackgroundColor;
         Bitmap.Canvas.FillRect(Bitmap.Canvas.ClipRect);
         Bitmap.Assign(GIFImage.Bitmap);
         // Reset other variables.
         FrameBitmap := TBitmap.Create;
         MaskBitmap := TBitmap.Create;
         GIFCache := FrmMain.GIFCacheManager.AddFile(Filename);
         GIFCache.AddBitmap(Bitmap);
         // Let's manually copy the frame, because the transparency treatment
         // from this GIF library sucks. But this part should be very slow.
         MyFrame := 1;
         while MyFrame < GIfImage.Images.Count do
         begin
            FrameBitmap.Assign(GIFImage.Images[MyFrame].Bitmap);
            MaskBitmap.Handle := GIFImage.Images[MyFrame].Mask;
            for x := GIFImage.Images[MyFrame].ClientRect.Left to (GIFImage.Images[MyFrame].ClientRect.Right-1) do
               for y := GIFImage.Images[MyFrame].ClientRect.Top to (GIFImage.Images[MyFrame].ClientRect.Bottom-1) do
               begin
                  if MaskBitmap.Canvas.Pixels[x,y] = 0 then
                  begin
                     Bitmap.Canvas.Pixels[GIFImage.Images[MyFrame].BoundsRect.Left + x,GIFImage.Images[MyFrame].BoundsRect.Top + y] := FrameBitmap.Canvas.Pixels[x,y];
                  end;
               end;
            FrameBitmap.FreeImage;
            GIFCache.AddBitmap(Bitmap);
            inc(MyFrame);
         end;
         FrameBitmap.Free;
         GIFImage.Free;
      end;
      Bitmap.Assign(GIFCache.GetBitmap(Frame));
      // If we finish the last frame, we remove the file.
      if Frame = (GIFCache.GetNumBitmaps-1) then
      begin
         // Remove cache.
         FrmMain.GIFCacheManager.RemoveFile(Filename);
      end;
   end;
   Result := Bitmap;
end;

function GetBMPFromJPGImageFile(filename: string): TBitmap;
var
   JPEGImage: TJPEGImage;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   JPEGImage := TJPEGImage.Create;

   JPEGImage.LoadFromFile(Filename);
   Bitmap.Assign(JPEGImage);

   JPEGImage.Free;
   Result := Bitmap;
end;

function GetBMPFromPCXImageFile(filename: string): TBitmap;
var
   PCXBitmap: TPCXBitmap;
   Bitmap:    TBitmap;
begin
   Bitmap    := TBitmap.Create;
   PCXBitmap := TPCXBitmap.Create;

   try
      try
         PCXBitmap.LoadFromFile(Filename);
         Bitmap.Assign(TBitmap(PCXBitmap));
      except
         ShowMessage(
            'Warning: PCX support on OS SHP Builder is limited and it does not support this file. You will not be able to do any operation with it. You will get unknown errors. Select another file.');
      end;
   finally
      PCXBitmap.Free;
   end;
   Result := Bitmap;
end;

function GetBMPFromImageFile(filename: string): TBitmap; overload;
begin
   Result := GetBMPFromImageFile(Filename,0);
end;

function GetBMPFromImageFile(filename: string; Frame: integer): TBitmap; overload;
var
   Bmp: TBitmap;
   Ext: string;
begin
   Bmp := TBitmap.Create;

   Ext := ansilowercase(extractfileext(filename));

   if Ext = '.bmp' then
      Bmp.LoadFromFile(Filename);

   if (Ext = '.jpg') or (Ext = '.jpeg') then
      bmp := GetBMPFromJPGImageFile(Filename);

   if (Ext = '.pcx') then
      bmp := GetBMPFromPCXImageFile(Filename);

   if (Ext = '.gif') then
      bmp := GetBMPFromGIFImageFile(Filename, Frame);

   if (Ext = '.png') then
      bmp := GetBMPFromPNGImageFile(Filename);

   if (Ext = '.tga') then
      bmp := GetBMPFromTGAImageFile(Filename);

   Result := bmp;
end;

function GetNumberOfFramesFromGif(filename: string): integer;
var
   GIF: TGIFImage;
begin
   GIF := TGIFImage.Create;
   GIF.LoadFromFile(Filename);
   Result := GIF.Images.Count;
   if Result = 0 then
      Result := 1;
   GIF.Free;
end;

procedure SaveBMPToTGAImageFile(const Bmp: TBitmap; FileName: string);
begin
   SaveToFileX(FileName, Bmp, 2);
end;

procedure SaveBMPToPngImageFile(const Bmp: TBitmap; FileName: string);
var
   PNG: TPNGObject;
begin
   Png := TPNGObject.Create;
   try
      Png.Assign(Bmp);
      Png.SaveToFile(FileName);
   finally
      Png.Free;
   end;
end;

function SaveBMPToGIFImageFile(const Bmp: array of TBitmap; FileName: string;
   Loop: boolean; Transparency: boolean; Colour0: TColor): boolean; overload;

   procedure AddBitmap(const Bitmap: TBitmap; var GIF: TGifImage;
      Transparency: boolean; Counter: integer; Colour: TColor);
   var
      GIFExtension: TGIFGraphicControlExtension;
   begin
      Gif.Add(Bmp[Counter]);
      GifExtension := TGIFGraphicControlExtension.Create(Gif.Images[Counter]);
      GifExtension.Delay := 10;
      if Transparency then
      begin
         GifExtension.TransparentColorIndex := Gif.GlobalColorMap.IndexOf(Colour);
         GifExtension.Transparent := True;
         GifExtension.Disposal    := dmBackground;
      end;
      Gif.Images[Counter].Extensions.Add(GifExtension);
   end;

var
   Gif:     TGifImage;
   Counter: integer;
   GIFAppExtNSLoop: TGIFAppExtNSLoop;
begin
   Result := False;
   Gif    := TGifimage.Create;
   Gif.GlobalColorMap.Add(Colour0);
   for Counter := 0 to High(Bmp) do
   begin
      try
         AddBitmap(Bmp[Counter], GIF, Transparency, Counter, Colour0);
      except
         Gif.Free;
         exit;
      end;
   end;
   try
      Gif.OptimizeColorMap;
      if loop then
      begin
         GIFAppExtNSLoop := TGIFAppExtNSLoop.Create(Gif.Images[Gif.Images.Count - 1]);
         GIFAppExtNSLoop.Loops := 0;
         Gif.Images[Gif.Images.Count - 1].Extensions.Add(GIFAppExtNSLoop);
      end;
      Gif.SaveToFile(Filename);
      Result := True;
   finally
      Gif.Free;
   end;
end;

// New Save Gif
function SaveBMPToGIFImageFile(const Bmp: array of TBitmap; FileName: string;
   Loop: boolean; Transparency: boolean; Palette: TPalette): boolean; overload;

   procedure AddBitmap(const Bitmap: TBitmap; var GIF: TGifImage;
      Transparency: boolean; Counter: integer; Colour: TColor);
   var
      GIFExtension: TGIFGraphicControlExtension;
   begin
      Gif.Add(Bmp[Counter]);
      GifExtension := TGIFGraphicControlExtension.Create(Gif.Images[Counter]);
      GifExtension.Delay := 10;
      if Transparency then
      begin
         GifExtension.TransparentColorIndex := Gif.GlobalColorMap.IndexOf(Colour);
         GifExtension.Transparent := True;
         GifExtension.Disposal    := dmBackground;
      end;
      Gif.Images[Counter].Extensions.Add(GifExtension);
   end;

var
   Gif:     TGifImage;
   Counter: integer;
   GIFAppExtNSLoop: TGIFAppExtNSLoop;
begin
   Result := False;
   Gif    := TGifimage.Create;
   for Counter := 0 to 255 do
      Gif.GlobalColorMap.Add(Palette[Counter]);
   for Counter := 0 to High(Bmp) do
   begin
      try
         AddBitmap(Bmp[Counter], GIF, Transparency, Counter, Palette[0]);
      except
         Gif.Free;
         exit;
      end;
   end;
   try
      //      Gif.OptimizeColorMap;
      if loop then
      begin
         GIFAppExtNSLoop := TGIFAppExtNSLoop.Create(Gif.Images[Gif.Images.Count - 1]);
         GIFAppExtNSLoop.Loops := 0;
         Gif.Images[Gif.Images.Count - 1].Extensions.Add(GIFAppExtNSLoop);
      end;
      Gif.SaveToFile(Filename);
      Result := True;
   finally
      Gif.Free;
   end;
end;

procedure SaveBMPToGIFImageFile(const Bmp: TBitmap; FileName: string); overload;
var
   GIF: TGIFImage;
begin
   GIF := TGIFImage.Create;
   try
      GIF.Assign(Bmp);
      GIF.OptimizeColorMap;
      GIF.SaveToFile(FileName);
   finally
      GIF.Free;
   end;
end;

procedure SaveBMPToJpegImageFile(const Bmp: TBitmap; JpgFileName: string);
var
   Jpg: TJPEGImage;
begin
   Jpg := TJPEGImage.Create;
   try
      Jpg.Assign(Bmp);
      Jpg.CompressionQuality := 100;
      Jpg.SaveToFile(JpgFileName);
   finally
      Jpg.Free;
   end;
end;

function SaveImageFileFromBMP(filename: string; Bmp: TBitmap): boolean;
var
   Ext: string;
begin
   Ext    := ansilowercase(extractfileext(filename));
   Result := True;

   try
      if Ext = '.bmp' then
         Bmp.SaveToFile(Filename)
      else if (Ext = '.jpg') or (Ext = '.jpeg') then
         SaveBMPToJpegImageFile(Bmp, Filename)
      else if Ext = '.gif' then
         SaveBMPToGIFImageFile(Bmp, Filename)
      else if Ext = '.png' then
         SaveBMPToPngImageFile(Bmp, Filename)
      else if Ext = '.tga' then
         SaveBMPToTGAImageFile(Bmp, Filename)
      else
         Result := False;
   except
      Result := False;
   end;
end;


function GetTransparentFromPNGFile(const Filename: string): TColor;
var
   PNG: TPNGObject;
begin
   PNG := TPNGObject.Create;
   PNG.LoadFromFile(Filename);
   Result := PNG.TransparentColor;
   PNG.Free;
end;

function GetTransparentFromGIFFile(const Filename: string): TColor;
var
   GIF: TGIFImage;
begin
   GIF := TGIFImage.Create;
   GIF.LoadFromFile(Filename);
   Result := GIF.Header.BackgroundColor;
   GIF.Free;
end;

function GetTransparentFromBMP(const Filename: string): TColor;
begin
   Result := GetTransparentFromBMP(Filename,0);
end;

function GetTransparentFromBMP(const Filename: string; Frame : integer): TColor;
var
   ext:    string;
   Bitmap: TBitmap;
begin
   ext := AnsiLowerCase(ExtractFileExt(Filename));

   if ext = '.gif' then
      Result := GetTransparentFromGIFFile(Filename)
   else if ext = '.png' then
      Result := GetTransparentFromPNGFile(Filename)
   else // get Pixel (0,0);
   begin
      Bitmap := GetBMPFromImageFile(Filename,Frame);
      Result := Bitmap.Canvas.Pixels[0, 0];
      Bitmap.Free;
   end;
end;

end.
