program reginame;
const
 letters : array[1..36] of char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
var
 name:string[30];
 number:string[5];

procedure alphanum;
var
 fv:byte;
 z:string;
 p:byte;

  procedure replace(what,whatwith:char);
  begin;
   p:=pos(what,z); if p>0 then z[p]:=whatwith;
  end;

begin;
 z:='';
 for fv:=1 to length(name) do
  if name[fv] in ['A'..'Z'] then
   z:=z+'7'+name[fv] else
   z:=z+upcase(name[fv]);
 replace(' ','1');
 replace('.','2');
 replace('-','3');
 replace('''','4');
 replace('"','5');
 replace('!','6');
 replace(',','9');
 replace('?','0');

 for fv:=1 to length(number) do
  number[fv]:=upcase(number[fv]);

 name:=z+'8'+number;
end;

procedure scramble;
var fv,what:byte;
begin;
 for fv:=1 to length(name) do
 begin;
  what:=pos(name[fv],letters);
  inc(what,177);
  inc(what,(fv+1)*3);
  name[fv]:=letters[(what mod 36)+1];
 end;
end;

procedure checks;
var fv,total:byte;
begin;
 total:=177;
 for fv:=1 to length(name) do
  inc(total,ord(name[fv]));
 name:='T'+name+letters[total mod 36];
end;

procedure negate;
var fv:byte;
begin;
 name[1]:='N';
 for fv:=2 to length(name) do
  name[fv]:=letters[37-pos(name[fv],letters)];
end;

begin;
 write('Registrant''s name?'); readln(name);
 write('And number (eg, A1)?'); readln(number);
 alphanum;
 writeln('Name = ',name);
 scramble;
 writeln('Scrambled = ',name);
 checks;
 writeln('With checks = ',name);
 negate;
 writeln('Or, negated, = ',name);
end.