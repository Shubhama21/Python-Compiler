#pragma once
#include "depend.h"

    // Init Functions
extern "C" int yylex_init();

    // Different yylval
YYSTYPE * yylval_ptr;
YYLTYPE * yylloc_ptr;
extern YYSTYPE yy1lval;
extern YYSTYPE yy2lval;
extern YYSTYPE yy3lval;
extern YYLTYPE yy1lloc;
extern YYLTYPE yy2lloc;
extern YYLTYPE yy3lloc;

    // Line Number Updations
#define YY_USER_ACTION {yylloc_ptr->first_line = yylineno; yylloc_ptr->last_line = yylineno;}

