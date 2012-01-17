program highscores;
uses Graph,Crt;

type
 scoretype = record
	      name:string[39];
              score:word;
             end;

 ratetype = record
             rank:string[10];
             lowest:word;
            end;

 tabletype = record
              a:array[1..12] of scoretype;
              light:byte;
             end;

const
 ratings : array[1..9] of ratetype =
  ((rank: 'Rubbish';    lowest:   0),
   (rank: 'Beginner';   lowest:   1),
   (rank: 'Poor';       lowest:  10),
   (rank: 'Average';    lowest:  30),
   (rank: 'Fair';       lowest:  50),
   (rank: 'Not bad';    lowest:  70),
   (rank: 'Good';       lowest: 100),
   (rank: 'Great';      lowest: 200),
   (rank: 'Fantastic!'; lowest: 330));

var
 gd,gm:integer;
 table:tabletype;

function ratingname(x:word):byte;
var fv:byte;
begin;
 for fv:=9 downto 1 do
  if x>=ratings[fv].lowest then
  begin;
   ratingname:=fv;
   exit;
  end; { bad style }
end;

procedure title;
const
 shades : array[0..6] of byte =
  (blue,lightgray,darkgray,blue,lightblue,blue,darkgray);
 message : string = 'A v a l o t  :  H i g h - S c o r e s';
var
 x:byte;
 len:integer;

 procedure sayfast(x,y:integer);
 var
  anchor:integer; fv:byte;
 begin;
  anchor:=-296;
  for fv:=1 to length(message) do
  begin;
   if message[fv]<>#32 then outtextxy(x+anchor,y-8,message[fv]);
   inc(anchor,16);
  end;
 end;

begin;
 settextstyle(0,0,2); (*settextjustify(1,1);*)
 len:=textheight(message);
 for x:=6 downto 0 do
 begin;
  setcolor(shades[x]);
  sayfast(320-x*2,20-x);
  if x>0 then
  begin;
   sayfast(320+x*2,20-x);
   sayfast(320+x*2,20+x);
   sayfast(320-x*2,20+x);
  end;
 end;
end;

procedure newtable;
const
 names : array[1..12] of string[15] =
  ('Mike','Liz','Thomas','Mark','Mandy','Andrew','Lucy Tryphena','',
   'Thanks to all','who helped...','','Have fun!');
var fv:byte;
begin;
 fillchar(table,sizeof(table),#177);
 for fv:=1 to 12 do
  with table.a[fv] do
  begin;
   name:=names[fv];
   score:=193-fv*16;
  end;
 table.light:=1;
end;

function strf(x:longint):string; { From Gyro. Delete when integrated. }
var q:string;
begin;
 str(x,q); strf:=q;
end;

procedure sparkle(x,y:integer; z:string);
begin;
 setcolor(cyan);  outtextxy(x-1,y-1,z);
 setcolor(blue);  outtextxy(x+1,y+1,z);
 setcolor(white); outtextxy(x  ,y  ,z);
end;

procedure drawtable;
var fv,last,now:byte;
begin;
 setfillstyle(1,8);
 bar(  0, 40,105, 58); bar(110, 40,400, 58);
 bar(405, 40,490, 58); bar(495, 40,640, 58);
 bar(  5, 60,105,181); bar(110, 60,400,181);
 bar(405, 60,490,181); bar(495, 60,635,181);
 bar(  0,185,640,190);
 setcolor(lightred); settextstyle(0,0,1); settextjustify(0,0);
 outtextxy( 45,55,'Number:');
 outtextxy(120,55,'Name:');
 outtextxy(420,55,'Score:');
 outtextxy(500,55,'Rating:');
 setcolor(white); last:=177;
 for fv:=1 to 12 do
  with table.a[fv] do
  begin;
   settextjustify(righttext,bottomtext);
   sparkle(100,60+fv*10,strf(fv)+'.');
   sparkle(455,60+fv*10,strf(score));
   if fv=table.light then sparkle(70,60+fv*10,'ออ'+^P);

   settextjustify(lefttext,bottomtext);
   sparkle(120,60+fv*10,name);
   now:=ratingname(score);
   if now<>last then
    sparkle(510,60+fv*10,ratings[ratingname(score)].rank)
   else
    sparkle(517,57+fv*10,',,');
   last:=now;
  end;
end;

procedure message(x:string);
begin;
 setfillstyle(1,8); bar(0,190,640,200);
 settextjustify(1,1); sparkle(320,195,x);
end;

procedure sorthst;
var fv:byte; ok:boolean; temp:scoretype;
begin;
 repeat
  ok:=true;
  for fv:=1 to 11 do
   with table do
    if a[fv].score<a[fv+1].score then
    begin;
     temp:=a[fv]; a[fv]:=a[fv+1]; a[fv+1]:=temp; { swap 'em }
     light:=fv; { must be- that's the only unsorted one }
     ok:=false; { So, we try again. }
    end;
 until ok;
end;

procedure entername;
var i:string[34]; x,y:integer; r:char; counter:integer; flash:byte;

  procedure cursor(col:byte);
  begin;
   setcolor(col);
   outtextxy(x,y,'?');
  end;

begin;
 y:=60+table.light*10; i:=''; settextjustify(2,0); counter:=999; flash:=0;
 repeat
  x:=128+length(i)*8;
  repeat
   inc(counter);
   if counter=1000 then
   begin;
    cursor(4+flash*10);
    flash:=1-flash;
    counter:=0;
   end;
   delay(1);
  until keypressed;
  cursor(8);
  sound(17177); r:=readkey; nosound;
  if r=#8 then begin;
   if i[0]>#0 then begin;
    bar(x-17,y-10,x-8,y);
    dec(i[0]); sparkle(x-16,y,i[length(i)]);
   end;
  end else begin;
   if (i[0]<#34) and (r<>#13) then begin;
    sparkle(x,y,r);
    i:=i+r;
   end;
  end;
  counter:=999;
 until r=#13;
end;

procedure newscore(sc:word);
begin;
 with table.a[12] do
  if sc>score then
  begin;
   name:=''; score:=sc; table.light:=10; sorthst; drawtable;
   message('Well done! Please enter your name, then press Return...');
   entername;
  end else drawtable; { too low for score }
 message('Press Space to continue...');
 repeat until keypressed and (readkey=#32);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 title;
 newtable;
 newscore({177}0);
end.