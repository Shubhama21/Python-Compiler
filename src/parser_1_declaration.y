%code requires{
    #include "depend.h"
}

%code top{
    // #define yyparse yyparse_1_declaration
    #include "depend.h"
}

%define api.value.type {Semantic_Data}
%define parse.error detailed
%define api.prefix {yy1}

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

file_input:
    Statements
    {
       // To introduce yyloc
        @1.first_line;
    }

Statements:
    Statements NEWLINE
    {

    }
|   Statements stmt
    {       
    }
|   %empty
    {
    }

Base_Class_List:
    %empty
    {
        $<lexeme>$ = "";
    }
|   '(' opt_comma ')'
    {
        $<lexeme>$ = "";
    }
|   '(' NAME opt_comma ')'
    {
        $<lexeme>$ = $<lexeme>2;
    }

opt_arglist:
    %empty
    {
    }
|   Argument_List
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
    }

Function_Defination_Semantic_Actions:
    %empty
    {
        if (current_symbol_table->type == FUNCTION_SYMBOL_TABLE){
            myerror("Function defination inside another function not allowed", yylineno);
        }
        Symbol_Table * function_symbol_table = new Symbol_Table;
        // if (current_symbol_table->type == GLOBAL_SYMBOL_TABLE){
        //     Function_Sym_Tbl_list.push_back(function_symbol_table);
        // }
        Function_Sym_Tbl_list.push_back(function_symbol_table);
        function_symbol_table->parent_symbol_table = current_symbol_table;
        function_symbol_table->type = FUNCTION_SYMBOL_TABLE;
        current_symbol_table = function_symbol_table;
    }

Function_Defination: 
    DEF NAME Function_Defination_Semantic_Actions Parameters ARROW Return_Type ':' Block
    {
        current_symbol_table->name = $<lexeme>2;
        current_symbol_table->parent_symbol_table->add_function($<lexeme>2, @1.first_line, $<virtual_line_no>1, current_symbol_table, $<func_args>4 , {$<is_list>6, $<lexeme>6});
        current_symbol_table = current_symbol_table->parent_symbol_table;
        //what happens if it is a class function?
    }
|   DEF NAME Function_Defination_Semantic_Actions Parameters ':' Block
    {
        current_symbol_table->name = $<lexeme>2;      
        current_symbol_table->parent_symbol_table->add_function($<lexeme>2, @1.first_line, $<virtual_line_no>4, current_symbol_table, $<func_args>4 , {false, "None"});
        current_symbol_table = current_symbol_table->parent_symbol_table;
    }

Parameters: 
    '(' ')'
    {
        $<func_args>$.clear();
    }
|   '(' Defination_Parameter_List ')'
    {
        $<func_args>$ = $<func_args>2;
    }

Defination_Parameter_List:
    SELF
    {
        if (current_symbol_table->parent_symbol_table->type == GLOBAL_SYMBOL_TABLE){
            myerror("Function defined outside class cannot have parameter self", $<line_no>1);
        }
        $<func_args>$.push_back({0,current_symbol_table->parent_symbol_table->name});
        current_symbol_table->add_entry("self" , $<virtual_line_no>1 , {0,current_symbol_table->parent_symbol_table->name} , true , $<line_no>1);
    }
|   SELF ':' NAME
    {
        if (current_symbol_table->parent_symbol_table->type == GLOBAL_SYMBOL_TABLE){
            myerror("Function defined outside class cannot have parameter self", $<line_no>1);
        }
        if (current_symbol_table->parent_symbol_table->name != $<lexeme>3){
            myerror("Type hint for self must be the same as class name", $<line_no>1);
        }
        $<func_args>$.push_back({0,current_symbol_table->parent_symbol_table->name});
        current_symbol_table->add_entry("self" , $<virtual_line_no>1 , {0,current_symbol_table->parent_symbol_table->name} , true , $<line_no>1);
    }
|   Parameter
    {
        $<func_args>$ = $<func_args>1;
    }
|   Defination_Parameter_List ',' Parameter
    {
        $<func_args>$ = $<func_args>1;
        $<func_args>$.push_back($<func_args>3[0]);
    }

Parameter:
    NAME ':' Data_Type   
    {
        current_symbol_table->add_entry($<lexeme>1, $<virtual_line_no>1, {$<is_list>3, $<lexeme>3} , true, $<line_no>1);
        $<func_args>$ = {{$<is_list>3 , $<lexeme>3}};
    }
|   NAME ':' Data_Type '=' Test
    {        
        current_symbol_table->add_entry($<lexeme>1, $<virtual_line_no>1, {$<is_list>3, $<lexeme>3} , true, $<line_no>1);
        $<func_args>$ = {{$<is_list>3 , $<lexeme>3}};
    }

opt_comma:
    %empty
    {
    }
|   ','
    {
    }

opt_semi_colon:
    %empty
    {
    }
|   ';'
    {
    }

stmt: 
    One_Line_Statement 
    {
    }
|   compound_stmt
    {
    }

One_Line_Statement: 
    Partial_Line_Statements opt_semi_colon NEWLINE
    {       
    }

Partial_Line_Statements:
    Partial_Line_Statement
    {
    }
|   Partial_Line_Statements ';' Partial_Line_Statement
    {
    }

Partial_Line_Statement: 
    Expression 
    {
    }
|   flow_stmt 
    {
    }
|   Global_Statement 
    {
    }
|   PRINT '(' Test ')'
    {
    }
Expression: 
    LHS_Variable_Declare ':' Data_Type 
    {
        if ($<is_self>1 == true){
            current_symbol_table->add_self_entry($<lexeme>1, $<virtual_line_no>2, {$<is_list>3, $<lexeme>3});   
        }
        else
        {
            current_symbol_table->add_entry($<lexeme>1, $<virtual_line_no>2, {$<is_list>3, $<lexeme>3} , false, $<line_no>2);
        }    
    }
|   LHS_Variable_Declare ':' Data_Type '=' Test
    {
        if ($<is_self>1 == true)
        {
            current_symbol_table->add_self_entry($<lexeme>1, $<virtual_line_no>2 , {$<is_list>3, $<lexeme>3});   
        }
        else{
            current_symbol_table->add_entry($<lexeme>1, $<virtual_line_no>2 , {$<is_list>3, $<lexeme>3} , false, $<line_no>2);
        }    
    }
|   LHS_Variable_Assign augassign Test
    {
    }
|   Test_List 
    {    
    }
|   LHS_Variable_Assign '=' Test
    {   
    }

LHS_Variable_Declare:
    Atomic_Expression
    {
        $<virtual_line_no>$ = $<virtual_line_no>1;
        if ($<is_declarable>1){
            $<lexeme>$ = $<lexeme>1;
            $<is_self>$ = $<is_self>1;       
        }
        else
        {
            myerror("This expression can not be declared", @1.first_line, @1.last_line);
        }
    }

LHS_Variable_Assign:
    Atomic_Expression
    {
        $<virtual_line_no>$ = $<virtual_line_no>1;
        if ($<is_assignable>1){
            $<lexeme>$ = $<lexeme>1;
        }
        else{
            myerror("LHS of assignment cannot be assigned a value", @1.first_line, @1.last_line);
        }
    }

Return_Type:
    NONE
    {
        $<lexeme>$ = $<lexeme>1;
        $<is_list>$ = false;
    }
|   Data_Type
    {
        $<lexeme>$ = $<lexeme>1;
        $<is_list>$ = $<is_list>1;
    }

Data_Type:
    NAME
    {
        if (Class_Table.find($<lexeme>1)==Class_Table.end())
        {
            myerror($<lexeme>1 + " is an invalid Data Type", @1.first_line);
        }
        $<lexeme>$ = $<lexeme>1;
        $<is_list>$ = false;
    }
|   NAME '[' NAME ']'
    {
        if ($<lexeme>1 != "list"){
            myerror($<lexeme>1 + "[" + $<lexeme>3 + "]" + " is an invalid Data Type", @1.first_line, @4.first_line);
        }
        if (Class_Table.find($<lexeme>3)==Class_Table.end())
        {
            myerror($<lexeme>3 + " is an invalid Data Type", @1.first_line);
        }
        $<lexeme>$ = $<lexeme>3;
        $<is_list>$ = true;
    }
|   Primitive_Type
    {
        $<lexeme>$ = $<lexeme>1;
        $<is_list>$ = false;
        // cout<<"Primitve production encountered\n";
    }
|   NAME '[' Primitive_Type ']'
    {
        if ($<lexeme>1 != "list"){
            myerror($<lexeme>1 + "[" + $<lexeme>3 + "]" + " is an invalid Data Type", @1.first_line, @4.first_line);
        }
        $<lexeme>$ = $<lexeme>3;
        $<is_list>$ = true;   
    }

Primitive_Type:
    INT
    {
        $<lexeme>$ = "int";
    }
|   FLOAT
    {
        $<lexeme>$ = "float";
    }
|   BOOL
    {
        $<lexeme>$ = "bool";
    }
|   STR
    {
        $<lexeme>$ = "str";
    }

augassign: 
    PLUS_EQ
    {
    }
|   MINUS_EQ
    {
    } 
|   MUL_EQ
    {
    }
|   DIV_EQ
    {
    }
|   PERCENT_EQ
    {
    } 
|   AND_EQ
    {
    }
|   OR_EQ
    {
    }
|   XOR_EQ
    {
    }
|   LEFTSHIFT_EQ
    {
    }
|   RIGHTSHIFT_EQ
    {
    }
|   POW_EQ
    {
    }
|   FLOORDIV_EQ
    {
    }

flow_stmt: 
    break_stmt 
    {
    }
|   continue_stmt 
    {
    }
|   Return_Statement 
    {
    }
break_stmt: 
    BREAK
    {
    }
continue_stmt: 
    CONTINUE
    {
    }
Return_Statement: 
    RETURN 
    {
    }
|   RETURN Test
    {
    }

Global_Statement: 
    GLOBAL Names
    {
        for (auto &it:$<name_list>2){
            if (current_symbol_table->symbol_table.find(it) != current_symbol_table->symbol_table.end()){
                myerror("Cannot re-declare local variable "+it+" as a global variable\n", $<line_no>1);
            }
            if (global_symbol_table->symbol_table.find(it) == current_symbol_table->symbol_table.end()){
                myerror("Global variable "+it+" has not been declared before\n", $<line_no>1);
            }
            current_symbol_table->symbol_table[it] = global_symbol_table->symbol_table[it];
        }
    }

Names:
    NAME
    {
        $<name_list>$.push_back($<lexeme>1);
    }
|   Names ',' NAME
    {
        $<name_list>$ = $<name_list>1;
        $<name_list>$.push_back($<lexeme>3);
    }


compound_stmt: 
    IF_Statement
    {
    } 
|   While_Statement
    {
    } 
|   For_Statement
    {
    } 
|   Function_Defination
    {
    } 
|   Class_Defination
    {
    } 

Optional_Else_Statement:
    %empty
    {
    }
|   ELSE ':' Block
    {
    }

IF_Statement: 
    IF Test ':' Block Elif_Statements Optional_Else_Statement
    {
    }
Elif_Statements:
    %empty
    {
    }
|   Elif_Statements ELIF Test ':' Block
    {
    }
While_Statement: 
    WHILE Test ':' Block
    {
    }
For_Statement: 
    FOR NAME IN RANGE '(' Test ')' ':' Marker Block
    {
    }
|    
    FOR NAME IN RANGE '(' Test ',' Test ')' ':' Marker Block
    {
    }
Marker:
    %empty
    {
        current_symbol_table->add_for_variable();
    }
Block: 
    One_Line_Statement 
    {
    }
|   NEWLINE INDENT stmt Block_Statements DEDENT
    {
    }
Block_Statements:
    %empty
    {
    }
|   Block_Statements stmt
    {
        
    }

Test: 
    or_Test 
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }

or_Test: 
    and_Test
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   or_Test OR and_Test
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
    
and_Test: 
    not_Test
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   and_Test AND not_Test
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
    
not_Test: 
    NOT not_Test 
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   comparison
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
comparison: 
    expr
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   comparison Comparison_Operator expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
    
Comparison_Operator: 
    '<'
    {
    }
|   '>'
    {
    }
|   EQ_EQ
    {
    }
|   GT_EQ
    {
    }
|   LE_EQ
    {
    }
|   NEQ
    {
    }
|   IS
    {
    }
|   IS NOT
    {
    }

expr:
    xor_expr
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   expr '|' xor_expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
xor_expr: 
    and_expr
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   xor_expr '^' and_expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
and_expr: 
    shift_expr
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   and_expr '&' shift_expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
shift_expr: 
    arith_expr 
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   shift_expr LEFTSHIFT arith_expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   shift_expr RIGHTSHIFT arith_expr
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
arith_expr: 
    term
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   arith_expr '+' term
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   arith_expr '-' term
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
term: 
    Factor
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   term '*' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   term '/' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   term '%' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   term FLOORDIV Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
Factor: 
    power
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   '+' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   '-' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
|   '~' Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    } 
power: 
    Atomic_Expression 
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
        
        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
    }
|   Atomic_Expression DOUBLE_STAR Factor
    {
        //INHERIT_FALSE_FLAGS
        $<is_declarable>1 = false;
        $<is_assignable>$ = false;
        $<is_func_ret_type>$ = false;
    }
/* Atomic_Expression: 
    Atom Trailers
    {
    }
Trailers:
    %empty
    {
    }
|   Trailers Trailer
    {
      
    } */
Atomic_Expression:
    Atom
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;

        //INHERIT_FLAGS
        $<is_declarable>$ = $<is_declarable>1;
        $<is_assignable>$ = $<is_assignable>1;
        $<is_func_ret_type>$ = $<is_func_ret_type>1;
        $<lexeme>$ = $<lexeme>1;
    }
|   Atomic_Expression Trailer
    {
        if ($<trailer_type>2 == '.'){
            if ($<lexeme>1 == "self"){
                $<is_declarable>$ = true;
                $<is_assignable>$ = true;
                $<lexeme>$ = $<lexeme>2;
                $<is_self>$ = true;
            }
            else
            {
                $<is_declarable>$ = false;
                $<is_assignable>$ = $<is_assignable>1;
                //foo().x = 2 was working
            }
        }
        else if ($<trailer_type>2 == '('){
            if ($<lexeme>1 == "self"){
                myerror("keyword \"self\" cannot be used as function name", @2.first_line);
            }
            else{
                $<is_declarable>$ = false;
                $<is_assignable>$ = false;
            }
        }
        else if ($<trailer_type>2 == '['){
            if ($<lexeme>1 == "self"){
                myerror("keyword \"self\" cannot be used as a list", @2.first_line);
            }
            else{
                $<is_declarable>$ = false;
                $<is_assignable>$ = $<is_assignable>1;
            }
        }
    }
Atom:
    '(' Test ')' 
    {
    }
|   '[' ']' 
    {
    }
|   '[' Test_List ']' 
    {
    }
|   NAME
    {
        $<is_declarable>$ = true;
        $<is_assignable>$ = true;
        $<is_func_ret_type>$ = true;
        $<lexeme>$ = $<lexeme>1;

        // Base Class List
        $<lexemes>$ = $<lexemes>1;
    } 
|   NUMBER
    {
        $<lexeme>$ = $<lexeme>1;
    } 
|   Strings
    {
        global_symbol_table->static_strings.push_back($<string_semantic_val>1);
    }
|   NONE
    {
        $<is_func_ret_type>$ = true;
    } 
|   TRUE
    {
    } 
|   FALSE
    {
    }
|   SELF
    {
        $<lexeme>$ = $<lexeme>1;
        $<is_declarable>$ = false;
        $<is_assignable>$ = false;
    }
|   LEN '(' Atomic_Expression ')'
    {
        
    }

Strings:
    STRING
    {
        $<string_semantic_val>$ = $<string_semantic_val>1;
    }
|   Strings STRING
    {
        $<string_semantic_val>$ = $<string_semantic_val>1 + $<string_semantic_val>2;
    }

Test_List: 
    Test Tests opt_comma
    {     
    }

Trailer: 
    '(' opt_arglist ')' 
    {
        $<trailer_type>$ = '(';
    }
|   '[' Test ']' 
    {
        $<trailer_type>$ = '[';
    }
|   '.' NAME
    {
        $<trailer_type>$ = '.';
        $<lexeme>$ = $<lexeme>2;
    }

Tests:
    %empty
    {
    }
|   Tests ',' Test
    {
    }

Class_Defination: 
    CLASS NAME Class_Defination_Semantic_Actions Base_Class_List 
        {
            current_symbol_table->name = $<lexeme>2;

            //check if class has been declared before
            if (Class_Table.find($<lexeme>2) != Class_Table.end()){
                myerror("Class " + $<lexeme>2 + " has been declared before", $<line_no>1);
            }

            // Updating Data Types
            Class_Attribute* attr = new Class_Attribute;
            attr->line_no = @1.first_line;
            attr->virtual_line_no = $<virtual_line_no>1;
            attr->symbol_table = current_symbol_table;
            Class_Table[$<lexeme>2] = attr;
            if ($<lexeme>4!="")
            {
                attr->add_inheritance($<lexeme>4);
            }

            // Updating the Class symbol Table
            current_symbol_table->class_attributes = attr;
            Class_Sym_Tbl_map[$<lexeme>2] = current_symbol_table;
        }
        ':' Block
    {
        // Transfer from init
        if (current_symbol_table->function_table.find("__init__") == current_symbol_table->function_table.end())
        {
            myerror("__init__ has not been declared in the class", @1.first_line, @6.last_line);
        }

        Symbol_Table * init_symbol_table = current_symbol_table->function_table.find("__init__")->second->func_sym;
        vector<pair<string, Symbol_Table_Entry *>> offset_sorted_self_variables(init_symbol_table->self_variables.begin(), init_symbol_table->self_variables.end());
        sort(offset_sorted_self_variables.begin(), offset_sorted_self_variables.end(), offset_sort);
        for (auto itr : init_symbol_table->self_variables)
        {
            current_symbol_table->add_self_entry(itr.first, itr.second);
        }

        // Setting return type of init function
        auto rtype = current_symbol_table->function_table.find("__init__")->second->return_type;
        if ( !((rtype==pair<bool, string>{false, "None"}) || (rtype==pair<bool, string>{false, $<lexeme>2})) )
        {
            myerror("Incorrect Return Type of __init__ in the class", @1.first_line);
        }
        current_symbol_table->function_table.find("__init__")->second->return_type = {false, $<lexeme>2};

        // Update current_symbol_table
        current_symbol_table = current_symbol_table->parent_symbol_table; 
    }
    
Class_Defination_Semantic_Actions:
    %empty
    {
        if (current_symbol_table->type == CLASS_SYMBOL_TABLE)
        {
            myerror("Class defination inside another class is not allowed", yylineno);
        }
        else if (current_symbol_table->type == FUNCTION_SYMBOL_TABLE)
        {
            myerror("Class defination inside a function is not allowed", yylineno);
        }

        Symbol_Table * class_symbol_table = new Symbol_Table;
        class_symbol_table->parent_symbol_table = current_symbol_table;
        class_symbol_table->type = CLASS_SYMBOL_TABLE;
        current_symbol_table = class_symbol_table;
    }

Argument_List: 
    Arguments opt_comma
    {
        // Base Class List
        $<lexemes>$ = $<lexemes>1;
    }
Arguments:
    Test
    {
    }
|   Arguments ',' Test
    {
    }

%%
