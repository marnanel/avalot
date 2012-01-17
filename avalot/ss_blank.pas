program ss_blank;
uses Dos,Crt;
var
 fv:byte;
 test:boolean;

function the_cows_come_home:boolean;
var rmove,rclick:registers;
begin;
 rmove.ax:=11; intr($33,rmove);
 rclick.ax:=3; intr($33,rclick);
 the_cows_come_home:=
   (keypressed) or { key pressed }
   (rmove.cx>0) or { mouse moved }
   (rmove.dx>0) or
   (rclick.bx>0);  { button clicked }
end;

begin;
 test:=the_cows_come_home;
 textattr:=0; clrscr;
 repeat until the_cows_come_home;
 textattr:=30; clrscr;
 writeln('*** Blank Screen *** (c) 1992, Thomas Thurman. (An Avvy Screen Saver.)');
 for fv:=1 to 46 do write('~'); writeln;
 writeln('This program may be freely copied.');
 writeln;
 writeln('Have fun!');
end.