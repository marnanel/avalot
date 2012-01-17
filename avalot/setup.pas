program setup;
uses Crt,Tommys,Joystick;

const
 selected = $60; { Background for selected lines of text. }

type
 mobytype = array[1..400] of string[80];

 byteset = set of byte; { Define its typemark. }

 option  = (_OVERRIDEEGACHECK, _ZOOMYSTART, _LOADFIRST, _NUMLOCKHOLD, _USEMOUSE,
            _CONTROLLER, _LOGGING, _LOGFILE,

            _JOYSTICKINSTALLED, _JOYTOP, _JOYBOTTOM, _JOYLEFT, _JOYRIGHT, _JOYMIDX,
            _JOYMIDY, _JOYCENTRINGFACTOR, _WHICHJOY, _QUIET, _SOUNDCARD,
            _BASEADDRESS, _IRQ, _DMA,
            _SAMPLERATE, _KEYBOARDCLICK,

            _PRINTER,

            Option_Error);


var
 moby:^mobytype;
 mobylength:word;
 background:byte; { The current background colour, times 16. }
 line:byte; { Which line you're on in the menus. }

 registrant,reginum:string;

 num_printers:byte;
 printers:array[1..10] of string;
 this_printer:string;

 { THE STATUS VARIABLES: }

   { general }

 override_ega:boolean;
 skip_loading_screens:boolean;
 load_particular:string;
 force_numlock:boolean;
 ignore_mouse:boolean;
 use_keyboard:boolean;
 log_to_printer:boolean;
 log_to_file:boolean;
 log_filename:string;
 autotype:string;

   { joystick }

 has_a_joystick:boolean;
 jtop,jbottom,jleft,jright,jmidx,jmidy:word;
 jcentre:byte;
 whichjoy:word;

   { sound }

 suppress_sfx:boolean;
 your_card:byte;
 samplerate:longint;
 sound_addr,sound_irq,sound_dma:longint;
 wants_keyclick:boolean;

  { registration }

 regname,regnum,chkname,chknum:string;


function trim_and_caps(this:string):string;
var fv:byte;
begin
 while (this[1]=' ') and (this<>'') do
                      delete(this,1,1);         { Strip leading blanks. }
 while (this[length(this)]=' ') and (this<>'') do
                      dec(this[0]);             { Strip trailing blanks. }
 for fv:=1 to length(this) do this[fv]:=upcase(this[fv]);{ And capitalise. }
 trim_and_caps:=this;
end;

function string_2_option(field:string):option;
begin

 field:=trim_and_caps(field);

 if field='OVERRIDEEGACHECK' then string_2_option:=_overrideegacheck else
 if field='ZOOMYSTART' then       string_2_option:=_zoomystart       else
 if field='LOADFIRST' then        string_2_option:=_loadfirst        else
 if field='NUMLOCKHOLD' then      string_2_option:=_numlockhold      else
 if field='USEMOUSE' then         string_2_option:=_usemouse         else
 if field='CONTROLLER' then       string_2_option:=_controller       else
 if field='LOGGING' then          string_2_option:=_logging          else
 if field='LOGFILE' then          string_2_option:=_logfile          else

  { joystick }

 if field='JOYSTICKINSTALLED' then string_2_option:=_joystickinstalled else
 if field='JOYTOP' then            string_2_option:=_joytop            else
 if field='JOYBOTTOM' then         string_2_option:=_joybottom         else
 if field='JOYLEFT' then           string_2_option:=_joyleft           else
 if field='JOYRIGHT' then          string_2_option:=_joyright          else
 if field='JOYMIDX' then           string_2_option:=_joymidx           else
 if field='JOYMIDY' then           string_2_option:=_joymidy           else
 if field='JOYCENTRINGFACTOR' then string_2_option:=_joycentringfactor else
 if field='WHICHJOY' then          string_2_option:=_whichjoy          else

  { sound }

 if field='QUIET' then             string_2_option:=_quiet             else
 if field='SOUNDCARD' then         string_2_option:=_soundcard         else
 if field='SAMPLERATE' then        string_2_option:=_samplerate        else
 if field='KEYBOARDCLICK' then     string_2_option:=_keyboardclick     else
 if field='BASEADDRESS' then       string_2_option:=_baseaddress       else
 if field='IRQ' then               string_2_option:=_irq               else
 if field='DMA' then               string_2_option:=_dma               else

  { printer }

 if field='PRINTER' then           string_2_option:=_printer           else


   string_2_option:=Option_Error;

end;

procedure clear_to(colour:byte);
begin
 window(1,1,80,24); background:=colour*16; textattr:=background; clrscr;
end;

procedure centre(where,colour:byte; what:string);
begin
 textattr:=background+colour;
 gotoxy(40-length(what) div 2,where);
 write(what);
end;

procedure load_file;
var
 t:text;
begin
 mobylength:=0;
 {$I-}
 assign(t,'avalot.ini');
 reset(t);
 {$I+}

 if ioresult<>0 then { No file. }
 begin
  writeln('SETUP: Avalot.ini not found!');
  halt(255);
 end;

 while not eof(t) do
 begin
  inc(mobylength); { Preincrement mode. }
  readln(t,moby^[mobylength]);
 end;

 close(t);

end;

function strhf(x:longint):string;  { assume x is +ve }
const hexdigits : array[0..16] of char = '0123456789ABCDEF';
var y:string; v:longint;
begin
   v:=x; y:='';

   while v<>0 do
   begin
      y:=hexdigits[v mod 16]+y;
      v:=v div 16;
   end;

   strhf:='$'+y;
end;

procedure update_moby;
var
 fv:byte;
 field:string;
 o:option;

   procedure get_field(x:string);
   begin
       if pos(';',x)<>0 then x:=copy(x,1,pos(';',x)-1);

       if pos('=',x)=0 then
           field:=''
       else
       begin
           field:=copy(x,0,pos('=',x)-1);
           while field[1]=' ' do field:=copy(field,2,255);
       end;
   end;

   function yn(x:boolean):string;
    begin if x then yn:='Yes' else yn:='No'; end;

   function kj(x:boolean):string;
    begin if x then kj:='Keyboard' else kj:='Joystick'; end;

   function put_logcodes:string;
   var q:byte;
   begin
       q:=byte(log_to_file)+byte(log_to_printer)*2;

       case q of
           0: put_logcodes:='No';
           1: put_logcodes:='Disk';
           2: put_logcodes:='Printer';
       end;
   end;

   function card:string;
   begin
      case your_card of
          0: card:='None';
          1: card:='SB';
          2: card:='SBPro';
          3: card:='SB16';
          4: card:='Pas';
          5: card:='PasPlus';
          6: card:='Pas16';
          7: card:='Aria';
          8: card:='WinSound';
          9: card:='Gravis';
         10: card:='DacLPT';
         11: card:='StereoDacs';
         12: card:='StereoOn1';
         13: card:='Speaker';
      end;
   end;


   procedure entail(x:string);
   var before,after:string;
   begin
    before:=copy(moby^[fv],1,pos('=',moby^[fv])-1);

    if pos(';',moby^[fv])=0 then
    begin
       moby^[fv]:=before+'='+x;
    end else
    begin
       after:=copy(moby^[fv],pos(';',moby^[fv]),255);

       moby^[fv]:=before+'='+x+' ';
       while length(moby^[fv])<25 do moby^[fv]:=moby^[fv]+' ';

       moby^[fv]:=moby^[fv]+after;
    end;
   end;



begin

    for fv:=1 to mobylength do
    begin
      get_field(moby^[fv]);

      if field<>'' then
      begin
       o:=string_2_option(field);

       if o=_OVERRIDEEGACHECK then entail(yn(override_ega)) else
       if o=_ZOOMYSTART then entail(yn(skip_loading_screens)) else
       if o=_LOADFIRST then entail(load_particular) else
       if o=_NUMLOCKHOLD then entail(yn(force_numlock)) else
       if o=_USEMOUSE then entail(yn(ignore_mouse)) else
       if o=_CONTROLLER then entail(kj(use_keyboard)) else
       if o=_LOGGING then entail(put_logcodes) else
       if o=_LOGFILE then entail(log_filename) else

        { joystick }

       if o=_JOYSTICKINSTALLED then entail(yn(has_a_joystick)) else
       if o=_JOYTOP then entail(strf(jtop)) else
       if o=_JOYBOTTOM then entail(strf(jbottom)) else
       if o=_JOYLEFT then entail(strf(jleft)) else
       if o=_JOYRIGHT then entail(strf(jright)) else
       if o=_JOYMIDX then entail(strf(jmidx)) else
       if o=_JOYMIDY then entail(strf(jmidy)) else
       if o=_JOYCENTRINGFACTOR then entail(strf(jcentre)) else
       if o=_WHICHJOY then entail(strf(whichjoy)) else

        { sound }

       if o=_QUIET then entail(yn(suppress_sfx)) else
       if o=_SOUNDCARD then entail(card) else
       if o=_SAMPLERATE then entail(strf(samplerate)) else
       if o=_BASEADDRESS then entail(strhf(sound_addr)) else
       if o=_IRQ then entail(strf(sound_irq)) else
       if o=_DMA then entail(strf(sound_dma)) else
       if o=_KEYBOARDCLICK then entail(yn(wants_keyclick)) else

        { printer }

       if o=_PRINTER then entail(this_printer);

      end;
    end;
end;

procedure save_file;
var
 t:text;
 fv:word;
begin
 textattr:=10;
 update_moby;

 clear_to(black);
 centre(14,14,'Saving...');

 assign(t,'avalot.ini');
 rewrite(t);

 for fv:=1 to mobylength do
 begin
  writeln(t,moby^[fv]);
 end;

 close(t);
end;

function detect:boolean;
var
 x,y,xo,yo:word;
 count:byte;
begin
 count:=0;
 if joystickpresent then
 begin
  detect:=true;
  exit;
 end;
 readjoya(xo,yo);
 repeat
  if count<7 then inc(count); { Take advantage of "flutter" }
  if count=6 then
  begin
   centre(7,1,'The Bios says you don''t have a joystick. However, it''s often wrong');
   centre(8,1,'about such matters. So, do you? If you do, move joystick A to');
   centre(9,1,'continue. If you don''t, press any key to cancel.');
  end;
  readjoya(x,y);
 until (keypressed) or (x<>xo) or (y<>yo);
 detect:=not keypressed;
end;

procedure display;
begin
 gotoxy(28,10); write(jleft,'  ');
 gotoxy(28,11); write(jright);
 gotoxy(28,12); write(jtop,'  ');
 gotoxy(28,13); write(jbottom);
end;

procedure readjoy(var x,y:word);
begin
 if whichjoy=1 then readjoya(x,y) else readjoyb(x,y);
end;

procedure getmaxmin;
var x,y:word; r:char;
begin
 clear_to(green);
 centre(5,1,'Rotate the joystick around in a circle, as far from the centre as it');
 centre(6,1,'can get. Then press any key.');
 centre(7,1,'Press Esc to cancel this part.');
 centre(16,1,'(To reset these figures, set "Do you have a joystick?" to No, then Yes.)');

 gotoxy(20,10); write('Left  :');
 gotoxy(20,11); write('Right :');
 gotoxy(20,12); write('Top   :');
 gotoxy(20,13); write('Bottom:');


 if jleft=0 then jleft:=maxint;
 if  jtop=0 then  jtop:=maxint;
 repeat
  readjoy(x,y);
  if x<jleft then jleft:=x;
  if y<jtop then jtop:=y;
  if x>jright then jright:=x;
  if y>jbottom then jbottom:=y;
  display;
 until keypressed;

 repeat r:=readkey until not keypressed;
 if r=#27 then exit;

 centre(19,1,'Thank you. Now please centre your joystick and hit a button.');
 repeat until (buttona1 or buttona2);

 readjoya(jmidx,jmidy);

 has_a_joystick:=true;
end;

procedure joysetup;
begin
 clear_to(green);
 if not detect then exit;
 getmaxmin;
end;

function choose_one_of(which:byteset):byte;

const
 upwards=-1;
 downwards=1;

var
 done:boolean;
 r:char;
 direction:shortint;

  procedure move(d:shortint);
  begin
   direction:=d; line:=line+d;
  end;

  procedure highlight(where,how:word);
  var fv:byte;
  begin
   where:=where*160-159;
   for fv:=0 to 79 do
    mem[$B800:where+fv*2]:=(mem[$B800:where+fv*2] and $F)+how;
  end;

begin
 done:=false; direction:=1;
 repeat
  while not (line in which) do
  begin
   line:=line+direction;
   if line>26 then line:=1;
   if line=0 then line:=26;
  end;

  highlight(line,selected);
  r:=readkey;
  highlight(line,background);
  case r of
   #0: case readkey of
        cUp: move(upwards);
        cDown: move(downwards);
       end;
   cReturn: done:=true;
   cEscape: begin
             choose_one_of:=15; { bottom line is always 15. }
             exit;
            end;
  end;

 until done;

 choose_one_of:=line;
end;

procedure bottom_bar;
  procedure load_regi_info;
  var
   t:text;
   fv:byte;
   x:string;
   namelen,numlen:byte;
   namechk,numchk:string;

   function decode1(c:char):char;
   var b:byte;
   begin
     b:=ord(c)-32;
     decode1:=chr(( (b and $F) shl 3) + ((b and $70) shr 4));
   end;

   function decode2(c:char):char;
   begin
     decode2:=chr( (ord(c) and $F) shl 2 + $43);
   end;

   function checker(proper,check:string):boolean;
   var fv:byte; ok:boolean;
   begin
     ok:=true;
     for fv:=1 to length(proper) do
       if (ord(proper[fv]) and $F)<>((ord(check[fv])-$43) shr 2)
         then ok:=false;

     checker:=ok;
   end;

  begin
    {$I-}
    assign(t,'register.dat'); reset(t);
    {$I+}

    if ioresult<>0 then
    begin
      registrant:='';
      exit;
    end;

    for fv:=1 to 53 do readln(t);
    readln(t,x);
    close(t);

    namelen:=107-ord(x[1]); numlen:=107-ord(x[2]);

    registrant:=copy(x,3,namelen);
    reginum:=copy(x,4+namelen,numlen);
    namechk:=copy(x,4+namelen+numlen,namelen);
    numchk:=copy(x,4+namelen+numlen+namelen,numlen);

    for fv:=1 to namelen do registrant[fv]:=decode1(registrant[fv]);
    for fv:=1 to numlen do reginum[fv]:=decode1(reginum[fv]);

    if (not checker(registrant,namechk)) or (not checker(reginum,numchk))
     then begin registrant:='?"!?'; reginum:='(.'; end;
  end;
begin
 load_regi_info;
 textattr:=96; background:=96;
 window(1,1,80,25);
 gotoxy(1,25); clreol;
 if registrant='' then
   centre(25,15,'Unregistered copy.')
 else
   centre(25,15,'Registered to '+registrant+' ('+reginum+').');
end;

procedure new_menu;
begin
 line:=1; { now that we've got a new menu. }
end;

function two_answers(ans_true,ans_false:string; which:boolean):string;
begin
 if which then
  two_answers:=' ('+ans_true+')'
 else
  two_answers:=' ('+ans_false+')';
end;

function yes_or_no(which:boolean):string;
begin
 yes_or_no:=two_answers('yes','no',which);
end;

function give_name(what:string):string;
begin
 if what='' then
  give_name:=' (none)'
 else
  give_name:=' ("'+what+'")';
end;

function sound_card(which:byte):string;
begin
 case which of
  0: sound_card:='none';
  1: sound_card:='SoundBlaster';
  2: sound_card:='SoundBlaster Pro';
  3: sound_card:='SoundBlaster 16';
  4: sound_card:='Pro Audio Spectrum';
  5: sound_card:='Pro Audio Spectrum+';
  6: sound_card:='Pro Audio Spectrum 16';
  7: sound_card:='Aria';
  8: sound_card:='Windows Sound System or compatible';
  9: sound_card:='Gravis Ultrasound';
  10: sound_card:='DAC on LPT1';
  11: sound_card:='Stereo DACs on LPT1 and LPT2';
  12: sound_card:='Stereo-on-1 DAC on LPT';
  13: sound_card:='PC speaker';
 end;
end;

procedure get_str(var n:string);
var
 x:string;
 r:char;
begin
    clear_to(black);
    centre(3,3,'Enter the new value. Press Enter to accept, or Esc to cancel.');
    x:='';

    repeat

        r:=readkey;

        case r of
            cBackspace: if x[0]>#0 then dec(x[0]);
            cReturn: begin
                         n:=x;
                         exit;
                     end;
            cEscape: exit;

            else
                if x[0]<#70 then x:=x+r;
        end;


        centre(7,2,' '+x+' ');

    until false;

end;

procedure get_num(var n:longint);
var
 x:string;
 r:char;
 e:integer;
begin
    clear_to(black);
    centre(3,3,'Enter the new value. Press Enter to accept, or Esc to cancel.');
    centre(4,3,'Precede with $ for a hex value.');
    x:='';

    repeat

        r:=upcase(readkey);

        case r of
            cBackspace: if x[0]>#0 then dec(x[0]);
            cReturn: begin
                         val(x,n,e);
                         exit;
                     end;
            cEscape: exit;

            else
                if (x[0]<#70) and 
                  ((r in ['0'..'9']) or ((x[1]='$') and (r in ['A'..'F'])) or
                    ((x='') and (r='$')))
                then x:=x+r;
        end;


        centre(7,2,' '+x+' ');

    until false;

end;

procedure general_menu;
begin
 new_menu;
 repeat
  clear_to(blue);

  centre( 3,15,'General Menu');

  centre( 5, 7,'Override EGA check?'+yes_or_no(override_ega));
  centre( 6, 7,'Skip loading screens?'+yes_or_no(skip_loading_screens));
  centre( 7, 7,'Load a particular file by default?'+give_name(load_particular));
  centre( 8, 7,'Force NumLock off?'+yes_or_no(force_numlock));
(*  centre( 9, 7,'Ignore the mouse?'+yes_or_no(ignore_mouse));*)
  centre(10, 7,'Default controller?'+two_answers('keyboard','joystick',use_keyboard));
  centre(12, 7,'Log to printer?'+yes_or_no(log_to_printer));
  centre(13, 7,'Log to file?'+yes_or_no(log_to_file));
  centre(14, 7,'Filename to log to?'+give_name(log_filename));

  centre(15,15,'Return to main menu.');

  case choose_one_of([5,6,7,8,(*9,*)10,12,13,14,15]) of
    5: override_ega:=not override_ega;
    6: skip_loading_screens:=not skip_loading_screens;
    7: get_str(load_particular);
    8: force_numlock:=not force_numlock;
(*    9: ignore_mouse:=not ignore_mouse;*)
   10: use_keyboard:=not use_keyboard;
   12: begin
        log_to_printer:=not log_to_printer;
        if (log_to_file and log_to_printer) then log_to_file:=false;
       end;
   13: begin
        log_to_file:=not log_to_file;
        if (log_to_file and log_to_printer) then log_to_printer:=false;
       end;
   14: get_str(log_filename);
   15: begin new_menu; exit; end;
  end;

 until false;
end;

procedure joystick_menu;
begin
 new_menu;
 repeat
  clear_to(green);

  centre(3,15,'Joystick Menu');

  centre(5,14,'Do you have a joystick?'+yes_or_no(has_a_joystick));
  centre(6,14,'Which joystick to use? '+chr(whichjoy+48));
  centre(7,14,'Select this one to set it up.');

  centre(15,15,'Return to main menu');

  case choose_one_of([5,6,7,15]) of
    5: begin
        has_a_joystick:=not has_a_joystick;
        if not has_a_joystick then
         begin jleft:=0; jright:=0; jtop:=0; jbottom:=0; end;
       end;
    6: whichjoy:=3-whichjoy; { Flips between 2 and 1. }
    7: joysetup;
   15: begin new_menu; exit; end;
  end;

 until false;
end;

procedure cycle(var what:byte; upper_limit:byte);
begin
 if what=upper_limit then
  what:=0
 else
  inc(what);
end;

procedure sound_menu;
begin
 new_menu;
 repeat
  clear_to(cyan);

  centre(3, 0,'Sound menu');

  centre(5, 0,'Do you want to suppress sound effects?'+yes_or_no(suppress_sfx));
  centre(6, 0,'Sound output device? ('+sound_card(your_card)+')');
  centre(7, 0,'Sampling rate? ('+strf(samplerate)+'Hz)');
  centre(8, 0,'Base address? ('+strhf(sound_addr)+' *hex*)');
  centre(9, 0,'IRQ? ('+strf(sound_irq)+')');
  centre(10,0,'DMA? ('+strf(sound_dma)+')');
  centre(11,0,'Do you want keyclick?'+yes_or_no(wants_keyclick));

  centre(15,15,'Return to main menu');

  centre(17,1,'WARNING: Incorrect values of IRQ and DMA may damage your computer!');
  centre(18,1,'Read AVALOT.INI for the correct values.');

  case choose_one_of([5,6,7,8,9,10,11,15]) of
    5: suppress_sfx:=not suppress_sfx;
    6: cycle(your_card,13);
    7: get_num(samplerate);
    8: get_num(sound_addr);
    9: get_num(sound_irq);
   10: get_num(sound_dma);
   11: wants_keyclick:=not wants_keyclick;
   15: begin new_menu; exit; end;
  end;

 until false;
end;

procedure printer_menu;
var
 fv:byte;
 chooseable_lines:byteset;
begin
 new_menu;

 chooseable_lines:=[15];
 for fv:=1 to num_printers do
  chooseable_lines:=chooseable_lines+[fv+8];

 repeat
  clear_to(red);

  centre(3,15,'Printer menu');

  centre(5,15,'Select one of the following printers:');
  centre(6,15,'The current choice is '+this_printer+'.');

  for fv:=1 to num_printers do
   centre(8+fv,14,printers[fv]);

  centre(15,15,'Return to main menu');

  fv:=choose_one_of(chooseable_lines);

  if fv=15 then begin new_menu; exit; end;

  this_printer:=printers[fv-8];

 until false;
end;

procedure regi_split(x:string);
var fv:byte;
begin
 regname[0]:=chr(107-ord(x[1])); chkname[0]:=regname[0];
 regnum[0]:=chr(107-ord(x[2]));   chknum[0]:=chknum[0];

 move(x[3],regname[1],ord(regname[0]));
  for fv:=1 to length(regname) do
   regname[fv]:=chr(abs(((ord(regname[fv])-33)-177*fv) mod 94)+33);
end;


procedure registration_menu;
var
 r:char;
 t,o:text;
 x:string;
 fv:byte;
begin
 clear_to(black);

 centre(3,15,'REGISTRATION');
 centre(5,14,'Please insert the disk you were sent when you registered');
 centre(6,14,'into any drive, and press its letter. For example, if the');
 centre(7,14,'disk is in drive A:, press A.');
 centre(9,14,'Press Esc to cancel this menu.');

 repeat r:=upcase(readkey) until r in [#27,'A'..'Z']; if r=#27 then exit;

 {$I-}
 assign(t,r+':\REGISTER.DAT');
 reset(t);
 {$I+}
 if ioresult<>0 then
 begin
   centre(17,15,'But it isn''t in that drive...');
   centre(19,15,'Press any key.');
   r:=readkey;
   exit;
 end;
 for fv:=1 to 54 do readln(t,x);
 regi_split(x);

 { Copy the file... }

 assign(o,'register.dat'); rewrite(o); reset(t);

 while not eof(t) do
 begin
   readln(t,x); writeln(o,x);
 end;
 close(t); close(o);

 centre(17,15,'Done! Press any key...');
 bottom_bar;
 r:=readkey;

end;

procedure menu;
begin
 bottom_bar;
 new_menu;
 repeat
  clear_to(black);

  centre(3,15,'Avalot Setup - Main Menu');

  centre(5, 9,'General setup');
  centre(6,10,'Joystick setup');
  centre(7,11,'Sound setup');
  centre(8,12,'Printer setup');
  centre(9,14,'REGISTRATION setup');

  centre(15,15,'--- EXIT SETUP ---');

  case choose_one_of([5,6,7,8,9,15]) of
    5: general_menu;
    6: joystick_menu;
    7: sound_menu;
    8: printer_menu;
    9: registration_menu;
   15: begin
        new_menu;
        clear_to(lightgray);
        centre(3,0,'Quit: would you like to save changes?');
        centre(5,1,'Quit and SAVE changes.');
        centre(6,1,'Quit and DON''T save changes.');
        centre(15,0,'Cancel and return to the main menu.');
        case choose_one_of([5,6,15]) of
         5: begin
             save_file;
             exit;
            end;
         6: exit;
        end;
        new_menu;
       end;
  end;

 until false;
end;

procedure defaults; { Sets everything to its default value. }
begin
   { general }

 override_ega:=false;
 skip_loading_screens:=false;
 load_particular:='';
 force_numlock:=true;
 ignore_mouse:=false;
 use_keyboard:=true;
 log_to_printer:=false;
 log_to_file:=false;
 log_filename:='avalot.log';

   { joystick }

 has_a_joystick:=false;
 { jtop,jbottom,jleft,jright,jmidx,jmidy need no initialisation. }

   { sound }

 suppress_sfx:=false;
 your_card:=0; { none }
 wants_keyclick:=false;

 { other stuff }

 registrant:='';

 num_printers:=0; this_printer:='??';
end;

procedure parse_file;
const
 parse_Weird_Field = 1;
 parse_Not_Yes_Or_No = 2;
 parse_Not_Numeric = 3;
 parse_Not_Kbd_Or_Joy = 4;
 parse_Weird_Logcode = 5;
 parse_Weird_Card = 6;

var
 where:word;
 this,thiswas:string[80];
 position:byte;
 field,data,pure_data:string[80];
 error_found,ignoring:boolean;
 o:option;

  procedure error(what:byte);
  begin
   textattr:=15;
   if not error_found then
   begin
    clrscr; textattr:=12;
    writeln('SETUP: *** ERROR FOUND IN AVALOT.INI! ***'); textattr:=15;
   end;
   write(' ');
   case what of
    parse_Weird_Field: write('Unknown identifier on the left');
    parse_Not_Yes_Or_No: write('Value on the right should be Yes or No');
    parse_Not_Numeric: write('Value on the right is not numeric');
    parse_Not_Kbd_Or_Joy: write('Value on the right should be Keyboard or Joystick');
    parse_Weird_Logcode: write('Value on the right should be No, Printer or Disk');
    parse_Weird_Card: write('Never heard of the card');
   end;
   writeln(' in:'); textattr:=10; writeln(thiswas);
   error_found:=true;
  end;

  function yesno(x:string):boolean;
  begin
   if x='YES' then
    yesno:=true
   else if x='NO' then
    yesno:=false
   else
   begin
    error(parse_Not_Yes_Or_No);
    yesno:=false;
   end;
  end;

  function kbdjoy(x:string):boolean;
  begin
   if x='KEYBOARD' then
    kbdjoy:=true
   else if x='JOYSTICK' then
    kbdjoy:=false
   else
   begin
    error(parse_Not_Kbd_Or_Joy);
    kbdjoy:=false;
   end;
  end;

  function numeric(x:string):word;
  const hexdigits : string[15] = '0123456789ABCDEF';
  var answer:word; e:integer;
  begin
     if x[1]='$' then
     begin
        answer:=0;
        for e:=2 to length(x) do
        begin
           answer:=answer shl 4;
           inc(answer,pos(upcase(x[e]),hexdigits)-1);
        end
     end else
     begin
        val(x,answer,e);
        if e<>0 then error(parse_Not_Numeric);
     end;
   numeric:=answer;
  end;

  procedure get_logcodes(x:string);
  begin
   if x='NO' then begin log_to_file:=false; log_to_printer:=false; end else
   if x='DISK' then begin log_to_file:=true; log_to_printer:=false; end else
   if x='PRINTER' then begin log_to_file:=false; log_to_printer:=true; end else
    error(parse_Weird_Logcode);
  end;

  procedure get_card(x:string);
  begin
   if x='NONE' then your_card:=0 else
   if x='SB' then your_card:=1 else
   if x='SBPRO' then your_card:=2 else
   if x='SB16' then your_card:=3 else
   if x='PAS' then your_card:=4 else
   if x='PASPLUS' then your_card:=5 else
   if x='PAS16' then your_card:=6 else
   if x='ARIA' then your_card:=7 else
   if x='WINSOUND' then your_card:=8 else
   if x='GRAVIS' then your_card:=9 else
   if x='DACLPT' then your_card:=10 else
   if x='STEREODACS' then your_card:=11 else
   if x='STEREOON1' then your_card:=12 else
   if x='SPEAKER' then your_card:=13 else
    error(parse_Weird_Card);
  end;

begin
 error_found:=false;
 ignoring:=false;

 for where:=1 to mobylength do
 begin
  this:=moby^[where]; thiswas:=this;

  position:=pos(';',this);
  if position>0 then this:=copy(this,1,position-1);

  if this='' then continue; { Don't carry on if by now it's empty. }

  if this[1]='[' then
  begin
   ignoring:=not (trim_and_caps(this)='[END]');

   if copy(this,1,8)='[printer' then
   begin
    inc(num_printers);
    printers[num_printers]:=copy(this,10,length(this)-10);
   end;
  end;

  if ignoring then continue;

  position:=pos('=',this);
  field:=trim_and_caps(copy(this,1,position-1));   if field='' then continue;
  pure_data:=copy(this,position+1,255);
  data:=trim_and_caps(pure_data);
  o:=string_2_option(field);

       { general }

  if o=_OVERRIDEEGACHECK then override_ega:=yesno(data) else
  if o=_ZOOMYSTART then skip_loading_screens:=yesno(data) else
  if o=_LOADFIRST then load_particular:=data else
  if o=_NUMLOCKHOLD then force_numlock:=yesno(data) else
  if o=_USEMOUSE then ignore_mouse:=yesno(data) else
  if o=_CONTROLLER then use_keyboard:=kbdjoy(data) else
  if o=_LOGGING then get_logcodes(data) else
  if o=_LOGFILE then log_filename:=data else

   { joystick }

  if o=_JOYSTICKINSTALLED then has_a_joystick:=yesno(data) else
  if o=_JOYTOP then jtop:=numeric(data) else
  if o=_JOYBOTTOM then jbottom:=numeric(data) else
  if o=_JOYLEFT then jleft:=numeric(data) else
  if o=_JOYRIGHT then jright:=numeric(data) else
  if o=_JOYMIDX then jmidx:=numeric(data) else
  if o=_JOYMIDY then jmidy:=numeric(data) else
  if o=_JOYCENTRINGFACTOR then jcentre:=numeric(data) else
  if o=_WHICHJOY then whichjoy:=numeric(data) else

   { sound }

  if o=_QUIET then suppress_sfx:=yesno(data) else
  if o=_SOUNDCARD then get_card(data) else
  if o=_SAMPLERATE then samplerate:=numeric(data) else
  if o=_BASEADDRESS then sound_addr:=numeric(data) else
  if o=_IRQ then sound_irq:=numeric(data) else
  if o=_DMA then sound_dma:=numeric(data) else
  if o=_KEYBOARDCLICK then wants_keyclick:=yesno(data) else

   { printer }

  if o=_PRINTER then this_printer:=pure_data else

   { others }

   error(parse_Weird_Field);
 end;

 if error_found then
 begin
  textattr:=15;
  writeln(' Try and fix the above errors. As a last resort, try deleting or');
  writeln(' renaming AVALOT.INI, and the default values will be used. Good luck.');
  halt(177);
 end;
end;

procedure clear_up;
begin
 window(1,1,80,25);
 textattr:=31;
 clrscr;
 writeln;
 writeln('Enjoy the game...');
 writeln;
 CGA_cursor_on;
end;

begin
 cursor_off;

 new(moby); { Allocate memory space }

 defaults;

 load_file;

 parse_file;

 menu;

 dispose(moby); { Deallocate memory space again }

 clear_up;
end.
