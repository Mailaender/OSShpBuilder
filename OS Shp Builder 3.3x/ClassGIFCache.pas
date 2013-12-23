unit ClassGIFCache;

interface

uses Graphics;

type
   CGIFCache = class
      public
         // Constructors
         constructor Create(const _Filename : string);
         destructor Destroy; override;
         procedure Reset;
         // Gets
         function GetNumBitmaps: integer;
         function GetBitmap(_ID : integer): TBitmap;
         function GetFilename : string;
         // Adds
         procedure AddBitmap(_Bitmap : TBitmap);
      private
         BitmapArray : array of TBitmap;
         Filename : string;
   end;

implementation

// Constructors
constructor CGIFCache.Create(const _Filename: string);
begin
   Reset;
   Filename := copy(_Filename,1,Length(_Filename));
end;

destructor CGIFCache.Destroy;
begin
   Reset;
   inherited Destroy;
end;

procedure CGIFCache.Reset;
var
   i : integer;
begin
   if GetNumBitmaps > 0 then
   begin
      for i := Low(BitmapArray) to High(BitmapArray) do
      begin
         BitmapArray[i].Free;
      end;
   end;
   SetLength(BitmapArray,0);
end;

// Gets
function CGIFCache.GetNumBitmaps: integer;
begin
   Result := High(BitmapArray)+1;
end;

function CGIFCache.GetBitmap(_ID : integer): TBitmap;
begin
   if (_ID >= 0) and (_ID <= High(BitmapArray)) then
   begin
      Result := BitmapArray[_ID];
   end
   else
      Result := nil;
end;

function CGIFCache.GetFilename: string;
begin
   Result := Filename;
end;


// Adds
procedure CGIFCache.AddBitmap(_Bitmap: TBitmap);
begin
   SetLength(BitmapArray,High(BitmapArray)+2);
   BitmapArray[High(BitmapArray)] := TBitmap.Create;
   BitmapArray[High(BitmapArray)].Assign(_Bitmap);
end;

end.
