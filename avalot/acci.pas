{  $D-}
{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 ACCIDENCE II     The parser. }
unit acci;

{$V-}

interface

const
 { verb codes }
  vb_exam = #1; vb_open = #2; vb_pause = #3; vb_get = #4; vb_drop = #5;
  vb_inv = #6; vb_talk = #7; vb_give = #8; vb_drink = #9; vb_load = #10;
  vb_save = #11; vb_pay = #12; vb_look = #13; vb_break = #14; vb_quit = #15;
  vb_sit = #16; vb_stand = #17; vb_go = #18; vb_info = #19; vb_undress = #20;
  vb_wear = #21; vb_play = #22; vb_ring = #23; vb_help = #24;
  vb_larrypass = #25; vb_phaon = #26; vb_boss = #27; vb_pee = #28;
  vb_cheat = #29; vb_magic = #30; vb_restart = #31; vb_eat = #32;
  vb_listen = #33; vb_buy = #34; vb_attack = #35; vb_password = #36;
  vb_dir = #37; vb_die = #38; vb_score = #39; vb_put = #40;
  vb_kiss = #41; vb_climb = #42; vb_jump = #43; vb_highscores = #44;
  vb_wake = #45; vb_hello = #46; vb_thanks = #47;

  vb_smartalec = #249; vb_expletive = #253;

 pardon = #254; { =didn't understand / wasn't given. }

type
 vocab = record
          n:byte; w:string[11];
         end;

 ranktype = record
             score:word; title:string[12];
            end;


const
 nowords = 277; { how many words does the parser know? }
 nowt = #250;
 moved = #0; { This word was moved. (Usually because it was the subject of
  conversation.) }

 first_password = 89; { Words[first_password] should equal "TIROS". }

 words : array[1..nowords] of vocab =

{ Verbs, 1-49 }
 ((n:  1; w:'EXAMINE'),   (n:  1; w:'READ'),      (n:  1; w:'XAM'), { short }
  (n:  2; w:'OPEN'),      (n:  2; w:'LEAVE'),     (n:  2; w:'UNLOCK'),
  (n:  3; w:'PAUSE'),     (n: 47; w:'TA'), { Early to avoid Take and Talk. }
  (n:  4; w:'TAKE'),      (n:  4; w:'GET'),       (n:  4; w:'PICK'),
  (n:  5; w:'DROP'),      (n:  6; w:'INVENTORY'), (n:  7; w:'TALK'),
  (n:  7; w:'SAY'),       (n:  7; w:'ASK'),
  (n:  8; w:'GIVE'),      (n:  9; w:'DRINK'),     (n:  9; w:'IMBIBE'),
  (n:  9; w:'DRAIN'),     (n: 10; w:'LOAD'),      (n: 10; w:'RESTORE'),
  (n: 11; w:'SAVE'),      (n: 12; w:'BRIBE'),     (n: 12; w:'PAY'),
  (n: 13; w:'LOOK'),      (n: 14; w:'BREAK'),     (n: 15; w:'QUIT'),
  (n: 15; w:'EXIT'),      (n: 16; w:'SIT'),       (n: 16; w:'SLEEP'),
  (n: 17; w:'STAND'),

  (n: 18; w:'GO'),        (n: 19; w:'INFO'),      (n: 20; w:'UNDRESS'),
  (n: 20; w:'DOFF'),
  (n: 21; w:'DRESS'),     (n: 21; w:'WEAR'),      (n: 21; w:'DON'),
  (n: 22; w:'PLAY'),
  (n: 22; w:'STRUM'),     (n: 23; w:'RING'),      (n: 24; w:'HELP'),
  (n: 25; w:'KENDAL'),    (n: 26; w:'CAPYBARA'),  (n: 27; w:'BOSS'),
  (n:255;w:'NINET'), { block for NINETY }
  (n: 28; w:'URINATE'),   (n: 28; w:'MINGITE'),   (n: 29; w:'NINETY'),
  (n: 30;w:'ABRACADABRA'),(n: 30; w:'PLUGH'),     (n: 30; w:'XYZZY'),
  (n: 30; w:'HOCUS'),     (n: 30; w:'POCUS'),     (n: 30; w:'IZZY'),
  (n: 30; w:'WIZZY'),     (n: 30; w:'PLOVER'),
  (n: 30;w:'MELENKURION'),(n: 30; w:'ZORTON'),    (n: 30; w:'BLERBI'),
  (n: 30; w:'THURB'),     (n: 30; w:'SNOEZE'),    (n: 30; w:'SAMOHT'),
  (n: 30; w:'NOSIDE'),    (n: 30; w:'PHUGGG'),    (n: 30; w:'KNERL'),
  (n: 30; w:'MAGIC'),     (n: 30; w:'KLAETU'),    (n: 30; w:'VODEL'),
  (n: 30; w:'BONESCROLLS'),(n: 30; w:'RADOF'),

  (n: 31; w:'RESTART'),
  (n: 32; w:'SWALLOW'),   (n: 32; w:'EAT'),       (n: 33; w:'LISTEN'),
  (n: 33; w:'HEAR'),      (n: 34; w:'BUY'),       (n: 34; w:'PURCHASE'),
  (n: 34; w:'ORDER'),     (n: 34; w:'DEMAND'),
  (n: 35; w:'ATTACK'),    (n: 35; w:'HIT'),       (n: 35; w:'KILL'),
  (n: 35; w:'PUNCH'),     (n: 35; w:'KICK'),      (n: 35; w:'SHOOT'),
  (n: 35; w:'FIRE'),

  { Passwords, 36: }

  (n: 36; w:'TIROS'),     (n: 36; w:'WORDY'),     (n: 36; w:'STACK'),
  (n: 36; w:'SHADOW'),    (n: 36; w:'OWL'),       (n: 36; w:'ACORN'),
  (n: 36; w:'DOMESDAY'),  (n: 36; w:'FLOPPY'),    (n: 36; w:'DIODE'),
  (n: 36; w:'FIELD'),     (n: 36; w:'COWSLIP'),   (n: 36; w:'OSBYTE'),
  (n: 36; w:'OSCLI'),     (n: 36; w:'TIMBER'),    (n: 36; w:'ADVAL'),
  (n: 36; w:'NEUTRON'),   (n: 36; w:'POSITRON'),  (n: 36; w:'ELECTRON'),
  (n: 36; w:'CIRCUIT'),   (n: 36; w:'AURUM'),     (n: 36; w:'PETRIFY'),
  (n: 36; w:'EBBY'),      (n: 36; w:'CATAPULT'),  (n: 36; w:'GAMERS'),
  (n: 36; w:'FUDGE'),     (n: 36; w:'CANDLE'),    (n: 36; w:'BEEB'),
  (n: 36; w:'MICRO'),     (n: 36; w:'SESAME'),    (n: 36; w:'LORDSHIP'),

  (n: 37; w:'DIR'),       (n: 37; w:'LS'),        (n: 38; w:'DIE'),
  (n: 39; w:'SCORE'),
  (n: 40; w:'PUT'),       (n: 40; w:'INSERT'),    (n: 41; w:'KISS'),
  (n: 41; w:'SNOG'),      (n: 41; w:'CUDDLE'),    (n: 42; w:'CLIMB'),
  (n: 42; w:'CLAMBER'),   (n: 43; w:'JUMP'),      (n: 44; w:'HIGHSCORES'),
  (n: 44; w:'HISCORES'),  (n: 45; w:'WAKEN'),     (n: 45; w:'AWAKEN'),
  (n: 46; w:'HELLO'),     (n: 46; w:'HI'),        (n: 46; w:'YO'),
  (n: 47; w:'THANKS'),  { = 47, "ta", which was defined earlier. }


{ Nouns - Objects: 50-100. }

  (n: 50; w:'WINE'),      (n: 50; w:'BOOZE'),    (n: 50;w:'NASTY'),
  (n: 50; w:'VINEGAR'),   (n: 51; w:'MONEYBAG'),
  (n: 51; w:'BAG'),       (n: 51; w:'CASH'),     (n: 51;w:'DOSH'),
  (n: 51; w:'WALLET'),
  (n: 52; w:'BODKIN'),    (n: 52; w:'DAGGER'),   (n: 53;w:'POTION'),
  (n: 54; w:'CHASTITY'),  (n: 54; w:'BELT'),     (n: 55;w:'BOLT'),
  (n: 55; w:'ARROW'),     (n: 55; w:'DART'),
  (n: 56; w:'CROSSBOW'),  (n: 56; w:'BOW'),      (n: 57;w:'LUTE'),
  (n: 58; w:'PILGRIM'),   (n: 58; w:'BADGE'),    (n: 59;w:'MUSHROOMS'),
  (n: 59; w:'TOADSTOOLS'),(n: 60; w:'KEY'),      (n: 61;w:'BELL'),
  (n: 62; w:'PRESCRIPT'), (n: 62; w:'SCROLL'),   (n: 62;w:'MESSAGE'),
  (n: 63; w:'PEN'),       (n: 63; w:'QUILL'),    (n: 64;w:'INK'),
  (n: 64; w:'INKPOT'),    (n: 65; w:'CLOTHES'),  (n: 66;w:'HABIT'),
  (n: 66; w:'DISGUISE'),  (n: 67; w:'ONION'),

  (n: 99;w:'PASSWORD'),

{ Objects from Also are placed between 101 and 131. }

{ Nouns - People - Male, 150-174 }
  (n:150; w:'AVVY'),      (n:150;w:'AVALOT'),    (n:150;w:'YOURSELF'),
  (n:150; w:'ME'),        (n:150;w:'MYSELF'),    (n:151;w:'SPLUDWICK'),
  (n:151; w:'THOMAS'),    (n:151;w:'ALCHEMIST'), (n:151;w:'CHEMIST'),
  (n:152; w:'CRAPULUS'),  (n:152;w:'SERF'),      (n:152;w:'SLAVE'),
  (n:158; w:'DU'),  { <<< Put in early for Baron DU Lustie to save confusion with Duck & Duke.}
  (n:152; w:'CRAPPY'),    (n:153;w:'DUCK'),      (n:153;w:'DOCTOR'),
  (n:154; w:'MALAGAUCHE'),
  (n:155; w:'FRIAR'),     (n:155;w:'TUCK'),      (n:156;w:'ROBIN'),
  (n:156; w:'HOOD'),      (n:157;w:'CWYTALOT'),  (n:157;w:'GUARD'),
  (n:157; w:'BRIDGEKEEP'),(n:158;w:'BARON'),     (n:158;w:'LUSTIE'),
  (n:159; w:'DUKE'),      (n:159;w:'GRACE'),     (n:160;w:'DOGFOOD'),
  (n:160; w:'MINSTREL'),  (n:161;w:'TRADER'),    (n:161;w:'SHOPKEEPER'),
  (n:161;w:'STALLHOLDER'),
  (n:162; w:'PILGRIM'),   (n:162;w:'IBYTHNETH'), (n:163;w:'ABBOT'),
  (n:163; w:'AYLES'),     (n:164;w:'PORT'),      (n:165;w:'SPURGE'),
  (n:166; w:'JACQUES'),   (n:166;w:'SLEEPER'),   (n:166;w:'RINGER'),

{ Nouns- People - Female: 175-199 }
  (n:175; w:'WIFE'),      (n:175;w:'ARKATA'),    (n:176;w:'GEDALODAVA'),
  (n:176; w:'GEIDA'),     (n:176;w:'PRINCESS'),  (n:178;w:'WISE'),
  (n:178; w:'WITCH'),

{ Pronouns, 200-224 }
  (n:200; w:'HIM'),       (n:200;w:'MAN'),       (n:200;w:'GUY'),
  (n:200; w:'DUDE'),      (n:200;w:'CHAP'),      (n:200;w:'FELLOW'),
  (n:201; w:'HER'),       (n:201;w:'GIRL'),      (n:201;w:'WOMAN'),
  (n:202; w:'IT'),        (n:202;w:'THING'),

  (n:203;w:'MONK'),       (n:204;w:'BARMAN'),    (n:204;w:'BARTENDER'),

{ Prepositions, 225-249 }
  (n:225; w:'TO'),        (n:226;w:'AT'),        (n:227;w:'UP'),
  (n:228; w:'INTO'),      (n:228;w:'INSIDE'),    (n:229;w:'OFF'),
  (n:230; w:'UP'),        (n:231;w:'DOWN'),      (n:232;w:'ON'),


{ Please, 251 }
  (n:251; w:'PLEASE'),

{ About, 252 }
  (n:252; w:'ABOUT'), (n:252; w:'CONCERNING'),

{ Swear words, 253 }
        {              I M P O R T A N T    M E S S A G E

          DO *NOT* READ THE LINES BELOW IF YOU ARE OF A SENSITIVE
          DISPOSITION. THOMAS IS *NOT* RESPONSIBLE FOR THEM.
          GOODNESS KNOWS WHO WROTE THEM.
          READ THEM AT YOUR OWN RISK. BETTER STILL, DON'T READ THEM.
          WHY ARE YOU SNOOPING AROUND IN MY PROGRAM, ANYWAY? }

  (n:253; w:'SHIT'),      (n:28 ;w:'PISS'),    (n:28 ;w:'PEE'),
  (n:253; w:'FART'),      (n:253;w:'FUCK'),    (n:253;w:'BALLS'),
  (n:253; w:'BLAST'),     (n:253;w:'BUGGER'),  (n:253;w:'KNICKERS'),
  (n:253; w:'BLOODY'),    (n:253;w:'HELL'),    (n:253;w:'DAMN'),
  (n:253; w:'SMEG'),
    { and other even ruder words. You didn't read them, did you? Good. }

{ Answer-back smart-alec words, 249 }
  (n:249; w:'YES'),       (n:249;w:'NO'),        (n:249;w:'BECAUSE'),

{ Noise words, 255 }
  (n:255; w:'THE'),       (n:255;w:'A'),         (n:255;w:'NOW'),
  (n:255; w:'SOME'),      (n:255;w:'AND'),       (n:255;w:'THAT'),
  (n:255; w:'POCUS'),     (n:255;w:'HIS'),       
  (n:255; w:'THIS'),      (n:255;w:'SENTINEL')); { for "Ken SENT Me" }

 what = 'That''s not possible!';

 const ranks: array[1..9] of ranktype =
   ((score:   0; title: 'Beginner'),    (score:  10; title: 'Novice'),
    (score:  20; title: 'Improving'),   (score:  35; title: 'Not bad'),
    (score:  50; title: 'Passable'),    (score:  65; title: 'Good'),
    (score:  80; title: 'Experienced'), (score: 108; title: 'The BEST!'),
    (score:maxint; title:'copyright''93'));

var
 thats:string[11];
 unknown:string[20];
 realwords:array[1..11] of string[20];
 verb,person,thing,thing2:char;
 polite:boolean;

procedure clearwords;
procedure parse;
procedure lookaround;
procedure opendoor;
procedure do_that;
procedure verbopt(n:char; var answer:string; var anskey:char);
procedure have_a_drink;

implementation
uses Gyro,Lucerna,Scrolls,Pingo,Trip5,Visa,Enid,NimUnit,Timeout,Celer,
      Highs,Helper,Sequence;

var
 fv:byte;

function wordnum(x:string):string;
var whatsit:char; fv:word; gotcha:boolean;

  procedure checkword; { Checks word "fv". }
  begin
   with words[fv] do
   begin
    if (w=x) or ((copy(w,1,length(x))=x) and not gotcha)
     then whatsit:=chr(n);
    if w=x then gotcha:=true;
   end;
  end;

begin
 if x='' then begin wordnum:=''; exit; end;
 whatsit:=pardon; gotcha:=false;
 for fv:=nowords downto 1 do checkword;
 wordnum:=whatsit;
end;

procedure replace(old1,new1:string);
var q:byte;
begin
 q:=pos(old1,thats);
 while q<>0 do
 begin
  thats:=copy(thats,1,q-1)+new1+copy(thats,q+length(old1),255);
  q:=pos(old1,thats);
 end;
end;

(*procedure ninetydump;
var f:file; y:integer; bit:byte; a:byte absolute $A000:800;
begin
 off;
 assign(f,'avvydump.avd');
 rewrite(f,1);
 blockwrite(f,dna,177); { just anything }
 for bit:=0 to 3 do
 begin
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockwrite(f,a,12080);
 end;
 close(f); on;
 display('Dumped.');
end;*)

function rank:string;
var fv:byte;
begin
 for fv:=1 to 8 do
  if (dna.score>=ranks[fv].score)
   and (dna.score<ranks[fv+1].score) then
   begin
    rank:=ranks[fv].title;
    exit;
   end;
end;

function totaltime:string;
const ticks_in_1_sec = 65535/3600;
var
 h,m,s:word; a:string[70];
begin
  { There are 65535 clock ticks in a second,
    1092.25 in a minute, and
    65535 in an hour. }
 h:=trunc(dna.total_time/ticks_in_1_sec); { No. of seconds. }
 m:=h mod 3600; h:=h div 3600;
 s:=m mod 60;   m:=m div 60;

 a:='You''ve been playing for ';

 if h>0 then a:=a+strf(h)+' hours, ';
 if (m>0) or (h<>0) then a:=a+strf(m)+' minutes and ';
 a:=a+strf(s)+' seconds.';

 totaltime:=a;
end;

procedure cheatparse(codes:string);
var cmd:char; num:word; se,sx,sy:integer; e:integer;
  procedure number;
  begin
   val(codes,num,e);
  end;
begin
 if not cheat then
 begin { put them off the scent! }
  display('Have you gone dotty??!');
  exit;
 end;
 cmd:=upcase(codes[2]); delete(codes,1,2); { strip header }
 display(^f'Ninety: '^r^d);
 case cmd of
  'R': begin
        number; if e<>0 then exit;
        display('room swap to '+codes+'.');
        fliproom(num,1);
       end;
  'Z': begin zonk; display('Zonk OK!'); end;
  'W': begin wobble; display('Ow my head!'); end;
  'A': begin
        tr[1].done;
        tr[1].init(1,true);
        dna.user_moves_avvy:=true;
        alive:=true;
        display('Reincat.');
       end;
  'B': begin
        sx:=tr[1].x;
        sy:=tr[1].y;
        se:=tr[1].face;
        delavvy;
        number;
        with tr[1] do
        begin
         Done;
         Init(num,true);
         display('Become '+codes+':'+^m^m+a.name+^m+a.comment);
         appear(sx,sy,se);
        end;
       end;
(*  'D': ninetydump;*)
  'G': play_Nim;
  '±': display(^s'2'^u);
  else display('unknown code!');
 end;
end;

procedure punctustrip(var x:string); { Strips punctuation from x. }
const punct : string[32] = '~`!@#$%^&*()_+-={}[]:"|;''\,./<>?';
var fv,p:byte;
begin
 for fv:=1 to 32 do
  repeat
   p:=pos(punct[fv],x);
   if p=0 then break; { <<< The first time I've ever used it! }
   delete(x,p,1);
  until false;
end;

function do_pronouns:boolean;
var fv:byte; ambiguous:boolean;
  procedure displaywhat(ch:char; animate:boolean); { << it's an adjective! }
  var ff:byte; z:string;
  begin
   if ch=pardon then
   begin
    ambiguous:=true;
    if animate then display('Whom?') else display('What?');
   end else
   begin
    if animate then display('{ '+getname(ch)+' }')
     else
     begin
       z:=get_better(ch);
       if z<>'' then display('{ '+z+' }');
     end;
   end;
  end;
begin
 ambiguous:=false;
 for fv:=1 to length(thats) do
  case thats[fv] of
   #200: begin
          displaywhat(him,true);
          thats[fv]:=him;
         end;
   #201: begin
          displaywhat(her,true);
          thats[fv]:=her;
         end;
   #202: begin
          displaywhat(it,false);
          thats[fv]:=it;
         end;
  end;
 do_pronouns:=ambiguous;
end;

procedure store_interrogation(interrogation:byte);
var fv:byte;

  procedure lowercase;
  var fv:byte;
  begin
   for fv:=1 to length(current) do
    if current[fv] in ['A'..'Z'] then
     inc(current[fv],32);
  end;

  procedure propernouns;
  var fv:byte;
  begin
   lowercase;
   for fv:=2 to length(current)-1 do
    if current[fv]=' ' then
     current[fv+1]:=upcase(current[fv+1]);
   current[1]:=upcase(current[1]);
  end;

  procedure sayit; { This makes Avalot say the response. }
  var x:string;
  begin
   x:=current; x[1]:=upcase(x[1]);
   display(^s'1'+x+'.'+^b+^s+'2');
  end;

begin
 if current='' then exit;

 { Strip current: }
 while (current[1]=' ') and (current<>'') do delete(current,1,1);
 while (current[length(current)]=' ') and (current<>'') do dec(current[0]);

 lose_timer(reason_CardiffSurvey); { if you want to use any other timer,
  put this into the case statement. }
 with dna do
  case interrogation of
   1: begin
       lowercase; sayit;
       like2drink:=current;
       dna.cardiff_things:=2;
      end;
   2: begin
       propernouns; sayit;
       favourite_song:=current;
       dna.cardiff_things:=3;
      end;
   3: begin
       propernouns; sayit;
       worst_place_on_earth:=current;
       dna.cardiff_things:=4;
      end;
   4: begin
       lowercase; sayit;
       fillchar(spare_evening,sizeof(spare_evening),#177);
       spare_evening:=current;
       dixi('z',5); { His closing statement... }
       tr[2].walkto(4); { The end of the drawbridge }
       tr[2].VanishIfStill:=true; { Then go away! }
       magics[2].op:=nix;
       dna.cardiff_things:=5;
      end;

   99: store_high(current);
  end;
 if interrogation<4 then Cardiff_survey;
end;

procedure clearwords;
begin
 fillchar(realwords,sizeof(realwords),#0);
end;

procedure parse;
var n,fv,ff:byte; c,cc,thisword:string; answer:string[1]; notfound:boolean;
begin
 { first parsing - word identification }

 thats:=''; c:=current+#32; n:=1; polite:=false;
 verb:=pardon; thing:=pardon; thing2:=pardon; person:=pardon;
 clearwords;
 if current[1]='.' then
 begin { a cheat mode attempt }
  cheatparse(current); thats:=nowt; exit;
 end; { not our department! Otherwise... }

 { Are we being interrogated right now? }

 if interrogation>0 then
 begin
  store_interrogation(interrogation);
  weirdword:=true;
  exit;
 end;

 cc:=c; for fv:=1 to length(c) do c[fv]:=upcase(c[fv]);
 while c<>'' do
 begin
   while (c[1]=#32) and (c<>'') do
     begin delete(c,1,1); delete(cc,1,1); end;
  thisword:=copy(c,1,pos(#32,c)-1);
  realwords[n]:=copy(cc,1,pos(#32,cc)-1);
  punctustrip(c);

  notfound:=true;

  if thisword<>'' then
  begin
   for ff:=1 to 30 do
   begin { Check Also, FIRST! }
    if pos(','+thisword,also[ff,0]^)>0 then
    begin
     thats:=thats+chr(99+ff);
     notfound:=false;
    end;
   end;
  end;

  if notfound then
  begin
   answer:=wordnum(thisword);
   if answer=pardon then
   begin
    notfound:=true;
    thats:=thats+pardon;
   end else
    thats:=thats+wordnum(thisword);
   inc(n);
  end;
  delete(c,1,pos(#32,c)); delete(cc,1,pos(#32,cc));
 end;

 if pos(#254,thats)>0 then unknown:=realwords[pos(#254,thats)] else unknown:=''; replace(#255,''); { zap noise words }
 replace(#13+#226,#1); { "look at" = "examine" }
 replace(#13+#228,#1); { "look in" = "examine" }
 replace(#4+#227,#17); { "get up" = "stand" }
 replace(#4+#231,#17); { "get down" = "stand"... well, why not? }
 replace(#18+#228,#2); { "go in" = "open [door]" }
 replace(#28+#229,#253); { "P' off" is a swear word }
 replace(#4+#6,#6); { "Take inventory" (remember Colossal Adventure?) }
 replace(#40+#232,#21); { "put on" = "don" }
 replace(#4+#229,#20); { "take off" = "doff" }

 with dna do { Words that could mean more than one person }
 begin
  if room=r__NottsPub then replace(#204,#164) { Barman = Port }
   else replace(#204,#154);                   { Barman = Malagauche }
  case room of
   r__AylesOffice: replace(#203,#163);        { Monk = Ayles }
   r__MusicRoom: replace(#203,#166);          { Monk = Jacques }
   else replace(#203,#162);                   { Monk = Ibythneth }
  end;
 end;

 if do_pronouns then
 begin
  weirdword:=true;
  thats:=nowt;
  exit;
 end;

 { second parsing - accidence }

 subject:=''; subjnumber:=0; { Find subject of conversation. }
 for fv:=1 to 11 do
  if realwords[fv,1] in ['`',''''] then
  begin
   subjnumber:=ord(thats[fv]);
   thats[fv]:=moved;
   break; { Only the second time I've used that! }
  end;
 if subjnumber=0 then { Still not found. }
  for fv:=1 to 10 do
   if thats[fv]=#252 then { the word is "about", or something similar }
   begin
    subjnumber:=ord(thats[fv+1]);
    thats[fv+1]:=#0;
    break; { ...Third! }
   end;
 if subjnumber=0 then { STILL not found! Must be the word after "say". }
  for fv:=1 to 10 do
   if (thats[fv]=#7) and not (thats[fv+1] in [#0,#225..#229]) then
   begin { SAY not followed by a preposition }
    subjnumber:=ord(thats[fv+1]);
    thats[fv+1]:=#0;
    break; { ...Fourth! }
   end;

 for fv:=length(thats) downto 1 do { Reverse order- so first'll be used }
  case thats[fv] of
   #1..#49,#253,#249: verb:=thats[fv];
   #50..#149: begin thing2:=thing; thing:=thats[fv]; end;
   #150..#199: person:=thats[fv];
   #251: polite:=true;
  end;

 if (unknown<>'') and not
  (verb in [vb_exam,vb_talk,vb_save,vb_load,vb_dir]) then
 begin
  display('Sorry, but I have no idea what `'+unknown+
    '" means. Can you rephrase it?');
  weirdword:=true;
 end else weirdword:=false;
 if thats='' then thats:=nowt;

 if thing<>pardon then it:=thing;
 if person<>pardon then
 begin
  if person<#175 then him:=person else her:=person;
 end;
end;

procedure examobj; { Examine a standard object-thing }
begin
 if thing<>thinks then thinkabout(thing,a_thing);
 with dna do
  case thing of
   wine : case winestate of
         { 4 is perfect wine. 0 is not holding the wine. }
           1: dixi('t',1); { Normal examine wine scroll }
           2: dixi('d',6); { Bad wine }
           3: dixi('d',7); { Vinegar }
          end;
   onion: if rotten_onion then
           dixi('q',21) { Yucky onion. }
          else
           dixi('t',18); { Normal onion scroll }
  else
   dixi('t',ord(thing)); { <<< Ordinarily }
  end;
end;

function personshere:boolean; { Person equivalent of "holding" }
begin
 if (person=pardon) or (person=#0)
   or (whereis[person]=dna.room) then personshere:=true
 else begin
  if person<#175 then display('H'^d) else display('Sh'^d);
  display('e isn''t around at the moment.');
  personshere:=false;
 end;
end;

procedure exampers;
begin
 if personshere then
 begin
  if thing<>thinks then thinkabout(person,a_person);
  dec(person,149);
  with dna do
   case person of { Special cases }
    #11: if wonNim then
         begin
          dixi('Q',8); { "I'm Not Playing!" }
          exit;
         end;
    #9: if Lustie_is_asleep then
        begin dixi('Q',65); { He's asleep. (65! Wow!) } exit; end;
   end;
   { Otherwise... } dixi('p',ord(person));
 end; { And afterwards... }
 case person of
  #14: if not dna.Ayles_is_awake then dixi('Q',13); { u.f.s.? }
 end;
end;

function holding:boolean;
begin
 if thing in [#51..#99] then begin holding:=true; exit; end; { Also }
 holding:=false;
 if thing>#100 then display('Be reasonable!') else
  if not dna.obj[thing] then { verbs that need "thing" to be in the inventory }
   display('You''re not holding it, Avvy.') else
    holding:=true;
end;

procedure examine;
  procedure special(before:boolean);
  begin
   case dna.room of
    r__Yours: case thing of
               #54: if before then show_one(5) else show_one(6);
              end;
   end;
  end;
begin
 { Examine. EITHER it's an object OR it's an Also OR it's a person OR
    it's something else. }
 if (person=pardon) and (thing<>pardon) then
 begin
  if holding then
   case thing of { remember it's been Slipped- ie subtract 49 }
       #1..#49 : examobj; { Standard object }
     #50..#100 : begin
                  special(true);
                  display(also[ord(thing)-50,1]^); { Also thing }
                  special(false);
                 end;
   end
 end else
  if (person<>pardon) then exampers
   else display('It''s just as it looks on the picture.'); { don't know- guess }
end;

procedure inv; { the time-honoured command... }
var fv:char; q:byte;
begin
 q:=0; display('You''re carrying '+^d);
 with dna do
 begin
  for fv:=#1 to numobjs do
   if obj[fv] then
   begin
    inc(q); if q=carrying then display('and '+^d);
    display(get_better(fv)+^d);
    if fv=wearing then display(', which you''re wearing'+^d);
     if q<carrying then display(', '+^d);
   end;
  if wearing=nowt then display('...'^m^m'...and you''re stark naked!') else
   display('.');
 end;
end;

procedure swallow; { Eat something. }
begin
 case thing of
  wine: case dna.winestate of
         { 4 is perfect }
          1: begin
              if dna.teetotal then begin dixi('D',6); exit; end;
              dixi('U',1); wobble; dixi('U',2);
              dna.obj[wine]:=false; objectlist;
              have_a_drink;
             end;
          2,3: dixi('d',8); { You can't drink it! }
         end;
  potion: begin background(4); dixi('U',3); gameover; background(0); end;
  ink: dixi('U',4);
  chastity: dixi('U',5);
  mushroom: begin
             dixi('U',6);
             gameover;
            end;
  onion: if dna.rotten_onion then dixi('U',11)
         else begin
          dixi('U',8);
          dna.obj[onion]:=false;
          objectlist;
         end;
  else
    if dna.room in [r__ArgentPub,r__NottsPub] then
      display('Try BUYing things before you drink them!')
    else
      display('The taste of it makes you retch!');
         { Constant- leave this one }
 end;
end;

procedure others;
 { This lists the other people in the room. }
var
 fv:char;
 num_people,this_person,here:byte;
begin

 num_people:=0;
 this_person:=0;
 here:=dna.room;

 for fv:=#151 to #178 do { Start at 151 so we don't list Avvy himself! }
  if whereis[fv]=here then
   inc(num_people);

 { If nobody's here, we can cut out straight away. }

 if num_people=0 then exit; { Leave the procedure. }

 for fv:=#151 to #178 do
  if whereis[fv]=here then
  begin
   inc(this_person);
   if this_person=1 then { First on the list. }
    display(getname(fv)+^d) else
    if this_person<num_people then { The middle... }
     display(', '+getname(fv)+^d) else
      display(' and '+getname(fv)+^d); { The end. }
  end;

 if num_people=1 then display(' is'^d) else display(' are'^d);

 display(' here.'); { End and display it. }
end;

procedure lookaround;
{ This is called when you say "look." }
begin
 display(also[0,1]^);
 case dna.room of
  r__Spludwicks: if dna.Avaricius_talk>0 then dixi('q',23) else others;
  r__Robins: begin
              if dna.tied_up then dixi('q',38);
              if dna.Mushroom_Growing then dixi('q',55);
             end;
  r__InsideCardiffCastle: if not dna.taken_pen then dixi('q',49);
  r__LustiesRoom: if dna.Lustie_is_asleep then dixi('q',65);
  r__Catacombs: case (dna.cat_y*256+dna.cat_x) of
                 258 : dixi('q',80); { Inside art gallery }
                 514 : dixi('q',81); { Outside ditto }
                 260 : dixi('q',82); { Outside Geida's room. }
                end;
  else others;
 end;
end;

procedure opendoor; { so whaddya THINK this does?! }
var fv:byte;
begin
 case dna.room of   { Special cases. }
   r__Yours: if infield(2) then
             begin { Opening the box. }
              thing:=#54; { The box. } person:=pardon;
              examine;
              exit;
             end;
   r__Spludwicks: if thing=#61 then begin
                    dixi('q',85);
                    exit;
                  end;
 end;


 if (not dna.user_moves_Avvy) and (dna.room<>r__Lusties)
   then exit; { No doors can open if you can't move Avvy. }
 for fv:=9 to 15 do
  if infield(fv) then
  begin
   with portals[fv] do
    case op of
     exclaim: begin tr[1].bounce; dixi('x',data); end;
     transport: fliproom(hi(data),lo(data));
     unfinished: begin
                  tr[1].bounce;
                  display(#7'Sorry.'^c^m'This place is not available yet!');
                 end;
     special: call_special(data);
     Mopendoor: open_the_door(hi(data),lo(data),fv);
    end;
    exit;
   end;
 if dna.room=r__Map then
  display('Avvy, you can complete the whole game without ever going '+
                 'to anywhere other than Argent, Birmingham, Cardiff, '+
                 'Nottingham and Norwich.')
 else display('Door? What door?');
end;

procedure putproc; { Called when you call vb_put. }
var temp:char;

 procedure silly;
 begin
  display('Don''t be silly!');
 end;

begin
 if not holding then exit;
 dec(thing2,49); { Slip the second object }
 temp:=thing; thing:=thing2; if not holding then exit;
 thing:=temp;

 { Thing is the thing which you're putting in. Thing2 is where you're
   putting it. }
 with dna do { Convenience thing. }
  case thing2 of
   wine: if thing=onion then
         begin
          if dna.rotten_onion then
          display('That''s a bit like shutting the stable door after the '+
                   'horse has bolted!')
          else begin { Put onion into wine? }
           if dna.winestate<>3 then
            display(^f'Oignon au vin'^r' is a bit too strong for your tastes!')
           else begin { Put onion into vinegar! Yes! }
            onion_in_vinegar:=true;
            points(7);
            dixi('u',9);
           end;
          end;
         end else silly;

    #54: if (room=1) then { Put something into the box. }
         begin
          if box_contents<>nowt then
           display('There''s something in the box already, Avvy. Try taking'+
            ' that out first.')
          else
           case thing of
            money: display('You''d better keep some ready cash on you!');
            bell: display('That''s a silly place to keep a bell.');
            bodkin: display('But you might need it!');
            onion: display('Just give it to Spludwick, Avvy!');
            else
            begin { Put the object into the box... }
             if wearing=thing then
              display('You''d better take '+get_better(thing)+' off first!')
             else
             begin
              show_one(5); { Open box. }
              box_contents:=thing;
              dna.obj[thing]:=false;
              objectlist;
              display('OK, it''s in the box.');
              show_one(6); { Shut box. }
             end;
            end;
           end;
         end else silly;

   else silly;
  end;
end;

function give2spludwick:boolean;
 { The result of this fn is whether or not he says "Hey, thanks!" }
  procedure not_in_order;
  begin
   display('Sorry, I need the ingredients in the right order for this potion.'+
    ' What I need next is '+
     get_better(spludwick_order[dna.given2spludwick])+'.'^s'2'^b);
  end;

  procedure go_to_cauldron;
  begin
     tr[2].call_Eachstep:=false; { Stops Geida_Procs. }
     set_up_timer(1,PROCSpludwick_goes_to_cauldron,reason_Spludwalk);
     tr[2].walkto(2);
  end;

begin
 with dna do
 begin

  give2spludwick:=false;

  if spludwick_order[given2spludwick]<>thing then
  begin
   not_in_order;
   exit;
  end;

  case thing of
   onion:
    begin
     obj[onion]:=false;
     if rotten_onion then
      dixi('q',22)
     else begin
      inc(given2spludwick);
      dixi('q',20);
      go_to_cauldron;
      points(3);
     end;
     objectlist;
    end;
   ink: begin
         obj[ink]:=false;
         objectlist;
         inc(given2spludwick);
         dixi('q',24);
         go_to_cauldron;
         points(3);
        end;
   mushroom: begin
              obj[mushroom]:=false;
              dixi('q',25);
              points(5);
              inc(given2spludwick);
              go_to_cauldron;
              obj[potion]:=true;
              objectlist;
             end;
   else give2spludwick:=true;
  end;
 end;
end;

procedure have_a_drink;
begin
 with dna do
 begin
  inc(alcohol);
  if alcohol=5 then
  begin
   obj[key]:=true; { Get the key. }
   teetotal:=true;
   Avvy_is_awake:=false;
   Avvy_in_bed:=true;
   objectlist;
   dusk;
   hang_around_for_a_while;
   fliproom(1,1);
   background(14);
   new_game_for_trippancy; { Not really }
  end;
 end;
end;

procedure Cardiff_climbing;
begin
 if dna.Standing_On_Dais then
 begin { Clamber up. }
  display('You climb down, back onto the floor.');
  dna.Standing_On_Dais:=false;
  apped(1,3);
 end else
 begin { Clamber down. }
  if infield(1) then
  begin
    display('You clamber up onto the dais.');
    dna.Standing_On_Dais:=true;
    apped(1,2);
  end else
    display('Get a bit closer, Avvy.');
 end;
end;

procedure stand_up;
  { Called when you ask Avvy to stand. }
  procedure already;
  begin
   display('You''re already standing!');
  end;
begin
 with dna do
  case dna.room of
   r__Yours: { Avvy isn't asleep. }
              if Avvy_in_bed then { But he's in bed. }
              begin
               if teetotal then
               begin
                dixi('d',12);
                background(0);
                dixi('d',14);
               end;
               tr[1].visible:=true;
               user_moves_Avvy:=true;
               apped(1,2);
               dna.rw:=left;
               show_one(4); { Picture of empty pillow. }
               points(1);
               Avvy_in_bed:=false;
               lose_timer(reason_Arkata_shouts);
              end else already;

    r__InsideCardiffCastle: Cardiff_climbing;

    r__NottsPub: if sitting_in_pub then begin
                  show_one(4); { Not sitting down. }
                  tr[1].visible:=true; { But standing up. }
                  apped(1,4); { And walking away. }
                  sitting_in_pub:=false; { Really not sitting down. }
                  user_moves_Avvy:=true; { And ambulant. }
                 end else already;
   else already;
  end;
end;

procedure getproc(thing:char);
begin
 with dna do
  case room of
   r__Yours:
     if infield(2) then
     begin
      if box_contents=thing then
      begin
       show_one(5);
       display('OK, I''ve got it.');
       obj[thing]:=true; objectlist;
       box_contents:=nowt;
       show_one(6);
      end else
       display('I can''t see '+get_better(thing)+' in the box.');
     end else dixi('q',57);
  r__InsideCardiffCastle:
    case thing of
     pen:
     begin
      if infield(2) then
      begin { Standing on the dais. }

       if dna.taken_pen then
        display('It''s not there, Avvy.')
       else
       begin { OK: we're taking the pen, and it's there. }
        show_one(4); { No pen there now. }
        call_special(3); { Zap! }
        dna.taken_pen:=true;
        dna.obj[pen]:=true;
        objectlist;
        display('Taken.');
       end;
      end else if dna.Standing_on_dais then dixi('q',53) else dixi('q',51);
     end;
      bolt: dixi('q',52);
     else dixi('q',57)
    end;
  r__Robins: if (thing=Mushroom) and (infield(1)) and (dna.Mushroom_Growing)
             then begin
              show_one(3);
              display('Got it!');
              dna.Mushroom_Growing:=false;
              dna.Taken_Mushroom:=true;
              dna.obj[mushroom]:=true;
              objectlist;
              points(3);
             end else dixi('q',57)
  else dixi('q',57)
 end;
end;

procedure give_Geida_the_lute;
begin
 with dna do
 begin
  if room<>r__LustiesRoom then
  begin
   display('Not yet. Try later!'^s'2'^b);
   exit;
  end;
  dna.obj[lute]:=false;
  objectlist;
  dixi('q',64); { She plays it. }

   { And the rest has been moved to Timeout... under give_lute_to_Geida. }

  set_up_timer(1,PROCgive_lute_to_Geida,reason_Geida_sings);
  back_to_bootstrap(4);
 end;
end;

procedure play_harp;
begin
 if infield(7) then
  musical_scroll
 else display('Get a bit closer to it, Avvy!');
end;

procedure winsequence;
begin
 dixi('q',78);
 first_show(7); then_show(8); then_show(9);
 start_to_close;
 set_up_timer(30,PROCwinning,reason_winning);
end;

procedure person_speaks;
var found:boolean; fv:byte; cfv:char;
begin

  if (person=pardon) or (person=#0) then
  begin
   if (him=pardon) or (whereis[him]<>dna.room) then person:=her
    else person:=him;
  end;

  if (whereis[person]<>dna.room) then
  begin
   display(^s'1'^d); { Avvy himself! }
   exit;
  end;

  found:=false; { The person we're looking for's code is in Person. }

  for fv:=1 to numtr do
   if tr[fv].quick and (chr(tr[fv].a.accinum+149)=person) then
   begin
    display(^s+chr(fv+48)+^d);
    found:=true;
   end;

  if not found then
    for fv:=10 to 25 do
     with quasipeds[fv] do
     if (who=person) and (room=dna.room) then
     begin
      display(^s+chr(fv+55)+^d);
     end;
end;

procedure do_that;
const booze: array[#51..#58] of string[6] = ('Bitter','GIED','Whisky','Cider','','','','Mead');
var fv,ff:byte; sx,sy:integer; ok:boolean;
  procedure heythanks;
  begin
    person_speaks;
    display('Hey, thanks!'^b'(But now, you''ve lost it!)');
    dna.obj[thing]:=false;
  end;

begin
 if thats=nowt then begin thats:=''; exit; end;
 if weirdword then exit;
 if thing<#200 then dec(thing,49); { "Slip" }

 if (not alive) and
  not (verb in [vb_load,vb_save,vb_quit,vb_info,vb_help,vb_larrypass,
     vb_phaon,vb_boss,vb_cheat,vb_restart,vb_dir,vb_score,
     vb_highscores,vb_smartalec])
  then begin
        display('You''re dead, so don''t talk. What are you, a ghost '+
         'or something? Try restarting, or restoring a saved game!'); exit;
       end;

 if (not dna.Avvy_is_awake) and
  not (verb in [vb_load,vb_save,vb_quit,vb_info,vb_help,vb_larrypass,
     vb_phaon,vb_boss,vb_cheat,vb_restart,vb_dir,vb_die,vb_score,
     vb_highscores,vb_smartalec,vb_expletive,vb_wake])
  then begin
        display('Talking in your sleep? Try waking up!'); exit;
       end;


 case verb of
  vb_exam: examine;
  vb_open: opendoor;
  vb_pause: display('Game paused.'+^c+^m+^m+'Press Enter, Esc, or click '+
             'the mouse on the `O.K." box to continue.');
  vb_get: begin
           if thing<>pardon then
           begin { Legitimate try to pick something up. }
            if dna.carrying>=maxobjs then display('You can''t carry any more!')
            else getproc(thing);
             
           end else
           begin { Not... ditto. }
            if person<>pardon then
             display('You can''t sweep folk off their feet!') else
            display('I assure you, you don''t need it.');
           end;
          end;
  vb_drop: display('Two years ago you dropped a florin in the street. Three days '+
       'later it was gone! So now you never leave ANYTHING lying around. OK?');
(*       begin dna.obj[thing]:=false; objectlist; end;*)
  vb_inv: inv;
  vb_talk:  if person=pardon then
            begin
              if subjnumber=99 then { They typed "say password". }
                display('Yes, but what '^f'is'^r' the password?')
              else if (subjnumber in [1..49,253,249]) then
              begin
                delete(thats,1,1);
                move(realwords[2],realwords[1],sizeof(realwords)-sizeof(realwords[1]));
                verb:=chr(subjnumber);
                do_that; exit;
              end else
              begin
                person:=chr(subjnumber); subjnumber:=0;
                if person in [pardon,#0] then display('Talk to whom?')
                 else if (personshere) then talkto(ord(person));
              end;
            end else if person=pardon then display('Talk to whom?')
            else if (personshere) then talkto(ord(person));

  vb_give: if holding then
           begin
            if person=pardon then display('Give to whom?') else
            if personshere then
            begin
             case thing of
              money : display('You can''t bring yourself to give away your moneybag.');
              bodkin,bell,clothes,habit :
                    display('Don''t give it away, it might be useful!');
              else case person of
                      pCrapulus: case thing of
                                 wine: begin
                                        display('Crapulus grabs the wine and gulps it down.');
                                        dna.obj[wine]:=false;
                                       end;
                                 else heythanks;
                                end;
                     pCwytalot: if thing in [crossbow,bolt] then
                                 display('You might be able to influence '+
                                 'Cwytalot more if you used it!')
                                else heythanks;
                     pSpludwick: if give2spludwick then heythanks;
                     pIbythneth: if thing=badge then
                                 begin
                                  dixi('q',32); { Thanks! Wow! }
                                  points(3);
                                  dna.obj[badge]:=false;
                                  dna.obj[habit]:=true;
                                  dna.GivenBadgeToIby:=true;
                                  show_one(8); show_one(9);
                                 end else heythanks;
                     pAyles: if dna.Ayles_is_awake then
                             begin
                               if thing=pen then
                               begin
                                dna.obj[pen]:=false;
                                dixi('q',54);
                                dna.obj[ink]:=true;
                                dna.given_pen_to_ayles:=true;
                                objectlist;
                                points(2);
                               end else heythanks;
                             end else
                               display('But he''s asleep!');
                     pGeida: case thing of
                              potion : begin
                                        dna.obj[potion]:=false;
                                        dixi('u',16); { She drinks it. }
                                        points(2);
                                        dna.Geida_given_potion:=true;
                                        objectlist;
                                       end;
                              lute: give_Geida_the_lute;
                              else heythanks;
                             end;
                     pArkata: case thing of
                              potion: if dna.Geida_given_potion then
                                       winsequence
                                      else dixi('q',77); { That Geida woman! }
                              else heythanks;
                             end;
                    else heythanks;
                   end;
             end;
            end;
            objectlist; { Just in case... }
           end;

  vb_eat,vb_drink: if holding then swallow;
  vb_load: edna_load(realwords[2]);
  vb_save: if alive then edna_save(realwords[2])
           else display('It''s a bit late now to save your game!');
  vb_pay: display('No money need change hands.');
  vb_look: lookaround;
  vb_break: display('Vandalism is prohibited within this game!');
  vb_quit: begin { quit }
            if demo then
            begin
             dixi('q',31);
             close(demofile);
             halt; { Change this later!!! }
            end;
        if not polite then display('How about a `please", Avvy?') else
         if ask(^s'C'^v'Do you really want to quit?') then lmo:=true;
       end;
  vb_go: display('Just use the arrow keys to walk there.');
  vb_info: begin
            aboutscroll:=true;
(*            display('Thorsoft of Letchworth presents:'+^c+^m+^m+
             'The mediëval descendant of'+^m+
             'Denarius Avaricius Sextus'+^m+'in:'+
             ^m+^m+'LORD AVALOT D''ARGENT'+
             ^m+'version '+vernum+^m+^m+'Copyright Ô '
             +copyright+', Mark, Mike and Thomas Thurman.');*)
             display(^m^m^m^m^m^m^m+'LORD AVALOT D''ARGENT'+^c^m+
              'The mediëval descendant of'+^m+
              'Denarius Avaricius Sextus'+
              ^m+^m+'version '+vernum+^m+^m+'Copyright Ô '
              +copyright+', Mark, Mike and Thomas Thurman.'+^s+'Y'+^v);
             aboutscroll:=false;
           end;
  vb_undress: if dna.wearing=nowt then display('You''re already stark naked!')
               else
            if dna.Avvys_in_the_cupboard then
            begin
             display('You take off '+get_better(dna.wearing)+'.');
             dna.wearing:=nowt; objectlist;
            end else
            display('Hadn''t you better find somewhere more private, Avvy?');
  vb_wear: if holding then
       begin { wear something }
        case thing of
         chastity: display('Hey, what kind of a weirdo are you??!');
         clothes,habit: begin { Change this! }
                         if dna.wearing<>nowt then
                         begin
                          if dna.wearing=thing then
                            display('You''re already wearing that.')
                          else
                            display('You''ll be rather warm wearing two '+
                           'sets of clothes!');
                          exit;
                         end else
                         dna.wearing:=thing; objectlist;
                         if thing=habit then fv:=3 else fv:=0;
                         with tr[1] do
                          if whichsprite<>fv then
                          begin
                           sx:=tr[1].x; sy:=tr[1].y;
                           Done;
                           Init(fv,true);
                           appear(sx,sy,left);
                           tr[1].visible:=false;
                          end;
                        end;
         else display(what);
        end;
       end;
  vb_play: if (thing=pardon) then
            case dna.room of { They just typed "play"... }
             r__ArgentPub: play_nim; { ...in the pub, => play Nim. }
             r__MusicRoom: play_harp;
            end
           else if holding then
           begin
            case thing of
             lute : begin
                     dixi('U',7);
                     if whereis[pCwytalot]=dna.room then dixi('U',10);
                     if whereis[pduLustie]=dna.room then dixi('U',15);
                    end;
             #52 : if (dna.room=r__MusicRoom) then play_harp
                    else display(what);
             #55 : if (dna.room=r__ArgentPub) then play_Nim
                    else display(what);
             else display(what);
            end;
           end;
  vb_ring: if holding then
       begin
        if thing=bell then
        begin
         display('Ding, dong, ding, dong, ding, dong, ding, dong...');
         if (dna.ringing_bells) and (flagset('B')) then
          display('(Are you trying to join in, Avvy??!)');
        end else display(what);
       end;
  vb_help: boot_help;
  vb_larrypass: display('Wrong game!');
  vb_phaon: display('Hello, Phaon!');
  vb_boss: bosskey;
  vb_pee: if flagset('P') then
          begin
           display('Hmm, I don''t think anyone will notice...');
           set_up_timer(4,PROCurinate,reason_GoToToilet);
          end else display('It would be '^f'VERY'^r' unwise to do that here, Avvy!');
  vb_cheat: begin
             display(^F+'Cheat mode now enabled.');
             cheat:=true;
            end;
  vb_magic: if dna.Avaricius_talk>0 then
             dixi('q',19)
            else begin
             if (dna.room=12) and (infield(2)) then
             begin { Avaricius appears! }
              dixi('q',17);
              if whereis[#151]=12 then
               dixi('q',18)
              else
              begin
               tr[2].init(1,false); { Avaricius }
               apped(2,4);
               tr[2].walkto(5);
               tr[2].call_Eachstep:=true;
               tr[2].Eachstep:=PROCback_and_forth;
               dna.Avaricius_talk:=14;
               set_up_timer(177,PROCAvaricius_talks,reason_AvariciusTalks);
              end;
             end else display('Nothing appears to happen...');
            end;
  vb_smartalec: display('Listen, smart alec, that was just rhetoric.');
  vb_expletive: with dna do begin
         case swore of
          0: display('Avvy! Do you mind? There might be kids playing!'^M^M+
              '(I shouldn''t say it again, if I were you!)');
          1: display('You hear a distant rumble of thunder. Must you always '+
              'do things I tell you not to?'^m^m'Don''t do it again!');
         else
          begin
           zonk;
           display('A crack of lightning shoots from the sky, '+
            'and fries you.'^m^m'(`Such is the anger of the gods, Avvy!")');
           gameover;
          end;
         end;
         inc(swore);
        end;
  vb_listen: if (dna.ringing_bells) and (flagset('B')) then
              display('All other noise is drowned out by the ringing of '+
                       'the bells.')
             else
              if listen='' then
               display('You can''t hear anything much at the moment, Avvy.')
                else display(listen);
  vb_buy: begin
           { What are they trying to buy? }
           case dna.room of
            r__argentpub: if infield(6) then
                begin { We're in a pub, and near the bar. }
                 case thing of
                  #51,#53,#54,#58: begin { Beer, whisky, cider or mead }
                            if dna.malagauche=177 then { Already getting us one. }
                              begin dixi('D',15); exit; end;
                            if dna.teetotal then begin dixi('D',6); exit; end;
                            if dna.alcohol=0 then points(3);
                            show_one(12);
                            display(booze[thing]+', please.'^s'1'^b);
                            dna.drinking:=thing;

                            show_one(10);
                            dna.malagauche:=177;
                            set_up_timer(27,PROCbuydrinks,reason_Drinks);
                           end;
                  #52: examine; { We have a right one here- buy Pepsi??! }
                  wine: if dna.obj[wine] then { We've already got the wine! }
                          dixi('D',2) { 1 bottle's shufishent! }
                         else begin
                          if dna.malagauche=177 then { Already getting us one. }
                            begin dixi('D',15); exit; end;
                          if dna.carrying>=maxobjs then
                             begin display('Your hands are full.'); exit end;
                          show_one(12); display('Wine, please.'^s'1'^b);
                          if dna.alcohol=0 then points(3);
                          show_one(10);
                          dna.malagauche:=177;

                          set_up_timer(27,PROCbuywine,reason_Drinks);
                         end;
                 end;
                end else dixi('D',5); { Go to the bar! }

            r__OutsideDucks: if infield(6) then
             begin
              if thing=onion then
              begin
               if dna.obj[onion] then
                dixi('D',10) { not planning to juggle with the things! }
               else
               if dna.carrying>=maxobjs then
                  display('Before you ask, you remember that your hands are full.')
               else
               begin
                if dna.bought_onion then
                 dixi('D',11) else
                  begin dixi('D',9); points(3); end;
                pennycheck(3); { It costs thruppence. }
                dna.obj[onion]:=true;
                objectlist;
                dna.bought_onion:=true;
                dna.rotten_onion:=false; { It's OK when it leaves the stall! }
                dna.onion_in_vinegar:=false;
               end;
              end else dixi('D',0);
             end else dixi('D',0);

             r__NottsPub: dixi('n',15); { Can't sell to southerners. }
            else dixi('D',0); { Can't buy that. }
           end;
          end;
  vb_attack: begin
              if (dna.room=r__BrummieRoad) and
               ((person=#157) or (thing=crossbow) or (thing=bolt))
               and (whereis[#157]=dna.room) then
              begin
               case ord(dna.obj[bolt])+ord(dna.obj[crossbow])*2 of
                { 0 = neither, 1 = only bolt, 2 = only crossbow,
                  3 = both. }
                0: begin
                    dixi('Q',10);
                    display('(At the very least, don''t use your bare hands!)');
                   end;
                1: display('Attack him with only a crossbow bolt? Are you '+
                    'planning on playing darts?!');
                2: display('Come on, Avvy! You''re not going to get very far '+
                     'with only a crossbow!');
                3: begin
                    dixi('Q',11);
                    dna.cwytalot_gone:=true;
                    dna.obj[bolt]:=false; dna.obj[crossbow]:=false;
                    objectlist;
                    magics[12].op:=nix;
                    points(7);
                    tr[2].walkto(2);
                    tr[2].vanishifstill:=true;
                    tr[2].call_Eachstep:=false;
                    whereis[#157]:=177;
                   end;
                else dixi('Q',10); { Please try not to be so violent! }
               end;
              end else dixi('Q',10);
             end;
  vb_password: if dna.room<>r__Bridge then
                dixi('Q',12) else
               begin
                ok:=true;
                for ff:=1 to length(thats) do
                 for fv:=1 to length(words[dna.pass_num+first_password].w) do
                  if words[dna.pass_num+first_password].w[fv] <>
                          upcase(realwords[ff,fv])
                   then ok:=false;
                if ok then
                begin
                 if dna.drawbridge_open<>0 then
                   display('Contrary to your expectations, the drawbridge fails to close again.')
                 else
                 begin
                    points(4);
                    display('The drawbridge opens!');
                    set_up_timer(7,PROCopen_drawbridge,Reason_DrawbridgeFalls);
                    dna.drawbridge_open:=1;
                 end;
                end else dixi('Q',12);
               end;
   vb_dir: dir(realwords[2]);
   vb_die: gameover;
   vb_score: display('Your score is '+strf(dna.score)+','^c^m'out of a '+
                      'possible 128.'^m^m'This gives you a rank of '+rank+
                      '.'^m^m+totaltime);
   vb_put: putproc;
   vb_stand: stand_up;

   vb_kiss: if (person=pardon)
              then display('Kiss whom?')
            else if personshere then
            case person of
             #150..#174: display('Hey, what kind of a weirdo are you??');
             pArkata: dixi('U',12);
             pGeida: dixi('U',13);
             pWiseWoman: dixi('U',14);
             else dixi('U',5); { You WHAT? }
            end;

   vb_climb: if (dna.room=r__InsideCardiffCastle) then Cardiff_climbing
             else { In the wrong room! }
              display('Not with your head for heights, Avvy!');

   vb_jump: begin
             set_up_timer(1,PROCjump,reason_Jumping);
             dna.user_moves_Avvy:=false;
            end;

   vb_highscores: show_highs;

   vb_wake: with dna do
             if personshere then
              case person of
               pardon,pAvalot,#0: if not Avvy_is_awake then
                    begin
                     Avvy_is_awake:=true;
                     points(1);
                     Avvy_in_bed:=true;
                     show_one(3); { Picture of Avvy, awake in bed. }
                     if teetotal then dixi('d',13);
                    end else display('You''re already awake, Avvy!');
               pAyles: if not Ayles_is_awake then display('You can''t seem to wake him by yourself.');
               pJacques: display('Brother Jacques, Brother Jacques, are you asleep?'^s'1'^b+
                          'Hmmm... that doesn''t seem to do any good...');
               else display('It''s difficult to awaken people who aren''t asleep...!');
              end;

   vb_sit: if dna.room=r__NottsPub then
           begin
            if dna.sitting_in_pub then
             display('You''re already sitting!')
            else
            begin
             tr[1].walkto(4); { Move Avvy to the place, and sit him down. }
             set_up_timer(1,PROCAvvy_sit_down,reason_sitting_down);
            end;
           end else
           begin { Default doodah. }
            dusk;
            hang_around_for_a_while;
            dawn;
            display('A few hours later...'^p'nothing much has happened...');
           end;

   vb_restart: if ask('Restart game and lose changes?') then begin
                dusk;
                newgame;
                dawn;
               end;

  pardon: display('Hey, a verb would be helpful!');

  vb_hello: begin person_speaks; display('Hello.'^b); end;
  vb_thanks: begin person_speaks; display('That''s OK.'^b); end;
  else display(^G+'Parser bug!');
 end;
end;

procedure verbopt(n:char; var answer:string; var anskey:char);
begin
 case n of
   vb_exam: begin answer:='Examine'; anskey:='x'; end; { the ubiqutous one }
   { vb_give isn't dealt with by this procedure, but by ddm__with }
  vb_drink: begin answer:='Drink';   anskey:='D'; end;
  vb_wear:  begin answer:='Wear';    anskey:='W'; end;
  vb_ring:  begin answer:='Ring';    anskey:='R'; end; { only the bell! }
  vb_play:  begin answer:='Play';    anskey:='P'; end;
  vb_eat:   begin answer:='Eat';     anskey:='E'; end;
  else      begin answer:='? Unknown!'; anskey:='?'; end; { Bug! }
 end;
end;

begin
 weirdword:=false;
end.
