unit CSchemes;

interface

type
   TColourSchemes = array of packed record
      Name, Filename, By, Website: string;
      Data: array [0..255] of byte;
   end;

implementation

end.
 