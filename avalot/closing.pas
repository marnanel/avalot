{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 CLOSING          The closing screen and error handler. }

unit Closing;

interface

const
 scr_BugAlert = 1;
 scr_RamCram = 2;
 scr_NagScreen = 3;
 scr_TwoCopies = 5;


procedure quit_with(which,errorlev:byte);

procedure end_of_program;

implementation

uses Gyro,Graph,Crt,Lucerna;

type scrtype = array[1..3840] of char;

var
 q:scrtype absolute $B8FA:0; { Nobody's using the graphics memory now. }
 f:file of scrtype;
 exitsave:pointer;

procedure get_screen(which:byte);
begin;
 closegraph;
 textattr:=0; clrscr;
 assign(f,'text'+strf(which)+'.scr'); reset(f); read(f,q); close(f);
end;

procedure show_screen;
var
 fv,ff,fq, tl,bl:byte;
 a:scrtype absolute $B800:0;
begin;
 for fv:=1 to 40 do
 begin;
  if fv>36 then begin; tl:=1; bl:=24; end
   else begin; tl:=12-fv div 3; bl:=12+fv div 3; end;
  for fq:=tl to bl do
   for ff:=80-fv*2 to 80+fv*2 do
    a[fq*160-ff]:=q[fq*160-ff];
  delay(5);
 end;
 gotoxy(1,25); textattr:=31; clreol; gotoxy(1,24);
end;

procedure quit_with(which,errorlev:byte);
begin;
 dusk;
 get_screen(which);
 show_screen; { No changes. }
 halt(errorlev);
end;

procedure put_in(x:string; where:word);
var fv:word;
begin;
 for fv:=1 to length(x) do
  q[1+(where+fv)*2]:=x[fv];
end;

procedure end_of_program;

const
 nouns: array[0..11] of string[11] =
  ('sackbut','harpsichord','camel','conscience','ice-cream','serf',
   'abacus','castle','carrots','megaphone','manticore','drawbridge');

 verbs: array[0..11] of string[9] =
  ('haunt','daunt','tickle','gobble','erase','provoke','surprise',
   'ignore','stare at','shriek at','frighten','quieten');

var
 result:string;
begin;
 nosound;
 get_screen(scr_NagScreen);
 result:=nouns[random(12)]+' will '+verbs[random(12)]+' you';
 put_in(result,1628);
 show_screen; { No halt- it's already set up. }
end;

{$F+}

procedure bug_handler;
begin;
 exitproc:=exitsave;

 if erroraddr<>nil then
 begin; { An error occurred! }
  if exitcode=203 then
   get_screen(scr_RamCram)
  else
  begin;
   get_screen(scr_BugAlert);
   put_in(strf(exitcode),678); { 678 = [38,8]. }
   put_in(strf(seg(erroraddr))+':'+strf(ofs(erroraddr)),758); { 758 = [38,9]. }
  end;
  show_screen;
  erroraddr:=nil;
 end;
end;

{$F-}

begin;
 exitsave:=exitproc;
 exitproc:=@bug_handler;
end.