program visatest;
uses Crt;

var
 block:char;
 point:word;

 result:array[1..2000] of char;
 result_len:word;

procedure unskrimble;
var fv:word;
begin
 for fv:=1 to 2000 do result[fv]:=char((not(ord(result[fv])-fv)) mod 256);
end;

procedure visa_get_scroll(block:char; point:word);
var
 indexfile,sezfile:file;
 idx_offset,sez_offset:word;
begin
 assign(indexfile,'avalot.idx'); assign(sezfile,'avalot.sez');

 reset(indexfile,1);
 seek(indexfile,(ord(upcase(block))-65)*2);
 blockread(indexfile,idx_offset,2);
 seek(indexfile,idx_offset+point*2);
 blockread(indexfile,sez_offset,2);
 close(indexfile);

 reset(sezfile,1);
 seek(sezfile,sez_offset);
 blockread(sezfile,result_len,2);
 blockread(sezfile,result,result_len);
 close(sezfile);
 unskrimble;
end;

procedure access_get_scroll(block:char; point:word);
var
 x:string;
 f:file;
begin
 str(point,x);
 x:='S'+block+x+'.RAW';
 assign(f,x);
 reset(f,1);
 result_len:=filesize(f);
 blockread(f,result,result_len);
 close(f);
end;

procedure display_it;
var fv:word;
begin
 for fv:=1 to result_len do write(result[fv]);
end;

begin
 repeat
  writeln;
  writeln;
  write('Block?'); readln(block);
  write('Point?'); readln(point);

  writeln('ACCESS reports (this one is always correct):');
  writeln; 
  access_get_scroll(block,point);
  display_it;

  writeln; writeln;
  writeln('VISA reports:');
  writeln;
  visa_get_scroll(block,point);
  display_it;
 until false;
end.