%option yylineno 

%{
 #include <string>
 #include <iostream>
 #include <vector>
 #include <list>
 using namespace std ;
 #include "Aux1.h"
 #include "parser.hpp" 

#define TOKEN(t) return t 
#define TOKENST(t) yylval.name = new std::string(yytext, yyleng) ; return t

extern "C" int yywrap() { return(1) ; }  

%}

%%
program                 TOKEN(RPROGRAM);
proc                    TOKEN(RPROC);
int                     TOKEN(RINT);
float                   TOKEN(RFLOAT);
if                      TOKEN(RIF);
while                   TOKEN(RWHILE);
forever                 TOKEN(RFOREVER);
do                      TOKEN(RDO);
until                   TOKEN(RUNTIL);
else                    TOKEN(RELSE);
skip                    TOKEN(RSKIP);
exit                    TOKEN(REXIT);
read                    TOKEN(RREAD);
println                 TOKEN(RPRINTLN);

"*"                     TOKEN(TMUL);
"/"                     TOKEN(TDIV);
"+"                     TOKEN(TSUM);
"-"                     TOKEN(TSUB);

"="                     TOKEN(TASSIG);
";"                     TOKEN(TSEMIC);
"{"                     TOKEN(TLBRACE);
"}"                     TOKEN(TRBRACE);
">="                    TOKEN(TCGE);
"=>"                    TOKEN(TIN);
"<="                    TOKEN(TLEOUT);
"<=>"                   TOKEN(TIO);
"<"                     TOKEN(TCLT);
">"                     TOKEN(TCGT);
"=="                    TOKEN(TCEQ);
"/="                    TOKEN(TCNE);
"("                     TOKEN(TLPAR);
")"                     TOKEN(TRPAR);
","                     TOKEN(TKOM);

#[^#\n]*\n                       ; /* one-line comments */
\[\*([^*]|\*+[^*\]])*\*+\]       ; /* multiple-line comments */

[ \t\n]                        ;

[a-zA-Z](_?[a-zA-Z0-9])*                          TOKENST(TID) ; 
[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?                  TOKENST(TFLOAT);
[0-9]+                                            TOKENST(TINTEGER); 

.                       { cout << "Unknown token: " << yytext << endl; yyterminate();}
%%




