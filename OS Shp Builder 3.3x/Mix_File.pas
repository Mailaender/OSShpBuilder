unit Mix_File;

interface

const
   c_mix_checksum  = $00010000;
   c_mix_encrypted = $00020000;
   cb_mix_key_source = 80;
   cb_mix_key      = 56;
   cb_mix_checksum = 20;
   max_buffer_size = 20; // -> need a true value.

type

   t_mix_header = record
      flags:   longint;
      c_files: smallint;
      size:    longint;

   end;

   t_mix_index_entry = record
      id:     longword;
      offset: longint;
      size:   longint;
   end;

type
   ArrayByte  = array of byte;
   PArrayByte = ^ArrayByte;

function get_blowfish_key(s, d: PArrayByte): integer; stdcall; external 'mixhelp.dll';
function decode_blowfish(s, d: PArrayByte; q: integer): integer;
   stdcall; external 'mixhelp.dll';

var
   key_source: array[0..79] of byte;
   MixFlags: integer;
   key: array[0..55] of byte;
   NoFiles, BodySize, CalcSize, cb_f, OffsetModifier, cb_index: integer;
   e:   array[0..7] of byte;
   q:   array[0..max_buffer_size - 1] of byte;
   SimpleHeader, Cached: boolean;
   ReadMixResult: integer;

implementation

{
  fs.Seek(MixStart,soFromBeginning);
  fs.Read(MixFlags,4);
  if not ((MixFlags and $FFFF)=0) then begin
    SimpleHeader:=True;
    MixFlags:=0;
    fs.Seek(MixStart,soFromBeginning);
  end else
    SimpleHeader:=False;

  if not ((MixFlags and c_mix_encrypted)=0) then begin //ouch, encrypted! Now we need the MixHelp.dll file...
    fs.Read(key_source,cb_mix_key_source);
    //Convert the WW-type key to a standard Blowfish key
    get_blowfish_key(@key_source,@key);
  end;

  //Now decode/read the Mix Header!
  fs.Read(e,8);
  if not ((MixFlags and c_mix_encrypted)=0) then decode_blowfish(@key,@e,8);
  NoFiles:=e[0]+e[1]*256;
  //file header size...

  cb_index:=NoFiles*SizeOf(recMixEntry);
  if SimpleHeader then
    cb_f:=cb_index
  else
    if not ((MixFlags and c_mix_encrypted)=0) then
      cb_f:=(cb_index+5) and not 7  //this is some sort of alignment which can differ 4 bytes?
    else
      cb_f:=cb_index;
}

end.
