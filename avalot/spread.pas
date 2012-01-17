program spread;
uses Graph,Crt;

type
 adxtype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

var
 sn:string[3];
 a:adxtype;
 pic:array[1..24,0..1] of pointer; { the pictures themselves }
 bigsize:word;

const
 col : array[0..15] of string[6] =
  ('Black','Blue','Green','Cyan','Red','Pink','Brown','Grey+',
   'Grey-','Blue+','Green+','Cyan+','Red+','Pink+','Yellow','White');
 prompt = #26+#175;

procedure load;
var
 f:file; gd,gm,sort,n:byte; p,q:pointer;
begin;
 assign(f,'v:sprite'+sn+'.avd'); reset(f,1); seek(f,59);
 blockread(f,a,sizeof(a)); blockread(f,bigsize,2);
 setactivepage(3);
 for sort:=0 to 1 do
 begin;
  mark(q); getmem(p,bigsize);
  blockread(f,p^,bigsize);
  putimage(0,0,p^,0); release(q); n:=1;
  with a do
   for gm:=0 to (num div seq)-1 do { directions }
    for gd:=0 to seq-1 do { steps }
    begin;
     getmem(pic[n,sort],a.size); { grab the memory }
     getimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       (gm div 2)*(xl*6)+gd*xl+xl-1,(gm mod 2)*yl+yl-1,
       pic[n,sort]^); { grab the pic }
     inc(n);
   end;
 end;
 close(f); setactivepage(0);
end;

procedure save;
var
 f:file; gd,gm,sort,n:byte; p,q:pointer;
 x:string; txl,tyl:integer;
begin;
 with a do
 begin;
  txl:=seq*xl*2; tyl:=yl*2;
 end;

 assign(f,'v:sprite'+sn+'.avd');
 x:='Sprite file for Avvy - Trippancy IV. Subject to copyright.'+#26;
 rewrite(f,1); blockwrite(f,x[1],59);

 blockwrite(f,a,sizeof(a)); blockwrite(f,bigsize,2);
 setactivepage(3);
 for sort:=0 to 1 do
 begin;
  mark(q); getmem(p,bigsize); n:=1;
  with a do
   for gm:=0 to (num div seq)-1 do { directions }
    for gd:=0 to seq-1 do { steps }
    begin;
     putimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       pic[n,sort]^,0); { drop the pic }
     inc(n);
   end;
  getimage(0,0,txl,tyl,p^);
  blockwrite(f,p^,bigsize); release(q);
 end;
 close(f); setactivepage(0);
end;

procedure setup;
var gd,gm:integer;
begin;
 writeln('SPREAD (c) 1992, Thomas Thurman.'); writeln;
 write('Enter number of SPRITE*.AVD file to edit:'); readln(sn);
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 load;
end;

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure likethis;
begin;
 with a do
 begin;
  setfillstyle(1,bgc); setcolor(fgc); settextstyle(0,0,1);
  bar(0,190,100,200); outtextxy(12,191,'Like this!');
 end;
end;

procedure values;
var fv:byte;
begin;
 settextstyle(2,0,9); setcolor(14);
 outtextxy(277,0,'Spread: editing '+sn); setcolor(15);
 with a do for fv:=0 to 3 do putimage(77+(xl+10)*fv,17,pic[seq*fv+1,1]^,0);
 settextstyle(2,0,7);
 outtextxy(0, 30,'Views:');
 with a do
 begin;
  outtextxy(0, 50,'N: Name: '+name);
  outtextxy(0, 70,'No. of pictures: '+strf(num)+' ('+strf(num div seq)+' ways)');
  outtextxy(0, 90,'XY: Size: '+strf(xl)+'x'+strf(yl));
  outtextxy(0,110,'S: Stride size: '+strf(seq));
  outtextxy(0,130,'Imagesize (bytes): '+strf(size));
  outtextxy(0,150,'B: Bubble background: '+col[bgc]);
  outtextxy(0,170,'F: Bubble foreground: '+col[fgc]);
  likethis;
 end;
 setcolor(lightgreen); settextstyle(0,0,1);
 outtextxy(400,50,'A) Animate');
 outtextxy(400,60,'E) Edit pictures');
 outtextxy(400,70,'alt-f2) Save');
 outtextxy(400,80,'ctrl-f3) Load');
 outtextxy(400,90,'or any key to the left...');
end;

function ccol:byte;
var fv:byte;
begin;
 restorecrtmode;
 writeln('Choose a colour- one of these...');
 for fv:=0 to 15 do
 begin;
  textattr:=14; write(fv,') '); textattr:=fv; write(#254+#32);
  textattr:=14; writeln(col[fv]);
 end;
 textattr:=14;
 repeat
  write(prompt); readln(fv);
 until fv<16;
 ccol:=fv; setgraphmode(0);
end;

function cstr(oc:string):string;
var x:string;
begin;
 restorecrtmode;
 writeln('Old choice is: <'+oc+'>');
 writeln;
 writeln('(Anything after a semi-colon will not be displayed by the game, e.g. Avvy;Monk');
 writeln(' will be displayed as Avvy.)');
 writeln;
 write('New choice, Enter for no change, Space+Enter for a blank?'+prompt); readln(x);
 if x='' then cstr:=oc else if x=' ' then cstr:='' else cstr:=x;
 setgraphmode(0);
end;

function cnum(on:longint):longint;
var x:string; q:longint; e:integer;
begin;
 restorecrtmode;
 repeat
  writeln('Old value is: ',on,'.');
  write('New choice, or Enter for no change?'+prompt); readln(x);
  if x='' then
  begin;
   e:=0; { must be OK here } q:=on;
  end else val(x,q,e);
  if e<>0 then writeln(x,' isn''t a number, silly!');
 until e=0;
 setgraphmode(0); cnum:=q;
end;

procedure animate;
var facing,step,slow,fv:byte;
begin;
 cleardevice;
 settextstyle(0,0,2); setcolor(12); outtextxy(0,0,'Animate');
 settextstyle(0,0,1); setcolor(15);
 outtextxy(0,20,'Enter = Turn, + = Faster, - = Slower, Esc = stop this.');
 facing:=0; step:=1; slow:=100;
 with a do
  repeat
   for fv:=0 to 1 do
    putimage(200*fv+177,77,pic[facing*seq+step,fv]^,4-fv*4);
   if keypressed then
    case upcase(readkey) of
     #13: begin;
           inc(facing); if facing*seq>=num then facing:=0;
          end;
     #27: begin; cleardevice; exit; end;
     '+': if slow>0 then dec(slow,5);
     '-': if slow<255 then inc(slow,5); else write(#7);
    end;
   inc(step); if step>seq then step:=1;
   delay(slow);
  until false;
end;

function tabpel(x,y:integer):byte;
begin;
 if getpixel(400+x,17+y)=15 then tabpel:=17
  else tabpel:=getpixel(500+x,17+y);
end;

procedure bigpixel(x,y:integer; size,col:byte);
begin;
 if col=17 then setfillstyle(9,8) else setfillstyle(1,col);
 bar(x*size,y*size,x*size+size-2,y*size+size-2);
end;

procedure blowup(n:byte);
var fv,x,y,xyl:byte;
begin;
 with a do
 begin;
  for fv:=0 to 1 do putimage(400+fv*100,17,pic[n,fv]^,0);
  xyl:=200 div yl;
  for x:=0 to xl do
   for y:=0 to yl do
    bigpixel(x,y,xyl,tabpel(x,y));
 end;
end;

procedure edit;
  procedure putnum(x,p:byte);
  var z:string[2];
  begin;
   str(x,z); outtextxy(x*53+17,87,z); putimage(x*53,100,pic[p,1]^,0);
  end;
  procedure title;
  begin;
   cleardevice; setcolor(11); settextstyle(0,0,2);
   outtextxy(0,0,'Edit- which one?'); settextstyle(0,0,1); setcolor(15);
  end;
var
 fv,ra,rb:byte;
begin;
 with a do
 begin;
  title; for fv:=1 to (num div seq) do putnum(fv,fv*seq);
  repeat ra:=ord(readkey)-48 until ra<(num div seq); dec(ra);
  title; for fv:=1 to seq do putnum(fv,ra*seq+fv);
  repeat rb:=ord(readkey)-48 until rb<seq;
  cleardevice;
  blowup(ra*seq+rb); readln;
  cleardevice;
 end;
end;

procedure pickone;
var r:char;
begin;
 r:=upcase(readkey);
 with a do
  case r of
   'N': name:=cstr(name);
   'S': seq:=cnum(seq);
   'F': fgc:=ccol;
   'B': bgc:=ccol;
   'A': animate;
   'E': edit;
   #0: case readkey of
        'i': save; { alt-f2 }
       end;
  end;
end;

begin;
 setup;
 repeat
  values;
  pickone;
 until false;
end.