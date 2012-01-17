program avalot_bootstrap;
uses Dos;

{$M 8192,0,$6000, S-}

type
  elm = (Normal, Musical, Elmpoyten, Regi);

const
 run_ShootEmUp = 1;
 run_DosShell = 2;
 run_GhostRoom = 3;
 run_Golden = 4;

 runcodes : array[false..true] of string[2] = ('et','Go');

 reset = 0;

 JSB = true;  No_JSB = false;
 Bflight = true; No_Bflight = false;


var
  storage: record
            operation:byte;
            Skellern:word;
            contents:array[1..10000] of byte;
           end;

  arguments,demo_args,args_with_no_filename:string;

  first_time:boolean;

  original_mode:byte;
  old_1c:pointer;

  Segofs:string;

  zoomy:boolean;

 soundcard,speed,baseaddr,irq,dma:longint;

procedure cursor_off; assembler;
asm
 mov ah,01; { Change cursor size. }
 mov cx,8224; { CH & CL are now 32. }
 int $10;  { Call the Bios }
end; { That's all. }

procedure cursor_on; assembler;
asm
 mov ah,01; { Change cursor size. }
 mov ch,5;  { Top line is 5. }
 mov cl,7;  { Bottom line is 7. }
 int $10;   { Call the Bios. }
end;

procedure quit;
begin
 cursor_on;
 halt;
end;

function strf(x:longint):string;
var q:string;
begin;
 str(x,q); strf:=q;
end;

function command_com:string;
var temp:string;
begin
 temp:=getenv('comspec');
 if temp='' then
  writeln('avvy_bootstrap: COMSPEC not defined, => cannot run Dos shell.');
 command_com:=temp;
end;

procedure explain(error:byte);
begin
 write(' (');
 case error of
  2: write('it''s not there');
  8: write('out of memory');
  else write('error ',error);
 end;
 writeln(').');
end;

{$F+}

procedure B_flight; interrupt;
begin
 inc(storage.Skellern);
end;

{$F-}

procedure Bflight_ON;
begin
 storage.Skellern:=reset;
 setintvec($1c,@B_flight);
end;

procedure Bflight_OFF;
begin
 setintvec($1c,old_1c);
end;

procedure run(what:string; with_jsb,with_bflight:boolean; how:elm);
var
 which_dir,args:string;
 error:integer;

   function elm2str(how:elm):string;
   begin
    case how of
     Normal, Musical: elm2str:='jsb';
     Regi: elm2str:='REGI';
     Elmpoyten: elm2str:='ELMPOYTEN';
    end;
   end;

begin
 if what='' then exit;

 getdir(0,which_dir);

 if with_jsb then
 begin
   if how=Musical then
     args:=elm2str(how)+' '+args_with_no_filename { FN is NOT given if musical}
   else
     args:=elm2str(how)+' '+arguments
 end else args:='';

 if how=Musical then args:=args+strf(soundcard)+' '+strf(speed)+' '+
                      strf(baseaddr)+' '+strf(dma)+' '+strf(irq);
 if with_bflight then Bflight_ON;

 swapvectors;
 exec(what,args);
 swapvectors;
 cursor_off;

 error:=doserror;

 if with_bflight then Bflight_OFF;

 chdir(which_dir);

 if error<>0 then
 begin
  write('avvy_bootstrap: cannot execute ',what,'!');
  explain(error);
  write('Press Enter:'); readln; quit;
 end;
end;

procedure run_avalot;
var error:integer;
begin

 Bflight_ON;

 swapvectors;
 exec('avalot.avx',runcodes[first_time]+Arguments);
 swapvectors;

 error:=doserror;

 Bflight_OFF;

 if error<>0 then
 begin
  write('avvy_bootstrap: error in loading AVALOT.AVX!');
  explain(error);
  quit;
 end;

 first_time:=false;
end;

procedure run_the_demo;
var args:string;
begin
 args:=Arguments;
 Arguments:=demo_args; { Force the demo. }

 run_avalot;

 Arguments:=args;   { Put all back to normal again. }
 first_time:=true;
end;

procedure get_arguments;
var
 fv:byte;
begin
 Arguments:='';

 for fv:=1 to ParamCount do
  Arguments:=Arguments+ParamStr(fv)+' ';

 dec(Arguments[0]); { Get rid of the trailing space. }

 segofs:=' '+strf(seg(storage))+' '+strf(ofs(storage));

 Arguments:=segofs+' '+Arguments;
end;

procedure dos_shell;
var r:registers;
begin
 r.ax:=original_mode; intr($10,r);
 writeln;
 writeln('The Avalot Dos Shell.');
 writeln('---------------------');
 writeln;
 writeln('Type EXIT to return to Avalot.');
 writeln;

 cursor_on;
 run(command_com,no_JSB,no_Bflight,Normal);
 cursor_off;

 writeln('Please wait, restoring your game...');
end;

function keypressed:boolean; var r:registers;
begin
 r.ah:=$B;
 msdos(r);
 keypressed:=r.al=$FF;
end;

procedure flush_buffer; var r:registers; begin r.ah:=7;
 while keypressed do msdos(r); end;

procedure demo;
begin
 run_the_demo; if keypressed then exit;
 run('intro.avx',JSB,Bflight,Musical); if keypressed then exit;
 run('stars.avx',JSB,No_Bflight,Musical); if keypressed then exit;

 flush_buffer;
end;

procedure call_menu;
begin
 run('stars.avx',JSB,No_Bflight,Musical);
 flush_buffer;
 repeat
  run('avmenu.avx',JSB,No_Bflight,Normal);

  case storage.operation of
   1: exit; { Play the game. }
   2: run('intro.avx',JSB,Bflight,Musical);
   3: run('preview1.avd',JSB,No_Bflight,Normal);
   4: run('viewdocs.avx',JSB,Bflight,Elmpoyten);
   5: run('viewdocs.avx',JSB,Bflight,Regi);
   6: quit;
   177: demo;
  end;

  flush_buffer;
 until false;
end;

procedure get_slope;
begin
 run('slope.avx',JSB,No_Bflight,Normal);
 if dosexitcode<>0 then
 begin
  cursor_on;
  halt;
 end;

 move(storage.contents,Arguments,sizeof(Arguments));
 move(storage.contents[4998],soundcard,4);
 move(storage.contents[5002],baseaddr,4);
 move(storage.contents[5006],irq,4);
 move(storage.contents[5010],dma,4);
 move(storage.contents[5014],speed,4);

 zoomy:=(Arguments[8]='y') or (Arguments[2]='y');
 demo_args:=arguments; demo_args[7]:='y';
 Arguments:=Segofs+' '+Arguments;
 demo_args:=SegOfs+' '+demo_args;

 args_with_no_filename:=Arguments;
 if Arguments[length(Arguments)]<>' ' then
 begin    { Filename was given }
   args_with_no_filename:=Arguments;
   while (args_with_no_filename<>'')
     and (args_with_no_filename[length(args_with_no_filename)]<>' ') do
      dec(args_with_no_filename[0]); { Strip off the filename. }
 end;
end;

begin
 original_mode:=mem[seg0040:$49]; getintvec($1c,old_1c);
 first_time:=true; cursor_off;

 get_arguments;
 get_slope;

 if not zoomy then call_menu;  { Not run when zoomy. }

 repeat
  run_avalot;

  if DosExitCode<>77 then quit; { Didn't stop for us. }

  case storage.operation of
   run_ShootEmUp: run('seu.avx',JSB,Bflight,Normal);
   run_DosShell: dos_shell;
   run_GhostRoom: run('g-room.avx',JSB,No_Bflight,Normal);
   run_Golden: run('golden.avx',JSB,Bflight,Musical);
  end;

 until false;
end.
