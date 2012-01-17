program overscroll;
uses Graph;
var
 gd,gm:integer;
begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 setactivepage(1); setcolor(9);
 settextstyle(0,0,2);
 outtextxy(0,  0,'This is a test to see whether you can');
 outtextxy(0, 20,'scroll text over the top of a picture.');
 outtextxy(0, 40,'I was wondering whether it would work.');
 outtextxy(0, 60,'Well, does it, or not?');
 outtextxy(0, 80,'If so, it could be useful for the');
 outtextxy(0,100,'Avalot title sequence.');
 outtextxy(0,120,'Good, isn''t it?');
 outtextxy(0,140,'The quick brown fox jumps over the');
 outtextxy(0,160,'lazy dog...');
 outtextxy(0,180,'This is the last line...');
 setactivepage(0);
 gm:=0;
 for gd:=0 to 640 do
 begin;
  inc(gm); if gm=8 then gm:=1; setcolor(gm);
  line(gd,0,gm,350);
  line(640-gd,0,640-gm,350);
 end;
(* for gd:=1 to 15 do
 begin;
  setfillstyle(1,gd); bar(gd*20,10,gd*20+19,100);
 end;*)
(* setfillstyle(1,6); bar(100,100,500,100);*) gd:=getpixel(0,0);
 for gm:=8 to 15 do setpalette(gm,egayellow);
 for gd:=0 to 199 do
 begin;
  port[$3C4]:=2; port[$3CF]:=4; port[$3C5]:=8; port[$3CF]:=0;
  move(mem[$A000:80],mem[$A000:0],16000);
  port[$3C4]:=2; port[$3CF]:=4; port[$3C5]:=8; port[$3CF]:=0;
  move(mem[$A000:gd*80+16384],mem[$A000:15920],80);
 end;
(* for gd:=0 to 199 do
 begin;
  port[$3C4]:=2; port[$3CF]:=4; port[$3C5]:=8; port[$3CF]:=0;
  move(mem[$A000:160],mem[$A000:0],15920);
  port[$3C4]:=2; port[$3CF]:=4; port[$3C5]:=8; port[$3CF]:=0;
  move(mem[$A000:gd*80+16384],mem[$A000:15920],80);
  move(mem[$A000:15920],mem[$A000:15840],80);
 end;*)
end.