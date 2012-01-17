program test_compress_pics; {$S-}
uses Graph;

type
 buffertype = array[1..50000] of byte;

var
 gd,gm:integer;
 describe:string[29];
 method:byte;
 bit:shortint;
 offset:word;
 a0:byte absolute $A000:800;
 a7:array[1..12080] of byte absolute $A000:800;
 buffer:^buffertype;
 bufsize:word;

procedure putup(what:byte);
begin;
 if offset>12080 then
 begin;
  inc(bit);
  port[$3c4]:=2; port[$3ce]:=4; port[$3C5]:=1 shl bit; port[$3CF]:=bit;
  offset:=1;
 end;

 a7[offset]:=what;
 inc(offset);
end;

procedure load_uncomp(xx:string); { Load2, actually }
var
(* a1:byte absolute $A000:17184;*)
 this:byte;
 f:file;
 place:word;
begin;
 assign(f,'v:place'+xx+'.avd'); reset(f,1); seek(f,146);
 blockread(f,describe,30); blockread(f,method,1);
 bufsize:=filesize(f)-177; blockread(f,buffer^,bufsize);
 close(f);

 bit:=-1; offset:=12081; place:=1;

 while place<=bufsize do
 begin;
  this:=buffer^[place];
  inc(place);
  putup(this);
 end;

 writeln(method,' : "',describe,'"');
end;

procedure load_comp(xx:string); { This loads in the compressed file. }

CONST
   MaxBuff  = 8192                 (* Buffer size for input and output files *);
   MaxTab   = 4095                 (* Table size - 1 ==> 2**10-1 ==> 12 bits *);
   No_Prev  = -1                   (* Special code for no previous character *);
   End_List = -1                   (* Marks end of a list                    *);
   MaxStack = 4096                 (* Decompression stack size  *);


TYPE
                                   (* One node in parsing table.             *)
   String_Table_Entry = RECORD
                           Unused   : BOOLEAN  (* Is this node *NOT* used yet?*);
                           PrevChar : INTEGER  (* Code for preceding string   *);
                           FollChar : INTEGER  (* Code for current character  *);
                           Next     : INTEGER  (* Next dupl in collision list *);
                        END;

type
 sttype = ARRAY[0..MaxTab] OF String_Table_Entry;

VAR
                                             (* String table *)

   String_Table   : ^sttype;

   Table_Used     : INTEGER                  (* # string table entries used *);
   Output_Code    : INTEGER                  (* Output compressed code      *);
   Input_Code     : byte                     (* Input compressed code       *);
   If_Compressing : BOOLEAN                  (* TRUE if compressing file    *);
   inempty,popempty:boolean;
                                   (* Decompression stack       *)

   Stack         : ARRAY[1..MaxStack] OF byte;

   Stack_Pointer : INTEGER         (* Decompression stack depth *);

 this:byte;
 f:file;
 place:word;

       FUNCTION Get_Hash_Code( var PrevC, FollC : INTEGER ) : INTEGER;

       VAR
          Index  : INTEGER;
          Index2 : INTEGER;

       BEGIN (* Get_Hash_Code *)
                                          (* Get initial index using hashing *)

          Index := ( ( PrevC SHL 5 ) XOR FollC ) AND MaxTab;

                                          (* If entry not already used, return *)
                                          (* its index as hash code for <w>C.  *)

          IF ( String_Table^[Index].Unused ) THEN
             Get_Hash_Code := Index
          ELSE
                                          (* If entry already used, search to  *)
                                          (* end of list of hash collision     *)
                                          (* entries for this hash code.       *)
                                          (* Do linear probe to find an        *)
                                          (* available slot.                   *)
             BEGIN

                                          (* Skip to end of collision list ... *)

                WHILE ( String_Table^[Index].Next <> End_List ) DO
                   Index := String_Table^[Index].Next;

                                          (* Begin linear probe down a bit from  *)
                                          (* last entry in collision list ...    *)

                Index2 := ( Index + 101 ) AND MaxTab;

                                          (* Look for unused entry using linear  *)
                                          (* probing ...                         *)

                WHILE ( NOT String_Table^[Index2].Unused ) DO
                   Index2 := SUCC( Index2 ) AND MaxTab;

                                          (* Point prior end of collision list   *)
                                          (* to this new node.                   *)

                String_Table^[Index].Next := Index2;

                                          (* Return hash code for <w>C           *)

                Get_Hash_Code          := Index2;

             END;

       END   (* Get_Hash_Code *);

       (*--------------------------------------------------------------------------*)
       (*          Make_Table_Entry --- Enter <w>C string in string table          *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Make_Table_Entry( var PrevC, FollC: INTEGER );

       BEGIN (* Make_Table_Entry *)
                                          (* Only enter string if there is room left *)

          IF ( Table_Used <= MaxTab ) THEN
             BEGIN
                WITH String_Table^[ Get_Hash_Code( PrevC , FollC ) ] DO
                   BEGIN
                      Unused   := false;
                      Next     := End_List;
                      PrevChar := PrevC;
                      FollChar := FollC;
                   END;
                                          (* Increment count of items used *)

                INC( Table_Used );
       (*
                IF ( Table_Used > ( MaxTab + 1 ) ) THEN
                   BEGIN
                      WRITELN('Hash table full.');
                   END;
       *)
             END;

       END   (* Make_Table_Entry *);

       PROCEDURE firstentries;
       { This is just a fast version of the above, when PrevC = No_Prev. TT. }

       var i,j:integer;

       BEGIN
         { There MUST be room- we've only just started! }

         j:=no_prev;

         for i:=0 to 255 do
          WITH String_Table^[ ((no_prev SHL 5 ) XOR i) AND MaxTab] DO
          BEGIN
           Unused   := false;
           Next     := End_List;
           PrevChar := No_Prev;
           FollChar := i;
          END;

         INC( Table_Used, 256 ); (* Increment count of items used *)

       END;

       (*--------------------------------------------------------------------------*)
       (*            Initialize_String_Table --- Initialize string table           *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Initialize_String_Table;

       VAR
          I: INTEGER;

       BEGIN (* Initialize_String_Table *)

                                          (* No entries used in table yet *)
          Table_Used  := 0;

        fillchar(string_table^,(maxtab+1)*sizeof(string_table^[1]),#255);
                                          (* Enter all single characters into *)
                                          (* table                            *)
        firstentries;

       END   (* Initialize_String_Table *);

       (*--------------------------------------------------------------------------*)
       (*            Lookup_String --- Look for string <w>C in string table        *)
       (*--------------------------------------------------------------------------*)

       FUNCTION Lookup_String( PrevC, FollC: INTEGER ) : INTEGER;

       VAR
          Index  : INTEGER;
          Index2 : INTEGER;
          Found  : BOOLEAN;

       BEGIN (* Lookup_String *)
                                          (* Initialize index to check from hash *)

          Index       := ( ( PrevC SHL 5 ) XOR FollC ) AND MaxTab;

                                          (* Assume we won't find string *)
          Lookup_String := End_List;
                                          (* Search through list of hash collision *)
                                          (* entries for one that matches <w>C     *)
          REPEAT

             Found := ( String_Table^[Index].PrevChar = PrevC ) AND
                      ( String_Table^[Index].FollChar = FollC );

             IF ( NOT Found ) THEN
                Index := String_Table^[Index].Next;

          UNTIL Found OR ( Index = End_List );

                                          (* Return index if <w>C found in table. *)
          IF Found THEN
             Lookup_String := Index;

       END   (* Lookup_String *);

       (*--------------------------------------------------------------------------*)
       (*                  Push --- Push character onto stack                      *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Push( C : byte);

       BEGIN (* Push *)

         INC( Stack_Pointer );
         Stack[ Stack_Pointer ] := C;

         IF ( Stack_Pointer >= MaxStack ) THEN
            BEGIN
               WRITELN('Stack overflow!');
               Halt;
            END;

       END  (* Push *);

       (*--------------------------------------------------------------------------*)
       (*                  Pop --- Pop character from stack                        *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Pop( VAR C : INTEGER );

       BEGIN (* Pop *)

        popempty:=stack_pointer=0;

          IF not popempty then
             BEGIN
                C := Stack[Stack_Pointer];
                DEC( Stack_Pointer );
             END;

       END   (* Pop *);

       (*--------------------------------------------------------------------------*)
       (*            Get_Code --- Get compression code from input file             *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Get_Code( VAR Hash_Code : integer );

       VAR
          Local_Buf : byte;

       BEGIN (* Get_Code *)

          IF inempty THEN
             BEGIN

                if place>bufsize then EXIT else
                begin;
                 local_buf:=buffer^[place];
                 inc(place);
                end;

                if place>bufsize then EXIT else
                begin;
                 input_code:=buffer^[place];
                 inc(place);
                end;

                Hash_Code  := ( ( Local_Buf SHL 4  ) AND $FF0 ) +
                              ( ( Input_Code SHR 4 ) AND $00F );

                Input_Code := Input_Code AND $0F;
                inempty:=false;

             END
          ELSE
             BEGIN

                if place>bufsize then EXIT else
                begin;
                 Local_Buf:=buffer^[place];
                 inc(place);
                end;

                Hash_Code  := Local_Buf + ( ( Input_Code SHL 8 ) AND $F00 );
                Inempty:=true;

             END;

       END   (* Get_Code *);

       (*--------------------------------------------------------------------------*)
       (*            Do_Decompression --- Perform decompression                    *)
       (*--------------------------------------------------------------------------*)

       PROCEDURE Do_Decompression;

       VAR
          C         : INTEGER             (* Current input character *);
          Code      : INTEGER             (* Current code string     *);
          Old_Code  : INTEGER             (* Previous code string    *);
          Fin_Char  : INTEGER             (* Final input character   *);
          In_Code   : INTEGER             (* Current input code      *);
          Last_Char : INTEGER             (* Previous character      *);
          Unknown   : BOOLEAN             (* TRUE if code not found  *);
          Temp_C    : INTEGER             (* Char popped off stack   *);

       BEGIN (* Do_Decompression *)

         Stack_Pointer := 0;     (* Decompression stack is empty *)
         Unknown       := FALSE; (* First string is always known *)
         Get_Code( Old_Code );   (* Get first string == Step 1   *)
         Code          := Old_Code;

         C:=String_Table^[Code].FollChar; (* Output corresponding character *)
         putup( C );
         Fin_Char := C; (* Remember this character  -- it    *)
                        (* is final character of next string *)

         Get_Code( In_Code ); (* Get next code  == Step 2 *)

         WHILE place<=bufsize do
            BEGIN
               Code := In_Code; (* Set code to this input code *)

               (* If code not in table, do special *)
               (* case ==> Step 3                  *)

               IF ( String_Table^[Code].Unused ) THEN
                  BEGIN
                     Last_Char := Fin_Char;
                     Code      := Old_Code;
                     Unknown   := TRUE;
                  END;
                                          (* Run through code extracting single *)
                                          (* characters from code string until  *)
                                          (* no more characters can be removed. *)
                                          (* Push these onto stack.  They will  *)
                                          (* be entered in reverse order, and   *)
                                          (* will come out in forwards order    *)
                                          (* when popped off.                   *)
                                          (*                                    *)
                                          (* ==> Step 4                         *)

               WHILE( String_Table^[Code].PrevChar <> No_Prev ) DO
                  WITH String_Table^[Code] DO
                     BEGIN
                        Push( FollChar );
                        Code := PrevChar;
                     END;
                                          (* We now have the first character in *)
                                          (* the string.                        *)

               Fin_Char := String_Table^[Code].FollChar;

                                          (* Output first character  ==> Step 5   *)
               putup( Fin_Char );
                                          (* While the stack is not empty, remove *)
                                          (* and output all characters from stack *)
                                          (* which are rest of characters in the  *)
                                          (* string.                              *)
                                          (*                                      *)
                                          (* ==> Step 6                           *)
               Pop( Temp_C );

               WHILE not popempty do
                  BEGIN
                     putup( Temp_C );
                     Pop( Temp_C );
                  END;
                                          (* If code isn't known, output the      *)
                                          (* follower character of last character *)
                                          (* of string.                           *)
               IF Unknown THEN
                  BEGIN
                     Fin_Char := Last_Char;
                     putup( Fin_Char );
                     Unknown  := FALSE;
                  END;
                                          (* Enter code into table ==> Step 7 *)

               Make_Table_Entry( Old_Code , Fin_Char );

                                          (* Make current code the previous code *)
               Old_Code := In_Code;

                                          (* Get next code  == Step 2 *)
               Get_Code( In_Code );

            END;

       END   (* Do_Decompression *);

begin;
 new(string_table);
 inempty:=true;
 Initialize_String_Table;

 assign(f,'v:compr'+xx+'.avd'); reset(f,1); seek(f,146);
 blockread(f,describe,30); blockread(f,method,1);
 bufsize:=filesize(f)-177; blockread(f,buffer^,bufsize);
 close(f);

 bit:=-1; offset:=12081; place:=1;

 do_decompression;

 writeln(method,' : "',describe,'"');

 dispose(string_table);
end;

begin;
 gd:=3; gm:=0; initgraph(gd,gm,'c:\bp\bgi');
 new(buffer);
 {$IFDEF uncomp}
 load_uncomp('21');
 {$ELSE}
 load_comp('21');
 {$ENDIF}
 dispose(buffer);
end.

***
