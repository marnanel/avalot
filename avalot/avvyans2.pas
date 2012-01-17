program textpic_in_ANSI;
uses Graph,Crt,Ansi;
var
 gd,gm:integer;
 f:file;
 aa:array[1..16000] of byte;
 cols:array[0..27,0..35] of byte;
 t:text;
 x:string;
 n:byte;
 spaces:byte;
 cfg,cbg:byte; { Current foreground & background. }
 ofg,obg:byte; { Old fg & bg. }

procedure do_spaces;
begin;
 if spaces=0 then exit;
 along(spaces);
 spaces:=0;
end;

procedure finishline;
var wx,wy:byte;
  procedure jumpto(xx:byte);
  begin;
   along(xx-wx);
  end;
begin;
 wx:=29-spaces; wy:=gm+1;
 case wy of
  1: begin;
      sgr(7); jumpto(35); write('Back in good old A.D. ');
      sgr(15); write('1189'); sgr(7); writeln('...'); cfg:=7;
     end;
  3..7: begin;
         readln(t,x);
         while x[length(x)]=#32 do dec(x[0]);
         if x<>'' then
         begin;
          jumpto(30);
          sgr(9);
          spaces:=0;
          while x<>'' do
          begin;
           if x[1]=' ' then
            inc(spaces)
           else
           begin;
            do_spaces;
            write(x[1]);
           end;
           delete(x,1,1);
          end;
          if wy=7 then close(t);
          writeln;
         end;
        end;
  8: begin;
      jumpto(67); sgr(9); writeln('d''Argent'); cfg:=9;
     end;
  11: begin;
       jumpto(37); sgr(14); writeln('He''s back...');
      end;
  13: begin;
       jumpto(47); sgr(14); writeln('And this time,');
      end;
  14: begin;
       jumpto(52); sgr(14); writeln('he''s wearing tights...');
      end;
  16: begin;
       jumpto(35); sgr(4);
       writeln('A Thorsoft of Letchworth game. * Requires EGA');
      end;
  17: begin;
       jumpto(37); sgr(4);
       writeln('and HD. * By Mike, Mark and Thomas Thurman.');
      end;
  18: begin;
       jumpto(39);
       sgr( 4); write('Sfx archive- ');
       sgr( 9); write('Download ');
       sgr(14); write('AVLT10.EXE');
       sgr( 9); write(' now!');
      end;
  else writeln;
 end;
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 fillchar(cols,sizeof(cols),#0);
 assign(f,'v:avvypic.ptx');
 reset(f,1);
 blockread(f,aa,filesize(f));
 close(f);
 putimage(0,0,aa,0);
 for gd:=0 to 27 do
  for gm:=0 to 34 do
   cols[gd,gm+1]:=getpixel(gd,gm);

 restorecrtmode;

 assign(output,'v:avalot.ans'); rewrite(output); normal; ed;
(* assign(output,''); rewrite(output); normal; ed;*)
 assign(t,'v:avalot.txt'); reset(t);

 for gm:=0 to 17 do
 begin;
  spaces:=0;
  for gd:=0 to 27 do
  begin;
   if (gd=22) and (gm=4) then
   begin;
    do_spaces;
    sgr(red); write('ß');
   end else
   begin;
    if (cols[gd,2*gm]=cols[gd,2*gm+1]) then
    begin;
     if cols[gd,2*gm]=0 then
      inc(spaces) { a blank space }
     else begin;
      do_spaces;

      if cfg=cols[gd,2*gm] then write('Û') else
       if cbg=cols[gd,2*gm] then write(' ') else
       begin;
        sgr((cols[gd,2*gm])+(cbg*16));
        cfg:=cols[gd,2*gm];
        write('Û');
       end;
     end;
    end else
     if (cols[gd,2*gm]>7) and (cols[gd,2*gm+1]<8) then
     begin;
      do_spaces;
      sgr(cols[gd,2*gm]+cols[gd,2*gm+1]*16);
      cfg:=cols[gd,2*gm]; cbg:=cols[gd,2*gm+1]*16;
      write('ß')
     end else
     begin;
      do_spaces;

      ofg:=cfg; obg:=cbg;
      cbg:=cols[gd,2*gm]; cfg:=cols[gd,2*gm+1];

      if (cbg=ofg) and (cfg=obg) then
      begin;
       n:=cfg*16+cbg;
       if n>128 then dec(n,128);
       write('ß');
      end else
      begin;
       n:=cbg*16+cfg;
       if n>128 then dec(n,128);
       if (cfg<>ofg) or (cbg<>obg) then sgr(n);
       write('Ü');
      end;

     end;
    end;
   end; finishline;
  end;
 writeln;
 normal;
end.