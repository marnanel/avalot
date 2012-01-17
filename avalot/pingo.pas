{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 PINGO            Full-screen sub-parts of the game. }

unit Pingo;

interface

procedure bosskey;

procedure copy02;

procedure copy03;

procedure copypage(frp,top:byte);

procedure wobble;

procedure zonk;

procedure winning_pic;

implementation

uses Graph,Gyro,Lucerna,Crt,Trip5,Scrolls;

procedure dplot(x,y:integer; z:string);
begin;
 setcolor( 9); outtextxy(x,y  ,z);
 setcolor(11); outtextxy(x,y-1,z);
end;

procedure bosskey;
(*const
 months : array[0..11] of char = 'JFMAMJJASOND';
 title = 'Net Profits';
 fish = #224; { à }
var fv:byte; gd,gm:integer; r:char;
begin;
 dusk; delavvy;
 setactivepage(3); mousepage(3); setvisualpage(3); off;
 cleardevice; setfillstyle(xhatchfill,11);
 settextstyle(1,0,4); settextjustify(1,1);
 dplot(320,10,title);
 settextstyle(1,0,0); setusercharsize(4,3,7,12);
 for fv:=0 to 11 do
 begin;
  dplot(26+fv*52,187,months[fv]);
  bar(fv*52,177-fv*14,51+fv*52,180);
  rectangle(fv*52,177-fv*14,51+fv*52,180);
 end;
 settextstyle(0,0,1);
 for fv:=1 to 177 do
 begin;
  gd:=random(630); gm:=random(160)+30;
  setcolor(lightred); outtextxy(gd  ,gm  ,fish);
  setcolor(yellow);   outtextxy(gd+1,gm-1,fish);
 end;
 newpointer(6); { TTHand }
 dawn; on; setbkcolor(1); repeat check until (mpress>0) or keypressed;
 while keypressed do r:=readkey; setbkcolor(0); settextjustify(0,0);
 dusk; setvisualpage(0); setactivepage(0); mousepage(0); dawn;
 copy02;*)
var fv:byte;
begin;
 dusk;
 off_virtual;
 for fv:=0 to 1 do
 begin;
  setactivepage(fv);
  cleardevice;
 end;
 load(98); off;
 setactivepage(1); setvisualpage(1);
 settextjustify(1,0); setcolor(8);
 outtextxy(320,177,'Graph/Histo/Draw/Sample: "JANJUN93.GRA": (W3-AB3)');
 outtextxy(320,190,'Press any key or click the mouse to return.');
 settextjustify(2,0);
 on; mousepage(1); newpointer(1); dawn;
 repeat check until (mpress>0) or keypressed;
 off; on_virtual;
 major_redraw;

 mousepage(cp);
end;

procedure copy02; { taken from Wobble (below) }
var a0:byte absolute $A000:0; a2:byte absolute $A800:0; bit:byte;
begin;
 off;
 for bit:=0 to 3 do begin;
  port[$3C4]:=2; port[$3CE]:=4;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(a0,a2,16000);
 end; on;
end;

procedure copy03; { taken from Wobble (below) }
var a0:byte absolute $A000:0; a2:byte absolute $AC00:0; bit:byte;
 squeaky_code:byte;
begin
   case Visible of
      M_Virtual : begin squeaky_code := 1; off_virtual; end;
      M_No      :       squeaky_code := 2;
      M_Yes     : begin squeaky_code := 3; off;         end;
   end;

 for bit:=0 to 3 do begin;
  port[$3C4]:=2; port[$3CE]:=4;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(a0,a2,16000);
 end;

 case squeaky_code of
   1 : on_virtual;
   2 : ; { zzzz, it was off anyway }
   3 : on;
 end;

end;

procedure copypage(frp,top:byte); { taken from Copy02 (above) }
var
 bit:byte;
begin;
 off;
 for bit:=0 to 3 do begin;
  port[$3C4]:=2; port[$3CE]:=4;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(mem[$A000:frp*pagetop],mem[$A000:top*pagetop],16000);
 end; on;
end;

procedure wobble;
var
 bit:byte;
 a2:byte absolute $A800:80;
begin;
 off;
 setactivepage(2); bit:=getpixel(0,0);
 cleardevice;
 for bit:=0 to 3 do begin;
  port[$3C4]:=2; port[$3CE]:=4;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(mem[$A000:cp*pagetop],a2,16000);
 end;
 for bit:=0 to 25 do
 begin;
  setvisualpage(2);  delay(bit*7);
  setvisualpage(cp); delay(bit*7);
 end;
 bit:=getpixel(0,0);
 draw_also_lines;
 setactivepage(1-cp); on;
end;

procedure zonk;
var
 xx,yy:integer;
(* a0:byte absolute $A000:0; a3:byte absolute $A000:245760;*) bit,fv:byte;
  procedure zl(x1,y1,x2,y2:integer);
  begin;
   setlinestyle(0,0,3); setcolor( 1); line(x1,y1,x2,y2);
   setlinestyle(0,0,1); setcolor(11); line(x1,y1,x2,y2);
  end;
begin;
 off;
 copypage(3,1-cp);
 with tr[1] do
 begin; xx:=x+a.xl div 2; yy:=y; end;

 setactivepage(3); cleardevice;
(* for bit:=0 to 3 do begin;
  port[$3C4]:=2; port[$3CE]:=4;
  port[$3C5]:=1 shl bit;
  port[$3CF]:=bit;
  move(a0,a3,16000);
 end;*)
 copypage(cp,3); off;
 zl(640,0,0,yy div 4);
 zl(0,yy div 4,640,yy div 2);
 zl(640,yy div 2,xx,yy); setbkcolor(yellow);

 for bit:=0 to 255 do
 begin;
  note(270-bit); setvisualpage(3);
  note(2700-10*bit); delay(5); nosound;
  note(270-bit); setvisualpage(cp);
  note(2700-10*bit); delay(5); nosound;
 end; setactivepage(0); setbkcolor(black); on; state(2);
 copypage(1-cp,3);
end;

procedure winning_pic;
var
 bit:byte;
 f:file;
 r:char;
begin
 dusk;

 assign(f,'finale.avd');
 reset(f,1);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4;
  port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,mem[$A000:0],16000);
 end;
 close(f); blitfix;

 setvisualpage(0);

 dawn;

 repeat check until keypressed or (mrelease>0);
 while keypressed do r:=readkey;
 major_redraw;
end;

end.