program slope;

type
 JoySetup = record
             xmid,ymid,xmin,ymin,xmax,ymax:word;
             centre:byte; { Size of centre in tenths }
            end;

const
 bug_twonames = 255;
 bug_pandl = 254;
 bug_weirdswitch = 253;
 bug_invalidini = 252;
 bug_notyesorno = 251;
 bug_weirdcard = 250;

var
 fv:byte;
 t:char;
 bugline:string;
 usingp,usingl:boolean;
 zoomy,numlockhold:boolean;
 doing_syntax:boolean;
 js:joysetup; use_joy_A:boolean;

 filename_specified:boolean;
 soundfx:boolean;

 inihead,initail:string; { For reading the .INI file. }

 filetoload:string;

 cl_Override,keyboardclick,demo:boolean;

 slopeline:string;

 storage_SEG,storage_OFS:word;

 argon:string;

 soundcard,baseaddr,speed,irq,dma:longint;

function strf(x:longint):string;
var q:string;
begin
 str(x,q); strf:=q;
end;

procedure linebug(which:byte);
begin
 write('AVALOT : ');
 case which of
  bug_twonames : writeln('You may only specify ONE filename.');
  bug_pandl : writeln('/p and /l cannot be used together.');
  bug_weirdswitch : writeln('Unknown switch ("',bugline,
                       '"). Type AVALOT /? for a list of switches.');
  bug_invalidini: writeln('Invalid line in AVALOT.INI ("',bugline,'")');
  bug_notyesorno: writeln('Error in AVALOT.INI: "',inihead,'" must be "yes" or "no."');
  bug_weirdcard: writeln('Unknown card: ',bugline,'.');
 end;

 halt(which);
end;

function card(x:string):longint;
begin
 if x='NONE' then card:=0 else
 if x='SB' then card:=1 else
 if x='SBPRO' then card:=2 else
 if x='SB16' then card:=3 else
 if x='PAS' then card:=4 else
 if x='PASPLUS' then card:=5 else
 if x='PAS16' then card:=6 else
 if x='ARIA' then card:=7 else
 if x='WINSOUND' then card:=8 else
 if x='GRAVIS' then card:=9 else
 if x='DACLPT' then card:=10 else
 if x='STEREODACS' then card:=11 else
 if x='STEREOON1' then card:=12 else
 if x='SPEAKER' then card:=13 else
  linebug(bug_WeirdCard);
end;

procedure upstr(var x:string);
var fv:byte;
begin
 for fv:=1 to length(x) do x[fv]:=upcase(x[fv]);
end;

function yesno:boolean;
begin
 if initail='YES' then yesno:=true else
  if initail='NO' then yesno:=false else
   linebug(bug_notyesorno);
end;

function value(x:string):word;
const hexdigits: string[15] = '0123456789ABCDEF';
var w:word; e:integer;
begin
   if x[1]='$' then
   begin
      w:=0;
      for e:=2 to length(x) do
      begin
         w:=w shl 4;
         inc(w,pos(upcase(x[e]),hexdigits)-1);
      end;
      value:=w;
   end else
   begin
      val(x,w,e);
      if e=0 then value:=w else value:=0;
   end;
end;

procedure ini_parse;
begin
 upstr(inihead);
 upstr(initail);

 if inihead='QUIET' then soundfx:=not yesno else
  if inihead='ZOOMYSTART' then zoomy:=yesno else
   if inihead='NUMLOCKHOLD' then numlockhold:=yesno else
    if inihead='LOADFIRST' then filetoload:=initail else
     if inihead='OVERRIDEEGACHECK' then cl_Override:=yesno else
      if inihead='KEYBOARDCLICK' then keyboardclick:=yesno else
       if inihead='JOYTOP' then js.ymin:=value(initail) else
        if inihead='JOYBOTTOM' then js.ymax:=value(initail) else
         if inihead='JOYLEFT' then js.xmin:=value(initail) else
          if inihead='JOYRIGHT' then js.xmax:=value(initail) else
           if inihead='JOYMIDX' then js.xmid:=value(initail) else
            if inihead='JOYMIDY' then js.ymid:=value(initail) else
             if inihead='JOYCENTRINGFACTOR' then js.centre:=value(initail) else
              if inihead='WHICHJOY' then use_joy_A:=value(initail)=1 else
               if inihead='SOUNDCARD' then soundcard:=card(initail) else
                if inihead='BASEADDRESS' then baseaddr:=value(initail) else
                 if inihead='IRQ' then irq:=value(initail) else
                  if inihead='DMA' then dma:=value(initail) else
                   if inihead='SAMPLERATE' then speed:=value(initail);
end;

procedure strip_ini;
var fv:byte;
begin
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
 begin { No "="! Weird! }
  bugline:=inihead;
  linebug(bug_invalidini);
 end;

 initail:=copy(inihead,fv+1,255);
 inihead[0]:=chr(fv-1);
end;

procedure load_ini;
var ini:text;
begin
 assign(ini,'AVALOT.INI');
 reset(ini);

 while not eof(ini) do
 begin
  readln(ini,inihead);
  strip_ini;
  if inihead<>'' then ini_parse;
 end;

 close(ini);
end;

procedure parse(x:string);
var arg:string;
  function getarg(otherwise:string):string;
  begin
   if arg='' then getarg:=otherwise else getarg:=arg;
  end;

begin
 case x[1] of
  '/','-': begin
            arg:=copy(x,3,255);
            case upcase(x[2]) of
             '?': doing_syntax:=true;
             'O': cl_Override:=true;
             'L': if not usingp then
                  begin
                   usingl:=true;
                   argon:=getarg('avvy.log');
                  end else linebug(bug_pandl);
             'P': if not usingl then
                  begin
                   usingp:=true;
                   argon:=getarg('prn');
                  end else linebug(bug_pandl);
             'Q': soundfx:=false;
             'Z': zoomy:=true;
             'K': keyboardclick:=true;
             'D': demo:=true;
             else begin
              bugline:=x;
              linebug(bug_weirdswitch);
             end;
            end;
           end;
  '*': begin
        inihead:=copy(x,2,255);
        strip_ini;
        if inihead<>'' then ini_parse;
       end;
  else begin { filename }
        if filename_specified then
         linebug(bug_twonames)
        else
         filetoload:=x;
        filename_specified:=true;
       end;
 end;
end;

procedure make_slopeline;
  function yn(b:boolean):char;
  begin
   if b then yn:='y' else yn:='n';
  end;

  function pln:char;
  begin
   if (not usingp) and (not usingl) then pln:='n' else
     if usingp then pln:='p' else
      if usingl then pln:='l';
  end;

begin
 if argon='' then argon:='nul';

 with js do
  slopeline:='1'+yn(doing_syntax)+yn(soundfx)+yn(cl_Override)+
   yn(keyboardclick)+pln+yn(demo)+yn(zoomy)+yn(numlockhold)+
   yn(use_joy_A)+
    ' '+strf(xmid)+
    ' '+strf(ymid)+
    ' '+strf(xmin)+
    ' '+strf(ymin)+
    ' '+strf(xmax)+
    ' '+strf(ymax)+
    ' '+strf(centre)+
    ' '+argon+' '+filetoload;
end;

procedure store_slopeline;
begin
 move(slopeline,mem[Storage_SEG:Storage_OFS+3],sizeof(slopeline));
 move(js,mem[Storage_SEG:Storage_OFS+300],sizeof(js));
 move(soundcard,mem[Storage_SEG:Storage_OFS+5000],4);
 move(baseaddr,mem[Storage_SEG:Storage_OFS+5004],4);
 move(irq,mem[Storage_SEG:Storage_OFS+5008],4);
 move(dma,mem[Storage_SEG:Storage_OFS+5012],4);
 move(speed,mem[Storage_SEG:Storage_OFS+5016],4);
end;

procedure get_storage_addr;
  procedure not_through_bootstrap;
  begin writeln('Not standalone!'); halt(255); end;
var e:integer;
begin
 if paramstr(1)<>'jsb' then not_through_bootstrap;
 val(paramstr(2),storage_SEG,e); if e<>0 then not_through_bootstrap;
 val(paramstr(3),storage_OFS,e); if e<>0 then not_through_bootstrap;
end;

begin
 get_storage_addr;

 filetoload:=''; argon:='';
 usingl:=false;
 usingp:=false;
 cl_Override:=false;
 soundfx:=true;
 zoomy:=false;
 numlockhold:=false;
 filename_specified:=false;
 keyboardclick:=false;
 doing_syntax:=false;
 soundcard:=0; baseaddr:=0; irq:=0; dma:=0;

 load_ini;

 for fv:=4 to paramcount do
  parse(paramstr(fv));

 make_slopeline;

 store_slopeline;
end.
