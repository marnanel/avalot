program help_xf;
uses Crt,Tommys;

const
  max_pages = 34;

var
 fv:byte;
 i:text;
 o:file;
 x:string;
 t:char;
 p,w:byte;

 where:array[0..max_pages] of word;

procedure out(x:string);
var fz:byte;
begin
 for fz:=1 to length(x) do
   x[fz]:=chr(ord(x[fz]) xor 177);
 blockwrite(o,x[0],1);
 blockwrite(o,x[1],length(x));
end;

begin
 assign(o,'help.avd');
 rewrite(o,1);

 blockwrite(o,where,sizeof(where));

 for fv:=0 to max_pages do
 begin
  where[fv]:=filepos(o);

  assign(i,'h'+strf(fv)+'.raw');
  reset(i);

  readln(i,x); { Title. }
  out(x);

  readln(i,p); { Picture. }
  blockwrite(o,p,1);

  repeat
   readln(i,x);
   out(x);
  until x='!';

  while not eof(i) do
  begin
   readln(i,x);
   if x='-' then
   begin { Null point }
    t:=#0; p:=0; w:=177;
   end else
   begin { Has a point. }
    readln(i,t);
    readln(i,p);
    readln(i,w);
   end;

   blockwrite(o,t,1);
   blockwrite(o,p,1);
   blockwrite(o,w,1);
  end;

  t:=#177;
  blockwrite(o,t,1);
  blockwrite(o,p,1);
  blockwrite(o,w,1);

  close(i);

 end;

 seek(o,0); blockwrite(o,where,sizeof(where));

 close(o);
end.