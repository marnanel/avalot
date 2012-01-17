program charmap;
uses Dos;
type infotype = record
                 chars:array[128..255,1..8] of byte;
                 data:string;
                end;
var
 table:infotype;
 where:pointer;
 w,fv,ff,num:byte;
begin;
 getintvec($1F,where); move(where^,table,1024);
 for w:=128 to 255 do
 begin; writeln(w);
 for fv:=1 to 8 do
 begin;
  num:=table.chars[w,fv];
  for ff:=1 to 8 do
  begin;
   if (num and 128)=0 then write('  ') else write('лл');
   num:=num shl 1;
  end;
  writeln;
 end; end;
end.