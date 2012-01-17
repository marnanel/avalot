program makesez;

type
 sezheader = record
              initials:array[1..2] of char; { should be "TT" }
              gamecode:word;
              revision:word; { as 3- or 4-digit code (eg v1.00 = 100) }
              chains:longint; { number of scroll chains }
              size:longint; { total size of all scroll chains }
             end;

const
 crlf = #13+#10;
 tabs = #9+#9+#9+#9+#9+#9+#9;
 eof = #26;

var
 sez:file;
 header:sezheader;
 x:string;
 check:char;

begin;
 fillchar(x,sizeof(x),#177);
 x:='This is a Sez file for an Avvy game, and its contents are subject'+crlf+
    'to copyright. Have fun with the game!'+crlf+crlf+tabs+'tt'+crlf+crlf+
    '[Lord Avalot D''Argent]'+crlf+crlf+eof+
    crlf+crlf+'Thomas was here!';
 with header do
 begin;
  initials:='TT';
  gamecode:=2; { code for Avalot }
  revision:=100; { version 1.00 }
  chains:=0; { no chains }
  size:=0; { empty! }
 end;
 check:=#177;
 assign(sez,'avalot.sez');
 rewrite(sez,1);
 blockwrite(sez,x[1],255);
 blockwrite(sez,header,sizeof(header));
 blockwrite(sez,check,1);
 x:=#0+#0+#0+'Thomas was here, too!'+crlf+crlf+'Good luck...';
 blockwrite(sez,x[1],39); { footer }
 close(sez);
end.