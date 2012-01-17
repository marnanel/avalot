program testandexor;
uses Graph;

const
 ttp = 81920;
 borland = xorput;
 mb1 = 2; { 2 }
 mb2 = 4; { 4 }

var
 gd,gm:integer;
 p:pointer;
 s:word;

procedure mblit;
var bit:byte; st:longint;
begin;
 st:=ttp;
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=mb1;
  portw[$3ce]:=copyput*256+3;
  portw[$3ce]:=$205;
  port[$3ce]:=$8;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(mem[$A000:st],mem[$A000:0],7200);
 end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 settextstyle(1,0,7);
 for gd:=0 to 1 do
 begin;
  setactivepage(gd); setcolor(6*gd+6);
  outtextxy(0,0,chr(65+gd));
 end;
 s:=imagesize(0,0,90,90); setactivepage(0); getmem(p,s);
 getimage(0,0,90,90,p^); putimage(100,100,p^,0);
 setactivepage(1); getimage(0,0,90,90,p^); setactivepage(0);
 putimage(100,100,p^,borland);
 mblit;
end.