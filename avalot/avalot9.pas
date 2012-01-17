{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 AVALOT           The kernel of the program. }

program Avalot;
uses Graph,Crt,Trip5,Gyro,Lucerna,Scrolls,Basher,Dropdown,Pingo,
 Logger,Timeout,Celer,Enid,Incline,Closing,Visa;

procedure setup;
var
 gd,gm:integer;
begin
 checkbreak:=false; visible:=m_No; to_do:=0; lmo:=false; resetscroll;
 randomize; setup_vmc; on_Virtual;
 gd:=3; gm:=0; initgraph(gd,gm,'');
 HoldTheDawn:=true; dusk;
 cmp:=177; mouse_init; (*on;*) dropsOK:=true; ctrl:=cKey; oldjw:=177;
 mousetext:=''; c:=999; settextjustify(0,0); ddmnow:=false; load_digits;
 cheat:=false; cp:=0; curpos:=1; 
 quote:=true; ledstatus:=177; defaultled:=2;
(* TSkellern:=0; { Replace with a more local variable sometime }*)
 dna.rw:=stopped; enid_Filename:=''; { undefined. }
 toolbar; state(2); copy03; lastscore:='TJA';

(* for gd:=0 to 1 do
 begin
  setactivepage(gd); outtextxy(7,177,chr(48+gd));
 end;*)

 loadtrip;

 if (filetoload='') and (not reloaded) then
  newgame { no game was requested- load the default }
 else begin
  if not reloaded then avvy_background;
  standard_bar; sprite_run;
  if reloaded then edna_reload else
  begin { Filename given on the command line (or loadfirst) }
   edna_load(filetoload);
   if there_was_a_problem then
   begin
    display('So let''s start from the beginning instead...');
    HoldTheDawn:=true; dusk; newgame;
   end;
  end;
 end;

 if not reloaded then
 begin
  soundfx:=not soundfx; fxtoggle;
  thinkabout(money,a_thing);
 end;

 get_back_Loretta; gm:=getpixel(0,0); setcolor(7);
 HoldTheDawn:=false; dawn; cursoron:=false; cursor_on; newspeed;

 if not reloaded then
   dixi('q',83); { Info on the game, etc. }
end;

begin
 setup;

 repeat

  clock;
  keyboard_link;
  menu_link;
  readstick;
  force_numlock;
  get_back_Loretta;
  trippancy_link;
  pics_link;
  checkclick;

  if visible=M_Virtual then plot_vmc(mx,my,cp);
  flip_page; { <<<! }
  slowdown;
  if visible=M_Virtual then wipe_vmc(cp);

  one_tick;

 until lmo;

 restorecrtmode;
 if logging then close(logfile);

 end_of_program;
end.

(*  typein; commanded; last:=current; *)
