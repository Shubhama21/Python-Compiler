%code requires{
    #include "depend.h"
}

%code top{
    // #define yyparse yyparse_1_declaration
    #include "depend.h"
    int curr_func_index = 0;
    Symbol_Table * dummy_class_symbol_table = new Symbol_Table;
}

%define api.value.type {Semantic_Data}
%define parse.error detailed
%define api.prefix {yy3}

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
        if ($<break_list>2.size()!=0){
            myerror("break statement can not be used outside a loop",  @2.first_line);
        }
        if ($<continue_list>2.size()!=0){
            myerror("break statement can not be used outside a loop",  @2.first_line);
        }       
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
        for(auto &it:current_symbol_table->function_parameters){
            instr_arg* new_arg = new instr_arg;                
            new_arg->type = LOCAL_VARIABLE;
            new_arg->offset = (it.second)->offset;
            new_arg->text = it.first;            
            (it.second)->assigned_temporary = new_arg;
            gen_3ac_command_res("popparam" , new_arg);
        }        
    }

Function_Defination: 
    DEF_NAME Function_Defination_Semantic_Actions Parameters ARROW Return_Type ':' Block
    {
        if ($<break_list>7.size()!=0){
            myerror("break statement can not be used outside a loop",  @7.first_line , @7.last_line);
        }
        if ($<continue_list>7.size()!=0){
            myerror("break statement can not be used outside a loop",  @7.first_line , @7.last_line);
        } 
        if (current_symbol_table->name == "__init__" && current_symbol_table->parent_symbol_table->type==CLASS_SYMBOL_TABLE){
            // instr_arg* ret_arg = current_symbol_table->symbol_table["self"]->assigned_temporary;
            // gen_3ac_command_arg("push" , ret_arg);
            gen_3ac_command("return");
        }
        current_symbol_table = current_symbol_table->parent_symbol_table;
    }
|   DEF_NAME Function_Defination_Semantic_Actions Parameters ':' Block
    {        
        if ($<break_list>5.size()!=0){
            myerror("break statement can not be used outside a loop",  @5.first_line , @5.last_line);
        }
        if ($<continue_list>5.size()!=0){
            myerror("break statement can not be used outside a loop",  @5.first_line , @5.last_line);
        }
        if (current_symbol_table->name == "__init__" && current_symbol_table->parent_symbol_table->type==CLASS_SYMBOL_TABLE){
            instr_arg* ret_arg = current_symbol_table->symbol_table["self"]->assigned_temporary;
            gen_3ac_command_arg("push" , ret_arg);
            gen_3ac_command("return");
        }
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
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1; 
    }
|   compound_stmt
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }

One_Line_Statement: 
    Partial_Line_Statements opt_semi_colon NEWLINE
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;       
    }

Partial_Line_Statements:
    Partial_Line_Statement
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }
|   Partial_Line_Statements ';' Partial_Line_Statement
    {
        merge_vec($<break_list>$ , $<break_list>1 , $<break_list>3);
        merge_vec($<continue_list>$ , $<continue_list>1 , $<continue_list>3);
        // $<break_list>$ = $<break_list>1;
        // $<continue_list>$ = $<continue_list>1;
        // $<break_list>$.push_back($<break_list>3[0]);
        // $<continue_list>$.push_back($<continue_list>3[0]);
    }

Partial_Line_Statement: 
    Expression 
    {
    }
|   flow_stmt 
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }
|   Global_Statement 
    {
    }
|   PRINT '(' Test ')'
    {
        int node_ix = node_count-1;
        pair<bool, string> mydatatype = data_type_nodes[node_ix]->new_data_type;
        gen_3ac_print_call($<res_arg>3 , mydatatype);
    }
Expression: 
    LHS_Variable_Declare ':' Data_Type 
    {
    }
|   LHS_Variable_Declare ':' Data_Type '=' Test
    {
        gen_3ac_mov($<res_arg>5 , $<res_arg>1);
    }
|   LHS_Variable_Assign augassign Test
    {
        instr_arg* temp = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , $<lexeme>2);
        temp = gen_3ac_convert(temp);
        gen_3ac_mov(temp , $<res_arg>1);
    }
|   Test
    {    
    }
|   LHS_Variable_Assign '=' Test
    {
        gen_3ac_mov($<res_arg>3 , $<res_arg>1);   
    }

LHS_Variable_Declare:
    Atomic_Expression
    {
        $<res_arg>$ = $<res_arg>1;
    }

LHS_Variable_Assign:
    Atomic_Expression
    {
        $<res_arg>$ = $<res_arg>1;
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
        $<lexeme>$ = "+";
    }
|   MINUS_EQ
    {
        $<lexeme>$ = "-";
    } 
|   MUL_EQ
    {
        $<lexeme>$ = "*";
    }
|   DIV_EQ
    {
        $<lexeme>$ = "/";
    }
|   PERCENT_EQ
    {
        $<lexeme>$ = "%";
    } 
|   AND_EQ
    {
        $<lexeme>$ = "&";
    }
|   OR_EQ
    {
        $<lexeme>$ = "|";
    }
|   XOR_EQ
    {
        $<lexeme>$ = "^";
    }
|   LEFTSHIFT_EQ
    {
        $<lexeme>$ = "<<";
    }
|   RIGHTSHIFT_EQ
    {
        $<lexeme>$ = ">>";
    }
|   POW_EQ
    {
        $<lexeme>$ = "**";
    }
|   FLOORDIV_EQ
    {
        $<lexeme>$ = "//";
    }

flow_stmt: 
    break_stmt 
    {
        $<break_list>$ = {gen_unconditional_jump()};
    }
|   continue_stmt 
    {
        $<continue_list>$ = {gen_unconditional_jump()};
    }
|   Return_Statement 
    {
        gen_3ac_command("return");
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
        gen_3ac_command_arg("push" , $<res_arg>2);
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
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
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

/* Optional_Else_Statement:
    %empty
    {
    }
|   ELSE ':' Block
    {
    } */

IF_Statement: 
    If_Elif_Statements
    {
        int new_label = gen_new_label();
        backpatch($<finish_list>1 , new_label);
        backpatch($<false_goto>1 , new_label);

        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }
|   If_Elif_Statements ELSE {$<finish_list>1.push_back(gen_unconditional_jump());
                             backpatch($<false_goto>1 , gen_new_label());}
                        ':' Block
    {
        int new_label = gen_new_label();
        backpatch($<finish_list>1 , new_label);

        merge_vec($<break_list>$ , $<break_list>1 , $<break_list>5);
        merge_vec($<continue_list>$ , $<continue_list>1 , $<continue_list>5);
    }

If_Elif_Statements:
    IF Test ':' {assert($<res_arg>2!=NULL); $<false_goto>2=gen_if_false_goto($<res_arg>2);} Block
    {
        $<false_goto>$ = $<false_goto>2;
        $<finish_list>$.clear();

        $<break_list>$ = $<break_list>5;
        $<continue_list>$ = $<continue_list>5;
    }
|   If_Elif_Statements  ELIF {$<finish_list>1.push_back(gen_unconditional_jump());
                             backpatch($<false_goto>1 , gen_new_label());} 
                        Test ':' {  assert($<res_arg>4!=NULL); 
                                    $<false_goto>4=gen_if_false_goto($<res_arg>4);} 
                        Block
    {
        $<finish_list>$ = $<finish_list>1 ;
        $<false_goto>$ = $<false_goto>4;

        merge_vec($<break_list>$ , $<break_list>1 , $<break_list>7);
        merge_vec($<continue_list>$ , $<continue_list>1 , $<continue_list>7);
    }

/* IF_Statement: 
    IF Test ':' Block Elif_Statements Optional_Else_Statement
    {
    }
Elif_Statements:
    %empty
    {
    }
|   Elif_Statements ELIF Test ':' Block
    {
    } */
While_Statement: 
    WHILE Marker Test ':' {assert($<res_arg>3!=NULL); $<false_goto>3=gen_if_false_goto($<res_arg>3);} Block
    {
        gen_unconditional_jump ($<label>2);
        backpatch($<continue_list>6 , $<label>2);

        int next_label = gen_new_label();
        assert($<false_goto>3 != NULL);
        backpatch($<false_goto>3 , next_label);
        backpatch($<break_list>6 , next_label);
    }

For_Statement: 
    FOR Atom IN RANGE '(' Test ')' ':'  {   $<for_it>1 = get_for_var("it"); 
                                            $<for_lim>1 = get_for_var("lim");
                                            for_iter_count++;
                                            gen_3ac_mov(make_constant_arg(0) , $<for_it>1);
                                            gen_3ac_mov($<res_arg>6 , $<for_lim>1);
                                            $<label>1 = gen_new_label();
                                            instr_arg* temp = gen_3ac_relational($<for_it>1 , $<for_lim>1 , "<");
                                            $<false_goto>1 = gen_if_false_goto(temp);
                                            gen_3ac_mov($<for_it>1 , $<res_arg>2);  }
                                    Block
    {
        int continue_label = gen_new_label();
        backpatch($<continue_list>10 , continue_label);

        instr_arg* constant_1 = make_constant_arg(1);           
        instr_arg* temp = gen_3ac_arithmetic ($<for_it>1 , constant_1 , "+");
        gen_3ac_mov (temp , $<for_it>1);
        gen_unconditional_jump($<label>1);

        int end_label = gen_new_label();
        backpatch($<false_goto>1 , end_label);
        backpatch($<break_list>10 , end_label);
    }
|    
    FOR Atom IN RANGE '(' Test ',' Test ')' ':' {   $<for_it>1 = get_for_var("it"); 
                                                    $<for_lim>1 = get_for_var("lim");
                                                    for_iter_count++;
                                                    gen_3ac_mov($<res_arg>6 , $<for_it>1);
                                                    gen_3ac_mov($<res_arg>8 , $<for_lim>1);
                                                    $<label>1 = gen_new_label();
                                                    instr_arg* temp;
                                                    temp = gen_3ac_relational($<for_it>1 , $<for_lim>1 , "<");
                                                    $<false_goto>1 = gen_if_false_goto(temp);
                                                    gen_3ac_mov($<for_it>1 , $<res_arg>2);  }
                                            Block
    {
        int continue_label = gen_new_label();
        backpatch($<continue_list>12 , continue_label);

        instr_arg* constant_1 = make_constant_arg(1);           
        instr_arg* temp = gen_3ac_arithmetic ($<for_it>1 , constant_1 , "+");
        gen_3ac_mov (temp , $<for_it>1);
        gen_unconditional_jump($<label>1);

        int end_label = gen_new_label();
        backpatch($<false_goto>1 , end_label);
        backpatch($<break_list>12 , end_label);
    }

Marker:
    %empty
    {
        $<label>$ = gen_new_label();
    }
Block: 
    One_Line_Statement 
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }
|   NEWLINE INDENT Block_Statements DEDENT
    {
        $<break_list>$ = $<break_list>3;
        $<continue_list>$ = $<continue_list>3;
    }
Block_Statements:
    stmt
    {
        $<break_list>$ = $<break_list>1;
        $<continue_list>$ = $<continue_list>1;
    }
|   Block_Statements stmt
    {
        merge_vec($<break_list>$ , $<break_list>1 , $<break_list>2);
        merge_vec($<continue_list>$ , $<continue_list>1 , $<continue_list>2);
    }

Test: 
    or_Test 
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }

or_Test: 
    and_Test
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   or_Test OR and_Test
    {
        $<data_type>$ = {false, "bool"};
        $<res_arg>$ = gen_3ac_logical($<res_arg>1 , $<res_arg>3 , "or");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
    
and_Test: 
    not_Test
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   and_Test AND not_Test
    {
        $<data_type>$ = {false, "bool"};
        $<res_arg>$ = gen_3ac_logical($<res_arg>1 , $<res_arg>3 , "and");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
    
not_Test: 
    comparison
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   NOT not_Test 
    {
        $<data_type>$ = {false, "bool"};
        $<res_arg>$ = gen_3ac_unary_logical($<res_arg>2 , "not");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }

comparison: 
    expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
        $<extra_arg>$ = $<res_arg>1;
    }
|   comparison Comparison_Operator expr
    {
        $<data_type>$ = {false, "bool"};
        if ($<data_type>1.second=="str")
        {
            $<res_arg>$ = gen_3ac_relational_str($<extra_arg>1 , $<res_arg>3 , $<lexeme>2);
        }
        else
        {
            $<res_arg>$ = gen_3ac_relational($<extra_arg>1 , $<res_arg>3 , $<lexeme>2);
        }
        if ($<res_arg>1!=$<extra_arg>1){
            $<res_arg>$ = gen_3ac_logical($<res_arg>1 , $<res_arg>$ , "and");
        }
        $<extra_arg>$ = $<res_arg>3;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
    
Comparison_Operator: 
    '<'
    {
        $<lexeme>$ = "<";
    }
|   '>'
    {
        $<lexeme>$ = ">";
    }
|   EQ_EQ
    {
        $<lexeme>$ = "==";
    }
|   GT_EQ
    {
        $<lexeme>$ = ">=";
    }
|   LE_EQ
    {
        $<lexeme>$ = "<=";
    }
|   NEQ
    {
        $<lexeme>$ = "!=";
    }
/* |   IS
    {
        $<lexeme>$ = "is";
    }
|   IS NOT
    {
        $<lexeme>$ = "is not";
    } */

expr:
    xor_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   expr '|' xor_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "|");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
xor_expr: 
    and_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   xor_expr '^' and_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "^");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
and_expr: 
    shift_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   and_expr '&' shift_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "&");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
shift_expr: 
    arith_expr 
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   shift_expr LEFTSHIFT arith_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "<<");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
|   shift_expr RIGHTSHIFT arith_expr
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , ">>");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
arith_expr: 
    term
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   arith_expr '+' term
    {
        $<data_type>$ = $<data_type>1;
        // check_and_cast();
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "+");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
|   arith_expr '-' term
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "-");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
term: 
    Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   term '*' Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "*");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   term '/' Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "/");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   term '%' Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "%");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   term FLOORDIV Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "//");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
Factor: 
    power
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   '+' Factor
    {
        $<data_type>$ = $<data_type>2;
        $<res_arg>$ = $<res_arg>2;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   '-' Factor
    {
        $<data_type>$ = $<data_type>2;
        $<res_arg>$ = gen_3ac_unary_op($<res_arg>2, "-");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   '~' Factor
    {
        $<data_type>$ = $<data_type>2;
        $<res_arg>$ = gen_3ac_unary_op($<res_arg>2 , "~");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    } 
power: 
    Atomic_Expression 
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>1;
    }
|   Atomic_Expression DOUBLE_STAR Factor
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = gen_3ac_arithmetic($<res_arg>1 , $<res_arg>3 , "**");

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }

Atomic_Expression:
    Atom
    {
        // Data Type
        $<data_type>$ = $<data_type>1;
        $<is_func>$ = $<is_func>1;
        $<function_table_entry>$ = $<function_table_entry>1;
        $<is_class>$ = $<is_class>1;

        $<res_arg>$ = $<res_arg>1;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }
|   Atomic_Expression Trailer
    {
        // Is it a function
        switch ($<trailer_type>2)
        {
            case '(':
            {
                Function_Attribute * fptr;

                // Constructor
                if ($<is_class>1)
                {
                    fptr = Class_Sym_Tbl_map[$<data_type>1.second]->is_present_function("__init__");
                }
                else
                {
                    fptr = $<function_table_entry>1;
                    // cout<<"Got function table entry\n";
                }

                int true_narg = fptr->arg_type.size();
                int passed_narg = $<data_type_vec>2.size();
                int i;

                // CLASS CALLING
                if ($<is_class>1)
                {
                    // Constructor
                    if ($<is_func>1==false)
                    {
                        // No need to match first
                        int alloc_size = Class_Sym_Tbl_map[$<data_type>1.second]->current_offset;
                        $<res_arg>$ = gen_3ac_malloc_call(make_constant_arg(alloc_size));
                        gen_3ac_function_call(fptr->func_pointer_arg , $<res_arg>$, $<res_arg_list>2 , $<res_arg_list>2.size()+1);
                    }
                    // Class calling function
                    else
                    {
                        // Match All but first on type
                        $<res_arg>$ = gen_3ac_function_call(fptr->func_pointer_arg , $<res_arg_list>2 , $<res_arg_list>2.size());
                    }
                }
                // OBJECT / NORMAL CALLING
                else
                {
                    // Object Calling its or it's parent's method - implicit self
                    if (fptr->func_sym->parent_symbol_table->type!=GLOBAL_SYMBOL_TABLE)
                    {                       
                        $<res_arg>$ = gen_3ac_function_call(fptr->func_pointer_arg , $<res_arg>1, $<res_arg_list>2 , $<res_arg_list>2.size()+1);
                    }
                    // Normal Function
                    else
                    {
                        $<res_arg>$ = gen_3ac_function_call(fptr->func_pointer_arg , $<res_arg_list>2 , $<res_arg_list>2.size());
                    }
                }
                // Data Type
                $<data_type>$ = fptr->return_type;
                if ($<is_class>1 && $<is_func>1==false)
                {
                    $<data_type>$ = $<data_type>1;
                }
                $<is_class>$ = false;
                $<is_func>$ = false;

                // Type Cast
                $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
                break;
            }
            case '[':
            {
                // Data Type
                $<data_type>$ = {false, $<data_type>1.second};
                $<is_func>$ = false;
                $<is_class>$ = false;

                //3ac operations
                int data_size = get_param_size({0,$<data_type>1.second});
                instr_arg* temp = gen_3ac_arithmetic($<res_arg>2 , make_constant_arg(data_size) , "*");
                temp = gen_3ac_arithmetic($<res_arg>1 , temp , "+");
                temp = gen_3ac_arithmetic(temp , make_constant_arg(8) , "+");
                $<res_arg>$ = get_dereference(temp);

                // Type Cast
                $<res_arg>$ = gen_3ac_convert($<res_arg>$); 
                break;
            }
            case '.':
            {
                Symbol_Table * my_scope = Class_Sym_Tbl_map[$<data_type>1.second];
                
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
                        $<is_class>$ = false;

                        // Symbol_Table * prev_scope = Class_Sym_Tbl_map[$<data_type>1.second];
                        assert(my_scope!=NULL);
                        int internal_offset = my_scope->get_offset($<lexeme>2).second;                
                        instr_arg* temp = gen_3ac_arithmetic($<res_arg>1 , make_constant_arg(internal_offset), "+");
                        $<res_arg>$ = get_dereference(temp);

                        // Type Cast
                        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
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
                        $<is_class>$ = false;

                        // Type Cast
                        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
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
                        $<res_arg>$ = $<res_arg>1;
                    }
                }

                break;
            }
        }
    }

Atom:
    '(' Test ')' 
    {
        $<data_type>$ = $<data_type>1;
        $<res_arg>$ = $<res_arg>2;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);   
    }
|   '[' ']' 
    {
    }
|   '[' Test_List ']' 
    {
        $<data_type>$ = {true, $<data_type>2.second};
        
        $<res_arg_list>$ = $<res_arg_list>2;
        int num_elements = $<res_arg_list>$.size();
        int list_element_size = get_param_size($<data_type>2);
        
        $<res_arg>$ = gen_3ac_malloc_call(make_constant_arg(list_element_size*num_elements+8));
        gen_3ac_mov_to_reference(make_constant_arg(num_elements) , $<res_arg>$);

        instr_arg* temp = gen_3ac_arithmetic($<res_arg>$ , make_constant_arg(8) , "+");
        instr_arg* offset_arg = make_constant_arg(list_element_size);
        for (int i=0 ; i<num_elements ; i++){
            gen_3ac_mov_to_reference($<res_arg_list>$[i] , temp);
            if (i!=num_elements-1) temp = gen_3ac_arithmetic(temp , offset_arg , "+");
        }

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);   
    }
|   NAME
    {
        Symbol_Table_Entry* entry = current_symbol_table->is_present_symbol($<lexeme>1);        
        if (entry!=NULL){
            
            if (entry->is_func_param == true){
                assert(entry->assigned_temporary!=NULL);
                $<res_arg>$ = entry->assigned_temporary;
            }
            else{
                $<res_arg>$ = new instr_arg;                
                $<res_arg>$->text = $<lexeme>1;
                pair<bool,int>off = current_symbol_table->get_offset($<lexeme>1);
                if (off.first == 1) $<res_arg>$->type = GLOBAL_VARIABLE;
                else $<res_arg>$->type = LOCAL_VARIABLE;
                $<res_arg>$->offset = off.second;
            }
        }
        
        // Checking in current symbol table
        auto ptr = current_symbol_table->is_present_symbol($<lexeme>1);
        if (ptr!=NULL)
        {
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
                    $<is_class>$ = true;
                    $<data_type>$ = {false, $<lexeme>1};
                    $<is_func>$ = false;
                }
            }
        }

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
|   NUMBER
    {
        $<res_arg>$ = new instr_arg;
        $<res_arg>$->type = CONSTANT;
        $<res_arg>$->text = $<lexeme>1;
        $<data_type>$ = $<data_type>1;
        if ($<data_type>$.second == "int"){
            $<res_arg>$->int_val = stoi($<lexeme>1);
        }
        else if ($<data_type>$.second == "float"){
            $<res_arg>$->float_val = stof($<lexeme>1);
        } 
        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);   
    } 
|   Strings
    {
        $<data_type>$ = {0, "str"};
        $<res_arg>$ = make_string_arg($<string_semantic_val>1);
        global_symbol_table->string_args.push_back($<res_arg>$);

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);   
    }
|   NONE
    {
        $<res_arg>$ = make_constant_arg(0);
    } 
|   TRUE
    {
        $<res_arg>$ = new instr_arg;
        $<res_arg>$->type = CONSTANT;
        $<res_arg>$->text = "1";
        $<data_type>$ = {0,"bool"};        
        $<res_arg>$->int_val = 1; 

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);          
    } 
|   FALSE
    {
        $<res_arg>$ = new instr_arg;
        $<res_arg>$->type = CONSTANT;
        $<res_arg>$->text = "0";
        $<data_type>$ = {0,"bool"};        
        $<res_arg>$->int_val = 0;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);   
    }
|   SELF
    {
        Symbol_Table_Entry* entry = current_symbol_table->is_present_symbol($<lexeme>1);
        if (entry != NULL){
            if (entry->is_func_param == true){
                assert(entry->assigned_temporary!=NULL);
                $<res_arg>$ = entry->assigned_temporary;
            }
            else{
                $<res_arg>$ = new instr_arg;
                $<res_arg>$->type = LOCAL_VARIABLE;
                // $<res_arg>$->offset = offset;
                $<res_arg>$->text = $<lexeme>1;
            }
        }
        // Data Type
        if (!(current_symbol_table->type==FUNCTION_SYMBOL_TABLE && current_symbol_table->parent_symbol_table->type==CLASS_SYMBOL_TABLE))
        {
            myerror("Invalid place to use SELF keyword, current symbol table is " + current_symbol_table->name, @1.first_line);
        }
        $<is_class>$ = false;
        $<is_func>$ = false;
        $<data_type>$ = {false, current_symbol_table->parent_symbol_table->name};

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
|   LEN '(' Atomic_Expression ')'
    {
        instr_arg* temp = make_new_temporary();
        gen_3ac_mov($<res_arg>3 , temp);
        $<res_arg>$ = make_new_temporary();
        gen_3ac_mov_from_reference(temp , $<res_arg>$); 

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
        $<data_type>$ = {false, "int"};
    }

Strings:
    STRING
    {
        $<data_type>$ = {false, "str"};
        $<string_semantic_val>$ = $<string_semantic_val>1;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }
|   Strings STRING
    {
        $<data_type>$ = {false, "str"};
        $<string_semantic_val>$ = $<string_semantic_val>1 + $<string_semantic_val>2;

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);
    }

Test_List: 
    Tests opt_comma
    {
        $<res_arg_list>$ = $<res_arg_list>1;
        $<data_type>$ = $<data_type>1;   

        // Type Cast
        $<res_arg>$ = gen_3ac_convert($<res_arg>$);  
    }

Trailer: 
    '(' opt_arglist ')' 
    {
        $<res_arg_list>$ = $<res_arg_list>2;
        $<trailer_type>$ = '(';
        // Trailer Type
        $<trailer_type>$ = '(';
        // Data Type
        $<data_type_vec>$ = $<data_type_vec>2;
    }
|   '[' Test ']' 
    {
        $<res_arg>$ = $<res_arg>2;
        $<trailer_type>$ = '[';
    }
|   '.' NAME
    {
        $<trailer_type>$ = '.';
        $<lexeme>$ = $<lexeme>2;
    }

Tests:
    Test
    {
        $<res_arg_list>$ = {$<res_arg>1};
        // Data Type
        $<data_type>$ = $<data_type>1;
    }
|   Tests ',' Test
    {
        $<res_arg_list>$ = $<res_arg_list>1;
        $<res_arg_list>$.push_back($<res_arg>3);
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
        $<res_arg_list>$.clear();
        $<data_type_vec>$.clear();
    }
|   Argument_List
    {
        $<res_arg_list>$ = $<res_arg_list>1;
        $<data_type_vec>$ = $<data_type_vec>1;
    }

Argument_List: 
    Arguments opt_comma
    {
        $<res_arg_list>$ = $<res_arg_list>1;
        // Data Type
        $<data_type_vec>$ = $<data_type_vec>1;
    }
Arguments:
    Test
    {
        $<res_arg_list>$ = {$<res_arg>1};
        $<data_type_vec>$.clear();
        $<data_type_vec>$.push_back($<data_type>1);
    }
|   Arguments ',' Test
    {
        $<res_arg_list>$ = $<res_arg_list>1;
        $<res_arg_list>$.push_back($<res_arg>3);
        // Data Type
        $<data_type_vec>1.push_back($<data_type>3);
        $<data_type_vec>$ = $<data_type_vec>1;
    }


%%
