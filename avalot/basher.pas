{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 BASHER           Handles the keyboard. }

unit Basher;

 { Note: this unit can record keystrokes, for the demo. If you want it
   to do this, define the o.c.c. RECORD. Setting gyro.demo to True will
   cause them to be played back. }

interface

uses Gyro,Tommys;

{$IFDEF RECORD}
var
 count:word;
{$ENDIF}

 procedure plottext;

 procedure keyboard_link;

 procedure cursor_on;

 procedure get_demorec;

 function demo_ready:boolean;

 procedure cursor_off;

 procedure filename_edit;
 procedure normal_edit;
{$IFDEF RECORD}
  procedure record_one;
{$ENDIF}

implementation

uses Enhanced,Lucerna,Graph,Scrolls,Acci,Trip5,Pingo,Dropdown,Logger,
 Sticks,Enid;

var
 entering_filename:boolean;
 left_margin:byte;

procedure plottext;
const p: array[0..2] of byte = (0,1,3);
var x,y,n:byte;
begin
 x:=0; if mouse_near_text then Super_Off;
 cursor_off;
 for n:=0 to 2 do
  for y:=0 to 7 do
  begin
   for x:=1 to length(current) do
    mem[$A000:p[n]*pagetop+12882+y*80+x]:=little[current[x],y];
   fillchar(mem[$A000:p[n]*pagetop+12883+y*80+x],77-x,#0);
  end;
 cursor_on;
 Super_On;
end;

procedure wipetext;
const n:array[0..2] of byte = (0,1,3);
var y,p:byte;
begin
 if mouse_near_text then Super_Off;
 cursor_off;
 for y:=0 to 7 do
  for p:=0 to 2 do
   fillchar(mem[$A000:n[p]*pagetop+12883+y*80],77,#0);
 quote:=true; curpos:=1; cursor_on;
 Super_On;
end;

(*procedure cursor;
begin
 if curflash=0 then
 begin
  if mouse_near_text then Super_Off;
  cursoron:=not cursoron;
  mem[$A000:13442+curpos]:=not mem[$A000:13442+curpos];
  mem[$A000:pagetop+13442+curpos]:=not mem[$A000:pagetop+13442+curpos];
  curflash:=17;
  Super_On;
 end else dec(curflash);
end;*)

procedure do_cursor;
var
 bf:bytefield;
 fv:byte;
begin
 mem[$AC00:13442+curpos]:=not mem[$AC00:13442+curpos];
 with bf do
 begin
  x1:=curpos+1; x2:=curpos+2; y1:=168; y2:=168;
 end;
 for fv:=0 to 1 do getset[fv].remember(bf);
end;

procedure cursor_on;
begin
 if cursoron then exit;
 do_cursor; cursoron:=true;
end;

procedure cursor_off;
begin
 if not cursoron then exit;
 do_cursor; cursoron:=false;
end;


procedure get_demorec;
begin
 read(demofile,demo_rec);
 inchar:=demo_rec.key;
   extd:=demo_rec.extd;
   dec(demo_rec.delay);
end;

{$IFDEF RECORD}
  procedure record_one;
  begin
   demo_rec.delay:=count;
   demo_rec.key:=inchar;
   demo_rec.extd:=extd;

   write(demofile,demo_rec);
   count:=0;
  end;
{$ENDIF}
(*
procedure storeline(whatwhat:string);
var
 fv:byte;
 what:string[77];
 ok:boolean;

  function upline(x:string):string;
  var fv:byte; n:string[77];
  begin
   for fv:=1 to length(x) do n[fv]:=upcase(x[fv]);
   n[0]:=x[0]; upline:=n;
  end;
begin

 what:=upline(whatwhat); ok:=false;
 for fv:=1 to 20 do
  if what=upline(previous^[fv]) then
  begin { it already exists, in string "fv" }
   move(previous^[fv+1],previous^[fv],(20-fv)*78);
   previous^[20]:=whatwhat; ok:=true;
  end;
 if ok then exit;
 { it's not on the list, so add it }
 move(previous^[2],previous^[1],1482); { shove up }
 previous^[20]:=whatwhat;
end;
*)
procedure typein;
var w:byte;
  function firstchar(x:string):char; begin firstchar:=x[1]; end;
  procedure try_dd; { This asks the Parsekey proc in Dropdown if it knows it. }
  begin
   parsekey(inchar,extd);
  end;
begin
 inkey;
 {$IFDEF RECORD} record_one; {$ENDIF}

 case inchar of
  #32..#46,#48..#223,#225..#255: if ddm_o.menunow then
             begin
              parsekey(inchar,extd);
             end else
             begin
              if length(current)<76 then
              begin
               if (inchar='"') or (inchar='`') then
               begin
                if quote then inchar:='`' else inchar:='"';
                quote:=not quote; { Quote- Unquote... }
               end;
               insert(inchar,current,curpos);
               inc(curpos);
               plottext;
              end else blip;
             end;
  #8: if not ddm_o.menunow then
      begin
       if curpos>left_margin then
       begin
        dec(curpos);
        if current[curpos] in ['"','`'] then quote:=not quote;
        delete(current,curpos,1);
        plottext;
       end else blip;
      end;
  #0,#224: begin
       case extd of
              { Function keys: }
        cf1: callverb(vb_help); { f1 - help (obviously) }
        cf2: fxtoggle; { f2 - sound }
        ccf2,cf11: begin clearwords; callverb(vb_save); end; { ^f2 - save }
        cf3: if length(current)<length((*previous^[20]*)last) then { f3 - rec last }
             begin
              current:=current+copy((*previous^[20]*)last,length(current)+1,255);
              curpos:=length(current)+1;
              plottext;
             end;
        ccf3,cf12: begin clearwords; callverb(vb_load); end; { ^f3 - load }
        cf4: callverb(vb_restart); { f4 - restart game }
        cf5: begin
                person:=pardon; thing:=pardon;
                callverb(firstchar(f5_does)); { f5 - get up/ whatever }
             end;
        cf6: callverb(vb_pause); { f6 - pause }
        cf7: callverb(vb_open); { f7 - open door }
        cf8: callverb(vb_look); { f8 - look }
        cf9: callverb(vb_score); { f9 - score }
        ccf7: major_redraw; { ^f7 - open door }
        cf10,c_aX,caf4: begin
                      {$IFDEF RECORD}
                       display('Hi. You have just finished recording. GIED.');
                       close(demofile); halt;
                      {$ENDIF}
                       callverb(vb_quit); { f10, alt-X, alt-f4 - quit }
                     end;
        ccf5: back_to_bootstrap(2); { ^f5 - Dos shell. }
        csf10: callverb(vb_info); { sf10 - version }

        c_aB: callverb(vb_boss); { alt-B }
        c_aD: display('Wrong game!'); { alt-D }
        ccLeft: if curpos>left_margin then
              begin cursor_off; dec(curpos); cursor_on; end; { ^left }
        ccRight: if curpos<=length(current) then { ^right }
              begin cursor_off; inc(curpos); cursor_on; end;
        ccHome: begin cursor_off; curpos:=1; cursor_on; end; { ^home }
        ccEnd: begin cursor_off; curpos:=length(current)+1; cursor_on; end; { ^end }
        c_aR: oh:=177; { alt-R = repeater (re-chime) }
        cUp,cDown,cLeft,cRight,cPgUp,cPgDn,cHome,cEnd: if ddm_o.menunow then try_dd
              else tripkey(extd); { Up/Down/Left/Right/PgUp/PgDn }
        cNum5: tripkey(extd); { Numeric 5 }
        cDel: if not ddm_o.menunow then
             begin
              if curpos<=length(current) then
              begin
               if current[curpos] in ['"','`'] then quote:=not quote;
               delete(current,curpos,1);
               plottext;
              end else blip;
             end;
        else try_dd;
       end;
      end;
  cEscape,'/': if ddm_o.menunow then { Escape }
           begin ddm_o.wipe; end else
            if entering_filename then
              begin normal_edit; wipetext; end else
                ddm_m.getcertain(ddm_o.menunum);
  cReturn: if ddm_o.menunow then try_dd { Return }
       else begin
        log_command(current);
        if entering_filename then
        begin
          edna_save(copy(current,24,255));
          normal_edit; wipetext;
        end else
        begin
          if current<>'' then last:=current;
          parse; do_that;
          if not entering_filename then
          begin
            current:='';
            wipetext;
          end;
        end;
       end;
  ^I: callverb(vb_inv); { Ctrl-I= inventory }
  ^G: errorled;
  ^U: begin
       current:='';
       wipetext;
      end;

  ^W: begin tr[1].xs:=walk; newspeed; end;
  ^R: begin tr[1].xs:=run;  newspeed; end;

  ^B: bosskey;
  ^J: ctrl:=cJoy; { Joystick }
  ^K: ctrl:=cKey; { Keyboard }
  ^C: callverb(vb_quit); { Ctrl-C= request to quit }

 end;
 showrw;

 if demo then get_demorec;
end;

(*        'x'..'z': begin setvisualpage(ord(extd)-63); write(#7); inkey; end;
        'Å': begin setvisualpage(0); write(#7); inkey; end;*)

procedure keyboard_link;
begin
 state(defaultled); (* if defaultled=1 then on; { For the menus }*)
 joykeys; { Test joystick buttons- I know that's not keyboard. }

 if demo then
 begin
  if keypressede then halt;
  if demo_rec.delay>0 then
   dec(demo_rec.delay)
  else typein;
  exit;
 end;

 {$IFDEF RECORD} inc(count); {$ENDIF}

 if not keypressede then exit;
 if keyboardclick then click;
 typein;
end;

function demo_ready:boolean;
begin
 if demo_rec.delay>0 then
 begin
  slowdown;
  dec(demo_rec.delay);
 end;
 demo_ready:=demo_rec.delay=0;
end;

procedure filename_edit;
begin
 entering_filename:=true;
 current:='Filename? (Esc=cancel):';
 left_margin:=24; curpos:=24;
 plottext;
end;

procedure normal_edit;
begin
 entering_filename:=false;
 current:='';
 left_margin:=1; curpos:=1;
end;

begin
(* new(previous);*) last:=''; normal_edit;

 if demo then
 begin
  assign(demofile,'demo.avd');
  reset(demofile);
 end;

 {$IFDEF RECORD}
  count:=0;
  assign(demofile,'demo.avd');
  rewrite(demofile);
 {$ENDIF}

end.