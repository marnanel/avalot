program readsez;

type
 markertype = record
               length:word;
               offset:longint;
               checksum:byte;
              end;

 sezheader = record
              initials:array[1..2] of char; { should be "TT" }
              gamecode:word;
              revision:word; { as 3- or 4-digit code (eg v1.00 = 100) }
              chains:longint; { number of scroll chains }
              size:longint; { total size of all chains }
             end;

var
 f:file;
 number:longint;
 marker:markertype;
 sezhead:sezheader;
 x:array[0..1999] of char;
 fv:word;
 sum:byte;

function sumup:byte;
var fv:word; total:byte;
begin;
 total:=0;
 for fv:=0 to marker.length do
 begin;
  inc(total,ord(x[fv]));
 end;
 sumup:=total;
end;

begin;
 writeln('READ-SEZ by TT.'); writeln;
 assign(f,'avalot.sez'); reset(f,1);
 seek(f,255); blockread(f,sezhead,sizeof(sezhead));
 with sezhead do
 begin;
  if initials<>'TT' then
  begin;
   writeln('Not a valid Sez file!');
   halt;
  end;
  writeln('Number of chains in file = ',chains);
  writeln('Total size of all chains = ',size,' bytes.');
 end;
 writeln;
 write('Number of scrollchain to display?'); readln(number);
 seek(f,262+number*7); blockread(f,marker,7);
 with marker do
 begin;
  writeln('Scrollchain no. ',number);
  writeln('Length: ',length);
  writeln('Offset: ',offset);
  writeln;
  writeln('Contents:');
  seek(f,270+sezhead.chains*7+offset);
  blockread(f,x,length+1);
  for fv:=0 to length do dec(x[fv],3+177*fv*length); { unscramble }
  for fv:=0 to length do write(x[fv]);
  writeln; sum:=sumup;
  writeln('Checksum in file: ',checksum,'. Actual value: ',sum,'.');
  writeln;
  if sum<>checksum then
  begin;
   writeln('Bleargh! Checksum failed!');
   halt;
  end;
 end;
 close(f);
end.