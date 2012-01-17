{$M 10000,0,1000} {$V-}
program edna;
uses Dos,Tommys;

type
  ednahead = record { Edna header }
            { This header starts at byte offset 177 in the .ASG file. }
            ID:array[1..9] of char; { signature }
            revision:word; { EDNA revision, here 2 (1=dna256) }
            game:string[50]; { Long name, eg Lord Avalot D'Argent }
            shortname:string[15]; { Short name, eg Avalot }
            number:word; { Game's code number, here 2 }
            ver:word; { Version number as integer (eg 1.00 = 100) }
            verstr:string[5]; { Vernum as string (eg 1.00 = "1.00" }
            filename:string[12]; { Filename, eg AVALOT.EXE }
            osbyte:byte; { Saving OS (here 1=DOS. See below for others.}
            os:string[5]; { Saving OS in text format. }

            { Info on this particular game }

            fn:string[8]; { Filename (not extension ('cos that's .ASG)) }
            d,m:byte; { D, M, Y are the Day, Month & Year this game was... }
            y:word;  { ...saved on. }
            desc:string[40]; { Description of game (same as in Avaricius!) }
            len:word; { Length of DNA (it's not going to be above 65535!) }

            { Quick reference & miscellaneous }

            saves:word; { no. of times this game has been saved }
            cash:integer; { contents of your wallet in numerical form }
            money:string[20]; { ditto in string form (eg 5/-, or 1 denarius)}
            points:word; { your score }

            { DNA values follow, then footer (which is ignored) }
           end;

  { Possible values of edhead.os:
     1 = DOS        4 = Mac
     2 = Windows    5 = Amiga
     3 = OS/2       6 = ST
     7 = Archimedes }

 fourtype = array[1..4] of char;

 avaricius_dna = record
                   desc: string[39];
                   dna: array[1..256] of integer;
                 end;

const
  ednaID = 'TT'+#177+#48+#01+#117+#177+#153+#177;
  Avaricius_file : fourtype = 'Avvy';

var
  filename:string;
  quiet,info:boolean;
  eh:ednahead;

  avaricius:boolean;
  id4:fourtype;
  av_eh:avaricius_dna;
  av_ver:string[4];

  ok:boolean;

  first_dir:string;

procedure explain;
begin
  writeln('EDNA Bucket v1.0 (c) 1993 Thomas Thurman.');
  writeln('  To load Avvy files.');
  writeln;
  writeln('Associate .ASG files with EDNA.EXE to load them directly.');
  writeln;
  writeln('Switches:');
  writeln('  /q (quiet) will stop EDNA from printing text to the screen.');
  writeln('  /i (info) will print info about the file, but won''t load it.');
  writeln;
  halt(1);
end;

procedure fix_filename;
var p,n,groi:string;
begin
  fsplit(filename,p,n,groi);
  filename:=p+n+'.ASG';
end;

procedure error(x:string);
begin
  writeln('EDNA : ',x);
  halt(255);
end;

procedure paramparse;
var
 fv:byte;
 x:string;
begin
  if paramcount=0 then explain;

  filename:='';
  quiet:=false; info:=false;

  for fv:=1 to paramcount do
  begin
    x:=paramstr(fv);

    if (x[1]='/') or (x[1]='-') then
       case upcase(x[2]) of { Parse switches }
         'Q': quiet:=not quiet;
         'I': info:=not info;
         else error('Unknown switch! ('+x[2]+')');
       end
    else
       if filename='' then filename:=x
         else error('Please, only one filename at a time!');
  end;

  if quiet and info then error('How can you give info quietly??');

  if filename='' then error('No filename given! Use EDNA alone for help.');

  fix_filename;
end;

procedure getfile;
var f:file;
begin
  assign(f,filename);
 {$I-}
  reset(f,1);
 {$I+}
  if ioresult<>0 then error('Can''t read file "'+filename+'".');

  seek(f,11); blockread(f,id4,4);
  avaricius:=id4=Avaricius_file;

  if avaricius then
  begin
    seek(f,47);
    blockread(f,av_eh,sizeof(av_eh));
    av_ver[0]:=#4; seek(f,31); blockread(f,av_ver[1],4);
  end else
  begin
    seek(f,177);
    blockread(f,eh,sizeof(eh));
  end;

  close(f);
end;

function plural(x:byte):string;
begin
  if x=1 then plural:='' else plural:='s';
end;

procedure show_info;
var _game,_shortname,_verstr,_filename,_os,_fn,_desc,_money:string;
   _revision,_number,_d,_m,_y,_saves,_points:integer;
   readable,understandable:boolean;
begin
  writeln('Info on file ',filename,':');
  writeln;
    if avaricius then
    with av_eh do
    begin { DNA-256 file. }
      _verstr:=av_ver;
      _game:='Denarius Avaricius Sextus'; _shortname:='Avaricius';
      _filename:='AVVY.EXE'; _os:='DOS'; _desc:=desc;
      _revision:=1; _number:=1; _fn:='(as above)';

      _money:=strf(dna[30])+' denari';
      if dna[30]=1 then _money:=_money+'us' else _money:=_money+'i';
      _d:=dna[7]; _m:=dna[8]; _y:=dna[9];
      _saves:=dna[6]; _points:=dna[36];

      readable:=true; understandable:=true;
    end else
     with eh do
     begin
       if id=ednaid then
       begin  { EDNA file. }
        _game:=game;
        _shortname:=shortname;
        _verstr:=verstr;
        _filename:=filename;
        _os:=os; _fn:=fn; _desc:=desc;
        _money:=money; _revision:=revision;
        _number:=number; _d:=d; _m:=m; _y:=y;
        _saves:=saves; _points:=points;

         readable:=true; understandable:=revision=2;
       end else
       begin
         writeln('Unknown format.');
         readable:=false;
       end;
     end;

    if _desc='' then _desc:='<none>';

    if readable then
    begin
      writeln('Signature is valid.');
      writeln('Revision of .ASG format: ',_revision);
      writeln;
      if understandable then
      begin
        writeln('The file was saved by ',_game,'.');
        writeln('Game number ',_number,' (',_shortname,'), version ',
            _verstr,', filename ',_filename,'.');
        writeln('Saved under ',_os,'.');
        writeln;
        writeln('This is ',_fn,'.ASG, saved on ',_d,'/',_m,'/',_y,' (d/m/y).');
        writeln('Description: ',_desc);
        writeln('It has been saved ',_saves,' time',plural(_saves),
                    '. You have ',_points,' point',plural(_points),',');
        writeln('and ',_money,' in cash.');
      end else writeln('Nothing else can be discovered.');
    end;

  halt(2);
end;

procedure load_file;
var
 progname,gamename,shortname,listname,exname,prog_dir:string;

 localdir,groi:string;

 x,y:string;

 t:text;

 i,ii:integer;
begin
  gamename:=fexpand(filename);
  fsplit(fexpand(paramstr(0)),localdir,groi,groi);
  listname:=localdir+'EDNA.DAT';

  if avaricius then
       begin shortname:='Avaricius'; exname:='AVVY'; end
  else begin shortname:=eh.shortname; fsplit(eh.filename,groi,exname,groi); end;

  assign(t,listname);
 {$I-}
  reset(t);
 {$I+}
  progname:='';
  if ioresult=0 then
  begin
    repeat
      readln(t,x); readln(t,y);
      if x=shortname then
      begin
        progname:=y;
        break;
      end
    until eof(t);
  end;

  if progname='' then
  begin  { No entry in EDNA.DAT }
    writeln('This file was saved by ',shortname,'.');
    writeln('However, no entry was found in EDNA.DAT for that game.');
    writeln;
    writeln('Please give the full path to that game, or press Enter to cancel.');
    writeln('(Example: C:\'+exname+'\'+exname+'.EXE)');
    writeln;
    readln(progname);
    if progname='' then halt(254);  { Quick exit! }

   {$I-}
    append(t);
    if ioresult<>0 then rewrite(t);

    writeln(t,shortname);
    writeln(t,progname);

    if ioresult<>0 then
    begin
      writeln('Strange... could not write to EDNA.DAT. (Disk read-only or full?)');
      writeln('The path will be used this time only.');
      write('Press Enter...'); readln;
    end;
    close(t);
    {$I+}
  end;

  if not quiet then writeln('Running ',shortname,': ',progname,'...');

  fsplit(fexpand(progname),prog_dir,groi,groi);
  if prog_dir[length(prog_dir)]='\' then dec(prog_dir[0]);

  {$I-}
  chdir(prog_dir); i:=ioresult;
  swapvectors;
  exec(progname,gamename); ii:=ioresult;
  swapvectors;
  chdir(first_dir);
  {$I+}

  if (i<>0) or (ii<>0) then
  begin
    writeln('WARNING: DOS reported an error. This probably means that the entry');
    writeln('for this game in ',listname,' is wrong.');
    writeln;
    writeln('Please edit this file, using');
    writeln;
    if lo(dosversion)<$05 then
      writeln('  edlin ',listname,' (or similar)')
    else
      writeln('  edit ',listname);
    writeln;
    writeln('and change the line after "',shortname,'" to show the correct path.');
    writeln;
    writeln('More info is in the Avvy documentation. Good luck!');
    writeln;
    write('Press Enter...'); readln;
  end;
end;

begin
  getdir(0,first_dir);
  paramparse;
  getfile;
  if info then show_info;
  load_file;
end.