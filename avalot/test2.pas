program test2;
uses Dos;
const
 signature:array[1..22] of char = '*AVALOT* v1.00 ±tt± '+#3+#0;
var
 getint1f:pointer;
 x:array[1..22] of char;
begin;
 getintvec($1f,getint1f);
 move(getint1f^,x,22);
 if x=signature then
  writeln('Signature found.') else writeln('Signature NOT found!');
end.