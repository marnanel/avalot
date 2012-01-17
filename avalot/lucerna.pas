{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 LUCERNA          The screen, [keyboard] and mouse handler. }

unit Lucerna;

interface

uses Gyro;

 procedure callverb(n:char);

 procedure draw_also_lines;

 procedure mouse_init;

 procedure mousepage(page:word);

 procedure load(n:byte);

 procedure exitroom(x:byte);

 procedure enterroom(x,ped:byte);

 procedure thinkabout(z:char; th:boolean); { Hey!!! Get it and put it!!! }

 procedure load_digits; { Load the scoring digits & rwlites }

 procedure toolbar;

 procedure showscore;

 procedure points(num:byte); { Add on no. of points }

 procedure mouseway;

 procedure inkey;

 procedure posxy;

 procedure fxtoggle;

 procedure objectlist;

 procedure checkclick;

 procedure errorled;

 procedure dusk;

 procedure dawn;

 procedure showrw;

 procedure mblit(x1,y1,x2,y2:byte; f,t:byte); { The Minstrel Blitter }

 procedure blitfix;

 procedure clock;

 procedure flip_page;

 procedure delavvy;

 procedure gameover;

 procedure minor_redraw;

 procedure major_redraw;

 function bearing(whichped:byte):word;

 procedure flesh_colours;

 procedure sprite_run;

 procedure fix_flashers;

implementation

uses Graph,Dos,Crt,Trip5,Acci,Pingo,Scrolls,
 Enhanced,Dropdown,Logger,Visa,Celer,Timeout,Basher,Sequence;

{$V-} {$S-}
var fxhidden:boolean; fxpal:array[0..3] of palettetype;

procedure callverb(n:char);
begin
  if n=pardon then
  begin
    display('The f5 key lets you do a particular action in certain '+
            'situations. However, at the moment there is nothing '+
            'assigned to it. You may press alt-A to see what the '+
            'current setting of this key is.');
  end else
  begin
    weirdword:=false; polite:=true; verb:=n;
    do_that;
  end;
end;

procedure draw_also_lines;
var
 ff:byte;
 squeaky_code:byte;
begin
   case Visible of
      M_Virtual : begin squeaky_code := 1; off_virtual; end;
      M_No      :       squeaky_code := 2;
      M_Yes     : begin squeaky_code := 3; off;         end;
   end;

 setactivepage(2);
 cleardevice;
 setcolor(15); rectangle(0,45,639,160);
 for ff:=1 to 50 do
  with lines[ff] do
   if x1<>maxint then
   begin
    setcolor(col); line(x1,y1,x2,y2);
   end;

   case squeaky_code of
      1 : on_virtual;
      2 : ; { zzzz, it was off anyway }
      3 : on;
   end;
end;

procedure load_also(n:string);
var
 f:file; minnames:byte; ff,fv:byte;

  function nextstring:string;
  var l:byte; x:string;
  begin
   blockread(f,l,1); blockread(f,x[1],l); x[0]:=chr(l); nextstring:=x;
  end;

 procedure unscramble;
 var fv,ff:byte;
    procedure scram1(var x:string);
    var fz:byte;
    begin;
     for fz:=1 to length(x) do
      x[fz]:=chr(ord(x[fz]) xor 177);
    end;
 begin
  for fv:=0 to 30 do
   for ff:=0 to 1 do
    if also[fv,ff]<>nil then
      scram1(also[fv,ff]^);
  scram1(listen);
  scram1(flags);
(*     for fz:=1 to length(also[fv,ff]^) do
      also[fv,ff]^[fz]:=chr(ord(also[fv,ff]^[fz]) xor 177);*)
 end;

begin
 for fv:=0 to 30 do
  for ff:=0 to 1 do
   if also[fv,ff]<>nil then begin dispose(also[fv,ff]); also[fv,ff]:=nil; end;
 assign(f,'also'+n+'.avd');
{$I-} reset(f,1); {$I+} if ioresult<>0 then exit; { no Also file }
 seek(f,128); blockread(f,minnames,1);
 for fv:=0 to minnames do
 begin
  for ff:=0 to 1 do
  begin
   new(also[fv,ff]);
   also[fv,ff]^:=nextstring;
  end;
  also[fv,0]^:=#157+also[fv,0]^+#157;
 end;
 fillchar(lines,sizeof(lines),$FF);

 fv:=getpixel(0,0); blockread(f,fv,1);
 blockread(f,lines,sizeof(lines[1])*fv);
 blockread(f,fv,1); fillchar(peds,sizeof(peds),#177);
 blockread(f,peds,sizeof(peds[1])*fv);
 blockread(f,numfields,1); blockread(f,fields,sizeof(fields[1])*numfields);
 blockread(f,magics,sizeof(magics));
 blockread(f,portals,sizeof(portals));
 blockread(f,flags,sizeof(flags));
 blockread(f,listen[0],1);
 blockread(f,listen[1],length(listen));
 draw_also_lines;

 setactivepage(1); close(f);
 unscramble;
 for fv:=0 to minnames do
  also[fv,0]^:=','+also[fv,0]^+',';
end;

procedure load(n:byte); { Load2, actually }
var
 a0:byte absolute $A000:800;
 a1:byte absolute $A000:17184;
 bit:byte;
 f:file; xx:string[2];
 was_Virtual:boolean;
begin
 was_Virtual:=visible=m_Virtual;
 if was_Virtual then off_virtual else off;
 clear_vmc;

 xx:=strf(n); flesh_colours;
 assign(f,'place'+xx+'.avd'); reset(f,1);
 seek(f,146); blockread(f,RoomName,30);
 { Compression method byte follows this... }
 seek(f,177);
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a0,12080); move(a0,a1,12080);
 end;
 close(f); load_also(xx); load_chunks(xx);

 copy03; bit:=getpixel(0,0);
 log_newroom(RoomName);

 if was_Virtual then on_Virtual else on;
end;

procedure zoomout(x,y:integer);
var
 x1,y1,x2,y2:integer;
 fv:byte;
begin
 setcolor(white); setwritemode(xorput);
 setlinestyle(dottedln,0,1);

 for fv:=1 to 20 do
 begin
  x1:=x-(x div 20)*fv;
  y1:=y-((y-10) div 20)*fv;
  x2:=x+(((639-x) div 20)*fv);
  y2:=y+(((161-y) div 20)*fv);

  rectangle(x1,y1,x2,y2);
  delay(17);
  rectangle(x1,y1,x2,y2);
 end;
 setwritemode(copyput); setlinestyle(0,0,1);
end;

procedure find_people(room:byte);
var fv:char;
begin
 for fv:=#151 to #178 do
  if whereis[fv]=room then
  begin
   if fv<#175 then him:=fv else her:=fv;
  end;
end;

procedure exitroom(x:byte);
begin
 nosound;
 forget_chunks;
 seescroll:=true; { This stops the trippancy system working over the
  length of this procedure. }

 with dna do
  case x of
   r__Spludwicks: begin
                   lose_timer(reason_AvariciusTalks);
  { He doesn't HAVE to be talking for this to work. It just deletes it IF it
  exists. }        Avaricius_talk:=0;
                  end;
   r__Bridge: if drawbridge_open>0 then
              begin
               drawbridge_open:=4; { Fully open. }
               lose_timer(reason_DrawbridgeFalls);
              end;
   r__OutsideCardiffCastle: lose_timer(reason_CardiffSurvey);

   r__Robins: lose_timer(reason_getting_tied_up);
  end;

 interrogation:=0; { Leaving the room cancels all the questions automatically. }

 seescroll:=false; { Now it can work again! }

 dna.last_room:=dna.room;
 if dna.room<>r__Map then
  dna.last_room_not_map:=dna.room;
end;

procedure new_town; { You've just entered a town from the map. }
begin
 standard_bar;

 case dna.room of
  r__OutsideNottsPub: { Entry into Nottingham. }
    if (dna.rooms[r__Robins]>0) and (dna.been_tied_up) and
     (not dna.Taken_Mushroom) then
      dna.Mushroom_Growing:=true;
  r__WiseWomans: { Entry into Argent. }
   begin
    if dna.Talked_To_Crapulus and (not dna.Lustie_is_asleep) then
    begin
     dna.Spludwicks_here:=not ((dna.rooms[r__WiseWomans] mod 3)=1);
     dna.Crapulus_will_tell:=not dna.Spludwicks_here;
    end else
    begin
      dna.Spludwicks_here:=true;
      dna.Crapulus_will_tell:=false;
    end;
    if (dna.box_contents=wine) then dna.winestate:=3; { Vinegar }
   end;
 end;

 if dna.room<>r__OutsideDucks then
 begin
  if (dna.obj[onion]) and not (dna.onion_in_vinegar) then
   dna.rotten_onion:=true; { You're holding the onion }
 end;
end;

procedure enterroom(x,ped:byte);
  procedure put_Geida_at(whichped:byte);
  begin
   if ped=0 then exit;
   tr[2].init(5,false); { load Geida }
   apped(2,whichped);
   tr[2].call_Eachstep:=true;
   tr[2].Eachstep:=PROCGeida_procs;
  end;
begin

 seescroll:=true; { This stops the trippancy system working over the
  length of this procedure. }

 find_people(x);
 dna.room:=x; if ped<>0 then inc(dna.rooms[x]);

 load(x);

 if (dna.rooms[x]=0) and (not flagset('S')) then points(1);
 whereis[pAvalot]:=dna.room;
 if dna.Geida_follows then whereis[pGeida]:=x;
 roomtime:=0;

 with dna do
  if (last_room=r__Map) and (last_room_not_map<>room) then
   new_town;

 case x of
  r__Yours: if dna.Avvy_in_bed then
            begin
             show_one(3);
             set_up_timer(100,PROCArkata_shouts,reason_Arkata_shouts);
            end;

  r__OutsideYours: if ped>0 then
  begin
   if not dna.talked_to_Crapulus then
   begin

    whereis[pCrapulus]:=r__OutsideYours;
    tr[2].init(8,false); { load Crapulus }

    if dna.rooms[r__OutsideYours]=1 then
    begin
     apped(2,4); { Start on the right-hand side of the screen. }
     tr[2].walkto(5); { Walks up to greet you. }
    end else
    begin
     apped(2,5); { Starts where he was before. }
     tr[2].face:=3;
    end;

    tr[2].call_Eachstep:=true;
    tr[2].Eachstep:=PROCface_Avvy; { He always faces Avvy. }

   end else whereis[pCrapulus]:=r__Nowhere;

   if dna.Crapulus_will_tell then
   begin
    tr[2].init(8,false);
    apped(2,2);
    tr[2].walkto(4);
    set_up_timer(20,PROCCrapulus_Splud_out,reason_Crapulus_says_Spludwick_out);
    dna.Crapulus_will_tell:=false;
   end;
  end;

  r__OutsideSpludwicks:
   if (dna.rooms[r__OutsideSpludwicks]=1) and (ped=1) then
   begin
    set_up_timer(20,PROCbang,reason_explosion);
    dna.Spludwicks_here:=true;
   end;

  r__Spludwicks:
   if dna.Spludwicks_here then
   begin
    if ped>0 then
    begin
     tr[2].init(2,false); { load Spludwick }
     apped(2,2);
     whereis[#151]:=r__Spludwicks;
    end;

    dna.DogfoodPos := 0; { Also Spludwick pos. }

    tr[2].call_Eachstep :=true;
    tr[2].Eachstep:=PROCGeida_procs;
   end else whereis[#151]:=r__Nowhere;

  r__BrummieRoad:
   begin
    if dna.Geida_follows then put_Geida_at(5);
    if dna.cwytalot_gone then
    begin
      magics[lightred].op:=nix;
      whereis[pCwytalot]:=r__Nowhere;
    end else
    begin
     if ped>0 then
     begin
      tr[2].init(4,false); { 4=Cwytalot}
      tr[2].call_Eachstep:=true;
      tr[2].Eachstep:=PROCfollow_Avvy_Y;
      whereis[pCwytalot]:=r__BrummieRoad;

      if dna.rooms[r__BrummieRoad]=1 then { First time here... }
      begin
       apped(2,2); { He appears on the right of the screen... }
       tr[2].walkto(4); { ...and he walks up... }
      end else
      begin { You've been here before. }
       apped(2,4); { He's standing in your way straight away... }
       tr[2].face:=left;
      end;
     end;
    end;
   end;

  r__ArgentRoad:
   with dna do
    if (Cwytalot_gone) and (not Cwytalot_in_Herts) and (ped=2) and
     (dna.rooms[r__ArgentRoad]>3) then
    begin
     tr[2].init(4,false); { 4=Cwytalot again}
     apped(2,1);
     tr[2].walkto(2);
     tr[2].vanishifstill:=true;
     Cwytalot_in_Herts:=true;
     {whereis[#157]:=r__Nowhere;} { can we fit this in? }
     set_up_timer(20,PROC_Cwytalot_in_Herts,reason_Cwytalot_in_Herts);
    end;

  r__Bridge:
  begin
   if dna.drawbridge_open=4 {open} then
   begin
    show_one(3); { Position of drawbridge }
    magics[green].op:=nix; { You may enter the drawbridge. }
   end;
   if dna.Geida_follows then put_Geida_at(ped+3); { load Geida }
  end;

  r__Robins:
  begin
   if ped>0 then
   begin
    if not dna.been_tied_up then
    begin { A welcome party... or maybe not... }
     tr[2].init(6,false);
     apped(2,2);
     tr[2].walkto(3);
     set_up_timer(36,PROCget_tied_up,reason_getting_tied_up);
    end;
   end;

   if dna.been_tied_up then
   begin
    whereis[pRobinHood]:=0; whereis[pFriarTuck]:=0;
   end;

   if dna.tied_up then show_one(2);

   if not dna.Mushroom_Growing then show_one(3);
  end;

  r__OutsideCardiffCastle:
   begin
    if ped>0 then
     case dna.Cardiff_things of
      0 : begin { You've answered NONE of his questions. }
           tr[2].init(9,false);
           apped(2,2);
           tr[2].walkto(3);
           set_up_timer(47,PROCcardiffsurvey,reason_CardiffSurvey);
          end;
      5 : magics[2].op:=nix; { You've answered ALL his questions. => nothing happens. }
     else begin { You've answered SOME of his questions. }
           tr[2].init(9,false);
           apped(2,3);
           tr[2].face:=right;
           set_up_timer(3,PROCcardiff_return,reason_CardiffSurvey);
          end;
     end;
    if dna.Cardiff_things<5 then
     interrogation:=dna.Cardiff_things else interrogation:=0;
   end;

  r__Map:
   begin { You're entering the map. }
    dawn; setactivepage(cp);
    if ped>0 then zoomout(peds[ped].x,peds[ped].y);
    setactivepage(1-cp);

    with dna do
     if (obj[wine]) and (winestate<>3) then
     begin
      dixi('q',9); { Don't want to waste the wine! }
      obj[wine]:=false;
      objectlist;
     end;

    dixi('q',69);
   end;

  r__Catacombs:
   begin
    if ped in [0,3,5,6] then
    with dna do
     begin
      case ped of
       3 : begin cat_x:=8; cat_y:=4; end; { Enter from oubliette }
       5 : begin cat_x:=8; cat_y:=7; end; { Enter from du Lustie's }
       6 : begin cat_x:=4; cat_y:=1; end; { Enter from Geida's }
      end;
      dna.Enter_Catacombs_From_Lusties_Room:=True;
      catamove(ped);
      dna.Enter_Catacombs_From_Lusties_Room:=False;
     end;
   end;

  r__ArgentPub: begin
                 if dna.wonNim then show_one(1); { No lute by the settle. }
                 dna.Malagauche:=0; { Ready to boot Malagauche }
                 if dna.GivenBadgeToIby then
                  begin show_one(8); show_one(9); end;
                end;

  r__LustiesRoom: begin
                   dna.DogfoodPos:=1; { Actually, du Lustie pos. }
                   if tr[1].whichsprite=0 then { Avvy in his normal clothes }
                    set_up_timer(3,PROCcallsguards,reason_du_Lustie_talks)
                   else
                    if not dna.Entered_Lusties_Room_As_Monk {already} then
                     { Presumably, Avvy dressed as a monk. }
                    set_up_timer(3,PROCgreetsmonk,reason_du_Lustie_talks);

                   if dna.Geida_follows then
                   begin
                    put_Geida_at(5);
                    if dna.Lustie_is_asleep then show_one(5);
                   end;
                  end;

  r__MusicRoom: begin
                 if dna.Jacques_awake>0 then
                 begin
                  dna.Jacques_awake:=5;
                  show_one(2);
                  show_one(4);
                  magics[brown].op:=nix;
                  whereis[pJacques]:=0;
                 end;
                 if ped<>0 then
                 begin
                  show_one(6);
                  first_show(5); then_show(7);
                  start_to_close;
                 end;
                end;

  r__OutsideNottsPub: if ped=2 then
                      begin
                       show_one(3); first_show(2);
                       then_show(1); then_show(4);
                       start_to_close;
                      end;

  r__OutsideArgentPub: if ped=2 then begin
                        show_one(6);
                        first_show(5); then_show(7);
                        start_to_close;
                       end;

  r__WiseWomans: begin
                  tr[2].init(11,false);
                  if (dna.rooms[r__WiseWomans]=1) and (ped>0) then
                  begin
                   apped(2,2); { Start on the right-hand side of the screen. }
                   tr[2].walkto(4); { Walks up to greet you. }
                  end else
                  begin
                   apped(2,4); { Starts where she was before. }
                   tr[2].face:=3;
                  end;

                  tr[2].call_Eachstep:=true;
                  tr[2].Eachstep:=PROCface_Avvy; { She always faces Avvy. }
                 end;

  r__InsideCardiffCastle:
   if ped>0 then
   begin
    tr[2].init(10,false); { Define the dart. }
    first_show(1);
    if dna.arrow_in_the_door then then_show(3) else then_show(2);
    if dna.taken_pen then show_one(4);
    start_to_close;
   end else
   begin
    show_one(1);
    if dna.arrow_in_the_door then show_one(3) else show_one(2);
   end;

  r__AvvysGarden: if (ped=1) then begin
                   show_one(2);
                   first_show(1); then_show(3);
                   start_to_close;
                  end;

  r__EntranceHall,r__InsideAbbey: if (ped=2) then begin
                    show_one(2);
                    first_show(1); then_show(3);
                    start_to_close;
                   end;

  r__AylesOffice: if dna.Ayles_is_awake then show_one(2); { Ayles awake. }

  r__Geidas: put_Geida_at(2); { load Geida }

  r__EastHall,r__WestHall: if dna.Geida_follows then put_Geida_at(ped+2);

  r__Lusties: if dna.Geida_follows then put_Geida_at(ped+6);

  r__NottsPub: begin
                if dna.sitting_in_pub then show_one(3);
                dna.DogfoodPos:=1; { Actually, du Lustie pos. }
               end;

  r__OutsideDucks: if ped=2 then
                   begin { Shut the door }
                    show_one(3);
                    first_show(2); then_show(1);
                    then_show(4); start_to_close;
                   end;
  r__Ducks: dna.DogfoodPos:=1; { Actually, Duck pos. }

 end;

 seescroll:=false; { Now it can work again! }

end;

procedure thinkabout(z:char; th:boolean); { Hey!!! Get it and put it!!! }
const
 x=205; y=170; picsize=966;
 thinkspace : bytefield =
  (x1: 25; y1:170; x2:32; y2: 200);
var
 f:file; p:pointer; fv:byte;
begin

 thinks:=z; dec(z);

 if th then
 begin { Things }
  assign(f,'thinks.avd'); wait; getmem(p,picsize);
  reset(f,1); seek(f,ord(z)*picsize+65); blockread(f,p^,picsize); off;
  close(f);
 end else
 begin { People }
  assign(f,'folk.avd');
  wait;
  getmem(p,picsize);
  reset(f,1);

  fv:=ord(z)-149;
  if fv>=25 then dec(fv,8);
  if fv=20 then dec(fv); { Last time... }

  seek(f,fv*picsize+65);
  blockread(f,p^,picsize);
  off;
  close(f);
 end;

 setactivepage(3);
 putimage(x,y,p^,0);
 setactivepage(1-cp);

 for fv:=0 to 1 do
  getset[fv].remember(ThinkSpace);

 freemem(p,picsize);
 on; thinkthing:=th;
end;

procedure load_digits; { Load the scoring digits & rwlites }
const
 digitsize = 134;
 rwlitesize = 126;
var f:file; fv:char; ff:byte;
begin
 assign(f,'digit.avd'); reset(f,1);
 for fv:='0' to '9' do
 begin
  getmem(digit[fv],digitsize); blockread(f,digit[fv]^,digitsize);
 end;
 for ff:=0 to 8 do
 begin
  getmem(rwlite[ff],rwlitesize); blockread(f,rwlite[ff]^,rwlitesize);
 end;
 close(f);
end;

procedure toolbar;
var f:file; s:word; fv:byte; p:pointer;
begin
 assign(f,'useful.avd'); reset(f,1);
 s:=filesize(f)-40; getmem(p,s);
 seek(f,40);
 blockread(f,p^,s);
 close(f);
(* off;*)

 setcolor(15); { (And sent for chrysanthemums...) Yellow and white. }
 setfillstyle(1,6);
 for fv:=0 to 1 do
 begin
  setactivepage(fv); putimage(5,169,p^,0);
  if demo then
  begin
   bar(264,177,307,190);
   outtextxy(268,188,'Demo!'); { well... actually only white now. }
  end;
 end;

(* on;*)
 freemem(p,s);
 oldrw:=177; showrw;
end;

procedure showscore;
const scorespace : bytefield = (x1:33; y1:177; x2:39; y2:200);
var q:string[3]; fv:byte;
begin
 if demo then exit;

 str(dna.score,q); while q[0]<#3 do q:='0'+q; off;
 setactivepage(3);
 for fv:=1 to 3 do
  if lastscore[fv]<>q[fv] then
   putimage(250+fv*15,177,digit[q[fv]]^,0);

 for fv:=0 to 1 do
  getset[fv].remember(scorespace);

 setactivepage(1-cp);
 on; lastscore:=q;
end;

procedure points(num:byte); { Add on no. of points }
var q,fv:byte;
begin
 for q:=1 to num do
 begin
  inc(dna.score);
  if soundfx then for fv:=1 to 97 do sound(177+dna.score*3); nosound;
 end;
 log_score(num,dna.score); showscore;
end;

procedure topcheck;
begin
 with ddm_m do { Menuset }
     getmenu(mpx); { Do this one }
end;

procedure mouseway;
var col:byte;
begin
 off; col:=getpixel(mx,my); on;
 with tr[1] do
  with dna do
   case col of
    green:        begin dna.rw:=up;    rwsp(1,up);    showrw; end;
    brown:        begin dna.rw:=down;  rwsp(1,down);  showrw; end;
    cyan:         begin dna.rw:=left;  rwsp(1,left);  showrw; end;
    lightmagenta: begin dna.rw:=right; rwsp(1,right); showrw; end;
    red,white,lightcyan,yellow: begin stopwalking; showrw; end;
   end;
end;

procedure inkey;
var r:char;
begin

 if demo then exit; { Demo handles this itself. }

 if mousetext='' then
 begin { read keyboard }
  readkeye;
  if (inchar=' ') and (shiftstate and 8>0) then
  begin
   inchar:=#0; extd:='#'; { alt-spacebar = alt-H }
  end;
 end else
 begin
  if mousetext[1]='`' then mousetext[1]:=#13; { Backquote = return in a macro }
  inchar:=mousetext[1]; mousetext:=copy(mousetext,2,255);
 end;
end;

procedure posxy;
var xs,ys:string[3];
begin
 setfillstyle(1,0); setcolor(10);
 repeat
  check;
  if mpress=1 then
  begin
   str(mx,xs); str(my,ys);
   off; bar(400,160,500,168);
   outtextxy(400,168,xs); outtextxy(440,168,': '+ys); on;
  end;
 until my=0;
 bar(400,161,640,168);
end;

procedure fxtoggle;
var page:byte;
const soundLED: bytefield =
 (x1: 52; y1:175; x2:55; y2: 177);
begin
 soundfx:=not soundfx;
 if soundfx then
 begin
  if not fxhidden then
  begin { ...but *not* when the screen's dark. }
   sound(1770); delay(77); nosound;
  end;
  setfillstyle(1,cyan);
 end else
  setfillstyle(1,black);
 setactivepage(3); bar(419,175,438,177);
 setactivepage(1-cp);
 for page:=0 to 1 do getset[page].remember(soundLED);
end;

procedure objectlist;
var fv:char;
begin
 dna.carrying:=0;
 if thinkthing and not dna.obj[thinks] then
  thinkabout(money,a_thing); { you always have money }
 for fv:=#1 to numobjs do
  if dna.obj[fv] then
  begin
   inc(dna.carrying); objlist[dna.carrying]:=fv;
  end;
end;

procedure verte;
var what:byte;
begin
 if not dna.user_moves_Avvy then exit;
 with tr[1] do { that's the only one we're interested in here }
 begin

  if mx<x then what:=1 else
   if mx>(x+a.xl) then what:=2 else
    what:=0; { On top }

  if my<y then inc(what,3) else
   if my>(y+a.yl) then inc(what,6);

  case what of
   0: stopwalking; { Clicked on Avvy- no movement }
   1: rwsp(1,left);
   2: rwsp(1,right);
   3: rwsp(1,up);
   4: rwsp(1,ul);
   5: rwsp(1,ur);
   6: rwsp(1,down);
   7: rwsp(1,dl);
   8: rwsp(1,dr);
  end; { no other values are possible... }

  showrw;

 end;
end;

procedure checkclick;
var b:bytefield;
begin
 check; ontoolbar:=slow_computer and ((my>=169) or (my<=10));

 if mrelease>0 then after_the_scroll:=false;
 case my of
  0..10: newpointer(1); { up arrow }
  159..169: newpointer(8); { I-beam }
  170..200: newpointer(2); { screwdriver }
  else
  begin
   if not ddmnow then  { Dropdown can handle its own pointers. }
   begin
    if ((keystatus and 1)=1) and (my>=11) and (my<=158) then
    begin
     newpointer(7); { Mark's crosshairs }
     verte;
     { Normally, if you click on the picture, you're guiding Avvy around. }
    end else
     newpointer(4); { fletch }
   end;
  end;
 end;

 if mpress>0 then
 begin
  case mpy of
     0..10: if dropsOK then topcheck;
   11..158: if not dropsOK then
             mousetext:=#13+mousetext; { But otherwise, it's
                                       equivalent to pressing Enter. }
  159..169: begin { Click on command line }
             cursor_off; curpos:=(mx-16) div 8;
             if curpos>length(current)+1 then curpos:=length(current)+1;
             if curpos<1 then curpos:=1;
             cursor_on;
            end;
  170..200: case mpx of { bottom check }
              0..207: mouseway;
              208..260: begin { Examine the thing }
                         repeat check until mrelease>0;
                         if thinkthing then
                         begin
                          thing:=thinks; inc(thing,49);
                          person:=pardon;
                         end else
                         begin
                          person:=thinks;
                          thing:=pardon;
                         end;
                         callverb(vb_exam);
                        end;
              261..319: begin
                         repeat checkclick until mrelease>0;
                         callverb(vb_score);
                        end;
              320..357: begin tr[1].xs:=walk; newspeed; end;
              358..395: begin tr[1].xs:=run;  newspeed; end;
              396..483: fxtoggle; { "sound" }
(*              484..534: begin { clock }
                         off; if getpixel(mx,my)=14 then mousetext:='#'+mousetext; on;
                        end;*)
              535..640: mousetext:=#13+mousetext;
             end;
  end;
 end;

(* if mrelease>0 then
 begin
  if (cw<>177) and (mry>10) then
   begin to_do:=(((mrx-20) div 100)*20)+(mry div 10); closewin; end;
 end;*)
end;

procedure mouse_init;
begin
 r.ax:=0;
 intr($33,r); { Returns- no. keys in bx and whether present in ax. }
 wait;
end;

procedure mousepage(page:word);
var onstate,wason:boolean;
begin
 if visible<>M_Virtual then
 begin
  onstate:=OnCanDoPageSwap;
  OnCanDoPageSwap:=false;
  wason:=visible=M_Yes;
  if wason then off;
  with r do begin ax:=29; bx:=page; end; intr($33,r);
  if wason then on;
  OnCanDoPageSwap:=onstate;
 end;
end;

procedure errorled;
var fv:byte;
begin
 state(0);
 for fv:=0 to 1 do
 begin
  setactivepage(fv);
  off; setfillstyle(1,red); bar(419,184,438,186); on;
 end;
 for fv:=177 downto 1 do
 begin
  sound(177+(fv*177177) div 999);
  delay(1); nosound;
 end;
 for fv:=0 to 1 do
 begin
  setactivepage(fv);
  off; setfillstyle(1,black); bar(419,184,438,186); on;
 end;
 state(defaultled); setactivepage(1-cp);
end;

function fades(x:shortint):shortint;
var r,g,b:byte;
begin
 r:=x div 16; x:=x mod 16;
 g:=x div 4;  b:=x mod 4;
 if r>0 then dec(r); if g>0 then dec(g); if b>0 then dec(b);
 fades:=(16*r+4*g+b);
{ fades:=x-1;}
end;

procedure dusk;
  procedure fadeout(n:byte);
  var fv:byte;
  begin
   getpalette(fxpal[n]);
   for fv:=1 to fxpal[n].size-1 do
    fxpal[n].colors[fv]:=fades(fxpal[n].colors[fv]);
   setallpalette(fxpal[n]);
   (*delay(50);*) slowdown;
  end;
var fv:byte;
begin
 setbkcolor(0);
 if fxhidden then exit; fxhidden:=true;
 getpalette(fxpal[0]); for fv:=1 to 3 do fadeout(fv);
end;

procedure dawn;
  procedure fadein(n:byte);
  begin
   setallpalette(fxpal[n]);
   (*delay(50);*) slowdown;
  end;
var fv:byte;
begin
 if (HoldTheDawn) or (not fxhidden) then exit; fxhidden:=false;
 for fv:=3 downto 0 do fadein(fv);
 with dna do
  if (room=r__Yours) and (Avvy_in_bed) and (teetotal) then background(14);
end;

procedure showrw;
var page:byte;
begin
 with dna do
 begin
  if oldrw=rw then exit;
  oldrw:=rw; off;
  for page:=0 to 1 do
  begin
   setactivepage(page); putimage(0,161,rwlite[rw]^,0);
  end; on;
  setactivepage(1-cp);
 end;
end;

procedure mblit(x1,y1,x2,y2:byte; f,t:byte); assembler;
{ The Minstrel Blitter }
 asm
{  ofsfr:=f*$4000+x1+y1*80;
   ofsto:=t*$4000+x1+y1*80;}

  mov bx,80; { We're multiplying by 80. }
  mov al,y1;
  mul bl;    { AX now contains y1*80. }
  xor cx,cx; { Zero CX. }
  mov cl,x1; { CX now equals x1 }
  add ax,cx; { AX now contains x1+y1*80. }
  mov si,ax;
  mov di,ax;

  mov ax,$4000;
  mov bl,f;
  mul bx; { Note that this is a *word*! }
  add si,ax;

  mov ax,$4000;
  mov bl,t;
  mul bx; { Note that this is a *word*! }
  add di,ax;

  push ds; { *** <<<< *** WE MUST PRESERVE THIS! }
  cld;  { Clear Direction flag - we're going forwards! }

  mov ax,$A000; { The screen memory. }
  mov ds,ax;
  mov es,ax; { The same. }

  { AH stores the number of bytes to copy. }
  { len:=(x2-x1)+1; }

  mov ah,x2;
  sub ah,x1;
  inc ah;

  { Firstly, let's decide how many times we're going round. }

  mov cl,y2; { How many numbers between y1 and y2? }
  sub cl,y1;
  inc cl; { Inclusive reckoning (for example, from 3 to 5 is 5-3+1=3 turns. }

  { We'll use SI and DI to be Ofsfr and Ofsto. }

  @Y_axis_loop:
   push cx;


   { OK... We've changed this loop from a for-next loop. "Bit" is
     represented by CX. }

{     port[$3c4]:=2; port[$3ce]:=4; }
   mov dx,$3c4;
   mov al,2;
   out dx,al;
   mov dx,$3ce;
   mov al,4;
   out dx,al;

   mov cx,4; { We have to copy planes 3, 2, 1 and Zero. We'll add 1 to the
    number, because at zero it stops. }

   mov bx,3; { This has a similar function to that of CX. }

   @start_of_loop:

    push cx;

{     port[$3C5]:=1 shl bit; }
    mov dx,$3C5;
    mov al,1;
    mov cl,bl; { BL = bit. }
    shl al,cl;
    out dx,al;
{     port[$3CF]:=bit; }
    mov dx,$3CF;
    mov al,bl; { BL = bit. }
    out dx,al;

{   move(mem[$A000:ofsfr],mem[$A000:ofsto],len); }

    xor ch,ch; { Clear CH. }
    mov cl,ah;

    repz movsb; { That's all we need to say! }

    mov cl,ah;
    sub si,cx; { This is MUCH, MUCH faster than pushing and popping them! }
    sub di,cx;

    pop cx; { Get the loop count back again. }
    dec bx; { One less... }
   loop @start_of_loop; { Until cx=0. }

   add si,80; { Do the next line... }
   add di,80;

   pop cx;
  loop @Y_axis_loop;

  pop ds; { Get it back again (or we'll be in trouble with TP!) }
end;

procedure blitfix;
var fv:byte;
begin
 fv:=getpixel(0,0); { perform read & so cancel Xor effect! }
end;

procedure clock;
const xm=510; ym=183;
var ah,am:arccoordstype; nh:word;
  procedure calchand(ang,length:word; var a:arccoordstype; c:byte);
  begin
   if ang>900 then begin a.xend:=177; exit; end;
   setcolor(c); arc(xm,ym,449-ang,450-ang,length); getarccoords(a);
  end;
  procedure hand(a:arccoordstype; c:byte);
  begin
   if a.xend=177 then exit;
   setcolor(c);
   with a do line(xm,ym,xend,yend); { "With a do-line???!", Liz said. }
  end;
  procedure chime;
  var gd,gm,fv:word;
  begin
   if (oh=17717) or (not soundfx) then exit; { too high- must be first time around }
   fv:=h mod 12; if fv=0 then fv:=12; wait;
   for gd:=1 to fv do
   begin
    for gm:=1 to 3 do
    begin
     sound((gd mod 3)*64+140-gm*30); delay(50-gm*12);
    end;
    nosound; if gd<>fv then delay(100);
   end;
  end;

  procedure refresh_hands;
  const clockspace : bytefield = (x1:61; y1:166; x2:66; y2:200);
  var page:byte;
  begin
   for page:=0 to 1 do
    getset[page].remember(clockspace);
  end;

  procedure plothands;
  begin
(*   off;*)
   setactivepage(3);
   calchand(onh,14,ah,yellow); calchand(om*6,17,am,yellow);
   hand(ah,brown); hand(am,brown);
   calchand(nh,14,ah,brown);   calchand(m*6,17,am,brown);
   hand(ah,yellow); hand(am,yellow);
   setactivepage(1-cp);

   refresh_hands;

(*   on;*)
  end;
begin { ...Clock. }
 gettime(h,m,s,s1);
 nh:=(h mod 12)*30+m div 2;
 if (oh<>h) then begin plothands; chime; end;
 if (om<>m) then plothands;
 if (h=0) and (oh<>0) and (oh<>17717) then
  display('Good morning!'^m^m'Yes, it''s just past midnight. Are you having'+
          ' an all-night Avvy session? Glad you like the game that much!');
 oh:=h; onh:=nh; om:=m;
end;

procedure flip_page;
begin
 if not ddm_o.menunow then
 begin
  cp:=1-cp;
  setvisualpage(cp);
  setactivepage(1-cp);
  (*mousepage(cp);*)
 end;

end;

procedure delavvy;
var page:byte;
begin
 off;
 with tr[1] do
  for page:=0 to 1 do
   mblit(x div 8,y,(x+a.xl) div 8+1,y+a.yl,3,page);
 blitfix;
 on;
end;

procedure gameover;
var fv:byte; sx,sy:integer;
begin
 dna.User_Moves_Avvy:=false;

 sx:=tr[1].x;
 sy:=tr[1].y;
 with tr[1] do
 begin
  Done;
  Init(12,true);        { 12 = Avalot falls }
  tr[1].step:=0;
  appear(sx,sy,0);
 end;
 set_up_timer(3,PROCAvalot_falls,reason_falling_over);
(* display(^m^m^m^m^m^m^i^i^i^i^i^i^s'Z'^v);*)
 alive:=false;
end;

{ OK. There are two kinds of redraw: Major and Minor. Minor is what happens
  when you load a game, etc. Major redraws EVERYTHING. }

procedure minor_redraw;
var fv:byte;
begin
 dusk;
 enterroom(dna.room,0); { Ped unknown or non-existant. }

 for fv:=0 to 1 do
 begin
  cp:=1-cp;
  getback;
 end;

 with dna do
 begin
  lastscore:='TJA'; { impossible digits }
  showscore;
 end;

 dawn;
end;

procedure major_redraw;
var fv:byte;
begin
 dusk;
 setactivepage(0); cleardevice;

 toolbar;
 copy03;

 enterroom(dna.room,0); { 0 = ped unknown or non-existant. }
 for fv:=0 to 1 do begin cp:=1-cp; getback end;

 om:=177;
 clock;

 thinkabout(thinks,thinkthing); standard_bar;
 soundfx:=not soundfx; fxtoggle;
 for fv:=0 to 1 do begin cp:=1-cp; getback end;
 plottext;
 ledstatus:=177; state(2);

 with dna do
 begin
  lastscore:='TJA'; { impossible digits }
  showscore;
 end;

 dawn;
end;

function bearing(whichped:byte):word;
  { Returns the bearing from ped Whichped to Avvy, in degrees. }
const rad2deg = 180/pi;
begin
 with peds[whichped] do
  if tr[1].x=x then
   bearing:=0  { This would cause a division by zero if we let it through. }
  else
  (*
   bearing:=trunc(((arctan((tr[1].y-y)/(tr[1].x-x)))*rad2deg)+90) mod 360*)
  begin
   if tr[1].x<x then
    bearing:=trunc(arctan((tr[1].y-y)/(tr[1].x-x))*rad2deg)+90
   else
    bearing:=trunc(arctan((tr[1].y-y)/(tr[1].x-x))*rad2deg)+270;
  end;
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

procedure sprite_run;
 { A sprite run is performed before displaying a scroll, if not all the
   sprites are still. It performs two fast cycles, only using a few of
   the links usually used, and without any extra animation. This should
   make the sprites the same on both pages. }
var fv:byte;
begin

 doing_sprite_run:=true;

 for fv:=0 to 1 do
 begin
  get_back_Loretta;
  trippancy_link;

  flip_page;
 end;

 doing_sprite_run:=false;

end;

procedure fix_flashers;
begin ledstatus:=177; oldrw:=177; state(2); showrw; end;

begin
 fxhidden:=false; oh:=17717; om:=17717;
 if atbios then atkey:='f1' else atkey:='alt-';
end.
