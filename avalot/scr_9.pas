program screen9;
uses Crt;
var
 t:text;
 x:string;
 fv:byte;
 f:file;
begin;
 assign(f,'v:paralogo.scr');
 clrscr;
 reset(f,1);
 blockread(f,mem[$B800:0],4000);
 close(f);
 gotoxy(1,1); insline;
 gotoxy(1,23); clreol;
end.