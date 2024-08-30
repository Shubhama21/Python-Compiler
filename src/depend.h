#pragma once

#include <iostream>
#include <stdlib.h>
#include <vector>
#include <string>
#include <fstream>
#include <map>
#include <set>
#include <algorithm>
#include <stack>
#include <assert.h>

#define INT_DT      (pair<bool, string>{false, "int"})
#define FLOAT_DT    (pair<bool, string>{false, "float"})
#define BOOL_DT     (pair<bool, string>{false, "bool"})
#define STR_DT      (pair<bool, string>{false, "str"})
#define PRIM_DT      {STR_DT, INT_DT, FLOAT_DT, BOOL_DT}

using namespace std;

// Error Functions
void myerror(string s, int line_no);
void myerror(string s, int first_line_no, int last_line_no);
void yyerror(const char * s);
extern void (*yy1error)(const char * s);
extern void (*yy2error)(const char * s);
extern void (*yy3error)(const char * s);

// YY-Functions and Attributes
extern int yylineno;

// Different Parses
extern int yy1parse();
extern int yy2parse();
extern int yy3parse();

// Different lexers
extern "C" int yylex();
extern int (*yy1lex)();
extern int (*yy2lex)();
extern int (*yy3lex)();

// Class Declarations
class Semantic_Data;
class Symbol_Table_Entry;
class Symbol_Table;
class Function_Attribute;
class Class_Attribute;
class IR_instruction;
class instr_arg;
class Data_Type_Node;

// Symbol Table Enums
enum {
    GLOBAL_SYMBOL_TABLE,
    FUNCTION_SYMBOL_TABLE,
    CLASS_SYMBOL_TABLE
};

// Type Checking
enum {
    GEN_ARITHMETIC,
    INT_ARITHMETIC,
    INT_SINGLE_ARITHMETIC,
    GEN_SINGLE_ARITHMETIC,
    BOOL_DOUBLE,
    BOOL_SINGLE,
    ASSIGNMENT
};

extern void check_dt(vector<pair<bool, string>> allowed_dtypes, vector<pair<bool, string>> ip_dtypes, int first_line, int last_line);
extern void up_cast_numeric(int node_ix1, int node_ix2);
extern pair<bool, string> type_check(int operation, int node_ix1, int node_ix2, int first_line, int last_line);
extern void type_check_func(pair<bool, string> func_dtype, int node_ix, int first_line, int last_line);

// IR ENUMS
enum {
    TEMPORARY_VARIABLE,
    LOCAL_VARIABLE,
    CONSTANT,
    TEMPORARY_POINTER,
    GLOBAL_VARIABLE,
    IMMEDIATE_POINTER,
    STRING_ARG
};

enum {
    RES_ARG1_OP_ARG2,
    RES_ARG1_OP_ARG2_RELATIONAL,
    RES_OP_ARG1,
    MOV,
    MOV_TO_REFERENCE,
    MOV_FROM_REFERENCE,
    LABEL,
    ifFalse_Goto,
    Goto,
    COMMAND_ARG1,
    COMMAND,
    COMMAND_RES,
    COMMAND_ARG1_ARG2,
    CONVERT_ARG
};

// Global Variables across parses
extern int line_pad_count;
extern Symbol_Table * current_symbol_table;
extern Symbol_Table * global_symbol_table;
extern Class_Attribute * Primitive_Attribute;
extern map<string, Class_Attribute *> Class_Table;
extern Symbol_Table * global_symbol_table;
extern vector<Symbol_Table*> Function_Sym_Tbl_list;
extern map<string, Symbol_Table*> Class_Sym_Tbl_map;
extern vector<IR_instruction*> final_3ac;
extern int get_param_size(pair<bool,string> s);

// 3AC Functions
extern instr_arg* make_new_temporary();
extern instr_arg* gen_3ac_arithmetic (instr_arg* arg1 , instr_arg* arg2 , string op);
extern instr_arg* gen_3ac_unary_op (instr_arg* arg1 , string op );
extern instr_arg* gen_3ac_relational (instr_arg* arg1 , instr_arg* arg2 , string op);
extern instr_arg* gen_3ac_relational_str (instr_arg* arg1 , instr_arg* arg2 , string op);
extern instr_arg* gen_3ac_logical (instr_arg* arg1 , instr_arg* arg2 , string op);
extern instr_arg* gen_3ac_unary_logical (instr_arg* arg1 , string op);
extern void gen_3ac_mov (instr_arg* arg1 , instr_arg* res);
extern void gen_3ac_mov_to_reference (instr_arg* arg1 , instr_arg* res);
extern void gen_3ac_mov_from_reference (instr_arg* arg1 , instr_arg* res);
extern int gen_new_label();
extern IR_instruction* gen_if_false_goto(instr_arg* arg);
extern IR_instruction* gen_unconditional_jump ();
extern IR_instruction* gen_unconditional_jump (int label_no);
extern void backpatch (vector<IR_instruction*> &instr_list , int label_no);
extern void backpatch (IR_instruction* instr , int label_no);
extern instr_arg* get_for_var(string s);
extern instr_arg* make_constant_arg(int val);
extern void merge_vec (vector<IR_instruction*>&res, vector<IR_instruction*>&vec1, vector<IR_instruction*>&vec2);
extern IR_instruction* gen_3ac_command_arg(string command , instr_arg* arg);
extern IR_instruction* gen_3ac_command(string command);
extern instr_arg* gen_3ac_command_res(string command , instr_arg* arg);
extern IR_instruction* gen_3ac_command_arg1_arg2(string command , instr_arg* arg1, instr_arg* arg2);
extern instr_arg* get_dereference(instr_arg* arg);
extern instr_arg* make_string_arg(string s);
extern instr_arg* gen_3ac_malloc_call(instr_arg* param);
extern void gen_3ac_print_call(instr_arg* param, pair<bool, string> dtype);
extern instr_arg* gen_3ac_function_call(instr_arg* func_arg, vector<instr_arg*> param, int num_param);
extern instr_arg* gen_3ac_function_call(instr_arg* func_arg, instr_arg* param1, vector<instr_arg*> param, int num_param);
extern instr_arg* gen_3ac_convert(instr_arg* arg);
extern instr_arg* gen_3ac_convert(instr_arg* arg, int x);
extern Symbol_Table * current_symbol_table;
extern int for_iter_count;
extern instr_arg* alloc_mem_arg;
extern instr_arg* print_arg;
extern bool found_in_global;

// Misc Functions

extern bool offset_sort(pair<string, Symbol_Table_Entry *> p1, pair<string, Symbol_Table_Entry *> p2);

// Node Functions
extern int node_count;
extern map<int, Data_Type_Node *> data_type_nodes;
extern int next_node_index();

class Data_Type_Node{
    public:
        pair<bool, string> init_data_type;
        bool is_func = false;
        bool is_class = false;
        pair<bool, string> new_data_type;
        int node_ix;    
};
extern int new_data_type_node(pair<bool, string> data_type_);

// Class Definations
class Semantic_Data{
    public:
        int virtual_line_no;
        int line_no;
        string lexeme;
        bool is_list;
        vector<pair<bool,string>> func_args;
        bool is_assignable;
        bool is_func_ret_type;
        bool is_declarable;
        vector<string> name_list;
        vector<string> lexemes;
        bool is_self = false;
        string string_semantic_val;

        //parse 2 harsh
        // pair<bool,string> data_type;
        Symbol_Table* var_scope = NULL;

        // parse 2
        pair<bool,string> data_type;
        vector<pair<bool,string>> data_type_vec;
        vector<int> node_ix_vec;
        Function_Attribute * function_table_entry;
        char trailer_type;
        bool is_func = false;
        bool is_class = false;
        int node_ix;
        int aug_type;

        //parse 3
        instr_arg* res_arg;
        instr_arg* extra_arg;   //used in exceptional cases like a>b>c
        vector<instr_arg*> res_arg_list;    //used in lists, function calls
        vector<IR_instruction*> finish_list;
        IR_instruction* false_goto;
        int label;    //label number of the first line of a block of code
        instr_arg* for_it;
        instr_arg* for_lim;
        vector<IR_instruction*> break_list;
        vector<IR_instruction*> continue_list;
};


class Symbol_Table_Entry{
    public:
        pair<bool,string> data_type;
        int min_virtual_line_no;
        int line_no;
        int offset;
        void set_min_virtual_line_no(int min_virtual_line_no_);
        void print();
        bool is_declared = false;
        bool is_func_param = false;
        bool is_global;
        instr_arg* assigned_temporary = NULL;
};

class Function_Attribute{
    public:
        pair<bool, string> return_type;
        vector<pair<bool,string>> arg_type;
        int min_virtual_line_no;
        int line_no;
        Symbol_Table * func_sym;
        instr_arg* func_pointer_arg;
        void print();
};

class Symbol_Table{
    public:
            // Attributes
        Symbol_Table* parent_symbol_table = NULL;
        int type;
        string name;
        string print_name;
        int current_offset = 0;
        int self_variables_offset = 0;
        map<string, Symbol_Table_Entry *> symbol_table;
        map<string, Function_Attribute*> function_table;
        map<string, Symbol_Table_Entry*> self_variables;
        vector<pair<string,Symbol_Table_Entry *>> function_parameters;
        vector<string> static_strings;
        vector<instr_arg*> string_args;

        Class_Attribute* class_attributes = NULL;
        Function_Attribute* function_attributes = NULL;

        vector<pair<string,int>> operators;
        vector<pair<string,int>> constants;

        map<int,Symbol_Table_Entry*> for_iter_variables;
        map<int,Symbol_Table_Entry*> for_lim_variables;
            //3AC code
        vector<IR_instruction*> final_3ac;

            // Methods
        Symbol_Table_Entry * add_entry(string lexeme_, int virtual_line_no_ , pair<bool, string> data_type_ , bool is_func_param_ , int line_no_ );
        void add_self_entry(string lexeme_, Symbol_Table_Entry * symbol_table_entry_);
        Function_Attribute * add_function(string lexeme_, int line_no_, int virtual_line_no_, Symbol_Table * func_sym_, vector<pair<bool,string>> &args_ , pair<bool, string> ret_type_);
        Symbol_Table_Entry * add_self_entry(string lexeme_, int virtual_line_no_ , pair<bool, string> data_type_);
        Symbol_Table_Entry * is_present_symbol(string lexeme_);
        Symbol_Table_Entry * is_present_self_variable(string lexeme_);
        Function_Attribute *  is_present_function(string lexeme_);
        pair<bool, int> get_offset(string lexeme_);
        void add_for_variable();
        void write_to_file(ofstream & fout);
};

class Class_Attribute{
    public:
        int virtual_line_no;
        int line_no;
        Symbol_Table * symbol_table = NULL;
        Symbol_Table * base_class = NULL;
        void add_inheritance(string name);
        bool is_parent(string pclass);
};

class instr_arg{
    public:
        int type;
        union{
            int temp_no;
            int int_val;
            float float_val;
            long long int immediate_pointer;
        };
        int offset;
        int stackptr_change_amount;      //for func_arg it is the amount by which stackpointer must change
        string text;
};

class IR_instruction{
    
    public:
        string op;
        instr_arg* arg1;
        instr_arg* arg2;
        instr_arg* res;
        int op_type;
};

// Milestone 3

extern string LABEL_PREFIX;
extern int label_count;