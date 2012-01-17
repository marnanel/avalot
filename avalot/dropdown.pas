{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 DROPDOWN         A customised version of Oopmenu (qv). }

unit dropdown;

interface

type
 proc = procedure;

 headtype = object
             title:string[8];
             trigger,alttrigger:char;
             position:byte;
             xpos,xright:integer;
             do_setup,do_choose:proc;

             constructor Init
              (trig,alttrig:char; name:string; p:byte; dw,dc:proc);
             procedure display;
             procedure highlight;
             function extdparse(c:char):boolean;
            end;

 optiontype = record
               title:string;
               trigger:char;
               shortcut:string[9];
               valid:boolean;
              end;

 onemenu = object
            oo:array[1..12] of optiontype;
            number:byte;
            width,left:integer;
            firstlix:boolean;
            flx1,flx2,fly:integer;
            oldy:byte; { used by Lightup }
            menunow:boolean; { Is there a menu now? }
            menunum:byte; { And if so, which is it? }
            choicenum:byte; { Your choice? }
            highlightnum:byte;

            procedure start_afresh;
            procedure opt(n:string; tr:char; key:string; val:boolean);
            procedure display;
            procedure wipe;
            procedure lightup;
            procedure displayopt(y:byte; highlit:boolean);
            procedure movehighlight(add:shortint);
            procedure select(n:byte);
            procedure keystroke(c:char);
            constructor Init;
           end;

 menuset = object
            ddms:array[1..8] of headtype;
            howmany:byte;

            constructor Init;
            procedure create(t:char; n:string; alttrig:char; dw,dc:proc);
            procedure update;
            procedure extd(c:char);
            procedure getcertain(fv:byte);
            procedure getmenu(x:integer);
           end;


var
 ddm_o:onemenu;
 ddm_m:menuset;

 people:string[5];


  procedure find_what_you_can_do_with_it;

  procedure parsekey(r,re:char);

  procedure menu_link;

  { DDM menu-bar procs }

  procedure standard_bar;
  (*procedure map_bar;*)

implementation

uses Crt,Graph,Dos,Lucerna,Gyro,Acci,Trip5,Enid,Basher;
{$V-}
const

 indent = 5;
 spacing = 10;

(* menu_b = blue; { Morpheus }
 menu_f = yellow;
 menu_border = black;
 highlight_b = lightblue;
 highlight_f = yellow;
 disabled = lightgray; *)

 menu_b = lightgray; { Windowsy }
 menu_f = black;
 menu_border = black;
 highlight_b = black;
 highlight_f = white;
 disabled = darkgray;

var
 r:char;
 fv:byte;

procedure find_what_you_can_do_with_it;
begin;
 case thinks of
  wine,ink: verbstr:=vb_exam+vb_drink;
  bell: verbstr:=vb_exam+vb_ring;
  potion,wine: verbstr:=vb_exam+vb_drink;
  chastity: verbstr:=vb_exam+vb_wear;
  lute: verbstr:=vb_exam+vb_play;
  mushroom,onion: verbstr:=vb_exam+vb_eat;
  clothes: verbstr:=vb_exam+vb_wear;
  else verbstr:=vb_exam; { anything else }
 end;
end;

procedure chalk(x,y:integer; t:char; z:string; valid:boolean);
var
 fv,ff,p,bit:byte;
 pageseg:word;
 ander:byte;
begin;

 pageseg:=$A000+cp*$400;

 if valid then ander:=255 else ander:=170;

 for fv:=1 to length(z) do
  for ff:=0 to 7 do
   for bit:=0 to 2 do
   begin;
    port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
    mem[pageseg:x+fv-1+(y+ff)*80]:=not (little[z[fv],ff] and ander);
   end;

 for ff:=0 to 8 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl 3; port[$3CF]:=3;
  fillchar(mem[pageseg:x+(y+ff)*80],length(z),#0); { blank it out. }
 end;

 p:=pos(t,z); if p=0 then exit; dec(p);

 for bit:=0 to 2 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  mem[pageseg:x+p+(y+8)*80]:=not ander;
 end;

 blitfix;
end;

procedure HLchalk(x,y:integer; t:char; z:string; valid:boolean);
 { Highlighted. }
var
 fv,ff,p:byte;
 pageseg:word;
 ander:byte;
begin;

 pageseg:=$A000+cp*$400;

 if valid then ander:=255 else ander:=170;

 for fv:=1 to length(z) do
  for ff:=0 to 7 do
   mem[pageseg:x+fv-1+(y+ff)*80]:=little[z[fv],ff] and ander;

 p:=pos(t,z); if p=0 then exit; dec(p);

 mem[pageseg:x+p+(y+8)*80]:=ander;
 blitfix;
end;

(*procedure say(x,y:integer; t:char; z:string; f,b:byte);
begin;
 settextjustify(0,2); setfillstyle(1,b); setcolor(f);
 bar(x-3,y-1,x+textwidth(z)+3,y+textheight(z));
 chalk(x,y,t,z);
end;*)

procedure bleep;
begin;
 sound(177); delay(7); nosound;
end;

procedure onemenu.start_afresh;
begin;
 number:=0; width:=0; firstlix:=false; oldy:=0; highlightnum:=0;
end;

constructor onemenu.Init;
begin;
 menunow:=false; ddmnow:=false; menunum:=1;
end;

procedure onemenu.opt(n:string; tr:char; key:string; val:boolean);
var l:integer;
begin;
 inc(number);
 l:=length(n+key)+3; if width<l then width:=l;
 with oo[number] do
 begin;
  title:=n;
  trigger:=tr;
  shortcut:=key;
  valid:=val;
 end;
end;

procedure onemenu.displayopt(y:byte; highlit:boolean);
var
 data:string;
begin;
 with oo[y] do
 begin;

  if highlit then
   setfillstyle(1,0)
   else
    setfillstyle(1,7);
  bar((flx1+1)*8,3+y*10,(flx2+1)*8,12+y*10);

(*  settextjustify(2,2);
   if shortcut>'' then outtextxy(flx2,4+y*10,shortcut);*)

  data:=title;

  while length(data+shortcut)<width do
   data:=data+' '; { Pad with spaces. }

  data:=data+shortcut;

  if highlit then
   HLchalk(left,4+y*10,trigger,data,valid)
  else
   chalk(left,4+y*10,trigger,data,valid);

 end;
end;

procedure onemenu.display;
var y:byte;
begin;
 off;
 setactivepage(cp); setvisualpage(cp);
 setfillstyle(1,menu_b); setcolor(menu_border);
 firstlix:=true;
 flx1:=left-2; flx2:=left+width; fly:=14+number*10;
 menunow:=true; ddmnow:=true;

 bar((flx1+1)*8,12,(flx2+1)*8,fly);
 rectangle((flx1+1)*8-1,11,(flx2+1)*8+1,fly+1);

 displayopt(1,true);
 for y:=2 to number do
  with oo[y] do displayopt(y,false);
 defaultled:=1; cmp:=177; mousepage(cp); on; { 4= fletch }
end;

procedure onemenu.wipe;
var r:bytefield;
begin;
 setactivepage(cp);
 off;
 with ddm_m.ddms[ddm_o.menunum] do
  chalk(xpos,1,trigger,title,true);
(* mblit((flx1-3) div 8,11,((flx2+1) div 8)+1,fly+1,3,cp);*)

(* with r do
 begin;
  x1:=flx1;
  y1:=11;
  x2:=flx2+1;
  y2:=fly+1;
 end;
 getset[cp].remember(r);*)

 mblit(flx1,11,flx2+1,fly+1,3,cp); blitfix;
 menunow:=false; ddmnow:=false; firstlix:=false; defaultled:=2;
 on_Virtual;
end;

procedure onemenu.movehighlight(add:shortint);
var hn:shortint;
begin;
 if add<>0 then
 begin;
  hn:=highlightnum+add;
  if (hn<0) or (hn>=number) then exit;
  highlightnum:=hn;
 end;
 setactivepage(cp); off;
  displayopt(oldy+1,false);
  displayopt(highlightnum+1,true);
 setactivepage(1-cp);
 oldy:=highlightnum; on;
end;

procedure onemenu.lightup; { This makes the menu highlight follow the mouse.}
begin;
 if (mx<flx1*8) or (mx>flx2*8) or (my<=12) or (my>fly-3) then exit;
 highlightnum:=(my-13) div 10;
 if highlightnum=oldy then exit;
 movehighlight(0);
end;

procedure onemenu.select(n:byte); { Choose which one you want. }
begin;
 if not oo[n+1].valid then exit;
 choicenum:=n; wipe;

 if choicenum=number then dec(choicenum); { Off the bottom. }
 if choicenum>number then choicenum:=0; { Off the top, I suppose. }

 ddm_m.ddms[menunum].do_choose;
end;

procedure onemenu.keystroke(c:char);
var fv:byte; found:boolean;
begin;
 c:=upcase(c); found:=false;
 for fv:=1 to number do
  with oo[fv] do
   if (upcase(trigger)=c) and valid then
   begin;
    select(fv-1);
    found:=true;
   end;
 if not found then blip;
end;

  constructor headtype.Init
   (trig,alttrig:char; name:string; p:byte; dw,dc:proc);
  begin;
   trigger:=trig; alttrigger:=alttrig; title:=name;
   position:=p; xpos:=(position-1)*spacing+indent;
   xright:=position*spacing+indent;
   do_setup:=dw; do_choose:=dc;
  end;

  procedure headtype.display;
  begin;
   off; {MT}
   chalk(xpos,1,trigger,title,true);
   on; {MT}
  end;

  procedure headtype.highlight;
  begin;
   off; off_Virtual; nosound;
   setactivepage(cp);
    HLchalk(xpos,1,trigger,title,true);
   with ddm_o do
   begin;
    left:=xpos;
    menunow:=true; ddmnow:=true; menunum:=position;
   end;
   cmp:=177; { Force redraw of cursor. }
  end;

  function headtype.extdparse(c:char):boolean;
  begin;
   if c<>alttrigger then begin; extdparse:=true; exit; end;
   extdparse:=false;
  end;

  constructor menuset.Init;
  begin;
   howmany:=0;
  end;

  procedure menuset.create(t:char; n:string; alttrig:char; dw,dc:proc);
  begin;
   inc(howmany);
   ddms[howmany].init(t,alttrig,n,howmany,dw,dc);
  end;

  procedure menuset.update;
  const
   menuspace : bytefield = (x1:0; y1:0; x2:80; y2:9);
  var
   fv,page,saveCP:byte;
  begin;
   setactivepage(3);
   setfillstyle(1,menu_b); bar(0, 0,640, 9);
   saveCP:=cp; cp:=3;

   for fv:=1 to howmany do
    ddms[fv].display;

   for page:=0 to 1 do
    getset[page].remember(menuspace);

   cp:=saveCP;
  end;

  procedure menuset.extd(c:char);
  var fv:byte;
  begin;
   fv:=1;
   while (fv<=howmany) and (ddms[fv].extdparse(c)) do inc(fv);
   if fv>howmany then exit; getcertain(fv);
  end;

  procedure menuset.getcertain(fv:byte);
  begin;
   with ddms[fv] do
    with ddm_o do
    begin;
     if (menunow) then
     begin;
      wipe; { get rid of menu }
      if (menunum=position) then exit; { clicked on own highlight }
     end;
     highlight; do_setup;
    end;
  end;

  procedure menuset.getmenu(x:integer);
  var fv:byte;
  begin;
   fv:=0;
   repeat
    inc(fv);
    if (x>ddms[fv].xpos*8) and (x<ddms[fv].xright*8) then
    begin;
     getcertain(fv);
     exit;
    end;
   until fv>howmany;
  end;

procedure parsekey(r,re:char);
begin;
 with ddm_o do
  case r of
   #0,#224: begin;
        case re of
         'K': if menunum>1 then begin;
               wipe;
               ddm_m.getcertain(menunum-1);
              end else
              begin; { Get menu on the left-hand side }
               wipe;
               ddm_m.getmenu((ddm_m.howmany-1)*spacing+indent);
              end;
         'M': if menunum<ddm_m.howmany then begin;
               wipe;
               ddm_m.getcertain(menunum+1);
              end else
              begin; { Get menu on the far right-hand side }
               wipe;
               ddm_m.getmenu(indent);
              end;
         'H': movehighlight(-1);
         'P': movehighlight(1);
         else ddm_m.extd(re);
         end;
        end;
   #13: select(ddm_o.highlightnum);
   else
   begin;
    if menunow then keystroke(r);
   end;
  end;
end;

{$F+  *** Here follow all the ddm__ and do__ procedures for the DDM system. }

procedure ddm__game;
begin;
 with ddm_o do
 begin;
  start_afresh;
  opt('Help...','H','f1',true);
  opt('Boss Key','B','alt-B',true);
  opt('Untrash screen','U','ctrl-f7',true);
  opt('Score and rank','S','f9',true);
  opt('About Avvy...','A','shift-f10',true);
  display;
 end;
end;

procedure ddm__file;
begin;
 with ddm_o do
 begin;
  start_afresh;
  opt('New game','N','f4',true);
  opt('Load...','L','^f3',true);
  opt('Save','S','^f2',alive);
  opt('Save As...','v','',alive);
  opt('DOS Shell','D',atkey+'1',true);
  opt('Quit','Q','alt-X',true);
  display;
 end;
end;

procedure ddm__action;
var n:string;
begin;
 n:=copy(f5_does,2,255);

 with ddm_o do
 begin;
  start_afresh;
  if n='' then
   opt('Do something','D','f5',false)
  else
   opt(copy(n,2,255),n[1],'f5',true);
  opt('Pause game','P','f6',true);
  if dna.room=99 then
   opt('Journey thither','J','f7',neardoor)
  else
   opt('Open the door','O','f7',neardoor);
  opt('Look around','L','f8',true);
  opt('Inventory','I','Tab',true);
  if tr[1].xs=walk then
    opt('Run fast','R','^R',true)
  else
    opt('Walk slowly','W','^W',true);
  display;
 end;
end;

procedure ddm__people;
var here:byte; fv:char;
begin;

 people:='';
 here:=dna.room;

 with ddm_o do
 begin;
  start_afresh;
  for fv:=#150 to #178 do
   if whereis[fv]=here then
   begin;
    opt(getname(fv),getnamechar(fv),'',true);
    people:=people+fv;
   end;
  display;
 end;
end;

procedure ddm__objects;
var fv:char;
begin;
 with ddm_o do
 begin;
  start_afresh;
  for fv:=#1 to numobjs do
   if dna.obj[fv] then
    opt(get_thing(fv),get_thingchar(fv),'',true);
  display;
 end;
end;

function himher(x:char):string; { Returns "im" for boys, and "er" for girls.}
begin;
 if x<#175 then himher:='im' else himher:='er';
end;

procedure ddm__with;
var fv:byte; verb:string[7]; vbchar:char; n:boolean;
begin;
 with ddm_o do
 begin;
  start_afresh;

  if thinkthing then
  begin;

   find_what_you_can_do_with_it;

   for fv:=1 to length(verbstr) do
   begin;
    verbopt(verbstr[fv],verb,vbchar);
    opt(verb,vbchar,'',true);
   end;

   { We disable the "give" option if: (a), you haven't selected anybody,
      (b), the person you've selected isn't in the room,
      or (c), the person you've selected is YOU! }

   if (last_person in [nowt,pAvalot]) or
    (whereis[last_person]<>dna.room) then
    opt('Give to...','G','',false) { Not here. } else
    begin;
     opt('Give to '+getname(last_person),'G','',true);
     verbstr:=verbstr+vb_Give;
    end;

  end else
  begin;
   opt('Examine','x','',true);
   opt('Talk to h'+himher(thinks),'T','',true);
   verbstr:=vb_Exam+vb_Talk;
   case thinks of

    pGeida,pArkata:
     begin;
      opt('Kiss her','K','',true);
      verbstr:=verbstr+vb_kiss;
     end;

    pDogfood:
     begin;
      opt('Play his game','P','',not dna.wonNim); { True if you HAVEN'T won. }
      verbstr:=verbstr+vb_Play;
     end;

    pMalagauche:
     begin;
      n:=not dna.teetotal;
      opt('Buy some wine','w','',not dna.obj[wine]);
      opt('Buy some beer','b','',n);
      opt('Buy some whisky','h','',n); opt('Buy some cider','c','',n);
      opt('Buy some mead','m','',n);
      verbstr:=verbstr+#101+#100+#102+#103+#104;
     end;

    pTrader:
     begin;
      opt('Buy an onion','o','',not dna.obj[onion]);
      verbstr:=verbstr+#105;
     end;

   end;
  end;
  display;
 end;
end;

(*procedure ddm__map;
begin;
 with ddm_o do
 begin;
  start_afresh;
  opt('Cancel map','G','f5',true);
  opt('Pause game','P','f6',true);
  opt('Journey thither','J','f7',neardoor);
  opt('Explanation','L','f8',true);
  display;
 end;
end;

procedure ddm__town;
begin;
 with ddm_o do
 begin;
  start_afresh;
  opt('Argent','A','',true);
  opt('Birmingham','B','',true);
  opt('Nottingham','N','',true);
  opt('Cardiff','C','',true);
  display;
 end;
end;*)

procedure do__game;
begin;
 case ddm_o.choicenum of
  { Help, boss, untrash screen. }
   0: callverb(vb_help);
   1: callverb(vb_boss);
   2: major_redraw;
   3: callverb(vb_score);
   4: callverb(vb_info);
 end;
end;

procedure do__file;
begin;
 case ddm_o.choicenum of
  { New game, load, save, save as, DOS shell, about, quit. }
   0: callverb(vb_restart);
   1: begin; realwords[2]:=''; callverb(vb_load); end;
   2: begin; realwords[2]:=''; callverb(vb_save); end;
   3: filename_edit;
   4: back_to_bootstrap(2);
   5: callverb(vb_quit);
 end;
end;

procedure do__action;
var n:string;
begin;
 case ddm_o.choicenum of
  { Get up/pause game/open door/look/inv/walk-run }
  0: begin
        person:=pardon; thing:=pardon;
        n:=f5_does; callverb(n[1]);
     end;
  1: callverb(vb_pause);
  2: callverb(vb_open);
  3: callverb(vb_look);
  4: callverb(vb_inv);
  5: begin
       if tr[1].xs=walk then tr[1].xs:=run
                        else tr[1].xs:=walk;
       newspeed;
     end;
 end;
end;

procedure do__objects;
begin;
 thinkabout(objlist[ddm_o.choicenum+1],a_thing);
end;

procedure do__people;
begin;
 thinkabout(people[ddm_o.choicenum+1],a_person);
 last_person:=people[ddm_o.choicenum+1];
end;

procedure do__with;
begin;
 thing:=thinks;

 if thinkthing then
 begin;

  inc(thing,49);

  if verbstr[ddm_o.choicenum+1]=vb_Give then
   person:=last_person
  else
   person:=#254;

 end else
 begin;
  case verbstr[ddm_o.choicenum+1] of
   #100: begin; thing:=#100; callverb(vb_buy); exit; end; { Beer }
   #101: begin; thing:= #50; callverb(vb_buy); exit; end; { Wine }
   #102: begin; thing:=#102; callverb(vb_buy); exit; end; { Whisky }
   #103: begin; thing:=#103; callverb(vb_buy); exit; end; { Cider }
   #104: begin; thing:=#107; callverb(vb_buy); exit; end; { Mead }
   #105: begin; thing:= #67; callverb(vb_buy); exit; end; { Onion (trader) }
   else
   begin;
    person:=thing;
    thing:=#254;
   end;
  end;
 end;
 callverb(verbstr[ddm_o.choicenum+1]);
end;

{$F- That's all. Now for the ...bar procs. }

procedure standard_bar; { Standard menu bar }
begin;
 ddm_m.init; ddm_o.init;
 with ddm_m do
 begin; { Set up menus }
  create('F','File','!',ddm__file,do__file); { same ones in map_bar, below, }
  create('G','Game',#34,ddm__game,do__game); { Don't forget to change the }
  create('A','Action',#30,ddm__action,do__action); { if you change them }
  create('O','Objects',#24,ddm__objects,do__objects); { here... }
  create('P','People',^Y,ddm__people,do__people);
  create('W','With',^Q,ddm__with,do__with);
  update;
 end;
end;

(*procedure map_bar; { Special menu bar for the map (screen 99) }
begin;
 ddm_m.init; ddm_o.init;
 with ddm_m do
 begin; { Set up menus }
  create('G','Game','#',ddm__game,do__game);
  create('F','File','!',ddm__file,do__test);
  create('M','Map','2',ddm__map,do__test);
  create('T','Town',#20,ddm__town,do__test);
  update;
 end;
end;*)

procedure checkclick; { only for when the menu's displayed }
begin;
 if mpress>0 then
 begin;
  if mpy>10 then
   with ddm_o do
    begin;
     if not ((firstlix) and
      ((mpx>=flx1*8) and (mpx<=flx2*8) and
      (mpy>=12) and (mpy<=fly))) then
     begin; { Clicked OUTSIDE the menu. }
      if menunow then wipe;
     end; { No "else"- clicking on menu has no effect (only releasing) }
    end else
   begin; { Clicked on menu bar }
    ddm_m.getmenu(mpx);
   end;
 end else
 begin; { NOT clicked button... }
  if mrelease>0 then
  begin;
   with ddm_o do
    if (firstlix) and
     ((mrx>=flx1*8) and (mrx<=flx2*8) and
     (mry>=12) and (mry<=fly)) then
      select((mry-13) div 10);
  end;
 end;
end;

procedure menu_link;
begin;
 with ddm_o do
 begin;
  if not menunow then exit;

  check; { find mouse coords & click information }
  checkclick; { work out click codes }

  { Change arrow... }

  case my of
     0.. 10: newpointer(1); { up-arrow }
    11..169: begin;
              if (mx>=flx1*8) and (mx<=flx2*8) and (my>10) and (my<=fly) then
               newpointer(3) { right-arrow }
              else newpointer(4); { fletch }
             end;
   169..200: newpointer(2); { screwdriver }
  end;

  if not menunow then exit;

  lightup;
 end;
end;

end.