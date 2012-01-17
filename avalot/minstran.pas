program Minstrel_Blitter;
uses Graph;
var
 gd,gm:integer;
 p:pointer; s:word;

procedure mblit(x1,y1,x2,y2:integer); { Minstrel Blitter }
var yy,len,pp:integer; bit:byte; const offset = 16384;
begin;
 x1:=x1 div 8; len:=((x2 div 8)-x1)+1;
 for yy:=y1 to y2 do
 begin;
  pp:=yy*80+x1;
  for bit:=0 to 3 do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   move(mem[$A000:offset+pp],mem[$A000:pp],len);
  end;
 end;
end;

const fx1=100; fy1=100; fx2=135; fy2=145;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 setactivepage(1); setfillstyle(7,9); bar(0,0,640,200);
 mblit(fx1,fy1,fx2,fy2);
 s:=imagesize(fx1,fy1,fx2,fy2); getmem(p,s);
 getimage(fx1,fy1,fx2,fy2,p^); setactivepage(0);
 putimage(fx1+100,fy1,p^,0); freemem(p,s);
end.