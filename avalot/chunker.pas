program chunker;

type
 flavourtype = (ch_EGA,ch_BGI);

 chunkblocktype = record
                   flavour:flavourtype;
                   x,y:integer;
                   xl,yl:integer;
                   size:longint;
                   natural:boolean;

                   memorise:boolean; { Hold it in memory? }
                  end;

var f:file;
    fn:string;
    num_chunks,fv:byte;
    offset:longint;
    ch:chunkblocktype;

begin
   writeln;
   writeln('CHUNKER 12/3/1995 TT');
   writeln;

   if paramcount<>1 then
   begin
      writeln('which chunk file?');
      halt;
   end;

   fn:=paramstr(1);
   assign(f,fn);
   reset(f,1);
   writeln('----- In chunk file ',fn,', there are: -----');

   seek(f,44);
   blockread(f,num_chunks,1);
   writeln(num_chunks:4,' chunks:');

   writeln('  No  Hdr    Offset  Flvr  Mem Nat      X      Y  Width Height Size of image');

   for fv:=1 to num_chunks do
   begin

      write('Ch',fv:2,':');

      seek(f,41+fv*4);

      write(41+fv*4:4);
      blockread(f,offset,4);
      write(offset:10);

      seek(f,offset);
      blockread(f,ch,sizeof(ch));
      with ch do
      begin
         if flavour=ch_BGI then
            write(' ch_BGI')
         else
            write(' ch_EGA');

         if memorise then
            write(' yes')
         else
            write(' no ');

         if natural then
            write(' yes')
         else
            write(' no ');

         write(x:7,y:7,xl:7,yl:7,size:10);
      end;

      writeln;
   end;

   writeln('---ENDS---');

   close(f);
end.