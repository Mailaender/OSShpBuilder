unit Tmp_File;

{
Version 1.0
- Included file structure
- Included Loading instructions.
}
interface

// Note: Requires SHP Engine included at OS SHP Builder 3.x
uses SHP_File, SHP_Engine, Math;

const
   TMP_ENGINE_VER = '1.0';
   TMP_ENGINE_BY  = 'Banshee';

type

   // The TMP file
   t_tmp_ts_header = record
      cblocks_x: integer;
      cblocks_y: integer;
      cx: integer;
      cy: integer;
   end;

   t_tmp_image_header = record
      x:      integer;
      y:      integer;
      extra_ofs: integer;
      z_ofs:  integer;
      extra_z_ofs: integer;
      x_extra: integer;
      y_extra: integer;
      cx_extra: integer;
      cy_extra: integer;
      has_extra_data: word; // default value = 1
      has_z_data: word;     // default value = 1
      has_damaged_data: word;  // default value = 1
      Height: smallint;
      terrain_type: smallint;
      ramp_type: smallint;
      radar_red_left: byte;
      radar_green_left: byte;
      radar_blue_left: byte;
      radar_red_right: byte;
      radar_green_right: byte;
      radar_blue_right: byte;
      pad:    array [0..2] of smallint;
   end;

   TTMPFileFrameData = record
      Header:     t_tmp_image_header;
      Databuffer: array of array of byte;
   end;

   TTMPFile = record
      Header: t_tmp_ts_header;
      Data:   array of TTMPFileFrameData;
   end;


   // The TMP document (Draft for future versions)
   // *********************

   // Type TMP Image Header
   TTMPImageHeader = record
      has_extra_data: word;
      has_z_data: word;
      has_damaged_data: word;
      Height: smallint;
      terrain_type: smallint;
      ramp_type: smallint;
      radar_red_left: byte;
      radar_green_left: byte;
      radar_blue_left: byte;
      radar_red_right: byte;
      radar_green_right: byte;
      radar_blue_right: byte;
      pad: array [0..2] of smallint;
   end;

   // PS: No need for databuffer. It's a temporary information.

   // Type TMP Frame Data. Mainly Header and pixels.
   TTMPFrameData = record
      Header:     TTMPImageHeader;
      FrameImage: array of array of byte;
   end;

   // Type TMP.
   TTMP = record
      Header: t_tmp_ts_header;
      Data:   array of TTMPFrameData;
   end;

   // For OS SHP Builder 3.x... might be down in future versions
   // TTMP Settings
   TTMPSettings = ^TTMPProperties;

   TTMPProperties = record
      Header: t_tmp_ts_header;
      Frames: array of t_tmp_image_header;
   end;

implementation

procedure LoadTMP(Filename: string; var SHP: TSHP);
var
   TMPFile: TTMPFile;
   counter: word;
   FileLocation, ImageSize: longword;
   MinOffset: longint;
   ImageOffset: array of longint;
   f: file;
   x0package, xpackage, xpointer, x, y: integer;
   TempDatabuffer, ShadowDatabuffer: array of array of byte;
   ExtraTempDatabuffer, ExtraShadowDatabuffer: array of array of byte;
   Minx, Maxx, Miny, Maxy: integer;
begin
   AssignFile(F, Filename);  // Open file
   Reset(F, 1); // Goto first byte?

   BlockRead(F, TMPFile.Header, Sizeof(TMPFile.Header)); // Read Header

   // basic stuff from a SHP document
   SHP.Header.A := 0;

   // In order to know the ammount of images, as well as width,
   // height and some other info, we gonna need to get the offsets.
   SHP.Header.NumImages := 0;
   MinOffset    := 999999;
   FileLocation := sizeof(TMPFile.Header);
   while (FileLocation < MinOffset) do
   begin
      // Read offset pointer
      SetLength(ImageOffset, SHP.Header.NumImages + 1);
      BlockRead(F, ImageOffset[SHP.Header.NumImages], sizeof(longint));
      // Increase FileLocation
      FileLocation := FileLocation + 4; // longint = 4 bytes
      if ImageOffset[SHP.Header.NumImages] <> 0 then
      begin // We have a new frame
            // Check if it's the lowest offset
         if ImageOffset[SHP.Header.NumImages] < MinOffset then
            MinOffset := ImageOffset[SHP.Header.NumImages];
         // Increase NumImages since it's a valid image
         Inc(SHP.Header.NumImages);
      end;
   end;
   // Eliminate any last element that gets 0 as offset ;)
   SetLength(ImageOffset, SHP.Header.NumImages + 1);
   // Set Length from TMPFile and SHP images...
   SetLength(TMPFile.Data, SHP.Header.NumImages);
   SetLength(SHP.Data, 3);
   SHP.Data[1].Header_Image.Compression := 1;
   SHP.Data[2].Header_Image.Compression := 1;

   // Time to read frame by frame
   for counter := 1 to SHP.Header.NumImages do
   begin
      // Read header
      Seek(F, ImageOffset[counter - 1]);
      BlockRead(F, TMPFile.Data[counter - 1].Header, sizeof(TMPFile.Data[counter - 1].Header));

      // Adapt the size of the databuffer to get the TMP frame
      ImageSize := (TMPFile.Data[counter - 1].Header.z_ofs - sizeof(TMPFile.Data)) -
         ImageOffset[counter - 1];
      SetLength(TempDatabuffer, counter);
      SetLength(TempDatabuffer[counter - 1], ImageSize);

      // Calculate final frame size
      Minx := Min(Minx, TMPFile.Data[counter - 1].Header.x);
      Maxx := Max(Maxx, TMPFile.Data[counter - 1].Header.x + TMPFile.Header.cx);
      Miny := Min(Miny, (TMPFile.Data[counter - 1].Header.y +
         (TMPFile.Data[counter - 1].Header.Height * ((TMPFile.Header.cy div 2) * -1))));
      Maxy := Max(Maxy, (TMPFile.Data[counter - 1].Header.y +
         (TMPFile.Data[counter - 1].Header.Height * ((TMPFile.Header.cy div 2) * -1))) +
         TMPFile.Header.cy);

      // Now, we read the frame databuffer
      Dec(ImageSize);
      for y := 0 to ImageSize do
      begin
         BlockRead(F, TempDatabuffer[counter - 1, y], sizeof(byte));
      end;

      // Read shadow data
      if TMPFile.Data[counter - 1].Header.has_z_data <> 0 then
      begin
         // Ajust shadow databuffer
         SetLength(ShadowDatabuffer, counter);
         SetLength(ShadowDatabuffer[counter - 1], ImageSize);

         Seek(F, ImageOffset[counter - 1] + TMPFile.Data[counter - 1].Header.z_ofs);

         for y := 0 to ImageSize do
         begin
            BlockRead(F, ShadowDatabuffer[counter - 1, y], sizeof(byte));
         end;
      end;
      // Do you think that the frame is over? Sometimes it is
      // But in other times, we still have to deal with extra
      // data. Fortunatelly it's a rectangle that makes things
      // a lot easier.
      if TMPFile.Data[counter - 1].Header.has_extra_data <> 0 then
      begin
         // Ajust shadow databuffer
         SetLength(ExtraTempDatabuffer, counter);
         SetLength(ExtraTempDatabuffer[counter - 1], ImageSize);

         // Height may change
         Miny := Min(Miny, (TMPFile.Data[counter - 1].Header.y_extra +
            (TMPFile.Data[counter - 1].Header.Height * ((TMPFile.Header.cy div 2) * -1))));
         Maxy := Max(Maxy, (TMPFile.Data[counter - 1].Header.y_extra +
            (TMPFile.Data[counter - 1].Header.Height * ((TMPFile.Header.cy div 2) * -1))) +
            TMPFile.Header.cy);

         Seek(F, ImageOffset[counter - 1] + TMPFile.Data[counter - 1].Header.extra_ofs);

         for y := 0 to ImageSize do
         begin
            BlockRead(F, ExtraTempDatabuffer[counter - 1, y], sizeof(byte));
         end;

         // Read shadow data inside the extra frame.
         if TMPFile.Data[counter - 1].Header.has_z_data <> 0 then
         begin
            // Ajust shadow databuffer
            ImageSize := TMPFile.Data[counter - 1].Header.cx_extra *
               TMPFile.Data[counter - 1].Header.cy_extra;
            SetLength(ExtraShadowDatabuffer, counter);
            SetLength(ExtraShadowDatabuffer[counter - 1], ImageSize);

            Seek(F, ImageOffset[counter - 1] + TMPFile.Data[counter - 1].Header.extra_z_ofs);

            for y := 0 to ImageSize do
            begin
               BlockRead(F, ExtraShadowDatabuffer[counter - 1, y], sizeof(byte));
            end;
         end;

      end;

   end;

   SHP.Header.NumImages := 2;

end;

end.
