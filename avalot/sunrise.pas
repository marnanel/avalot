program sunrise;
uses Graph,Crt;
var
 gd,gm:integer;
 tskellern:longint absolute $0:244; { Over int $61 }

procedure hold;
begin;
 repeat until TSkellern>=1;
 TSkellern:=0;
end;

begin;
 gd:=3; gm:=1; initgraph(gd,gm,'c:\bp\bgi');

 setvisualpage(1);
 setfillstyle(1,1);
 for gd:=1 to 640 do
  bar(gd,177+trunc(20*sin(gd/39)),gd,350);
 setfillstyle(1,3); setcolor(3);
 fillellipse(320,277,60,50);
 settextjustify(1,1); settextstyle(0,0,2); setcolor(9);
 outtextxy(320,50,'The sun rises over Hertfordshire...');
 settextjustify(2,0); settextstyle(0,0,1); setcolor(0);
 outtextxy(635,350,'Press any key...');

 setpalette(0,EGAblue);
 setpalette(1,EGAgreen);
 setpalette(2,EGAyellow);
 setpalette(3,EGAgreen);
 setpalette(9,EGAlightblue);
 setpalette(11,EGAlightblue);
 setvisualpage(0);

 port[$3C4]:=2; port[$3Ce]:=4;
 port[$3C5]:=1 shl 1; port[$3CF]:=1;

 for gm:=227 downto 1 do { <<< try running this loop the other way round! }
 begin;
  move(mem[$A000:gm*80+80],mem[$A000:gm*80],8042);
  hold;
  if keypressed then exit;
 end;

 for gm:=101 downto 1 do
 begin;
  move(mem[$A000:80],mem[$A000:0],gm*80);
  hold;
  if keypressed then exit;
 end;
end.