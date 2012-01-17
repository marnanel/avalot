program displtext; {$S-}
uses dos,crt,tommys;

type bigtextarray= array[0..49999] of byte;
     Chaptertype= record
      HeaderName:string[60];
      HeaderOffset:word;
     end;
     sbtype= array[1..1120] of byte;

const contsize=29; {number of headers in AVALOT.DOC}
      contentsheader:String[80]=' -=- The contents of the Lord AVALOT D''Argent (version 1.3) documentation -=-';
      listpal:array[0..15] of byte=(1,0,3,0,7,0,7,7,0,0,0,0,0,0,0,0);
      blankpal:array[0..15] of byte=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
      tabstop=8; {length of tab stops}

{NOTE: Tabs are not properly implemented. The program just interprets them}
{as a number of spaces.}

var textvar,textvar8: array[1..256, 0..15] of byte;
    posof13: array[0..1500] of word;
    scvar: array[1..65535] of byte absolute $A000:$0000;
    stbar,stbar2: sbtype;
    dpt: pointer;
    sot,nol,bat,bab,tlab,nosl,bfseg,bfofs,useless: word;
    textmem: ^bigtextarray;
    atsof,fast,regimode:boolean;
    hol:byte;
    stline:string[80];
    contlist: array[1..contsize] of Chaptertype;
    lat:integer;

procedure wipeit(pos:longint; count:word); {Like fillchar, but wraps}
var wpos:longint;
begin
 wpos:=word(pos);
 fillchar(mem[$A000+wpos div 16:wpos mod 16],count,0)
end;

procedure wrapcopy(fromarr:sbtype; pos:longint); {Like fillchar, but wraps}
var wpos:longint;
begin
 wpos:=word(pos);
 move(fromarr,mem[$A000+wpos div 16:wpos mod 16],1120)
end;

procedure blankscreen; {blanks the screen (!)}
var r:registers;
begin
 r.ax:=$1002;
 r.es:=seg(blankpal);
 r.dx:=ofs(blankpal);
 intr($10,r);
end;

procedure showscreen; {shows the screen (!)}
var r:registers;
begin
 r.ax:=$1002;
 r.es:=seg(listpal);
 r.dx:=ofs(listpal);
 intr($10,r);
end;

procedure wipesb(wheretop:word);
var plane:byte;
begin
 for plane:=2 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl plane; port[$3CF]:=plane;
  fillchar(scvar[(wheretop+336)*80+1],1120,0);
 end;
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=2; port[$3CF]:=1;
end;

procedure displstat(wipepos:byte); {displays the status bar}
var plane:byte;
begin
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=4; port[$3CF]:=2;
 wrapcopy(stbar,(lat+336)*80);
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=8; port[$3CF]:=3;
 wrapcopy(stbar2,(lat+336)*80);
 for plane:=2 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl plane; port[$3CF]:=plane;
  case wipepos of
   0: wipeit((lat+335)*80-1,80);
   1: wipeit(lat*80-1,80);
  end;
 end;
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=2; port[$3CF]:=1;
end;

procedure udstat; {updates the status bar}
var pt:string[3];
    fv,fv2:byte;
begin
 fillchar(pt,4,#0);
 str(round((tlab-21)/(nol-21)*100),pt);
 for fv:=1 to 3 do
  for fv2:=0 to 13 do
  begin;
   stbar[fv2*80+fv+68]:=not textvar[ord(pt[fv])+1,fv2];
   stbar2[fv2*80+fv+68]:=textvar[ord(pt[fv])+1,fv2];
  end;
end;

procedure finddocinfo; {finds the line breaks in AVALOT.DOC & finds the
headers by searching for '"""'}
var wv,oldwv,varpos,varpos2,contlpos:word;
    thisaheader:boolean;
    headerstring:string[60];
begin
 thisaheader:=false;
 posof13[0]:=65535; {this +2 will wrap around to 1}
 wv:=1;
 oldwv:=1;
 varpos:=1;
 contlist[1].headername:='Start of documentation';
 contlist[1].headeroffset:=0;
 contlpos:=2;
 while wv<sot do
 begin
  while (textmem^[wv]<>13) and (textmem^[wv]<>34) and (wv-oldwv<80) do inc(wv);
  case textmem^[wv] of
  13: begin
       posof13[varpos]:=wv;
       inc(varpos);
       oldwv:=wv+1;
       thisaheader:=false;
      end;
  34: if (textmem^[wv-1]=34) and (textmem^[wv-2]=34) and (varpos>12)
       and (thisaheader=false) then
      begin
       thisaheader:=true;
       headerstring[0]:=#0;
       varpos2:=posof13[varpos-2]+2;
       while (textmem^[varpos2]=32) or (textmem^[varpos2]=9) do inc(varpos2);
       while varpos2<>posof13[varpos-1] do
       begin;
        headerstring:=headerstring+chr(textmem^[varpos2]);
        inc(varpos2);
       end;
       contlist[contlpos].headername:=headerstring;
       contlist[contlpos].headeroffset:=varpos-2;
       inc(contlpos);
      end;
    end;
  inc(wv);
 end;
 nol:=varpos-2;
 nosl:=nol*14;
end;

procedure graphmode(gm:byte); {puts the display adaptor into a specified mode}
var regs:registers;
begin
 regs.ax:=gm;
 intr($10,regs);
end;

procedure setoffset(where_on_screen:word); assembler; {for scrolling the screen}
asm
 mov bx, where_on_screen
 mov dx, $03D4
 mov ah, bh
 mov al, $C
 out dx, ax

 mov ah, bl
 inc al
 out dx, ax
end;

procedure setupsb(sbtype:byte); {sets up the status bar in several styles}
var fv:integer;
begin
 case sbtype of
  1: if regimode=false then stline:='Doc lister: PgUp, PgDn, Home & End to move. Esc exits. C='
   +#26+'contents '+#179+'   % through   ' else
   stline:='Doc lister: PgUp, PgDn, Home & End to move. Esc exits to main menu.'
   +#179+'   % through';
  2: stline:='Esc=to doc lister '+#179+' Press the key listed next to the section you wish to jump to';
 end;
 for fv:=0 to 1118 do begin;
  stbar[fv+1]:=not textvar[ord(stline[fv mod 80+1])+1,fv div 80];
  stbar2[fv+1]:=textvar[ord(stline[fv mod 80+1])+1,fv div 80];
 end;
end;

procedure setup; {sets up graphics, variables, etc.}
var f:file;
    fv:integer;
    r:registers;
begin
 if (paramstr(1)<>'REGI') and (paramstr(1)<>'ELMPOYTEN')
 then
  begin
   clrscr;
   Writeln('This program cannot be run on its own. Run AVALOT.EXE.');
   Halt(123);
  end;
 val(paramstr(2),bfseg,useless);
 val(paramstr(3),bfofs,useless);
 inc(bfofs);
 atsof:=true;
 fast:=false;
 Assign(f,'avalot.fnt');
 reset(f,1);
 Blockread(f,textvar,4096);
 close(f);
 Assign(f,'ttsmall.fnt');
 reset(f,1);
 Blockread(f,textvar8,4096);
 close(f);
 Assign(f,'avalot.doc');
 reset(f,1);
 sot:=filesize(f);
 mark(dpt);
 New(textmem);
 BlockRead(f,textmem^,sot);
 close(f);
 finddocinfo;
 if paramstr(1)='REGI' then
  begin;
   regimode:=true;
   tlab:=contlist[contsize].Headeroffset+24;
   lat:=contlist[contsize].headeroffset*14;
  end
  else
  begin;
   lat:=0; tlab:=24;
   regimode:=false;
  end;
 setupsb(1);
 graphmode(16);
 directvideo:=false;
 showscreen;
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=2; port[$3CF]:=1;
end;

procedure drawscreenf(tl:integer); {draws a screen from a line forwards}
{N.B. tl>1}
var fv,fv2,curbyte,plane:word;
    xpos:byte;
begin
 blankscreen;
 wipesb(lat);
 if tl>nol-24 then tl:=nol-24;
 if tl<0 then tl:=0;
 lat:=tl*14;
 for plane:=2 to 3 do {wipe sb off}
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl plane; port[$3CF]:=plane;
  {fillchar(mem [$A000:((lat-1)*80) mod 65536],26800,0);}
  wipeit(lat*80,26800);
 end;
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=2; port[$3CF]:=1; {back to normal}
 if tl>0 then curbyte:=posof13[tl-1]+2 else curbyte:=0;
 bat:=curbyte;
 for fv:=lat to lat+335 do
 begin
  fv2:=curbyte;
  xpos:=1;
  while xpos<=80 do
  begin
   if fv2<posof13[tl] then
   begin
    if textmem^[fv2]=9 then
    begin
     wipeit(fv*80+xpos,tabstop);
     inc(xpos,tabstop);
    end else
    begin
     mem[$A000:word(fv*80+xpos-1)]:=
      textvar[textmem^[fv2]+1,fv mod 14];
     inc(xpos);
    end;
   end else
   begin
    wipeit(fv*80+xpos-1,82-xpos);
    xpos:=81;
   end;
   inc(fv2);
  end;
  if fv mod 14=0 then
  begin
   inc(tl);
   curbyte:=posof13[tl-1]+2;
  end;
 end;
 bab:=curbyte;
 tlab:=tl;
 udstat;
 displstat(2);
 setoffset(word(lat*80));
 if tl-23>1 then atsof:=false;
 showscreen;
end;

procedure displcont; {displays the contents}
var fv,fv2,fv3,keyon,jumppos,plane:byte;
    olat:word;
    curstr:string[62];
    rkv:char;
begin
 blankscreen;
 olat:=lat; lat:=0; keyon:=1; jumppos:=0;
 SetOffset(0);
 for plane:=1 to 3 do {wipe sb off}
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl plane; port[$3CF]:=plane;
  fillchar(scvar,26800,0);
 end;
 port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=2; port[$3CF]:=1; {back to normal}
 setupsb(2);
 displstat(2);
 for fv:=1 to 80 do
  for fv2:=0 to 27 do
  begin
   scvar[fv2*80+fv]:=textvar[ord(Contentsheader[fv])+1,fv2 div 2];
  end;
 for fv:=1 to contsize do
 begin
  if keyon<10 then curstr:=strf(keyon)+'. '+Contlist[fv].HeaderName else
   curstr:=Chr(keyon+55)+'. '+Contlist[fv].HeaderName;
  for fv2:=1 to length(curstr) do
   for fv3:=0 to 7 do
    scvar[(fv+3)*640+fv3*80+fv2]:=textvar8[ord(curstr[fv2])+1,fv3];
  inc(keyon);
 end;
 showscreen;
 repeat until keypressed;
 rkv:=readkey;
 case rkv of
  #49..#57:  jumppos:=ord(rkv)-48;
  #65..#90:  jumppos:=ord(rkv)-55;
  #97..#122: jumppos:=ord(rkv)-87;
  else lat:=olat;
 end;
 if jumppos>0 then lat:=contlist[jumppos].Headeroffset;
 setupsb(1);
 if fast=false then wipesb(0);
 drawscreenf(lat);
end;

procedure down; {scrolls the screen down one line}
var fv,xpos,wpos,lab:word;
begin
 inc(lat);
 lab:=lat+335;
 setoffset(word(lat*80));
 if lab mod 14=0 then begin
 bat:=posof13[tlab-24]+2; bab:=posof13[tlab]+2; inc(tlab); udstat; end;
 fv:=bab;
 xpos:=1;
 while xpos<=80 do
 begin
  if fv<posof13[tlab] then
  begin
   if textmem^[fv]=9 then
   begin
    wipeit(lab*80+xpos-1,tabstop);
    inc(xpos,tabstop);
   end else
   begin
    wpos:=(lab*80+xpos) mod 65536;
    (*fillchar(mem[$A000+wpos div 16:wpos mod 16],count,0)*)
    mem[$A000:wpos-1]:=textvar[textmem^[fv]+1,lab mod 14];
    inc(xpos);
   end;
  end else
   begin
    wipeit(lab*80+xpos-1,81-xpos);
    xpos:=81;
   end;
  inc(fv);
 end;
 atsof:=false;
 if fast=true then displstat(0);
end;

procedure up; {scrolls the screen up one line}
var fv,xpos,wpos:word;
begin
 if lat=0 then begin atsof:=true; exit; end;
 if lat mod 14=0 then
  if tlab>24 then
  begin
   dec(tlab); bat:=posof13[tlab-24]+2; bab:=posof13[tlab-1]+2; udstat; end else
  begin atsof:=true; udstat; exit; end;
 dec(lat);
 setoffset(word(lat*80));
 fv:=bat;
 xpos:=1;
 while xpos<=80 do
 begin
  if fv<posof13[tlab-23] then
  begin
   if textmem^[fv]=9 then
   begin
    wipeit(lat*80+xpos-1,tabstop);
    inc(xpos,tabstop);
   end else
   begin
    wpos:=word((lat*80+xpos) mod 65536);
    mem[$A000:wpos-1]:=textvar[textmem^[fv]+1,lat mod 14];
    inc(xpos);
   end;
  end else
   begin
    wipeit(lat*80+xpos-1,81-xpos);
    xpos:=81;
   end;
  inc(fv);
 end;
 if fast=true then displstat(1);
 {ateof:=false;}
end;

procedure endit; {Ends the program}
begin
 release(dpt);
 graphmode(2);
end;

procedure control; {User control}
var rkv,rkv2{the sequel},rkv3:char;
    fv:integer;
    first:boolean;
begin
 if regimode=false then displcont else drawscreenf(tlab-24);
 first:=true;
 repeat;
  rkv:=readkey;
  case rkv of
   #0: begin
        rkv2:=readkey;
        case rkv2 of
         cHome:drawscreenf(0);
         cEnd: drawscreenf(nol-24);
         cPgDn:
          begin;
           memw[bfseg:bfofs]:=0;
           if fast=false then wipesb(lat);
           fv:=1;
           while (lat+336<nosl) and (fv<337) do
           begin
            inc(fv);
            down;
           end;
           if (first=true) and (memw[bfseg:bfofs]<=2) then fast:=true;
           if (fast=false) or (first=true) then displstat(0);
          end;
         cPgUp:
          begin;
           memw[bfseg:bfofs]:=0;
           if fast=false then wipesb(lat);
           fv:=1;
           while (atsof=false) and (fv<337) do
           begin
            inc(fv);
            up;
           end;
           if (first=true) and (memw[bfseg:bfofs]<=2) then fast:=true;
           if (fast=false) or (first=true) then displstat(0);
           end;
(*         cUp:repeat;
              up;
              readkey;
             until (readkey<>cUp) or (atsof=true);
         cDown: repeat;
                 down;
                 readkey;
                until (readkey<>cDown) or (ateof=true);*)
        end;
        first:=false;
       end;
   #27: exit;
   #67,#99: if regimode=false then begin wipesb(lat); displcont; end;
  end;
 until false;
end;

begin
 setup;
 control;
 endit;
end.
