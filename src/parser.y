%code requires{
    #include "depend.h"
}

%code top{
    // #define yyparse yyparse_2
    #include "depend.h"
}

%define api.value.type {Semantic_Data}
%define parse.error detailed
%define api.prefix {yy}

/* Official */

%token NAME
%token INDENT
%token STRING
%token DEDENT
%token NUMBER
%token NEWLINE
 
/* Keywods */
%token BREAK     
%token CONTINUE     
%token RETURN       
%token GLOBAL
%token NONLOCAL
%token ASSERT
%token IS
%token NOT
%token AND
%token OR
%token IN
%token CLASS
%token DEF
%token IF
%token ELIF
%token ELSE
%token WHILE
%token FOR
%token NONE
%token TRUE
%token FALSE
%token SELF
%token INT
%token BOOL
%token FLOAT
%token STR
%token RANGE
%token LEN
%token PRINT
 
/* Operator with more than 1 symbol */
%token ARROW            /* -> */
%token PLUS_EQ          /* += */
%token MINUS_EQ         /* -= */
%token MUL_EQ           /* *= */
%token DIV_EQ           /* /= */
%token PERCENT_EQ       /* %= */
%token AND_EQ           /* &= */     
%token OR_EQ            /* |= */
%token XOR_EQ           /* ^= */
%token LEFTSHIFT        /* << */
%token LEFTSHIFT_EQ     /* <<= */
%token RIGHTSHIFT       /* >> */ 
%token RIGHTSHIFT_EQ    /* >>= */ 
%token DOUBLE_STAR      /* ** */
%token POW_EQ           /* **= */ 
%token FLOORDIV         /* // */
%token FLOORDIV_EQ      /* //= */
%token EQ_EQ            /* == */
%token NEQ              /* != */
%token LE_EQ            /* <= */
%token GT_EQ            /* >= */
 
%%

input:
    %empty
|   NAME
    {
        @1.first_line;
    }

%%
