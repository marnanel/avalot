program sez;
uses Crt;
{$V-}

const xls : array[#1..#31] of char =
 {ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_}
 'จ"ํจจจจจจจ?จจจจจจจจจจจจจ';
const spc = '   ';

type sctype = array[1..25,1..80,1..2] of char;

var
 z:string;
 sc:sctype;
 x,y,fv:byte;
 xlat:boolean;
 title:array[1..100] of string[30];
 lines:array[1..1000] of ^string;
 c_index,c_offset:byte;

 dp,ip,thumbc,scrollpos:word;
 index:array[1..20] of word;
 names:array[1..20] of string[80];
 thumb:array[1..1777] of longint;

procedure clear;
var x,y:byte;
begin;
 for x:=1 to 80 do for y:=1 to 25 do
  begin; sc[y,x,1]:=#0; sc[y,x,2]:=#48; end;
end;

procedure show;
begin;
 move(sc,mem[$B800:0],4000);
end;

procedure take;
begin;
 move(mem[$B800:0],sc,4000);
end;

procedure line(y:byte);
var fv:byte;
begin;
 for fv:=1 to 80 do begin; sc[y,fv,1]:='๗'; sc[y,fv,2]:=#49; end;
end;

procedure display(xx,yy:byte; q:string; col:char);
var fv:byte;
begin;
 x:=xx; y:=yy;
 for fv:=1 to length(q) do
 begin;
  if q[fv]>#31 then
  begin;
   sc[y,x,1]:=q[fv];
   sc[y,x,2]:=col;
  end else
  begin;
   if xlat then
   begin;
    sc[y,x,1]:=xls[q[fv]];
    sc[y,x,2]:=#30;
   end else
   begin;
    sc[y,x,1]:=chr(ord(q[fv])+96);
    sc[y,x,2]:=#78;
   end;
  end;
  inc(x);
  if x=81 then
   begin; x:=1; inc(y); end;
 end;
 sc[y,x,1]:=#0; sc[y,x,2]:=col;
 show;
end;

procedure preview(q:string);
var r:char; i:string; y,n:byte; centring:boolean;

  procedure left;
   begin; textattr:=9; gotoxy(1,y); write(i); inc(y); i:=''; end;
  procedure centre;
   begin; textattr:=2; gotoxy(40-length(i) div 2,y); write(i); inc(y); i:=''; end;
  procedure linebreak;
  begin;
   if i[length(i)]=^C then begin; centring:=true; dec(i[0]); end;
   if i[length(i)]=^L then begin; centring:=false; dec(i[0]); end;
   if centring then centre else left; inc(y);
  end;

  procedure light(x:string);
  begin; textattr:=15; writeln('<'+x+'>'); textattr:=9; inc(y); end;

begin;
 take; textattr:=9; clrscr; y:=1; n:=1; i:=''; centring:=false;
 if not(q[length(q)] in [^D,^P,^Q,^B]) then q:=q+^P;
 if q[length(q)]=^D then dec(q[0]);

 while n<=length(q) do
 begin;
  case q[n] of
   ^M: linebreak;
   ^P: begin; linebreak; light('Pagebreak'); end;
   ^B: begin; linebreak; light('Bubble'); end;
   '@': i:=i+' Speaker ';
   ^U: i:=i+'[cash balance]';
   else i:=i+q[n];
  end;
  inc(n);
 end;

 textattr:=cyan; write('Any key...'); r:=readkey;
 show;
end;

procedure edit(var q:string);
var r:char; u:byte;
begin;
 clear;
 display(1,1,'Thorsoft Avvy Lanche Sez Editor...',#52); line(2); line(25);
 u:=1;
 repeat
  display(1,3,q,#48); gotoxy(u mod 80,3+u div 80);
  r:=readkey;
  case r of
   #0: case readkey of
        'A': preview(q); { f7- preview feature! }
        'C': xlat:=not xlat; { f9- toggle translation }
        'D': exit; { f10- exit }
        'K': if u>1 then dec(u); { left }
        'M': if u<length(q) then inc(u); { right }
        'G': u:=1;
        'O': u:=length(q)+1;
        's': if u>1 then repeat dec(u) until (q[u-1]=#32) or (u=1); { ^left }
        't': if u<length(q) then
              repeat inc(u) until (q[u-1]=#32) or (u=length(q)); { ^right }
        'S': q:=copy(q,1,u-1)+copy(q,u+1,255);
       end;
   #8: if u>1 then begin; q:=copy(q,1,u-2)+copy(q,u,255); dec(u); end;
   #9: begin; q:=copy(q,1,u-1)+^p+copy(q,u,255); inc(u); end;
   else begin; q:=copy(q,1,u-1)+r+copy(q,u,255); inc(u); end;
  end;
 until false;
end;

procedure loadsed;
var t:text; fv:byte;
begin;
 assign(t,'v:avalot.sed');
 reset(t);
 for fv:=1 to ip do readln(t,names[fv]);
 for fv:=1 to dp do readln(t,title[fv]);
 close(t);
end;

procedure pick(var q:byte; limit:byte);
var r:char;
begin;
 q:=1;
 repeat
  gotoxy(2,q); write(^D); r:=readkey; write(^H+' ');
  case r of
   #13: exit;
   #27: begin; q:=177; exit; end;
   #0: case readkey of
        'H': if q>1 then dec(q);
        'P': if q<limit then inc(q);
        'O': q:=limit;
        'G': q:=1;
       end;
  end;
 until false;
end;

procedure loadsez;
begin;
 Boogie boogie boogie, this will cause an error because I haven't finished
 it yet!
  for ff:=1 to length(z) do dec(z[ff],177);
end;

procedure selectscroll;
begin;
 repeat
  clrscr;
  for fv:=index[c_index] to index[c_index+1]-1 do
   writeln(spc+title[fv]);
  pick(c_offset,index[c_index+1]-index[c_index]);
  if c_offset=177 then exit;
  dec(c_offset,1);
  textmode(co80);
  loadsez; edit(z);
  textmode(256);
 until false;
end;

procedure selectindex;
begin;
 repeat
  textmode(256);
  textattr:=31; clrscr;
  for fv:=1 to ip do
  begin;
   write(spc+names[fv]);
   clreol; writeln;
  end;
  pick(c_index,ip);
  if c_index=177 then exit;
  selectscroll;
 until false;
end;

procedure setupload;
var
 f:file;
 fv:word;
 ff:byte;
begin;
 assign(f,'v:avalot.sez'); reset(f,1);
 seek(f,57); blockread(f,dp,2); blockread(f,ip,2); { should be 78 & 4. It works!!! }
 seek(f,61); blockread(f,index,ip*2);
 blockread(f,thumb,dp*4+4);
 for fv:=1 to dp do
 begin;
  new(lines[fv]);
  blockread(f,lines^[fv,2,0],1);
  blockread(f,lines^[fv,2,1],length(lines^[fv,2]));
 end;

 (* Routines for loading from disk:
  thumb:=index[c_index]+c_offset;
  write('Thumbcode= ',index[c_index],'+',c_offset,'= ',thumbc,'.');
  seek(f,101+thumbc*4);
  blockread(f,scrollpos,2);
  writeln('Scroll position= ',scrollpos,'.');
  seek(f,104+dp*4+scrollpos);
  blockread(f,z[0],1); blockread(f,z[1],length(z));
  for ff:=1 to length(z) do dec(z[ff],177);
 *)

 close(f);
end;

begin;
 xlat:=false; setupload; loadsed;
 selectindex;
end.