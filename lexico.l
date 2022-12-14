%option noyywrap
%{
	#include "grammar.tab.h"
%}

DIGIT [0-9]
ALPHA [a-zA-Z]
CHARACTERS_BLOCK {QUOTES}({ALPHA}*{WHITESPACE}*{DIGIT}*{COMA}*{DOSP}*{DOT})+{QUOTES}
NAME {ALPHA}([0-9]*{ALPHA}*)+
WHITESPACE [ \r\t\v\f]
LINEFEED \n
SINGLECOMMENT {MENOR}{PLUS}({DOT}*{WHITESPACE}*)+{LINEFEED}+{PLUS}{MAYOR}
MULTILINECOMMENT {MENOR}{PLUS}({DOT}*{WHITESPACE}*{LINEFEED}*)+{PLUS}{MAYOR}
DOT .
COMA[,]
DOSP[:]
MENOR [<]
MAYOR [>]
PLUS [+]
MINUS [-]
WILDCARD [*]
QUOTES [\"]

%%

"+"				{ return PLUS; }
"-"				{ return MINUS; }
"/"				{ return DIVISION; }
","				{ return COMMA; }
"["				{ return LEFT_BRACKET; }
"]"				{ return RIGHT_BRACKET; }
"\\"			{ return SLASH; }
"?"				{ return IF; }
"|"				{ return ELSE; }
"@"				{ return WHILE; }
"="				{ return EQ; }
"<="			{ return LE; }
"<"				{ return LT; }
">"				{ return GT; }
">="			{ return GE; }
"!="			{ return NE; }
"itob"			{ return ITOB; }
"load"			{ return LOAD; }
"show"			{ return SHOW; }	
"+:"			{ return INCREMENTO; }
"-:"			{ return DECREMENTO; }
"Int"			{ return INT; }
"Bln"			{ return BLN; }
"Str"			{ return STR; }
"Dec"			{ return DEC; }
"answer:0;"		{ return ANSWER; }
"tru"			{ return TRU; }
"fls"			{ return FLS; }
{DIGIT}+                { return INTEGER_VALUE; }
{DIGIT}+{DOT}{DIGIT}+ 	{ return DECIMAL_VALUE; }
{NAME}			{ return NAME; }
{CHARACTERS_BLOCK}      { return CHARACTERS_BLOCK; }
{QUOTES}		{ return QUOTES; }
{SINGLECOMMENT}         { return SINGLECOMMENT; }
{MULTILINECOMMENT}      { return MULTILINECOMMENT; }
":"			{ return COLON; }
"::"		{ return DOBLE_COLON;}
";"			{ return SEMICOLON; }
"->"			{ return RIGHT_ARROW; }
"{"			{ return LEFT_CURLY_BRACE; }
"}"			{ return RIGHT_CURLY_BRACE; }
"("			{ return LEFT_PARENTHESIS; }
")"			{ return RIGHT_PARENTHESIS; }
"$"			{ return DOLLAR_SIGN; }
{WHITESPACE}
{LINEFEED}		++yylineno;

%%

#include <stdio.h>


