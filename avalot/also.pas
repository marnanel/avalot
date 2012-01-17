program Also;
uses Graph,Rodent,Crt;
{$R+,V-}

type
 fonttype = array[0..255,0..15] of byte;

 fieldtype = object
              x1,y1,x2,y2:integer;
             end;

 linetype = object(fieldtype)
             col:byte;
            end;

 pedtype = record
            x,y:integer; dir:byte;
           end;

 magictype = record
              op:byte; { one of the operations }
              data:word; { data for them }
             end;

const
 numlines=50; up = 0; right = 1; down = 2; left = 3; ur=4; dr=5; dl=6; ul=7;
 still = 8;

 nay = maxint;

 { Magic commands are }

 {N} nix = 0; { ignore it if this line is touched }
 {B} bounce = 1; { bounce off this line }
 {E} exclaim = 2; { put up a chain of scrolls }
 {T} transport = 3; { enter new room }
 {U} unfinished = 4; { unfinished connection }
 {S} special= 5; { special call }
 {O} opendoor = 6; { slowly opening door. }

var
 gd,gm:integer;
 lines:array[1..numlines] of linetype;
 fields:array[1..numlines] of fieldtype;
 do1:boolean;
 current:byte;
 n:string;
 names:array[0..29,1..2] of string;
 f:file of fonttype;
 skinny:fonttype;
 tx,ty:byte;
 chars:array[0..79,0..22] of char;
 cursorflash:byte;
 peds:array[1..15] of pedtype;
 magics:array[1..15] of magictype;
 portals:array[9..15] of magictype;
 flags:string[26];
 listen:string;

const
 crosshairs : graphcursmasktype =
 ( Mask:
     ((63551,63807,63807,63807,61727,257,897,32765,897,257,61727,63807,63807,63807,63551,65535),
      (4368,21140,8840,53910,640,640,31868,33026,31868,640,640,53910,8840,21140,4368,0));
   Horzhotspot: 7;
   Verthotspot: 7);

 hook : graphcursmasktype =
 ( Mask:
     ((32831,32831,49279,49279,57599,61695,61471,61447,63491,57089,36801,32771,49159,57375,63743,65535),
      (0,16256,7936,7936,3584,1536,1792,2016,248,28,8220,12344,8160,1792,0,0));
   Horzhotspot: 2;
   Verthotspot: 9);

 tthand : graphcursmasktype =
 ( Mask:
     ((62463,57855,57855,57855,57471,49167,32769,0,0,0,0,32768,49152,57344,61441,61443),
      (3072,4608,4608,4608,4992,12912,21070,36937,36873,36865,32769,16385,8193,4097,2050,4092));
   Horzhotspot: 4;
   Verthotspot: 0);

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure glimpse(ret:byte); { glimpse of screen 3 }
var sink:char;
begin;
 hidemousecursor; setvisualpage(3); setcrtpagenumber(3); showmousecursor;
 repeat until not anymousekeypressed;
 repeat until anymousekeypressed;
 hidemousecursor; setvisualpage(ret); setcrtpagenumber(ret); showmousecursor;
 while keypressed do sink:=readkey;
end;

procedure newline(t:byte; p,q,r,s:integer; c:byte);
begin;
 with lines[t] do
 begin;
  x1:=p; y1:=q; x2:=r; y2:=s; col:=c;
 end;
end;

procedure newfield(t:byte; p,q,r,s:integer);
begin; with fields[t] do begin; x1:=p; y1:=q; x2:=r; y2:=s; end; end;

procedure drawped(p:byte);
begin;
 with peds[p] do
  if dir<177 then
  begin;
   setcolor(p); circle(x,y,5); moveto(x,y);
   case dir of
    up:   linerel(0,-5);  down:  linerel(0,5);
    left: linerel(-7,0);  right: linerel(7,0);
    ul:   linerel(-7,-5); dl:    linerel(-7, 5);
    ur:   linerel( 7,-5); dr:    linerel( 7, 5);
   end;
  end;
end;

procedure drawup;
var fv:byte;
begin;
 cleardevice;
 for fv:=1 to numlines do
  with lines[fv] do
   if x1<>nay then
   begin;
    setcolor(col);
    line(x1,y1,x2,y2);
   end;
 for fv:=1 to numlines do
  with fields[fv] do
   if x1<>nay then
   begin;
    setcolor(fv);
    rectangle(x1,y1,x2,y2);
   end;
 for fv:=1 to 15 do drawped(fv);
end;

procedure addped;
var n,fv:byte;
begin;
 n:=0; repeat inc(n) until (n=16) or (peds[n].dir=177);
 setcrtpagenumber(0); setactivepage(0); setvisualpage(0);
 drawup; setgraphicscursor(tthand); showmousecursor;
 repeat
  if rightmousekeypressed then exit;
  if keypressed then glimpse(0);
 until leftmousekeypressed;
 hidemousecursor;
 with peds[n] do
 begin;
  x:=mousex; y:=mousey;
 end;
 cleardevice; setfillstyle(6,9); for fv:=1 to 3 do bar(200*fv,0,200*fv,200);
 for fv:=1 to 2 do bar(0,60*fv,640,60*fv);
 showmousecursor;
 repeat if rightmousekeypressed then exit; until leftmousekeypressed;
 hidemousecursor;
 with peds[n] do
  case ((mousex div 200)*10)+(mousey div 60) of
   00: dir:=ul;   10: dir:=up;    20: dir:=ur;
   01: dir:=left; 11: dir:=still; 21: dir:=right;
   02: dir:=dl;   12: dir:=down;  22: dir:=dr;
  end;
end;

procedure addline(ccc:byte);
var fv:byte;
begin;
 repeat
  for fv:=1 to numlines do
   with lines[fv] do
    if x1=nay then
    begin;
     x1:=fv*17; x2:=x1; y1:=200; y2:=190; col:=ccc;
     exit; { bad style! }
    end;
 until false;
end;

function colour:byte;
var fv:byte;
begin;
 setactivepage(0); setvisualpage(0); setcrtpagenumber(0);
 outtextxy(0,0,'Select a colour, please...');
 for fv:=1 to 15 do
 begin;
  setfillstyle(1,fv);
  bar(fv*40,27,39+fv*40,200);
 end;
 showmousecursor;
 repeat
  if rightmousekeypressed then begin; hidemousecursor; exit; end;
  if keypressed then glimpse(2);
 until leftmousekeypressed;
 hidemousecursor;
 colour:=getpixel(mousex,mousey); cleardevice;
end;

procedure addfield;
var fv:byte; ok:boolean;
begin;
 repeat
  fv:=colour;
  ok:=fields[fv].x1=nay;
  if not ok then write(#7);
 until ok;
 with fields[fv] do
 begin;
  x1:=300+fv*17; x2:=x1+1; y1:=200; y2:=177;
 end;
end;

function checkline:byte;
var fv,ans:byte;
begin;
 setgraphicscursor(crosshairs);
 setcrtpagenumber(0); setactivepage(0); setvisualpage(0); drawup;
 repeat
  showmousecursor;
  repeat
   if rightmousekeypressed then begin; checkline:=255; exit; end;
   if keypressed then glimpse(0);
  until leftmousekeypressed;
  hidemousecursor;
  setactivepage(1); ans:=177;
  for fv:=1 to numlines do {  }
  begin;
   with lines[fv] do
    if x1<>nay then
    begin;
     setcolor( 9); line(x1,y1,x2,y2);
     if getpixel(mousex,mousey)=9 then ans:=fv;
     setcolor( 0); line(x1,y1,x2,y2);
    end;
   with fields[fv] do
    if x1<>nay then
    begin;
     setcolor( 9); rectangle(x1,y1,x2,y2);
     if getpixel(mousex,mousey)=9 then ans:=fv+100;
     setcolor( 0); rectangle(x1,y1,x2,y2);
    end;
  end;
  setactivepage(0);
 until ans<>177;
 checkline:=ans;
end;

procedure chooseside;
var clicol,savelcol:byte; itsaline:boolean; current:fieldtype; temp:integer;
  procedure plotline;
  begin;
   if itsaline then
    with lines[gd] do
     if do1 then line(mousex,mousey,x2,y2) else
      line(x1,y1,mousex,mousey)
   else
    with fields[gd] do
     if do1 then rectangle(mousex,mousey,x2,y2) else
      rectangle(x1,y1,mousex,mousey);
end;
begin;
 repeat
  gd:=checkline; itsaline:=gd<100;
  if gd=255 then begin; hidemousecursor; exit; end;
  if not itsaline then dec(gd,100);
  setactivepage(2); setvisualpage(2); cleardevice;
  setgraphicscursor(tthand); setcrtpagenumber(2);
  if itsaline then
  begin;
   current:=lines[gd];
   savelcol:=lines[gd].col;
  end else current:=fields[gd];
  with current do
  begin;
   setcolor(9);
   if itsaline then line(x1,y1,x2,y2) else rectangle(x1,y1,x2,y2);
    setcolor(9);
    setfillstyle(1,red);   bar(x1-3,y1-3,x1+3,y1+3);
    setfillstyle(1,green); bar(x2-3,y2-3,x2+3,y2+3);
   repeat until not anymousekeypressed;
   clicol:=177; showmousecursor;
  repeat
   if anymousekeypressed then
   begin;
    hidemousecursor;
    clicol:=getpixel(mousex,mousey);
    showmousecursor;
   end;
   if rightmousekeypressed then
    begin; hidemousecursor; exit; end;
   if keypressed then glimpse(2);
  until clicol in [red,green];
  do1:=clicol=red; hidemousecursor;
  setgraphicscursor(hook); setcrtpagenumber(0);
  setactivepage(0); setvisualpage(0); setcolor(0);
  if itsaline then
  with  lines[gd] do begin; line(x1,y1,x2,y2); setcolor(col); end else
  with fields[gd] do begin; rectangle(x1,y1,x2,y2); setcolor(gd); end;
  setwritemode(xorput);
  while not anymousekeypressed do
  begin;
   plotline;
   showmousecursor; delay(1); hidemousecursor;
   plotline;
   if rightmousekeypressed then begin; hidemousecursor; exit; end;
   if keypressed then glimpse(0);
  end;
  { update "current" rec }
  if do1 then begin; x1:=mousex; y1:=mousey; end
   else begin; x2:=mousex; y2:=mousey; end;
  if not itsaline then
  begin;
   if x1>x2 then begin; temp:=x2; x2:=x1; x1:=temp; end;
   if y1>y2 then begin; temp:=y2; y2:=y1; y1:=temp; end;
  end;
  { copy "current" to line/field }
  if itsaline then
   with lines[gd] do
   begin;
    x1:=current.x1; x2:=current.x2; y1:=current.y1; y2:=current.y2;
    col:=savelcol;
   end else fields[gd]:=current;
 end;
 setwritemode(0);
 until false;
end;

procedure delped;
begin;
 setcrtpagenumber(0); setactivepage(0); setvisualpage(0);
 drawup; setgraphicscursor(tthand); showmousecursor;
 repeat until leftmousekeypressed; peds[colour].dir:=177;
end;

function menu:byte;
var clicol:byte;
  procedure say(y:byte; x:string);
  begin;
   setfillstyle(1,y);
   bar(0,y*17,100,y*17+15); outtextxy(123,y*17,x);
  end;
begin;
  setcolor(15); settextstyle(0,0,2); clicol:=0; setgraphicscursor(tthand);
  setvisualpage(2); setactivepage(2); setcrtpagenumber(2); cleardevice;
  say(3,'Move lines around');
  say(4,'Add a new line');
  say(5,'Delete a line');
  say(6,'Add a ped');
  say(7,'Delete a ped');
  say(8,'Add a field');
  say(10,'Return to Also.');
  showmousecursor;
  repeat
   if leftmousekeypressed then
   begin;
    hidemousecursor;
    clicol:=getpixel(mousex,mousey);
    showmousecursor;
   end;
   if rightmousekeypressed then begin; hidemousecursor; exit; end;
   if keypressed then glimpse(2);
  until clicol>0;
  repeat until not anymousekeypressed;
  hidemousecursor;
  menu:=clicol;
end;

procedure removeline;
begin;
 gd:=checkline; if gd=255 then begin; hidemousecursor; exit; end;
 if gd>100 then
  fields[gd-100].x1:=nay
 else lines[gd].x1:=nay; { cancels it out }
 cleardevice; drawup;
end;

procedure lino;
begin;
 resetmouse;
 repeat
  case menu of
   3: chooseside;
   4: addline(colour);
   5: removeline;
   6: addped;
   7: delped;
   8: addfield;
  10: exit;
  end;
 until false;
end;

procedure loadscreen; { load2 }
var
 a:byte absolute $A000:246560;
 bit:byte;
 f:file;
begin;
 setactivepage(3); setvisualpage(3);
 assign(f,'c:\avalot\place'+n+'.avd'); reset(f,1); seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12080);
 end;
 close(f);
 setvisualpage(0);
 outtextxy(0,190,'Look carefully, and then press any key...');
 setactivepage(0);
end;

procedure ctrlsout(var x:string); { Replace real ctrls with caret codes }
var fv:byte; xx:string;
begin;
 xx:='';
 for fv:=1 to length(x) do
  if x[fv]>#31 then xx:=xx+x[fv] else xx:=xx+'^'+chr(ord(x[fv])+64);
 x:=xx;
end;

procedure ctrlsin(var x:string); { Opposite of ctrlsout }
var fv:byte; xx:string; ctrlwas:boolean;
begin;
 xx:=''; ctrlwas:=false;
 for fv:=1 to length(x) do
  if ctrlwas then { last char was a caret }
   begin;
    xx:=xx+chr(ord(upcase(x[fv]))-64);
    ctrlwas:=false;
   end
  else
  begin; { last char wasn't a caret... }
   if x[fv]='^' then ctrlwas:=true else { ...but this one is }
    xx:=xx+x[fv]; { ...but this one isn't }
  end;
 x:=xx;
end;

procedure flipover; { temp view other screen }
var r:char;
begin;
 setvisualpage(3); r:=readkey; setvisualpage(0);
end;

procedure plotchar(x,y:byte; n:char);
var fv:byte;
begin;
 if chars[x,y]=n then exit;
 for fv:=0 to 15 do
  mem[$A000:y*1200+(fv+3)*80+x]:=skinny[ord(n),fv];
 chars[x,y]:=n;
end;

procedure cursor;
var fv:byte;
begin;
 inc(cursorflash);
 case cursorflash of
  1,127: for fv:=12 to 14 do
          mem[$A000:ty*1200+(3+fv)*80+tx]:=not(mem[$A000:ty*1200+(3+fv)*80+tx]);
  255: cursorflash:=0;
 end;
end;

procedure losecursor;
begin;
 if cursorflash<127 then begin; cursorflash:=126; cursor; end;
 cursorflash:=0;
end;

procedure gwrite(x:string);
var fv:byte;
begin;
 for fv:=1 to length(x) do
 begin;
  plotchar(tx,ty,x[fv]);
  inc(tx);
  if tx=80 then begin; inc(ty); tx:=0; end;
 end;
end;

function typein(x:string):string;
const marker = #2;
var p:byte; r:char;
begin;
 setvisualpage(0); setactivepage(0); cleardevice;
 settextstyle(0,0,1); setcolor(15);
 outtextxy( 0,  0,'Press TAB to see the room...');
 outtextxy( 0, 20,'You may use any of these Control Codes:');
 outtextxy(30, 30,'Anywhere: ^M = new line, ^P = new scroll, |1 fix to speaker 1.');
 outtextxy(90, 40,'^B = new bubble');
 outtextxy(30, 50,'At end of line: ^C = centre line, ^L = left justify.');
 outtextxy(30, 60,'At end of scroll: ^D = Don''t add automatic ^P here.');
 outtextxy( 0, 80,'(Use by typing in (eg for ^P) ^ then P, not Ctrl-P.)');
 p:=0; ctrlsout(x); fillchar(chars,sizeof(chars),#32);
 repeat
  tx:=0; ty:=6; gwrite(x+#4+#32);
  tx:=(p mod 80); ty:=(p div 80)+6;
  while not keypressed do begin; delay(1); cursor; end; losecursor;
  r:=readkey;
  case r of
   #8: if p>0 then begin; x:=copy(x,1,p-1)+copy(x,p+1,255); dec(p); end; { backspace }
   #9: flipover;
   #32..#255: begin; x:=copy(x,1,p)+r+copy(x,p+1,255); inc(p); end;
   #0: case readkey of { extd. keystroke }
        'G': p:=0; { Home }
        'K': if p>0 then dec(p); { left }
        'M': if p<length(x) then inc(p); { right }
        'H': if p>80 then dec(p,80); { up }
        'P': if p<length(x)-80 then inc(p,80); { down }
        'O': p:=length(x); { End }
        'S': x:=copy(x,1,p)+copy(x,p+2,255); { Del }
       end;
  end;
 until r=#13;
 ctrlsin(x); typein:=x;
end;

function typeno(title:string):byte;
var
 x:string[2]; r:char; e:integer; p:word;
begin;
 cleardevice; x:='000';
 settextstyle(0,0,3); setcolor(9); outtextxy(0,0,title);
 setfillstyle(1,0); setcolor(10); fillchar(chars,sizeof(chars),#32);
 repeat
  bar(100,100,150,125);
  outtextxy(100,100,x);
  repeat r:=readkey until r in ['0'..'9',#27,#13];
  if r=#27 then begin; typeno:=255; exit; end;
  if r<>#13 then x:=x[2]+r;
 until r=#13;
 val(x,p,e); typeno:=p;
end;

procedure showallnames;
var fv:byte; s:string[2]; r:char;
begin;
 settextstyle(0,0,2); cleardevice; setcolor(13); outtextxy(0,0,'Descriptions start...');
 settextstyle(0,0,1); setcolor(7);
 for fv:=1 to 29 do
 begin;
  str(fv:2,s);
  outtextxy((fv div 15)*320,((fv mod 15)*10)+30,s+'='+copy(names[fv,1],0,33));
 end;
 setcolor(15); outtextxy(500,190,'Press any key...');
 r:=readkey;
end;

procedure showallassoc;
var fv:byte; s:string[2]; r:char;

  procedure saascreen;
  begin;
   settextstyle(0,0,2); cleardevice; setcolor(10); outtextxy(0,0,'Everything...');
   settextstyle(0,0,1); setcolor(2);
   outtextxy(17,20,'(Format: <number> : <start of names> : <start of desc.>)');
  end;

begin;
 saascreen;
 for fv:=1 to 30 do
 begin;
  str(fv-1:2,s);
  outtextxy(0,(((fv-1) mod 10)*10)+30,
   s+':'+copy(names[fv-1,1],1,7)+':'+copy(names[fv-1,2],1,70));
  if (fv mod 10)=0 then begin; r:=readkey; saascreen; end;
 end;
 setcolor(15); outtextxy(500,190,'Press any key...');
 r:=readkey;
end;

procedure clear;
var fv:byte;
begin;
 fillchar(names ,sizeof(names ),  #0);
 for fv:=1 to numlines do begin; lines[fv].x1:=nay; fields[fv].x1:=nay; end;
 fillchar(peds  ,sizeof(peds  ),#177);
end;

procedure scramble; { Works both ways. }
var fv,ff:byte;
  procedure scram1(var x:string);
  var fz:byte;
  begin;
   for fz:=1 to length(x) do
    x[fz]:=chr(ord(x[fz]) xor 177);
  end;
begin;
 for fv:=0 to 29 do
  for ff:=1 to 2 do
   scram1(names[fv,ff]);
 scram1(listen);
 scram1(flags);
end;

procedure save;
var x:string; f:file; minnames,minlines,minpeds,minfields,fv,ff:byte;
begin;
 minnames :=0; for fv:=0 to 29 do if names[fv,1]<>''    then minnames :=fv;
 minlines :=0; for fv:=1 to numlines do
                if lines[fv].x1<>nay  then minlines :=fv;
 minpeds  :=0; for fv:=1 to 15 do if peds[fv].dir<177   then minpeds  :=fv;
 minfields:=0; for fv:=1 to 30 do if fields[fv].x1<>nay then minfields:=fv;
 assign(f,'c:\avalot\also'+n+'.avd');
 rewrite(f,1);
 x:='This is an Also .AVD file, which belongs to AVALOT.EXE. Its contents'+
 #13+#10+'are subject to copyright, so there. Have fun!'+#26+' *Minstrel* ';
 blockwrite(f,x[1],128);
 scramble;
 blockwrite(f,minnames,1);
 for fv:=0 to minnames do
  for ff:=1 to 2 do
   blockwrite(f,names[fv,ff],length(names[fv,ff])+1);
 blockwrite(f,minlines,1);
 blockwrite(f,lines,sizeof(lines[1])*minlines);
 blockwrite(f,minpeds,1);
 blockwrite(f,peds,sizeof(peds[1])*minpeds);
 blockwrite(f,minfields,1);
 blockwrite(f,fields,sizeof(fields[1])*minfields);
 blockwrite(f,magics,sizeof(magics));
 blockwrite(f,portals,sizeof(portals));
 blockwrite(f,flags,sizeof(flags));
 blockwrite(f,listen[0],1);
 blockwrite(f,listen[1],length(listen));
 close(f);
 scramble;
end;

procedure load;
var f:file; minnames,minlines,minpeds,minfields:byte; ff,fv:byte;

  function nextstring:string;
  var l:byte; x:string;
  begin;
   x:=''; blockread(f,l,1); blockread(f,x[1],l); x[0]:=chr(l); nextstring:=x;
  end;

begin;
 clear;
 assign(f,'c:\avalot\also'+n+'.avd');
{$I-} reset(f,1); {$I+} if ioresult<>0 then exit; { no Also file }
 seek(f,128); blockread(f,minnames,1);
 for fv:=0 to minnames do
  for ff:=1 to 2 do
   names[fv,ff]:=nextstring;
 blockread(f,minlines,1);
 blockread(f,lines,sizeof(lines[1])*minlines);
 blockread(f,minpeds,1);
 blockread(f,peds,sizeof(peds[1])*minpeds);
 blockread(f,minfields,1);
 blockread(f,fields,sizeof(fields[1])*minfields);
 blockread(f,magics,sizeof(magics));
 blockread(f,portals,sizeof(portals));
 blockread(f,flags,sizeof(flags));
 blockread(f,listen[0],1);
 blockread(f,listen[1],length(listen));
 close(f);
 scramble;
end;

procedure editmagics;
const codes : array[1..15] of char = '123456789ABCDEF';
var
 y:integer;
 r,rr:char; p:byte;

  procedure display;
  var fv:byte;
  begin;
   cleardevice;
   settextstyle(0,0,2); setcolor(15); outtextxy(0,0,'Magics.');
   settextstyle(0,0,1);
   for fv:=1 to 15 do
   begin;
    y:=23+fv*10;
    setcolor(fv); outtextxy(100,y,'$'+codes[fv]);
    with magics[fv] do
    begin;
     case op of
      nix: begin; setcolor(8); outtextxy(140,y,'Nix'); end;
      bounce: begin; setcolor(10); outtextxy(143,y,'Bounce!'); end;
      exclaim: begin;
                setcolor(14); outtextxy(143,y,'Exclaim: '+strf(data));
               end;
      transport: begin;
                  setcolor(12);
                  outtextxy(143,y,'Transport to '+strf(hi(data))+
                   ', ped '+strf(lo(data)));
                 end;
      unfinished: begin;
                   setcolor(15); outtextxy(143,y,'*** UNFINISHED! ***');
                  end;
      special: begin;
                setcolor(6); outtextxy(143,y,'Special call no. '+strf(data));
               end;
      opendoor: begin;
                 setcolor(11);
                 outtextxy(143,y,'Opening door to '+strf(hi(data))+
                  ', ped '+strf(lo(data)));
                end;
     end;
    end;
   end;
   outtextxy(177,190,'Which do you want to change? (Esc=Exit) $');
  end;

  function ask(x:string):word;
  var q:string; thomaswashere:word; e:integer;
  begin;
   cleardevice;
   setcolor(10); settextstyle(0,0,3); outtextxy(0,100,x);
   repeat
    readln(q); val(q,thomaswashere,e);
   until e=0; ask:=thomaswashere;
  end;

begin;
 repeat
  display;
  repeat
   r:=upcase(readkey);
   if r=#27 then exit;
   p:=pos(r,codes); { which are we editing? }
  until p>0; { it must BE there... }
  setcolor(p); cleardevice;
  outtextxy(177,17,'Editing magic $'+r+'.');
  outtextxy(0,30,'New operation ( (N)ix, (B)ounce, (E)xclaim, (T)ransport, (U)nfinished),');
  outtextxy(30,40,'(S)pecial, (O)pening Door?');
  repeat rr:=upcase(readkey) until rr in ['N','B','E','T','U','S','O',#27];
  with magics[p] do
   case rr of
    #27: exit; { cancelling code }
    'N': op:=nix;
    'B': op:=bounce;
    'E': begin; op:=exclaim; data:=ask('Which scroll?'); end;
    'T': begin; op:=transport; data:=ask('Ped no.?')+ask('Whither?')*256; end;
    'U': op:=unfinished;
    'S': begin; op:=special; data:=ask('Which call?'); end;
    'O': begin; op:=opendoor; data:=ask('Ped no.?')+ask('Whither?')*256; end;
   end;
 until false;
end;

procedure editportals; { much t'same as editmagics }
const codes : array[9..15] of char = '9ABCDEF';
var
 y:integer;
 r,rr:char; p:byte;

  procedure display;
  var fv:byte;
  begin;
   cleardevice;
   settextstyle(0,0,2); setcolor(15); outtextxy(0,0,'Portals.');
   settextstyle(0,0,1);
   for fv:=9 to 15 do
   begin;
    y:=fv*10-53;
    setcolor(fv); outtextxy(100,y,'$'+codes[fv]);
    with portals[fv] do
    begin;
     case op of
      nix: begin; setcolor(8); outtextxy(140,y,'Nix'); end;
      exclaim: begin;
                setcolor(14); outtextxy(143,y,'Exclaim: '+strf(data));
               end;
      transport: begin;
                  setcolor(12);
                  outtextxy(143,y,'Transport to '+strf(hi(data))+
                   ', ped '+strf(lo(data)));
                 end;
      unfinished: begin;
                   setcolor(15); outtextxy(143,y,'*** UNFINISHED! ***');
                  end;
      special: begin;
                setcolor(6); outtextxy(143,y,'Special call no. '+strf(data));
               end;
      opendoor: begin;
                 setcolor(11);
                 outtextxy(143,y,'Opening door to '+strf(hi(data))+
                  ', ped '+strf(lo(data)));
                end;
     end;
    end;
   end;
   outtextxy(177,190,'Which do you want to change? (Esc=Exit) $');
  end;

  function ask(x:string):word;
  var q:string; thomaswashere:word; e:integer;
  begin;
   cleardevice;
   setcolor(10); settextstyle(0,0,3); outtextxy(0,100,x);
   repeat
    readln(q); val(q,thomaswashere,e);
   until e=0; ask:=thomaswashere;
  end;

begin;
 repeat
  display;
  repeat
   r:=upcase(readkey);
   if r=#27 then exit;
   p:=pos(r,codes); { which are we editing? }
  until p>0; { it must BE there... }
  inc(p,8); setcolor(p); cleardevice;
  outtextxy(177,17,'Editing portal $'+r+'.');
  outtextxy(0,30,'New operation ( (N)ix, (E)xclaim, (T)ransport, (U)nfinished),');
  outtextxy(30,40,'(S)pecial, (O)pening Door?');
  repeat rr:=upcase(readkey) until rr in ['N','E','T','U','S','O',#27];
  with portals[p] do
   case rr of
    #27: exit; { cancelling code }
    'N': op:=nix;
    'E': begin; op:=exclaim; data:=ask('Which scroll?'); end;
    'T': begin; op:=transport; data:=ask('Ped no.?')+ask('Whither?')*256; end;
    'U': op:=unfinished;
    'S': begin; op:=special; data:=ask('Which call?'); end;
    'O': begin; op:=opendoor; data:=ask('Ped no.?')+ask('Whither?')*256; end;
   end;
 until false;
end;

procedure editflags;
var r:char;
begin;
 cleardevice;
 settextstyle(0,0,2); setcolor(15); outtextxy(0,0,'Flags.');
 settextstyle(0,0,1); setcolor(10);
 outtextxy(100,30,'Press the letter of the flag you want to toggle.');
 outtextxy(100,40,'Tab = flip screens, Esc/Enter = return to menu.');
 setcolor(14); setfillstyle(1,0);
 for r:='A' to 'Z' do
  if pos(r,flags)>0 then outtextxy(ord(r)*20-1223,77,r);
 repeat
  repeat r:=upcase(readkey) until r in ['A'..'Z',#27,#13,#9];
  case r of
   'A'..'Z': begin;
              if pos(r,flags)>0 then
              begin; { flag is on- switch it off }
               delete(flags,pos(r,flags),1);
               bar(ord(r)*20-1223,77,ord(r)*20-1213,87);
               sound(1777); delay(7); nosound;
              end else
              begin; { flag is off- switch it on }
               flags:=flags+r;
               outtextxy(ord(r)*20-1223,77,r);
               sound(177); delay(7); nosound;
              end;
             end;
   #27,#13: exit;
   #9: flipover;
  end;
 until false;
end;

procedure alsomenu;
var r:char; t:byte;
begin;
 repeat
  setactivepage(0); setvisualpage(0);
  cleardevice; setcolor(15); settextstyle(0,0,2);
  outtextxy(0,0,'Also... Main Menu');
  settextstyle(0,0,1); setcolor(10);
  outtextxy(100, 40,'1) Edit the names of an object');
  outtextxy(100, 50,'2) View all names');
  outtextxy(100, 60,'3) Edit the description of this object');
  outtextxy(100, 70,'4) View all associations.');
  outtextxy(100, 80,'5) Enter Lino mode.');
  outtextxy(100, 90,'6) Edit magics.');
  outtextxy(100,100,'7) Edit portals.');
  outtextxy(100,110,'8) Edit flags.');
  outtextxy(100,120,'9) Edit listen field.');
  outtextxy(100,160,'S) Save');
  outtextxy(100,170,'L) Load');
  outtextxy( 80,180,'Tab) View other screen');
  if current=0 then outtextxy(0,140,'< Main description of room >') else
   outtextxy(0,140,'<'+names[current,1]+'>');
  repeat
   r:=upcase(readkey); if r=#9 then flipover;
  until r in ['1'..'9','S','L',#0];
  case r of
   '1': begin;
         repeat
          t:=typeno('Which object? (0-30)');
         until (t<30) or (t=255);
         if (t<>255) and (t<>0) then names[t,1]:=typein(names[t,1]);
         current:=t;
        end;
   '2': showallnames;
   '3': names[current,2]:=typein(names[current,2]);
   '4': showallassoc;
   '5': lino;
   '6': editmagics;
   '7': editportals;
   '8': editflags;
   '9': listen:=typein(listen);
   'S': save;
   'L': load;
   #0: if readkey=#45 then exit;
  end;
 until false;
end;

begin;
 writeln('*** ALSO ***');
 writeln;
 write('No. of screen to edit?'); readln(n); load;
 assign(f,'v:avalot.fnt'); reset(f); read(f,skinny); close(f);
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi'); current:=0;
 loadscreen;
 alsomenu;
end.
