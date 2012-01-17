program fontslide;
uses Crt;
type
 fonttype = array[#0..#255,0..15] of byte;

var
 font1:fonttype;
 fv:byte;
 r:char;
 f:file of fonttype;

begin;
 assign(f,'v:avalot.fnt'); reset(f); read(f,font1); close(f);
 for r:=#0 to #255 do
 begin;
  for fv:= 0 to  3 do font1[r,fv]:=font1[r,fv] shr 1;
  for fv:= 7 to  8 do font1[r,fv]:=font1[r,fv] shl 1;
  for fv:= 9 to 14 do font1[r,fv]:=font1[r,fv] shl 2;
 end;
 assign(f,'v:avitalic.fnt'); rewrite(f); write(f,font1); close(f);
end.