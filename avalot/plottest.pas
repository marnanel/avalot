program plottest;
uses Graph;
var
 gd,gm:integer; fv:byte;
 a:array[1..35,0..39] of byte;
 b:array[0..3,0..4,1..35] of byte;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 for gd:=0 to 39 do
  for gm:=1 to 35 do
   a[gm,gd]:=(gd+gm) mod 16;
 for gd:=0 to 39 do
  for gm:=1 to 35 do
   putpixel(gd+100,gm+100,a[gm,gd]);

 fillchar(b,sizeof(b),#0);
 for gm:=1 to 35 do
  for gd:=0 to 39 do
  begin;
   for fv:=0 to 3 do
   begin;
    b[fv,gd div 8,gm]:=(b[fv,gd div 8,gm] shl 1);
    inc(b[fv,gd div 8,gm],((a[gm,gd] and (1 shl fv)) shr fv));
   end;
  end;

 for gd:=1 to 35 do
  for gm:=0 to 4 do
  begin;
   for fv:=0 to 3 do
   begin;
    port[$3C4]:=2; port[$3CE]:=4;
    port[$3C5]:=1 shl fv; port[$3CF]:=fv;
    mem[$A000:gd*80+gm]:=b[fv,gm,gd];
   end;
  end;
end.