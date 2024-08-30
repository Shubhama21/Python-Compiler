%code requires{
    #include "depend.h"
}

%code top{
    // #define yyparse yyparse_1_declaration
    #include "depend.h"

    
}

%define api.value.type {Semantic_Data}
%define parse.error detailed
%define api.prefix {yy2}

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
    }
|   '(' opt_comma ')'
    {
    }
|   '(' Names opt_comma ')'
    {
    }


Function_Defination_Semantic_Actions:
    %empty
    {
    }

Function_Defination: 
    DEF_NAME Function_Defination_Semantic_Actions Parameters ARROW Return_Type ':' Block
    {
        // Updating the current_symbol_table
        current_symbol_table = current_symbol_table->parent_symbol_table;
    }
|   DEF_NAME Function_Defination_Semantic_Actions Parameters ':' Block
    {
        // Updating the current_symbol_table
        current_symbol_table = current_symbol_table->parent_symbol_table;
    }

DEF_NAME:
    DEF NAME
    {
        // Updating the current_symbol_table
        Function_Attribute * fptr = current_symbol_table->is_present_function($<lexeme>2);
        current_symbol_table = fptr->func_sym;
    }

Parameters: 
    '(' ')'
    {
    }
|   '(' Defination_Parameter_List ')'
    {
    }

Defination_Parameter_List:
    SELF
    {
    }
|   Parameter
    {
    }
|   Defination_Parameter_List ',' Parameter
    {
    }

Parameter:
    NAME ':' Data_Type   
    {
        auto ptr = current_symbol_table->is_present_symbol($<lexeme>1);
        ptr->is_declared = true;
    }
|   NAME ':' Data_Type 
        {
            auto ptr = current_symbol_table->is_present_symbol($<lexeme>1);
            ptr->is_declared = true;
        }
        '=' Test
    {
        auto ptr = current_symbol_table->is_present_symbol($<lexeme>1);
        type_check_func(ptr->data_type, $<node_ix>6, @1.first_line, @6.last_line);
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
        check_dt(PRIM_DT, {$<data_type>3}, @1.first_line, @4.last_line);
    }
Expression: 
    LHS_Variable_Declare ':' Data_Type 
    {
    }
|   LHS_Variable_Declare ':' Data_Type '=' Test
    {
        type_check(ASSIGNMENT, $<node_ix>1, $<node_ix>5, @1.first_line, @5.last_line);
    }
|   LHS_Variable_Assign augassign Test
    {
        if ($<aug_type>2==POW_EQ)
        {
            check_dt({INT_DT, BOOL_DT}, {$<data_type>3}, @3.first_line, @3.last_line);
            $<aug_type>2 = GEN_ARITHMETIC;
        }
        auto rhs_dtype = type_check($<aug_type>2, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        int rhs_node_ix = new_data_type_node(rhs_dtype);
        $<data_type>$ = type_check(ASSIGNMENT, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
    }
|   Test
    {    
    }
|   LHS_Variable_Assign '=' Test
    {
        type_check(ASSIGNMENT, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
    }

LHS_Variable_Declare:
    Atomic_Expression
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }

LHS_Variable_Assign:
    Atomic_Expression
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }

Return_Type:
    NONE
    {
    }
|   Data_Type
    {
    }

Data_Type:
    NAME
    {
    }
|   NAME '[' NAME ']'
    {
    }
|   Primitive_Type
    {
    }
|   NAME '[' Primitive_Type ']'
    {
    }

Primitive_Type:
    INT
|   FLOAT
|   BOOL
|   STR

augassign: 
    PLUS_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
    }
|   MINUS_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
    } 
|   MUL_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
    }
|   DIV_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
    }
|   PERCENT_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
    } 
|   AND_EQ
    {
        $<aug_type>$ = INT_ARITHMETIC;
    }
|   OR_EQ
    {
        $<aug_type>$ = INT_ARITHMETIC;
    }
|   XOR_EQ
    {
        $<aug_type>$ = INT_ARITHMETIC;
    }
|   LEFTSHIFT_EQ
    {
        $<aug_type>$ = INT_ARITHMETIC;
    }
|   RIGHTSHIFT_EQ
    {
        $<aug_type>$ = INT_ARITHMETIC;
    }
|   POW_EQ
    {
        $<aug_type>$ = POW_EQ;
    }
|   FLOORDIV_EQ
    {
        $<aug_type>$ = GEN_ARITHMETIC;
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
        auto rtype = current_symbol_table->function_attributes->return_type;
        if (rtype!=pair<bool, string>{false, "None"})
        {
            myerror("Function is returning nothing although its return type is not None", @1.first_line);
        }
    }
|   RETURN Test
    {
        auto rtype = current_symbol_table->function_attributes->return_type;
        type_check_func(rtype, $<node_ix>2, @1.first_line, @2.last_line);
    }

Global_Statement: 
    GLOBAL Names
    {
    }

Names:
    NAME
    {
    }
|   Names ',' NAME
    {
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

IF_Statement: 
    If_Elif_Statements
    {
    }
|   If_Elif_Statements ELSE {;} ':' Block
    {
    }

If_Elif_Statements:
    IF Test ':' {;} Block
    {
        $<data_type>$ = type_check(BOOL_SINGLE, $<node_ix>2, -1, @2.first_line, @2.last_line);
    }
|   If_Elif_Statements  ELIF {;} Test ':' {;} Block
    {
        $<data_type>$ = type_check(BOOL_SINGLE, $<node_ix>4, -1, @4.first_line, @4.last_line);
    }

While_Statement: 
    WHILE Marker Test ':' {;} Block
    {
        $<data_type>$ = type_check(BOOL_SINGLE, $<node_ix>3, -1, @3.first_line, @3.last_line);
    }

For_Statement: 
    FOR Atom IN RANGE '(' Test ')' ':'  {;} Block
    {
        check_dt({INT_DT}, {$<data_type>2, $<data_type>6}, @2.first_line, @6.last_line);
    }
|   FOR Atom IN RANGE '(' Test ',' Test ')' ':' {;} Block
    {
        check_dt({INT_DT}, {$<data_type>2, $<data_type>6, $<data_type>8}, @2.first_line, @8.last_line);
    }

Marker:
    %empty
    {
    }
Block: 
    One_Line_Statement 
    {
    }
|   NEWLINE INDENT Block_Statements DEDENT
    {
    }
Block_Statements:
    stmt
    {
    }
|   Block_Statements stmt
    {
    }

Test: 
    or_Test 
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }

or_Test: 
    and_Test
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   or_Test OR and_Test
    {
        $<data_type>$ = type_check(BOOL_DOUBLE, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
    
and_Test: 
    not_Test
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   and_Test AND not_Test
    {
        $<data_type>$ = type_check(BOOL_DOUBLE, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
    
not_Test: 
    comparison
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   NOT not_Test 
    {
        $<data_type>$ = type_check(BOOL_SINGLE, $<node_ix>2, -1, @1.first_line, @2.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }

comparison: 
    expr
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   comparison Comparison_Operator expr
    {
        if (!($<data_type>1==$<data_type>3 && $<data_type>3==STR_DT))
        {
            type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        }
        $<data_type>$ = BOOL_DT;
        $<node_ix>$ = new_data_type_node($<data_type>$);
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

expr:
    xor_expr
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   expr '|' xor_expr
    {
        $<data_type>$ = type_check(INT_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
xor_expr: 
    and_expr
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   xor_expr '^' and_expr
    {
        $<data_type>$ = type_check(INT_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
and_expr: 
    shift_expr
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   and_expr '&' shift_expr
    {
        $<data_type>$ = type_check(INT_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
shift_expr: 
    arith_expr 
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   shift_expr LEFTSHIFT arith_expr
    {
        $<data_type>$ = type_check(INT_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   shift_expr RIGHTSHIFT arith_expr
    {
        $<data_type>$ = type_check(INT_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
arith_expr: 
    term
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   arith_expr '+' term
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   arith_expr '-' term
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
term: 
    Factor
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   term '*' Factor
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   term '/' Factor
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   term '%' Factor
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   term FLOORDIV Factor
    {
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
Factor: 
    power
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   '+' Factor
    {
        $<data_type>$ = type_check(GEN_SINGLE_ARITHMETIC, $<node_ix>2, -1, @2.first_line, @2.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   '-' Factor
    {
        $<data_type>$ = type_check(GEN_SINGLE_ARITHMETIC, $<node_ix>2, -1, @2.first_line, @2.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   '~' Factor
    {
        $<data_type>$ = type_check(INT_SINGLE_ARITHMETIC, $<node_ix>2, -1, @2.first_line, @2.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    } 
power: 
    Atomic_Expression 
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = $<node_ix>1;
    }
|   Atomic_Expression DOUBLE_STAR Factor
    {
        check_dt({INT_DT, BOOL_DT}, {$<data_type>3}, @3.first_line, @3.last_line);
        $<data_type>$ = type_check(GEN_ARITHMETIC, $<node_ix>1, $<node_ix>3, @1.first_line, @3.last_line);
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }

Atomic_Expression:
    Atom
    {
        $<data_type>$ = $<data_type>1;
        $<is_func>$ = $<is_func>1;
        $<function_table_entry>$ = $<function_table_entry>1;
        $<is_class>$ = $<is_class>1;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   Atomic_Expression Trailer
    {
        // Is it a function
        switch ($<trailer_type>2)
        {
            case '(':
            {
                if ($<is_func>1==false && $<is_class>1==false)
                {
                    myerror("Following is not a function", @2.first_line);
                }

                Function_Attribute * fptr;

                // Constructor
                if ($<is_class>1)
                {
                    fptr = Class_Sym_Tbl_map[$<data_type>1.second]->is_present_function("__init__");
                }
                else
                {
                    fptr = $<function_table_entry>1;
                }

                int true_narg = fptr->arg_type.size();
                int passed_narg = $<node_ix_vec>2.size();
                int i;

                // CLASS CALLING
                if ($<is_class>1)
                {
                    // Constructor
                    if ($<is_func>1==false)
                    {
                        // No need to match first
                        // Number
                        if (true_narg!=passed_narg+1)
                        {
                            myerror("Wrong Number of Arguments passed to function", @2.first_line);
                        }
                        // Rest Type
                        for (int i=1;i<true_narg;i++)
                        {
                            type_check_func(fptr->arg_type[i], $<node_ix_vec>2[i-1], @2.first_line, @2.last_line);
                        }
                    }
                    // Class calling function
                    else
                    {
                        // Match All but first on type
                        // Number
                        if (true_narg!=passed_narg)
                        {
                            myerror("Wrong Number of Arguments passed to function", @2.first_line);
                        }
                        // Self Type
                        if (Class_Table[ data_type_nodes[$<node_ix_vec>2[0]]->init_data_type.second ]->is_parent(fptr->arg_type[0].second)==false)
                        {
                            myerror("Type Error in Self Argument passed to function", @2.first_line);
                        }
                        // Rest Type
                        for (int i=1;i<true_narg;i++)
                        {
                            type_check_func(fptr->arg_type[i], $<node_ix_vec>2[i], @2.first_line, @2.last_line);
                        }
                    }
                }
                // OBJECT / NORMAL CALLING
                else
                {
                    // Object Calling its or it's parent's method - implicit self
                    if (fptr->func_sym->parent_symbol_table->type!=GLOBAL_SYMBOL_TABLE)
                    {
                        // Number
                        if (true_narg!=passed_narg+1)
                        {
                            myerror("Wrong Number of Arguments passed to function", @2.first_line);
                        }
                        // Self Type
                        if (Class_Table[ $<data_type>1.second ]->is_parent(fptr->arg_type[0].second)==false)
                        {
                            myerror("Type Error in Self Argument passed to function", @2.first_line);
                        }
                        // Rest Type
                        for (int i=1;i<true_narg;i++)
                        {
                            type_check_func(fptr->arg_type[i], $<node_ix_vec>2[i-1], @2.first_line, @2.last_line);
                        }
                    }
                    // Normal Function
                    else
                    {
                        // Number
                        if (true_narg!=passed_narg)
                        {
                            myerror("Wrong Number of Arguments passed to function", @2.first_line);
                        }
                        // Rest Type
                        for (int i=0;i<true_narg;i++)
                        {
                            type_check_func(fptr->arg_type[i], $<node_ix_vec>2[i], @2.first_line, @2.last_line);
                        }
                    }
                }

                // Data Type
                $<data_type>$ = fptr->return_type;
                $<node_ix>$ = new_data_type_node($<data_type>$);
                if ($<is_class>1 && $<is_func>1==false)
                {
                    $<data_type>$ = $<data_type>1;
                }
                $<is_class>$ = false;
                $<is_func>$ = false;
                break;
            }
            case '[':
            {
                // Check is_list
                if ($<is_class>1 || $<is_func>1==true || $<data_type>1.first==false)
                {
                    myerror("A non-list type of entry is being indexed which is invalid", @1.last_line);
                }

                // Data Type
                $<data_type>$ = {false, $<data_type>1.second};
                $<node_ix>$ = new_data_type_node($<data_type>$);
                $<is_func>$ = false;
                $<is_class>$ = false;
                break;
            }
            case '.':
            {
                Symbol_Table * my_scope = Class_Sym_Tbl_map[$<data_type>1.second];
                
                // Class Name can't be an attribute
                if (Class_Sym_Tbl_map.find($<lexeme>2)!= Class_Sym_Tbl_map.end())
                {
                    myerror("Class Name can not be an attribute", @2.first_line);
                }

                // Data Type
                if ($<is_func>1==true || $<data_type>1.first==true || my_scope==NULL)
                {
                    myerror("The following has no attributes", @1.last_line);
                }

                bool found = false;

                // Is Present Self Variable
                if ($<is_class>1==false)
                {
                    auto ptr = my_scope->is_present_self_variable($<lexeme>2);
                    if (ptr!=NULL)
                    {
                        found = true;
                        $<is_func>$ = false;
                        $<data_type>$ = ptr->data_type;
                        $<node_ix>$ = new_data_type_node($<data_type>$);
                        $<is_class>$ = false;
                    }
                }
                
                // Is Present Symbol
                if (found==false)
                {
                    auto ptr = my_scope->is_present_symbol($<lexeme>2);
                    if (ptr!=NULL)
                    {
                        found = true;
                        $<is_func>$ = false;
                        $<data_type>$ = ptr->data_type;
                        $<node_ix>$ = new_data_type_node($<data_type>$);
                        $<is_class>$ = false;
                    }
                }

                // Is Present Function
                if (found==false)
                {
                    found_in_global = false;
                    auto fptr = my_scope->is_present_function($<lexeme>2);
                    if (fptr!=NULL && !found_in_global)
                    {
                        found = true;
                        $<is_func>$ = true;
                        $<function_table_entry>$ = fptr;
                        $<is_class>$ = $<is_class>1;
                        $<data_type>$ = $<data_type>1;
                    }
                }

                // Error
                if (found==false)
                {
                    myerror("The following does not have the specified attribute", @1.last_line);
                }
                break;
            }
        }
    }

Atom:
    '(' Test ')' 
    {
        $<data_type>$ = $<data_type>2;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   '[' ']' 
    {
        myerror("Empty List is invalid", @1.first_line);
    }
|   '[' Test_List ']' 
    {
        if ($<data_type>2.first == true)
        {
            myerror("List of lists are not allowed\n", $<line_no>1);
        }
        $<data_type>$ = {true, $<data_type>2.second};
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   NAME
    {
        // Checking in current symbol table
        auto ptr = current_symbol_table->is_present_symbol($<lexeme>1);
        if (ptr!=NULL)
        {
            if (ptr->min_virtual_line_no > $<virtual_line_no>1)
            {
                myerror("Variable used before declaration", $<virtual_line_no>1);
            }
            else if (ptr->min_virtual_line_no == $<virtual_line_no>1 && ptr->is_declared==true)
            {
                myerror("Variable used before declaration", $<virtual_line_no>1);
            }
            if (ptr->is_declared==false)
            {
                ptr->is_declared=true;
            }
            // Data Type
            $<data_type>$ = ptr->data_type;
            $<is_class>$ = false;
            $<is_func>$ = false;
        }
        // Checking in current function table
        else
        {
            auto fptr = global_symbol_table->is_present_function($<lexeme>1);
            if (fptr!=NULL)
            {
                if (fptr->min_virtual_line_no >= $<virtual_line_no>1)
                {
                    myerror("Function used before declaration", $<virtual_line_no>1);
                }   
                $<is_func>$ = true;
                $<function_table_entry>$ = fptr;
                $<is_class>$ = false;
            }
            else
            {
                // Checking in Class Table
                auto cptr_entry = Class_Table.find($<lexeme>1);
                if (cptr_entry!=Class_Table.end())
                {
                    auto cptr = cptr_entry->second;
                    if (cptr->virtual_line_no >= $<virtual_line_no>1)
                    {
                        myerror("Class used before declaration", $<virtual_line_no>1);
                    }
                    $<is_class>$ = true;
                    $<data_type>$ = {false, $<lexeme>1};
                    $<is_func>$ = false;
                }
                else
                {
                    myerror("Name used before declaration", $<virtual_line_no>1);
                }
            }
        }
        $<node_ix>$ = new_data_type_node($<data_type>$);
    } 
|   NUMBER
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    } 
|   Strings
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   NONE
    {
    } 
|   TRUE
    {
        $<data_type>$ = {false, "bool"};
        $<node_ix>$ = new_data_type_node($<data_type>$);
    } 
|   FALSE
    {
        $<data_type>$ = {false, "bool"};
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   SELF
    {
        if (!(current_symbol_table->type==FUNCTION_SYMBOL_TABLE && current_symbol_table->parent_symbol_table->type==CLASS_SYMBOL_TABLE))
        {
            myerror("Invalid place to use SELF keyword", @1.first_line);
        }
        $<data_type>$ = {false, current_symbol_table->parent_symbol_table->name};
        $<is_class>$ = false;
        $<is_func>$ = false;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   LEN '(' Atomic_Expression ')'
    {
        if ($<data_type>3.first != true)
        {
            // cout<<$<data_type>3.first<<" "<<$<data_type>3.second<<endl;
            myerror("Argument to len must be of type list", @1.first_line);
        }
        $<data_type>$ = {false, "int"};
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }

Strings:
    STRING
    {   
        $<data_type>$ = {false, "str"};
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }
|   Strings STRING
    {
        $<data_type>$ = $<data_type>1;
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }

Test_List: 
    Tests opt_comma
    {
        // Data Type
        $<data_type>$ = $<data_type>1; 
        $<node_ix>$ = new_data_type_node($<data_type>$);
    }

Trailer: 
    '(' opt_arglist ')' 
    {
        // Trailer Type
        $<trailer_type>$ = '(';
        // Data Type
        $<node_ix_vec>$ = $<node_ix_vec>2;
    }
|   '[' Test ']' 
    {
        // Trailer Type
        $<trailer_type>$ = '[';
        check_dt({INT_DT}, {$<data_type>2}, @1.first_line, @3.last_line);
    }
|   '.' NAME
    {
        // Trailer Type
        $<trailer_type>$ = '.';
        $<lexeme>$ = $<lexeme>2;
    }

Tests:
    Test
    {
        // Data Type
        $<data_type>$ = $<data_type>1; 
    }
|   Tests ',' Test
    {
        // Data Type
        if ($<data_type>1 != $<data_type>3)
        {
            myerror("Non-homogenous List", @2.first_line);
        }
        $<data_type>$ = $<data_type>1;
    }

Class_Defination: 
    CLASS NAME Class_Defination_Semantic_Actions Base_Class_List ':'
        {
            current_symbol_table = Class_Table[$<lexeme>2]->symbol_table;
        }
        Block
    {
        current_symbol_table = global_symbol_table;
    }
    
Class_Defination_Semantic_Actions:
    %empty
    {
    }

opt_arglist:
    %empty
    {
        // Checking Function Args
        $<node_ix_vec>$.clear();
    }
|   Argument_List
    {
        // Checking Function Args
        $<node_ix_vec>$ = $<node_ix_vec>1;
    }

Argument_List: 
    Arguments opt_comma
    {
        // Data Type
        $<node_ix_vec>$ = $<node_ix_vec>1;
    }
Arguments:
    Test
    {
        // Data Type
        $<node_ix_vec>$.clear();
        $<node_ix_vec>$.push_back($<node_ix>1);
    }
|   Arguments ',' Test
    {
        // Data Type
        $<node_ix_vec>1.push_back($<node_ix>3);
        $<node_ix_vec>$ = $<node_ix_vec>1;
    }

%%
