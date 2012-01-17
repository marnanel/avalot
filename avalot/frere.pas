program test;
uses Crt;

type
 tunetype = array[1..31] of byte;

const

  lower = 0;
   same = 1;
 higher = 2;

 keys: array[1..12] of char = 'QWERTYUIOP[]';
 notes: array[1..12] of word =
  (196,220,247,262,294,330,350,392,440,494,523,587);

 tune: tunetype =
  (higher,higher,lower,same,higher,higher,lower,higher,higher,higher,
   lower,higher,higher,
   same,higher,lower,lower,lower,lower,higher,higher,lower,lower,lower,
   lower,same,lower,higher,same,lower,higher);

var
 this_one,last_one:byte;

 pressed:char;

 value:byte;

 played: tunetype;

procedure store(what:byte);
begin;

 move(played[2],played[1],sizeof(played)-1);

 played[31]:=what;

end;

function they_match:boolean;
var fv:byte;
begin;

 for fv:=1 to sizeof(played) do
  if played[fv]<>tune[fv] then
  begin;
   they_match:=false;
   exit;
  end;

 they_match:=true;

end;

begin;

 textattr:=30; clrscr; writeln;

 repeat

  pressed:=upcase(readkey);

  value:=pos(pressed,keys);

  if value>0 then
  begin;

   last_one:=this_one;
   this_one:=value;

   sound(notes[this_one]);
   delay(100);
   nosound;

   if this_one<last_one then
    store(lower) else

     if this_one=last_one then
      store(same) else

       store(higher);

   if they_match then
   begin;
    textattr:=94; clrscr; writeln;
    writeln(#7+'It matches!');
    readln;
    halt;
   end;

  end;

 until pressed=#27;

 writeln('*** PROGRAM STOPPED! ***');
end.