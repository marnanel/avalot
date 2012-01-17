program hibits;
var
 inf,outf:file of char;
 x:char;
 q:string;
 fv:byte;
begin;
 assign(inf,'v:thank.you');
 assign(outf,'d:hibits.out');
 reset(inf); rewrite(outf);

 q:=#32+'(Seven is a bit of a lucky number.)'+#32+#141+#138+#138;

 for fv:=1 to length(q) do write(outf,q[fv]);

 while not eof(inf) do
 begin;
  read(inf,x);
  if x<#128 then inc(x,128);
  write(outf,x);
 end;
 close(inf); close(outf);
end.