{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 NIM UNIT         A unit version of the pub game (Nim). }

unit Nimunit;

interface

  uses Gyro,Graph,Crt,Pingo,Visa,Lucerna,Logger,Celer;

  procedure play_Nim;


implementation

const
 names: array[false..true] of string[7] = ('Avalot','Dogfood');

var
 old,stones:array[1..3] of byte;
 stonepic:array[0..3,0..22,1..7] of byte; { picture of Nimstone }
 turns:byte;
 Dogfoodsturn:boolean; fv:byte; stonesleft:byte;

 clicked:boolean;

 row,number:byte;

 squeak:boolean;
 mnum,mrow:shortint;

procedure chalk(x,y:integer; z:string);
const greys: array[0..3] of byte = (0,8,7,15);
var fv:byte;
begin
 for fv:=0 to 3 do
 begin
  setcolor(greys[fv]);
  outtextxy(x-fv,y,z);
  sound(fv*100*length(z)); delay(3); nosound; delay(30);
 end;
end;

procedure setup;
const page3 = $AC00;
var
 gd,gm:byte;
 f:file;
 bit:byte;
begin
 setactivepage(3);
 setvisualpage(3);
 cleardevice;
 dawn;

 assign(f,'nim.avd');
 reset(f,1);
 seek(f,41);
 for gm:=0 to 22 do
  for bit:=0 to 3 do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockread(f,stonepic[bit,gm],7);
  end;
 for gd:=1 to 3 do
  for gm:=0 to 22 do
   for bit:=0 to 3 do
   begin
    port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
    blockread(f,mem[page3:3200+gd*2800+gm*80],7);
   end;
 for gm:=0 to 36 do
  for bit:=0 to 3 do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   blockread(f,mem[page3:400+49+gm*80],30);
  end;
 close(f);

 gd:=getpixel(0,0); { clear codes }
 setcolor(4); rectangle(394,50,634,197);
 setfillstyle(1,6); bar(395,51,633,196);
 rectangle(10,5,380,70); bar(11,6,379,69);
 setcolor(15);
 outtextxy(475,53,'SCOREBOARD:');
 setcolor(14);
 outtextxy(420,63,'Turn:');
 outtextxy(490,63,'Player:');
 outtextxy(570,63,'Move:');

 for gd:=1 to 3 do stones[gd]:=gd+2;

 turns:=0; dogfoodsturn:=true;

 chalk(27,15,'Take pieces away with:');
 chalk(77,25,'1) the mouse (click leftmost)');
 chalk(53,35,'or 2) the keyboard:');
 chalk(220,35,#24+'/'+#25+': choose row,');
 chalk(164,45,'+/- or '+#27+'/'+#26+': more/fewer,');
 chalk(204,55,'Enter: take stones.');

 row:=1; number:=1; fillchar(old,sizeof(old),#0); stonesleft:=12;

 { Set up mouse. }
 off_virtual;
 OnCanDoPageSwap:=false;

 setactivepage(3);
 setvisualpage(3);
end;

procedure plotstone(x,y:byte);
var fv,bit:byte; ofs:word;
begin
 ofs:=3200+y*2800+x*8;
 for fv:=0 to 22 do
  for bit:=0 to 3 do
  begin
   port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
   move(stonepic[bit,fv],mem[$AC00:ofs+fv*80],7);
  end;
end;

procedure board;
var fv,ff:byte;
begin
 for fv:=1 to 3 do
  for ff:=1 to stones[fv] do
   plotstone(ff,fv);
end;

procedure startmove;
var tstr:string[2]; ypos:integer;
begin
 inc(turns); str(turns:2,tstr); ypos:=63+turns*10;
 dogfoodsturn:=not dogfoodsturn;
 chalk(433,ypos,tstr);
 chalk(493,ypos,names[dogfoodsturn]);
 old:=stones;
end;

procedure show_changes;
var fv,ff,fq:byte; move:string[2];
begin
 move:=chr(64+row)+chr(48+number);
 chalk(573,63+turns*10,move);
 log_aside(names[dogfoodsturn]+' plays '+move+'.');

 for fv:=1 to 3 do
  if old[fv]>stones[fv] then
   for ff:=stones[fv]+1 to old[fv] do
    for fq:=0 to 22 do fillchar(mem[$AC00:3200+fv*2800+ff*8+fq*80],7,#0);
 dec(stonesleft,number);
end;

procedure checkmouse;
  procedure blip; begin note(1771); delay(3); nosound; clicked:=false; end;
begin
 xycheck; { Check the mouse }
 clicked:=keystatus>0;
 if clicked then
 with r do
  begin { The mouse was clicked. Where?  }
   mrow:=(my-38) div 35;
   if (mrow<1) or (mrow>3) then blip;
   mnum:=stones[mrow]-(mx div 64)+1;
   if (mnum<1) or (mnum>stones[mrow]) then blip;
  end;
end;

procedure takesome;
  procedure less; begin if number>1 then dec(number); end;
var r:char; sr:byte;
begin
 number:=1;
 repeat
  repeat
   sr:=stones[row];
   if sr=0 then begin row:=row mod 3+1; number:=1; end;
  until sr<>0;
  if number>sr then number:=sr;
  setcolor(1); rectangle(63+(sr-number)*64,38+35*row,54+sr*64,63+35*row);
   { Wait for choice }
  on;
  repeat checkmouse until keypressed or clicked;
  if keypressed then r:=upcase(readkey);
  off;

  setcolor(0); rectangle(63+(sr-number)*64,38+35*row,54+sr*64,63+35*row);

  if clicked then
  begin
   number:=mnum;
   row:=mrow;
   exit;
  end else
  begin
   case r of
    #0: case readkey of
         'H': if row>1 then dec(row); { Up }
         'P': if row<3 then inc(row); { Down }
         'K': inc(number);
         'M': less;
         'I': row:=1; { PgUp }
         'Q': row:=3; { PgDn }
         'G': number:=5; { Home- check routine will knock this down to size }
         'O': number:=1; { End }
        end;
    '+': inc(number);
    '-': less;
    'A'..'C': row:=ord(r)-64;
    '1'..'5': number:=ord(r)-48;
    #13: exit; { Enter was pressed }
   end;
  end;
 until false;
end;

procedure endofgame;
var rr:char;
begin
 chalk(595,63+turns*10,'Wins!');
 outtextxy(100,190,'- - -   Press any key...  - - -');
 while keypressed do rr:=readkey;
 repeat check until mpress=0;

 with r do repeat check until keypressed or (mrelease>0);
 if keypressed then rr:=readkey;

 mousepage(cp);
 off;
 on_Virtual;
end;

procedure dogfood; { AI procedure to play the game }
const
 other: array[1..3,1..2] of byte = ((2,3),(1,3),(1,2));
var
 live,fv,ff,matches,thisone,where:byte;
 r,sr:array[1..3] of byte;
 sorted:boolean; temp:byte; inap:array[1..3] of boolean;
 lmo:boolean; { Let Me Out! }
 ooo:byte; { Odd one out }

  function find(x:byte):boolean;
   { This gives True if there's a pile with x stones in. }
  var q:boolean; p:byte;
  begin
   q:=false;
   for p:=1 to 3 do if stones[p]=x then begin q:=true; inap[p]:=true; end;
   find:=q;
  end;

  procedure find_ap(start,stepsize:byte);
  var ff:byte;
  begin
   matches:=0;
   fillchar(inap,sizeof(inap),#0); { blank 'em all }
   for ff:=0 to 2 do if find(start+ff*stepsize) then inc(matches)
    else thisone:=ff;

   { Now.. Matches must be 0, 1, 2, or 3.
     0/1 mean there are no A.P.s here, so we'll keep looking,
     2 means there is a potential A.P. that we can create (ideal!), and
     3 means that we're already in an A.P. (Trouble!). }

   case matches of
    2: begin
        for ff:=1 to 3 do { find which one didn't fit the A.P. }
         if not inap[ff] then ooo:=ff;
        if stones[ooo]>(start+thisone*stepsize) { check it's possible! }
        then begin { create an A.P. }
         row:=ooo; { already calculated }
         { Start+thisone*stepsize will give the amount we SHOULD have here. }
         number:=stones[row]-(start+thisone*stepsize); lmo:=true; exit;
        end;
       end;
    3: begin { we're actually IN an A.P! Trouble! Oooh dear. }
        row:=r[3]; number:=1; lmo:=true; exit; { take 1 from the largest pile }
       end;
   end;
  end;

begin
 live:=0; lmo:=false;
 for fv:=1 to 3 do
 begin
  if stones[fv]>0 then
  begin
   inc(live);
   r[live]:=fv; sr[live]:=stones[fv];
  end;
 end;
 case live of
  1: { Only one is free- so take 'em all }
       begin row:=r[1]; number:=stones[r[1]]; exit; end;
  2: { Two are free- make them equal }
     begin
      if sr[1]>sr[2] then
      begin row:=r[1]; number:=sr[1]-sr[2]; exit; end else { T > b }
       if sr[1]<sr[2] then
       begin row:=r[2]; number:=sr[2]-sr[1]; exit; end else { B > t }
        begin row:=r[1]; number:=1; exit; end; { B = t... oh no, we've lost! }
     end;
  3: { Ho hum... this'll be difficult! }
     begin
      { There are three possible courses of action when we have 3 lines left:
          1) Look for 2 equal lines, then take the odd one out.
          2) Look for A.P.s, and capitalise on them.
          3) Go any old where. }

      for fv:=1 to 3 do { Look for 2 equal lines }
       if stones[other[fv,1]]=stones[other[fv,2]] then
       begin
        row:=fv; { this row } number:=stones[fv]; { all of 'em } exit;
       end;

      repeat
       sorted:=true;
       for fv:=1 to 2 do
        if sr[fv]>sr[fv+1] then
        begin
         temp:=sr[fv+1]; sr[fv+1]:=sr[fv]; sr[fv]:=temp;
         temp:= r[fv+1];  r[fv+1]:= r[fv];  r[fv]:=temp;
         sorted:=false;
        end;
      until sorted;
      { Now we look for A.P.s ... }
      for fv:=1 to 3 do
      begin
       find_ap(fv,1); { there are 3 "1"s }
       if lmo then exit; { cut-out }
      end;
      find_ap(1,2); { only "2" possible }
      if lmo then exit;

      { A.P. search must have failed- use the default move. }
      row:=r[3]; number:=1; exit;
     end;
 end;
end;

procedure play_Nim; { Plays the game. Only procedure in this unit to
 be declared in the interface section. }
var groi:byte;
begin
 if dna.wonNim then
 begin { Already won the game. }
  dixi('Q',6);
  exit;
 end;

 if not dna.asked_Dogfood_about_Nim then
 begin
   dixi('q',84);
   exit;
 end;

 dixi('Q',3);
 inc(dna.playedNim);
 dusk;
 OnCanDoPageSwap:=false;
 copypage(3,1-cp); { Store old screen. } groi:=getpixel(0,0);
 off;

 setup;
 board;
 on;
 mousepage(3);

 repeat
  startmove;
  if Dogfoodsturn then dogfood else takesome;
  dec(stones[row],number);
  show_changes;
 until stonesleft=0;
 endofgame; { Winning sequence is A1, B3, B1, C1, C1, btw. }

 dusk; off;
 OnCanDoPageSwap:=true;
 copypage(1-cp,3); { Restore old screen. } groi:=getpixel(0,0);
 on; dawn;

 if Dogfoodsturn then
 begin { Dogfood won - as usual }
  log_aside('He won.');
  if dna.playedNim=1 then { Your first game }
   dixi('Q',4) { Goody! Play me again? }
  else
   dixi('Q',5); { Oh, look at that! I've won again! }
  pennycheck(4); { And you've just lost 4d! }
 end else
 begin { You won - strange! }
  log_aside('You won.');
  dixi('Q',7); { You won! Give us a lute! }
  dna.obj[lute]:=true;
  objectlist;
  dna.wonNim:=true;
  show_one(1); { Show the settle with no lute on it. }
  points(7); { 7 points for winning! }
 end;

 if dna.playedNim=1 then points(3); { 3 points for playing your 1st game. }

end;

end. { No init part. }