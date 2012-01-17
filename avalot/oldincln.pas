{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 INCLINE          The command-line parser. }

unit incline;

interface


{ This unit has NO externally-callable procedures. Also note that
  it MUST be called *first* (so if you load AVALOT.PAS and press f7
  twice you get to the "begin" statement.) }

implementation
 uses Gyro,Logger;

const
 bug_twonames = 255;
 bug_pandl = 254;
 bug_weirdswitch = 253;
 bug_invalidini = 252;
 bug_notyesorno = 251;

var
 fv:byte;
 t:char;
 bugline:string;
 usingp,usingl:boolean;
 zoomy,numlockhold:boolean;

 filename_specified:boolean;

 inihead,initail:string; { For reading the .INI file. }


procedure linebug(which:byte);
begin;
 write('AVALOT : ');
 case which of
  bug_twonames : writeln('You may only specify ONE filename.');
  bug_pandl : writeln('/p and /l cannot be used together.');
  bug_weirdswitch : writeln('Unknown switch ("',bugline,
                       '"). Type AVALOT /? for a list of switches.');
  bug_invalidini: writeln('Invalid line in AVALOT.INI ("',bugline,'")');
  bug_notyesorno: writeln('Error in AVALOT.INI: "',inihead,'" must be "yes" or "no."');
 end;
 halt(which);
end;

procedure syntax;
begin;
 assign(output,''); rewrite(output);
 writeln;
 writeln('Lord Avalot d''Argent'^i^i'(c) '+copyright+' Mark, Mike and Thomas Thurman.');
 writeln('~~~~~~~~~~~~~~~~~~~~~'^i^i+vernum);
 writeln;
 writeln('Syntax:');
 writeln(^i'/?'^i'displays this screen,');
 writeln(^i'/O'^i'overrides EGA check,');
 writeln(^i'/L<f>'^i'logs progress to <f>, default AVVY.LOG,');
 writeln(^i'/P<x>'^i'logs with Epson codes to <x>, default PRN,');
 writeln(^i'/Q'^i'cancels sound effects,');
 writeln(^i'/S'^i'disables Soundblaster,');
 writeln(^i'/Z'^i'goes straight into the game.');
 writeln;
 writeln(^i^i^i^i^i^i^i'... Have fun!');
 halt(177);
end;

procedure upstr(var x:string);
var fv:byte;
begin;
 for fv:=1 to length(x) do x[fv]:=upcase(x[fv]);
end;

function yesno:boolean;
begin;
 if initail='YES' then yesno:=true else
  if initail='NO' then yesno:=false else
   linebug(bug_notyesorno);
end;

procedure ini_parse;
begin;
 upstr(inihead);
 upstr(initail);

 if inihead='QUIET' then soundfx:=not yesno else
  if inihead='ZOOMYSTART' then zoomy:=yesno else
   if inihead='NUMLOCKHOLD' then numlockhold:=yesno else
    if inihead='LOADFIRST' then filetoload:=initail else
     if inihead='OVERRIDEEGACHECK' then cl_Override:=yesno else
      if inihead='KEYBOARDCLICK' then keyboardclick:=yesno;
end;

procedure strip_ini;
var fv:byte;
begin;
 if (inihead='') then exit;

 { Firstly, delete any comments. }
 fv:=pos(';',inihead);
 if fv>0 then delete(inihead,fv,255);

 { Lose the whitespace... }

 while inihead[length(inihead)]=' ' do dec(inihead[0]);
 while (inihead<>'') and (inihead[1]=' ') do delete(inihead,1,1);

 { It's possible that now we'll end up with a blank line. }

 if (inihead='') or (inihead[1]='[') then exit;

 fv:=pos('=',inihead);

 if fv=0 then
 begin; { No "="! Weird! }
  bugline:=inihead;
  linebug(bug_invalidini);
 end;

 initail:=copy(inihead,fv+1,255);
 inihead[0]:=chr(fv-1);
end;

procedure load_ini;
var ini:text;
begin;
 assign(ini,'AVALOT.INI');
 reset(ini);

 while not eof(ini) do
 begin;
  readln(ini,inihead);
  strip_ini;
  if inihead<>'' then ini_parse;
 end;

 close(ini);
end;

procedure parse(x:string);
var arg:string;
  function getarg(otherwise:string):string;
  begin;
   if arg='' then getarg:=otherwise else getarg:='';
  end;

begin;
 case x[1] of
  '/','-': begin;
            arg:=copy(x,3,255);
            case upcase(x[2]) of
             '?': syntax;
             'O': cl_Override:=true;
             'L': if not usingp then
                  begin;
                   log_setup(getarg('avvy.log'),false);
                   usingl:=true;
                  end else begin; close(logfile); linebug(bug_pandl); end;
             'P': if not usingl then
                  begin;
                   log_setup(getarg('prn'),true);
                   usingp:=true;
                  end else begin; close(logfile); linebug(bug_pandl); end;
             'Q': soundfx:=false;
             'Z': zoomy:=true;
             'K': keyboardclick:=true;
             'D': demo:=true;
             else begin;
              bugline:=x;
              linebug(bug_weirdswitch);
             end;
            end;
           end;
  '*': begin;
        inihead:=copy(x,2,255);
        strip_ini;
        if inihead<>'' then ini_parse;
       end;
  else begin; { filename }
        if filename_specified then
         linebug(bug_twonames)
        else
         filetoload:=x;
        filename_specified:=true;
       end;
 end;
end;

procedure not_through_bootstrap;
begin
 writeln('Avalot must be loaded through the bootstrap.');
 halt;
end;

procedure get_storage_addr;
var e:integer;
begin
 val(paramstr(2),storage_SEG,e); if e<>0 then not_through_bootstrap;
 val(paramstr(3),storage_OFS,e); if e<>0 then not_through_bootstrap;
 Skellern:=storage_OFS+1;
end;

begin;
 filetoload:='';
 usingl:=false;
 usingp:=false;
 logging:=false;
 cl_Override:=false;
 soundfx:=true;
 zoomy:=false;
 numlockhold:=false;
 filename_specified:=false;
 keyboardclick:=false;

 load_ini;

 if (paramcount<3) or
  ((paramstr(1)<>'Go') and (paramstr(1)<>'et')) then not_through_bootstrap;

 reloaded:=paramstr(1)='et';

 get_storage_addr;

 for fv:=4 to paramcount do
  parse(paramstr(fv));
end.
