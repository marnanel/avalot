program sezxfr;
uses Crt; {$V-}
var
 t:text;
 x:string;
 data:array[1..100,1..2] of string;
 dp,ip,fv:word;
 index:array[1..20] of word;
 names:array[1..20] of string[10];
 thumb:array[1..1777] of longint; total:longint;
 f:file;

procedure strip; begin; x:=copy(x,2,255); end;

procedure squish(var q:string);
var n:string; ctrl:boolean; fv:byte;
begin;
 ctrl:=false; n:='';
 for fv:=1 to length(q) do
  if q[fv]='^' then ctrl:=true else
  begin; { not a caret }
   if ctrl then q[fv]:=chr(ord(upcase(q[fv]))-64);
   n:=n+q[fv]; ctrl:=false;
  end;
 while n[length(n)]=#32 do dec(n[0]); { strip trailing spaces }
 for fv:=1 to length(n) do inc(n[fv],177); { scramble }
 q:=n;
end;

begin;
 dp:=0; ip:=0; fillchar(data,sizeof(data),#0);
 fillchar(thumb,sizeof(thumb),#177);
 fillchar(index,sizeof(index),#3);
 assign(t,'v:sez.dat'); reset(t);
 while not eof(t) do
 begin;
  readln(t,x);
  case x[1] of
   ';': begin; textattr:=lightred; strip; end;
   ':': begin;
         textattr:=lightblue; strip;
         if dp>0 then squish(data[dp,2]);
         inc(dp); data[dp,1]:=x;
         if pos('*',x)>0 then
         begin; { index }
          inc(ip); index[ip]:=dp; names[ip]:=copy(x,1,pos('*',x)-1);
         end;
        end;
   else
   begin;
    textattr:=white;
    data[dp,2]:=data[dp,2]+x+#32;
   end;
  end;
  writeln(x);
 end;
 squish(data[dp,2]);

 total:=1;
 for fv:=1 to dp do
 begin;
  thumb[fv]:=total;
  inc(total,length(data[fv,2])+1);
 end;

 thumb[dp+1]:=total;

 { save it all! Firstly, the Sez file... }

 assign(f,'v:avalot.sez'); rewrite(f,1);
 x:='This is a Sez file for an Avvy game, and it''s copyright!'+#26;
 blockwrite(f,x[1],57);
 blockwrite(f,dp,2); blockwrite(f,ip,2);
 blockwrite(f,index,40);
 blockwrite(f,thumb,dp*4+4);
 for fv:=1 to dp do
  blockwrite(f,data[fv,2],length(data[fv,2])+1);
 close(f);

 { ...then the Sed file. }

 assign(t,'v:avalot.sed'); rewrite(t);
 for fv:=1 to ip do writeln(t,names[fv]);
 for fv:=1 to dp do writeln(t,data[fv,1]);
 close(t);

 { Done! }
end.