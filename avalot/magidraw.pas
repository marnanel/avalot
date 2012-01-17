program magidraw;
uses Graph,Crt;

const
 nextcode : word = 17717;

var
 gd,gm:integer;
 magic:file; (* of word;*)
 next:word;
 buffer:array[1..16401] of word;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 assign(magic,'v:magic2.avd'); reset(magic,1);
 blockread(magic,buffer,sizeof(buffer));
 close(magic);
(* while not eof(magic) do*)
 for gd:=1 to 16401 do
 begin;
(*  read(magic,next);
  if next<>nextcode then*)
  if buffer[gd]<>nextcode then
   mem[$A000:buffer[gd]]:=255
  else
   delay(1);
 end;
(* close(magic);*)
end.