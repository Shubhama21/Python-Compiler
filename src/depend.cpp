#include "depend.h"

    // Node Functions
int node_count;
map<int, Data_Type_Node *> data_type_nodes;
int next_node_index()
{
    int val = node_count;
    node_count++;
    return val;
}

int new_data_type_node(pair<bool, string> data_type_)
{
    int node_ix_ = node_count;
    Data_Type_Node * ptr = new Data_Type_Node;
    ptr->init_data_type = data_type_;
    ptr->new_data_type = data_type_;
    ptr->node_ix = node_ix_;
    data_type_nodes[node_ix_] = ptr;
    node_count++;
    return node_ix_;
}

    // Global Variables

map<string, Class_Attribute*> Class_Table = {{"int" , NULL},{"float" , NULL},{"bool" , NULL},{"str" , NULL}};
map<string, Symbol_Table *> Function_Symbol_Tables;
Symbol_Table * global_symbol_table = new Symbol_Table;
Symbol_Table * current_symbol_table = global_symbol_table;
vector<Symbol_Table*> Function_Sym_Tbl_list;
map<string, Symbol_Table*> Class_Sym_Tbl_map = {{"int" , NULL},{"float" , NULL},{"bool" , NULL},{"str" , NULL}};
Class_Attribute* Primitive_Attribute = new Class_Attribute;
int temp_count = 0;
int string_count = 0;
int label_count = 0;
int for_iter_count = 0;
vector<int> label_to_3ac_instr;
instr_arg* alloc_mem_arg = new instr_arg;
instr_arg* print_arg = new instr_arg;
bool found_in_global;

int get_param_size(pair<bool,string> s)
{
    // if (s.first == true) return 8;
    // else if (s.second=="int" || s.second=="float") return 4;
    // else if (s.second=="bool") return 1;    
    // else return 8;
    return 8;
}

    /* Error Functions */

void myerror(string s, int line_no)
{
    cout<<"Error Detected on Line No: "<<line_no<<endl;
    cout<<s<<endl;
    exit(1);
}

void myerror(string s, int first_line_no, int last_line_no)
{
    cout<<"Error Detected on Line No: "<<first_line_no<<" to "<<last_line_no<<endl;
    cout<<s<<endl;
    exit(1);
}

void yyerror(const char * s)
{
    cout<<"Error realised on Line No: "<<yylineno<<endl;
    cout<<s<<endl;
    exit(0);
}

void (*yy1error)(const char * s) = yyerror;
void (*yy2error)(const char * s) = yyerror;
void (*yy3error)(const char * s) = yyerror;


    // Different Lexers

int (*yy1lex)() = yylex;
int (*yy2lex)() = yylex;
int (*yy3lex)() = yylex;


    // Type Checking Function

string dtype_to_str(pair<bool, string> dtype)
{
    if (dtype.first==true)
    {
        return "list[" + dtype.second + "]";
    }
    else
    {
        return dtype.second;
    }
}

void check_dt(vector<pair<bool, string>> allowed_dtypes, vector<pair<bool, string>> ip_dtypes, int first_line, int last_line)
{
    for (auto d : ip_dtypes)
    {
        bool found = false;
        for (auto ad : allowed_dtypes)
        {
            if (ad==d)
            {
                found = true;
            }
        }
        if (!found)
        {
            string error_msg = "The provided data type is not compatible in the given context. The expected data types are the following: ";
            int i;
            int n = ip_dtypes.size();
            for(i=0;i<n;i++)
            {
                error_msg+= dtype_to_str(allowed_dtypes[i]);
                if (i==n-1)
                {
                    error_msg+=" ";
                }
                else
                {
                    error_msg+=" or ";
                }
            }
            error_msg += "but the data type which has been used is: " + dtype_to_str(d);
            myerror(error_msg, first_line, last_line);
        }
    }
}


void type_check_func(pair<bool, string> func_dtype, int node_ix, int first_line, int last_line)
{
    auto arg_dtype = data_type_nodes[node_ix]->init_data_type;
    if (func_dtype != arg_dtype)
    {
        if (func_dtype!=arg_dtype)
        {
            if (func_dtype==INT_DT)
            {
                check_dt({FLOAT_DT, BOOL_DT}, {arg_dtype}, first_line, last_line);
            }
            else if (func_dtype==FLOAT_DT)
            {
                check_dt({INT_DT}, {arg_dtype}, first_line, last_line);
            }
            else if (func_dtype==BOOL_DT)
            {
                check_dt({STR_DT, FLOAT_DT, INT_DT, BOOL_DT}, {arg_dtype}, first_line, last_line);
            }
            else
            {
                string error_msg = "The provided data type is not compatible in the given context. The expected data type is: " + dtype_to_str(func_dtype) + " but the data type which has been used is: " + dtype_to_str(arg_dtype);
                myerror(error_msg, first_line, last_line);
            }
        }
    }
    data_type_nodes[node_ix]->new_data_type = func_dtype;
}

void up_cast_numeric(int node_ix1, int node_ix2)
{
    auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
    auto dtype2 = data_type_nodes[node_ix2]->init_data_type;
    if (dtype1==dtype2)
    {
        if (dtype1==BOOL_DT)
        {
            data_type_nodes[node_ix1]->new_data_type = INT_DT;
            data_type_nodes[node_ix2]->new_data_type = INT_DT;
        }
    }
    else
    {
        if (dtype1==FLOAT_DT)
        {
            data_type_nodes[node_ix2]->new_data_type = FLOAT_DT;
        }
        else if (dtype2==FLOAT_DT)
        {
            data_type_nodes[node_ix1]->new_data_type = FLOAT_DT;
        }
        else if (dtype1==INT_DT)
        {
            data_type_nodes[node_ix2]->new_data_type = INT_DT;
        }
        else
        {
            data_type_nodes[node_ix1]->new_data_type = INT_DT;
        }
    }
}

pair<bool, string> type_check(int operation, int node_ix1, int node_ix2, int first_line, int last_line)
{
    auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
    switch(operation)
    {
        case GEN_ARITHMETIC:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            auto dtype2 = data_type_nodes[node_ix2]->init_data_type;
            check_dt({FLOAT_DT, INT_DT, BOOL_DT}, {dtype1, dtype2}, first_line, last_line);
            up_cast_numeric(node_ix1, node_ix2);
            return data_type_nodes[node_ix1]->new_data_type;
        }
        case GEN_SINGLE_ARITHMETIC:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            check_dt({FLOAT_DT, INT_DT, BOOL_DT}, {dtype1}, first_line, last_line);
            if (dtype1==BOOL_DT)
            {
                data_type_nodes[node_ix1]->new_data_type = INT_DT;
                return INT_DT;
            }
            else
            {
                return dtype1;
            }
        }
        case INT_ARITHMETIC:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            auto dtype2 = data_type_nodes[node_ix2]->init_data_type;
            check_dt({INT_DT}, {dtype1, dtype2}, first_line, last_line);
            return INT_DT;
        }
        case INT_SINGLE_ARITHMETIC:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            check_dt({INT_DT}, {dtype1}, first_line, last_line);
            return INT_DT;
        }
        case BOOL_DOUBLE:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            auto dtype2 = data_type_nodes[node_ix2]->init_data_type;
            check_dt({STR_DT, FLOAT_DT, INT_DT, BOOL_DT}, {dtype1, dtype2}, first_line, last_line);
            data_type_nodes[node_ix1]->new_data_type = BOOL_DT;
            data_type_nodes[node_ix2]->new_data_type = BOOL_DT;
            return BOOL_DT;
        }
        case BOOL_SINGLE:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            check_dt({STR_DT, FLOAT_DT, INT_DT, BOOL_DT}, {dtype1}, first_line, last_line);
            data_type_nodes[node_ix1]->new_data_type = BOOL_DT;
            return BOOL_DT;
        }
        case ASSIGNMENT:
        {
            auto dtype1 = data_type_nodes[node_ix1]->init_data_type;
            auto dtype2 = data_type_nodes[node_ix2]->init_data_type;
            if (dtype1!=dtype2)
            {
                if (dtype1==INT_DT)
                {
                    check_dt({FLOAT_DT, BOOL_DT}, {dtype2}, first_line, last_line);
                }
                else if (dtype1==FLOAT_DT)
                {
                    check_dt({INT_DT}, {dtype2}, first_line, last_line);
                }
                else if (dtype1==BOOL_DT)
                {
                    check_dt({STR_DT, FLOAT_DT, INT_DT, BOOL_DT}, {dtype2}, first_line, last_line);
                }
                else
                {
                    myerror("Can not assign " + dtype_to_str(dtype2) + " to " + dtype_to_str(dtype1), first_line, last_line);
                }
            }
            data_type_nodes[node_ix2]->new_data_type = dtype1;
            return data_type_nodes[node_ix1]->new_data_type;
        }
    }
    return INT_DT;
}

    // Misc Functions

bool offset_sort(pair<string, Symbol_Table_Entry *> p1, pair<string, Symbol_Table_Entry *> p2)
{
    if (p1.second->offset < p2.second->offset)
    {
        return true;
    }
    else
    {
        return false;
    }
}



    /* Function Attribute Function Definations */
    
void Function_Attribute::print()
{
    cout<<"Printing Function Attribute"<<endl;
    cout<<"min_virtual_line_no: "<<min_virtual_line_no<<endl;
    cout<<"return_type is_list: "<<return_type.first<<endl;
    cout<<"return_type string: "<<return_type.second<<endl;
    cout<<"arguments: "<<endl;
    for (auto item : arg_type)
    {
        cout<<"is_list: "<<item.first<<" "<<"data_type: "<<item.second<<endl;
    }
    cout<<endl;
}


    /* Symbol Table Entry Function Definations */

void Symbol_Table_Entry::set_min_virtual_line_no(int min_virtual_line_no_)
{
    min_virtual_line_no = min_virtual_line_no_;
}

void Symbol_Table_Entry::print()
{
    cout<<"Printing Symbol Table Entry"<<endl;
    // cout<<"is_list: "<<data_type.first<<endl;
    // cout<<"data_type: "<<data_type.second<<endl;
    // cout<<"min_virtual_line_no: "<<min_virtual_line_no<<endl;
    cout<<"offset"<<offset<<endl;
    cout<<endl;
}


    /* Symbol Table Function Definations */

Symbol_Table_Entry * Symbol_Table::add_entry(string lexeme_, int virtual_line_no_ , pair<bool, string> data_type_ , bool is_func_param_ , int line_no_ )
{
    if (is_present_symbol(lexeme_))
    {
        cout<<lexeme_<<" has been declared previously within this hierarcy\nLine No:"<<virtual_line_no_ - line_pad_count<<endl;
        exit(1);
    }
    Symbol_Table_Entry * symbol_table_entry = new Symbol_Table_Entry;
    symbol_table_entry->set_min_virtual_line_no(virtual_line_no_);
    symbol_table_entry->data_type = data_type_;
    symbol_table_entry->is_func_param = is_func_param_;
    symbol_table_entry->line_no = line_no_;

    if (type == GLOBAL_SYMBOL_TABLE){
        symbol_table_entry->is_global = true;
        symbol_table_entry->offset = current_offset;
        int mysize = get_param_size(data_type_);
        current_offset+=mysize;
    }

    else if (type == FUNCTION_SYMBOL_TABLE){
        symbol_table_entry->is_global = false;
        if (is_func_param_){
            symbol_table_entry->offset = 8*(2+function_parameters.size());
            function_parameters.push_back({lexeme_ , symbol_table_entry});
        }
        else
        {
            int mysize = get_param_size(data_type_);
            current_offset+=mysize;
            symbol_table_entry->offset = -current_offset;
        }
    }
    else{
        symbol_table_entry->is_global = false;
    }
    
    
    
    symbol_table[lexeme_] = symbol_table_entry;
    return symbol_table_entry;
}

void Symbol_Table::add_self_entry(string lexeme_, Symbol_Table_Entry * symbol_table_entry_)
{
    if (is_present_self_variable(lexeme_))
    {
        cout<<lexeme_<<" has been declared previously within this heirarcy\n"<<yylineno<<endl;
        exit(1);
    }
    symbol_table_entry_->offset = current_offset;
    self_variables[lexeme_] = symbol_table_entry_;
    int mysize = get_param_size(symbol_table_entry_->data_type);
    current_offset+=mysize;
}

Symbol_Table_Entry * Symbol_Table::add_self_entry(string lexeme_, int virtual_line_no_ , pair<bool, string> data_type_)
{
    Symbol_Table_Entry * symbol_table_entry = new Symbol_Table_Entry;
    if (is_present_self_variable(lexeme_))
    {
        cout<<lexeme_<<" has been declared previously within this heirarcy\n"<<yylineno<<endl;
        exit(1);
    }
    symbol_table_entry->set_min_virtual_line_no(virtual_line_no_);
    symbol_table_entry->data_type = data_type_;
    symbol_table_entry->offset = self_variables_offset;
    self_variables[lexeme_] = symbol_table_entry;
    int mysize = get_param_size(data_type_);
    self_variables_offset+=mysize;
    return symbol_table_entry;
}

void Symbol_Table::write_to_file(ofstream & fout)
{
    //Global Symbol Table
    if (type==GLOBAL_SYMBOL_TABLE){
        fout<<"Global Symbol Table\n\n";

        fout<< "Symbol Table Entries" << endl;
        fout <<"Lexeme, line no, offset, data type, size" << endl; 
        for(auto x: symbol_table){
            if (x.second==NULL)
            {
                fout<<"~~~~~~~~~~~~~~~~~~~"<<x.first<<endl;
            }
            if (x.second==NULL || x.second->is_func_param == true) continue;
            fout << (x.first) <<"," <<(x.second)->line_no << ","<<(x.second)->offset<<",";
            if (((x.second)->data_type).first == false) fout<<x.second->data_type.second<<",";
            else fout<<"list["<<x.second->data_type.second<<"],";
            fout<<get_param_size(x.second->data_type)<<"\n";
        }

        fout<<"\n";

        fout << "Function Attributes" << endl;
        fout << "Function Name, line_no, return type,  argument type" << endl;
        for(auto x: function_table){
          fout<<x.first<<",";
          fout << (x.second)->line_no<< ",";
          
          if(((x.second)->return_type).first)
            fout<<"list["<< ((x.second)->return_type).second<<"]"<<",";
          else
            fout << ((x.second)->return_type).second <<",";            
          
          for(auto y: x.second->arg_type){
            if(y.first){
                fout<<"list["<<y.second<<"]"<<",";
            }
            else
                fout<<y.second<<",";
          }
          fout<<endl;
        }
        fout<<"\n";

        fout<<"Statically Stored Strings"<<endl;
        for(auto x: static_strings){
            fout << x << endl;
        }

        fout<<"\nOther tokens\n";
        fout<<"Category, lexeme , line no\n";
        for (auto &it : constants){
            fout<<"Constant, "<<it.first<<","<<it.second<<"\n";
        }
        for (auto &it : operators){
            fout<<"Operator, "<<it.first<<","<<it.second<<"\n";
        }
    }

    // Function Symbol Table
    else{
        fout<<"Function: "<<print_name<<endl;
        fout<<"Total size of local variables = "<<current_offset<<'\n';

        fout<< "\nSymbol Table Entries" << endl;
        fout <<"Lexeme, line no, offset, data type , size" << endl; 
        for(auto x: symbol_table){
            if (x.second==NULL)
            {
                fout<<"~~~~~~~~~~~~~~~~~~~"<<x.first<<endl;
            }
            if (x.second==NULL || x.second->is_func_param == true || x.second->is_global) continue;
            fout << (x.first) <<"," <<(x.second)->line_no << ","<<(x.second)->offset<<",";
            if (((x.second)->data_type).first == false) fout<<x.second->data_type.second<<",";
            else fout<<"list["<<x.second->data_type.second<<"],";
            fout<<get_param_size(x.second->data_type)<<"\n";
        }
        fout<<"\n";

        fout<<"Function Parameters\n";
        fout <<"Lexeme, line no, data type, size" << endl; 
        for (auto &it: function_parameters){
            fout << (it.first) << ","<<(it.second)->line_no << ",";
            if (((it.second)->data_type).first) fout<<"list["<<it.second->data_type.second<<"],";
            else fout<<it.second->data_type.second<<",";
            fout<<get_param_size(it.second->data_type)<<"\n";
        }

        fout<<"\nOther tokens\n";
        fout<<"Category, lexeme , line no\n";
        for (auto &it : constants){
            fout<<"Constant, "<<it.first<<","<<it.second<<"\n";
        }
        for (auto &it : operators){
            fout<<"Operator, "<<it.first<<","<<it.second<<"\n";
        }
    }        
    
    // fout<<"Function Table Entries: "<<endl;
    // for (auto item : function_table)
    // {
    //     fout<<"Function Name: "<<item.first<<endl;
    //     item.second->print();
    // }

    // fout<<"Class Inheritance"<<endl;
    // fout<<"Yet to add"<<endl;

    fout<<endl;
}
Function_Attribute * Symbol_Table::add_function(string lexeme_, int line_no_, int virtual_line_no_, Symbol_Table * func_sym_, vector<pair<bool,string>> &args_ , pair<bool, string> ret_type_)
{
    if (function_table.find(lexeme_)!=function_table.end())
    {
        myerror("The function " + lexeme_ + " has been declared before", line_no_);
    }

    Function_Attribute * entry = new Function_Attribute;
    entry->min_virtual_line_no = virtual_line_no_;
    entry->line_no = line_no_;
    entry->arg_type = args_;
    entry->return_type = ret_type_;
    entry->func_sym = func_sym_;
    func_sym_->function_attributes = entry;
    
    instr_arg* func_ptr_arg = new instr_arg;
    func_ptr_arg->type = IMMEDIATE_POINTER;
    if (this->type == GLOBAL_SYMBOL_TABLE){
        func_ptr_arg->text = lexeme_;
        func_sym_->print_name = lexeme_;
    }
    else{
        func_ptr_arg->text = this->name+"."+lexeme_;
        func_sym_->print_name = this->name+"."+lexeme_;
    }
    func_ptr_arg->stackptr_change_amount = 0;
    for(auto &it : args_){
        func_ptr_arg->stackptr_change_amount += get_param_size(it);
    }
    entry->func_pointer_arg = func_ptr_arg;

    function_table[lexeme_] = entry;
    return entry;
}
Symbol_Table_Entry * Symbol_Table::is_present_symbol(string lexeme_)
{
    auto ptr = symbol_table.find(lexeme_);
    if (ptr!=symbol_table.end())
    {
        if (type==GLOBAL_SYMBOL_TABLE)
            found_in_global = true;
        return ptr->second;
    }
    if (type==GLOBAL_SYMBOL_TABLE)
    {
        return NULL;
    }
    if (class_attributes!=NULL && class_attributes->base_class!=NULL)
    {
        auto ptr = class_attributes->base_class->is_present_symbol(lexeme_);
        return ptr;
    }
    else
    {
        auto ptr = global_symbol_table->is_present_symbol(lexeme_);
        return ptr;
    }
}

Symbol_Table_Entry * Symbol_Table::is_present_self_variable(string lexeme_)
{
    auto ptr = self_variables.find(lexeme_);
    if (ptr!=self_variables.end())
    {
        if (type==GLOBAL_SYMBOL_TABLE)
            found_in_global = true;
        return ptr->second;
    }
    if (type==GLOBAL_SYMBOL_TABLE)
    {
        return NULL;
    }
    if (class_attributes!=NULL && class_attributes->base_class!=NULL)
    {
        auto ptr = class_attributes->base_class->is_present_self_variable(lexeme_);
        return ptr;
    }
    else
    {
        auto ptr = global_symbol_table->is_present_self_variable(lexeme_);
        return ptr;
    }
}

Function_Attribute * Symbol_Table::is_present_function(string lexeme_)
{
    auto ptr = function_table.find(lexeme_);
    if (ptr!=function_table.end())
    {
        if (type==GLOBAL_SYMBOL_TABLE)
            found_in_global = true;
        return ptr->second;
    }
    if (type==GLOBAL_SYMBOL_TABLE)
    {
        return NULL;
    }
    if (class_attributes!=NULL && class_attributes->base_class!=NULL)
    {
        auto fptr = class_attributes->base_class->is_present_function(lexeme_);
        return fptr;
    }
    else
    {
        auto fptr = global_symbol_table->is_present_function(lexeme_);
        return fptr;
    }
}

void Symbol_Table::add_for_variable()
{
    Symbol_Table_Entry* entry = new Symbol_Table_Entry;
    //entry->offset = 
    for_iter_variables[for_iter_count] = entry;
    entry = new Symbol_Table_Entry;
    //entry->offset = 
    for_lim_variables[for_iter_count] = entry;
    for_iter_count++;
}

pair<bool, int> Symbol_Table::get_offset(string lexeme_)
{
    switch(type)
    {
        case FUNCTION_SYMBOL_TABLE:
        {
            found_in_global = false;
            Symbol_Table_Entry * ptr = is_present_symbol(lexeme_);
            if (ptr!=NULL)
            {
                return {found_in_global,ptr->offset};
            }
            break;
        }
        case CLASS_SYMBOL_TABLE:
        {
            found_in_global = false;
            Symbol_Table_Entry * ptr = is_present_self_variable(lexeme_);
            if (ptr!=NULL)
            {
                return {found_in_global,ptr->offset};
            }
            break;
        }
        case GLOBAL_SYMBOL_TABLE:
        {
            found_in_global = false;
            Symbol_Table_Entry * ptr = is_present_symbol(lexeme_);
            if (ptr!=NULL)
            {
                return {found_in_global,ptr->offset};
            }
            break;
        }
    }
    return {false, -1};
}

    // Class Attribute Functions

void Class_Attribute::add_inheritance(string name){
    // Updating Pointer
    if(Class_Table.find(name)==Class_Table.end())
    {
        myerror("Class " + name + " has not been defined",line_no);
    }
    if (name==symbol_table->name)
    {
        myerror("Class " + name + ": can not inherit from itself",line_no);
    }
    base_class = Class_Sym_Tbl_map[name];
    symbol_table->current_offset = base_class->current_offset;
}

bool Class_Attribute::is_parent(string pclass)
{
    if (pclass==symbol_table->name)
    {
        return true;
    }
    bool ans = false;
    if (base_class!=NULL)
    {
        Class_Attribute * cptr = base_class->class_attributes;
        ans = ans || cptr->is_parent(pclass);
    }
    return ans;
}

bool is_memory_var (instr_arg* arg){
    return (arg->type == LOCAL_VARIABLE || arg->type == GLOBAL_VARIABLE);
}

instr_arg* make_new_temporary(){
    instr_arg* new_arg = new instr_arg;
    new_arg->type = TEMPORARY_VARIABLE;
    new_arg->temp_no = temp_count;
    new_arg->text = "%t"+ to_string(temp_count);

    // Fix it may not only be int
    Symbol_Table_Entry* entry = current_symbol_table->add_entry(new_arg->text, -1, INT_DT, false, -1);
    new_arg->offset = entry->offset;
    temp_count++;
    return new_arg;
}

instr_arg* gen_3ac_arithmetic (instr_arg* arg1 , instr_arg* arg2 , string op){
    // if (is_memory_var(arg1) && is_memory_var(arg2)){
    //     // gen_3ac_mov(arg1 , )
    // }
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->arg2 = arg2;
    new_instruction->op = op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_ARG1_OP_ARG2;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

instr_arg* gen_3ac_unary_op (instr_arg* arg1 , string op){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->op = op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_OP_ARG1;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

instr_arg* gen_3ac_relational (instr_arg* arg1 , instr_arg* arg2 , string op){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->arg2 = arg2;
    new_instruction->op = op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_ARG1_OP_ARG2_RELATIONAL;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

instr_arg* gen_3ac_relational_str (instr_arg* arg1 , instr_arg* arg2 , string op){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->arg2 = arg2;
    new_instruction->op = "str " + op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_ARG1_OP_ARG2_RELATIONAL;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

instr_arg* gen_3ac_logical (instr_arg* arg1 , instr_arg* arg2 , string op){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->arg2 = arg2;
    new_instruction->op = op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_ARG1_OP_ARG2;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

instr_arg* gen_3ac_unary_logical (instr_arg* arg1 , string op){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->op = op;
    new_instruction->res = make_new_temporary();
    new_instruction->op_type = RES_OP_ARG1;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction->res;
}

void gen_3ac_mov (instr_arg* arg1 , instr_arg* res){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->op = "MOV";
    new_instruction->res = res;
    new_instruction->op_type = MOV;

    current_symbol_table->final_3ac.push_back(new_instruction);
}

void gen_3ac_mov_to_reference (instr_arg* arg1 , instr_arg* res){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->op = "MOV_TO_REFERENCE";
    new_instruction->res = res;
    new_instruction->op_type = MOV_TO_REFERENCE;

    current_symbol_table->final_3ac.push_back(new_instruction);
}

void gen_3ac_mov_from_reference (instr_arg* arg1 , instr_arg* res){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg1;
    new_instruction->op = "MOV_FROM_REFERENCE";
    new_instruction->res = res;
    new_instruction->op_type = MOV_FROM_REFERENCE;

    current_symbol_table->final_3ac.push_back(new_instruction);
}

int gen_new_label(){
    if (current_symbol_table->final_3ac.size() > 0 && current_symbol_table->final_3ac.back()->op_type == LABEL){
        string label_text = current_symbol_table->final_3ac.back()->op;
        return stoi(label_text);
    }
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->op = to_string(label_count);
    new_instruction->op_type = LABEL;

    label_to_3ac_instr.push_back(current_symbol_table->final_3ac.size());
    current_symbol_table->final_3ac.push_back(new_instruction);
    return label_count++;
}

IR_instruction* gen_if_false_goto(instr_arg* arg){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->arg1 = arg;
    new_instruction->op = "ifFalseGoto";
    new_instruction->arg2 = new instr_arg;
    new_instruction->arg2->type = CONSTANT;
    new_instruction->op_type = ifFalse_Goto;

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction;
}

IR_instruction* gen_unconditional_jump (){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->op = "Goto";
    new_instruction->op_type = Goto;

    new_instruction->arg2 = new instr_arg;
    new_instruction->arg2->type = CONSTANT;    

    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction;
}

IR_instruction* gen_unconditional_jump (int label_no){
    IR_instruction* new_instruction = new IR_instruction;
    new_instruction->op = "Goto";
    new_instruction->op_type = Goto;

    new_instruction->arg2 = new instr_arg;
    new_instruction->arg2->type = CONSTANT;
    new_instruction->arg2->int_val = label_no;
    new_instruction->arg2->text = LABEL_PREFIX + to_string(label_no);
    
    current_symbol_table->final_3ac.push_back(new_instruction);
    return new_instruction;
}

void backpatch (vector<IR_instruction*> &instr_list , int label_no){
    for (auto &it : instr_list){
        assert(it->op_type == Goto || it->op_type == ifFalse_Goto);
        it->arg2->int_val = label_no;
        it->arg2->text = LABEL_PREFIX + to_string(label_no);
    }
}

void backpatch (IR_instruction* instr , int label_no){    
        assert(instr->op_type == Goto || instr->op_type == ifFalse_Goto);
        instr->arg2->int_val = label_no;
        instr->arg2->text = LABEL_PREFIX + to_string(label_no);
}

instr_arg* get_for_var(string s){
    instr_arg* arg = new instr_arg;
    arg->type = LOCAL_VARIABLE;
    // arg->offset= 
    arg->text = "#"+s+to_string(for_iter_count);
    // May not be only int
    Symbol_Table_Entry* entry = current_symbol_table->add_entry(arg->text, -1, INT_DT, false, -1);
    arg->offset = entry->offset;
    return arg;
}

instr_arg* make_constant_arg(int val){
    instr_arg* arg = new instr_arg;
    arg->type = CONSTANT;
    arg->int_val = val;
    arg->text = to_string(val);
    return arg;
}

void merge_vec (vector<IR_instruction*>&res , vector<IR_instruction*>&vec1 , vector<IR_instruction*>&vec2){
    res.clear();
    res.reserve(vec1.size()+vec2.size());
    res.insert( res.end(), vec1.begin(), vec1.end() );
    res.insert( res.end(), vec2.begin(), vec2.end() );
}

IR_instruction* gen_3ac_command_arg(string command , instr_arg* arg){
    IR_instruction* new_instr = new IR_instruction;
    new_instr->arg1 = arg;
    new_instr->op = command;
    new_instr->op_type = COMMAND_ARG1;
    current_symbol_table->final_3ac.push_back(new_instr);
    return new_instr;
}

IR_instruction* gen_3ac_command(string command ){
    IR_instruction* new_instr = new IR_instruction;
    new_instr->op = command;
    new_instr->op_type = COMMAND;
    current_symbol_table->final_3ac.push_back(new_instr);
    return new_instr;
}

instr_arg* gen_3ac_command_res(string command , instr_arg* arg ){
    IR_instruction* new_instr = new IR_instruction;
    new_instr->op = command;
    new_instr->op_type = COMMAND_RES;
    new_instr->res = arg;
    current_symbol_table->final_3ac.push_back(new_instr);
    return arg;
}

IR_instruction* gen_3ac_command_arg1_arg2(string command , instr_arg* arg1, instr_arg* arg2){
    IR_instruction* new_instr = new IR_instruction;
    new_instr->arg1 = arg1;
    new_instr->arg2 = arg2;
    new_instr->op = command;
    new_instr->op_type = COMMAND_ARG1_ARG2;
    current_symbol_table->final_3ac.push_back(new_instr);
    return new_instr;
}

instr_arg* get_dereference(instr_arg* arg){
    instr_arg* arg_ref = new instr_arg;
    arg_ref->type = TEMPORARY_POINTER;
    arg_ref->temp_no = arg->temp_no;
    arg_ref->text = "(" + arg->text + ")";
    arg_ref->offset = arg->offset;
    return arg_ref;
}
extern void gen_3ac_print_call(instr_arg* param, pair<bool, string> dtype)
{
    if (dtype.second=="str")
    {
        gen_3ac_command_arg("print_str" , param);
    }
    else if(dtype.second=="int")
    {
        gen_3ac_command_arg("print_int" , param);
    }
    else if(dtype.second=="bool")
    {
        gen_3ac_command_arg("print_bool", param);
    }
}

instr_arg* gen_3ac_malloc_call(instr_arg* param){
    gen_3ac_command_arg("malloc" , param);
    auto ans = gen_3ac_command_res("pop_return_val" , make_new_temporary());
    return ans;
}

instr_arg* gen_3ac_function_call(instr_arg* func_arg, vector<instr_arg*> param , int num_param){
    if (num_param%2==1)
    {
        gen_3ac_command("push_dummy_param");
    }
    for (int i=param.size()-1 ; i>=0 ; i--){
        gen_3ac_command_arg("param" , param[i]);
    }
    gen_3ac_command_arg1_arg2 ("call" , func_arg , make_constant_arg(num_param));
    // gen_3ac_command("stackpointer +" + to_string(func_arg->stackptr_change_amount) );
    auto ans = gen_3ac_command_res("pop_return_val" , make_new_temporary());
    gen_3ac_command_arg("restore_stack_fc" , make_constant_arg(8*(num_param + num_param%2)));
    return ans;
}

instr_arg* gen_3ac_function_call(instr_arg* func_arg, instr_arg* param1 , vector<instr_arg*> param , int num_param){
    if (num_param%2==1)
    {
        gen_3ac_command("push_dummy_param");
    }
    for (int i=param.size()-1 ; i>=0 ; i--){
        gen_3ac_command_arg("param" , param[i]);
    }
    gen_3ac_command_arg("param" , param1);
    gen_3ac_command_arg1_arg2 ("call" , func_arg , make_constant_arg(num_param));
    // gen_3ac_command("stackpointer +" + to_string(func_arg->stackptr_change_amount) );
    auto ans = gen_3ac_command_res("pop_return_val" , make_new_temporary());
    gen_3ac_command_arg("restore_stack_fc" , make_constant_arg(8*(num_param + num_param%2)));
    return ans;
}

instr_arg* make_string_arg(string s){
    instr_arg* arg = new instr_arg;
    arg->type = STRING_ARG;
    arg->temp_no = string_count++;
    arg->text = "\"";
    for (int i=0 ; i<s.size() ; i++){
        switch (s[i]){
            case '\n':
                arg->text += "\\n";
                break;
            case '\t':
                arg->text += "\\t";
                break;
            case '\"':
                arg->text += "\\\"";
                break;
            case '\'':
                arg->text += "\\\'";
                break;
            case '\a':
                arg->text += "\\a";
                break;
            case '\b':
                arg->text += "\\b";
                break;
            case '\f':
                arg->text += "\\f";
                break;
            case '\v':
                arg->text += "\\v";
                break;
            case '\r':
                arg->text += "\\r";
                break; 
            default:
                arg->text += s[i];
                break;
        }
    }
    arg->text += "\\n";
    arg->text += "\"";
    return arg;
}

instr_arg* gen_3ac_convert(instr_arg* arg){
    
    int node_index = next_node_index();
    pair<bool, string> from_type, to_type;
    from_type = data_type_nodes[node_index]->init_data_type;
    to_type = data_type_nodes[node_index]->new_data_type;
    
    if (from_type == to_type){
        return arg;
    }
    else
    {
        IR_instruction* instr = new IR_instruction;
        instr->op_type = CONVERT_ARG;
        instr->arg1 = arg;
        instr->op = from_type.second + "_to_" + to_type.second;
        instr->res = make_new_temporary();
        current_symbol_table->final_3ac.push_back(instr);
    
        return instr->res;
    }
}

instr_arg* gen_3ac_convert(instr_arg* arg, int x){
    
    int node_index =x;
    pair<bool, string> from_type, to_type;
    from_type = data_type_nodes[node_index]->init_data_type;
    to_type = data_type_nodes[node_index]->new_data_type;
    
    if (from_type == to_type){
        return arg;
    }
    else
    {
        IR_instruction* instr = new IR_instruction;
        instr->op_type = CONVERT_ARG;
        instr->arg1 = arg;
        instr->op = from_type.second + "_to_" + to_type.second;
        instr->res = make_new_temporary();
        current_symbol_table->final_3ac.push_back(instr);
    
        return instr->res;
    }
}

// Milestone 3

string LABEL_PREFIX = "L";
