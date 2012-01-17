{
  €ﬂ‹ €ﬂ‹ ‹ﬂﬂ‹  ﬂ€ﬂ €ﬂﬂ  ‹ﬂ ﬂ€ﬂ      ‹ﬂ€ﬂ‹  ﬂ€ﬂ €‹  € ‹€ﬂﬂ  ﬂ€ﬂ €ﬂ‹ €ﬂﬂ €
  €ﬂ  €€  €  € ‹ €  €ﬂﬂ ﬂ‹   €      €  €  €  €  € €‹€  ﬂﬂﬂ‹  €  €€  €ﬂﬂ €
  ﬂ   ﬂ ﬂ  ﬂﬂ   ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ      ﬂ  ﬂ  ﬂ ﬂﬂﬂ ﬂ  ﬂﬂ  ﬂﬂﬂ   ﬂ  ﬂ ﬂ ﬂﬂﬂ ﬂﬂﬂ

                 ACCESS           The temporary Sez handler. }

unit Access;

interface

procedure dixi(p:char; n:byte);

procedure talkto(whom:byte);

implementation

uses Gyro,Scrolls,Acci,Trip5,Lucerna;

var int_say_went_OK:boolean;

procedure int_say(filename:string; bubble:boolean);
 { Internal use ONLY! }
var f:file;
begin;
 {$I-}
 assign(f,filename);
 reset(f,1);
 if ioresult<>0 then
 begin;
  int_say_went_OK:=false;
  exit;
 end;
 bufsize:=filesize(f);
 blockread(f,buffer,bufsize);
 if bubble then
 begin;
  inc(bufsize);
  buffer[bufsize]:=^B;
 end;
 close(f);
 {$I+}

 calldrivers;

 int_say_went_OK:=true;
end;

procedure dixi(p:char; n:byte);
begin; HALT(153);
 int_say('s'+p+strf(n)+'.raw',false);
end;

procedure talkto(whom:byte);
var
 fv:byte;
 no_matches:boolean;
begin; HALT(153);
 if person=pardon then
 begin;
  person:=chr(subjnumber);
  subjnumber:=0;
 end;

 case chr(whom) of
  pSpludwick:

    if (dna.Lustie_is_asleep) and (not dna.obj[potion]) then
    begin;
     dixi('q',68);
     dna.obj[potion]:=true;
     objectlist; points(3); exit;
    end else
    begin;
     if dna.Talked_To_Crapulus then
      case dna.given2spludwick of { Spludwick - what does he need? }
         { 0 - let it through to use normal routine. }
         1..2: begin;
                display('Can you get me '+
                 get_better(spludwick_order[dna.given2spludwick])+', please?'+
                  ^s'2'^b);
                exit;
               end;
         3: begin;
             dixi('q',30); { need any help with the game? }
             exit;
            end;
       end
     else dixi('q',42); { Haven't talked to Crapulus. Go and talk to him. }
    end;

  pIbythneth: if dna.GivenBadgeToIby then
              begin;
               dixi('q',33); { Thanks a lot! }
               exit; { And leave the proc. }
              end; { Or... just continue, 'cos he hasn't got it. }
  pDogfood: if dna.WonNim then
            begin; { We've won the game. }
             dixi('q',6); { "I'm Not Playing!" }
             exit; { Zap back. }
            end;
  pAyles: if not dna.Ayles_is_awake then
          begin;
           dixi('q',43); { He's fast asleep! }
           exit;
          end;
  pGeida: if dna.Geida_given_potion then
           dna.Geida_Follows:=true else
          begin;
           dixi('u',17);
           exit;
          end;
 end;

 if whom>149 then dec(whom,149);

 no_matches:=true;
 for fv:=1 to numtr do
  if tr[fv].a.accinum=whom then
  begin;
   display(^S+chr(fv+48)+^D);
   no_matches:=false;
   break;
  end;

 if no_matches then display(^S^S^D);

 if subjnumber=0 then { For the moment... later we'll parse "say". }
  int_say('ss'+strf(whom)+'.raw',true)
 else
 begin;
  int_say('ss'+strf(whom)+'-'+strf(subjnumber)+'.raw',true);
  if not int_say_went_OK then { File not found! }
   dixi('n',whom);
 end;

 case chr(whom+149) of
  pCrapulus:
     begin; { Crapulus: get the badge - first time only }
      dna.obj[badge]:=true;
      objectlist;
      dixi('q',1); { Circular from Cardiff. }
      dna.talked_to_Crapulus:=true;

      whereis[pCrapulus]:=177; { Crapulus walks off. }

      tr[2].VanishIfStill:=true;
      tr[2].walkto(4); { Walks away. }

      points(2);
     end;

  pAyles: dixi('q',44); { Can you get me a pen? }

 end;
end;

end.
