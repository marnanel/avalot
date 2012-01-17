{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 FILING           The saving and loading handler. }

program Filing;
{$R+}

(*interface*)

uses Gyro;

const
 months : array[1..12] of string[6] =
  ('Jan*','Feb*','March','April','May','June','July','August',
   'Sept&','Oct&','Nov&','Dec&');
 ednaID = 'TT'+#177+#30+#01+#75+#177+#153+#177;
 systems : array[1..6] of string[7] =
   ('DOS','Windows','OS/2','Mac','Amiga','ST');

type
  edhead = record { Edna header }
            { This header starts at byte offset 177 in the .ASG file. }
            ID:array[1..9] of char; { signature }
            revision:word; { EDNA revision, here 2 (1=dna256) }
            game:string[50]; { Long name, eg Lord Avalot D'Argent }
            shortname:string[15]; { Short name, eg Avalot }
            number:word; { Game's code number, here 2 }
            ver:word; { Version number as integer (eg 1.00 = 100) }
            verstr:string[5]; { Vernum as string (eg 1.00 = "1.00" }
            filename:string[12]; { Filename, eg AVALOT.EXE }
            os:byte; { Saving OS (here 1=DOS). See below for others.}

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

(*implementation*)

var
 f:file;
 fv:byte;
 dna256:array[1..255] of word;
 ok:boolean;
 e:edhead;

procedure info256(x:string); { info on dna256 *.ASG files }
var
 describe:string[40];
begin;
 assign(f,x);
 {$I-} reset(f,1);
 seek(f,47);
 blockread(f,describe,40);
 blockread(f,dna256,sizeof(dna256));
 close(f); {$I+}
 with e do
 begin;
  revision:=1;
  game:='Denarius Avaricius Sextus';
  shortname:='Avaricius';
  number:=1;
  verstr:='[?]';
  filename:='AVVY.EXE';
  os:=1; { Dos }
  fn:=x;
  d:=dna256[7]; m:=dna256[8]; y:=dna256[9];
  desc:=describe;
  len:=512;
  saves:=dna256[6];
  cash:=dna256[30];
  money:=strf(cash)+' denari';
  if cash=1 then money:=money+'us' else money:=money+'i';
  points:=dna256[36];
 end;
end;

function enlarge(x:string):string;
begin;
 case x[length(x)] of
  '*': begin; dec(x[0]); x:=x+'uary'; end;
  '&': begin; dec(x[0]); x:=x+'ember'; end;
 end;
 enlarge:=x;
end;

function th(x:byte):string;
var n:string[4];
begin;
 n:=strf(x);
 case x of
  1,21,31: n:=n+'st';
  2,22: n:=n+'nd';
  3,23: n:=n+'rd';
  else n:=n+'th';
 end;
 th:=n;
end;

begin;
 info256('t:justb4.asg');

 with e do
 begin;
  write('DNA coding: ');
  case revision of
   1: writeln('dna256');
   2: writeln('E.D.N.A.');
   else writeln('Unknown!');
  end;
  writeln('Filename: ',game,' (version ',verstr,')');
  writeln('Description: ',desc);
  writeln('Cash: ',money);
  writeln('Score: ',points);
  writeln('Date: ',th(d),' ',enlarge(months[m]),' ',y);
  writeln('Number of saves: ',saves);
 end;
end.