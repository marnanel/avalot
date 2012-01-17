program charmap;
uses Dos,Graph;
type infotype = record
                 chars:array[128..255,1..8] of byte;
                 data:string;
                end;
var
 table:infotype;
 where:pointer;
 gd,gm:integer;
begin;
 getintvec($1F,where); move(where^,table,1280);
 gd:=1; gm:=0; initgraph(gd,gm,'c:\turbo');
 writeln('Now in CGA low-res 320x200.');
 writeln('High ASCII codes work- œœœ °±² ðððññóòôõ');
 writeln('And the code is...');
 writeln(table.data);
 writeln('Press Enter...');
 readln; closegraph;
end.