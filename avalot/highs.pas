{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 HIGHS            This handles the high-scores. }

unit Highs;

interface

  procedure show_highs;

  procedure store_high(who:string);

implementation

uses Gyro,Scrolls;

type
 highscoretype = array[1..12] of record
                                  name:string[30];
                                  score:word;
                                  rank:string[12];
                                 end;

var
 h:highscoretype;

procedure get_new_highs;
var fv:byte;
begin;
 for fv:=1 to 12 do
  with h[fv] do
  begin;
   score:=32-fv*2;
   rank:='...';
  end;
 h[1].name:='Mike'; h[2].name:='Liz';  h[3].name:='Thomas'; h[4].name:='Mark';
 h[5].name:='Mandy'; h[6].name:='Andrew';  h[7].name:='Lucy Tryphena';
 h[8].name:='Tammy the dog';
 h[9].name:='Avaricius'; h[10].name:='Spellchick';  h[11].name:='Caddelli';
 h[12].name:='Spludwick';
end;

procedure show_highs;
 { This procedure shows the high-scores. }
var
 fv:byte;
 x:string[40];
 y:string[5];
begin;
 display('HIGH SCORERS'^c^m'  Name'^i^i'Score   Rank'^m'  """"'^i^i'"""""   """"'^l^d);
 for fv:=1 to 12 do
  with h[fv] do
  begin;
   display(^m+name+^d);
   fillchar(x,sizeof(x),#32);
   y:=strf(score);
   x[0]:=chr(29-(length(name+y)));
   display(x+y+' '+rank+^d);
  end;

 display('');
end;

procedure store_high(who:string);
 { This procedure shows the high-scores. }
var
 fv,ff:byte;
begin;

 for fv:=1 to 12 do
  if h[fv].score<dna.score then break;

 { Shift all the lower scores down a space. }
 for ff:=fv to 11 do
  h[ff+1]:=h[ff];

 with h[fv] do
 begin;
  name:=who;
  score:=dna.score;
 end;

end;

procedure get_highs;
var f:file of highscoretype;
begin;
 {$I-}
 assign(f,'scores.avd');
 reset(f);
  { Did we get it? }

 if ioresult<>0 then
 begin; { No. }
  get_new_highs; { Invent one. }
 end else
 begin; { Yes. }
  read(f,h);
  close(f);
 end;
end;

begin;
 get_highs;
end.