program init_transfer;
uses Crt;
type
 inirex = record
           a:string[12];
           num:word;
          end;

var
 i:text;
 o:file of inirex;
 x:inirex;

begin;
 assign(i,'v:init0.dat'); reset(i);
 assign(o,'v:init.avd'); rewrite(o);

 while not eof(i) do
 begin;
  readln(i,x.a);
  readln(i,x.num);
  write(o,x);
  write('.');
 end;

 close(i); close(o);
 writeln;
end.