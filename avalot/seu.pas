program seu;
uses Graph,Dos,Crt,Tommys;

const
 msize = 100;
 flag = -20047;
 perm = -1;

 Avvy_shoot = 87;
 facing_right = 88;
 facing_left = 94;

 avvy_Y = 150;

 left_margin = 10;
 right_margin = 605;

 shooting : array[0..6] of byte = (87,80,81,82,81,80,87);

 stocks = 28;

 framedelaymax = 2;

 maxrunners = 4;

 times_a_second = (*31*)18;

 flash_time = 20; { If flash_time is <= this, the word "time" will flash. }
                  { Should be about 20. }

 {  --- Scores for various things ---  }

 score_for_hitting_face = 3;
 bonus_for_hitting_escaper = 5;

type
 mtype = record
          Ix,Iy:shortint;
          x,y:integer;
          p:byte;
          timeout:integer;
          cameo:boolean;
          cameo_frame:byte;
          missile:boolean;
          wipe:boolean;
         end;

 xtype = record
          s:word;
          p:pointer;
         end;

 rectype = object
            x1,y1,x2,y2:integer;
           end;

 plottype = object(rectype)
             which:byte;
            end;

 plotmasktype = object(plottype)
                 whichmask:byte;
                end;

var
 x:array[1..100] of xtype;
 m:array[1..100] of mtype;
 r:array[0..1,1..100] of rectype;
 rsize:array[0..1] of byte;
 cp:byte;
 score:word; time:byte;

 ShiftState : Byte ABSOLUTE $40:$17;

 avvypos:word;
 avvyWas:word;
 avvyanim:byte;
 avvyfacing:byte;

 was_facing:byte;

 alt_was_pressed_before:boolean;

 throw_next:byte;

 firing:boolean;

 stockstatus:array[0..6] of byte;

 running:array[1..maxrunners] of record
                         x,y:integer;
                         frame:byte;
                         toohigh,lowest:byte;
                         ix,iy:shortint;
                         framedelay:byte;
                        end;

 score_is:string[5];
 time_is:string[3];

 time_this_second:byte;

 escape_count:word;
 escape_stock:byte;
 escaping,got_out:boolean;

 has_escaped:array[0..6] of boolean;

 count321:byte;

 storage_SEG,storage_OFS:word;

 how_many_have_escaped:byte;

procedure flippage;
begin
 setactivepage(cp);
 cp:=1-cp;
 setvisualpage(cp);
end;

procedure flesh_colours; assembler;
asm
  mov ax,$1012;
  mov bx,21;                 { 21 = light pink (why?) }
  mov cx,1;
  mov dx,seg    @flesh;
  mov es,dx;
  mov dx,offset @flesh;
  int $10;

  mov dx,seg    @darkflesh;
  mov es,dx;
  mov dx,offset @darkflesh;
  mov bx,5;                 { 5 = dark pink. }
  int $10;

  jmp @TheEnd;

 @flesh:
  db 56,35,35;

 @darkflesh:
  db 43,22,22;

 @TheEnd:
end;

function overlap(a1x,a1y,a2x,a2y,b1x,b1y,b2x,b2y:word):boolean;
begin { By De Morgan's law: }
 overlap:=(a2x>=b1x) and (b2x>=a1x) and (a2y>=b1y) and (b2y>=a1y);
end;

procedure getsize(w:byte; var xx,yy:integer);
var n:array[0..1] of integer;
begin
 move(x[w].p^,n,4);
 xx:=n[0]; yy:=n[1];
end;

procedure display(xx,yy:integer; w:byte);
begin
 putimage(xx,yy,x[w].p^,0);
end;

function get_stock_number(x:byte):byte;
begin
 while has_escaped[x] do
 begin
  inc(x);
  if x=7 then x:=0;
 end;
 get_stock_number:=x;
end;

procedure cameo_display(xx,yy:integer; w1,w2:byte);
begin
 putimage(xx,yy,x[w2].p^,andput);
 putimage(xx,yy,x[w1].p^,xorput);
end;

procedure blankit;
var fv:byte;
begin
 for fv:=1 to rsize[cp] do
 with r[cp,fv] do
  bar(x1,y1,x2,y2);
 rsize[cp]:=0;
end;

procedure blank(xx1,yy1,xx2,yy2:integer);
begin
 inc(rsize[cp]);
 with r[cp,rsize[cp]] do
 begin
  x1:=xx1;
  y1:=yy1;
  x2:=xx2;
  y2:=yy2;
 end;
end;

procedure movethem;
var fv:byte;
begin
 for fv:=1 to msize do
  with m[fv] do
   if x<>flag then
   begin
    x:=x+ix;
    y:=y+iy;
   end;
end;

procedure plotthem;
var fv:byte; xx,yy:integer;
begin
 for fv:=1 to msize do
  with m[fv] do
  if x<>flag then
   begin
    if cameo then
    begin
     cameo_display(x,y,p,cameo_frame);
     if cp=0 then begin inc(cameo_frame,2); inc(p,2); end;
    end else display(x,y,p);
    getsize(p,xx,yy);
    if wipe then blank(x,y,x+xx,y+yy);
    if timeout>0 then
    begin
     dec(timeout);
     if timeout=0 then x:=flag;
    end;
   end;
end;

procedure define(xx,yy:integer; pp:byte; ixx,iyy:shortint; timetime:integer;
 is_a_missile,do_we_wipe:boolean);
var which:byte;
begin
 for which:=1 to msize do
  with m[which] do
  begin
   if x=flag then
   begin
    x:=xx;
    y:=yy;
    p:=pp;
    ix:=ixx;
    iy:=iyy;
    timeout:=timetime;
    cameo:=false;
    missile:=is_a_missile;
    wipe:=do_we_wipe;

    exit;
   end;
  end;
end;

procedure define_cameo(xx,yy:integer; pp:byte; timetime:integer);
var which:byte;
begin
 for which:=1 to msize do
  with m[which] do
  begin
   if x=flag then
   begin
    x:=xx;
    y:=yy;
    p:=pp;
    ix:=0;
    iy:=0;
    timeout:=timetime;
    cameo:=true;
    cameo_frame:=pp+1;
    missile:=false;
    wipe:=false;

    exit;
   end;
  end;
end;

procedure get_score;
var fv:byte;
begin
 str(score:5,score_is);
 for fv:=1 to 5 do
  if score_is[fv]=' ' then
   score_is[fv]:='0';
end;

procedure get_time;
var fv:byte;
begin
 str(time:5,time_is);
 for fv:=1 to 3 do
  if time_is[fv]=' ' then
   time_is[fv]:='0';
end;

procedure display_const(x,y:integer; what:byte);
var page:byte;
begin
 for page:=0 to 1 do
 begin
  setactivepage(page);
  display(x,y,what);
 end;
 setactivepage(1-cp);
end;

procedure show_stock(x:byte);
begin
 if escaping and (x=escape_stock) then
 begin
  display_const(x*90+20,30,stocks+2);
  exit;
 end;
 if stockstatus[x]>5 then exit;
 display_const(x*90+20,30,stocks+stockstatus[x]);
 stockstatus[x]:=1-stockstatus[x];
end;

procedure show_score;
var
 fv:byte;
 score_was:string[5];
begin
 score_was:=score_is; get_score;
 for fv:=1 to 5 do
  if score_was[fv]<>score_is[fv] then
   display_const(30+fv*10,0,ord(score_is[fv])-47);
end;

procedure show_time;
var
 fv:byte;
 time_was:string[3];
begin
 time_was:=time_is; get_time;
 for fv:=1 to 3 do
  if time_was[fv]<>time_is[fv] then
   display_const(130+fv*10,0,ord(time_is[fv])-47);
end;

procedure gain(howmuch:shortint);
begin
 if (-howmuch>score) then score:=0 else
  score:=score+howmuch;
 show_score;
end;

procedure new_escape;
begin
 escape_count:=random(18)*20;
 escaping:=false;
end;

procedure instructions;
  procedure nextpage;
  var c:char;
  begin
   outtextxy(400,190,'Press a key for next page >');
   c:=readkey;
   cleardevice;
  end;
begin
 display(25,25,facing_right);
 outtextxy(60,35,'< Avvy, our hero, needs your help - you must move him around.');
 outtextxy(80,45,'(He''s too terrified to move himself!)');

 outtextxy(0,75,'Your task is to prevent the people in the stocks from escaping');
 outtextxy(0,85,'by pelting them with rotten fruit, eggs and bread. The keys are:');
  outtextxy(80,115,'LEFT SHIFT'); outtextxy(200,115,'Move left.');
 outtextxy(72,135,'RIGHT SHIFT'); outtextxy(200,135,'Move right.');
        outtextxy(136,155,'ALT'); outtextxy(200,155,'Throw something.');
 nextpage;

 display(25,35,stocks);
 outtextxy(80,35,'This man is in the stocks. Your job is to stop him getting out.');
 outtextxy(88,45,'UNFORTUNATELY... the locks on the stocks are loose, and every');
 outtextxy(88,55,'so often, someone will discover this and try to get out.');
 display(25, 85,stocks+2);
 outtextxy(80, 85,'< Someone who has found a way out!');
 outtextxy(88, 95,'You MUST IMMEDIATELY hit people smiling like this, or they');
 outtextxy(88,105,'will disappear and lose you points.');
 display(25,125,stocks+5);
 display(25,155,stocks+4);
 outtextxy(80,125,'< Oh dear!');
 nextpage;

 outtextxy(0,35,'Your task is made harder by:');
 display(25,55,48);
 outtextxy(60,55,'< Yokels. These people will run in front of you. If you hit');
 outtextxy(68,65,'them, you will lose MORE points than you get hitting people');
 outtextxy(68,75,'in the stocks. So BEWARE!');
 outtextxy(80,125,'Good luck with the game!');
 nextpage;
end;

procedure setup;
var
 gd,gm:integer;
 f:file;
 rkv:char;
begin
 rkv:=upcase(readkey);
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 flesh_colours;

 assign(f,'notts.avd');
 reset(f,1); gd:=1;
 score:=0; time:=120; score_is:='(c)94';
 time_this_second:=0;

 while not eof(f) do
  with x[gd] do
  begin
   blockread(f,s,2);
   getmem(p,s);
   blockread(f,p^,s);
   inc(gd);
  end;
 close(f);

 if (rkv='I') or ((rkv=#0) and (readkey=cf1)) then instructions;

 for gd:=0 to 6 do
 begin
  stockstatus[gd]:=random(2);
  show_stock(gd);
 end;

 fillchar(m,sizeof(m),#177);
 setfillstyle(1,0);
 cp:=0;
 flippage;
 fillchar(rsize,sizeof(rsize),#0);
 avvyWas:=320;
 avvypos:=320;
 avvyanim:=1;
 avvyfacing:=facing_left;

 alt_was_pressed_before:=false;
 throw_next:=74;
 firing:=false;

 for gd:=1 to maxrunners do
  with running[gd] do
  begin
   x:=flag;
  end;

 new_escape;
 fillchar(has_escaped,sizeof(has_escaped),#0); { All false. }
 count321:=255; { Counting down. }

 { Set up status line. }

 display_const(0,0,17); { Score: }
 show_score;            { value of score (00000 here) }
 display_const(110,0,20); { Time: }
 show_time;            { value of time }

 randomize;

 how_many_have_escaped:=0;
end;

procedure init_runner(xx,yy:integer; f1,f2:byte; ixx,iyy:shortint);
var fv:byte;
begin
 for fv:=1 to maxrunners do
  with running[fv] do
   if x=flag then
   begin
    x:=xx; y:=yy;
    frame:=f1;
    toohigh:=f2;
    lowest:=f1;
    ix:=ixx; iy:=iyy;
    if (ix=0) and (iy=0) then ix:=2; { To stop them running on the spot! }
    framedelay:=framedelaymax;
    exit;
   end;
end;

procedure titles;
var
 r:registers;
 a:byte absolute $A000:0;
 f:file;
 bit:byte;
begin
 r.ax:=$D;
 intr($10,r);

 assign(f,'shoot1.avd');
 reset(f,1);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,8000);
 end;
 close(f);
end;
{
procedure animate3;
begin
 define(100,100,10,1,0,perm,false,true);
 define( 50,20 ,30,3,3,30,false,true);
 repeat;
  blankit;
  plotthem;
  movethem;
  flippage;
  delay(100);
 until keypressed;
end;

procedure animate2;
var
 x,n:byte;
 helpx:integer;
 helpdir:shortint;
 helpani:byte;
begin
 x:=0; n:=0; helpani:=0;
 helpx:=10; helpdir:=1;
 setfillstyle(1,0);

 repeat
  display(x*52,0,n+28);
  inc(x); inc(n);

  if x=13 then
  begin
   bar(helpx-2,50,helpx+5,80);
   if helpdir>0 then
    display(helpx,50,80-helpani)
   else
    display(helpx,50,86-helpani);
   helpx:=helpx+helpdir*5;
   if (helpx>600) or (helpx<3) then helpdir:=-helpdir;
   if helpani=0 then helpani:=5 else dec(helpani);

   x:=0;
(*   delay(100);*)
  end;
  if n=6 then n:=0;
 until keypressed;
end;
}

procedure move_avvy;
begin
  if avvyWas<avvypos then
  begin
(*   bar(avvyWas,avvy_Y,avvyPos,Avvy_Y+85);*)
   avvyfacing:=facing_right;
  end else if avvyWas>avvypos then
  begin
(*   bar(avvyWas+32,Avvy_Y,avvyPos+33,Avvy_Y+85);*)
   avvyfacing:=facing_left;
  end;

  if not firing then
  begin
   if avvyWas=avvypos then
    avvyanim:=1
   else
   begin
    inc(avvyanim);
    if avvyanim=6 then avvyanim:=0;
   end;
  end;

 if avvyfacing=avvy_Shoot then
  define(avvypos,avvy_Y,shooting[avvyanim],0,0,1,false,true)
 else
  define(avvypos,avvy_Y,avvyanim+avvyfacing,0,0,1,false,true);

 avvyWas:=avvypos;

 if (avvyfacing=avvy_Shoot) then
 begin
  if (avvyanim=6) then
  begin
   avvyfacing:=was_facing;
   avvyanim:=0;
   firing:=false;
  end else inc(avvyanim);
 end;
end;

procedure read_kbd;
begin

 if firing then exit;

 if (shiftstate and 8)>0 then
 begin { Alt - shoot }
  if (alt_was_pressed_before) or (count321<>0) then exit;
  alt_was_pressed_before:=true;
  firing:=true;
  define(avvypos+27,avvy_Y+5,throw_next,0,-2,53,true,true);
  inc(throw_next); if throw_next=80 then throw_next:=74;
  avvyanim:=0;
  was_facing:=avvyfacing;
  avvyfacing:=avvy_Shoot;
  exit;
 end;

 alt_was_pressed_before:=false;

 if (shiftstate and 1)>0 then
 begin { Move right. }
  inc(avvypos,5);
  if avvypos>right_margin then avvypos:=right_margin;
  exit;
 end;

 if (shiftstate and 2)>0 then
 begin { Move left. }
  dec(avvypos,5);
  if avvypos<left_margin then avvypos:=left_margin;
 end;

end;

procedure animate;
var fv:byte;
begin
 if random(10)=1 then show_stock(get_stock_number(random(6)));
 for fv:=0 to 6 do
  if stockstatus[fv]>5 then
  begin
   dec(stockstatus[fv]);
   if stockstatus[fv]=8 then
   begin
    stockstatus[fv]:=0;
    show_stock(fv);
   end;
  end;
end;

procedure collision_check;
var
 fv:byte;
 dist_from_side:integer;
 this_stock:byte;
begin
 for fv:=1 to 100 do
  with m[fv] do
   if x<>flag then
   begin
    if (missile) and (y<60) and (timeout=1) then
    begin
(*     sound(177); delay(1); nosound;*)
     dist_from_side:=(x-20) mod 90;
     this_stock:=((x-20) div 90);
     if (not has_escaped[this_stock]) and
      (dist_from_side>17) and (dist_from_side<34) then
     begin
      sound(999); delay(3); nosound;
      define(x+20,y,26+random(2),3,1,12,false,true); { Well done! }
      define(this_stock*90+20,30,31,0,0,7,false,false); { Face of man }
      define_cameo(this_stock*90+20+10,35,40,7); { Splat! }
      define(this_stock*90+20+20,50,34+random(5),0,2,9,false,true); { Oof! }
      stockstatus[this_stock]:=17;
      gain(score_for_hitting_face);

      if (escaping) and (escape_stock=this_stock) then
      begin { Hit the escaper. }
       sound(1777); delay(1); nosound;
       gain(bonus_for_hitting_escaper);
       escaping:=false; new_escape;
      end;
     end else
     begin
      define(x,y,83+random(3),2,2,17,false,true); { Missed! }
      if (not has_escaped[this_stock]) and
       ((dist_from_side>3) and (dist_from_side<43)) then
      begin
       define(this_stock*90+20,30,30,0,0,7,false,false); { Face of man }
       if dist_from_side>35 then
        define_cameo(x-27,35,40,7) { Splat! }
       else
        define_cameo(x-7,35,40,7);
       stockstatus[this_stock]:=17;
      end;
     end;
    end;
   end;
end;

function sgn(a:integer):shortint;
begin
 if a=0 then begin sgn:=0; exit; end;
 if a>0 then begin sgn:=1; exit; end;
 sgn:=-1;
end;

procedure turn_around(who:byte; randomX:boolean);
begin
 with running[who] do
 begin
  if randomX then
  begin
   if ix>0 then ix:=-(random(5)+1) else ix:=(random(5)+1);
  end else
   ix:=-ix;
  iy:=-iy;
 end;
end;

procedure bump_folk;
var fv,ff:byte;
begin
 for fv:=1 to maxrunners do
  if running[fv].x<>flag then
   for ff:=fv+1 to maxrunners do
    if (running[ff].x<>flag) and
     overlap(running[fv].x,running[fv].y,
             running[fv].x+17,running[fv].y+24,
             running[ff].x,running[ff].y,
             running[ff].x+17,running[ff].y+24) then
     begin
      turn_around(fv,false); { Opp. directions. }
      turn_around(ff,false);
     end;
end;

procedure people_running;
var fv:byte;
begin
 if count321<>0 then exit;
 for fv:=1 to maxrunners do
  with running[fv] do
   if x<>flag then
   begin
    if ((y+iy)<=53) or ((y+iy)>=120) then
    begin
     iy:=-iy;
    end;

    if ix<0 then
     define(x,y,frame,0,0,1,false,true)
    else
     define(x,y,frame+7,0,0,1,false,true);
    if framedelay=0 then
    begin
     inc(frame); if frame=toohigh then frame:=lowest;
     framedelay:=framedelaymax;
     y:=y+iy;
    end else dec(framedelay);

    if ((x+ix)<=0) or ((x+ix)>=620) then turn_around(fv,true);

    x:=x+ix;
   end;
end;

procedure update_time;
begin
 if count321<>0 then exit;
 inc(time_this_second);
 if time_this_second < times_a_second then exit;
 dec(time);
 show_time;
 time_this_second:=0;
 if time<=flash_time then
  if odd(time) then display_const(110,0,20) { Normal time }
   else display_const(110,0,86) { Flash time }
end;

procedure hit_people;
var fv,ff:byte;
begin
 if count321<>0 then exit;
 for fv:=1 to 100 do
  with m[fv] do
   if missile and (x<>flag) then
    for ff:=1 to maxrunners do
     if (running[ff].x<>flag) and
        overlap(x,y,x+7,y+10,
                running[ff].x,running[ff].y,
                running[ff].x+17,
                running[ff].y+24) then
      begin
       sound(7177);
(*       setcolor(4);
       rectangle(x,y,x+7,y+10);
       rectangle(running[ff].x,running[ff].y,
                 running[ff].x+17,
                 running[ff].y+24);*)
       nosound;
       x:=flag;
       gain(-5);
       define(running[ff].x+20,running[ff].y+3,
              34+random(6),1,3,9,false,true); { Oof! }
       define(x,y,83,1,0,17,false,true); { Oops! }
      end;
end;

procedure escape_check;
begin
 if count321<>0 then exit;
 if escape_count>0 then begin dec(escape_count); exit; end;

 { Escape_count = 0; now what? }

 if escaping then
 begin
  if got_out then
  begin
   new_escape; escaping:=false;
   display_const(escape_stock*90+20,30,stocks+4);
  end else
  begin
   display_const(escape_stock*90+20,30,stocks+5);
   escape_count:=20; got_out:=true;
   define(escape_stock*90+20,50,25,0,2,17,false,true); { Escaped! }
   gain(-10);
   has_escaped[escape_stock]:=true;

   inc(how_many_have_escaped);

   if how_many_have_escaped = 7 then
   begin
    for time:=0 to 1 do
    begin
     setactivepage(time);
     cleardevice;
    end;
    setactivepage(1-cp);

    memW[Storage_SEG:Storage_OFS+1]:=0;
    repeat until memW[Storage_SEG:Storage_OFS+1]>9;

    setvisualpage(1-cp);
    display(266,90,23);

    memW[Storage_SEG:Storage_OFS+1]:=0;
    repeat until memW[Storage_SEG:Storage_OFS+1]>72;

    setvisualpage(cp);

    memW[Storage_SEG:Storage_OFS+1]:=0;
    repeat until memW[Storage_SEG:Storage_OFS+1]>9;

    time:=0;
   end;
  end;
 end else
 begin
  escape_stock:=get_stock_number(random(7)); escaping:=true; got_out:=false;
  display_const(escape_stock*90+20,30,stocks+2); { Smiling! }
  escape_count:=200;
 end;
end;

procedure check321;
begin
 if count321=0 then exit;
 dec(count321);
 case count321 of
   84: define(320, 60,16, 2, 1,94,false,true);
  169: define(320, 60,15, 0, 1,94,false,true);
  254: begin
        define(320, 60,14,-2, 1,94,false,true);
        define(  0,100,18, 2, 0,254,false,true);
       end;
 end;
end;

procedure check_params;
var e:integer;
  procedure not_bootstrap;
  begin
   writeln('This is not a standalone program!');
   halt(255);
  end;
begin
 if paramstr(1)<>'jsb' then not_bootstrap;

 val(paramstr(2),storage_SEG,e); if e<>0 then not_bootstrap;
 val(paramstr(3),storage_OFS,e); if e<>0 then not_bootstrap;

end;

begin
 check_params;

 titles;
 setup;
 init_runner( 20, 70,48,54, random(5)+1,random(4)-2);
 init_runner(600, 70,48,54, random(5)+1,random(4)-2);
 init_runner(600,100,61,67,-random(5)+1,random(4)-2);
 init_runner( 20,100,61,67,-random(5)+1,random(4)-2);
 repeat
  memW[Storage_Seg:Storage_Ofs+1]:=0;

  blankit;
  hit_people;
  plotthem;
  movethem;
  move_avvy;
  bump_folk;
  people_running;
  animate;
  escape_check;

  collision_check;

  update_time;

  check321;

  read_kbd;
  flippage;
  repeat until memW[Storage_SEG:Storage_OFS+1]>0;

 until time=0;

(* textmode(259);
 textattr:=1;
 writeln('Your final score was: ',score,'.');
 readln;*)
 mem[Storage_SEG:Storage_OFS]:=score;
end.