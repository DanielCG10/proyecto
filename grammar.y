%code requires {
	#include <string>
}
%{
	#include <math.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <iostream>
	#include <memory>
	#include <string>
	using namespace std;
	extern char *yytext;
	std::string result;
	int yylex(void);	
	void yyerror(char const *);
%}

%define api.value.type { std::string }

%token  NAME COLON RIGHT_ARROW LEFT_CURLY_BRACE RIGHT_CURLY_BRACE SEMICOLON LEFT_PARENTHESIS RIGHT_PARENTHESIS SINGLECOMMENT MULTILINECOMMENT QUOTES CHARACTERS_BLOCK INT INTEGER_VALUE DECIMAL_VALUE LOAD SHOW DOLLAR_SIGN INCREMENTO DECREMENTO DEC BLN SET TRU FLS ITOB LEFT_BRACKET RIGHT_BRACKET EQ LE LT GT GE NE IF ELSE COMMA PLUS SLASH MINUS DIVISION STR DOBLE_COLON WHILE ANSWER 

%start input

%%

input:
	function function_list	{ result = std::string("#include <cstdio>\n #include <iostream>\n using namespace std;\n") + $1 + $2; }
	;

function_list:
	function function_list                  { $$ = $1 + $2; }
	|
	%empty					{ $$ = ""; }
	;

function:
	name DOBLE_COLON LEFT_BRACKET RIGHT_BRACKET RIGHT_ARROW LEFT_BRACKET INT RIGHT_BRACKET COLON LEFT_CURLY_BRACE statements ANSWER RIGHT_CURLY_BRACE    
	{ 
		if($1 == "main"){
			$$ = "int main(int argc, char *argv[]){\n" + $11 + "\n}\n";
		}else{
			$$ = std::string("\n void ") + "_" + $1 + "()" + "{\n" + $11 + "\n}\n";
		} 
	}
	|
	%empty					{ $$ = ""; }
	;

statements:
	statements statement { 
				$$ = $1 + $2;
				}
	|
	%empty					{ $$ = ""; }
	;

statement:
	bifurcation { $$ = $1; }
	|
	loop { $$ = $1; }
	|
	assignment SEMICOLON { $$ = $1; }
	|
	unitaryOperations SEMICOLON { $$ = $1; }
	|
	std_input SEMICOLON { $$ = $1; }
	|
	definition SEMICOLON { $$ = $1; }
	|
	std_output SEMICOLON { $$ = $1; }
	|
	MULTILINECOMMENT	{ $$ = ""; }
	|
	SINGLECOMMENT	{ $$ = ""; }
	|
	expression SEMICOLON { $$ = $1; }
	;

bifurcation:
	LEFT_BRACKET logical_eval RIGHT_BRACKET IF statement { $$ = "if(" + $2 + "){\n" + $5 + "}\n"; }
	|
	ELSE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE 	{ $$ = "else{\n" + $3 + "}\n";}
	|
	LEFT_BRACKET logical_eval RIGHT_BRACKET IF LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE { $$ = "if(" + $2 + "){\n" + $6 + "}\n"; }
	|
	LEFT_BRACKET logical_eval RIGHT_BRACKET ELSE IF LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE { $$ = "else if(" + $2 + "){\n" + $7 + "}\n"; }
	;

	loop:

	LEFT_BRACKET logical_eval RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE { $$ = "while(" + $2 + "){\n" + $6 		+"}\n"; }
	|
	LEFT_BRACKET  name COLON integer_value SLASH DOLLAR_SIGN name comp_operator integer_value SLASH name COLON DOLLAR_SIGN name PLUS integer_value RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
         {$$ = "for(int " + $2 + "=" + $4 +  ";" + $7 + $8 + $9 +";" + $11 + "=" + $14 + "+" + $16 + "){\n" + $20 + "}\n"; }
    |
	LEFT_BRACKET  name COLON integer_value SLASH DOLLAR_SIGN name comp_operator integer_value SLASH name COLON DOLLAR_SIGN name MINUS integer_value RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
         {$$ = "for(int " + $2 + "=" + $4 +  ";" + $7 + $8 + $9 +";" + $11 + "=" + $14 + "-" + $16 + "){\n" + $20 + "}\n"; }
    |
	LEFT_BRACKET  name COLON integer_value SLASH DOLLAR_SIGN name comp_operator DOLLAR_SIGN name  SLASH name COLON DOLLAR_SIGN name PLUS integer_value RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
        { $$ = "for(int " + $2 + "=" + $4 +  ";" + $7 + $8 + $10 + ";" + $12 + "=" + $15 + "+" + $17 + "){\n" + $21 + "}\n"; }
	|
	LEFT_BRACKET  name COLON integer_value SLASH DOLLAR_SIGN name comp_operator DOLLAR_SIGN name  SLASH name COLON DOLLAR_SIGN name MINUS integer_value RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
        { $$ = "for(int " + $2 + "=" + $4 +  ";" + $7 + $8 + $10 + ";" + $12 + "=" + $15 + "-" + $17 + "){\n" + $21 + "}\n"; }
    |
    LEFT_BRACKET  name COLON DOLLAR_SIGN name SLASH DOLLAR_SIGN name comp_operator integer_value  SLASH name COLON DOLLAR_SIGN name PLUS integer_value RIGHT_BRACKET WHILE LEFT_CURLY_BRACE statements RIGHT_CURLY_BRACE
    { $$ = "for(int " + $2 + "=" + $5 +  ";" + $8 + $9 + $10 + ";" + $12 + "=" + $15 + "+" + $17 + "){\n" + $21 + "}\n"; }
	;

logical_eval:
	integer_value comp_operator integer_value	{ $$ = $1 + $2 + $3; }
	|
	DOLLAR_SIGN name comp_operator integer_value { $$ = $2 + $3 + $4; }
	|
	DOLLAR_SIGN name comp_operator DOLLAR_SIGN name { $$ = $2 + $3 + $5; }
	|
    DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET comp_operator DOLLAR_SIGN name
    { $$ = $2 + "[" + $5 + "]" + $7 + $9; }
	|
	DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET comp_operator DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET
	{ $$ = $2 + "[" + $5 + "]" + $7 + $9 + "[" + $12 + "]"; } 
	;

comp_operator:
	EQ	{ $$ = "=="; }
	|
	LE	{ $$ = "<="; }
	|
	LT	{ $$ = "<"; }
	|
	GT	{ $$ = ">"; }
	|
	GE	{ $$ = ">="; }
	|
	NE	{ $$ = "!="; }
	;

assignment:
	name COLON integer_value { $$ = $1 + "=" + $3 + ";\n";}
	|
	name COLON decimal_value { $$ = $1 + "=" + $3 + ";\n";}
	|
	ids DOBLE_COLON integer_value { $$ = $1 + "=" + $3 + ";\n";}
	|
	ids DOBLE_COLON decimal_value { $$ = $1 + "=" + $3 + ";\n";}
	|
	ids DOBLE_COLON characters_block {$$ = $1 + "=" + $3 + ";\n";}
	|
	ids INCREMENTO integer_value { $$ = $1 + "+=" + $3 + ";\n";}
	|
	ids DOBLE_COLON DOLLAR_SIGN ids { $$ = $1 + "=" + $4 + ";\n";}
	|
	name COLON DOLLAR_SIGN name { $$ = $1 + "=" + $4 + ";\n";}
	|
	name INCREMENTO DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET
        { $$ = $1 + "+=" + $4 + "[" + $7 + "]" + ";\n"; }
	|
	ids COLON LEFT_BRACKET integer_value COMMA integer_value RIGHT_BRACKET { $$ = $1 + "[" + $4 + "]=" + $6 + ";\n";}
	|
	name COLON DOLLAR_SIGN name PLUS integer_value { $$ = $1 + "=" + $4 + "+" + $6 + ";\n";}
	|
	name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET INCREMENTO integer_value
        { $$ = $1 + "[" + $4 + "]" + "+=" + $7 + ";\n"; }
	|
	name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET COLON integer_value
        { $$ = $1 + "[" + $4 + "]" + "=" + $7 + ";\n"; }
	|
	name COLON LEFT_BRACKET integer_value COMMA integer_value2 RIGHT_BRACKET { $$ = $1 + "[" + $4 + "]" + "=" + $6 + ";\n"; }
	|
	name COLON LEFT_BRACKET DOLLAR_SIGN name COMMA DOLLAR_SIGN name RIGHT_BRACKET { $$ = $1 + "[" + $5 + "]" + "=" + $8 + ";\n"; }
	|
	name COLON LEFT_BRACKET integer_value COMMA DOLLAR_SIGN name RIGHT_BRACKET { $$ = $1 + "[" + $4 + "]" + "=" + $7 + ";\n"; }
	|
	name COLON LEFT_BRACKET DOLLAR_SIGN name COMMA integer_value RIGHT_BRACKET { $$ = $1 + "[" + $5 + "]" + "=" + $7 + ";\n"; }
	|
	name COLON DOLLAR_SIGN name LEFT_BRACKET integer_value RIGHT_BRACKET { $$ = $1 + "=" + $4 + "[" + $6 + "]" + ";\n"; }
	|
	name COLON DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN ids RIGHT_BRACKET { $$ = $1 + "=" + $4 + "[" + $7 + "]" + ";\n"; }
	|
	name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET COLON DOLLAR_SIGN name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET
	{ $$ = $1 + "[" + $4 + "]" + "=" + $8 + "[" + $11 + "]" + ";\n"; }
	|
	name LEFT_BRACKET DOLLAR_SIGN name RIGHT_BRACKET COLON DOLLAR_SIGN name  
        { $$ = $1 + "[" + $4 + "]" + "=" + $8 + ";\n"; }
	|
	name COLON DOLLAR_SIGN name DIVISION integer_value { $$ = $1 + "=" + $4 + "/" + $6 + ";\n"; }
	|
	ids DOBLE_COLON FLS  { $$ = $1 + "=false; \n"; }
	|
	ids DOBLE_COLON TRU	{ $$ = $1 + "=true; \n"; }
	|
	ids DECREMENTO integer_value { $$ = $1 + "-=" + $3 + ";\n";}
	;

integer_value:
	INTEGER_VALUE { $$ = std::string(yytext); }
	;

integer_value2:
	INTEGER_VALUE { $$ = std::string(yytext); }
	;

decimal_value:
	DECIMAL_VALUE { $$ = std::string(yytext); }
	;

unitaryOperations:
	INCREMENTO identifiers	{ $$ = $2 + "++;\n";}
	|
	DECREMENTO identifiers { $$ = $2 + "--;\n";}
	;

std_input:
	LOAD COLON name { $$ = "\t cin >> " + $3 + ";\n"; }
	;

definition:
	name COLON INT LEFT_BRACKET integer_value RIGHT_BRACKET { $$ = "int " + $1 + "[" + $5 + "];\n";	}
	|
	name COLON DEC LEFT_BRACKET integer_value RIGHT_BRACKET { $$ = "float " + $1 + "[" + $5 + "];\n";	}
	|
	ids COMMA ids COMMA ids COLON STR { $$ = "\t string " + $1 + "," + $3 + "," + $5 + ";\n"; }
	|
	ids COMMA ids COMMA ids COLON DEC { $$ = "\t float " + $1 + "," + $3 + "," + $5 + ";\n"; }
	|
	BLN DOBLE_COLON identifiers { $$ = "\t bool " + $2 + ";\n"; }
	|
	ids DOBLE_COLON INT { $$ = "\t int " + $1 + ";\n"; }
	|
	ids DOBLE_COLON DEC { $$ = "\t float " + $1 + ";\n"; }
	|
	ids COMMA ids COMMA ids COLON INT { $$ = "\t int " + $1 + "," + $3 + "," + $5 + ";\n"; }
	|
	STR DOBLE_COLON identifiers { $$ = "\t string " + $2 + ";\n";}
	|
	DEC DOBLE_COLON identifiers { $$ = "\t float " + $2 + ";\n";}
	;

identifiers:
	identifiers ids	{ $$ = $1 + $2; }
	|
	%empty	{ $$ = ""; }
	;

ids:
	name	{ $$ = $1; }
	;

std_output:
	SHOW COLON ITOB DOLLAR_SIGN name	{ 
					$$ = "cout << ((" + $5 + "==1) ? \"true\" : \"false\") << endl;"; 
					}
	|
	SHOW COLON characters_block	{ $$ = "\t cout << " + $3 + " << endl;\n"; }
	|
	SHOW COLON DOLLAR_SIGN name	{ $$ = "cout << " + $4 + " << endl;"; }
	|
	SHOW COLON characters_block COMMA DOLLAR_SIGN name { $$ = "cout << " + $3 + " << " + $6 + " << endl;"; }
	|
	SHOW COLON characters_block COMMA DOLLAR_SIGN name COMMA characters_block{ $$ = "cout << " + $3 + " << " + $6 + " << " + $8 + " << endl;"; }
	|
	SHOW COLON DOLLAR_SIGN ids COMMA integer_value { $$ = "cout << " + $4 + "[" + $6 + "]  << endl;\n"; }
	|
	SHOW COLON DOLLAR_SIGN ids COMMA DOLLAR_SIGN ids { $$ = "cout << " + $4 + "["+ $7 + "]" + "<< endl;\n"; }
	|
	SHOW COLON characters_block COMMA DOLLAR_SIGN ids COMMA DOLLAR_SIGN ids { $$ = "cout << " + $3 + "<<" + $6 + "["+ $9 + "]" + "<< endl;\n"; }
	;

expression:
	name LEFT_PARENTHESIS RIGHT_PARENTHESIS	{ $$ = std::string("\t _") + $1 + "();\n"; }
	;

characters_block: 
	CHARACTERS_BLOCK { $$ = std::string(yytext); }
	;

name:
	NAME    {  
		$$ = std::string(yytext);
		}
	;

%%

void yyerror (char const *x){
	printf ("Error %s \n", x);
	exit(1);
}
