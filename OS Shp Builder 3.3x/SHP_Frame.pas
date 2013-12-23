unit SHP_Frame;

interface

uses
   Windows, Graphics, Classes, SHP_File, SHP_Shadows, Palette,
   Undo_Redo, Dialogs, SysUtils, Math;

procedure Insertblankframe(var SHP: TSHP; const Frame: integer);
function Insertblankframe_shadow(var SHP: TSHP; const Frame: integer): integer;
procedure SwapFrameImages(var SHP: TSHP; const Frame1, Frame2: integer);
procedure MoveSeveralFrameImagesUp(var SHP: TSHP; const Frame, Ammount: integer);
procedure MoveFrameImagesUp(var SHP: TSHP; const Frame: integer);
procedure MoveSeveralFrameImagesDown(var SHP: TSHP; const Frame, Ammount: integer);
procedure ClearFrameImage(var SHP: TSHP; const Frame: integer); overload;
procedure ClearFrameImage(var UndoRedo: TUndoRedo; var SHP: TSHP;
   const Frame: integer); overload;
procedure MoveFrameImagesDown(var SHP: TSHP; const Frame: integer);
procedure Deleteframe(var SHP: TSHP; const Frame: integer);
procedure Deleteframe_shadow(var SHP: TSHP; const Frame: integer);

function GetBMPOfFrameImage(const SHP: TSHP; Frame: integer;
   const Palette: TPalette): TBitmap; overload;
function GetBMPOfFrameImage(const Frame: TFrameImage;
   const Palette: TPalette; Width, Height : integer): TBitmap; overload;
function GetBMPOfFrameImage_ShadowColour(const SHP: TSHP; Frame: integer;
   const Palette: TPalette; shadowcolour: byte): TBitmap;

implementation

procedure ClearFrameImage(var SHP: TSHP; const Frame: integer); overload;
var
   x, y: integer;
begin

   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
         SHP.Data[Frame].FrameImage[x, y] := 0;
end;

procedure ClearFrameImage(var UndoRedo: TUndoRedo; var SHP: TSHP;
   const Frame: integer); overload;
var
   x, y: integer;
begin

   for x := 0 to SHP.Header.Width - 1 do
      for y := 0 to SHP.Header.Height - 1 do
      begin
         AddToUndoMultiFrames(UndoRedo, Frame, x, y, SHP.Data[Frame].FrameImage[x, y]);
         SHP.Data[Frame].FrameImage[x, y] := 0;
      end;
end;

procedure Insertblankframe(var SHP: TSHP; const Frame: integer);
begin
   MoveFrameImagesUp(SHP, Frame);
   ClearFrameImage(SHP, Frame);
end;

function Insertblankframe_shadow(var SHP: TSHP; const Frame: integer): integer;
var
   owner, shadow: integer;
begin
   if IsShadow(SHP, Frame) then
   begin
      shadow := Frame;
      owner  := GetShadowOposite(SHP, Frame);
   end
   else
   begin
      shadow := GetShadowFromOposite(SHP, Frame);
      owner  := Frame;
   end;

   MoveFrameImagesUp(SHP, owner);
   ClearFrameImage(SHP, owner);

   MoveFrameImagesUp(SHP, shadow + 1);
   ClearFrameImage(SHP, shadow + 1);

   Result := owner;
end;

// 3.35: Imported from 3.4 to allow import on existing SHP.
procedure MoveSeveralFrameImagesUp(var SHP: TSHP; const Frame, Ammount: integer);
var
   x, xx, yy: integer;
begin
   // Basic Check Up
   if Frame < 1 then
      exit;
   if Frame > (SHP.Header.NumImages + Ammount) then
      exit;

   // Set Up
   SHP.Header.NumImages := SHP.Header.NumImages + Ammount;
   SetLength(SHP.Data, SHP.Header.NumImages + 1);
   for x := Ammount downto 0 do
   begin
      SetLength(SHP.Data[SHP.Header.NumImages - x].FrameImage, SHP.Header.Width,
         SHP.Header.Height);
   end;

   // Move stuff
   for x := SHP.Header.NumImages downto (Frame + Ammount) do
   begin
      for xx := 0 to SHP.Header.Width - 1 do
         for yy := 0 to SHP.Header.Height - 1 do
            SHP.Data[x].FrameImage[xx, yy] := SHP.Data[x - Ammount].FrameImage[xx, yy];
   end;
end;

procedure MoveSeveralFrameImagesDown(var SHP: TSHP; const Frame, Ammount: integer);
var
   x, xx, yy: integer;
begin
   // Basic Check Up
   if (Frame < 1) or (Frame > (SHP.Header.NumImages + Ammount)) then
      exit;

   // Move stuff
   for x := Frame to SHP.Header.NumImages - Ammount do
   begin
      for xx := 0 to SHP.Header.Width - 1 do
         for yy := 0 to SHP.Header.Height - 1 do
            SHP.Data[x].FrameImage[xx, yy] := SHP.Data[x + Ammount].FrameImage[xx, yy];
   end;

   // Ajust Data
   SHP.Header.NumImages := SHP.Header.NumImages - Ammount;
   SetLength(SHP.Data, SHP.Header.NumImages + 1);
end;

procedure MoveFrameImagesUp(var SHP: TSHP; const Frame: integer);
var
   x, xx, yy, c: integer;
begin
   if Frame < 1 then
      exit;

   if Frame > SHP.Header.NumImages then
      exit;

   SHP.Header.NumImages := SHP.Header.NumImages + 1;
   SetLength(SHP.Data, SHP.Header.NumImages + 1);
   SetLength(SHP.Data[SHP.Header.NumImages].FrameImage, SHP.Header.Width,
      SHP.Header.Height);

   c := 0;
   for x := Frame to SHP.Header.NumImages - 1 do
   begin
      for xx := 0 to SHP.Header.Width - 1 do
         for yy := 0 to SHP.Header.Height - 1 do
            SHP.Data[SHP.Header.NumImages - c].FrameImage[xx, yy] :=
               SHP.Data[SHP.Header.NumImages - 1 - c].FrameImage[xx, yy];
      c := c + 1;
   end;
end;

procedure MoveFrameImagesDown(var SHP: TSHP; const Frame: integer);
var
   x, xx, yy: integer;
begin
   if Frame < 1 then
      exit;

   if Frame > SHP.Header.NumImages then
      exit;

   if Frame < SHP.Header.NumImages then
      for x := Frame to SHP.Header.NumImages - 1 do
      begin
         for xx := 0 to SHP.Header.Width - 1 do
            for yy := 0 to SHP.Header.Height - 1 do
               SHP.Data[x].FrameImage[xx, yy] := SHP.Data[x + 1].FrameImage[xx, yy];
      end;

   SHP.Header.NumImages := SHP.Header.NumImages - 1;
   SetLength(SHP.Data, SHP.Header.NumImages + 1);
end;

procedure SwapFrameImages(var SHP: TSHP; const Frame1, Frame2: integer);
var
   x, xx, yy: integer;
   minframe, maxframe: integer;
   TempFrame: TFrameImage;
begin
   // Basic Check Up
   if (Frame1 < 1) or (Frame1 >= (SHP.Header.NumImages)) then
      exit;
   if (Frame2 < 1) or (Frame2 >= (SHP.Header.NumImages)) then
      exit;
   if (Frame1 = Frame2) then
      exit;

   minframe := Min(Frame1, Frame2);
   maxframe := Max(Frame1, Frame2);

   // Copy maxframe in a temp frame.
   setlength(TempFrame, SHP.Header.Width, SHP.Header.Height);
   for xx := 0 to SHP.Header.Width - 1 do
      for yy := 0 to SHP.Header.Height - 1 do
         TempFrame[xx, yy] := SHP.Data[maxframe].FrameImage[xx, yy];

   // Move stuff
   for x := MaxFrame downto MinFrame + 1 do
   begin
      for xx := 0 to SHP.Header.Width - 1 do
         for yy := 0 to SHP.Header.Height - 1 do
            SHP.Data[x].FrameImage[xx, yy] := SHP.Data[x - 1].FrameImage[xx, yy];
   end;

   // copy tempframe at minframe
   for xx := 0 to SHP.Header.Width - 1 do
      for yy := 0 to SHP.Header.Height - 1 do
         SHP.Data[minframe].FrameImage[xx, yy] := TempFrame[xx, yy];
end;


procedure Deleteframe(var SHP: TSHP; const Frame: integer);
begin
   MoveFrameImagesDown(SHP, Frame);
end;

procedure Deleteframe_shadow(var SHP: TSHP; const Frame: integer);
var
   owner, shadow: integer;
begin
   if IsShadow(SHP, Frame) then
   begin
      shadow := Frame;
      owner  := GetShadowOposite(SHP, Frame);
   end
   else
   begin
      shadow := GetShadowFromOposite(SHP, Frame);
      owner  := Frame;
   end;

   Deleteframe(SHP, owner);
   Deleteframe(SHP, shadow - 1);
end;

function GetBMPOfFrameImage(const SHP: TSHP; Frame: integer;
   const Palette: TPalette): TBitmap;
var
   BMP:  TBitmap;
   x, y: integer;
begin
   BMP := TBitmap.Create;
   //Result := BMP; // Assume Worst Case


   // Set image width n height
   BMP.Width  := SHP.header.Width;
   BMP.Height := SHP.header.Height;

   // Clear the image of colour (fills with the transparent colour)
   BMP.Canvas.Brush.Color := palette[TRANSPARENT];
   BMP.Canvas.FillRect(rect(0, 0, BMP.Width, BMP.Height));

   // Populate the image pixel by pixel
   for y := 0 to SHP.header.Height - 1 do
      for x := 0 to SHP.header.Width - 1 do
      begin

         if shp.Data[Frame].frameimage[x, y] <> TRANSPARENT then
            // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
            BMP.Canvas.Pixels[x, y] := palette[shp.Data[Frame].frameimage[x, y]];
      end;

   Result := BMP;

end;

function GetBMPOfFrameImage(const Frame: TFrameImage;
   const Palette: TPalette; Width, Height : integer): TBitmap;
var
   BMP:  TBitmap;
   x, y: integer;
begin
   BMP := TBitmap.Create;
   //Result := BMP; // Assume Worst Case


   // Set image width n height
   BMP.Width  := Width;
   BMP.Height := Height;

   // Clear the image of colour (fills with the transparent colour)
   BMP.Canvas.Brush.Color := palette[TRANSPARENT];
   BMP.Canvas.FillRect(rect(0, 0, BMP.Width, BMP.Height));

   // Populate the image pixel by pixel
   for y := 0 to Height - 1 do
      for x := 0 to Width - 1 do
      begin

         if Frame[x, y] <> TRANSPARENT then
            // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
            BMP.Canvas.Pixels[x, y] := palette[Frame[x, y]];
      end;

   Result := BMP;

end;

function GetBMPOfFrameImage_ShadowColour(const SHP: TSHP; Frame: integer;
   const Palette: TPalette; shadowcolour: byte): TBitmap;
var
   BMP:  TBitmap;
   x, y: integer;
begin
   BMP := TBitmap.Create;


   // Set image width n height
   BMP.Width  := SHP.header.Width;
   BMP.Height := SHP.header.Height;

   // Clear the image of colour (fills with the transparent colour)
   BMP.Canvas.Brush.Color := palette[0];
   BMP.Canvas.FillRect(rect(0, 0, BMP.Width, BMP.Height));

   // Populate the image pixel by pixel
   for y := 0 to SHP.header.Height - 1 do
      for x := 0 to SHP.header.Width - 1 do
      begin

         if shp.Data[Frame].frameimage[x, y] <> 0 then
            // Stops it drawing transparent colours, stops shadows oposite form drawing over shadow
            BMP.Canvas.Pixels[x, y] := palette[shadowcolour];
      end;

   Result := BMP;
end;

end.
