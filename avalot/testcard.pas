program testcard;
uses Graph,Dos;
var
 gd,gm:integer;
 filename:string;

 f:file; bit:byte;
 a:byte absolute $A000:800;
 r:searchrec;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');

 for gd:=0 to 14 do
  for gm:=0 to 11 do
  begin;
   setfillstyle(gm,gd+1);
   bar(gd*43,gm*12+10,42+gd*43,gm*12+21);
  end;

 writeln; writeln; writeln; writeln;

 writeln('Thorsoft testcard.');
 writeln;
 write('Room number? '); readln(filename);

 findfirst('place'+filename+'.avd',anyfile,r);
 if doserror=0 then
 begin;
  writeln('*** ALREADY EXISTS! CANCELLED! ***');
  readln;
  halt;
 end;

 writeln;
 writeln('*** Until this room is drawn, this screen is standing in for it. ***');
 writeln;
 write('Any other comments? ');
 readln;

 assign(f,'place'+filename+'.avd');
 rewrite(f,1);
 blockwrite(f,gd,177); { just anything }
 for bit:=0 to 3 do
 begin;
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  blockwrite(f,a,12080);
 end;
 close(f);
end.