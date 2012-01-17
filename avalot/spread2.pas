program spread2;
uses Graph,Crt,Squeak;
{$V-,R+}

const
 pattern = 12; { Pattern for transparencies. }
 Grey50 : FillPatternType = ($AA, $55, $AA,
  $55, $AA, $55, $AA, $55);

type
 adxtype = record
            name:string[12]; { name of character }
            comment:string[16]; { comment }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
            accinum:byte; { the number according to Acci (1=Avvy, etc.) }
           end;

var
 sf:file;
 a:adxtype;
 r:char;
 adxmodi,picmodi:boolean;
 mani:array[5..2053] of byte;
 sil:array[0..99,0..10] of byte;
 aa:array[1..16000] of byte;
 soa:word;
 xw:byte;
 leftc,rightc:byte;
 lmo:boolean;
 clip:array[1..2] of pointer;
 clipx,clipy:integer;
 boardfull:boolean;
 xofs,yofs:integer; { Distance of TL corner of cut from TL corner of pic. }

 bigpix_size,bigpix_gap:byte; { Size & gap betwixt big pixels. }

procedure setup;
const shouldid = -1317732048;
var
 ok:boolean;
 id:longint;
 sn:string[2];
begin;
 writeln('Sprite Editor 2 (c) 1993, Thomas Thurman.');
 bigpix_size:=3; bigpix_gap:=5;
 repeat
  ok:=true;
  write('Number of sprite?'); readln(sn);
  assign(sf,'v:\sprite'+sn+'.avd');
  reset(sf,1);
  seek(sf,177);
  blockread(sf,id,4);
  if id<>shouldid then
  begin;
   writeln('That isn''t a valid Trip5 spritefile.');
   writeln('Please choose another.');
   writeln;
   ok:=false; close(sf);
  end else
  begin;
   blockread(sf,soa,2);
   if soa<>sizeof(a) then { to change this, just change the "type adx=" bit.}
   begin;
    writeln('That spritefile contains an unknown ADX field type.');
    writeln('Please choose another.');
    writeln;
    ok:=false; close(sf);
   end;
  end;
 until ok;
 blockread(sf,a,soa);
 writeln(filepos(sf));
 adxmodi:=false; picmodi:=false;
 getmem(clip[1],a.size); getmem(clip[2],a.size); boardfull:=false;
end;

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure centre(y:byte; z:string);
begin;
 gotoxy(40-length(z) div 2,y); write(z);
end;

procedure info(x,y:byte; p,q:string);
begin;
 gotoxy(x,y);
 textattr:=6;  write(p+':ú');
 textattr:=11; write(q);
 textattr:=8; write('ú');
end;

procedure colours(f,b:byte);
begin;
 gotoxy(35,11);
 textattr:=6;
 write('Bubbles');
 textattr:=b*16+f;
 write(' like this! ');
end;

procedure adxinfo;
begin;
 with a do
 begin;
  info( 5, 8,'Name',name);
  info(35, 8,'Comment',comment);
  info( 5, 9,'Width',strf(xl));
  info(15, 9,'Height',strf(yl));
  info(35, 9,'Size of one pic',strf(size));
  info( 5,10,'Number in a stride',strf(seq));
  info(35,10,'Number of strides',strf(num div seq));
  info( 5,11,'Total number',strf(num));
  info( 5,12,'Acci number',strf(accinum));
  colours(fgc,bgc);
 end;
end;

procedure status;
begin;
 textattr:=7;
 clrscr;
 textattr:=10; centre(3,'Sprite Editor 2 (c) 1993, Thomas Thurman.');
 textattr:=6; gotoxy(3,7); write('ADX information:');
 adxinfo;
 textattr:=6;
 gotoxy(3,14); write('Options:');
 gotoxy(5,15); write('A) edit ADX information');
 gotoxy(5,16); write('P) edit pictures');
 gotoxy(5,17); write('S) save the ADX info (pics are saved automatically)');
end;

procedure enterstring(w:string; l:byte; var q:string);
var t:string;
begin;
 textattr:=13; clrscr;
 writeln;
 writeln('Press Return for no change, Space+Return for a blank.');
 repeat
  write('New value for ',w,' (max length ',l,')?');
  readln(t);
 until length(t)<=l;
 if t=' ' then q:='' else if t<>'' then q:=t;
 adxmodi:=true;
end;

procedure entercolour(w:string; var c:byte);
var fv:byte;
  procedure loseold; begin; write(#8+#255); end;
  procedure drawnew; begin; gotoxy(3+fv*5,11); write(#24); end;
begin;
 textattr:=13; clrscr;
 writeln; writeln('New value for ',w,'?');
 writeln('  Use '#26#27' to move about, Enter=OK, Esc=Cancel.');
 for fv:=1 to 15 do
 begin;
  gotoxy(3+fv*5,10); textattr:=fv; write('þ');
 end;
 fv:=c;
 repeat
  drawnew;
  r:=readkey;
  case r of
   #27: exit; { no change to c }
   #13: begin;
         c:=fv; adxmodi:=true;
         exit;
        end;
   #0: case readkey of
        'G': begin; loseold; fv:= 0; drawnew; end; { home }
        'O': begin; loseold; fv:=15; drawnew; end; { end }
        'K': if fv> 0 then begin; loseold; dec(fv); drawnew; end; { left }
        'M': if fv<15 then begin; loseold; inc(fv); drawnew; end; { right }
       end;
  end;
 until false;
end;

procedure enternum(w:string; var q:byte);
var t:string; e:integer; r:byte;
begin;
 textattr:=13; clrscr;
 writeln;
 writeln('Press Return for no change.');
 repeat
  write('New value for ',w,'?');
  readln(t);
  if t='' then exit; { No change... }
  val(t,r,e);
 until e=0;
 q:=r; { Update variable. }
 adxmodi:=true;
end;

procedure editadx;
var r:char;
begin;
 repeat
  clrscr;
  textattr:=10; centre(3,'ADX Editor:');
  textattr:= 9; centre(5,'N: Name, C: Comment, F: Foreground, B: Background, A: Accinum, X: eXit.');
  adxinfo;
  r:=upcase(readkey);
  case r of
   'N': enterstring('Name',12,a.name);
   'C': enterstring('Comment',16,a.comment);
   'F': entercolour('Foreground',a.fgc);
   'B': entercolour('Background',a.bgc);
   'A': enternum('Accinum',a.accinum);
   'X',#27: exit;
   else write(#7);
  end;
 until false;
end;

procedure saveit;
var
 pak:char;
 oldsoa:integer;
begin;
 textattr:=10; clrscr;
 centre(7,'Saving!');
 if adxmodi then
 begin;
  centre(10,'ADX information being saved...');
  seek(sf,181); { start of ADX info }
  soa:=sizeof(a);
  blockread(sf,oldsoa,2);
(*  if soa=oldsoa then
  begin;*)
   seek(sf,181);
   blockwrite(sf,soa,2);
   blockwrite(sf,a,soa);
   adxmodi:=false;
(*  end else write(#7);*)
 end else centre(10,'No changes were made to ADX...');
 centre(25,'Press any key...'); pak:=readkey;
end;

procedure quit;
begin;
 close(sf);
 halt;
end;

procedure getsilmani; { Reclaims original sil & mani arrays }
var x,y,z:byte; offs:word;
begin;

 { Sil... }

 getimage(500,150,500+a.xl,150+a.yl,aa);

 for x:=0 to 3 do
  for y:=0 to a.yl do
   for z:=0 to (a.xl div 8) do
   begin;
    offs:=5+y*xw*4+xw*x+z;
    sil[y,z]:=aa[offs];
   end;

 { ...Mani. }

 getimage(500,50,500+a.xl,50+a.yl,aa);

 move(aa[5],mani,sizeof(mani));

end;

procedure explode(which:byte); { 0 is the first one! }
 { Each character takes five-quarters of (a.size-6) on disk. }
var
 fv,ff:byte; so1:word; { size of one }
begin;
 with a do
 begin;
  so1:=size-6; inc(so1,so1 div 4);
  seek(sf,183+soa+so1*which); { First is at 221 }
(*  where:=filepos(sf);*)
  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);

  for fv:=0 to yl do
   blockread(sf,sil[fv],xw);
  blockread(sf,mani,size-6);
  aa[size-1]:=0; aa[size]:=0; { footer }
 end;
end;

procedure implode(which:byte); { Writes a pic back onto the disk }
var
 fv,ff:byte; so1:word; { size of one }
begin;
 with a do
 begin;

  getsilmani; { Restore original arrays }

  so1:=size-6; inc(so1,so1 div 4);
  seek(sf,183+soa+so1*which); { First is at 221 }

  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);

  for fv:=0 to yl do
   blockwrite(sf,sil[fv],xw);
  blockwrite(sf,mani,size-6);
  aa[size-1]:=0; aa[size]:=0; { footer }
 end;
end;

procedure plotat(xx,yy:integer); { Does NOT cameo the picture!}
begin;
 move(mani,aa[5],sizeof(mani));
 with a do
 begin;
  aa[1]:=xl; aa[2]:=0; aa[3]:=yl; aa[4]:=0; { set up x&y codes }
 end;
 putimage(xx,yy,aa,0);
end;

procedure plotsil(xx,yy:integer); { Plots silhouette- rarely used }
var x,y,z:byte; offs:word;
begin;
 for x:=0 to 3 do
  for y:=0 to a.yl do
   for z:=0 to (a.xl div 8) do
   begin;
    offs:=5+y*xw*4+xw*x+z;
    aa[offs]:=sil[y,z];
   end;

 with a do
 begin;
  aa[1]:=xl; aa[2]:=0; aa[3]:=yl; aa[4]:=0; { set up x&y codes }
 end;

 putimage(xx,yy,aa,0);

end;

procedure style(x:byte);
begin;
 if x=16 then
  {setfillstyle(pattern,8)}setfillpattern(Grey50,8)
 else
  setfillstyle(1,x);
end;

procedure bigpixel(x,y:integer);
begin;
 if getpixel(500+x,150+y)=15 then
  {setfillstyle(pattern,8)}setfillpattern(Grey50,8)
 else
  setfillstyle(1,getpixel(500+x,50+y));

 bar(x*bigpix_gap,y*bigpix_gap,
  x*bigpix_gap+bigpix_size,y*bigpix_gap+bigpix_size);
end;

procedure subplot(y:byte; x:integer; c:char);
begin;
 setfillstyle(1,0); bar(x,0,x+9,170); outtextxy(x+5,y*10+5,c);
end;

procedure plotleft;  begin; subplot( leftc,239,#26); end; { palette arrows }
procedure plotright; begin; subplot(rightc,351,#27); end;

procedure plotbig(x,y,c:byte);
begin;
 style(c);
 bar(x*bigpix_gap,y*bigpix_gap,
   x*bigpix_gap+bigpix_size,y*bigpix_gap+bigpix_size);
 if c=16 then
 begin;
  putpixel(500+x,150+y,15);
  putpixel(500+x, 50+y,0);
 end else
 begin;
  putpixel(500+x,150+y,0);
  putpixel(500+x, 50+y,c);
 end;
end;

procedure changepic;
begin;
 mx:=mx div bigpix_gap; my:=my div bigpix_gap;
 with a do if (mx>xl) or (my>yl) then exit;
 if mkey=left then
  plotbig(mx,my,leftc) else
  plotbig(mx,my,rightc);
end;

procedure changecol;
begin;
 my:=my div 10; if my>16 then exit;
 if mkey=left then
 begin;
  leftc:=my; plotleft;
 end else
 begin;
  rightc:=my; plotright;
 end;
end;

procedure showcutpic;
begin;
 setfillstyle(5,1); bar(20,160,40+clipx,180+clipy);
 putimage(30,170,clip[2]^,andput);
 putimage(30,170,clip[1]^,xorput);
end;

procedure movesquare(var xc,yc:integer; xl,yl:integer);
var x2,y2:integer;
begin;
 repeat
  x2:=xl+xc; y2:=yl+yc;
  setcolor(15);
  repeat
   rectangle(xc*bigpix_gap-1,yc*bigpix_gap-1,
    x2*(bigpix_gap+1)-1,y2*(bigpix_gap+1)-1);
  until keypressed;
  setcolor(0); rectangle(xc*bigpix_gap-1,yc*bigpix_gap-1,
   x2*(bigpix_gap+1)-1,y2*(bigpix_gap+1)-1);
  case readkey of
   #0: case readkey of
        #72: dec(yc);
        #75: dec(xc);
        #77: inc(xc);
        #80: inc(yc);
       end;
   #13: exit;
  end;
  while (xl+xc)>a.xl do dec(xc);
  while (yl+yc)>a.yl do dec(yc);
  if xc<0 then xc:=0;
  if yc<0 then yc:=0;
 until false;
end;

procedure switch(var v1,v2:integer);
 { Swaps over the values of v1 and v2. }
var temp:integer;
begin;
 temp:=v1; v1:=v2; v2:=temp;
end;

procedure choosesquare(var x1,y1,x2,y2:integer);
var TL:boolean;
begin;
 repeat
  setcolor(15);
  repeat
   rectangle(x1*bigpix_gap-1,y1*bigpix_gap-1,
    (x2+1)*bigpix_gap-1,(y2+1)*bigpix_gap-1);
  until keypressed;
  setcolor(0);
  rectangle(x1*bigpix_gap-1,y1*bigpix_gap-1,
   (x2+1)*bigpix_gap-1,(y2+1)*bigpix_gap-1);
  case readkey of
   #0: case readkey of
        #72: if TL then dec(y1) else dec(y2);
        #75: if TL then dec(x1) else dec(x2);
        #77: if TL then inc(x1) else inc(x2);
        #80: if TL then inc(y1) else inc(y2);
       end;
   #9: TL:=not TL;
   #13: begin;
         if x1>x2 then switch(x1,x2); { Get the square the right way up. }
         if y1>y2 then switch(y1,y2);
         dec(y2,y1); dec(x2,x1); { y1 & y2 have to be the OFFSETS! }
         exit;
        end;
  end;
  if x1<0 then x1:=0; if y1<0 then y1:=0;
  with a do
  begin;
   if y2>yl then y2:=yl; if x2>xl then x2:=xl;
  end;
 until false;
end;

procedure paste;
var x,y:byte;
begin;
 if not boardfull then
 begin;
  write(#7);
  exit;
 end;
 with a do
  if not ((clipx=xl) and (clipy=yl)) then
   movesquare(xofs,yofs,clipx,clipy);
 putimage(500+xofs, 50+yofs,clip[1]^,0);
 putimage(500+xofs,150+yofs,clip[2]^,0);
 for x:=0 to a.xl do
  for y:=0 to a.yl do
  begin;
   bigpixel(x,y);
  end;
end;

procedure cut;
begin;
 xofs:=0; yofs:=0; { From the TL. }
 with a do
 begin;
  getimage(500, 50,500+xl, 50+yl,clip[1]^);
  getimage(500,150,500+xl,150+yl,clip[2]^);
  clipx:=xl; clipy:=yl;
 end;
 showcutpic;
 boardfull:=true;
end;

procedure cutsome;
begin;
 with a do
 begin;
  choosesquare(xofs,yofs,clipx,clipy);
  getimage(500+xofs, 50+yofs,500+xofs+clipx, 50+yofs+clipy,clip[1]^);
  getimage(500+xofs,150+yofs,500+xofs+clipx,150+yofs+clipy,clip[2]^);
 end;
 showcutpic;
 boardfull:=true;
end;

function confirm(c:char; x:string):boolean;
var col:byte; groi:char;
begin;
 while keypressed do groi:=readkey;
 x:=x+'? '+c+' to confirm.';
 col:=1;
 repeat
  setcolor(col); outtextxy(555,5,x);
  inc(col); if col=16 then col:=1;
 until keypressed;
 confirm:=upcase(readkey)=c;
 setfillstyle(1,0); bar(470,0,640,10);
end;

procedure checkbutton(which:byte);
begin;
 my:=(my-12) div 25;
 case my of
  0: if confirm('S','Save') then begin; implode(which); lmo:=true; end;
  1: if confirm('C','Cancel') then lmo:=true;
  4: cut;
  5: if confirm('P','Paste') then paste;
  6: cutsome;
 end;
end;

procedure animate;
begin;
end;

procedure undo;
begin;
end;

procedure flipLR; { Flips left-to-right. }
var fv,ff:integer;
 procedure flipline(x1,x2,y:integer);
 var fv,ff:integer;
 begin;
  for fv:=x1 to x2 do putpixel(fv,0,getpixel(fv,y));
  ff:=x2;
  for fv:=x1 to x2 do
  begin;
   putpixel(fv,y,getpixel(ff,0));
   dec(ff);
  end;
 end;
begin;
 with a do
  for fv:=0 to yl do
  begin;
   flipline(500,500+xl, 50+fv);
   flipline(500,500+xl,150+fv);
  end;
 for fv:=0 to a.xl do
  for ff:=0 to a.yl do
   bigpixel(fv,ff);
end;

procedure change_colours; { Swaps one colour with another. }
var fv,ff:byte;
begin;

 if (leftc=16) or (rightc=16) then { See-through can't be one of the colours. }
 begin;
  write(#7); { Bleep! }
  exit;
 end;

 with a do
  for fv:=0 to yl do
   for ff:=0 to xl do
    if getpixel(500+ff,50+fv)=leftc
     then putpixel(500+ff,50+fv,rightc);

 for fv:=0 to a.xl do
  for ff:=0 to a.yl do
   bigpixel(fv,ff);
end;

procedure redraw;
var x,y:byte;
begin;
 setfillstyle(1,0);
 bar(0,0,250,200);

 for x:=0 to a.xl do
  for y:=0 to a.yl do
  begin;
   bigpixel(x,y);
  end;
end;

procedure parse(c:char); { Parses keystrokes }
begin;
 case upcase(c) of
  ^V,'P': paste;
  ^C,'C': cut;
  ^X,'X': cutsome;
  'A': animate;
  'U': undo;
  '@': flipLR;
  '!': change_colours;
  '<': if bigpix_size>1 then
       begin;
        dec(bigpix_size); dec(bigpix_gap);
        redraw;
       end;
  '>': if bigpix_size<8 then
       begin;
        inc(bigpix_size); inc(bigpix_gap);
        redraw;
       end;
  #27: if confirm('X','Exit') then lmo:=true;
 end;
end;

procedure editone(which:byte);
var x,y:byte;
begin;
 cleardevice;
 explode(which);
 plotat(500,50);
 plotsil(500,150);
 for x:=0 to a.xl do
  for y:=0 to a.yl do
  begin;
   bigpixel(x,y);
  end;
 for y:=0 to 16 do
 begin;
  style(y);
  bar(251,y*10+1,349,y*10+9);
  rectangle(250,y*10,350,y*10+10);
 end;

 settextstyle(0,0,1); leftc:=15; rightc:=16; plotleft; plotright; lmo:=false;

 outtextxy(410, 25,'Save');
 outtextxy(410, 50,'Cancel');
 outtextxy(410, 75,'Animate');
 outtextxy(410,100,'Undo');
 outtextxy(410,125,'Cut');
 outtextxy(410,150,'Paste');
 outtextxy(410,175,'X: Cut Some');
 if boardfull then showcutpic;
 setfillstyle(6,15);
 for y:=0 to 7 do
  bar(370,y*25+12,450,y*25+12);

 repeat
  on;
  repeat
   if keypressed then parse(readkey);
  until anyo or lmo;
  off;

  if not lmo then
  begin;
   getbuttonstatus;

   case mx of
      1..249: changepic;
    250..350: changecol;
    370..450: checkbutton(which);
   end;
  end;
 until lmo;
 settextstyle(2,0,7); setcolor(15);
end;

procedure editstride(which:byte);
var
 whichc:char;
 first:shortint;
 r:char;
  procedure drawup;
  var fv:byte;
  begin;
   whichc:=chr(which+48);
   cleardevice;
   outtextxy(320,10,'Edit stride '+whichc);
   first:=(which-1)*a.seq-1;
   for fv:=1 to a.seq do
   begin;
    explode(fv+first);
    plotat(fv*73,77);
    outtextxy(17+fv*73,64,chr(fv+48));
   end;
   outtextxy(320,177,'Which?');
  end;
begin;
 drawup;
 repeat
  r:=readkey;
  if (r>'0') and (r<=chr(a.seq+48)) then
  begin;
   editone(ord(r)-48+first);
   drawup;
  end;
 until r=#27;
end;

procedure editpics;
var
 nds:byte; { num div seq }
 r:char; which:byte; e:integer;
  procedure drawup;
  var fv:byte;
  begin;
   setgraphmode(0); directvideo:=false; settextjustify(1,1);
   with a do nds:=num div seq;
   settextstyle(2,0,7);
   outtextxy(320,10,'Edit pictures...');
   outtextxy(320,40,'(Usually, 1=away, 2=right, 3=towards, 4=left.)');
   for fv:=1 to nds do
   begin;
    explode((fv-1)*a.seq);
    plotat(fv*73,100);
    outtextxy(17+fv*73,87,chr(fv+48));
   end;
   outtextxy(320,60,'There are '+strf(nds)+' strides available.');
   outtextxy(320,177,'Which do you want?');
  end;
begin;
 drawup;
 repeat
  r:=readkey;
  if (r>'0') and (r<=chr(nds+48)) then
  begin;
   editstride(ord(r)-48);
   drawup;
  end;
  until r=#27;
 restorecrtmode;
end;

procedure titles;
var
 gd,gm:integer;
 pak:char; wait:word;
begin;
 gd:=3; gm:=1; initgraph(gd,gm,'c:\bp\bgi');
 settextstyle(5,0,10); settextjustify(1,1);
 gm:=getmaxy div 2; wait:=0;
 repeat
  for gm:=0 to 15 do
  begin;
   setcolor(15-gm);
   for gd:=0 to (150-gm*10) do
   begin;
    outtextxy(320,124-gd,'Spread 2');
    outtextxy(320,125+gd,'Spread 2');
    if (gd=5) and (gm=0) then wait:=2345;
    if (gd=6) and (gm=0) then wait:=0;
    repeat
     if keypressed then
     begin;
      while keypressed do pak:=readkey;
      restorecrtmode;
      exit;
     end;
     if wait>0 then begin; dec(wait); delay(1); end;
    until wait=0;
   end;
  end;
 until false;
end;

begin;
 titles;
 setup;
 repeat
  status;
  r:=upcase(readkey);
  case r of
   'A': editadx;
   'P': editpics;
   'S': saveit;
   'X',#27: quit;
  end;
 until false;
end.