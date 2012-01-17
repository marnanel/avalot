program info_test;

const
 months = 'JanFebMarAprMayJunJulAugSepOctNovDec';
 ednaID = 'TT'+#177+#30+#01+#75+#177+#153+#177;

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

var
 f:file;
 fv:byte;
 dna256:array[1..255] of word;
 ok:boolean;
 e:edhead;

procedure info(x:string); { info on .ASG files }
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
  revision:=1;
  game:='Denarius Avaricius Sextus';
  shortname:='Avaricius';
  number:=1;
  verstr:='[?]';
  filename:='AVVY.EXE';
  os:=1;
  fn:=x;
  d:=dna256[7]; m:=dna256[8]; y:=dna256[9];
  desc:=describe;
  len:=512;
  saves:=dna256[6];
  cash:
  money:string[20]; { ditto in string form (eg 5/-, or 1 denarius)}
  points:word; { your score }
end;

begin;
 info('tt.asg');

 writeln('Filename: ',x);
 writeln('Description: ',desc);
 writeln('Cash: ',dna256[30]);
 writeln('Score: ',dna256[36]);
 writeln('Date: ',dna256[7],' ',copy(months,dna256[8]*3-2,3),' ',dna256[9]);
 writeln('Number of saves: ',dna256[6]);
end.