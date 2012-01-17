{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 TRIP42           Trippancy IV point 2 - "Trip Oop 2" }

unit trip42; { Trippancy IV.2 (Trip Oop) }
interface
(* {$R+ but switch it off soon...} *)

uses Graph,Crt,Gyro,Sticks;

const maxgetset = 10;

type
 adxtype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

 triptype = object
             a:adxtype; { vital statistics }
             face,step:byte;
             x,y:integer; { current xy coords }
             ox,oy:array[0..1] of integer; { last xy coords }
             ix,iy:shortint; { amount to move sprite by, each step }
             pic:array[1..24,0..1] of pointer; { the pictures themselves }
             quick,visible,homing,check_me:boolean;
             hx,hy:integer; { homing x & y coords }
             count:byte; { counts before changing step }

             constructor Init(spritenum:byte); { loads & sets up the sprite }
             procedure original; { just sets Quick to false }
             procedure andexor; { drops sprite onto screen }
             procedure turn(whichway:byte); { turns him round }
             procedure appear(wx,wy:integer; wf:byte); { switches him on }
             procedure bounce; { bounces off walls. }
             procedure walk; { prepares for andexor, etc. }
             procedure walkto(xx,yy:integer); { home in on a point }
             procedure stophoming; { self-explanatory }
             procedure homestep; { calculates ix & iy for one homing step }
             procedure speed(xx,yy:shortint); { sets ix & iy, non-homing, etc }
             procedure stopwalk; { Stops the sprite from moving }
             procedure chatter; { Sets up talk vars }
            end;

 getsettype = object
               gs: array[1..maxgetset] of fieldtype;
               numleft:byte;

               constructor Init;
               procedure remember(r:fieldtype);
               procedure recall(var r:fieldtype);
              end;

const

 numtr = 5; { current max no. of sprites }

procedure trippancy_link;

procedure loadtrip;

procedure tripkey(dir:char);

procedure apped(trn,np:byte);

procedure fliproom(room,ped:byte);

function infield(x:byte):boolean; { returns True if you're within field "x" }

function neardoor:boolean; { returns True if you're near a door! }

procedure readstick;

var
 tr:array[1..numtr] of triptype;
 getset:array[0..1] of getsettype;

implementation

uses Scrolls,Lucerna,Dropdown,Access;

(*procedure copier(x1,y1,x2,y2,x3,y3,x4,y4:integer);

  function dropin(xc,yc,x1,y1,x2,y2:integer):boolean;
  { Dropin returns True if the point xc,yc falls within the 1-2 rectangle. }
  begin;
   dropin:=((xc>=x1) and (xc<=x2) and (yc>=y1) and (yc<=y2));
  end;

  function lesser(a,b:integer):integer;
  begin;
   if a<b then lesser:=a else lesser:=b;
  end;

  function greater(a,b:integer):integer;
  begin;
   if a>b then greater:=a else greater:=b;
  end;

begin;
 if dropin(x3,y3,x1,y1,x2,y2)
 or dropin(x3,y4,x1,y1,x2,y2)
 or dropin(x4,y3,x1,y1,x2,y2)
 or dropin(x4,y4,x1,y1,x2,y2) then
 begin; { Overlaps }
  mblit(lesser(x1,x3),lesser(y1,y3),greater(x2,x4),greater(y2,y4),1,0);
 end else
 begin; { Doesn't overlap- copy both of them seperately }
  mblit(x3,y3,x4,y4,1,0); { backwards- why not...? }
  mblit(x1,y1,x2,y2,1,0);
 end;
end; *)

procedure loadtrip;
var gm:byte;
begin;
 for gm:=1 to numtr do tr[gm].original;
 tr[1].init(0);
end;

function checkfeet(x1,x2,oy,y:integer; yl:byte):byte;
var a,c:byte; fv,ff:integer;
begin;
 a:=0; setactivepage(2); if x1<0 then x1:=0; if x2>639 then x2:=639;
 if oy<y then
  for fv:=x1 to x2 do
   for ff:=oy+yl to y+yl do
   begin;
    c:=getpixel(fv,ff);
    if c>a then a:=c;
   end else
  for fv:=x1 to x2 do
   for ff:=y+yl to oy+yl do
   begin;
    c:=getpixel(fv,ff);
    if c>a then a:=c;
   end;
 checkfeet:=a; setactivepage(1-cp);
end;

procedure touchcol(tc:byte);
var bug:boolean; procedure fr(a,b:byte); begin; fliproom(a,b); bug:=false; end;
begin;
 bug:=true; { j.i.c. }
 case dna.room of
  1: fr(2,3);
  2: begin; { main corridor }
      case tc of
       1: fr(3,1); { to the other corridor }
       2: fr(2,1); { to this corridor! Fix this later... }
      end;
     end;
  3: begin; { turn corridor }
      case tc of
       1: fr(2,1); { to the other corridor }
       2: fr(12,1); { through Spludwick's door }
      end;
     end;
  12: fr(3,2);
 end;
 if bug then
 begin;
  display(^G+'Unknown touchcolour ('+strf(tc)+')'+' in '+strf(dna.room)
   +'.'); tr[1].bounce;
 end;
end;

constructor triptype.Init(spritenum:byte);
var gd,gm:integer; s:word; f:file; xx:string[2]; sort,n:byte;
 bigsize:word; p,q:pointer;
begin;
 str(spritenum,xx); assign(f,'c:\avalot\sprite'+xx+'.avd');
 reset(f,1); seek(f,59);
 blockread(f,a,sizeof(a)); blockread(f,bigsize,2);
 setactivepage(3);
 for sort:=0 to 1 do
 begin;
  mark(q); getmem(p,bigsize);
  blockread(f,p^,bigsize);
  off; putimage(0,0,p^,0); release(q); n:=1;
  with a do
   for gm:=0 to (num div seq)-1 do { directions }
    for gd:=0 to seq-1 do { steps }
    begin;
     getmem(pic[n,sort],a.size); { grab the memory }
     getimage((gm div 2)*(xl*6)+gd*xl,(gm mod 2)*yl,
       (gm div 2)*(xl*6)+gd*xl+xl-1,(gm mod 2)*yl+yl-1,
       pic[n,sort]^); { grab the pic }
     inc(n);
   end; {on;}
 end;
 close(f); setactivepage(1-cp);

 x:=0; y:=0; quick:=true; visible:=false;
(* for x:=0 to 1 do getmem(behind[x],a.size);*)
 homing:=false; ix:=0; iy:=0; step:=0; check_me:=a.name='Avalot';
 count:=0;
end;

procedure triptype.original;
begin;
 quick:=false;
end;

procedure triptype.andexor;
var picnum:byte; { Picnum, Picnic, what ye heck }
begin;
 picnum:=face*a.seq+step+1; off;
 putimage(x,y,pic[picnum,0]^,andput);
 putimage(x,y,pic[picnum,1]^,xorput); {on;}
end;

procedure triptype.turn(whichway:byte);
begin;
 if whichway=8 then face:=0 else face:=whichway;
end;

procedure triptype.appear(wx,wy:integer; wf:byte);
begin;
 x:=(wx div 8)*8; y:=wy; ox[cp]:=wx; oy[cp]:=wy; turn(wf);
 visible:=true; ix:=0; iy:=0;
end;

procedure triptype.walk;
var tc:byte; r:fieldtype;
begin;
 with r do
 begin;
  x1:=x-1; y1:=y-2; x2:=x+a.xl+1; y2:=y+a.yl+2;
 end;
 getset[1-cp].remember(r);
 ox[cp]:=x; oy[cp]:=y;
 if homing then homestep;
 x:=x+ix; y:=y+iy;
 if check_me then begin;
  tc:=checkfeet(x,x+a.xl,oy[cp],y,a.yl);
  if tc<>0 then
   with magics[tc] do
    case op of
     exclaim: begin; bounce; dixi('x',data); end;
     bounces: bounce;
     transport: fliproom(hi(data),lo(data));
     unfinished: begin;
                  bounce;
                  display(#7'Sorry.'^c^m'This place is not avaliable yet!');
                 end;
    end;
 end;
 inc(count);
 if ((ix<>0) or (iy<>0)) and (count>1) then
 begin;
  inc(step); if step=a.seq then step:=0; count:=0;
 end;
end;

procedure triptype.bounce;
begin; x:=ox[cp]; y:=oy[cp]; stopwalk; exit; end;

procedure triptype.walkto(xx,yy:integer);
begin;
 speed(xx-x,yy-y); hx:=xx; hy:=yy; homing:=true;
end;

procedure triptype.stophoming;
begin;
 homing:=false;
end;

procedure triptype.homestep;
var temp:integer;
begin;
 if (hx=x) and (hy=y) then
 begin; { touching the target }
  homing:=false; exit;
 end;
 ix:=0; iy:=0;
 if hy<>y then
 begin;
  temp:=hy-y; if temp>4 then iy:=4 else if temp<-4 then iy:=-4 else iy:=temp;
 end;
 if hx<>x then
 begin;
  temp:=hx-x; if temp>4 then ix:=4 else if temp<-4 then ix:=-4 else ix:=temp;
 end;
end;

procedure triptype.speed(xx,yy:shortint);
begin;
 ix:=xx; iy:=yy;
 if (ix=0) and (iy=0) then exit; { no movement }
 if ix=0 then
 begin; { No horz movement }
  if iy<0 then turn(up) else turn(down);
 end else
 begin;
  if ix<0 then turn(left) else turn(right)
 end;
end;

procedure triptype.stopwalk;
begin;
 ix:=0; iy:=0; homing:=false;
end;

procedure triptype.chatter;
begin;
 talkx:=x+a.xl div 2; talky:=y; talkf:=a.fgc; talkb:=a.bgc;
end;

constructor getsettype.Init;
begin;
 numleft:=0; { initialise array pointer }
end;

procedure getsettype.remember(r:fieldtype);
begin;
 inc(numleft);
 gs[numleft]:=r;
end;

procedure getsettype.recall(var r:fieldtype);
begin;
 r:=gs[numleft];
 dec(numleft);
end;

procedure rwsp(t,r:byte);
const xs = 3; ys = 1;
begin;
 with tr[t] do case r of
      up: speed(  0,-ys); down: speed(  0, ys); left: speed(-xs,  0);
   right: speed( xs,  0);   ul: speed(-xs,-ys);   ur: speed( xs,-ys);
      dl: speed(-xs, ys);   dr: speed( xs, ys);
  end;
end;

procedure apped(trn,np:byte);
begin;
 with tr[trn] do
 begin; with peds[np] do appear(x-a.xl div 2,y-a.yl,dir);
  rwsp(trn,tr[trn].face); end;
end;

procedure getback;
var
 fv:byte;
 r:fieldtype;
begin;
 with r do
  with getset[1-cp] do
   while numleft>0 do
   begin;
    recall(r);
    mblit(x1,y1,x2,y2,3,1-cp);
   end;
end;

procedure trippancy_link;
var
 fv:byte;
begin;
 if (ddm_o.menunow) or ontoolbar or seescroll or (not alive) then exit;
 for fv:=1 to numtr do with tr[fv] do if quick then getback;
 for fv:=1 to numtr do with tr[fv] do if quick then walk;
 for fv:=1 to numtr do with tr[fv] do if quick and visible then andexor;
end;

procedure stopwalking;
begin;
 tr[1].stopwalk; dna.rw:=stopped;
end;

procedure tripkey(dir:char);
begin;
 if ctrl=cJoy then exit;

 with tr[1] do
  with dna do
  begin;
   case dir of
    'H': if rw<>up    then
            begin; rw:=up;    rwsp(1,rw); end else stopwalking;
    'P': if rw<>down  then
            begin; rw:=down;  rwsp(1,rw); end else stopwalking;
    'K': if rw<>left  then
            begin; rw:=left;  rwsp(1,rw); end else stopwalking;
    'M': if rw<>right then
            begin; rw:=right; rwsp(1,rw); end else stopwalking;
    'I': if rw<>ur    then
            begin; rw:=ur;    rwsp(1,rw); end else stopwalking;
    'Q': if rw<>dr    then
            begin; rw:=dr;    rwsp(1,rw); end else stopwalking;
    'O': if rw<>dl    then
            begin; rw:=dl;    rwsp(1,rw); end else stopwalking;
    'G': if rw<>ul    then
            begin; rw:=ul;    rwsp(1,rw); end else stopwalking;
    'L': stopwalking;
   end;
 end;
end;

procedure getsetclear;
var fv:byte;
begin;
 for fv:=0 to 1 do getset[fv].Init;
end;

procedure fliproom(room,ped:byte);
begin;
 dusk; getsetclear; enterroom(room); apped(1,ped);
 oldrw:=dna.rw; dna.rw:=tr[1].face; showrw; dawn;
end;

function infield(x:byte):boolean; { returns True if you're within field "x" }
var yy:integer;
begin;
 with fields[x] do with tr[1] do
 begin;
  yy:=y+a.yl;
  infield:=(x>=x1) and (x<=x2) and (yy>=y1) and (yy<=y2);
 end;
end;

function neardoor:boolean; { returns True if you're near a door! }
var ux,uy:integer; fv:byte; nd:boolean;
begin;
 if numfields<9 then
 begin; { there ARE no doors here! }
  neardoor:=false;
  exit;
 end;
 with tr[1] do
 begin;
  ux:=x;
  uy:=y+a.yl;
 end; nd:=false;
 for fv:=9 to numfields do
  with fields[fv] do
  begin;
   if ((ux>=x1) and (ux<=x2) and (uy>=y1) and (uy<=y2)) then nd:=true;
  end;
 neardoor:=nd;
end;

procedure readstick;
var jw:byte;
begin;
 if ctrl=cKey then exit;

 jw:=joyway;

 with tr[1] do
 begin;
  if jw=stopped then stopwalking else
  begin;
   dna.rw:=jw; rwsp(1,dna.rw);
  end;
 end;

 if jw<>oldjw then
 begin;
  showrw;
  oldjw:=jw;
 end;

end;

begin;
 getsetclear;
end.
