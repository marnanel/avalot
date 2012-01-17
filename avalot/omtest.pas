program oopmenutest;
uses Graph,Oopmenu,Rodent,Crt,Enhanced;
var
 st:string[5];
 fv:byte;

procedure graphics;
 var gd,gm:integer; begin; gd:=3; gm:=0; initgraph(gd,gm,''); end;

{$F+ ... All ddm__procs and do__procs must be compiled in Far-Call state. }

procedure ddm__file;
begin;
 with o do
 begin;
  start_afresh;
  opt('Load...','L','f3',true);
  opt('Save...','S','f2',false);
  opt('Save As...','A','ctrl-f2',false);
  opt('OS Shell...','O','f2',true);
  opt('Untrash screen','U','f11',true);
  display;
 end;
end;

procedure ddm__heart;
begin;
 with o do
 begin;
  start_afresh;
  opt('About...','A','shift-f10',true);
  opt('Boss Key','B','alt-B',true);
  opt('Help...','H','f1',true);
  opt('Status screen','S','f12',true);
  opt('Quit','Q','f10',true);
  display;
 end;
end;

procedure ddm__Action;
begin;
 with o do
 begin;
  start_afresh;
  opt('Get up','G','',true);
  opt('Open door','O','',true);
  opt('Pause game','P','',true);
  opt('Look around','L','',true);
  opt('Inventory','I','Tab',true);
  opt('Do the boogie','b','',true);
  display;
 end;
end;

procedure ddm__Objects;
begin;
 with o do
 begin;
  start_afresh;
  opt('Bell','B','',true);
  opt('Wine','W','',true);
  opt('Chastity Belt','C','',true);
  opt('Crossbow Bolt','t','',true);
  opt('Crossbow','r','',true);
  opt('Potion','P','',true);
  display;
 end;
end;

procedure ddm__People;
begin;
 with o do
 begin;
  start_afresh;
  opt('Avalot','A','',true);
  opt('Spludwick','S','',true);
  opt('Arkata','k','',true);
  opt('Dogfood','D','',true);
  opt('Geida','G','',true);
  display;
 end;
end;

procedure ddm__Use;
begin;
 with o do
 begin;
  start_afresh;
  opt('Drink','D','',true);
  opt('Wear','W','',true);
  opt('Give to [du Lustie]','G','',true);
  display;
 end;
end;

procedure do__stuff;
var st:string[2];
begin;
 str(o.choicenum+1,st);
 setfillstyle(1,6); setcolor(14);
 bar(0,177,640,200);
 outtextxy(320,177,'You just chose: '+st);
end;

procedure do__heart;
begin;
 case o.choicenum of
  0: outtextxy(100,100,'A really funny game!');
  1: outtextxy(100,120,'You ought to be working!');
  2: outtextxy(100,140,'No help available, so THERE!');
  3: outtextxy(100,160,'Everything''s COOL and FROODY!');
  4: halt;
 end;
end;

{$F- ... End of ddm__procs }

begin;
 graphics;
 setfillstyle(6,6); bar(0,0,639,199);
 resetmouse;
 m.Init; o.Init;
 with m do
 begin;
  create('H',#3,'#',ddm__heart,do__heart);
  create('F','File','!',ddm__file,do__stuff);
  create('A','Action',#30,ddm__action,do__stuff);
  create('O','Objects',#24,ddm__objects,do__stuff);
  create('P','People',^Y,ddm__people,do__stuff);
  create('W','With',^Q,ddm__use,do__stuff);
  update;
 end;
 repeat
  showmousecursor;
  repeat
   getbuttonpressinfo(1);
   getbuttonreleaseinfo(1);
   getbuttonstatus;
   with o do if menunow then o.lightup;
  until (buttonpresscount>0) or (buttonreleasecount>0) or keypressede;
  hidemousecursor;
  if buttonpresscount>0 then
  begin;
   if mousey>10 then
    with o do
     begin;
      if not ((o.firstlix) and
       ((mousex>=flx1) and (mousex<=flx2) and
       (mousey>=12) and (mousey<=fly))) then
      begin; { Clicked OUTSIDE the menu. }
       if o.menunow then wipe;
       setcolor(2); for fv:=1 to 17 do circle(mousex,mousey,fv*3);
       setcolor(0); for fv:=1 to 17 do circle(mousex,mousey,fv*3);
      end;
     end else
    begin; { Clicked on menu bar }
     m.getmenu(mousex);
    end;
  end else
  begin; { NOT clicked button... }
   if buttonreleasecount>0 then
   begin;
    with o do
     if (firstlix) and
      ((mousex>=flx1) and (mousex<=flx2) and
      (mousey>=12) and (mousey<=fly)) then
       select((mousey-14) div 10);
   end else
   begin; { NOT clicked or released button, so must be keypress }
    readkeye;
    parsekey(inchar,extd);
   end;
  end;
 until false;
end.