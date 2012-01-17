program test;
{$M 2048,0,0}
uses Dos;
const
 signature:array[1..22] of char = '*AVALOT* v1.00 ±tt± '+#3+#0;
var
 saveint1f:pointer;
begin;
 getintvec($1f,saveint1f);
 setintvec($1f,@signature);
 swapvectors;
 exec('c:\command.com','');
 swapvectors;
 setintvec($1f,saveint1f);
end.
