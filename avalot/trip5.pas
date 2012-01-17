{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 TRIP5            Trippancy V }

unit trip5; { Trippancy V } { Define NOASM to use Pascal instead of asm. }
{$S- Fast!}
interface

uses Graph,Crt,Gyro,Sticks;

const maxgetset = 35;

type

 manitype = array[5..2053] of byte;

 siltype = array[0..50,0..10] of byte; { 35, 4 }

 adxtype = record { Second revision of ADX type }
            name:string[12]; { name of character }
            comment:string[16]; { comment }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
            accinum:byte; { the number according to Acci (1=Avvy, etc.) }
           end;

 trip_saver_type = record
                    whichsprite:byte;
                    face:byte; step:byte;
                    x:integer;    y:integer;
                    ix:shortint;   iy:shortint;
                    visible:boolean;
                    homing:boolean;
                    check_me:boolean;
                    count:byte;
                    xw,xs,ys:byte;
                    totalnum:byte;
                    hx:integer; hy:integer;
                    call_Eachstep:boolean;
                    Eachstep:byte;
                    vanishifstill:boolean;
                   end;

 triptype = object
             a:adxtype; { vital statistics }
             face,step:byte;
             x,y:integer; { current xy coords }
             ox,oy:array[0..1] of integer; { last xy coords }
             ix,iy:shortint; { amount to move sprite by, each step }
             mani:array[1..24] of ^manitype;
             sil:array[1..24] of ^siltype;
             whichsprite:byte;
             quick,visible,homing,check_me:boolean;
             hx,hy:integer; { homing x & y coords }
             count:byte; { counts before changing step }
             xw:byte; { x-width in bytes }
             xs,ys:byte; { x & y speed }
             totalnum:byte; { total number of sprites }
             vanishifstill:boolean; { Do we show this sprite if it's still? }

             call_eachstep:boolean; { Do we call the eachstep procedure? }
             eachstep:byte;

             constructor Init(spritenum:byte; do_check:boolean);
              { loads & sets up the sprite }
             procedure original; { just sets Quick to false }
             procedure andexor; { drops sprite onto screen }
             procedure turn(whichway:byte); { turns him round }
             procedure appear(wx,wy:integer; wf:byte); { switches him on }
             procedure bounce; { bounces off walls. }
             procedure walk; { prepares for andexor, etc. }
             procedure walkto(pednum:byte); { home in on a point }
             procedure stophoming; { self-explanatory }
             procedure homestep; { calculates ix & iy for one homing step }
             procedure speed(xx,yy:shortint); { sets ix & iy, non-homing, etc }
             procedure stopwalk; { Stops the sprite from moving }
             procedure chatter; { Sets up talk vars }
             procedure set_up_saver(var v:trip_saver_type);
             procedure unload_saver(v:trip_saver_type);
               procedure savedata(var f:file); { Self-explanatory, }
               procedure loaddata(var f:file);  { really. }
               procedure save_data_to_mem(var where:word);
               procedure load_data_from_mem(var where:word);
             destructor Done;
            end;

 getsettype = object
               gs: array[1..maxgetset] of bytefield;
               numleft:byte;

               constructor Init;
               procedure remember(r:bytefield);
               procedure recall(var r:bytefield);
              end;


const
 up = 0;
 right = 1;
 down = 2;
 left = 3;
 ur=4; dr=5; dl=6; ul=7;
 stopped=8;

 numtr = 5; { current max no. of sprites }



 PROCfollow_Avvy_Y = 1;

 PROCback_and_forth = 2;

 PROCface_Avvy = 3;

 PROCarrow_procs = 4;

 PROCSpludwick_procs = 5;

 PROCgrab_Avvy = 6;

 PROCGeida_procs = 7;


procedure trippancy_link;

procedure get_back_Loretta;

procedure loadtrip;

procedure call_special(which:word);

procedure open_the_door(whither,ped,magicnum:byte); { Handles slidey-open doors. }

procedure catamove(ped:byte);

procedure stopwalking;

procedure tripkey(dir:char);

procedure rwsp(t,r:byte);

procedure apped(trn,np:byte);

procedure getback;

procedure fliproom(room,ped:byte);

function infield(which:byte):boolean; { returns True if you're within field "which" }

function neardoor:boolean; { returns True if you're near a door! }

procedure readstick;

procedure newspeed;

procedure new_game_for_trippancy;

var
 tr:array[1..numtr] of triptype;
 getset:array[0..1] of getsettype;
 aa:array[1..16000] of byte;

 mustexclaim:boolean; saywhat:word;

implementation

uses Scrolls,Lucerna,Dropdown,Visa,Celer,Timeout,Sequence,Enid;

procedure loadtrip;
var gm:byte;
begin
 for gm:=1 to numtr do tr[gm].original;
 fillchar(aa,sizeof(aa),#0);
end;

function checkfeet(x1,x2,oy,y:integer; yl:byte):byte;
var a,c:byte; fv,ff:integer;
begin
(* if not alive then begin checkfeet:=0; exit; end;*)
 a:=0; setactivepage(2); if x1<0 then x1:=0; if x2>639 then x2:=639;
 if oy<y then
  for fv:=x1 to x2 do
   for ff:=oy+yl to y+yl do
   begin
    c:=getpixel(fv,ff);
    if c>a then a:=c;
   end else
  for fv:=x1 to x2 do
   for ff:=y+yl to oy+yl do
   begin
    c:=getpixel(fv,ff);
    if c>a then a:=c;
   end;
 checkfeet:=a; setactivepage(1-cp);
end;

function geida_ped(which:byte):byte;
begin
 case which of
    1: geida_ped:= 7;
  2,6: geida_ped:= 8;
  3,5: geida_ped:= 9;
    4: geida_ped:=10;
 end;
end;

procedure catamove(ped:byte);
 { When you enter a new position in the catacombs, this procedure should
   be called. It changes the Also codes so that they may match the picture
   on the screen. (Coming soon: It draws up the screen, too.) }
var
 here:longint;
 xy_word:word;
 fv,ff:byte;

{ XY_word is cat_x+cat_y*256. Thus, every room in the
  catacombs has a different number for it. }

begin
 with dna do
 begin
  xy_word:=cat_x+cat_y*256;
  Geida_spin:=0;
 end;
 case xy_word of
  1801: begin { Exit catacombs }
         fliproom(r__LustiesRoom,4);
         display('Phew! Nice to be out of there!');
         exit;
        end;
  1033: begin { Oubliette }
         fliproom(r__Oubliette,1);
         display('Oh, NO!'^s'1'^b);
         exit;
        end;
     4: begin
         fliproom(r__Geidas,1);
         exit;
        end;
  2307: begin
         fliproom(r__Lusties,5);
         display('Oh no... here we go again...');
         dna.User_Moves_Avvy:=false;
         tr[1].iy:=1; tr[1].ix:=0;
         exit;
        end;
 end;

 if not dna.Enter_Catacombs_From_Lusties_Room then load(29);
 with dna do here:=catamap[cat_y,cat_x];

 case (here and $F) of { West. }
  $0: begin { no connection (wall) }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=nix; { Door. }
      show_one(28);
     end;
  $1: begin { no connection (wall + shield), }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=nix; { Door. }
      show_one(28); { Wall, plus... }
      show_one(29); { ...shield. }
     end;
  $2: begin { wall with door }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=special; { Door. }
      show_one(28); { Wall, plus... }
      show_one(30); { ...door. }
     end;
  $3: begin { wall with door and shield }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=special; { Door. }
      show_one(28); { Wall, plus... }
      show_one(30); { ...door, and... }
      show_one(29); { ...shield. }
     end;
  $4: begin { no connection (wall + window), }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=nix; { Door. }
      show_one(28); { Wall, plus... }
      show_one(5);  { ...window. }
     end;
  $5: begin { wall with door and window }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=special; { Door. }
      show_one(28); { Wall, plus... }
      show_one(30); { ...door, and... }
      show_one(5); { ...window. }
     end;
  $6: begin { no connection (wall + torches), }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=nix; { No door. }
      show_one(28); { Wall, plus... }
      show_one(7); { ...torches. }
     end;
  $7: begin { wall with door and torches }
      magics[2].op:=bounces; { Sloping wall. }
      magics[3].op:=nix; { Straight wall. }
      portals[13].op:=special; { Door. }
      show_one(28); { Wall, plus... }
      show_one(30); { ...door, and... }
      show_one(7); { ...torches. }
     end;
  $F: begin { straight-through corridor. }
      magics[2].op:=nix; { Sloping wall. }
      magics[3].op:=special; { Straight wall. }
     end;
 end;

                         {  ---- }

 case (here and $F0) shr 4 of { East }
  $0: begin { no connection (wall) }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=nix; { Door. }
      show_one(19);
     end;
  $1: begin { no connection (wall + window), }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=nix; { Door. }
      show_one(19); { Wall, plus... }
      show_one(20); { ...window. }
     end;
  $2: begin { wall with door }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=special; { Door. }
      show_one(19); { Wall, plus... }
      show_one(21); { ...door. }
     end;
  $3: begin { wall with door and window }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=special; { Door. }
      show_one(19); { Wall, plus... }
      show_one(20); { ...door, and... }
      show_one(21); { ...window. }
     end;
  $6: begin { no connection (wall + torches), }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=nix; { No door. }
      show_one(19); { Wall, plus... }
      show_one(18); { ...torches. }
     end;
  $7: begin { wall with door and torches }
      magics[5].op:=bounces; { Sloping wall. }
      magics[6].op:=nix; { Straight wall. }
      portals[15].op:=special; { Door. }
      show_one(19); { Wall, plus... }
      show_one(21); { ...door, and... }
      show_one(18); { ...torches. }
     end;
  $F: begin { straight-through corridor. }
      magics[5].op:=nix; { Sloping wall. }
      magics[6].op:=special; { Straight wall. }
      portals[15].op:=nix; { Door. }
     end;
 end;

                         {  ---- }

 case (here and $F00) shr 8 of { South }
  $0: begin { No connection. }
      magics[7].op:=bounces;
      magics[12].op:=bounces;
      magics[13].op:=bounces;
     end;
  $1: begin
       show_one(22);
       with magics[13] do
        if (xy_word=2051) and (dna.Geida_follows) then
         op:=exclaim
        else op:=special; { Right exit south. }
       magics[7].op:=bounces;
       magics[12].op:=bounces;
     end;
  $2: begin
      show_one(23);
      magics[7].op:=special; { Middle exit south. }
       magics[12].op:=bounces;
       magics[13].op:=bounces;
     end;
  $3: begin
       show_one(24);
       magics[12].op:=special; { Left exit south. }
       magics[7].op:=bounces;
       magics[13].op:=bounces;
      end;
 end;

 case (here and $F000) shr 12 of { North }
  $0: begin { No connection }
      magics[1].op:=bounces;
      portals[12].op:=nix; { Door. }
     end;
   { LEFT handles: }
(*  $1: begin
      show_one(4);
      magics[1].op:=bounces; { Left exit north. } { Change magic number! }
      portals[12].op:=special; { Door. }
     end;*)
  $2: begin
      show_one(4);
      magics[1].op:=bounces; { Middle exit north. }
      portals[12].op:=special; { Door. }
     end;
(*  $3: begin
      show_one(4);
      magics[1].op:=bounces; { Right exit north. } { Change magic number! }
      portals[12].op:=special; { Door. }
     end;
  { RIGHT handles: }
  $4: begin
      show_one(3);
      magics[1].op:=bounces; { Left exit north. } { Change magic number! }
      portals[12].op:=special; { Door. }
     end;*)
  $5: begin
      show_one(3);
      magics[1].op:=bounces; { Middle exit north. }
      portals[12].op:=special; { Door. }
     end;
(*  $6: begin
      show_one(3);
      magics[1].op:=bounces; { Right exit north. }
      portals[12].op:=special; { Door. }
     end;*)
 { ARCHWAYS: }
  $7,$8,$9: begin
      show_one(6);

      if ((here and $F000) shr 12)>$7 then show_one(31);
      if ((here and $F000) shr 12)=$9 then show_one(32);

      magics[1].op:=special; { Middle arch north. }
      portals[12].op:=nix; { Door. }
     end;
  { DECORATIONS: }
  $D: begin { No connection + WINDOW }
      magics[1].op:=bounces;
      portals[12].op:=nix; { Door. }
      show_one(14);
     end;
  $E: begin { No connection + TORCH }
      magics[1].op:=bounces;
      portals[12].op:=nix; { Door. }
      show_one(8);
     end;
 { Recessed door: }
  $F: begin
      magics[1].op:=nix; { Door to Geida's room. }
      show_one(1);
      portals[12].op:=special; { Door. }
     end;
 end;

 case xy_word of
   514: show_one(17);     { [2,2] : "Art Gallery" sign over door. }
   264: show_one(9);      { [8,1] : "The Wrong Way!" sign. }
  1797: show_one(2);      { [5,7] : "Ite Mingite" sign. }
   258: for fv:=0 to 2 do { [2,1] : Art gallery - pictures }
         begin
          show_one_at(15,130+fv*120,70);
          show_one_at(16,184+fv*120,78);
         end;
  1287: for fv:=10 to 13 do show_one(fv); { [7,5] : 4 candles. }
   776: show_one(10);     { [8,3] : 1 candle. }
  2049: show_one(11);     { [1,8] : another candle. }
   257: begin show_one(12); show_one(13); end; { [1,1] : the other two. }
 end;

 if (dna.Geida_follows) and (ped>0) then
 with tr[2] do
  begin
   if not quick then { If we don't already have her... }
    tr[2].init(5,true); { ...Load Geida. }
   apped(2,geida_ped(ped));
   tr[2].call_Eachstep :=true;
   tr[2].Eachstep:=PROCGeida_procs;
  end;
end;

procedure call_special(which:word);
 { This proc gets called whenever you touch a line defined as Special. }
  procedure dawndelay;
   begin set_up_timer(2,procDawn_Delay,reason_DawnDelay); end;
begin
 case which of
  1: begin { Special 1: Room 22: top of stairs. }
      show_one(1);
      dna.Brummie_Stairs:=1;
      magics[10].op:=nix;
      set_up_timer(10,PROCstairs,reason_BrummieStairs);
      stopwalking;
      dna.user_moves_Avvy:=false;
     end;
  2: begin { Special 2: Room 22: bottom of stairs. }
      dna.Brummie_Stairs:=3;
      magics[11].op:=nix;
      magics[12].op:=exclaim;
      magics[12].data:=5;
      magics[4].op:=bounces; { Now works as planned! }
      stopwalking;
      dixi('q',26);
      dna.user_moves_Avvy:=true;
     end;
  3: begin { Special 3: Room 71: triggers dart. }
      tr[1].bounce; { Must include that. }

      if not dna.arrow_triggered then
      begin
       dna.arrow_triggered:=true;
       apped(2,4); { The dart starts at ped 4, and... }
       tr[2].walkto(5); { flies to ped 5. }
       tr[2].face:=0; { Only face. }
       { Should call some kind of Eachstep procedure which will deallocate
         the sprite when it hits the wall, and replace it with the chunk
         graphic of the arrow buried in the plaster. }
       { OK! }
       tr[2].call_Eachstep:=true;
       tr[2].Eachstep:=PROCarrow_procs;
      end;
     end;

  4: begin { This is the ghost room link. }
      dusk;
      tr[1].turn(right); { you'll see this after we get back from bootstrap }
      set_up_timer(1,PROCghost_room_phew,reason_ghost_room_phew);
      back_to_bootstrap(3);
     end;

  5: if dna.Friar_Will_Tie_You_Up then
     begin { Special 5: Room 42: touched tree, and get tied up. }
      magics[4].op:=bounces; { Boundary effect is now working again. }
      dixi('q',35);
      tr[1].done;
      (*tr[1].vanishifstill:=true;*)
      show_one(2);
      dixi('q',36);
      dna.tied_up:=true;
      dna.Friar_Will_Tie_You_Up:=false;
      tr[2].walkto(3);
      tr[2].VanishIfStill:=true;
      tr[2].Check_Me:=true; { One of them must have Check_Me switched on. }
      whereis[pFriarTuck]:=177; { Not here, then. }
      set_up_timer(364,PROChang_around,reason_hanging_around);
     end;

   6: begin { Special 6: fall down oubliette. }
       dna.User_Moves_Avvy:=false;
       tr[1].ix:=3;
       tr[1].iy:=0;
       tr[1].face:=right;
       set_up_timer(1,PROCfall_down_oubliette,reason_falling_down_oubliette);
      end;

   7: begin { Special 7: stop falling down oubliette. }
       tr[1].visible:=false;
       magics[10].op:=nix;
       stopwalking;
       lose_timer(reason_falling_down_oubliette);
       mblit(12,80,38,160,3,0);
       mblit(12,80,38,160,3,1);
       display('Oh dear, you seem to be down the bottom of an oubliette.');
       set_up_timer(200,PROCmeet_Avaroid,reason_meeting_Avaroid);
      end;

   8: with dna do { Special 8: leave du Lustie's room. }
       if (Geida_follows) and (not Lustie_is_asleep) then
       begin
        dixi('q',63);
        tr[2].turn(down); tr[2].stopwalk; tr[2].call_Eachstep:=false; { Geida }
        gameover;
       end;

   9: begin { Special 9: lose Geida to Robin Hood... }
       if not dna.Geida_follows then exit; { DOESN'T COUNT: no Geida. }
       tr[2].call_Eachstep:=false; { She no longer follows Avvy around. }
       tr[2].walkto(4); { She walks to somewhere... }
       tr[1].Done;     { Lose Avvy. }
       dna.user_moves_avvy:=false;
       set_up_timer(40,PROCrobin_hood_and_geida,reason_robin_hood_and_geida);
      end;

  10: begin { Special 10: transfer north in catacombs. }
       if (dna.cat_x=4) and (dna.cat_y=1) then
       begin { Into Geida's room. }
        if dna.obj[key] then dixi('q',62) else
        begin
         dixi('q',61);
         exit;
        end;
       end;
       dusk;
       dec(dna.cat_y);
       catamove(4); if dna.room<>r__Catacombs then exit;
       delavvy;
       with dna do
       case (catamap[cat_y,cat_x] and $F00) shr 8 of
        $1: apped(1,12);
        $3: apped(1,11);
        else apped(1,4);
       end;
       getback;
       dawndelay;
      end;
  11: begin { Special 11: transfer east in catacombs. }
       dusk;
       inc(dna.cat_x);
       catamove(1); if dna.room<>r__Catacombs then exit;
       delavvy;
       apped(1,1);
       getback;
       dawndelay;
      end;
  12: begin { Special 12: transfer south in catacombs. }
       dusk;
       inc(dna.cat_y);
       catamove(2); if dna.room<>r__Catacombs then exit;
       delavvy;
       apped(1,2);
       getback;
       dawndelay;
      end;
  13: begin { Special 13: transfer west in catacombs. }
       dusk;
       dec(dna.cat_x);
       catamove(3); if dna.room<>r__Catacombs then exit;
       delavvy;
       apped(1,3);
       getback;
       dawndelay;
      end;
 end;
end;

procedure hide_in_the_cupboard; forward;

procedure open_the_door(whither,ped,magicnum:byte);
 { This slides the door open. (The data really ought to be saved in
   the Also file, and will be next time. However, for now, they're
   here.) }
begin
 case dna.room of
  r__OutsideYours,r__OutsideNottsPub,r__OutsideDucks:
   begin
    first_show(1);
    then_show(2);
    then_show(3);
   end;
  r__InsideCardiffCastle:
   begin
    first_show(1);
    then_show(5);
   end;
  r__AvvysGarden,r__EntranceHall,r__InsideAbbey:
   begin
    first_show(1);
    then_show(2);
   end;
  r__MusicRoom,r__OutsideArgentPub:
   begin
    first_show(5);
    then_show(6);
   end;
  r__Lusties:
   case magicnum of
    14: if dna.Avvys_in_the_cupboard then
         begin
          hide_in_the_cupboard;
          first_show(8); then_show(7);
          start_to_close;
          exit;
         end else
         begin
            apped(1,6);
            tr[1].face:=right; { added by TT 12/3/1995 }
            first_show(8); then_show(9);
         end;
    12: begin
         first_show(4); then_show(5); then_show(6);
        end;
   end;
 end;

 then_flip(whither,ped);
 start_to_open;
end;

procedure newspeed;
 { Given that you've just changed the speed in triptype.xs, this adjusts
   ix. }
 const lightspace: bytefield = (x1:40; y1:199; x2:47; y2:199);
 var page:byte;
begin
 with tr[1] do
 begin
   ix:=(ix div 3)*xs;
   setactivepage(3);

   setfillstyle(1,14);
   if xs=run then bar(371,199,373,199) else bar(336,199,338,199);
   setfillstyle(1,9);
   if xs=run then bar(336,199,338,199) else bar(371,199,373,199);

   setactivepage(1-cp);
   for page:=0 to 1 do getset[page].remember(lightspace);
 end;
end;

constructor triptype.Init(spritenum:byte; do_check:boolean);
const idshould = -1317732048;
var
 gd,gm:integer; xx:string[2];
 fv(*,nds*):byte;
 aa,bb:byte;
 id:longint; soa:word;
 inf:file;
begin
 if spritenum=177 then exit; { Already running! }
 str(spritenum,xx); assign(inf,'sprite'+xx+'.avd');
 reset(inf,1);
 seek(inf,177);
 blockread(inf,id,4);
 if id<>idshould then
 begin
  write(#7);
  close(inf);
  halt;
 end;

 blockread(inf,soa,2);
 blockread(inf,a,soa);

 with a do
 begin
  (*nds:=num div seq;*) totalnum:=1;
  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);
  for aa:=1 to (*nds*seq*)num do
  begin
   getmem(sil[totalnum],11*(yl+1));
   getmem(mani[totalnum],size-6);
   for fv:=0 to yl do
   begin
    blockread(inf,sil[totalnum]^[fv],xw);
   end;
   blockread(inf,mani[totalnum]^,size-6);
   inc(totalnum);
  end;
 end;

 (* on; *)
 x:=0; y:=0; quick:=true; visible:=false; xs:=3; ys:=1;
(* if spritenum=1 then newspeed; { Just for the lights. }*)

 homing:=false; ix:=0; iy:=0; step:=0; check_me:=do_check;
 count:=0; whichsprite:=spritenum; vanishifstill:=false;
 call_eachstep:=false;
 close(inf);
end;

procedure triptype.original;
begin
 quick:=false; whichsprite:=177;
end;

procedure triptype.andexor;
var
 picnum:byte; { Picnum, Picnic, what ye heck }
 Lay,Laz:byte; { Limits for Qaz and Qay or equivs. (Laz always = 3). }
{$IFDEF NOASM}
 offs,fv:word;
 Qax,Qay,Qaz:byte;
{$ELSE}
 segmani,ofsmani:word;
 ofsaa,realofsaa:word;
 segsil,ofssil:word;
 z:word; xwidth:byte;

{$ENDIF}
begin
 if ((vanishifstill) and (ix=0) and (iy=0)) then exit;
 picnum:=face*a.seq+step+1;

 with a do
 begin
  getimage(x,y,x+xl,y+yl,aa); { Now loaded into our local buffer. }

  { Now we've got to modify it! }

   { Qaz ranges over the width of the sprite/8.
     Qay    "    "   the height.
     Qax    "    "   1 to 4 (the planes). }

  with a do
  begin
    {$IFDEF NOASM}
    Laz:=xw-1; Lay:=yl;  { -1's only for Pascal. }
    {$ELSE}
    Laz:=xw; Lay:=yl+1;  { +1's only for ASM! }
    {$ENDIF}
  end;

  { ASSEMBLERISED: }
{$IFDEF NOASM}
  for Qax:=0 to 3 do { 3 }
   for Qay:=0 to Lay do { 35 }
    for Qaz:=0 to Laz do { 4 }
    begin
     offs:=5+Qay*xw*4+xw*Qax+Qaz;
     aa[offs]:=aa[offs] and sil[picnum]^[Qay,Qaz];
    end;

  for fv:=5 to size-2 do
   aa[fv]:=aa[fv] xor mani[picnum]^[fv];

{$ELSE}
  { OK, here's the same thing in assembler...

         AL is Qax,
         BL is Qay,
         CL is Qaz,
         DX is Offs }

 { For the first part: }
 xwidth:=xw;
 segsil:=seg(sil[picnum]^);
 ofssil:=ofs(sil[picnum]^);

 { For the first and second parts: }
 segmani:=seg(mani[picnum]^); { It's easier to do this in Pascal, and }
 ofsmani:=ofs(mani[picnum]^)+1; { besides it only goes round once here. }
 { Segment of AA is always the current data segment. }
 ofsaa:=ofs(aa)+5;
 realofsaa:=ofs(aa)-1; { We may not need this. }
 z:=size-7;

 asm

  xor ax,ax;             { Initialise ax, bx, and cx, using a rather }
  @QAXloop: { AL }

   xor bx,bx;            { nifty speed trick. }
   @QAYloop: { BL }

    xor cx,cx;
    @QAZloop: { CL }

     { Right, well, here we are. We have to do some rather nifty array
       manipulation, stuff like that. We're trying to assemblerise:
         DX:= 5 + BX * xw * 4 + xw * AX + CX;
         aa[DX]:=aa[DX] and sil[picnum]^[BL,CL]; }

     push ax;  {AXcdx}   { OK, we're going to do some strange things }
                         { with ax, so we'd better save it. }
     mov dx,5;           { First of all... set dx to 5. }
     add dx,cx;          { DX now = 5+CX }
     mul xwidth;         { Multiply ax by xw (the Pascal variable.) }
     add dx,ax;          { DX now = 5+CX+xw*AX }

     { Right. Mul only works on ax. Don't ask me why. Ask Intel. Anyway,
     since ax is saved on the stack, we can move bx over it. Note that
     if xw was a word, using mul would have destroyed the contents of
     dx. NOT a good idea! }

     push cx;  {CXmul}   { We must just borrow cx for a second. }
     mov ax,bx;          { Make ax = bx. }
     mul xwidth;         { Do the same to it as we did to ax before. }
     mov cl,2;
     shl ax,cl;          { And multiply it by 4 (i.e., shl it by 2.) }
     add dx,ax;          { DX now = 5+CX+xw*AX+xw*BX*4. That's OK. }

     pop cx;   {CXmul}
     pop ax;   {AXcdx}   { Now we have to get ax and cx back again. }

   { Registers are now returned to original status. }

     { Righto. DX is now all worked out OK. We must now find out the
     contents of: 1) aa[dx], and 2) (harder) sil[picnum]^[BL,CL]. Gulp. }

     { DS already points to the segment of AA. So... let's use CL to
     put aa[dx] in, and use BX for the offset. Looks like we're going
     to have to push a few registers! }

     push ax; { AXaa. Saving loop value of AX. }
      { Let's use ax to do our dirty work with. }
     push dx; { Saving Offs(DX.) }

     push bx; { BXaa. Saving loop value of BX. }

     mov bx,realofsaa; { aa is now pointed to by [ds:bx]. }
     add bx,dx;        { Offset is dx bytes. }
     mov dl,[bx];      { cl now holds the contents of aa[dx]. }

     pop bx; { BXaa. Restoring loop value of BX. }

   { Stack now holds: Offs(DX). }

     { ^^^ That works. Now to find sil[picnum]^[BL,CL]. Our first task is
     to find the address of sil[picnum]^. Since it's dynamic, we must
     push and pop ds. }

     push ds; { DXaa. Saving value of Trip5's data segment. }
      { Push ds. Now we can put the segment of sil[picnum]^... }
     mov ds,segsil; { ...into ds, and... }
     mov ax,ofssil; { ...its offset into ax. }
      { Addr of sil[picnum]^ is now in [ds:ax]. BUT we want a particular
      offset: to wit, [BL,CL]. Now, siltype is defined so that this offset
      will be at an offset of (BL*11)+CL. }

     push bx; { Saving loop value of BX. }
     push cx; { Saving loop value of CX. }
     push ax; { Saving offset of sil[picnum]^. }
       { Save them for a bit (!) }
     mov al,bl;          { Put bl into al. }
     mov bl,11;          { ... }
     mul bl;             { ...times it by 11. }
     mov bx,ax;          { Put it back into bx (now = bx*11) }
     pop ax; { Restoring offset of sil[picnum]^. }
                         { Get ax back again. }
     add ax,bx;          { Add (original bl)*11 to al. }
     add ax,cx;          { Add cl to al. }
      { AX now holds the offset of sil[picnum]^[bx,cl]. }

   { Stack now holds: loop value of AX, Trip5's DS, lv of BX, lv of CX. }

     { Right. Now the address of sil[picnum]^[bl,cl] is in [ds:ax]. Let's
       get the elusive byte itself, and put it into ax. Firstly, we must
       swap ax and bx. }

     xchg ax,bx;
     mov al,[bx]; { AX now contains sil[picnum]^[bl,cl], AT LAST!! }

      { So now AL contains the sil stuff, and DL holds aa[offs]. }

     and al,dl; { aa[offs]:=aa[offs] and sil[picnum]^[Qay,Qaz]. }

     pop cx; { Restoring loop value of CX. }
     pop bx; { Restoring loop value of BX. }
     pop ds; { Restore value of Trip5's data segment. }

     { Right. AL contains the byte we need to replace aa[offs] with.
       All that's left to do is to put it back. Remember that we already
       have the segment of aa in the current DS, so... }

     pop dx; { Restore Offs(DX). }

     { Stack is now as when we entered the loop. Since this copy of DX
       is now being used for the last time, we can muck around with it. }

     { Recap: DX now holds the offset from the start of AA. If we add
       the offset of aa to it, we'll get the offset of the byte we want.
       DS is already set up. }

     push bx; { I'm just borrowing bx for a sec. I'll put it back in 5 lines.}
     mov bx,realofsaa;
     add dx,bx; { Now aa[offs] is at aa[ds:dx]. }
     mov bx,dx; { But we can't address memory with dx, so use bx. }
     mov [bx],al;   { Shove it into the memory! }
     pop bx; { See! I said I would. }

     pop ax; { Restore loop value of AX. }

     { Right, the fancy stuff's all done now. Finish off the loop code. }

     inc cl;
     cmp cl,laz;           { CL must not reach 5. Does it?  }
     jnz @QAZloop;       { no, keep going around the QAZloop. }

    inc bl;
    cmp bl,lay;           { BL must not reach 36. Does it? }
    jnz @QAYloop;        { no, keep going around the QAYloop. }

   inc al;
   cmp al,4;             { AL must not reach 4. Does it? }
   jnz @QAXloop;         { no, keep going around the QAXloop. }

  { al, bl and cl are now at their maxima, so we can stop the loops. }

  { *** SECOND ASSEMBLER BIT. *** }

  mov cx,z;             { Find the size of the array, -7. }
  mov bx,ofsmani;       { Now find the offset and put that into bx. }
  mov dx,ofsaa;         { We'll use dx to be the same as fv, +5. }

  { DS should already hold the segment of aa. }

  @nextbyte:            { Main loop... }

   { Firstly, we must get hold of aa[fv] (here called aa[dx].)}
   push bx;             { We need to "borrow" bx for a second... }
   mov bx,dx;           { Wrong register- shove it into bx. }
   mov al,[bx];         { Get aa[fv] and put it into al. }
   pop bx;              { Right, you can have bx back again. }

   { Secondly, we must get hold of mani[picnum]^[fv]. }
   push cx;             { Let's borrow cx for this one. }
   push ds;             { we must use ds to point to segmani. }
   mov ds,segmani;      { Find the segment of mani[picnum]^, }
   mov cl,[bx];         { now get the byte at [ds:bx] and put it into cl. }
   pop ds;              { Put ds back to being the current data segment. }

   { Right: now we can do what we came here for in the first place.
     AL contains aa[fv], CL contains mani[picnum]^[fv]. }

   xor al,cl;           { Xor al with bl. That's it! }

   pop cx;              { We don't need cx any more for this now. }

   push bx;             { Borrow bx... }
   mov bx,dx;           { Put dx into bx. }
   mov [bx],al;         { Put the changed al back into [ds:bx] (ie, [ds:dx].}
   pop bx;              { Get it back. }

   inc bx;              { Add one to bx, for the next char. }
   inc dx;              { And dx, for the same reason. }

  loop @nextbyte;       { Keep going round until cx=0. }
end;
{$ENDIF}

  { Now.. let's try pasting it back again! }

  putimage(x,y,aa,0);
 end;
end;

procedure triptype.turn(whichway:byte);
begin
 if whichway=8 then face:=0 else face:=whichway;
end;

procedure triptype.appear(wx,wy:integer; wf:byte);
begin
 x:=(wx div 8)*8; y:=wy; ox[cp]:=wx; oy[cp]:=wy; turn(wf);
 visible:=true; ix:=0; iy:=0;
end;


procedure triptype.walk;
var tc:byte; r:bytefield;

  function collision_check:boolean;
  var fv:byte;
  begin
   for fv:=1 to numtr do
    if tr[fv].quick and (tr[fv].whichsprite<>whichsprite) and
       ((x+a.xl)>tr[fv].x) and
        (x<(tr[fv].x+tr[fv].a.xl)) and
         (tr[fv].y=y) then
         begin
          collision_check:=true;
          exit;
         end;
   collision_check:=false;
  end;
begin

 if visible then
 begin
  with r do
  begin
   x1:=(x div 8)-1;
   if x1=255 then x1:=0;
   y1:=y-2;
   x2:=((x+a.xl) div 8)+1;
   y2:=y+a.yl+2;
  end;
  getset[1-cp].remember(r);
 end;

 if not doing_sprite_run then
 begin
  ox[cp]:=x; oy[cp]:=y;
  if homing then homestep;
  x:=x+ix; y:=y+iy;
 end;

  if check_me then
  begin
   if collision_check then
   begin
    bounce;
    exit;
   end;

   tc:=checkfeet(x,x+a.xl,oy[cp],y,a.yl);

   if (tc<>0) and (not doing_sprite_run) then
    with magics[tc] do
     case op of
      exclaim: begin
                bounce; mustexclaim:=true; saywhat:=data;
               end;
      bounces: bounce;
      transport: fliproom(hi(data),lo(data));
      unfinished: begin
                   bounce;
                   display(#7'Sorry.'^c^m'This place is not available yet!');
                  end;
      special: call_special(data);
      Mopendoor: open_the_door(hi(data),lo(data),tc);
     end;
  end;

 if not doing_sprite_run then
 begin
  inc(count);
  if ((ix<>0) or (iy<>0)) and (count>1) then
  begin
   inc(step); if step=a.seq then step:=0; count:=0;
  end;
 end;

end;

procedure triptype.bounce;
begin
 x:=ox[cp]; y:=oy[cp];
 if check_me then stopwalking else stopwalk;
 OnCanDoPageSwap:=false;
 showrw;
 OnCanDoPageSwap:=true;
end;

function sgn(x:integer):shortint;
begin
 if x>0 then sgn:=1 else
  if x<0 then sgn:=-1 else
   sgn:=0; { x=0 }
end;

procedure triptype.walkto(pednum:byte);
begin
 speed(sgn(peds[pednum].x-x)*4,sgn(peds[pednum].y-y));
 hx:=peds[pednum].x-a.xl div 2;
 hy:=peds[pednum].y-a.yl; homing:=true;
end;

procedure triptype.stophoming;
begin
 homing:=false;
end;

procedure triptype.homestep;
var temp:integer;
begin
 if (hx=x) and (hy=y) then
 begin { touching the target }
  stopwalk;
  exit;
 end;
 ix:=0; iy:=0;
 if hy<>y then
 begin
  temp:=hy-y; if temp>4 then iy:=4 else if temp<-4 then iy:=-4 else iy:=temp;
 end;
 if hx<>x then
 begin
  temp:=hx-x; if temp>4 then ix:=4 else if temp<-4 then ix:=-4 else ix:=temp;
 end;
end;

procedure triptype.speed(xx,yy:shortint);
begin
 ix:=xx; iy:=yy;
 if (ix=0) and (iy=0) then exit; { no movement }
 if ix=0 then
 begin { No horz movement }
  if iy<0 then turn(up) else turn(down);
 end else
 begin
  if ix<0 then turn(left) else turn(right)
 end;
end;

procedure triptype.stopwalk;
begin
 ix:=0; iy:=0; homing:=false;
end;

procedure triptype.chatter;
begin
 talkx:=x+a.xl div 2; talky:=y; talkf:=a.fgc; talkb:=a.bgc;
end;

procedure triptype.set_up_saver(var v:trip_saver_type);
begin
 v.whichsprite:=whichsprite;
 v.face:=face;
 v.step:=step;
 v.x:=x;
 v.y:=y;
 v.ix:=ix;
 v.iy:=iy;
 v.visible:=visible;
 v.homing:=homing;
 v.check_me:=check_me;
 v.count:=count;
 v.xw:=xw;
 v.xs:=xs;
 v.ys:=ys;
 v.totalnum:=totalnum;
 v.hx:=hx;
 v.hy:=hy;
 v.call_Eachstep:=call_Eachstep;
 v.Eachstep:=Eachstep;
 v.vanishifstill:=vanishifstill;
end;

procedure triptype.unload_saver(v:trip_saver_type);
begin
 whichsprite:=v.whichsprite;
 face:=v.face;
 step:=v.step;
 x:=v.x;
 y:=v.y;
 ix:=v.ix;
 iy:=v.iy;
 visible:=v.visible;
 homing:=v.homing;
 check_me:=v.check_me;
 count:=v.count;
 xw:=v.xw;
 xs:=v.xs;
 ys:=v.ys;
 totalnum:=v.totalnum;
 hx:=v.hx;
 hy:=v.hy;
 call_Eachstep:=v.call_Eachstep;
 Eachstep:=v.Eachstep;
 vanishifstill:=v.vanishifstill;
end;

procedure triptype.savedata(var f:file);
var
 tripsaver:trip_saver_type;
begin
 set_up_saver(tripsaver);

 with tripsaver do
 begin
  blockwrite(f,whichsprite,1);
  blockwrite(f,face,1); blockwrite(f,step,1);
  blockwrite(f,x,2);    blockwrite(f,y,2);
  blockwrite(f,ix,1);   blockwrite(f,iy,1);
  blockwrite(f,visible,1);
  blockwrite(f,homing,1);
  blockwrite(f,check_me,1);
  blockwrite(f,count,1);
  blockwrite(f,xw,1);
  blockwrite(f,xs,1); blockwrite(f,ys,1);
  blockwrite(f,totalnum,1);
  blockwrite(f,hx,2); blockwrite(f,hy,2);
  blockwrite(f,call_Eachstep,1);
  blockwrite(f,Eachstep,1);
  blockwrite(f,vanishifstill,1);
 end;
end;

procedure triptype.loaddata(var f:file);
var
 spritewas,spriteis,saveface,savex,savey,savestep:word;
 wasquick:boolean;
 tripsaver:trip_saver_type;

begin
 wasquick:=quick;
 quick:=true; spritewas:=whichsprite;

 with tripsaver do
 begin
  blockread(f,whichsprite,1);
  blockread(f,face,1); blockread(f,step,1);
  blockread(f,x,2);    blockread(f,y,2);
  blockread(f,ix,1);   blockread(f,iy,1);

  if (not wasquick) or (whichsprite<>spritewas) then
  begin
   spriteis:=whichsprite;
   savex:=x; savey:=y; saveface:=face; savestep:=step;

   if wasquick then done;

   init(spriteis,check_me);

   appear(savex,savey,saveface); step:=savestep;
  end;

  blockread(f,visible,1);
  blockread(f,homing,1);
  blockread(f,check_me,1);
  blockread(f,count,1);
  blockread(f,xw,1);
  blockread(f,xs,1); blockread(f,ys,1);
  blockread(f,totalnum,1);
  blockread(f,hx,2); blockread(f,hy,2);
  blockread(f,call_Eachstep,1);
  blockread(f,Eachstep,1);
  blockread(f,vanishifstill,1);
 end;

 unload_saver(tripsaver);
end;

destructor triptype.Done;
var
 gd,gm:integer; xx:string[2];
 fv(*,nds*):byte;
 aa,bb:byte;
 id:longint; soa:word;
begin
 with a do
 begin
(*  nds:=num div seq;*)
  xw:=xl div 8; if (xl mod 8)>0 then inc(xw);
  for aa:=1 to (*nds*seq*) num do
  begin
   dec(totalnum);
   freemem(mani[totalnum],size-6);
   freemem(sil[totalnum],11*(yl+1));  { <<- Width of a siltype. }
  end;
 end;

 quick:=false; whichsprite:=177;
end;

constructor getsettype.Init;
begin
 numleft:=0; { initialise array pointer }
end;

procedure getsettype.remember(r:bytefield);
begin
 inc(numleft);
 if numleft>maxgetset then runerror(runerr_Getset_Overflow);
 gs[numleft]:=r;
end;

procedure getsettype.recall(var r:bytefield);
begin
 r:=gs[numleft];
 dec(numleft);
end;

procedure rwsp(t,r:byte);
begin
 with tr[t] do case r of
      up: speed(  0,-ys); down: speed(  0, ys); left: speed(-xs,  0);
   right: speed( xs,  0);   ul: speed(-xs,-ys);   ur: speed( xs,-ys);
      dl: speed(-xs, ys);   dr: speed( xs, ys);
  end;
end;

procedure apped(trn,np:byte);
begin
 with tr[trn] do
  with peds[np] do
  begin
   appear(x-a.xl div 2,y-a.yl,dir);
   rwsp(trn,dir);
  end;
end;

procedure getback;
var
 fv:byte;
 r:bytefield;
 endangered:boolean;

(*   function overlap(x1,y1,x2,y2,x3,y3,x4,y4:word):boolean;
   begin { By De Morgan's law: }
    overlap:=(x2>=x3) and (x4>=x1) and (y2>=y3) and (y4>=y1);
   end;*)
   { x1,x2 - as bytefield, but *8. y1,y2 - as bytefield.
     x3,y3 = mx,my. x4,y4 = mx+16,my+16. }
   function overlaps_with_mouse:boolean;
   begin
    with r do
     overlaps_with_mouse:=
      (x2*8>=mx) and (mx+16>=x1*8) and (y2>=my) and (my+16>=y1);
   end;

begin
 endangered:=false;
(* Super_Off;*)

 with r do
  with getset[1-cp] do
   while numleft>0 do
   begin
    recall(r);

(*    if overlaps_with_mouse and not endangered then
    begin
     endangered:=true;
     blitfix;
     Super_Off;
    end;*)

    mblit(x1,y1,x2,y2,3,1-cp);
   end;

 blitfix;
 (*if endangered then*) (*Super_On;*)
end;

{ Eachstep procedures: }
procedure follow_Avvy_Y(tripnum:byte);
begin
 with tr[tripnum] do
 begin
  if tr[1].face=left then exit;
  if homing then hy:=tr[1].y else
  begin
   if (y<tr[1].y) then
    inc(y) else
     if (y>tr[1].y) then
      dec(y) else
       exit;
   if ix=0 then begin inc(step); if step=a.seq then step:=0; count:=0; end;
  end;
 end;
end;

procedure back_and_forth(tripnum:byte);
begin
 with tr[tripnum] do
  if not homing then
  begin
   if face=right then walkto(4) else walkto(5);
  end;
end;

procedure face_Avvy(tripnum:byte);
begin
 with tr[tripnum] do
  if not homing then
  begin
   if tr[1].x>=x then face:=right
    else face:=left;
  end;
end;

procedure arrow_procs(tripnum:byte);
var fv:byte;
begin
 with tr[tripnum] do
  if homing then
  begin { Arrow is still in flight. }
   { We must check whether or not the arrow has collided with Avvy's head.
     This is so if: a) the bottom of the arrow is below Avvy's head,
      b) the left of the arrow is left of the right of Avvy's head, and
      c) the right of the arrow is right of the left of Avvy's head. }
   if ((y+a.yl)>=tr[1].y) { A }
    and (x<=(tr[1].x+tr[1].a.xl)) { B }
     and ((x+a.xl)>=tr[1].x) { C }
    then begin { OK, it's hit him... what now? }

     tr[2].call_Eachstep:=false; { prevent recursion. }
     dixi('Q',47); { Complaint! }
     done; { Deallocate the arrow. }
(*     tr[1].done; { Deallocate normal pic of Avvy. }

     off;
     for fv:=0 to 1 do
     begin
      cp:=1-cp;
      getback;
     end;
     on;*)

     gameover;

     dna.User_Moves_Avvy:=false; { Stop the user from moving him. }
     set_up_timer(55,PROCnaughty_Duke,reason_Naughty_Duke);
    end;
  end else { Arrow has hit the wall! }
  begin
   done; { Deallocate the arrow. }
   show_one(3); { Show pic of arrow stuck into the door. }
   dna.Arrow_In_The_Door:=true; { So that we can pick it up. }
  end;
end;

(*procedure Spludwick_procs(tripnum:byte);
var fv:byte;
begin
 with tr[tripnum] do
  if not homing then { We only need to do anything if Spludwick *stops*
                       walking. }
  with dna do
   begin
    inc(DogfoodPos);
    if DogfoodPos=8 then DogfoodPos:=1;
    walkto(DogfoodPos);
   end;
end;*)

procedure grab_Avvy(tripnum:byte); { For Friar Tuck, in Nottingham. }
var fv:byte; tox,toy:integer;
begin
 with tr[tripnum] do
  with dna do
   begin
    tox:=tr[1].x + 17;
    toy:=tr[1].y - 1;
    if (x=tox) and (y=toy) then
    begin
     call_eachstep:=false;
     face:=left;
     stopwalk;
     { ... whatever ... }
    end else
    begin { Still some way to go. }
     if x<tox then
     begin
      inc(x,5);
      if x>tox then x:=tox;
     end;
     if y<toy then inc(y);
     inc(step); if step=a.seq then step:=0;
    end;
   end;
end;

procedure Geida_procs(tripnum:byte);
  procedure take_a_step;
  begin
   with tr[tripnum] do
   if ix=0 then
    begin inc(step); if step=a.seq then step:=0; count:=0; end;
  end;

  procedure spin(whichway:byte);
  begin
   with tr[tripnum] do
   if face<>whichway then
   begin
    face:=whichway;
    if (whichsprite=2) then exit; { Not for Spludwick }

    inc(dna.Geida_spin);
    dna.Geida_time:=20;
    if (dna.Geida_spin=5) then
    begin
     display('Steady on, Avvy, you''ll make the poor girl dizzy!');
     dna.Geida_spin:=0; dna.Geida_time:=0; { knock out records }
    end;
   end;
  end;
begin
 with tr[tripnum] do
 begin
  if dna.Geida_time>0 then
  begin
   dec(dna.Geida_time);
   if dna.Geida_time=0 then dna.Geida_spin:=0;
  end;

  if (y<(tr[1].y-2)) then
  begin { Geida is further from the screen than Avvy. }
   spin(down);
   iy:=1; ix:=0;
   take_a_step;
   exit;
  end else
   if (y>(tr[1].y+2)) then
   begin { Avvy is further from the screen than Geida. }
    spin(up);
    iy:=-1; ix:=0;
    take_a_step;
    exit;
   end;

  iy:=0;
  if (x<tr[1].x-tr[1].xs*8) then
  begin
   ix:=tr[1].xs;
   spin(right);
   take_a_step;
  end else
    if (x>tr[1].x+tr[1].xs*8) then
    begin
     ix:=-tr[1].xs;
     spin(left);
     take_a_step;
    end else ix:=0;
 end;
end;

{ That's all... }

procedure call_andexors;
var
 order:array[1..5] of byte;
 fv,temp:byte;
 ok:boolean;
begin
 fillchar(order,5,#0);
 for fv:=1 to numtr do with tr[fv] do
  if quick and visible then
   order[fv]:=fv;

 repeat
  ok:=true;
  for fv:=1 to 4 do
   if ((order[fv]<>0) and (order[fv+1]<>0))
    and (tr[order[fv]].y>tr[order[fv+1]].y) then
   begin { Swap them! }
    temp:=order[fv];
    order[fv]:=order[fv+1];
    order[fv+1]:=temp;
    ok:=false;
   end;
 until ok;

 for fv:=1 to 5 do
  if order[fv]>0 then
   tr[order[fv]].andexor;
end;

procedure trippancy_link;
var
 fv:byte;
begin
 if ddmnow or ontoolbar or seescroll then exit;
 for fv:=1 to numtr do with tr[fv] do if quick then walk;
 call_andexors;
 for fv:=1 to numtr do with tr[fv] do
  if quick and call_eachstep then
  begin
   case tr[fv].eachstep of
    PROCfollow_Avvy_Y : follow_Avvy_Y(fv);
    PROCback_and_forth : back_and_forth(fv);
    PROCface_Avvy : face_avvy(fv);
    PROCarrow_procs : arrow_procs(fv);
(*    PROCSpludwick_procs : spludwick_procs(fv);*)
    PROCgrab_Avvy : grab_Avvy(fv);
    PROCGeida_procs : geida_procs(fv);
   end;
  end;
 if mustexclaim then
 begin
  mustexclaim:=false;
  dixi('x',saywhat);
 end;
end;

procedure get_back_Loretta;
var fv:byte;
begin
(* for fv:=1 to numtr do with tr[fv] do if quick then getback;*)
 for fv:=1 to numtr do if tr[fv].quick then
 begin
  getback;
  exit;
 end;
(* for fv:=0 to 1 do begin cp:=1-cp; getback; end;*)
end;

procedure stopwalking;
begin
 tr[1].stopwalk; dna.rw:=stopped; if alive then tr[1].step:=1;
end;

procedure tripkey(dir:char);
begin
 if (ctrl=cJoy) or (not dna.user_moves_Avvy) then exit;

 with tr[1] do
  with dna do
  begin
   case dir of
    'H': if rw<>up    then
            begin rw:=up;    rwsp(1,rw); end else stopwalking;
    'P': if rw<>down  then
            begin rw:=down;  rwsp(1,rw); end else stopwalking;
    'K': if rw<>left  then
            begin rw:=left;  rwsp(1,rw); end else stopwalking;
    'M': if rw<>right then
            begin rw:=right; rwsp(1,rw); end else stopwalking;
    'I': if rw<>ur    then
            begin rw:=ur;    rwsp(1,rw); end else stopwalking;
    'Q': if rw<>dr    then
            begin rw:=dr;    rwsp(1,rw); end else stopwalking;
    'O': if rw<>dl    then
            begin rw:=dl;    rwsp(1,rw); end else stopwalking;
    'G': if rw<>ul    then
            begin rw:=ul;    rwsp(1,rw); end else stopwalking;
    'L': stopwalking;
   end;
 end;
end;

procedure readstick;
var jw:byte;
begin
 if ctrl=cKey then exit;

 jw:=joyway;

 with tr[1] do
 begin
  if jw=stopped then stopwalking else
  begin
   dna.rw:=jw; rwsp(1,dna.rw);
  end;
 end;

 if jw<>oldjw then
 begin
  showrw;
  oldjw:=jw;
 end;

end;

procedure getsetclear;
var fv:byte;
begin
 for fv:=0 to 1 do getset[fv].Init;
end;

procedure hide_in_the_cupboard;
const nowt = #250; { As in Acci. }
begin
 with dna do
 begin
  if Avvys_in_the_cupboard then
  begin
   if wearing=nowt then
    display(^f'AVVY!'^r' Get dressed first!')
   else
   begin
    tr[1].visible:=true;
    user_moves_Avvy:=true;
    apped(1,3); { Walk out of the cupboard. }
    display('You leave the cupboard. Nice to be out of there!');
    Avvys_in_the_cupboard:=false;
    first_show(8); then_show(7); start_to_close;
   end;
  end else
  begin { Not hiding in the cupboard }
   tr[1].visible:=false;
   user_moves_Avvy:=false;
   display('You walk into the room...'^p'It seems to be an empty, '+
    'but dusty, cupboard. Hmmmm... you leave the door slightly open to '+
    'avoid suffocation.');
   Avvys_in_the_cupboard:=true;
   show_one(8);
  end;
 end;
end;

procedure fliproom(room,ped:byte);
var fv:byte; beforex,beforey:integer;

   procedure tidy_after_mouse;

      procedure tidy_up(a,b,c,d:integer);
      var bf:bytefield;
      begin
         with bf do
         begin
            x1:=a div 8;
            y1:=b;
            x2:=(c+7) div 8;
            y2:=d;
            setactivepage(0);
            rectangle(x1*8,y1,x2*8+7,y2);
         end;
         getset[0].remember(bf);
         getset[1].remember(bf);
      end;
   begin
      tidy_up(beforex,beforey,beforex+15,beforey+15);
      xycheck;
      tidy_up(mx,my,mx+15,my+15);
   end;

begin
 if not alive then
 begin { You can't leave the room if you're dead. }
   tr[1].ix:=0; tr[1].iy:=0; { Stop him from moving. }
   exit;
 end;

 if (ped=177) and (dna.room=r__Lusties) then
 begin
  hide_in_the_cupboard;
  exit;
 end;

 if (dna.jumpstatus>0) and (dna.room=r__InsideCardiffCastle) then
 begin { You can't *jump* out of Cardiff Castle! }
  tr[1].ix:=0;
  exit;
 end;

 xycheck; beforex:=mx; beforey:=my;

 exitroom(dna.room);
 dusk; getsetclear;


 for fv:=2 to numtr do
  with tr[fv] do
  if quick then done; { Deallocate sprite }

 if dna.room=r__LustiesRoom then
  dna.Enter_Catacombs_From_Lusties_Room:=True;

 enterroom(room,ped); apped(1,ped);
 dna.Enter_Catacombs_From_Lusties_Room:=False;
 oldrw:=dna.rw; dna.rw:=tr[1].face; showrw;

 for fv:=0 to 1 do
 begin
  cp:=1-cp;
  getback;
 end;
 dawn;

 { Tidy up after mouse. I know it's a kludge... }
(*  tidy_after_mouse;*)
end;

function infield(which:byte):boolean;
 { returns True if you're within field "which" }
var yy:integer;
begin
 with fields[which] do with tr[1] do
 begin
  yy:=y+a.yl;
  infield:=(x>=x1) and (x<=x2) and (yy>=y1) and (yy<=y2);
 end;
end;

function neardoor:boolean; { returns True if you're near a door! }
var ux,uy:integer; fv:byte; nd:boolean;
begin
 if numfields<9 then
 begin { there ARE no doors here! }
  neardoor:=false;
  exit;
 end;
 with tr[1] do
 begin
  ux:=x;
  uy:=y+a.yl;
 end; nd:=false;
 for fv:=9 to numfields do
  with fields[fv] do
  begin
   if ((ux>=x1) and (ux<=x2) and (uy>=y1) and (uy<=y2)) then nd:=true;
  end;
 neardoor:=nd;
end;

procedure new_game_for_trippancy; { Called by gyro.newgame }
begin
 tr[1].visible:=false;
end;

procedure triptype.save_data_to_mem(var where:word);
var
 tripsaver:trip_saver_type;
begin
 set_up_saver(tripsaver);
 move(tripsaver,mem[Storage_SEG:where],sizeof(tripsaver));
 inc(where,sizeof(tripsaver));
end;

procedure triptype.load_data_from_mem(var where:word);
var
 spritewas,spriteis,saveface,savex,savey,savestep:word;
 wasquick:boolean;
 tripsaver:trip_saver_type;
begin
 move(mem[Storage_SEG:where],tripsaver,sizeof(tripsaver));
 inc(where,sizeof(tripsaver));
 unload_saver(tripsaver);

 spriteis:=whichsprite;
 savex:=x; savey:=y; saveface:=face; savestep:=step;

 init(spriteis,check_me);

 appear(savex,savey,saveface); unload_saver(tripsaver);
 step:=savestep;
end;

begin
 getsetclear; mustexclaim:=false;
end.
