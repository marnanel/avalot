program dwidth;
uses Graph;

type
 fonttype = array[#0..#255,0..15] of byte;

var
 gd,gm:integer;
 f:fonttype;
 ff:file of fonttype;

begin;
 assign(ff,'v:avalot.fnt'); reset(ff); read(ff,f); close(ff);
 gd:=3; gm:=0; initgraph(gd,gm,'');
 for gd:=0 to 15 do mem[$A000:gd*80]:=f['A',gd];
end.