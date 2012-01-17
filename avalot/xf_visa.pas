program transfer_Visa;
uses Crt,Dos;
{$R+}

const
 used : string[9] = 'DNPQSTUXZ';

 header : string[12] = 'Avalot Sez:'+#26;

var
 sez,infile:file;
 s:searchrec;

 positions:array['A'..'Z',0..99] of word;
 maxlen:array['A'..'Z'] of word;

 speak_positions:array[1..50,0..255] of word;
 speak_maxlen:array[1..50] of word;

 data:array[1..2000] of char;
 data_length:word;

 fv:byte;

function numeric_bit:byte;
var x:string[5]; e:integer; result:byte;
begin
 x:=copy(s.name,3,pos('.',s.name)-3);
 val(x,result,e);
 if e<>0 then
 begin
  writeln('NUMERIC ERROR: ',s.name,'/',x);
  halt(255);
 end;
 numeric_bit:=result;
end;

function speak_left:byte;
var x:string; e:integer; result:byte;
begin
 x:=copy(s.name,3,pos('.',s.name)-3);
 x:=copy(x,1,pos('-',x)-1);
 val(x,result,e);
 if e<>0 then
 begin
  writeln('NUMERIC ERROR (left): ',s.name,'/',x);
  halt(255);
 end;
 speak_left:=result;
end;

function speak_right:byte;
var x:string; e:integer; result:byte;
begin
 x:=copy(s.name,3,pos('.',s.name)-3);
 x:=copy(x,pos('-',x)+1,255);
 val(x,result,e);
 if e<>0 then
 begin
  writeln('NUMERIC ERROR (right): ',s.name,'/',x);
  halt(255);
 end;
 speak_right:=result;
end;

procedure write_out;
var
 points:array['A'..'Z'] of word;
 speak_points:array[1..50] of word;
 outf:file;
 fv:byte;
begin
 fillchar(points,sizeof(points),#0);
 fillchar(speak_points,sizeof(speak_points),#0);

 assign(outf,'v:avalot.idx');
 rewrite(outf,1);
 blockwrite(outf,points,sizeof(points));

 for fv:=1 to length(used) do
 begin
  points[used[fv]]:=filepos(outf);
  blockwrite(outf,positions[used[fv]],maxlen[used[fv]]*2+2);
 end;

 seek(outf,0);
 blockwrite(outf,points,sizeof(points));

 close(outf);

 { --- now the speech records --- }

 assign(outf,'v:converse.avd');
 rewrite(outf,1);
 blockwrite(outf,speak_points,sizeof(speak_points));

 for fv:=1 to 15 do
 begin
  speak_points[fv]:=filepos(outf);

  blockwrite(outf,speak_positions[fv],speak_maxlen[fv]*2+2);
 end;

 seek(outf,0);
 blockwrite(outf,speak_points,sizeof(speak_points));

 close(outf);
end;

procedure skrimble;
var fv:word;
begin
 for fv:=1 to 2000 do data[fv]:=char((not(ord(data[fv]))+fv) mod 256);
end;

begin
 fillchar(positions,sizeof(positions),#0);
 fillchar(maxlen,sizeof(maxlen),#0);

 clrscr;

 assign(sez,'v:avalot.sez');
 rewrite(sez,1);
 blockwrite(sez,header[1],12);

 findfirst('s*.raw',anyfile,s);
 while doserror=0 do
 begin
  assign(infile,s.name);
  reset(infile,1);
  blockread(infile,data,2000,data_length);
  close(infile);

  clrscr;
  if pos('-',s.name)=0 then
  begin { Not a speech record. }
   writeln(s.name,numeric_bit:10);

   positions[s.name[2],numeric_bit]:=filepos(sez);
   if maxlen[s.name[2]]<numeric_bit then maxlen[s.name[2]]:=numeric_bit;

  end else
  begin { A speech record. }
   writeln(s.name,speak_left:10,speak_right:10,' SR');

   speak_positions[speak_left,speak_right]:=filepos(sez);
   if speak_maxlen[speak_left]<speak_right then
       speak_maxlen[speak_left]:=speak_right;
  end;

  skrimble;

  blockwrite(sez,data_length,2);
  blockwrite(sez,data,data_length);

  findnext(s);
  clreol;
 end;

 close(sez);

 write_out; 
end.