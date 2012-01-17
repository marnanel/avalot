{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 ENID             Edna's manager. }

unit Arch; { Loads/ saves files. }

interface

uses Gyro;

procedure save(name:string);

implementation

uses Dos,Scrolls;

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
            os:byte; { Saving OS (here 1=DOS. See below for others.} }

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
     3 = OS/2       6 = ST }
const
 crlf = #13+#10;

 ednafirst : array[1..177] of char =
  'This is an EDNA-based file, saved by a Thorsoft game. Good luck!'+crlf+
  ^Z+ { 67 bytes... }
  crlf+crlf+ { 71 bytes... }
  '12345678901234567890123456789012345678901234567890'+
  '12345678901234567890123456789012345678901234567890'+
  '123456';

 months = 'JanFebMarAprMayJunJulAugSepOctNovDec';
 ednaID = 'TT'+#177+#48+#01+#117+#177+#153+#177;

 ttage = 18;
 ttwashere = 'Thomas was here ';

procedure save(name:string);
var
 f:file;
 eh:edhead;
 groi:word;
 groi2:string;
begin;
 fillchar(eh,sizeof(eh),#177); { Fill up the edhead }

 inc(dna.saves); { It's been saved one more time... }

 with eh do
 begin;

  { Info about this program }

  id:=ednaid;  { Edna's signature }
  revision:=2; { Second revision of .ASG format }
  game:='Lord Avalot d''Argent'; { Title of game }
  shortname:='Avalot';
  number:=2; { Second Avvy game }
  ver:=100; { Version 1.00 }
  verstr:='1.00'; { ditto }
  filename:='AVALOT.EXE'; { program's filename }
  os:=1; { Saved under DOS }

  { Info on this particular game }

  fsplit(name,groi2,fn,groi2); { fn = filename of this game }
  getdate(d,m,y,groi); { Day, month & year when the game was saved }
  desc:=RoomName; { Description of game (same as in Avaricius!) }
  len:=sizeof(dna); { Length of DNA (it's not going to be above 65535!) }

  { Quick reference & miscellaneous }

  saves:=dna.saves; { no. of times this game has been saved }
  cash:=dna.pence; { contents of your wallet in numerical form }
  money:=lsd; { ditto in string form (eg 5/-, or 1 denarius)}
  points:=dna.score; { your score }
 end;

 assign(f,name);
 rewrite(f,1);

 blockwrite(f,ednafirst,177);
 blockwrite(f,eh,sizeof(eh));
 blockwrite(f,dna,sizeof(dna));

 for groi:=1 to ttage do
  blockwrite(f,ttwashere,sizeof(ttwashere));

 close(f);
end;

end.