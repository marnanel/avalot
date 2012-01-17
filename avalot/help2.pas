program help2;
uses Graph,Crt;
type
 fonttype = array[#0..#255,0..15] of byte;

 hypertype = record
              trigger:char;
              line:byte;
              start,finish:byte;
              ref:word;
             end;

var
 gd,gm:integer;
 font:array[1..2] of fonttype;
 current:array[0..7,1..80] of byte;
 data:array[1..250] of string[79];
 fv,position,size:integer;
 title:string[79];
 link:array[1..20] of hypertype;
 numlinks:byte;
 r:char;
 reverse:array[0..9] of byte;
 revpos:array[0..9] of byte;

procedure loadfont;
var fontfile: file of fonttype;
begin;
 assign(fontfile,'c:\thomas\ttsmall.fnt'); reset(fontfile);
 read(fontfile,font[1]); close(fontfile);
(* assign(fontfile,'c:\avalot\avalot.fnt'); reset(fontfile);
 read(fontfile,font[2]); close(fontfile);*)
 { NB: We'll put BOTH of these fonts one after the other, in the same
   file, in the final compilation. }
end;

procedure scribe(which,what:byte);
  procedure underline(var x:byte); begin; x:=x or 177; end;
var fv,ff:byte; x:string;
begin;
 x:=data[what];
 fillchar(current,sizeof(current),#0);
 for ff:=1 to length(x) do
  for fv:=0 to 7 do
  begin;
   current[fv,ff]:=font[which,x[ff],fv];
  end;

 for fv:=1 to numlinks do
  with link[fv] do
   if line=what then
    for ff:=start to finish do
     underline(current[7,ff]);

end;

procedure display(y:word);
begin;
 for fv:=0 to 7 do
  move(current[fv],mem[$A000:(y+fv)*80],79);
end;

procedure update_link(which:char; whence,whither:byte);
var fv:byte;
begin;
 for fv:=1 to numlinks do
  with link[fv] do
   if trigger=which then
   begin;
    line:=size;
    start:=whence;
    finish:=whither;
   end;
end;

procedure getlinks(var x:string);
var p,q:byte;
begin;
 repeat
  p:=pos('[',x);
  if p=0 then exit; { lousy, huh? }
  q:=pos(']',x); 
  update_link(x[p+1],p,q-3);
  delete(x,q,1); delete(x,p,2);
 until false;
end;

procedure loaddata(which:byte);
var
 t:text;
 x:string;
 e:integer;
begin;
 revpos[9]:=position;
 fillchar(data,sizeof(data),#0);
 move(reverse[1],reverse[0],9);
 move(revpos[1],revpos[0],9);
 reverse[9]:=which; revpos[9]:=1;

 str(which,x);
 assign(t,'h'+x+'.raw');
 reset(t);
 readln(t,title);
 size:=0; numlinks:=0;
 while not eof(t) do
 begin;
  readln(t,x);
  if x[1]=':' then
  begin;
   inc(numlinks);
   with link[numlinks] do
   begin;
    trigger:=x[2];
    delete(x,1,3);
    delete(x,pos(' ',x),255);
    val(x,ref,e);
   end;
  end else begin;
   inc(size);
   getlinks(x);
   data[size]:=x;
  end;
 end;
 position:=1; dec(size,15);
 close(t);
end;

procedure screen;
begin;
 setbkcolor(1);
 setfillstyle(1,1);  bar(0,0,640,38);
 setfillstyle(1,14); bar(0,39,640,39);
end;

procedure showscreen;
var fv:byte;
begin;
 if position<1 then position:=1;
 for fv:=0 to 15 do
 begin;
  scribe(1,fv+position);
  display(41+fv*10);
 end;
end;

procedure up;
var fv:byte;
begin;
 dec(position);
 scribe(1,position);
 for fv:=0 to 9 do
 begin;
  move(mem[$A000:3200],mem[$A000:3280],12720);
  if fv in [0,9] then fillchar(mem[$A000:3200],79,#0) else
   move(current[8-fv],mem[$A000:3200],80);
 end;
end;

procedure down;
var fv:byte;
begin;
 inc(position);
 scribe(1,position+15);
 for fv:=0 to 9 do
 begin;
  move(mem[$A000:3280],mem[$A000:3200],12720);
  if fv in [0,9] then fillchar(mem[$A000:15920],79,#0) else
   move(current[fv-1],mem[$A000:15920],80);
 end;
end;

procedure newpage(c:char);
var fv:byte;
begin;
 for fv:=1 to numlinks do
  with link[fv] do
   if trigger=c then
   begin;
    loaddata(ref);
    showscreen;
   end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 loadfont;
 screen;
 loaddata(0);
 showscreen;
 fillchar(reverse,sizeof(reverse),#0);
 fillchar(revpos,sizeof(revpos),#1);
 repeat
  r:=upcase(readkey);
  case r of
   #0: case readkey of
        'H': if position>1 then up;
        'P': if position<size then down;
        'I': begin; dec(position,16); showscreen; end;
        'Q': begin; inc(position,16); showscreen; end;
        'G': begin; position:=1; showscreen; end;
        'O': begin; position:=size; showscreen; end;
    end;
   'B': begin; { go Back }
         gd:=reverse[8];
         gm:=revpos[8];
         move(reverse[0],reverse[2],8);
         move(revpos[0],revpos[2],8);
         loaddata(gd); position:=gm;
         showscreen;
        end;
   'C': begin; { Contents }
         loaddata(0);
         showscreen;
        end;
   'H': begin;
         loaddata(7); { help on help }
         showscreen;
        end;
   #27: halt;
   else newpage(r);
  end;
 until false;
end.