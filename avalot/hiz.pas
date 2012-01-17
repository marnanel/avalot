program hiz;
{$M 6000,600,600}
{$V-,I-,R-,F+} { Do not change these directives. }
uses Graph,Crt,Dos,Tsru;

const { program's signature }
  TSR_tmark : string[20] = 'FISH FISH FISH!!!';

var
 gd,gm:integer;
 a:byte absolute $A000:0;
 sv:array[1..800,0..3] of byte;
 bit:byte; nam:string;
 Tsr_int: byte; tsr_ax:word;

procedure grab;
begin;
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  move(a,sv[1,bit],800);
 end;
end;

procedure drop;
begin;
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  move(sv[1,bit],a,800);
 end;
end;

procedure say(x:string);
begin;
 grab; write(#13+x);
end;

procedure pak(x:string);
var r:char;
begin;
 say(x+' (press any key...)'); r:=readkey; drop;
end;

function typein:string;
var r:char; x:string;
begin;
 x:='';
 repeat
  r:=readkey;
  case r of
    #8: if x[0]>#0 then begin; write(#8+#32+#8); dec(x[0]); end;
   #13: begin; typein:=x;  exit; end;
   #27: begin; typein:=''; exit; end;
   else if x[0]<#50 then begin; x:=x+r; write(r); end;
  end;
 until false;
end;

procedure load;
var a:byte absolute $A000:1200; f:file;
begin;
 say('LOAD: filename?'); nam:=typein; drop;
 if nam='' then exit;
 assign(f,nam); reset(f,1);
 if ioresult<>0 then
 begin;
  pak('LOAD: file not found.'); exit;
 end;
 seek(f,177);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockread(f,a,12080);
  if ioresult<>0 then
  begin;
   pak('LOAD: error whilst loading.'); close(f); exit;
  end;
 end;
 close(f);
end;

procedure save;
const header : string =
 'This is a file from an Avvy game, and its contents are subject to '+
 'copyright.'+#13+#10+#13+#10+'Have fun!'+#26;
var f:file; screenname:string[30]; s:searchrec; r:char;
a:byte absolute $A000:1200;
begin;
 say('SAVE: filename?'); nam:=typein; drop;
 if nam='' then exit;
 findfirst(nam,anyfile,s); if doserror=0 then
 begin;
  say('SAVE: That exists, are you sure? (Y/N)');
  repeat r:=upcase(readkey) until r in ['Y','N']; drop;
  if r='N' then exit;
 end;
 screenname:='Saved with HIZ.';
 assign(f,nam); rewrite(f,1); blockwrite(f,header[1],146);
 blockwrite(f,screenname,31);
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockwrite(f,a,12080);
  if ioresult<>0 then
  begin;
   pak('SAVE: error whilst saving.'); close(f); exit;
  end;
 end;
end;

procedure hedges;
begin;
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  fillchar(mem[$A000:14*80],80,#255);
  fillchar(mem[$A000:166*80],80,#255);
 end;
end;

procedure reset;
var regs:registers;
begin;
 regs.ax:=14;
 intr($10,regs);
 directvideo:=false;
end;

procedure do_pop;
var r:char;
begin;
 repeat
  say('HIZ: Load Save Hedges Reset eXit?'); r:=upcase(readkey); drop;
  case r of
   'L': load;
   'S': save;
   'H': hedges;
   'R': reset;
   'X': exit;
  end;
 until false;
end;

{ Now for the TSR stuff }

procedure mypoprtn;
var r:registers;
begin;
 beginpop;
 do_pop;
 endpop;
end;
(**********************)
procedure stop_tsr;
begin;
 if tsrexit then
  writeln('HIZ stopped')
 else
  writeln('Unable to stop HIZ - other TSR has been installed.');
end;
(**********************)
{ This interrupt is called at program start-up. Its purpose is to provide
 a way to communicate with an installed copy of the TSR through cmdline
 params. The installation of the intrpt serves to prevent any attempt to
 install a 2nd copy of the TSR }
procedure tsr_intrtn(Flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word);
interrupt;
begin;
 tsr_ax:=ax;
 cli;
 beginint;
 sti;

 case tsr_ax of
 1: begin;
     stop_tsr; { Terminate TSR, if poss.}
    end;
 2: begin;
     TSROFF:= true; { Suspend TSR }
     writeln('HIZ suspended.');
    end;
 3: begin;
     TSROFF:=false;
     writeln('HIZ restarted');
    end;
  end;
 cli;
 endint;
 sti;
end;
(*******************)
var
 i: byte;
 r: registers;
 st:string;
 b: boolean;

begin;

 (********************************************)
 (* Check to see if TSR is already installed *)
 (********************************************)

 TSR_int:=dupcheck(TSR_tmark,@TSR_intrtn);

 (*****************************************)
 (* If it IS already installed, check for *)
 (* parameter.                            *)
 (*****************************************)

 If TSR_int > 0 then
 begin
  if paramcount>0 then
  begin
   st:=paramstr(1);
   for i:=1 to length(st) do
   st[i]:=upcase(st[i]);
   if st='STOP' then
    r.ax:=1
   else if st='HOLD' then r.ax:=2
   else if st='RSTR' then r.ax:=3
   else r.ax:=4;

   if r.ax<4 then
   begin;
    intr(TSR_int,r);
    exit;
   end
   else
   begin;
    writeln('HIZ: invalid parameter ',paramstr(1));
    writeln('Syntax: HIZ stop/hold/rstr');
    exit;
   end;
   end
  else
  begin;
   writeln('HIZ already installed.');
   writeln('(If you''re sure it isn''t, try running BLANKINT /I.');
   writeln('It''s in the TURBO directory.)');
  end;
  exit;
 end;

 write('Wait...'+#13); { tell 'em to wait...! }

 { Call PopSetUp to point to PopUp routine. Include the
   scancode and the keymask to activate the program. In
   this example, the scancode is $23 (H) and the
   keymask is 08h (Alt.) }

 PopSetUp(@Mypoprtn,$23,$08);

 directvideo:=false;
 writeln('Û Û ßÛß ßßÛ v1.0, (c) 1992, Thomas Thurman.');
 writeln('ÛßÛ  Û  Üß');
 writeln('ß ß ßßß ßßß The AVD saving/loading/hedging program.');
 writeln('            Use with Dr. Genius. The Hot Key is Ctrl-Alt-H.');

 writeln;
 writeln(' Enter "HIZ stop" to remove Hiz from memory');
 writeln('       "HIZ hold" to temporarily halt Hiz');
 writeln('       "HIZ rstr" to restart Hiz');
 stacksw:=-1;
 install_int;
 keep(0);
end.
