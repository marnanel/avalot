program ss_clock;
uses Dos,Crt,Graph,Drivers;

const
 width = 88;
 height = 8; { width & height of string returned by "time" }

var
 gd,gm:integer;
 xx,yy:integer;
 ix,iy:shortint;
 cp:byte;
 count:byte;
 pages:array[0..1] of pointtype;
 test:boolean;

function the_cows_come_home:boolean;
var rmove,rclick:registers;
begin;
 rmove.ax:=11; intr($33,rmove);
 rclick.ax:=3; intr($33,rclick);
 the_cows_come_home:=
   (keypressed) or { key pressed }
   (rmove.cx>0) or { mouse moved }
   (rmove.dx>0) or
   (rclick.bx>0);  { button clicked }
end;

function time:string;
var h,m,s,s1:word; hh,mm,ss:string[2]; ampm:char;
begin;
 gettime(h,m,s,s1);
 if h<12 then
  ampm:='a'
 else begin;
  ampm:='p';
  if h=0 then h:=12 else dec(h,12); { 24-hr adjustment }
 end;
 str(h:2,hh); str(m:2,mm); str(s:2,ss); { stringify them }
 time:=hh+'.'+mm+'.'+ss+' '+ampm+'m';
end;

begin;
 test:=the_cows_come_home;
 gm:=registerbgidriver(@egavgadriverproc);
 gd:=3; gm:=1; initgraph(gd,gm,'');
 ix:=3; iy:=1; xx:=177; yy:=177; setcolor(11); cp:=0;
 setfillstyle(1,0); count:=2;
 repeat
  setactivepage(cp); setvisualpage(1-cp); cp:=1-cp;
  delay(20); if count>0 then dec(count);
  with pages[cp] do
  begin;
   if count=0 then
    bar(x,y,x+width,y+height);
   x:=xx; y:=yy; { update record for next time }
  end;
  outtextxy(xx,yy,time);
  xx:=xx+ix; yy:=yy+iy;
  if xx<= 10 then ix:=random(9)+1; if xx>=629-width  then ix:=-random(9)+1;
  if yy<= 10 then iy:=random(9)+1; if yy>=339-height then iy:=-random(9)+1;
 until the_cows_come_home;
 closegraph;
 textattr:=30; clrscr;
 writeln('*** Bouncing Clock *** (c) 1992, Thomas Thurman. (An Avvy Screen Saver.)');
 for gd:=1 to 48 do write('~'); writeln;
 writeln('This program may be freely copied.');
 writeln;
 writeln('Have fun!');
end.