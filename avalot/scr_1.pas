program mediumtext;
uses Crt;

const
 codes : string[4] = ' ßÜÛ';

type
 fonttype = array[#0..#255,0..15] of byte;

var
 x,xx,y:byte;
 title,fn:string;
 f:file of fonttype;
 font:fonttype;
 code:byte;

procedure save;
type atype = array[1..3840] of byte;
var
 f:file of atype;
 fv:word;
 a:atype absolute $B800:0;
begin;
 assign(f,'TEXT1.SCR');
 rewrite(f); write(f,a); close(f);
end;

procedure centre(y:byte; z:string);
begin;
 gotoxy(40-length(z) div 2,y); write(z);
end;

begin;
(* write('Title?'); readln(title);
 write('Font?'); readln(fn); *)
 textattr:=0; clrscr;
 title:='Bug Alert!'; fn:='';
 for xx:=1 to 77 do
 begin;
  gotoxy(random(80)+1,random(24)+1);
  case random(2) of
   0: textattr:=red;
   1: textattr:=lightred;
  end;
  case random(4) of
   0: write('*');
   1: write(#15);
   2: write('ù');
   3: write('ú');
  end;
 end;
 textattr:=12;
 assign(f,'c:\thomas\ttsmall.fnt');
 reset(f); read(f,font); close(f);
 for y:=0 to 3 do
 begin;
  for x:=1 to length(title) do
  begin;
   for xx:=7 downto 0 do
   begin;
    code:=byte(((1 shl xx) and font[title[x],y*2])>0)+
     byte(((1 shl xx) and font[title[x],y*2+1])>0)*2;
    gotoxy(1+x*8-xx,y+1);
    if code>0 then write(codes[code+1]);
   end;
  end;
  (*if wherex<>1 then writeln;*)
 end;
 textattr:=red;
 centre(7,'An internal error has just occurred within the program.');

 textattr:=white; gotoxy(26, 9); write('Error number: ');
  textattr:=lightred; write('   ');
 textattr:=white; gotoxy(27,10); write('at location: ');
  textattr:=lightred; write('           ');
 centre(12,'This screen should never come up...');
 centre(13,'but it just has!');
 textattr:=15;
 centre(15,'So, please tell Thorsoft about this as soon as');
 centre(16,'possible, so that we can fix it.');
 textattr:=red;
 centre(20,'Thanks...');
 save;
end.