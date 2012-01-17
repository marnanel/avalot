unit oopmenu;

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
            procedure displayopt(y,b,f,d:byte);
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
            procedure getmenu(x:integer);
           end;


var
 o:onemenu;
 m:menuset;
 kbuffer:string;

  procedure parsekey(r,re:char);

implementation

uses Crt,Graph,Rodent,Dos;

const

 indent = 40;
 spacing = 83;

 menu_b = blue;
 menu_f = yellow;
 menu_border = black;
 highlight_b = lightblue;
 highlight_f = yellow;
 disabled = lightgray;

(* menu_b = lightgray;
 menu_f = black;
 menu_border = black;
 highlight_b = black;
 highlight_f = white;
 disabled = darkgray;*)

{ Built-in mouse routine }

var
 r:char;
 fv:byte;

procedure chalk(x,y:integer; t:char; z:string);
var p:byte;
begin;
 outtextxy(x,y,z);
 p:=pos(t,z); if p=0 then exit; dec(p);
 outtextxy(x+p*8,y+1,'_');
end;

procedure say(x,y:integer; t:char; z:string; f,b:byte);
begin;
 settextjustify(0,2); setfillstyle(1,b); setcolor(f);
 bar(x-3,y-1,x+textwidth(z)+3,y+textheight(z)+1);
 chalk(x,y,t,z);
end;

procedure mblit(x1,y1,x2,y2:integer; f,t:byte); { NOT The Minstrel Blitter }
var p,q:pointer; s:word;
begin;
 mark(q);
 s:=imagesize(x1,y1,x2,y2); getmem(p,s);
 setactivepage(f); getimage(x1,y1,x2,y2,p^);
 setactivepage(t); putimage(x1,y1,p^,0);
 setactivepage(0); release(q);
end;

procedure onemenu.start_afresh;
begin;
 number:=0; width:=0; firstlix:=false; oldy:=0; highlightnum:=0;
end;

constructor onemenu.Init;
begin;
 menunow:=false;
end;

procedure onemenu.opt(n:string; tr:char; key:string; val:boolean);
var l:integer;
begin;
 inc(number);
 l:=textwidth(n+key)+30; if width<l then width:=l;
 with oo[number] do
 begin;
  title:=n;
  trigger:=tr;
  shortcut:=key;
  valid:=val;
 end;
end;

procedure onemenu.displayopt(y,b,f,d:byte);
begin;
 with oo[y] do
 begin;
  if valid then setcolor(f) else setcolor(d);
  if b<>177 then
  begin;
   setfillstyle(1,b);
   bar(flx1,3+y*10,flx2,12+y*10);
  end;
  settextjustify(2,2);
   if shortcut>'' then outtextxy(flx2,4+y*10,shortcut);
  settextjustify(0,2);
   chalk(left+3,4+y*10,trigger,title);
 end;
end;

procedure onemenu.display;
var y:byte;
begin;
 setfillstyle(1,menu_b); setcolor(menu_border);
 firstlix:=true;
 flx1:=left-2; flx2:=left+width; fly:=14+number*10;
 mblit(flx1-3,11,flx2+1,fly+1,0,1);
 menunow:=true;

 bar(flx1,12,flx2,fly);
 rectangle(flx1-1,11,flx2+1,fly+1);

 setcolor(menu_f); settextjustify(0,2);
 displayopt(1,highlight_b,highlight_f,177);
 for y:=2 to number do
  with oo[y] do displayopt(y,177,menu_f,disabled);
end;

procedure onemenu.wipe;
begin;
 with m.ddms[o.menunum] do say(flx1+2,1,trigger,title,menu_f,menu_b);
 mblit(flx1-3,11,flx2+1,fly+1,1,0);
 menunow:=false; firstlix:=false;
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
 hidemousecursor;
 displayopt(oldy+1,menu_b,menu_f,disabled);
 displayopt(highlightnum+1,highlight_b,highlight_f,disabled);
 showmousecursor;
 oldy:=highlightnum;
end;

procedure onemenu.lightup; { This makes the menu highlight follow the mouse.}
begin;
 if (mousex<flx1) or (mousex>flx2)
  or (mousey<=12) or (mousey>fly-3) then exit;
 highlightnum:=(mousey-12) div 10;
 if highlightnum=oldy then exit;
 movehighlight(0);
end;

procedure onemenu.select(n:byte); { Choose which one you want. }
begin;
 if not oo[n+1].valid then exit;
 choicenum:=n;
 m.ddms[menunum].do_choose;
 wipe;
end;

procedure onemenu.keystroke(c:char);
var fv:byte;
begin;
 c:=upcase(c);
 for fv:=1 to number do
  if upcase(oo[fv].trigger)=c then select(fv-1);
end;

procedure bleep;
begin;
 sound(177); delay(7); nosound;
end;

  constructor headtype.Init
   (trig,alttrig:char; name:string; p:byte; dw,dc:proc);
  begin;
   trigger:=trig; alttrigger:=alttrig; title:=name;
   position:=p; xpos:=(position-1)*spacing+indent;
   xright:=xpos+textwidth(name)+3;
   do_setup:=dw; do_choose:=dc;
  end;

  procedure headtype.display;
  begin;
   say(xpos,1,trigger,title,menu_f,menu_b);
  end;

  procedure headtype.highlight;
  begin;
   say(xpos,1,trigger,title,highlight_f,highlight_b);
   with o do
   begin;
    left:=xpos;
    menunow:=true; menunum:=position;
   end;
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
  var fv:byte;
  begin;
   setfillstyle(1,menu_b); bar(0,0,640,10);
   for fv:=1 to howmany do ddms[fv].display;
  end;

  procedure menuset.extd(c:char);
  var fv:byte;
  begin;
   fv:=1;
   while (fv<=howmany) and (ddms[fv].extdparse(c)) do inc(fv);
   if fv>howmany then exit; getmenu(fv*spacing-indent);
  end;

  procedure menuset.getmenu(x:integer);
  var fv:byte;
  begin;
   fv:=0;
   repeat
    inc(fv);
    if (x>ddms[fv].xpos-3) and (x<ddms[fv].xright) then
     with ddms[fv] do
      with o do
      begin;
       if (menunow) then
       begin;
        wipe; { get rid of menu }
        if (menunum=position) then exit; { click on own highlight }
       end;
       highlight; do_setup;
       exit;
      end;
   until fv>howmany;
  end;

procedure parsekey(r,re:char);
begin;
 with o do
  case r of
   #0: begin;
        case re of
         'K': begin;
               wipe;
               m.getmenu((menunum-2)*spacing+indent);
              end;
         'M': begin;
               wipe;
               m.getmenu((menunum*spacing+indent));
              end;
         'H': movehighlight(-1);
         'P': movehighlight(1);
         else m.extd(re);
         end;
        end;
   #27: if menunow then wipe;
   #13: select(o.highlightnum);
   else
   begin;
    if menunow then keystroke(r) else
     kbuffer:=kbuffer+r+re;
   end;
  end;
end;

end.