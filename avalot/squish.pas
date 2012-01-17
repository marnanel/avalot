program Squish;

{ This is the first version. Thanks to Pib. }

(*--------------------------------------------------------------------------*)
(*                                                                          *)
(*                  Global declarations for PIBLZW                          *)
(*                                                                          *)
(*--------------------------------------------------------------------------*)

CONST
   MaxBuff  = 8192                 (* Buffer size for input and output files *);
   MaxTab   = 4095                 (* Table size - 1 ==> 2**10-1 ==> 12 bits *);
   No_Prev  = $7FFF                (* Special code for no previous character *);
   EOF_Char = -2                   (* Marks end of file                      *);
   End_List = -1                   (* Marks end of a list                    *);
   Empty    = -3                   (* Indicates empty                        *);

TYPE
   AnyStr             = STRING[255]  (* General string type                  *);

                                   (* One node in parsing table.             *)
   String_Table_Entry = RECORD
                           Used     : BOOLEAN  (* Is this node used yet?      *);
                           PrevChar : INTEGER  (* Code for preceding string   *);
                           FollChar : INTEGER  (* Code for current character  *);
                           Next     : INTEGER  (* Next dupl in collision list *);
                        END;

VAR
   Input_File     : FILE                     (* Input file   *);
   Output_File    : FILE                     (* Output file  *);

   InBufSize      : INTEGER                  (* Count of chars in input buffer *);

   Input_Buffer   : ARRAY[1..MaxBuff] OF BYTE (* Input buffer area         *);
   Output_Buffer  : ARRAY[1..MaxBuff] OF BYTE (* Output buffer area        *);

   Input_Pos      : INTEGER                  (* Cur. pos. in input buffer   *);
   Output_Pos     : INTEGER                  (* Cur. pos. in output buffer  *);

                                             (* String table *)

   String_Table   : ARRAY[0..MaxTab] OF String_Table_Entry;

   Table_Used     : INTEGER                  (* # string table entries used *);
   Output_Code    : INTEGER                  (* Output compressed code      *);
   Input_Code     : INTEGER                  (* Input compressed code       *);
   If_Compressing : BOOLEAN                  (* TRUE if compressing file    *);
   Ierr           : INTEGER                  (* Input/output error          *);

   header:string; describe:string[30]; method:byte;

PROCEDURE Terminate;

BEGIN (* Terminate *)
                                   (* Write any remaining characters *)
                                   (* to output file.                *)
   IF ( Output_Pos > 0 ) THEN
      BlockWrite( Output_File, Output_Buffer, Output_Pos );

   Ierr := IOResult;
                                   (* Close input and output files   *)
   CLOSE( Input_File  );
   Ierr := IOResult;

   CLOSE( Output_File );
   Ierr := IOResult;

   writeln('done.');

END   (* Terminate *);

(*--------------------------------------------------------------------------*)
(*          Get_Hash_Code --- Gets hash code for given <w>C string          *)
(*--------------------------------------------------------------------------*)

FUNCTION Get_Hash_Code( PrevC, FollC : INTEGER ) : INTEGER;

VAR
   Index  : INTEGER;
   Index2 : INTEGER;

BEGIN (* Get_Hash_Code *)
                                   (* Get initial index using hashing *)

   Index := ( ( PrevC SHL 5 ) XOR FollC ) AND MaxTab;

                                   (* If entry not already used, return *)
                                   (* its index as hash code for <w>C.  *)

   IF ( NOT String_Table[Index].Used ) THEN
      Get_Hash_Code := Index
   ELSE
                                   (* If entry already used, search to  *)
                                   (* end of list of hash collision     *)
                                   (* entries for this hash code.       *)
                                   (* Do linear probe to find an        *)
                                   (* available slot.                   *)
      BEGIN

                                   (* Skip to end of collision list ... *)

         WHILE ( String_Table[Index].Next <> End_List ) DO
            Index := String_Table[Index].Next;

                                   (* Begin linear probe down a bit from  *)
                                   (* last entry in collision list ...    *)

         Index2 := ( Index + 101 ) AND MaxTab;

                                   (* Look for unused entry using linear  *)
                                   (* probing ...                         *)

         WHILE ( String_Table[Index2].Used ) DO
            Index2 := SUCC( Index2 ) AND MaxTab;

                                   (* Point prior end of collision list   *)
                                   (* to this new node.                   *)

         String_Table[Index].Next := Index2;

                                   (* Return hash code for <w>C           *)

         Get_Hash_Code          := Index2;

      END;

END   (* Get_Hash_Code *);

(*--------------------------------------------------------------------------*)
(*          Make_Table_Entry --- Enter <w>C string in string table          *)
(*--------------------------------------------------------------------------*)

PROCEDURE Make_Table_Entry( PrevC, FollC: INTEGER );

BEGIN (* Make_Table_Entry *)
                                   (* Only enter string if there is room left *)

   IF ( Table_Used <= MaxTab ) THEN
      BEGIN
         WITH String_Table[ Get_Hash_Code( PrevC , FollC ) ] DO
            BEGIN
               Used     := TRUE;
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

(*--------------------------------------------------------------------------*)
(*            Initialize_String_Table --- Initialize string table           *)
(*--------------------------------------------------------------------------*)

PROCEDURE Initialize_String_Table;

VAR
   I: INTEGER;

BEGIN (* Initialize_String_Table *)

                                   (* No entries used in table yet *)
   Table_Used  := 0;
                                   (* Clear all table entries      *)
   FOR I := 0 TO MaxTab DO
      WITH String_Table[I] DO
         BEGIN
            PrevChar := No_Prev;
            FollChar := No_Prev;
            Next     := -1;
            Used     := FALSE;
         END;
                                   (* Enter all single characters into *)
                                   (* table                            *)
   FOR I := 0 TO 255 DO
      Make_Table_Entry( No_Prev , I );

END   (* Initialize_String_Table *);

(*--------------------------------------------------------------------------*)
(*            Initialize --- Initialize compression/decompression           *)
(*--------------------------------------------------------------------------*)

PROCEDURE Initialize;

VAR
   Input_Name  : AnyStr            (* Input file name  *);
   Output_Name : AnyStr            (* Output file name *);

BEGIN (* Initialize *)

 write('Number of file to compress:'); readln(input_name);
 writeln('For the moment, I''m writing the compressed version to v:compr',
            input_name,'.avd.');
 output_name:='d:compr'+input_name+'.avd';
  input_name:='d:place'+input_name+'.avd';

 write('Wait... ');

                                   (* Open input file *)

   ASSIGN ( Input_File , Input_Name );
   RESET  ( Input_File , 1 );
   Ierr := IOResult;

 blockread(input_file,header,146);
 blockread(input_file,describe,30);
 blockread(input_file,method,1);

 if method=177 then
 begin;
  writeln('It''s already compressed!');
  halt(177);
 end;

                                   (* Open output file *)

   ASSIGN ( Output_File , Output_Name );
   REWRITE( Output_File , 1 );
   Ierr := IOResult;

 method:=177;

 blockwrite(output_file,header,146);
 blockwrite(output_file,describe,30);
 blockwrite(output_file,method,1);

                                   (* Point input point past end of *)
                                   (* buffer to force initial read  *)
   Input_Pos  := MaxBuff + 1;
                                   (* Nothing written out yet       *)
   Output_Pos := 0;
                                   (* Nothing read in yet           *)
   InBufSize  := 0;
                                   (* No input or output codes yet  *)
                                   (* constructed                   *)
   Output_Code := Empty;
   Input_Code  := Empty;
                                   (* Initialize string hash table  *)
   Initialize_String_Table;

END   (* Initialize *);

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

      Found := ( String_Table[Index].PrevChar = PrevC ) AND
               ( String_Table[Index].FollChar = FollC );

      IF ( NOT Found ) THEN
         Index := String_Table[Index].Next;

   UNTIL Found OR ( Index = End_List );

                                   (* Return index if <w>C found in table. *)
   IF Found THEN
      Lookup_String := Index;

END   (* Lookup_String *);

(*--------------------------------------------------------------------------*)
(*              Get_Char  ---  Read character from input file               *)
(*--------------------------------------------------------------------------*)

PROCEDURE Get_Char( VAR C: INTEGER );

BEGIN (* Get_Char *)
                                   (* Point to next character in buffer *)
   INC( Input_Pos );
                                   (* If past end of block read in, then *)
                                   (* reset input pointer and read in    *)
                                   (* next block.                        *)

   IF ( Input_Pos > InBufSize ) THEN
      BEGIN
         BlockRead( Input_File, Input_Buffer, MaxBuff, InBufSize );
         Input_Pos := 1;
         Ierr      := IOResult;
      END;
                                  (* If end of file hit, return EOF_Char *)
                                  (* otherwise return next character in  *)
                                  (* input buffer.                       *)
   IF ( InBufSize = 0 ) THEN
      C := EOF_Char
   ELSE
      C := Input_Buffer[Input_Pos];

END   (* Get_Char *);

(*--------------------------------------------------------------------------*)
(*             Write_Char  ---  Write character to output file              *)
(*--------------------------------------------------------------------------*)

PROCEDURE Put_Char( C : INTEGER );

BEGIN (* Put_Char *)
                                   (* If buffer full, write it out and *)
                                   (* reset output buffer pointer.     *)

   IF ( Output_Pos >= MaxBuff ) THEN
      BEGIN
         BlockWrite( Output_File, Output_Buffer, MaxBuff );
         Output_Pos := 0;
         Ierr       := IOResult;
      END;
                                   (* Place character in next slot in  *)
                                   (* output buffer.                   *)

   INC( Output_Pos );
   Output_Buffer[Output_Pos] := C;

END   (* Put_Char *);

(*--------------------------------------------------------------------------*)
(*             Put_Code  ---  Write hash code to output file.               *)
(*--------------------------------------------------------------------------*)

PROCEDURE Put_Code( Hash_Code : INTEGER );

BEGIN (* Put_Code *)
                                   (* Output code word is empty.        *)
                                   (* Put out 1st 8 bits of compression *)
                                   (* code and save last 4 bit for next *)
                                   (* time through.                     *)

   IF ( Output_Code = Empty ) THEN
      BEGIN
         Put_Char( ( Hash_Code SHR 4 ) AND $FF );
         Output_Code := Hash_Code AND $0F;
      END
   ELSE
                                   (* Output code word not empty.         *)
                                   (* Put out last 4 bits of previous     *)
                                   (* code appended to 1st 4 bits of this *)
                                   (* code.  Then put out last 8 bits of  *)
                                   (* this code.                          *)
      BEGIN
         Put_Char( ( ( Output_Code SHL 4 ) AND $FF0 ) +
                   ( ( Hash_Code SHR 8 ) AND $00F ) ) ;
         Put_Char( Hash_Code AND $FF );
         Output_Code := Empty;
      END;

END   (* Put_Code *);

(*--------------------------------------------------------------------------*)
(*             Do_Compression --- Perform Lempel-Ziv-Welch compression      *)
(*--------------------------------------------------------------------------*)

PROCEDURE Do_Compression;

VAR
   C  : INTEGER             (* Current input character = C *);
   WC : INTEGER             (* Hash code value for <w>C    *);
   W  : INTEGER             (* Hash code value for <w>     *);

BEGIN (* Do_Compression *)
                                   (* Read first character ==> Step 2 *)
   Get_Char( C );
                                   (* Initial hash code -- first character *)
                                   (* has no previous string (<w> is null) *)

   W := Lookup_String( No_Prev , C );

                                   (* Get next character ==> Step 3    *)
   Get_Char( C );
                                   (* Loop over input characters until *)
                                   (* end of file reached ==> Step 4.  *)
   WHILE( C <> EOF_Char ) DO
      BEGIN
                                   (* See if <w>C is in table. *)

         WC := Lookup_String( W , C );

                                   (* If <w>C is not in the table, *)
                                   (* enter it into the table and  *)
                                   (* output <w>.  Reset <w> to    *)
                                   (* be the code for C ==> Step 6 *)

         IF ( WC = End_List ) THEN
            BEGIN

               Make_Table_Entry( W , C );
               Put_Code( W );
               W := Lookup_String( No_Prev , C );

            END
         ELSE                      (* If <w>C is in table, keep looking *)
                                   (* for longer strings == Step 5      *)

            W := WC;

                                   (* Get next input character ==> Step 3 *)
         Get_Char( C );

      END;
                                   (* Make sure last code is       *)
                                   (* written out ==> Step 4.      *)
   Put_Code( W );

END   (* Do_Compression *);

(*--------------------------------------------------------------------------*)
(*                     PibCompr --- Main program                            *)
(*--------------------------------------------------------------------------*)

BEGIN (* PibCompr *)
                                   (* We are doing compression *)
   If_Compressing := TRUE;
                                   (* Initialize compression   *)
   Initialize;
                                   (* Perform compression      *)
   Do_Compression;
                                   (* Clean up and exit        *)
   Terminate;

END   (* PibCompr *).
