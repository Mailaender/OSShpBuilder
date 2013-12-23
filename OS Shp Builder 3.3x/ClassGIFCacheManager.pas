unit ClassGIFCacheManager;

interface

uses ClassGIFCache, SysUtils;

type
   CGIFCacheManager = class
      public
         // Constructors
         constructor Create;
         destructor Destroy; override;
         procedure Reset;
         // Gets
         function GetNumFiles: integer;
         function GetFile(_ID : integer): CGIFCache; overload;
         function GetFile(_Filename : string): CGIFCache; overload;
         // Adds
         function AddFile(const _Filename : string): CGIFCache;
         // Removes
         procedure RemoveFile(const _Filename: string);
      private
         FileList : array of CGIFCache;
   end;


implementation

// Constructors
constructor CGIFCacheManager.Create;
begin
   Reset;
end;

destructor CGIFCacheManager.Destroy;
begin
   Reset;
   inherited Destroy;
end;

procedure CGIFCacheManager.Reset;
var
   i : integer;
begin
   if GetNumFiles > 0 then
   begin
      for i := Low(FileList) to High(FileList) do
      begin
         FileList[i].Free;
      end;
   end;
   SetLength(FileList,0);
end;

// Gets
function CGIFCacheManager.GetNumFiles: integer;
begin
   Result := High(FileList)+1;
end;

function CGIFCacheManager.GetFile(_ID : integer): CGIFCache;
begin
   if (_ID >= 0) and (_ID <= High(FileList)) then
   begin
      Result := FileList[_ID];
   end
   else
      Result := nil;
end;

function CGIFCacheManager.GetFile(_Filename : string): CGIFCache;
var
   i : integer;
begin
   i := Low(FileList);
   while i <= High(FileList) do
   begin
      if CompareStr(FileList[i].GetFilename,_Filename) = 0 then
      begin
         Result := FileList[i];
         exit;
      end;
      inc(i);
   end;
   Result := nil;
end;

// Adds
function CGIFCacheManager.AddFile(const _Filename : string): CGIFCache;
begin
   SetLength(FileList,High(FileList)+2);
   FileList[High(FileList)] := CGIFCache.Create(_Filename);
   Result := FileList[High(FileList)];
end;

// Removes
procedure CGIFCacheManager.RemoveFile(const _Filename: string);
var
   i : integer;
   found : boolean;
begin
   i := Low(FileList);
   found := false;
   while i <= High(FileList) do
   begin
      if CompareStr(FileList[i].GetFilename,_Filename) = 0 then
      begin
         FileList[i].Free;
         found := true;
      end;
      if found then
      begin
         if i < High(FileList) then
         begin
            FileList[i] := FileList[i+1];
         end;
      end;
      inc(i);
   end;
   if found then
      SetLength(FileList,High(FileList));
end;

end.
