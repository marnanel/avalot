{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 SCROLLS          The scroll driver. }
{  $D-}
unit scrolls;
{$V-}

interface

uses Gyro,Joystick;

const
 aboutscroll : boolean = false; { Is this the about box? }

procedure state(x:byte); { Sets "Ready" light to whatever }

procedure drawscroll(gotoit:proc); { This is one of the oldest procs in the game. }

procedure bubble(gotoit:proc);

procedure resetscroll;

procedure calldrivers;

procedure display(z:string);

function ask(question:string):boolean;

procedure natural;

function lsd:string;

procedure okay; { Says "Okay!" }

procedure musical_scroll;

implementation
 uses Lucerna,Graph,Crt,Trip5,Enhanced,Dos,Logger,Acci,Basher,Visa,Timeout;

const
 roman = 0;
 italic = 1;

 halficonwidth = 19; { Half the width of an icon. }

var
 dix,diy:integer;
 ch:array[roman..italic] of raw;
 cfont:byte; { Current font }

 dodgex,dodgey:integer;
 param:byte; { For using arguments code }

 use_icon:byte;

procedure state(x:byte); { Sets "Ready" light to whatever }
var page:byte;
begin
 if ledstatus=x then exit; { Already like that! }
 case x of
  0: setfillstyle(1,black); { Off }
  1: setfillstyle(9,green); { Half-on (menus) }
  2: setfillstyle(1,green); { On (kbd) }
  3: setfillstyle(6,green); { Hit a key }
 end;
 Super_Off;
 for page:=0 to 1 do
  begin setactivepage(page); bar(419,195,438,197); end; Super_On;
 ledstatus:=x;
end;

procedure easteregg;
var
 fv,ff:word;
begin
 background(15);
 for fv:=4 to 100 do
  for ff:=0 to 70 do
   begin sound(fv*100+ff*10); delay(1); end;
 nosound; setcolor(10);
 settextstyle(0,0,3); settextjustify(1,1); outtextxy(320,100,'GIED');
 settextstyle(0,0,1); settextjustify(0,2);
 background(0);
end;

procedure say(x,y:integer; z:string); { Fancy FAST screenwriting }
const locol = 2;
var
 xx,yy,ox,bit,lz,t:byte; yp:integer; offset:boolean;
 itw:array[1..12,1..80] of byte;
begin
 offset:=x mod 8=4; x:=x div 8; lz:=length(z); ox:=0;
 log_scrollline;

 for xx:=1 to lz do
 begin
  case z[xx] of
   ^r: begin cfont:=roman; log_roman; end;
   ^f: begin cfont:=italic; log_italic; end;
   else begin
    inc(ox);
    for yy:=1 to 12 do itw[yy,ox]:=not ch[cfont,z[xx],yy+1];
    log_scrollchar(z[xx]);
   end;
  end;
 end;

 lz:=ox;
 if offset then
 begin { offsetting routine }
  inc(lz);
  for yy:=1 to 12 do
  begin
   bit:=240; itw[yy,lz]:=255;
   for xx:=1 to lz do
   begin
    t:=itw[yy,xx];
    itw[yy,xx]:=bit+t div 16;
    bit:=t shl 4;
   end;
  end;
 end;
 yp:=x+y*80+(1-cp)*pagetop;
 for yy:=1 to 12 do
 begin
  inc(yp,80);
  for bit:=0 to locol do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   move(itw[yy],mem[$A000:yp],lz);
  end;
 end;
end;

{ Here are the procedures that Scroll calls } { So they must be... } {$F+}

procedure normscroll;
const
 egg : array[1..8] of char = ^P^L^U^G^H+'***';
 e : array[1..8] of char = '(c) 1994';
var
 r:char;
 OKtoexit:boolean;
begin
 state(3); seescroll:=true;
 off_virtual;
 on; newpointer(4);
 mousepage(1-cp);

 if demo then get_demorec;

 repeat
  repeat
   check; { was "checkclick;" }

 {$IFDEF RECORD} slowdown; inc(basher.count); {$ENDIF}

   if demo then
   begin
    if demo_ready then break;
    if keypressede then halt;
   end else
    if keypressede then break;
  until (mrelease>0) or (buttona1) or (buttonb1);


  if mrelease=0 then
  begin
   inkey;
   if aboutscroll then
   begin
    move(e[2],e[1],7);
    e[8]:=inchar;
    if e=egg then easteregg;
   end;
   OKtoexit:=inchar in [#13,#27,'+','#'];
   if not OKtoexit then errorled;
  end;

 until (OKtoexit) or (mrelease>0);
 {$IFDEF RECORD} record_one; {$ENDIF}
 screturn:=r='#'; { "back door" }
 state(0); seescroll:=false; mousepage(cp); off;
end;

procedure dialogue;
var r:char;
begin
 state(3); seescroll:=true; r:=#0;
 newpointer(6); on;
 mousepage(1-cp);
 repeat
  repeat
   check;
   if mrelease>0 then
   begin
    if (mx>=dix-65) and (my>=diy-24) and (mx<=dix- 5) and (my<=diy-10)
      then r:='Y';
    if (mx>=dix+ 5) and (my>=diy-24) and (mx<=dix+65) and (my<=diy-10)
      then r:='N';
   end else
       if keypressede then
       begin
        inkey;
        r:=upcase(inchar);
       end;
  until (r<>#0);
 until r in ['Y','N','O','J']; { Yes, Ja, Oui, or No, Non, Nein }
 screturn:=r<>'N';
 state(0); seescroll:=false; mousepage(cp); off;
end;

procedure music_scroll;
var
 r:char;
 value:byte;

 last_one,this_one:byte;

 played:tunetype;

  procedure store(what:byte);
  begin
   move(played[2],played[1],sizeof(played)-1);
   played[31]:=what;
  end;

  function they_match:boolean;
  var fv,mistakes:byte;
  begin
   mistakes:=0;

   for fv:=1 to sizeof(played) do
    if played[fv]<>tune[fv] then
    begin
     inc(mistakes);
    end;

   they_match:=mistakes<5;
  end;

begin
 state(3); seescroll:=true; on;
 newpointer(4);
 repeat
  repeat
   check; { was "checkclick;" }
   if keypressede then break;
  until (mpress>0) or (buttona1) or (buttonb1);

  if mpress=0 then
  begin
   inkey;
   r:=upcase(inchar);  if r='Z' then r:='Y'; { Euro keyboards }

   value:=pos(r,keys);

   if value>0 then
   begin

    last_one:=this_one;
    this_one:=value;

    sound(notes[this_one]);
    delay(100);
    nosound;

    if not dna.ringing_bells then
    begin { These handle playing the right tune. }

     if this_one<last_one then
      store(lower) else

       if this_one=last_one then
        store(same) else

         store(higher);

     if they_match then
     begin
      screturn:=true;
      off;
      state(0); seescroll:=false;

      set_up_timer(8,PROCJacques_wakes_up,reason_Jacques_waking_up);
      exit;
     end;

    end;

   end;

  end;

 until (r in [#13,#27,'+','#']) or (mpress>0);
 screturn:=false;
 off;
 state(0); seescroll:=false;
end;

{ ThatsAll, so put us back to } {$F-}

procedure resetscrolldriver; { phew }
begin
 scrollbells:=0; cfont:=roman; log_epsonroman; use_icon:=0;
 interrogation:=0; { always reset after a scroll comes up. }
end;

procedure dingdongbell; { Pussy's in the well. Who put her in? Little... }
var fv:byte;
begin
 for fv:=1 to scrollbells do errorled; { ring the bell "x" times }
end;

procedure dodgem; { This moves the mouse pointer off the scroll so that
 you can read it. }
begin
 xycheck; { Mx & my now contain xy pos of mouse }
 dodgex:=mx; dodgey:=my; { Store 'em }
 hopto(dodgex,underscroll); { Move the pointer off the scroll. }
end;

procedure undodgem; { This is the opposite of Dodgem. It moves the
 mouse pointer back, IF you haven't moved it in the meantime. }
begin
 xycheck;
 if (mx=dodgex) and (my=underscroll) then
  { No change, so restore the pointer's original position. }
  hopto(dodgex,dodgey);
end;

procedure geticon(x,y:integer; which:byte);
var
 f:file;
 p:pointer;
begin
 assign(f,'icons.avd');
 reset(f,1);
 dec(which);
 seek(f,which*426);
 getmem(p,426);
 blockread(f,p^,426);
 putimage(x,y,p^,0);
 freemem(p,426);
 close(f);
end;

procedure block_drop(fn:string; xl,yl,y:integer);
var
 f:file; bit:byte;
 fv:integer; st:word;
begin
 st:=(y-1)*80+(40-xl div 2)+((1-cp)*pagetop);

 assign(f,fn+'.avd');
 reset(f,1);

 for fv:=1 to yl do
  for bit:=0 to 3 do
  begin;
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockread(f,mem[$A000:st+(fv*80)],xl);
  end;

 close(f);
 bit:=getpixel(0,0);
end;

procedure drawscroll(gotoit:proc); { This is one of the oldest procs in the game. }
var
 b,groi:byte; lx,ly,mx,my,ex,ey:integer; centre:boolean;
 icon_indent:byte;
begin
 off_virtual;
 setvisualpage(cp); setactivepage(1-cp);
 OnCanDoPageSwap:=false; { On can now no longer swap pages. So we can
  do what we want without its interference! }
 log_epsonroman; { Scrolls always START with Roman. }
 lx:=0; ly:=scrolln*6;
 for b:=1 to scrolln do
 begin
  ex:=length(scroll[b])*8; if lx<ex then lx:=ex;
 end;
 mx:=320; my:=100; { Getmaxx & getmaxy div 2, both. }
 lx:=lx div 2; dec(ly,2);

 if use_icon in [1..34] then inc(lx,halficonwidth);

 off;
(* mblit(mx-lx-46,my-ly-6,mx+lx+15,my+ly+6,0,3);*)
 setfillstyle(1,7);
 setcolor(7);
 pieslice(mx+lx,my-ly,360,90,15);
 pieslice(mx+lx,my+ly,270,360,15);
 setcolor(4);
 arc(mx+lx,my-ly,360,90,15);
 arc(mx+lx,my+ly,270,360,15);
 bar(mx-lx-30,my+ly+6,mx+lx,my+ly);
 bar(mx-lx-30,my-ly-6,mx+lx,my-ly);
 bar(mx-lx-15,my-ly,mx+lx+15,my+ly);
 setfillstyle(1,8);
 pieslice(mx-lx-31,my-ly,360,180,15);
 pieslice(mx-lx-31,my+ly,180,360,15);
 setfillstyle(1,4);
 bar(mx-lx-30,my-ly-6,mx+lx,my-ly-6);
 bar(mx-lx-30,my+ly+6,mx+lx,my+ly+6);
 bar(mx-lx-15,my-ly,mx-lx-15,my+ly);
 bar(mx+lx+15,my-ly,mx+lx+15,my+ly);
 ex:=mx-lx; ey:=my-ly;
 dec(mx,lx); dec(my,ly+2);
 setcolor(0); centre:=false;

 case use_icon of
      0: icon_indent:=0; { No icon. }
  1..33: begin           { Standard icon }
          geticon(mx,my+ly div 2,use_icon);
          icon_indent:=53;
         end;
     34: begin block_drop('about',28,76,15);    icon_indent:=0; end;
     35: begin block_drop('gameover',52,59,71); icon_indent:=0; end;
 end;

 for b:=1 to scrolln do
 begin
  case scroll[b,length(scroll[b])] of
   ^C : begin centre:=true;  dec(scroll[b,0]); end;
   ^L : begin centre:=false; dec(scroll[b,0]); end;
   ^Q : begin settextjustify(1,1);
         dix:=mx+lx; diy:=my+ly; scroll[b,1]:=#32; groi:=getpixel(0,0);
(*         inc(diy,14);*)
         shbox(dix-65,diy-24,dix- 5,diy-10,'Yes.');
         shbox(dix+ 5,diy-24,dix+65,diy-10,'No.');
        end;
  end;

  if centre then
   say(320-length(scroll[b])*4+icon_indent,my,scroll[b])
  else
   say(mx+icon_indent,my,scroll[b]);
  log_scrollendline(centre);
  inc(my,12);
 end;

 underscroll:=my+3;
 setvisualpage(1-cp); dingdongbell;
 my:=getpixel(0,0); dropsOK:=false; dodgem;

 gotoit;

 undodgem; dropsOK:=true;
 log_divider;
 setvisualpage(cp); mousepage(cp); off;
(* mblit(ex-46,ey-6,ex+lx*2+15,ey+ly*2+6,3,0);*)
 mblit((ex-46) div 8,ey-6,1+(ex+lx*2+15) div 8,ey+ly*2+6,cp,1-cp);
 blitfix;
 OnCanDoPageSwap:=true; { Normality again }
 on; settextjustify(0,0); (*sink*)
 resetscrolldriver;
 if mpress>0 then after_the_scroll:=true;
end;

procedure bubble(gotoit:proc);
var
 xl,yl,my,xw,yw:integer; fv:byte; p:array[1..3] of pointtype;
 rp1,rp2:pointer; { replace: 1=bubble, 2=pointer }
 xc:integer; { x correction }
begin
 setvisualpage(cp); setactivepage(1-cp);
 OnCanDoPageSwap:=false; { On can now no longer swap pages. So we can
  do what we want without its interference! }
 mousepage(1-cp); { Mousepage }

 setfillstyle(1,talkb); setcolor(talkb); off;

 xl:=0; yl:=scrolln*5;
 for fv:=1 to scrolln do
  if textwidth(scroll[fv])>xl then xl:=textwidth(scroll[fv]);
 xl:=xl div 2;

 xw:=xl+18; yw:=yl+7;
 my:=yw*2-2; xc:=0;

 if (talkx-xw)<0 then xc:=-(talkx-xw);
 if (talkx+xw)>639 then xc:=639-(talkx+xw);

 p[1].x:=talkx-10; p[1].y:=yw;
 p[2].x:=talkx+10; p[2].y:=yw;
 p[3].x:=talkx;    p[3].y:=talky;

(* mblit(talkx-xw+xc,7,talkx+xw+xc,my,0,3);
 mblit(talkx-10,my,talkx+10,talky,0,3);*)
 bar(xc+talkx-xw+10,7,talkx+xw-10+xc,my);
 bar(xc+talkx-xw,12,talkx+xw+xc,my-5);
 pieslice(xc+talkx+xw-10,12,360,90,9);    { TR }
 pieslice(xc+talkx+xw-10,my-5,270,360,9); { BR }
 pieslice(xc+talkx-xw+10,12,90,180,9);    { TL }
 pieslice(xc+talkx-xw+10,my-5,180,270,9); { BL }
 fillpoly(3,p);

 setcolor(talkf); dec(yl,3); settextjustify(1,2);
 for fv:=0 to scrolln-1 do
  outtextxy(talkx+xc,(fv*10)+12,scroll[fv+1]);
 for fv:=1 to scrolln do { These should be separate loops. }
  log_bubbleline(fv,param,scroll[fv]);
 log_divider;

 setvisualpage(1-cp);
 dingdongbell;
 OnCanDoPageSwap:=false;
 on; dropsOK:=false; gotoit; off; dropsOK:=true;
 mblit((talkx-xw+xc) div 8,7,1+(talkx+xw+xc) div 8,my,3,1-cp);
 mblit((talkx-10) div 8,my,1+(talkx+10) div 8,talky,3,1-cp);
 blitfix;

 setvisualpage(cp);
 settextjustify(0,0); on; (*sink;*)
 OnCanDoPageSwap:=true;
 resetscrolldriver;
 if mpress>0 then after_the_scroll:=true;
end;

function ask(question:string):boolean;
begin
 display(question+^M+^Q);
 if screturn and (random(2)=0) { half-and-half chance } then
 begin
  display('...Positive about that?'^S'I'^V^M^Q); { be annoying! }
  if screturn and (random(4)=3) { another 25% chance } then
   display(^I'100% certain??!'^I^V^M^Q); { be very annoying! }
 end;
 ask:=screturn;
end;

procedure resetscroll;
begin
 scrolln:=1; fillchar(scroll,sizeof(scroll),#0);
end;

procedure natural; { Natural state of bubbles }
begin
 talkx:=320; talky:=200; talkb:=8; talkf:=15;
end;

function lsd:string;
var x:string;
begin
 if dna.pence<12 then
 begin { just pence }
  x:=strf(dna.pence)+'d';
 end else
  if dna.pence<240 then
  begin { shillings & pence }
   x:=strf(dna.pence div 12)+'/';
   if (dna.pence mod 12)=0 then x:=x+'-' else x:=x+strf(dna.pence mod 12);
  end else { L, s & d }
   x:='œ'+strf(dna.pence div 240)+'.'+strf((dna.pence div 12) mod 20)+'.'+
    strf(dna.pence mod 12);
 if dna.pence>12 then x:=x+' (that''s '+strf(dna.pence)+'d)';
 lsd:=x;
end;

procedure calldrivers;
var
 fv:word; nn:byte; nnn:char; mouthnext:boolean;
 call_spriterun:boolean; { Only call sprite_run the FIRST time. }

 was_virtual:boolean; { Was the mouse cursor virtual on entry to this proc? }

  procedure strip(var q:string);
  begin
   while pos(#32,q[length(q)])>0 do dec(q[0]); { strip trailing spaces }
  end;

  procedure solidify(n:byte);
  begin
   if pos(#32,scroll[n])=0 then exit; { no spaces }
   { so there MUST be a space there, somewhere... }
   repeat
    scroll[n+1]:=scroll[n,length(scroll[n])]+scroll[n+1];
    dec(scroll[n,0]);
   until scroll[n,length(scroll[n])]=#32;
   strip(scroll[n]);
  end;
begin

 nosound; state(0); screturn:=false; mouthnext:=false;
 call_spriterun:=true;

 case buffer[bufsize] of
   ^d: dec(bufsize); { ^D = (D)on't include pagebreak }
   ^b,^q: ; { ^B = speech (B)ubble, ^Q = (Q)uestion in dialogue box }
  else begin
        inc(bufsize); buffer[bufsize]:=^p;
       end;
 end;
 for fv:=1 to bufsize do
  if mouthnext then
  begin
   if buffer[fv]=^S then param:=0 else
   case buffer[fv] of
    '0'..'9': param:=ord(buffer[fv])-48;
    'A'..'Z': param:=ord(buffer[fv])-55;
   end;
   mouthnext:=false;
  end else
   case buffer[fv] of
    ^p: begin
         if (scrolln=1) and (scroll[1]='') then break;

         if call_spriterun then sprite_run;
         call_spriterun:=false;

         was_virtual:=visible=M_Virtual;
         if was_virtual then off_Virtual;
         drawscroll(normscroll);
         if was_Virtual then on_Virtual;
         resetscroll;
         if screturn then exit;
        end;
    ^g: inc(scrollbells); { #7 = "Bel" }
    ^b: begin
         if (scrolln=1) and (scroll[1]='') then break;

         if call_spriterun then sprite_run;
         call_spriterun:=false;
         case param of
          0: natural; { Not attached: generic bubble with no speaker. }
          1..9: if (param>numtr) or (not tr[param].quick) then
                 begin { not valid }
                  errorled;
                  natural;
                 end
                 else tr[param].chatter; { Normal sprite talking routine. }
          10..36: with quasipeds[param] do
                  begin { Quasi-peds. (This routine performs the same
                   thing with QPs as triptype.chatter does with the
                   sprites.) }
                   with peds[whichped] do
                   begin
                    talkx:=x; talky:=y; { Position. }
                   end;
                   talkf:=fgc; talkb:=bgc; { Colours. }
                  end;
          else begin errorled; natural; end; { not valid }
         end;

         was_virtual:=visible=M_Virtual;
         if was_virtual then off_Virtual;
         bubble(normscroll);
         if was_Virtual then on_Virtual;
         resetscroll;
         if screturn then exit;
        end;
    ^u: begin
         with dna do
          case param of
           1: display(lsd+^d); { insert cash balance (recursion) }
           2: display(words[first_password+pass_num].w+^d);
           3: display(like2drink+^d);
           4: display(favourite_song+^d);
           5: display(worst_place_on_earth+^d);
           6: display(spare_evening+^d);
           { ... }
           9: display(strf(cat_x)+','+strf(cat_y)+^d);
           10: case box_contents of
                #0: begin { Sixpence. }
                     dixi('q',37); { You find the sixpence. }
                     inc(pence,6);
                     box_contents:=nowt;
                     points(2); exit;
                    end;
                nowt: display('nothing at all. It''s completely empty.');
                else display(get_better(box_contents)+'.');
               end;
           11: begin
                nn:=1;
                for nnn:=#1 to numobjs do
                if obj[nnn] then
                begin
                 inc(nn);
                 display(get_better(nnn)+', '+^d);
                end;
               end;
          end;
        end;
    ^v: use_icon:=param;
    ^m: inc(scrolln);
    ^q: begin
         if call_spriterun then sprite_run;
         call_spriterun:=false;

         inc(scrolln); scroll[scrolln]:=^Q;
         was_virtual:=visible=M_Virtual;
         if was_virtual then off_Virtual;
         drawscroll(dialogue); 
         if was_Virtual then on_Virtual;
         resetscroll;
        end;
    ^s : mouthnext:=true;
    ^i : for nn:=1 to 9 do scroll[scrolln]:=scroll[scrolln]+' '
    else
    begin { add new char }
     if length(scroll[scrolln])=50 then
     begin
      solidify(scrolln);
      inc(scrolln);
     end;
     scroll[scrolln]:=scroll[scrolln]+buffer[fv];
   end;
  end;
end;

procedure display(z:string);
begin
 bufsize:=length(z);
 move(z[1],buffer,bufsize);
 calldrivers;
end;

procedure loadfont;
var f:file of raw;
begin
 assign(f,'avalot.fnt'); reset(f); read(f,ch[0]); close(f);
 assign(f,'avitalic.fnt'); reset(f); read(f,ch[1]); close(f);
 assign(f,'ttsmall.fnt'); reset(f); read(f,little); close(f);
end;

procedure okay;
begin
 display('Okay!');
end;

procedure musical_scroll;
var was_virtual:boolean;
begin
 display('To play the harp...'^m^m'Use these keys:'^m^i+
  'Q W E R T Y U I O P [ ]'^m^m'Or press Enter to stop playing.'^d);

 sprite_run;

 was_virtual:=visible=M_Virtual;
 if was_virtual then off_Virtual;
 drawscroll(music_scroll);
 if was_Virtual then on_Virtual;
 resetscroll;
end;

begin
 loadfont;
 resetscrolldriver;
end.