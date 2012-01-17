unit sezunit;

	interface

uses Gyro;

type
 sezheader = record
              initials:array[1..2] of char; { should be "TT" }
              gamecode:word;
              revision:word; { as 3- or 4-digit code (eg v1.00 = 100) }
              chains:longint; { number of scroll chains }
              size:longint; { total size of all chains }
             end;


var
 chain:array[0..1999] of char; { This chain }
 chainsize:word; { Length of "chain" }
 sezerror:byte; { Error code }
 sezhead:sezheader;

const { Error codes for "sezerror" }
 sezOk = 0;
 sezGunkyfile = 1;
 sezHacked = 2;


procedure sez_setup;

procedure getchain(number:longint);


	implementation

type
 markertype = record
               length:word;
               offset:longint;
               checksum:byte;
              end;

var
 f:file;
 number:longint;
 marker:markertype;
 fv:word;
 sum:byte;

procedure sez_setup; { This procedure sets up the Sez system (obviously!) }
begin;

  { Set up variables }

 fillchar(chain,sizeof(chain),#177); { blank out gunk in "chain" }
 chainsize:=0; { it's empty (for now...) }
 sezerror:=sezok; { everything's fine! }

  { Set up AVALOT.SEZ }

 assign(f,'avalot.sez'); reset(f,1);
 seek(f,255); blockread(f,sezhead,sizeof(sezhead));
 if ioresult<>0 then begin; sezerror:=sezGunkyfile; exit; end; { too short }
 with sezhead do
 begin;
  if (initials<>'TT') or (gamecode<>thisgamecode)
   or (revision<>thisvercode) then
  begin;
   sezerror:=sezGunkyfile; { not a valid file }
   exit;
  end;
 end;
end;

function sumup:byte;
var fv:word; total:byte;
begin;
 total:=0;
 for fv:=0 to chainsize do
 begin;
  inc(total,ord(chain[fv]));
 end;
 sumup:=total;
end;

procedure getchain(number:longint);
begin;
 seek(f,262+number*7); blockread(f,marker,7);
 with marker do
 begin;
  seek(f,270+sezhead.chains*7+offset);
  blockread(f,chain,length+1);
  for fv:=0 to length do dec(chain[fv],3+177*fv*length); { unscramble }
  chainsize:=length;
  if sumup<>checksum then
  begin;
   sezerror:=sezHacked;
   exit;
  end;
 end;
 close(f);
 sezerror:=sezok; { nowt went wrong }
end;

end.