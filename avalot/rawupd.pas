program raw_update;
uses Dos,Crt;
var
 s:searchrec;
 x,y:string;
 hash_time,s_time:longint;
 s_exists:boolean;

procedure find_out_about_s(name:string);
var ss:searchrec;
begin;
 findfirst(name,anyfile,ss);
 s_exists:=doserror=0;

 if s_exists then
  s_time:=ss.time;
end;

procedure get_y;
begin
 y:=x;
 if x[2] in ['0'..'9'] then
  y[1]:='h' else
  if x[3]='K' then
   y[1]:='a' else
    y[1]:='s';
end;

procedure rename_it;
var f:file;
begin
 write(x,' -> ',y);
 assign(f,x); reset(f); rename(f,y); close(f);
 writeln(' ...done.');
end;

begin
 writeln;
 findfirst('#*.*',anyfile,s);
 while doserror=0 do
 begin
  x:=s.name;
  get_y;
  hash_time:=s.time;
  write(x:15); clreol;
  find_out_about_s(y);
  if s_exists then
  begin
   write(': s exists and is ');
   if s_time<hash_time then
    writeln('NEWER!')
    else if s_time=hash_time then
     write('equal.'+#13)
      else writeln('older.');
  end else
  begin
   write(' ... NO S FOUND! Renaming...');
   rename_it;
  end;

  findnext(s);
 end;
end.