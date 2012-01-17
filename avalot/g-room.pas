program g_room;
uses Graph,Crt;
{$R+}

const
 adjustment : array[1..5] of shortint = (7,0,7,7,7);

 plane_to_use : array[0..3] of byte = (2,2,2,3);

 waveorder : array[1..5] of byte = (5,1,2,3,4);

 glerkfade : array[1..26] of byte =
  (1,1,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,4,4,3,3,3,2,2,1);

 greldetfade : array[1..18] of byte = (1,2,3,4,5,6,6,6,5,5,4,4,3,3,2,2,1,1);

type
 flavourtype = (ch_EGA,ch_BGI,ch_Natural,ch_Two,ch_One);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                  end;

 glerktype = array[1..6,0..3,0..34,1..9] of byte;


var
 f:file;
 cb:chunkblocktype;
 ghost:array[1..5,2..3,0..65,0..25] of byte;
 fv:byte;
 memlevel:pointer;
 y,yy,bit,xofs:byte;

 eyes:array[0..1] of pointer;
 exclamation:pointer;
 aargh:array[1..6] of pointer;
 bat:array[1..3] of pointer;
 glerk:^glerktype;
 green_eyes:array[1..5] of pointer;
 greldet:array[1..6,false..true] of pointer;

 aargh_where:array[1..6] of pointtype;

 gd,gm:integer; gb:boolean;

 glerkstage:byte;

 bat_x,bat_y:integer; bat_count:word; aargh_count:shortint;

 greldet_x,greldet_y:integer; greldet_count:byte; red_greldet:boolean;

procedure plain_grab;
 { Just grabs the next one and puts it where it's told to. }
var
 xx,yy,xofs:integer;
begin;
 blockread(f,cb,sizeof(cb));

 with cb do
  case flavour of
   ch_One: begin;
            xofs:=x div 8;
            bit:=3;
             for yy:=0 to yl do
             begin;
              port[$3c4]:=2; port[$3ce]:=4;
              port[$3C5]:=1 shl bit; port[$3CF]:=bit;

              blockread(f,mem[$A000:(yy+y)*80+xofs],xl div 8);
             end;
           end;
   ch_EGA: begin;
            xofs:=x div 8;
            bit:=3;
            for bit:=0 to 3 do
             for yy:=0 to yl do
             begin;
              port[$3c4]:=2; port[$3ce]:=4;
              port[$3C5]:=1 shl bit; port[$3CF]:=bit;

              blockread(f,mem[$A000:(yy+y)*80+xofs],xl div 8);
             end;
           end;
  end;
end;

procedure get_me(var p:pointer);
begin;
 blockread(f,cb,sizeof(cb));
 { Take it for granted that cb.flavour = ch_BGI! }

 with cb do
 begin;
  getmem(p,size);
  blockread(f,p^,size);
 end;
end;

procedure get_me_aargh(which:byte);
begin;
 blockread(f,cb,sizeof(cb));
 { Take it for granted that cb.flavour = ch_BGI! }

 with cb do
 begin;
  getmem(aargh[which],size);
  blockread(f,aargh[which]^,size);
 end;

 with aargh_where[which] do
 begin
  x:=cb.x;
  y:=cb.y;
 end;
end;

procedure wait(how_long:word);
var i:word; r:char;
begin
 for i:=1 to how_long do
  if keypressed then
  begin
   sound(6177);
   while keypressed do r:=readkey;
   delay(1);
   nosound;
  end else
   delay(1);
end;

procedure do_bat;
var
 dx,iy:shortint; batimage:byte; batsize:pointtype;
   procedure super_blank;
   var
    oldsize:pointtype;
   begin
    move(bat[batimage-1]^,oldsize,4);
    bar(bat_x+batsize.x,bat_y,bat_x+oldsize.x,bat_y+oldsize.y);
   end;
begin
 inc(bat_count);

 if odd(bat_count) then
 begin
  case bat_count of
   1..90: begin dx:=2; iy:=1; batimage:=1; end;
   91..240: begin dx:=1; iy:=1; batimage:=2; end;
   241..260: begin dx:=1; iy:=4; batimage:=3; end;
  end;

  move(bat[batimage]^,batsize,4);

  if (bat_count=91) or (bat_count=241) then
   super_blank; { When the bat changes, blank out the old one. }

  bar(bat_x,bat_y,bat_x+batsize.x,bat_y+iy);
  bar(bat_x+batsize.x,bat_y,bat_x+batsize.x-dx,bat_y+batsize.y);

  dec(bat_x,dx); inc(bat_y);
  putimage(bat_x,bat_y,bat[batimage]^,0);
 end;
end;

procedure big_green_eyes(how:byte);
begin
 putimage(330,103,green_eyes[how]^,0);
 putimage(376,103,green_eyes[how]^,0);
end;

begin;
 if paramstr(1)<>'jsb' then halt(255);
 gd:=3; gm:=0; initgraph(gd,gm,'');
 fillchar(ghost,sizeof(ghost),#0);

 assign(f,'spooky.avd');
 reset(f,1);
 seek(f,44);

 mark(memlevel);

 for fv:=1 to 5 do
 begin;
  blockread(f,cb,sizeof(cb));
  for bit:=2 to 3 do
   for y:=0 to cb.yl do
    blockread(f,ghost[fv,bit,y],cb.xl div 8);
 end;

 get_me(eyes[0]); { Get BGI-based ones }
 get_me(eyes[1]);
 get_me(exclamation);

 plain_grab; { Grabs to screen (cobweb) }
 plain_grab; { Grabs to screen (Mark's signature) }
 plain_grab; { Grabs to screen (open door) }

 for fv:=1 to 3 do
  get_me(bat[fv]);

(* new(glerk);
 for fv:=1 to 5 do { Grab the Glerk. }
 begin;
  blockread(f,cb,sizeof(cb));
  for bit:=0 to 3 do
   for y:=0 to 34 do
    blockread(f,glerk^[fv,bit,y],cb.xl div 8);
  inc(gd,gm);
 end;
*)

 new(glerk);

 for fv:=1 to 6 do
  with cb do
  begin;
   blockread(f,cb,sizeof(cb));
   bit:=3;
   for bit:=0 to 3 do
    for yy:=0 to yl do
(*    begin;
     port[$3c4]:=2; port[$3ce]:=4;
     port[$3C5]:=1 shl bit; port[$3CF]:=bit;*)

     blockread(f,glerk^[fv,bit,yy],xl div 8);
(*     move(glerk^[fv,bit,yy],mem[$A000:yy*80+177],xl div 8);*)
(*     blockread(f,mem[$A000:yy*80+177],xl div 8);*)

(*    end;*)
  end;

 for fv:=1 to 6 do get_me_aargh(fv);
 for fv:=1 to 5 do get_me(green_eyes[fv]);
 for gb:=false to true do
  for fv:=1 to 6 do get_me(greldet[fv,gb]);

 close(f);

 { Avvy walks over... }

 setfillstyle(1,0);
 glerkstage:=0; bat_x:=277; bat_y:=40; bat_count:=0;

 for gd:=500 downto 217 do
 begin;
  if (gd mod 30) in [22..27] then
  begin;
   if (gd mod 30)=27 then bar(gd,135,gd+16,136);
   putimage(gd,136,eyes[0]^,0);
   putpixel(gd+16,137,0);
  end else
  begin;
   if gd mod 30=21 then bar(gd,137,gd+17,138);

   putimage(gd,135,eyes[0]^,0);
   putpixel(gd+16,136,0); { eyes would leave a trail 1 pixel high behind them }
  end;

  { Plot the Glerk: }
  if gd mod 10=0 then
  begin;
   inc(glerkstage);
   if glerkstage>26 then break;

   for gm:=0 to 34 do
    for bit:=0 to 3 do
    begin;
     port[$3c4]:=2; port[$3ce]:=4;
     port[$3C5]:=1 shl bit; port[$3CF]:=bit;

     move(glerk^[glerkfade[glerkstage],bit,gm],
      mem[$A000:1177+gm*80],9);
    end;
    bit:=getpixel(0,0);
   end;

   do_bat;

   wait(15);
 end;

 setfillstyle(1,0);
 bar(456,14,530,50);

 { It descends... }

 for gm:=-64 to 103 do
 begin;
  bit:=getpixel(0,0);

  if gm>0 then
   fillchar(mem[$A000:(gm-1)*80],26,#0);

  for y:=0 to 65 do
   if (y+gm)>=0 then
    for bit:=0 to 3 do
     begin;
      port[$3c4]:=2; port[$3ce]:=4;
      port[$3C5]:=1 shl bit; port[$3CF]:=bit;

      move(ghost[2+(abs(gm div 7) mod 2)*3,plane_to_use[bit],y],
       mem[$A000:(y+gm)*80],26);
     end;

  wait(27);
 end;

 { And waves... }

 aargh_count:=-14;

 for gd:=1 to 4 do
  for fv:=1 to 5 do
  begin;

   y:=getpixel(0,0);

   for y:=0 to 7 do
    fillchar(mem[$A000:7760+y*80],26,#0);

   for y:=0 to 65 do
    for bit:=0 to 3 do
    begin;
     port[$3c4]:=2; port[$3ce]:=4;
     port[$3C5]:=1 shl bit; port[$3CF]:=bit;
     move(ghost[waveorder[fv],plane_to_use[bit],y],
      mem[$A000:7760+(y+adjustment[fv])*80],26);
    end;

   inc(aargh_count);

   if aargh_count>0 then
    with aargh_where[aargh_count] do
     putimage(x,y,aargh[aargh_count]^,0);

   wait(177);
 end;

 { ! appears }

 gd:=getpixel(0,0);
 putimage(246,127,exclamation^,0);
 wait(777);
 bar(172, 78,347,111); { erase "aargh" }

 for gm:=5 downto 1 do
 begin
  wait(377);
  big_green_eyes(gm);
 end;
 bar(246,127,251,133); { erase the "!" }

 { He hurries back. }

 glerkstage:=1; greldet_count:=18; red_greldet:=false;

 for gd:=217 to 479 do
 begin;
  if (gd mod 30) in [22..27] then
  begin;
   if (gd mod 30)=22 then
    bar(gd+22,134,gd+38,137);
   putimage(gd+23,136,eyes[1]^,0);
   putpixel(gd+22,137,0);
  end else
  begin;
   if gd mod 30=28 then
    bar(gd+22,135,gd+38,138);

   putimage(gd+23,135,eyes[1]^,0);
   putpixel(gd+22,136,0); { eyes would leave a trail 1 pixel high behind them }
  end;

  { Plot the Green Eyes: }
  if gd mod 53=5 then
  begin;
   big_green_eyes(glerkstage);
   inc(glerkstage);
  end;

  { Plot the Greldet: }

  if greldet_count=18 then
  begin { A new greldet. }
   greldet_x:=random(600);
   greldet_y:=random(80);
   greldet_count:=0;
   red_greldet:=not red_greldet;
  end;

  inc(greldet_count);
  putimage
   (greldet_x,greldet_y,greldet[greldetfade[greldet_count],red_greldet]^,0);

  wait(10);
 end;

 release(memlevel);
 closegraph;
end.