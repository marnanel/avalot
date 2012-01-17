{
  ÛßÜ ÛßÜ ÜßßÜ  ßÛß Ûßß  Üß ßÛß      ÜßÛßÜ  ßÛß ÛÜ  Û ÜÛßß  ßÛß ÛßÜ Ûßß Û
  Ûß  ÛÛ  Û  Û Ü Û  Ûßß ßÜ   Û      Û  Û  Û  Û  Û ÛÜÛ  ßßßÜ  Û  ÛÛ  Ûßß Û
  ß   ß ß  ßß   ßß  ßßß   ß  ß      ß  ß  ß ßßß ß  ßß  ßßß   ß  ß ß ßßß ßßß

                 LOGGER           Handles the logging. }

unit Logger;

interface

procedure log_setup(name:string; printing:boolean);

procedure log_divider; { Prints the divider sign. }

procedure log_command(x:string); { Prints a command }

procedure log_scrollchar(x:string); { print one character }

procedure log_italic;

procedure log_roman;

procedure log_epsonroman;

procedure log_scrollline; { Set up a line for the scroll driver }

procedure log_scrollendline(centred:boolean);

procedure log_bubbleline(linenum,whom:byte; x:string);

procedure log_newline;

procedure log_newroom(where:string);

procedure log_aside(what:string);

procedure log_score(credit,now:word);

implementation

uses Gyro,Trip5;

const

 divide = '--- oOo ---';

(* Epson codes:

 startwith='';
 endwith='';
 double_width = #14; { shift out (SO) }
 double_off = #20; { device control 4 (DC4) }
 italic = #27+'4'; { switches italics on... }
 italic_off = #27+'5'; { and off. }
 emph_on = #27+#69;
 emph_off = #27+#70;
 divide_indent = 15;

*)

  { L'jet codes: }

 startwith=#27+#40+'10J'+#88;
 endwith=#27+#69;
 italic = #27+#40+#115+#49+#83; { switches italics on... }
 italic_off = #27+#40+#115+#48+#83; { and off. }
 emph_on = #27+#40+#115+#51+#66;
 emph_off = #27+#40+#115+#48+#66;
 double_width = emph_on; { There IS no double-width. }
 double_off = emph_off; { So we'll have to use bold. }
 quote : string = 'ª';
 unquote : string = 'º';
 copyright : string = '(c)';
 divide_indent = 30;

var
 scroll_line:string;
 scroll_line_length:byte;

procedure centre(size,x:byte); { Prints req'd number of spaces. }
var fv:byte;
begin;
 if not logging then exit;
 for fv:=1 to size-(x div 2) do
  write(logfile,' ');
end;

procedure log_setup(name:string; printing:boolean); { Sets up. }
begin;
 assign(logfile,name);
 rewrite(logfile);
 write(logfile,startwith);
 log_epson:=printing;
 logging:=true;

 if not printing then begin quote:='"'; unquote:='"'; copyright:='(c)'; end;
end;

procedure log_divider; { Prints the divider sign. }
var fv:byte;
begin;
 if not logging then exit;
 if log_epson then
 begin;
  write(logfile,' '+double_width);
  for fv:=1 to divide_indent do write(logfile,' ');
  write(logfile,' '+double_off);
 end else
  for fv:=1 to 36 do write(logfile,' ');
 writeln(logfile,divide);
end;

procedure log_command(x:string); { Prints a command }
begin;
 if not logging then exit;
 if log_epson then
  writeln(logfile,double_width+'>'+double_off+' '+italic+x+italic_off)
 else
  writeln(logfile,'> '+x);
end;

procedure log_addstuff(x:string);
begin;
 if not logging then exit;
 scroll_line:=scroll_line+x;
end;

procedure log_scrollchar(x:string); { print one character }
var z:string[2];
begin;
 if not logging then exit;
 case x[1] of
  '`': z:=quote; { Open quotes: "66" }
  '"': z:=unquote; { Close quotes: "99" }
  #239: z:=copyright; { Copyright sign. }
  else z:=x;
 end;
 log_addstuff(z);
 inc(scroll_line_length,length(z));
end;

procedure log_italic;
begin;
 if not logging then exit;
 if log_epson then
  log_addstuff(italic)
 else
  log_addstuff('*');
end;

procedure log_roman;
begin;
 if not logging then exit;
 if log_epson then
  log_addstuff(italic_off)
 else
  log_addstuff('*');
end;

procedure log_epsonroman; { This only sends the Roman code if you're on Epson.}
begin;
 if not logging then exit;
 if log_epson then log_addstuff(italic_off);
end;

procedure log_scrollline; { Set up a line for the scroll driver }
begin;
 scroll_line_length:=0;
 scroll_line:='';
end;

procedure log_scrollendline(centred:boolean);
var x,fv:byte;
begin;
 if not logging then exit;
 x:=17;
 if centred then inc(x,(50-scroll_line_length) div 2);
 for fv:=1 to x do write(logfile,' ');
 writeln(logfile,scroll_line);
end;

procedure log_bubbleline(linenum,whom:byte; x:string);
var fv:byte;
begin;
 if not logging then exit;
 if linenum=1 then
 begin;
  for fv:=1 to 15 do write(logfile,' ');
  writeln(logfile,italic+tr[whom].a.name+': '+italic_off+x);
 end else
 begin;
  for fv:=1 to 17 do write(logfile,' ');
  writeln(logfile,x);
 end;
end;

procedure log_newline;
begin;
 if logging then writeln(logfile);
end;

procedure log_newroom(where:string);
var fv:byte;
begin;
 if not logging then exit;
 for fv:=1 to 20 do write(logfile,' ');
 if log_epson then write(logfile,emph_on);
 write(logfile,'('+where+')');
 if log_epson then write(logfile,emph_off);
 writeln(logfile);
end;

procedure log_aside(what:string);
 { This writes "asides" to the printer. For example, moves in Nim. }
begin;
 if not logging then exit;
 writeln(logfile,'   (',italic,what,italic_off,')');
 { "What" is what to write. }
end;

procedure log_score(credit,now:word);
var fv:byte;
begin;
 if not logging then exit;
 for fv:=1 to 50 do write(logfile,' ');
 writeln(logfile,'Score ',italic,'credit : ',credit,italic_off,' total : ',now);
end;

end.
