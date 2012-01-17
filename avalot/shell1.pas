program charmap;
{$M $800,0,0}
uses Dos;
type infotype = record
                 chars:array[128..255,1..8] of byte;
                 data:string;
                end;
var
 table:infotype;
 where:pointer;
 comspec:string;
begin;
 getintvec($1F,where); move(where^,table,1280);
 comspec:=getenv('comspec');
 table.data:=table.data+'Avalot;';
 setintvec($1F,@table);
 writeln;
 writeln('The Astounding Avvy DOS Shell...       don''t forget to register!');
 writeln;
 writeln('Use the command EXIT to return to your game.');
 writeln;
 writeln('Remember: You *mustn''t* load any TSRs while in this DOS shell.');
 writeln;
 writeln('This includes: GRAPHICS, PRINT, DOSKEY, and pop-up programs (like Sidekick.)');
 writeln;
 writeln('About to execute "',comspec,'"...');
 swapvectors;
 exec('c:\command.com','');
 swapvectors;
 setintvec($1F,where);
end.