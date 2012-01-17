program nimst;
uses Graph;

const header : string = 'Datafile for Avalot, copyright (c) 1992.'+#26;

var
 gd,gm,x,y:integer;
 f:file;
 bit:byte;

procedure plot(ch:char; x:byte);
begin;
 setcolor(blue);     outtextxy(x*80+4,0,ch); outtextxy(x*80+10,0,ch);
 setcolor(lightblue); outtextxy(x*80+5,0,ch); outtextxy(x*80+9,0,ch);
 setcolor(darkgray); outtextxy(x*80+6,0,ch); outtextxy(x*80+8,0,ch);
 setcolor(yellow);     outtextxy(x*80+7,0,ch);
end;

procedure load;
var z:byte;
 a:array[1..4] of pointer;
 check:string[12];
 f:file; s:word;
begin;
 assign(f,'c:\avalot\nimstone.avd'); reset(f,1);
 seek(f,85); z:=3;
 s:=imagesize(0,0,Getmaxx,75);
 getmem(a[z],s);
 blockread(f,a[z]^,s);
 putimage(0,7,a[z]^,0);
 freemem(a[z],s); close(f);
end;

procedure spludge(x,y:integer; z:string);
var dx,dy:shortint;
begin;
 setcolor(15);
 for dx:=-1 to 1 do
  for dy:=-1 to 1 do
   outtextxy(x+dx,y+dy,z);
 setcolor(0);
 outtextxy(x,y,z);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 load;
 settextstyle(4,0,0); setusercharsize(2,1,1,1);
 plot('A',1);
 plot('B',2);
 plot('C',3);
(* rectangle(gd*80,7,56+gd*80,29); *)

 setfillstyle(1,1); setcolor(9);
 fillellipse( 97,104,6,4); fillellipse(321,104,6,4);
 fillellipse( 97,131,6,4); fillellipse(321,131,6,4);
 bar(97,100,321,134);
 bar(92,104,326,131);
 setfillstyle(1,9);
 bar(91,103, 91,131); bar(327,104,327,131);
 bar(98, 99,321, 99); bar( 97,135,321,135);

 settextstyle(2,0,0); setusercharsize(20,10,11,10);
 spludge( 99,100,'The Ancient Game of');
 settextstyle(1,0,0); setusercharsize(40,10,10,10);
 spludge( 99,105,'NIM');

 { now save it all! }

 assign(f,'c:\avalot\nim.avd');
 rewrite(f,1);
 blockwrite(f,header[1],length(header));
 for gd:=0 to 3 do
  for gm:=7 to 29 do
   for bit:=0 to 3 do
   begin;
    port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
    blockwrite(f,mem[$A000:gd*10+gm*80],7);
   end;
 for gm:=99 to 135 do
  for bit:=0 to 3 do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockwrite(f,mem[$A000:11+gm*80],30);
  end;
 close(f);
end.