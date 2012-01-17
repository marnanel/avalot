{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 GYRO             It all revolves around this bit! }

unit Gyro;

interface

uses Graph,Dos,Crt;

const
 numobjs = #18; { always preface with a # }
 maxobjs = 12;  { carry limit }
 howlong : byte = 1{8}; { 18 ticks. }

 OnCanDoPageSwap : boolean = TRUE; { Variable constant for overriding the
  ability of On to switch pages. You may know better than On which page
  to switch to. }

 num = 32;  { Code for Num Lock }

 mouse_size = 134;

type
 proc = procedure;

 postype = record
            x,y,datapos:word; length:byte;
           end;

 mp = record { mouse-pointer }
       mask: array[0..1,0..15] of Word;
       Horzhotspot,verthotspot:integer;
      end;

 dnatype = record { here goes... } { Ux, uy, & ww now all belong to Trip5 }
            rw:byte; { Realway- just for convenience! }
            carrying:byte; { how many objects you're carrying... }
            obj:array[#1..numobjs] of boolean; { ...and which ones they are. }
            score:integer; { your score, of course }
            pence:longint; { your current amount of dosh }
            room:byte; { your current room }
            wearing:char; { what you're wearing }
            swore:byte; { number of times you've sworn }
            saves:byte; { number of times this game has been saved }
            rooms:array[1..100] of byte; { Add one to each every time
                                            you enter a room }
            alcohol:byte; { Your blood alcohol level. }
            playedNim:byte; { How many times you've played Nim. }
            wonNim:boolean; { Have you *won* Nim? (That's harder.) }
            winestate:byte; { 0=good (Notts), 1=passable(Argent) ... 3=vinegar.}
            cwytalot_gone:boolean; { Has Cwytalot rushed off to Jerusalem yet?}

            pass_num:byte; { Number of the password for this game. }
            Ayles_is_awake:boolean; { pretty obvious! }
            drawbridge_open:byte; { Between 0 (shut) and 4 (open). }
            Avaricius_talk:byte; { How much Avaricius has said to you. }
            bought_onion:boolean; { Have you bought an onion yet? }
            rotten_onion:boolean; { And has it rotted? }
            onion_in_vinegar:boolean; { Is the onion in the vinegar? }

            given2Spludwick:byte; { 0 = nothing given, 1 = onion... }
            Brummie_stairs:byte; { Progression through the stairs trick. }
            Cardiff_things:byte; { Things you get asked in Cardiff. }

            Cwytalot_in_Herts:boolean; { Have you passed Cwytalot in Herts?}

            Avvy_is_awake:boolean; { Well? Is Avvy awake? (Screen 1 only.) }
            Avvy_in_bed:boolean; { True if Avvy's in bed, but awake. }

            user_moves_Avvy:boolean; { If this is false, the user has no
                                        control over Avvy's movements. }

            DogfoodPos:byte; { Which way Dogfood's looking in the pub. }

            GivenBadgeToIby:boolean; { Have you given the badge to Iby yet? }

            Friar_will_tie_you_up:boolean; { If you're going to get tied up. }
            tied_up:boolean; { You ARE tied up! }

            box_contents:char; { 0 = money (sixpence), 254 = empty, any
             other number implies the contents of the box. }

            talked_to_Crapulus:boolean; { Pretty self-explanatory. }

            Jacques_awake:byte; { 0=asleep, 1=awake, 2=gets up, 3=gone. }

            ringing_bells:boolean; { Is Jacques ringing the bells? }

            standing_on_dais:boolean; { In room 71, inside Cardiff Castle. }
            taken_pen:boolean; { Have you taken the pen (in Cardiff?) }
            arrow_triggered:boolean; { And has the arrow been triggered? }
            arrow_in_the_door: boolean; { Did the arrow hit the wall? }

            like2drink,
            favourite_song,
            worst_place_on_earth,
            spare_evening:string[77]; { Personalisation str's }

            total_time:longint; { Your total time playing this game, in ticks.}

            jumpstatus:byte; { Fixes how high you're jumping. }

            Mushroom_Growing:boolean; { Is the mushroom growing in 42? }

            Spludwicks_here:boolean; { Is Spludwick at home? }

            last_room:byte;
            last_room_not_map:byte;

            Crapulus_will_tell:boolean; { Will Crapulus tell you about
                        Spludwick being away? }

            Enter_Catacombs_From_Lusties_Room:boolean;
            teetotal:boolean; { Are we touching any more drinks? }
            malagauche:byte; { Position of Malagauche. See Celer for more info. }
            drinking:char; { What's he getting you? }

            Entered_Lusties_Room_As_Monk:boolean;

            cat_x, cat_y : byte; { XY coords in the catacombs. }

            Avvys_in_the_cupboard:boolean; { On screen 22. }

            Geida_follows:boolean; { Is Geida following you? }

            Geida_spin,Geida_time:byte; { For the making "Geida dizzy" joke. }

            nextbell:byte; { For the ringing. }

            Geida_given_potion:boolean; { Does Geida have the potion? }
            Lustie_is_asleep:boolean; { Is BDL asleep? }

            flip_to_where, flip_to_ped:byte; { For the sequencer. }

            been_tied_up:boolean; { In r__Robins. }

            sitting_in_pub:boolean; { Are you sitting down in the pub? }
            Spurge_talk:byte; { Count for talking to Spurge. }

            met_avaroid:boolean;

            taken_mushroom,
            given_pen_to_ayles,
            asked_Dogfood_about_Nim:boolean;
           end;

 pedtype = record
            x,y:integer; dir:byte;
           end;

 magictype = record
              op:byte; { one of the operations }
              data:word; { data for them }
             end;

 fieldtype = object
              x1,y1,x2,y2:integer;
             end;

 bytefield = record
              x1,y1,x2,y2:byte;
             end;

 linetype = object(fieldtype)
             col:byte;
            end;

 adxtype = record
            name:string[12]; { name of character }
            num:byte; { number of pictures }
            xl,yl:byte; { x & y lengths of pictures }
            seq:byte; { how many in one stride }
            size:word; { the size of one picture }
            fgc,bgc:byte; { foreground & background bubble colours }
           end;

 raw = array[#0..#255,0..15] of byte; { raw_font_type }

 controllers = (cJoy,cKey);

 previoustype = array[1..20] of string[77];

 corridor_type = record { Decarations for the corridors. }
                  doors:word; { Door styles are calc'ed from this word.
                   Assign a different number to each one! }
                 end;

 demo_type = record
              delay:word;
              key,extd:char;
             end;

 quasiped_type = record
                  whichped,fgc,room,bgc:byte; who:char;
                 end;
 { A quasiped defines how people who aren't sprites talk. For example,
   quasiped "A" is Dogfood. The rooms aren't stored because I'm leaving
   that to context. }

 tunetype = array[1..31] of byte;

 vmctype = record { Virtual Mouse Cursor }
            andpic,xorpic:pointer;
            backpic:array [0..1] of pointer;
            wherewas:array [0..1] of PointType;
            picnumber:byte;
            ofsx,ofsy:shortint;
           end;

 sundry = record { Things which must be saved over a backtobootstrap,
                   outside DNA. }
           qEnid_Filename:pathstr;
           qsoundfx:boolean;
           qthinks:char;
           qthinkthing:boolean;
          end;

 JoySetup = record
             xmid,ymid,xmin,ymin,xmax,ymax:word;
             centre:byte; { Size of centre in tenths }
            end;

type
  ednahead = record { Edna header }
            { This header starts at byte offset 177 in the .ASG file. }
            ID:array[1..9] of char; { signature }
            revision:word; { EDNA revision, here 2 (1=dna256) }
            game:string[50]; { Long name, eg Lord Avalot D'Argent }
            shortname:string[15]; { Short name, eg Avalot }
            number:word; { Game's code number, here 2 }
            ver:word; { Version number as integer (eg 1.00 = 100) }
            verstr:string[5]; { Vernum as string (eg 1.00 = "1.00" }
            filename:string[12]; { Filename, eg AVALOT.EXE }
            osbyte:byte; { Saving OS (here 1=DOS. See below for others.}
            os:string[5]; { Saving OS in text format. }

            { Info on this particular game }

            fn:string[8]; { Filename (not extension ('cos that's .ASG)) }
            d,m:byte; { D, M, Y are the Day, Month & Year this game was... }
            y:word;  { ...saved on. }
            desc:string[40]; { Description of game (same as in Avaricius!) }
            len:word; { Length of DNA (it's not going to be above 65535!) }

            { Quick reference & miscellaneous }

            saves:word; { no. of times this game has been saved }
            cash:integer; { contents of your wallet in numerical form }
            money:string[20]; { ditto in string form (eg 5/-, or 1 denarius)}
            points:word; { your score }

            { DNA values follow, then footer (which is ignored) }
           end;

  { Possible values of edhead.os:
     1 = DOS        4 = Mac
     2 = Windows    5 = Amiga
     3 = OS/2       6 = ST
     7 = Archimedes }

const
 vernum = '1.30';
 copyright = '1995';
 thisvercode = 130;
  { as "vernum", but numerically & without the ".". }
 thisgamecode = 2; { Avalot's code number }

{ Objects you can hold: }
  Wine=#1; Money=#2; Bodkin=#3; Potion=#4; chAstity=#5; bolt=#6;
  Crossbow=#7; Lute=#8; badge=#9; Mushroom=#10; Key=#11; bEll=#12;
  prescription=#13; pen=#14; ink=#15; clothes=#16; habit=#17; onion=#18;

{ People who hang around this game. }

 { Boys: }
 pAvalot=#150; pSpludwick=#151; pCrapulus=#152; pDrDuck=#153;
 pMalagauche=#154; pFriarTuck=#155; pRobinHood=#156; pCwytalot=#157;
 pduLustie=#158; pDuke=#159; pDogfood=#160; pTrader=#161;
 pIbythneth=#162; pAyles=#163; pPort=#164; pSpurge=#165; pJacques=#166;

 { Girls: }
 pArkata=#175; pGeida=#176; pWiseWoman=#178;

 xw = 30;
 yw = 36; { x width & y whatsit }

 margin = 5;

 mps : array[1..9] of mp =
(( Mask: { 1 - up-arrow }
     ((65151,64575,64575,63519,63519,61455,61455,57351,57351,49155,49155,64575,64575,64575,64575,64575),
      (0,384,384,960,960,2016,2016,4080,4080,8184,384,384,384,384,384,0));
   Horzhotspot: 8;
   Verthotspot: 0),

 ( Mask: { 2 - screwdriver }
     ((8191,4095,2047,34815,50175,61951,63743,64543,65039,65031,65027,65281,65408,65472,65505,65523),
      (0,24576,28672,12288,2048,1024,512,256,224,176,216,96,38,10,12,0));
   Horzhotspot: 0;
   Verthotspot: 0),

 ( Mask: { 3 - right-arrow }
     ((65535,65535,64639,64543,7,1,0,1,7,64543,64639,65535,65535,65535,65535,65535),
      (0,0,0,384,480,32760,32766,32760,480,384,0,0,0,0,0,0));
   Horzhotspot: 15;
   Verthotspot: 6),

 ( Mask: { 4 - fletch }
     ((255,511,1023,2047,1023,4607,14591,31871,65031,65283,65281,65280,65280,65409,65473,65511),
      (0,10240,20480,24576,26624,17408,512,256,128,88,32,86,72,20,16,0));
   Horzhotspot: 0;
   Verthotspot: 0),

 ( Mask: { 5 - hourglass }
     ((0,0,0,34785,50115,61455,61455,63519,63519,61839,61455,49155,32769,0,0,0),
      (0,32766,16386,12300,2064,1440,1440,576,576,1056,1440,3024,14316,16386,32766,0));
   Horzhotspot: 8;
   Verthotspot: 7),

 ( Mask: { 6 - TTHand }
     ((62463,57855,57855,57855,57471,49167,32769,0,0,0,0,32768,49152,57344,61441,61443),
      (3072,4608,4608,4608,4992,12912,21070,36937,36873,36865,32769,16385,8193,4097,2050,4092));
   Horzhotspot: 4;
   Verthotspot: 0),

 ( Mask: { 7- Mark's crosshairs }
     ((65535,65151,65151,65151,65151,0,65151,65151,65151,65151,65535,65535,65535,65535,65535,65535),
      (0,384,384,384,384,65535,384,384,384,384,0,0,0,0,0,0));
   Horzhotspot: 8;
   Verthotspot: 5),

 ( Mask: { 8- I-beam. }
     ((65535,65535,63631,63503,63503,65087,65087,65087,65087,65087,63503,63503,63631,65535,65535,65535),
      (0,0,0,864,128,128,128,128,128,128,128,864,0,0,0,0));
   Horzhotspot: 8;
   Verthotspot: 7),

 ( Mask: { 9- Question mark. }
     ((511,1023,2047,31,15,8199,32647,65415,63503,61471,61503,61695,63999,63999,61695,61695),
      (65024,33792,34816,34784,40976,57224,32840,72,1936,2080,2496,2304,1536,1536,2304,3840));
   Horzhotspot: 0;
   Verthotspot: 0));

 lads: array[#150..#166] of string[19] =
  ('Avalot','Spludwick','Crapulus','Dr. Duck','Malagauche','Friar Tuck',
   'Robin Hood','Cwytalot','du Lustie','the Duke of Cardiff','Dogfood',
   'A trader','Ibythneth','Ayles','Port','Spurge','Jacques');

 lasses: array[#175..#178] of string[14] =
  ('Arkata','Geida','±','the Wise Woman');

  ladchar : array[#150..#165] of char = 'ASCDMTRwLfgeIyPu';

 lasschar : array[#175..#178] of char = 'kG±o';

 numtr = 2; { current max no. of sprites }

 a_thing=true; a_person=false; { for Thinkabout }

 { Magic/portal commands are }

 {N} nix = 0; { ignore it if this line is touched }
 {B} bounces = 1; { bounce off this line. Not valid for portals. }
 {E} exclaim = 2; { put up a chain of scrolls }
 {T} transport = 3; { enter new room }
 {U} unfinished = 4; { unfinished connection }
 {S} special = 5; { special function. }
 {O} Mopendoor = 6; { opening door. }

 { These following constants should be included in CFG when it's written. }

  slow_computer = false; { stops walking when mouse touches toolbar }

 { --- }

 border = 1; { size of border on shadowboxes }

 pagetop = 81920;

    up = 0;
 right = 1;
  down = 2;
  left = 3;
 ur=4; dr=5; dl=6; ul=7;
  stopped=8;

 walk = 3;
 run = 5;

 {$I ROOMNUMS.INC - Room number constants (r__xxx) }

 whereis : array[#150..#178] of byte =
     { The Lads }
  (r__Yours, { Avvy }
   r__Spludwicks, { Spludwick }
   r__OutsideYours, { Crapulus }
   r__Ducks, { Duck - r__DucksRoom's not defined yet. }
   r__ArgentPub, { Malagauche }
   r__Robins, { Friar Tuck. }
   177, { Robin Hood - can't meet him at the start. }
   r__BrummieRoad, { Cwytalot }
   r__LustiesRoom, { Baron du Lustie. }
   r__OutsideCardiffCastle, { The Duke of Cardiff. }
   r__ArgentPub, { Dogfood }
   r__OutsideDucks, { Trader }
   r__ArgentPub, { Ibythneth }
   r__AylesOffice, { Ayles }
   r__NottsPub, { Port }
   r__NottsPub, { Spurge }
   r__MusicRoom, { Jacques }
    0,0,0,0,0,0,0,0,
     { The Lasses }
   r__Yours, { Arkata }
   r__Geidas, { Geida }
   177, { nobody allocated here! }
   r__WiseWomans); { The Wise Woman. }

{ Art gallery at 2,1; notice about this at 2,2. }

 catamap: array[1..8,1..8] of longint =
             { Geida's room }
  {  1     2     3   | 4     5     6     7     8}
 (($0204,$0200,$D0F0,$F0FF,$00FF,$D20F,$D200,$0200),
  ($50F1,$20FF,$02FF,$00FF,$E0FF,$20FF,$200F,$7210),
  ($E3F0,$E10F,$72F0,$00FF,$E0FF,$00FF,$00FF,$800F),
  ($2201,$2030,$800F,$0220,$020F,$0030,$00FF,$023F), { >> Oubliette }
  ($5024,$00F3,$00FF,$200F,$22F0,$020F,$0200,$7260),
  ($00F0,$02FF,$E2FF,$00FF,$200F,$50F0,$72FF,$201F),
  ($00F6,$220F,$22F0,$030F,$00F0,$020F,$8200,$02F0), { <<< In here }
  ($0034,$200F,$51F0,$201F,$00F1,$50FF,$902F,$2062));
                { vv Stairs trap. }

{ Explanation: $NSEW.
   Nibble N: North.
    0     = no connection,
    2     = (left,) middle(, right) door with left-hand handle,
    5     = (left,) middle(, right) door with right-hand handle,
    7     = arch,
    8     = arch and 1 north of it,
    9     = arch and 2 north of it,
    D     = no connection + WINDOW,
    E     = no connection + TORCH,
    F     = recessed door (to Geida's room.)

   Nibble S: South.
    0     = no connection,
    1,2,3 = left, middle, right door.

   Nibble E: East.
    0     = no connection (wall),
    1     = no connection (wall + window),
    2     = wall with door,
    3     = wall with door and window,
    6     = wall with candles,
    7     = wall with door and candles,
    F     = straight-through corridor.

   Nibble W: West.
    0     = no connection (wall),
    1     = no connection (wall + shield),
    2     = wall with door,
    3     = wall with door and shield,
    4     = no connection (window),
    5     = wall with door and window,
    6     = wall with candles,
    7     = wall with door and candles,
    F     = straight-through corridor. }

 interrogation : byte = 0;
  { If this is greater than zero, the next line you type is stored in
    the DNA in a position dictated by the value. If a scroll comes up,
    or you leave the room, it's automatically set to zero. }

 demo:boolean = false; { If this is true, we're in a demo of the game. }

 spludwick_order : array[0..2] of char = (onion,ink,mushroom);

 quasipeds : array[10..25] of quasiped_type =
((whichped:2;fgc:lightgray; room:19;bgc:brown;who:pDogfood),  { A: Dogfood (screen 19). }
 (whichped:3;fgc:green;     room:19;bgc:white;who:pIbythneth),  { B: Ibythneth (screen 19). }
 (whichped:3;fgc:white;     room: 1;bgc:magenta;who:pArkata),{ C: Arkata (screen 1). }
 (whichped:3;fgc:black;     room:23;bgc:red;who:#177),    { D: Hawk (screen 23). }
 (whichped:3;fgc:lightgreen;room:50;bgc:brown;who:pTrader),  { E: Trader (screen 50). }
 (whichped:6;fgc:yellow;    room:42;bgc:red;who:pAvalot),    { F: Avvy, tied up (scr.42) }
 (whichped:2;fgc:blue;      room:16;bgc:white;who:pAyles),  { G: Ayles (screen 16). }
 (whichped:2;fgc:brown;     room: 7;bgc:white;who:pJacques),  { H: Jacques (screen 7). }
 (whichped:2;fgc:lightgreen;room:47;bgc:green;who:pSpurge),  { I: Spurge (screen 47). }
 (whichped:3;fgc:yellow;    room:47;bgc:red;who:pAvalot),    { J: Avalot (screen 47). }
 (whichped:2;fgc:lightgray; room:23;bgc:black;who:pduLustie),  { K: du Lustie (screen 23). }
 (whichped:2;fgc:yellow;    room:27;bgc:red;who:pAvalot),    { L: Avalot (screen 27). }
 (whichped:3;fgc:white;     room:27;bgc:red;who:#177),    { M: Avaroid (screen 27). }
 (whichped:4;fgc:lightgray; room:19;bgc:darkgray;who:pMalagauche), {N: Malagauche (screen 19). }
 (whichped:5;fgc:lightmagenta;room:47;bgc:red;who:pPort),     { O: Port (screen 47). }
 (whichped:2;fgc:lightgreen; room:51;bgc:darkgray;who:pDrDuck));{P: Duck (screen 51). }

  lower = 0;
   same = 1;
 higher = 2;

 keys: array[1..12] of char = 'QWERTYUIOP[]';
 notes: array[1..12] of word =
  (196,220,247,262,294,330,350,392,440,494,523,587);

 tune: tunetype =
  (higher,higher,lower,same,higher,higher,lower,higher,higher,higher,
   lower,higher,higher,
   same,higher,lower,lower,lower,lower,higher,higher,lower,lower,lower,
   lower,same,lower,higher,same,lower,higher);

 { special run-time errors }

 runerr_GetSet_Overflow = 50;

var
 current:string[77]; curpos:byte; cursoron:boolean;
(* previous:^previoustype;*)
 last:string[77];
 dna:dnatype;
 lines:array[1..50] of linetype; { For Also. }
 c:integer;
 r:registers;
 visible: ( M_No , M_Yes , M_Virtual );
 dropsOK,screturn,soundfx,cheat:boolean;
 mx,my:word; { mouse x & y now }
 mpx,mpy:word; { mouse x & y when pressed }
 mrx,mry:word; { mouse x & y when released }
 mpress,mrelease:byte; { times left mouse button has been pressed/released }
 keystatus:byte; { Mouse key status }
 un:array[1..10] of string[20];
 unn:byte; mousetext:string;
(* which:array[0..5] of byte;*)
 p:pointer; weirdword:boolean;
 to_do:byte; lmo,mousemade:boolean;
 scroll:array[1..15] of string[50];
 scrolln,score,whichwas:byte; thinks:char; thinkthing:boolean;

(* pp:array[1..1000] of postype;
 bb:array[1..9000] of byte;*)
 pptr,bptr:word;
 ppos:array[0..0,0..1] of integer;
 pozzes:array[1..24] of word;
 anim:byte; copier:pointer;
 talkx,talky:integer; talkb,talkf:byte;
 scrollbells:byte; { no. of times to ring the bell }
 ontoolbar,seescroll:boolean;

 objlist:array[1..10] of char;
 digit:array['0'..'9'] of pointer;
 rwlite:array[0..8] of pointer; oldrw:byte;
 lastscore:string[3]; cmp:byte; { current mouse-pointer }
 verbstr:string[10]; { what you can do with your object. :-) }

 also:array[0..30,0..1] of ^string;
 peds:array[1..15] of pedtype;
 magics:array[1..15] of magictype;
 portals:array[9..15] of magictype;
 fields:array[1..30] of fieldtype; numfields:byte;
 flags:string[26]; listen:string;

 oh,onh,om,h,m,s,s1:word;

 atkey:string[4]; { For XTs, set to "alt-". For ATs, set to "f1". }

 cp,ledstatus,defaultled:byte;
 little:raw; quote:boolean; { 66 or 99 next? }
 alive:boolean;
 buffer:array[1..2000] of char; bufsize:word;

 oldjw:byte; { Old joystick-way }
 ctrl:controllers;

 underscroll:integer; { Y-coord of just under the scroll text. }

 { TSkellern is only temporary, and I'll replace it
   with a local version when it's all fixed up. }

(* tskellern:longint absolute $0:244; { Over int $61 }*)

 ddmnow:boolean; { Kludge so we don't have to keep referring to Dropdown }
 roomname:string[40]; { Name of this room }

 logfile:text; logging,log_epson:boolean;

 cl_override:boolean;

 locks: Byte ABSOLUTE $40:$17;

 subject:string[20]; { What you're talking to them about. }
 subjnumber:byte; { The same thing. }

 keyboardclick:boolean; { Is a keyboard click noise wanted? }

 him,her,it:char;
 roomtime:longint; { Set to 0 when you enter a room, added to in every loop.}

 after_the_scroll:boolean;

  { For the demo: }
 demo_rec:demo_type;
 demofile:file of demo_type;

 last_person:char; { Last person to have been selected using the People
                     menu. }

 doing_sprite_run:boolean; { Only set to True if we're doing a sprite_run
  at this moment. This stops the trippancy system from moving any of the
  sprites. }

 vmc:vmctype;
 filetoload:string;

 HoldTheDawn:boolean; { If this is true, calling Dawn will do nothing.
  It's used, for example, at the start, to stop Load from dawning. }

 storage_SEG,storage_OFS:word; { Seg and ofs of the Storage area. }
 Skellern:word; { Offset of the timer variable - 1 more than storage_OFS }
 reloaded:boolean; { Is this NOT the primary loading? }

 Super_Was_Virtual,Super_Was_Off : boolean; { Used by Super_Off and Super_On }

 enid_Filename:pathstr;

 js:joysetup;
 cxmin,cxmax,cymin,cymax:word; use_joy_A:boolean;

 procedure newpointer(m:byte);

 procedure wait; { makes hourglass }

 procedure on;

 procedure off;

 procedure on_Virtual;

 procedure off_Virtual;

 procedure xycheck;

 procedure hopto(x,y:integer); { Moves mouse pointer to x,y }

 procedure check;

 procedure note(Hertz:word);

 procedure blip;

 function strf(x:longint):string;

 procedure shbox(x1,y1,x2,y2:integer; t:string);

 procedure newgame;

 procedure click;

 procedure slowdown;

 function flagset(x:char):boolean;

 procedure force_numlock;

 function pennycheck(howmuchby:word):boolean;

 function getname(whose:char):string;

 function getnamechar(whose:char):char;

 function get_thing(which:char):string;

 function get_thingchar(which:char):char;

 function get_better(which:char):string;

 function f5_does:string;

 procedure plot_vmc(xx,yy:integer; page:byte);

 procedure wipe_vmc(page:byte);

 procedure setup_vmc;

 procedure clear_vmc;

 procedure load_a_mouse(which:byte);

 procedure background(x:byte);

 procedure hang_around_for_a_while;

 procedure Super_Off;

 procedure Super_On;

 function mouse_near_text:boolean;

implementation

uses Pingo,Scrolls,Lucerna,Visa,Acci,Trip5,Dropdown,Basher;

const
 things: array[#1..numobjs] of string[15] =
  ('Wine','Money-bag','Bodkin','Potion','Chastity belt',
  'Crossbow bolt','Crossbow','Lute','Pilgrim''s badge','Mushroom','Key',
  'Bell','Scroll','Pen','Ink','Clothes','Habit','Onion');

 thingchar : array[#1..numobjs] of char = 'WMBParCLguKeSnIohn'; { V=Vinegar }

 better: array[#1..numobjs] of string[17]=
  ('some wine','your money-bag','your bodkin','a potion','a chastity belt',
   'a crossbow bolt','a crossbow','a lute','a pilgrim''s badge','a mushroom',
   'a key','a bell','a scroll','a pen','some ink','your clothes','a habit',
   'an onion');

 betterchar : array[#1..numobjs] of char = 'WMBParCLguKeSnIohn';

procedure newpointer(m:byte);
begin
 if m=cmp then exit; cmp:=m;
 with r do
 begin
  ax:=9; bx:=word(mps[m].horzhotspot); cx:=word(mps[m].verthotspot);
  es:=seg(mps[m].mask); dx:=ofs(mps[m].mask);
 end;
 intr($33,r);
 load_a_mouse(m);
end;

procedure wait; { makes hourglass }
begin
 newpointer(5);
end;

procedure on;
begin
 if visible in [m_Yes,m_Virtual] then exit;

 r.ax:=1; intr($33,r); visible:=m_Yes;
 if OnCanDoPageSwap then
 begin
  r.ax:=29; r.bx:=cp; intr($33,r); { show mouse on current page }
 end;
end;

procedure on_Virtual;
begin
 case visible of
  m_Virtual: exit;
  m_Yes: off;
 end;

 visible:=m_Virtual;
end;

procedure off;
begin
 case visible of
  m_No,m_Virtual : exit;
  m_Yes : begin r.ax:=2; intr($33,r); end;
 end;
 visible:=m_No;
end;

procedure off_Virtual;
var fv:byte;
begin
 if visible<>m_Virtual then exit;

 for fv:=0 to 1 do
 begin
  setactivepage(fv);
  Wipe_VMC(1-fv);
 end;
 setactivepage(1-cp); visible:=m_No;
end;

procedure xycheck; { only updates mx & my, not all other mouse vars }
begin
 r.ax:=3; intr($33,r); { getbuttonstatus }
 with r do
 begin
  keystatus:=bx;
  mx:=cx; my:=dx;
 end;
end;

procedure hopto(x,y:integer); { Moves mouse pointer to x,y }
begin
 with r do
 begin
  ax:=4;
  cx:=x;
  dx:=y;
 end;
 intr($33,r);
end;

procedure check;
begin
 with r do begin ax:=6; bx:=0; end; intr($33,r); { getbuttonreleaseinfo }
 with r do
 begin
  mrelease:=bx;
  mrx:=cx; mry:=dx;
 end;
 with r do begin ax:=5; bx:=0; end; intr($33,r); { getbuttonpressinfo }
 with r do
 begin
  mpress:=bx;
  mpx:=cx; mpy:=dx;
 end;
 xycheck; { just to complete the job. }
end;

procedure note(Hertz:word);
begin
 if soundfx then sound(Hertz);
end;

procedure blip;
var fv:byte;
begin
 for fv:=1 to 7 do begin sound(177+(fv*200) mod 177); delay(1); end;
 nosound;
end;

function strf(x:longint):string;
var q:string;
begin
 str(x,q); strf:=q;
end;

procedure shadow(x1,y1,x2,y2:integer; hc,sc:byte);
var fv:byte;
begin
 for fv:=0 to border do
 begin
  setfillstyle(1,hc);
  bar(x1+fv,y1+fv,x1+fv,y2-fv);
  bar(x1+fv,y1+fv,x2-fv,y1+fv);

  setfillstyle(1,sc);
  bar(x2-fv,y1+fv,x2-fv,y2-fv);
  bar(x1+fv,y2-fv,x2-fv,y2-fv);
 end;
end;

procedure shbox(x1,y1,x2,y2:integer; t:string);
const fc = 7;
begin
 off;
 shadow(x1,y1,x2,y2,15,8); setfillstyle(1,fc);
 bar(x1+border+1,y1+border+1,x2-border-1,y2-border-1);
 setcolor(1); x1:=(x2-x1) div 2+x1; y1:=(y2-y1) div 2+y1;
 outtextxy(x1,y1,t);
 if length(t)>1 then
 begin
  fillchar(t[2],length(t)-1,#32); t[1]:='_';
  outtextxy(x1-1,y1+1,t);
 end;
 on;
end;

procedure newgame; { This sets up the DNA for a completely new game. }
var gd,gm:byte;
begin
 for gm:=1 to numtr do
  with tr[gm] do
  if quick then done; { Deallocate sprite. Sorry, beta testers! }

 tr[1].init(0,true);
 alive:=true;

 score:=0; (*for gd:=0 to 5 do which[gd]:=1;*)
 fillchar(dna,sizeof(dna),#0); natural;
 normal_edit; mousepage(0);
 dna.spare_evening:='answer a questionnaire';
 dna.like2drink:='beer';

 with dna do
 begin
  pence:=30; { 2/6 } rw:=stopped; wearing:=clothes;
  obj[money]:=true; obj[bodkin]:=true; obj[bell]:=true; obj[clothes]:=true;
 end;

 thinks:=#2; objectlist;
 ontoolbar:=false; seescroll:=false;

 ppos[0,1]:=-177; {tr[1].appear(300,117,right);} gd:=0;
 for gd:=0 to 30 do for gm:=0 to 1 do also[gd,gm]:=nil;
(* fillchar(previous^,sizeof(previous^),#0); { blank out array } *)
 him:=#254; her:=#254; it:=#254; last_person:=#254; { = Pardon? }
 dna.pass_num:=random(30)+1; after_the_scroll:=false;
 dna.user_moves_Avvy:=false; doing_sprite_run:=false;
 dna.Avvy_in_bed:=true; enid_filename:='';

 for gd:=0 to 1 do begin cp:=1-cp; getback; end;

 enterroom(1,1); new_game_for_trippancy;
 showscore;

 standard_bar; clock;
 sprite_run;
end;

procedure click; { "Audio keyboard feedback" }
begin
 sound(7177); delay(1); nosound;
end;

procedure slowdown;
begin
(* repeat until TSkellern>=howlong; TSkellern:=0;*)
 repeat until memW[Storage_SEG:Skellern]>=howlong;
 memW[Storage_SEG:Skellern]:=0;
end;

function flagset(x:char):boolean;
begin
 flagset:=pos(x,flags)>0;
end;

procedure force_numlock;
begin
 if (locks and num)>0 then dec(locks,num);
end;

function pennycheck(howmuchby:word):boolean;
begin
 dec(dna.pence,howmuchby);
 if dna.pence<0 then
 begin
  dixi('Q',2); { "you are now denariusless!" }
  pennycheck:=false;
  gameover;
 end else
  pennycheck:=true;
end;

function getname(whose:char):string;
begin
 if whose<#175 then getname:=lads[whose] else getname:=lasses[whose];
end;

function getnamechar(whose:char):char;
begin
 if whose<#175 then getnamechar:=ladchar[whose]
  else getnamechar:=lasschar[whose];
end;

function get_thing(which:char):string;
begin
 with dna do
  case which of
   wine: case winestate of
          1,4: get_thing:=things[which];
          3: get_thing:='Vinegar';
         end;
   onion: if rotten_onion then
           get_thing:='rotten onion'
          else get_thing:=things[which];
   else get_thing:=things[which];
  end;
end;

function get_thingchar(which:char):char;
begin
 with dna do
  case which of
   wine: if winestate=3 then get_thingchar:='V' { Vinegar }
          else get_thingchar:=thingchar[which];
   else get_thingchar:=thingchar[which];
  end;
end;

function get_better(which:char):string;
begin
 if which>#150 then dec(which,149);
 with dna do
  case which of
   wine: case winestate of
          0,1,4: get_better:=better[which];
          3: get_better:='some vinegar';
         end;
   onion: if rotten_onion then
           get_better:='a rotten onion'
           else if onion_in_vinegar then
            get_better:='a pickled onion (in the vinegar)'
             else get_better:=better[which];
   else
     if (which<numobjs) and (which>#0) then
        get_better:=better[which] else
        get_better:='';
  end;
end;

function f5_does:string;
 { This procedure determines what f5 does. }
begin
 with dna do
  case room of
   r__Yours:
    begin
     if not Avvy_is_awake then
     begin { He's asleep, =>= wake up. }
      f5_does:=vb_wake+'WWake up';
      exit;
     end;

     if Avvy_in_bed then
     begin { In bed. => = get up. }
      f5_does:=vb_stand+'GGet up';
      exit;
     end;

    end;

   r__InsideCardiffCastle:
    begin
     if standing_on_dais then
      f5_does:=vb_climb+'CClimb down'
     else
      f5_does:=vb_climb+'CClimb up';
     exit;
    end;

   r__NottsPub:
    begin
     if sitting_in_pub then
      f5_does:=vb_stand+'SStand up'
     else
      f5_does:=vb_sit+'SSit down';
     exit;
    end;

   r__MusicRoom:
    if infield(7) then
    begin
     f5_does:=vb_play+'PPlay the harp';
     exit;
    end;
  end;

 f5_does:=pardon; { If all else fails... }
end;

procedure plot_vmc(xx,yy:integer; page:byte);
begin
 if visible<>m_Virtual then exit;
 with vmc do
 begin
  xx:=xx+ofsx; if xx<0 then xx:=0;
  yy:=yy+ofsy; if yy<0 then yy:=0;

  setactivepage(1-cp);
  getimage(xx,yy,xx+15,yy+15,backpic[page]^);
  putimage(xx,yy,andpic^,andput);
  putimage(xx,yy,xorpic^,xorput);

(*  setcolor( 0); outtextxy(xx+8,yy+16,'Û'); outtextxy(xx,yy+16,'Û');
  setcolor(11+page);
  outtextxy(xx+8,yy+16,chr(48+roomtime mod 10));
  outtextxy(xx  ,yy+16,chr(48+(roomtime div 10) mod 10));*)

  with wherewas[page] do
  begin
   x:=xx;
   y:=yy;
  end;
 end;
end;

procedure wipe_vmc(page:byte);
begin
 if visible<>m_Virtual then exit;
 with vmc do
  with wherewas[page] do
   if x<>maxint then
    putimage(x,y,backpic[page]^,0);
end;

procedure setup_vmc;
var fv:byte;
begin
 with vmc do
 begin
  getmem(andpic,mouse_size);
  getmem(xorpic,mouse_size);

  for fv:=0 to 1 do
  begin
   getmem(backpic[fv],mouse_size);
   wherewas[fv].x:=maxint;
  end;
 end;
end;

procedure clear_vmc;
var fv:byte;
begin
 for fv:=0 to 1 do vmc.wherewas[fv].x:=maxint;
end;

procedure setminmaxhorzcurspos(min,max:word); { phew }
begin
 with r do
 begin
  ax:=7;
  cx:=min;
  dx:=max;
 end;
 intr($33,r);
end;

procedure setminmaxvertcurspos(min,max:word);
begin
 with r do
 begin
  ax:=8; { A guess. In the book, 7 }
  cx:=min;
  dx:=max;
 end;
 intr($33,r);
end;

procedure load_a_mouse(which:byte);
var f:file;
begin
 assign(f,'mice.avd');
 reset(f,1);
 seek(f,mouse_size*2*(which-1)+134);

 with vmc do
 begin
  blockread(f,andpic^,mouse_size);
  blockread(f,xorpic^,mouse_size);
  close(f);
  with mps[which] do
  begin
   ofsx:=-Horzhotspot;
   ofsy:=-Verthotspot;

   setminmaxHorzcurspos(Horzhotspot+3,624+Horzhotspot);
   setminmaxVertcurspos(Verthotspot,199);
  end;
 end;
end;

procedure background(x:byte); begin setbkcolor(x); end;

procedure hang_around_for_a_while;
var fv:byte;
begin
 for fv:=1 to 28 do slowdown;
end;

function mouse_near_text:boolean;
begin
 mouse_near_text:=(my>144) and (my<188);
end;

{ Super_Off and Super_On are two very useful procedures. Super_Off switches
  the mouse cursor off, WHATEVER it's like. Super_On restores it again
  afterwards. }

procedure Super_Off;
begin
 Super_Was_Off:=visible=M_No;
 if Super_Was_Off then exit;

 Super_Was_Virtual:=visible=M_Virtual;

 if visible=M_Virtual then off_Virtual else Off;
end;

procedure Super_On;
begin
 if (visible<>M_No) or (Super_Was_Off) then exit;

 if Super_Was_Virtual then on_Virtual else On;
end;

end.
