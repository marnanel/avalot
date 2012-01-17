program magidraw;
uses Graph;

const
 pagetop : longint = 81920;
 nextcode : word = 17717;

var
 gd,gm:integer;
 magic,out:file of word;
 next,gg:word;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 assign(magic,'v:magicirc.avd'); reset(magic);
 assign(out,'v:magic2.avd'); rewrite(out);
 move(mem[$A000:0],mem[$A000:pagetop],16000);
 while not eof(magic) do
 begin;
  read(magic,next);
  if next<>nextcode then
   mem[$A000:next]:=255
  else
  begin;
   for gg:=0 to 16000 do
    if mem[$A000:gg]<>mem[$A000:gg+pagetop] then
     write(out,gg);
   write(out,nextcode);
   move(mem[$A000:0],mem[$A000:pagetop],16000);
  end;
 end;
 close(magic); close(out);
end.