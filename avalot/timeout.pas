{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 TIMEOUT          The scheduling unit. }

unit Timeout;

interface

uses Gyro,Celer;

const
 { reason_ now runs between 1 and 28. }

 reason_DrawbridgeFalls = 2;
 reason_AvariciusTalks = 3;
 reason_GoToToilet = 4;
 reason_Explosion = 5;
 reason_BrummieStairs = 6;
 reason_CardiffSurvey = 7;
 reason_Cwytalot_in_Herts = 8;
 reason_Getting_Tied_Up = 9;
 reason_Hanging_Around = 10; { Tied to the tree in Nottingham. }
 reason_Jacques_waking_up = 11;
 reason_Naughty_Duke = 12;
 reason_Jumping = 13;
 reason_Sequencer = 14;
 reason_Crapulus_says_Spludwick_Out = 15;
 reason_DawnDelay = 16;
 reason_Drinks = 17;
 reason_du_Lustie_talks = 18;
 reason_falling_down_oubliette = 19;
 reason_meeting_Avaroid = 20;
 reason_rising_up_oubliette = 21;
 reason_robin_hood_and_geida = 22;
 reason_sitting_down = 23;
 reason_ghost_room_phew = 1;
 reason_arkata_shouts = 24;
 reason_winning = 25;
 reason_falling_over = 26;
 reason_Spludwalk = 27;
 reason_Geida_sings = 28;

 { PROCx now runs between 1 and 41. }

 PROCopen_drawbridge = 3;

 PROCAvaricius_talks = 4;

 PROCurinate = 5;

 PROCtoilet2 = 6;

 PROCbang = 7;

 PROCbang2 = 8;

 PROCstairs = 9;

 PROCcardiffsurvey = 10;

 PROCcardiff_return = 11;

 PROC_Cwytalot_in_Herts = 12;

 PROCget_tied_up = 13;

 PROCget_tied_up2 = 1;

 PROChang_around = 14;

 PROChang_around2 = 15;

 PROCafter_the_shootemup = 32;

 PROCJacques_wakes_up = 16;

 PROCnaughty_Duke = 17;

 PROCnaughty_Duke2 = 18;

 PROCnaughty_Duke3 = 38;

 PROCjump = 19;

 PROCsequence = 20;

 PROCCrapulus_Splud_Out = 21;

 PROCDawn_Delay = 22;

 PROCbuydrinks = 23;

 PROCbuywine = 24;

 PROCcallsguards = 25;

 PROCgreetsmonk = 26;

 PROCfall_down_oubliette = 27;

 PROCmeet_Avaroid = 28;

 PROCrise_up_oubliette = 29;

 PROCrobin_hood_and_geida = 2;

 PROCrobin_hood_and_geida_TALK = 30;

 PROCavalot_returns = 31;

 PROCavvy_sit_down = 33; { In Nottingham. }

 PROCghost_room_phew = 34;

 PROCArkata_shouts = 35;

 PROCwinning = 36;

 PROCAvalot_falls = 37;

 PROCSpludwick_goes_to_cauldron = 39;

 PROCSpludwick_leaves_cauldron = 40;

 PROCgive_lute_to_Geida = 41;

type
 timetype = record
             time_left:longint;
             then_where:byte;
             what_for:byte;
            end;

var
 times:array[1..7] of timetype;

procedure set_up_timer(howlong:longint; whither,why:byte);

procedure one_tick;

procedure lose_timer(which:byte);

(*function timer_is_on(which:byte):boolean;*)

 { Procedures to do things at the end of amounts of time: }

 procedure open_drawbridge;

 procedure Avaricius_talks;

 procedure Urinate;

 procedure Toilet2;

 procedure bang;

 procedure bang2;

 procedure stairs;

 procedure Cardiff_survey;

 procedure Cardiff_return;

 procedure Cwytalot_in_Herts;

 procedure get_tied_up;

 procedure get_tied_up2;

 procedure hang_around;

 procedure hang_around2;

 procedure after_the_shootemup;

 procedure Jacques_wakes_up;

 procedure Naughty_Duke;

 procedure Naughty_Duke2;

 procedure Naughty_Duke3;

 procedure jump;

 procedure Crapulus_says_Splud_out;

 procedure buydrinks;

 procedure buywine;

 procedure callsguards;

 procedure greetsmonk;

 procedure fall_down_oubliette;

 procedure meet_Avaroid;

 procedure rise_up_oubliette;

 procedure robin_hood_and_geida;

 procedure robin_hood_and_geida_TALK;

 procedure avalot_returns;

 procedure avvy_sit_down;

 procedure ghost_room_phew;

 procedure Arkata_shouts;

 procedure winning;

 procedure Avalot_falls;

 procedure Spludwick_goes_to_cauldron;

 procedure Spludwick_leaves_cauldron;

 procedure give_lute_to_Geida;

implementation

uses Visa,Lucerna,Trip5,Scrolls,Sequence,Pingo,Acci,Enid;

var
 fv:byte;

procedure set_up_timer(howlong:longint; whither,why:byte);
begin
 fv:=1;
 while (fv<8) and (times[fv].time_left<>0) do inc(fv);
 if fv=8 then exit; { Oh dear... }

 with times[fv] do { Everything's OK here! }
 begin
  time_left:=howlong;
  then_where:=whither;
  what_for:=why;
 end;
end;

procedure one_tick;
begin

 if ddmnow then exit;

 for fv:=1 to 7 do
  with times[fv] do
   if time_left>0 then
   begin
    dec(time_left);

    if time_left=0 then
    case then_where of
     PROCopen_drawbridge : open_drawbridge;
     PROCAvaricius_talks : Avaricius_talks;
     PROCUrinate : Urinate;
     PROCToilet2 : Toilet2;
     PROCbang: bang;
     PROCbang2: bang2;
     PROCstairs: stairs;
     PROCcardiffsurvey: Cardiff_Survey;
     PROCcardiff_return: Cardiff_Return;
     PROC_Cwytalot_in_Herts: Cwytalot_in_Herts;
     PROCget_tied_up: get_tied_up;
     PROCget_tied_up2: get_tied_up2;
     PROChang_around: hang_around;
     PROChang_around2: hang_around2;
     PROCafter_the_shootemup: after_the_shootemup;
     PROCJacques_wakes_up: Jacques_wakes_up;
     PROCnaughty_Duke: naughty_Duke;
     PROCnaughty_Duke2: naughty_Duke2;
     PROCnaughty_Duke3: naughty_Duke3;
     PROCjump: jump;
     PROCsequence: call_sequencer;
     PROCCrapulus_Splud_Out: Crapulus_says_Splud_out;
     PROCDawn_Delay: Dawn;
     PROCbuydrinks: buydrinks;
     PROCbuywine: buywine;
     PROCcallsguards: callsguards;
     PROCgreetsmonk: greetsmonk;
     PROCfall_down_oubliette: fall_down_oubliette;
     PROCmeet_Avaroid: meet_Avaroid;
     PROCrise_up_oubliette: rise_up_oubliette;
     PROCrobin_hood_and_geida: robin_hood_and_geida;
     PROCrobin_hood_and_geida_TALK: robin_hood_and_geida_TALK;
     PROCavalot_returns: avalot_returns;
     PROCavvy_sit_down: avvy_sit_down;
     PROCghost_room_phew: ghost_room_phew;
     PROCArkata_shouts: arkata_shouts;
     PROCwinning: winning;
     PROCAvalot_falls: Avalot_falls;
     PROCSpludwick_goes_to_cauldron: Spludwick_goes_to_cauldron;
     PROCSpludwick_leaves_cauldron: Spludwick_leaves_cauldron;
     PROCgive_lute_to_Geida: give_lute_to_Geida;
    end;
   end;
 inc(roomtime); { Cycles since you've been in this room. }
 inc(dna.total_time); { Total amount of time for this game. }
end;

procedure lose_timer(which:byte);
var fv:byte;
begin
 for fv:=1 to 7 do
  with times[fv] do
   if what_for=which then
    time_left:=0; { Cancel this one! }
end;

(*function timer_is_on(which:byte):boolean;
var fv:byte;
begin
 for fv:=1 to 7 do
  with times[fv] do
   if (what_for=which) and (time_left>0) then
   begin
    timer_is_on:=true;
    exit;
   end;
 timer_is_on:=false;
end;*)

{ Timeout procedures: }

procedure open_drawbridge;
begin
 with dna do
 begin
  inc(drawbridge_open);
  show_one(drawbridge_open-1);

  if drawbridge_open=4 then
   magics[2].op:=nix { You may enter the drawbridge. }
  else set_up_timer(7,PROCopen_drawbridge,Reason_DrawbridgeFalls);
 end;
end;

{ --- }

procedure Avaricius_talks;
begin
 with dna do
 begin
  dixi('q',Avaricius_talk);
  inc(Avaricius_talk);

  if Avaricius_talk<17 then
   set_up_timer(177,PROCAvaricius_talks,reason_AvariciusTalks)
  else points(3);

 end;
end;

procedure Urinate;
begin
 tr[1].turn(up);
 stopwalking;
 showrw;
 set_up_timer(14,PROCtoilet2,reason_GoToToilet);
end;

procedure Toilet2;
begin
 display('That''s better!');
end;

procedure bang;
begin
 display(^f'< BANG! >');
 set_up_timer(30,PROCbang2,reason_explosion);
end;

procedure bang2;
begin
 display('Hmm... sounds like Spludwick''s up to something...');
end;

procedure stairs;
begin
 blip;
 tr[1].walkto(4);
 show_one(2);
 dna.Brummie_Stairs:=2;
 magics[11].op:=special;
 magics[11].data:=2; { Reached the bottom of the stairs. }
 magics[4].op:=nix; { Stop them hitting the sides (or the game will hang.) }
end;

procedure Cardiff_survey;
begin
 with dna do
 begin
  case Cardiff_things of
   0: begin
       inc(Cardiff_things);
       dixi('q',27);
      end;
  end;
  dixi('z',Cardiff_things);
 end;
 interrogation:=dna.Cardiff_things;
 set_up_timer(182,PROCcardiffsurvey,reason_CardiffSurvey);
end;

procedure Cardiff_return;
begin
 dixi('q',28);
 Cardiff_survey; { add end of question. }
end;

procedure Cwytalot_in_Herts;
begin
 dixi('q',29);
end;

procedure get_tied_up;
begin
 dixi('q',34); { ...Trouble! }
 dna.user_moves_Avvy:=false;
 dna.been_tied_up:=true;
 stopwalking;
 tr[2].stopwalk; tr[2].stophoming;
 tr[2].call_Eachstep:=true;
 tr[2].eachstep:=PROCgrab_Avvy;
 set_up_timer(70,PROCget_tied_up2,reason_Getting_Tied_Up);
end;

procedure get_tied_up2;
begin
 tr[1].walkto(4);
 tr[2].walkto(5);
 magics[4].op:=nix; { No effect when you touch the boundaries. }
 dna.Friar_Will_Tie_You_Up:=true;
end;

procedure hang_around;
begin
 tr[2].Check_Me:=false;
 tr[1].init(7,true); { Robin Hood }
 whereis[pRobinHood]:=r__Robins;
 apped(1,2);
 dixi('q',39);
 tr[1].walkto(7);
 set_up_timer(55,PROChang_around2,reason_hanging_around);
end;

procedure hang_around2;
begin
 dixi('q',40);
 tr[2].VanishIfStill:=false;
 tr[2].walkto(4);
 whereis[pFriarTuck]:=r__Robins;
 dixi('q',41);
 tr[1].done; tr[2].done; { Get rid of Robin Hood and Friar Tuck. }

 set_up_timer(1,PROCafter_the_shootemup,reason_Hanging_Around); { Immediately
  call the following proc (when you have a chance). }

 dna.tied_up:=false;

 back_to_bootstrap(1); { Call the shoot-'em-up. }
end;

procedure after_the_shootemup;
var shootscore,gain:byte;
begin
 tr[1].init(0,true); { Avalot. }
 apped(1,2); dna.user_moves_Avvy:=true;
 dna.obj[crossbow]:=true; objectlist;

 shootscore:=mem[Storage_SEG:Storage_OFS];
 gain:=(shootscore+5) div 10; { Rounding up. }

 display(^f'Your score was '+strf(shootscore)+'.'+^m^m'You gain ('+
    strf(shootscore)+' ˆ 10) = '+strf(gain)+' points.');

 if gain>20 then
 begin
   display('But we won''t let you have more than 20 points!');
   points(20)
 end else
   points(gain);

 dixi('q',70);
end;

procedure Jacques_wakes_up;
begin
 inc(dna.Jacques_awake);

 case dna.Jacques_awake of { Additional pictures. }
  1 : begin
       show_one(1); { Eyes open. }
       dixi('Q',45);
      end;
  2 : begin { Going through the door. }
       show_one(2); { Not on the floor. }
       show_one(3); { But going through the door. }
       magics[6].op:=nix; { You can't wake him up now. }
      end;
  3 : begin { Gone through the door. }
       show_one(2); { Not on the floor, either. }
       show_one(4); { He's gone... so the door's open. }
       whereis[pJacques]:=0; { Gone! }
      end;
 end;


 if dna.Jacques_awake=5 then
 begin
  dna.ringing_bells:=true;
  dna.Ayles_is_awake:=true;
  points(2);
 end;

 case dna.Jacques_awake of
  1..3: set_up_timer(12,PROCJacques_wakes_up,reason_Jacques_waking_up);
  4: set_up_timer(24,PROCJacques_wakes_up,reason_Jacques_waking_up);
 end;

end;

procedure naughty_Duke;
 { This is when the Duke comes in and takes your money. }
begin
 tr[2].init(9,false); { Here comes the Duke. }
 apped(2,1); { He starts at the door... }
 tr[2].walkto(3); { He walks over to you. }

 { Let's get the door opening. }

 show_one(1); first_show(2); start_to_close;

 set_up_timer(50,PROCnaughty_Duke2,reason_naughty_Duke);
end;

procedure naughty_Duke2;
begin
 dixi('q',48); { Ha ha, it worked again! }
 tr[2].walkto(1); { Walk to the door. }
 tr[2].VanishIfStill:=true; { Then go away! }
 set_up_timer(32,PROCnaughty_Duke3,reason_naughty_Duke);
end;

procedure naughty_Duke3;
begin
 show_one(1); first_show(2); start_to_close;
end;

procedure jump;
begin
 with dna do
 begin
  inc(jumpstatus);

  with tr[1] do
   case jumpstatus of
    1,2,3,5,7,9: dec(y);
    12,13,14,16,18,19: inc(y);
   end;

  if jumpstatus=20 then
  begin { End of jump. }
   dna.user_moves_Avvy:=true;
   dna.jumpstatus:=0;
  end else
  begin { Still jumping. }
   set_up_timer(1,PROCjump,reason_Jumping);
  end;

  if (jumpstatus=10) { You're at the highest point of your jump. }
   and (dna.room=r__InsideCardiffCastle)
    and (dna.Arrow_In_The_Door=true)
     and (infield(3)) { beside the wall} then
    begin { Grab the arrow! }
       if dna.carrying>=maxobjs then
          display('You fail to grab it, because your hands are full.')
       else
       begin
          show_one(2);
          dna.Arrow_In_The_Door:=false; { You've got it. }
          dna.obj[bolt]:=true;
          objectlist;
          dixi('q',50);
          points(3);
       end;
    end;
 end;
end;

procedure Crapulus_says_Splud_out;
begin
 dixi('q',56);
 dna.Crapulus_will_tell:=false;
end;

procedure buydrinks;
begin
 show_one(11); { Malagauche gets up again. }
 dna.malagauche:=0;

 dixi('D',ord(dna.drinking)); { Display message about it. }
 wobble; { Do the special effects. }
 dixi('D',1); { That'll be thruppence. }
 if pennycheck(3) { Pay 3d. }
  then dixi('D',3); { Tell 'em you paid up. }
 have_a_drink;
end;

procedure buywine;
begin
 show_one(11); { Malagauche gets up again. }
 dna.malagauche:=0;

 dixi('D',50); { You buy the wine. }
 dixi('D',1); { It'll be thruppence. }
 if pennycheck(3) then
 begin
  dixi('D',4); { You paid up. }
  dna.obj[wine]:=true;
  objectlist;
  dna.winestate:=1; { OK Wine }
 end;
end;

procedure callsguards;
begin
 dixi('Q',58); { GUARDS!!! }
 gameover;
end;

procedure greetsmonk;
begin
 dixi('Q',59); dna.Entered_Lusties_Room_As_Monk:=true;
end;

procedure fall_down_oubliette;
begin
 magics[9].op:=nix;
 inc(tr[1].iy); { increments dx/dy! }
 inc(tr[1].y,tr[1].iy); { Dowwwn we go... }
 set_up_timer(3,PROCfall_down_oubliette,reason_falling_down_oubliette);
end;

procedure meet_Avaroid;
begin
 if dna.Met_Avaroid then
 begin
  display('You can''t expect to be '^f'that'^r' lucky twice in a row!');
  gameover;
 end else
 begin
  dixi('Q',60); dna.Met_Avaroid:=true;
  set_up_timer(1,PROCrise_up_oubliette,reason_rising_up_oubliette);
  with tr[1] do begin face:=left; x:=151; ix:=-3; iy:=-5; end;
  background(2);
 end;
end;

procedure rise_up_oubliette;
begin
 with tr[1] do
 begin
  visible:=true;
  inc(iy); { decrements dx/dy! }
  dec(y,iy); { Uuuupppp we go... }
  if iy>0 then
   set_up_timer(3,PROCrise_up_oubliette,reason_rising_up_oubliette)
  else
   dna.User_Moves_Avvy:=true;
 end;
end;

procedure robin_hood_and_geida;
begin
 tr[1].init(7,true);
 apped(1,7);
 tr[1].walkto(6);
 tr[2].stopwalk;
 tr[2].face:=left;
 set_up_timer(20,PROCrobin_hood_and_geida_TALK,reason_robin_hood_and_geida);
 dna.Geida_follows:=false;
end;

procedure robin_hood_and_geida_TALK;
begin
 dixi('q',66); tr[1].walkto(2); tr[2].walkto(2);
 tr[1].vanishifstill:=true; tr[2].vanishifstill:=true;
 set_up_timer(162,PROCavalot_returns,reason_robin_hood_and_geida);
end;

procedure avalot_returns;
begin
 tr[1].done; tr[2].done;
 tr[1].init(0,true);
 apped(1,1);
 dixi('q',67);
 dna.user_moves_avvy:=true;
end;

procedure avvy_sit_down;
 { This is used when you sit down in the pub in Notts. It loops around so
   that it will happen when Avvy stops walking. }
begin
 if tr[1].homing then { Still walking }
  set_up_timer(1,PROCAvvy_sit_down,reason_sitting_down)
 else
 begin
  show_one(3);
  dna.sitting_in_pub:=true;
  dna.user_moves_Avvy:=false;
  tr[1].visible:=false;
 end;
end;

procedure ghost_room_phew;
begin
 display(^f'PHEW!'^r' You''re glad to get out of '^f'there!');
end;

procedure Arkata_shouts;
begin
  if dna.teetotal then exit;
  dixi('q',76);
  set_up_timer(160,PROCArkata_shouts,reason_Arkata_shouts);
end;

procedure winning;
begin
 dixi('q',79);
 winning_pic;
 repeat checkclick until mrelease=0;
 callverb(vb_score);
 display(' T H E    E N D ');
 lmo:=true;
end;

procedure Avalot_falls;
begin
 if tr[1].step<5 then
 begin
  inc(tr[1].step);
  set_up_timer(3,PROCAvalot_falls,reason_falling_over);
 end else
  display(^m^m^m^m^m^m^i^i^i^i^i^i^s'Z'^v);
end;

procedure Spludwick_goes_to_cauldron;
begin
  if tr[2].homing then
    set_up_timer(1,PROCSpludwick_goes_to_cauldron,reason_Spludwalk)
  else
    set_up_timer(17,PROCSpludwick_leaves_cauldron,reason_Spludwalk);
end;

procedure Spludwick_leaves_cauldron;
begin
  tr[2].call_Eachstep:=true; { So that normal procs will continue. }
end;

procedure give_lute_to_Geida; { Moved here from Acci. }
begin
  dixi('Q',86);
  points(4);
  dna.Lustie_is_asleep:=true;
  first_show(5); then_show(6); { He falls asleep... }
  start_to_close; { Not really closing, but we're using the same procedure. }
end;

{ "This is all!" }

begin
 fillchar(times,sizeof(times),#0);
end.
