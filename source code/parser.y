%{
   #include <stdio.h>
   #include <iostream>
   #include <vector>
   #include <string>
   using namespace std; 

   extern int yylex();
   extern int yylineno;
   extern char *yytext;
   void yyerror (const char *msg) {
     printf("line %d: %s at '%s'\n", yylineno, msg, yytext) ;
   }

   #include "Code.h"
   #include "Aux1.h"

   Code code;

%}


/* Declare the atribute types */

%union {
   string *name; 
   string *type;
   IdList *names;
   expressionstruct *exp;
   int ref;
   skipexitstruct *jump;
}


/* 
 * Tokens that have the .name atribute
 */

%token <name> TID TINTEGER TFLOAT

/* Non-atribute having tokens: */

%token RINT RFLOAT TASSIG TLBRACE TRBRACE TSEMIC TKOM RDO RPROGRAM RUNTIL RELSE 
%token RPROC TLPAR TRPAR TIN TIO RWHILE RFOREVER RSKIP RIF REXIT RREAD
%token TSUM TSUB TMUL TDIV TCEQ TCGT TCLT TCGE TLEOUT TCNE RPRINTLN


/* Declare the non-finals which have atributes */

%type <exp> expression
%type <name> variable
%type <type> type par_type
%type <names> id_list id_list_others
%type <ref> M 
%type <jump> statement statement_list


%start program

%nonassoc TCEQ TCGT TCLT TCGE TLEOUT TCNE
%left TSUM TSUB
%left TMUL TDIV

%%

program : RPROGRAM TID { code.addStatement("prog " + *$<name>2); delete $<name>2;}
            declarations method_declarations 
            TLBRACE statement_list TRBRACE {code.addStatement("halt "); code.write();}
         ;

declarations : type id_list TSEMIC 
               {code.addDecls(*$<type>1, *$<names>2);delete $<names>2;}
               declarations
             | /* empty production */
             ;

id_list : TID id_list_others
               {
                $<names>$ = new IdList;
                $<names>$ -> push_back(*$<name>1);
                $<names>$ -> insert($<names>$->end(), $<names>2->begin(), $<names>2->end());
                delete $<name>1;
                delete $<names>2;
               }
            ;

id_list_others : TKOM TID id_list_others
                        {
                          $<names>$ = new IdList;
                          $<names>$ -> push_back(*$<name>2);
                          $<names>$ -> insert($<names>$->end(), $<names>3->begin(), $<names>3->end());
                          delete $<name>2;
                          delete $<names>3;
                        }
                      | /* empty production */ {$<names>$ = new IdList;}
                      ;

type : RINT {$<type>$ = new std::string; *$<type>$ = SINTEGER;}
     | RFLOAT {$<type>$ = new std::string; *$<type>$ = SFLOAT;}
     ;

method_declarations : method_declaration method_declarations
                          | /* empty production */
                          ;

method_declaration : RPROC TID {code.addStatement("proc " + *$<name>2); delete $<name>2;}
                              arguments declarations method_declarations 
                              TLBRACE statement_list TRBRACE {code.addStatement("endproc");}
                            ;

arguments : TLPAR par_list TRPAR
            | /* empty production */
            ;

par_list : type par_type id_list 
               {
                code.addParams(*$<type>1, *$<names>3, *$<type>2);
                delete $<type>1;
                delete $<names>3;
                delete $<type>2;
               }
               par_list_others
             ;                          

par_type : TIN {$<type>$ = new std::string; *$<type>$ = "in";}
         | TLEOUT {$<type>$ = new std::string; *$<type>$ = "out";}
         | TIO {$<type>$ = new std::string; *$<type>$ = "in out";}
         ;

par_list_others : TSEMIC type par_type id_list 
                        {
                          code.addParams(*$<type>2, *$<names>4, *$<type>3);
                          delete $<type>2;
                          delete $<names>4;
                          delete $<type>3;
                        }
                        par_list_others
                       | /* empty production */ 
                       ;

statement_list : statement statement_list
                     {
                      $<jump>$ = new skipexitstruct;
                      $<jump>$->skip = $<jump>1->skip;
                      $<jump>$->skip.insert($<jump>$->skip.end(), $<jump>2->skip.begin(), $<jump>2->skip.end());
                      $<jump>$->exit = $<jump>1->exit;
                      $<jump>$->exit.insert($<jump>$->exit.end(), $<jump>2->exit.begin(), $<jump>2->exit.end());
                      delete $<jump>1;
                      delete $<jump>2;
                     }
                    | /* empty production */ {$<jump>$ = new skipexitstruct;}
                    ;

statement : variable TASSIG expression TSEMIC
               { 
                 $<jump>$ = new skipexitstruct;
                 code.addStatement(*$<name>1 + " := " + $<exp>3->name);
                 delete $<name>1;
                 delete $<exp>3;
               }
           | RIF expression M TLBRACE statement_list TRBRACE M TSEMIC
               { 
                 $<jump>$ = new skipexitstruct;
                 code.completeStatement($<exp>2->trueL, $<ref>3);
                 code.completeStatement($<exp>2->falseL, $<ref>7);
                 $<jump>$->exit = $<jump>5->exit;
                 $<jump>$->skip = $<jump>5->skip; 
                 delete $<exp>2;
               }
           | RWHILE RFOREVER M TLBRACE statement_list TRBRACE M TSEMIC
               {
                 $<jump>$ = new skipexitstruct;
                 stringstream ss; ss << $<ref>3;
                 code.addStatement("goto " + ss.str());
                 code.completeStatement($<jump>5->exit, $<ref>7+1);
                 $<jump>$->skip = $<jump>5->skip;
                 delete $<jump>5;
               }
           | RDO M TLBRACE statement_list TRBRACE RUNTIL M expression RELSE M TLBRACE statement_list TRBRACE M TSEMIC
               {
                 $<jump>$ = new skipexitstruct;
                 code.completeStatement($<exp>8->trueL, $<ref>10);
                 code.completeStatement($<exp>8->falseL, $<ref>2);
                 code.completeStatement($<jump>4->skip, $<ref>7);
                 code.completeStatement($<jump>4->exit, $<ref>14);
                 code.completeStatement($<jump>12->exit, $<ref>14);
                 $<jump>$->skip = $<jump>12->skip;
                 delete $<exp>8;
                 delete $<jump>4;
                 delete $<jump>12;
               }
           | RSKIP RIF expression TSEMIC M
               {
                $<jump>$ = new skipexitstruct;
                code.completeStatement($<exp>3->falseL, $<ref>5);
                $<jump>$->skip = $<exp>3->trueL;
                delete $<exp>3;
               }
           | REXIT TSEMIC
               {
                $<jump>$ = new skipexitstruct;
                $<jump>$->exit.push_back(code.getRef());
                code.addStatement("goto");
               }
           | RREAD TLPAR variable TRPAR TSEMIC
               {
                $<jump>$ = new skipexitstruct;
                code.addStatement("read " + *$<name>3);
               }
           | RPRINTLN TLPAR expression TRPAR TSEMIC
               {
                $<jump>$ = new skipexitstruct;
                code.addStatement("write " + $<exp>3->name);
                code.addStatement("writeln");
               }
           ;

M : /* empty production */ { $<ref>$ = code.getRef(); }
  ;

variable : TID {$<name>$ = $<name>1;}
         ;

expression : expression TSUM expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = code.newId();
                code.addStatement($<exp>$->name + " := " + $<exp>1->name + " + " + $<exp>3->name);
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TSUB expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = code.newId();
                code.addStatement($<exp>$->name + " := " + $<exp>1->name + " - " + $<exp>3->name);
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TMUL expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = code.newId();
                code.addStatement($<exp>$->name + " := " + $<exp>1->name + " * " + $<exp>3->name);
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TDIV expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = code.newId();
                code.addStatement($<exp>$->name + " := " + $<exp>1->name + " / " + $<exp>3->name);
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TCEQ expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " = " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TCGT expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " > " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TCLT expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " < " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TCGE expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " >= " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TLEOUT expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " <= " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | expression TCNE expression
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->trueL.push_back(code.getRef());
                $<exp>$->falseL.push_back(code.getRef()+1);
                code.addStatement("if " + $<exp>1->name + " != " + $<exp>3->name + " goto");
                code.addStatement("goto");
                delete $<exp>1;
                delete $<exp>3;
              }
            | variable
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = *$<name>1;
                delete $<name>1;
              }
            | TINTEGER
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = *$<name>1;
                delete $<name>1;
              }
            | TFLOAT
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = *$<name>1;
                delete $<name>1;
              }
            | TLPAR expression TRPAR
              {
                $<exp>$ = new expressionstruct;
                $<exp>$->name = $<exp>2->name;
                $<exp>$->trueL = $<exp>2->trueL;
      		      $<exp>$->falseL = $<exp>2->falseL;
                delete $<exp>2;
              }
            ;

%%

