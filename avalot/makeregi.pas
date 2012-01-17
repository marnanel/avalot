program generate_name; { regname's name starts at $7D1 (2001). }

const
 padding : array[1..56] of char =
 'For all the Etruscan armies were ranged beneath his eye';

var
 txi,txo:text;
 x,y:string;
 fv:word;
 f:file of byte;
 sum,n:byte;
 name,number:string;

 CHKNAME,CHKNUM,REGNAME,REGNUM:STRING;


   function decode1(c:char):char;
   var b:byte;
   begin
     b:=ord(c)-32;
     decode1:=chr(( (b and $F) shl 3) + ((b and $70) shr 4));
   end;

   function encode1(c:char):char;
   var b:byte;
   begin
     b:=ord(c);
     b:=( (b and $78) shr 3) + ((b and $7) shl 4);
     encode1:=chr(b+32);
   end;

   function encode2(c:char):char;
   begin
     encode2:=chr((((ord(c) and $F) shl 2)+$43));
   end;

   function enc1(x:string):string;
   var y:string; fv:byte;
   begin
     y:=x; for fv:=1 to length(y) do y[fv]:=encode1(y[fv]);
     enc1:=y;
   end;

   function enc2(x:string):string;
   var y:string; fv:byte;
   begin
     y:=x; for fv:=1 to length(y) do y[fv]:=encode2(y[fv]);
     enc2:=y;
   end;

   function checker(proper,check:string):boolean;
   var fv:byte; ok:boolean;
   begin
     ok:=true;
     for fv:=1 to length(proper) do
       if (ord(proper[fv]) and $F)<>((ord(check[fv])-$43) shr 2)
         then ok:=false;

     checker:=ok;
   end;

  procedure unscramble;
  var namelen,numlen:byte;
  begin

    namelen:=107-ord(x[1]); numlen:=107-ord(x[2]);

    regname:=copy(x,3,namelen);
    regnum:=copy(x,4+namelen,numlen);
    chkname:=copy(x,4+namelen+numlen,namelen);
    chknum:=copy(x,4+namelen+numlen+namelen,numlen);

    for fv:=1 to namelen do regname[fv]:=decode1(regname[fv]);
    for fv:=1 to numlen do regnum[fv]:=decode1(regnum[fv]);

    if (not checker(regname,chkname)) or (not checker(regnum,chknum))
     then begin
       writeln('CHECK ERROR: ',regname,'/',chkname,';',regnum,'/',chknum,'.');
       halt;
     end else writeln('--- Passed both checks. ---');
  end;

begin

 write('Name? '); readln(name);
 write('Number? '); readln(number);

 x:=chr(107-ord(name[0]))+chr(107-ord(number[0]));


 x:=x+enc1(name)+'J'+enc1(number)+enc2(name)+enc2(number);

 number:=''; fv:=1;
 while (length(number)+length(x))<57 do
 begin
   number:=number+padding[fv]; fv:=fv+1;
 end;
 x:=x+enc1(number);


 writeln(x); writeln;
 unscramble;

 assign(txi,'v:register.raw'); reset(txi);
 assign(txo,'a:register.dat'); rewrite(txo);

 for fv:=1 to 53 do
 begin
  readln(txi,y); writeln(txo,y);
 end;

 readln(txi,y); writeln(txo,x);

 while not eof(txi) do
 begin
  readln(txi,y); writeln(txo,y);
 end;

 close(txi); close(txo);
end.