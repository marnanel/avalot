{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 INCLINE          The command-line parser. }

unit incline;

interface


{ This unit has NO externally-callable procedures. Also note that
  it MUST be called *first* (so if you load AVALOT.PAS and press f7
  twice you get to the "begin" statement.) }

implementation
 uses Gyro,Logger;

var
 fv:byte;
 t:char;
 bugline:string;
 zoomy,numlockhold:boolean;

 filename_specified:boolean;

procedure syntax;
begin
 assign(output,''); rewrite(output);
 writeln;
 writeln('Lord Avalot d''Argent'^i^i'(c) '+copyright+' Mark, Mike and Thomas Thurman.');
 writeln('~~~~~~~~~~~~~~~~~~~~~'^i^i+vernum);
 writeln;
 writeln('Syntax:');
 writeln(^i'/?'^i'displays this screen,');
 writeln(^i'/O'^i'overrides EGA check,');
 writeln(^i'/L<f>'^i'logs progress to <f>, default AVVY.LOG,');
 writeln(^i'/P<x>'^i'logs with Epson codes to <x>, default PRN,');
 writeln(^i'/Q'^i'cancels sound effects,');
 writeln(^i'/Z'^i'goes straight into the game.');
 writeln;
 writeln(^i^i^i^i^i^i^i'... Have fun!');
 halt(177);
end;

procedure not_through_bootstrap;
begin
 writeln('Avalot must be loaded through the bootstrap.');
 halt;
end;

procedure get_storage_addr;
var e:integer;
begin
 val(paramstr(2),storage_SEG,e); if e<>0 then not_through_bootstrap;
 val(paramstr(3),storage_OFS,e); if e<>0 then not_through_bootstrap;
 Skellern:=storage_OFS+1;
end;

function value(x:string):longint;
var q:longint; e:integer;
begin
 val(x,q,e); value:=q;
end;

procedure undo_js;
begin
 with js do
 begin
  cxmin:=xmid-(((xmid-xmin) div 10)*centre);
  cxmax:=xmid+(((xmax-xmid) div 10)*centre);
  cymin:=ymid-(((ymid-ymin) div 10)*centre);
  cymax:=ymid+(((ymax-ymid) div 10)*centre);

(*  writeln(lst,'MID ',xmid,'x',ymid);
  writeln(lst,'MAX ',xmax,'x',ymax);
  writeln(lst,'MIN ',xmin,'x',ymin);
  writeln(lst,'CENTRE ',xmid);
  writeln(lst,cxmin);
  writeln(lst,cxmax);
  writeln(lst,cymin);
  writeln(lst,cymax);*)
 end;
end;

procedure check_slope_line;
var slope:string;
  function yn(where:byte):boolean; begin yn:=slope[where]='y'; end;
begin
 slope:=paramstr(4);

(* if slope='' then fillchar(slope,sizeof(slope),'n');*)

 if slope[1]<>'1' then not_through_bootstrap;

 if yn(2) then syntax;

 soundfx:=yn(3);
 cl_Override:=yn(4);
 keyboardclick:=yn(5); { 6 - see below }
 demo:=yn(7);
 zoomy:=yn(8);
 numlockhold:=yn(9);
 use_joy_A:=yn(10);

 with js do
 begin
    xmid:=value(paramstr( 5));
    ymid:=value(paramstr( 6));
    xmin:=value(paramstr( 7));
    ymin:=value(paramstr( 8));
    xmax:=value(paramstr( 9));
    ymax:=value(paramstr(10));
  centre:=value(paramstr(11));

    undo_js;
 end;

 case slope[6] of
  'l': log_setup(paramstr(12),false);
  'p': log_setup(paramstr(12),true);
 end;
end;

procedure get_extra_data;
begin
 if not reloaded then exit;

 move(mem[Storage_SEG:Storage_OFS+300],js,sizeof(js));

 undo_js;
end;

begin
(* writeln('Load code: ',paramstr(1));
 writeln('Seg & ofs: ',paramstr(2),':',paramstr(3));
 writeln('Slope line: ',paramstr(4));
 writeln('Log file: ',paramstr(5));
 writeln('File to load: ',paramstr(6));
 readln;*)

 filetoload:=paramstr(13);
 filename_specified := filetoload <> '';

 logging:=false;

 if (paramcount<3) or
  ((paramstr(1)<>'Go') and (paramstr(1)<>'et')) then not_through_bootstrap;

 reloaded:=paramstr(1)='et';

 get_storage_addr;

 get_extra_data;

 check_slope_line;
end.
