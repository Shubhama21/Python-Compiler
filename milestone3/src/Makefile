parser: lex.yy.o parser.tab.o parser_1_declaration.tab.o parser_2.tab.o parser_3.tab.o depend.o
	g++ depend.o lex.yy.o parser.tab.o parser_1_declaration.tab.o parser_2.tab.o parser_3.tab.o -o parser -ll -lfl -g

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c -o lex.yy.o

parser.tab.o: parser.tab.c
	g++ -c parser.tab.c -o parser.tab.o

parser_1_declaration.tab.o: parser_1_declaration.tab.c
	g++ -c parser_1_declaration.tab.c -o parser_1_declaration.tab.o

parser_2.tab.o: parser_2.tab.c
	g++ -c parser_2.tab.c -o parser_2.tab.o

parser_3.tab.o: parser_3.tab.c
	g++ -c parser_3.tab.c -o parser_3.tab.o

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

parser.tab.c: parser.y
	bison parser.y 

parser.tab.h: parser.y
	bison -d parser.y

parser_1_declaration.tab.c: parser_1_declaration.y
	bison parser_1_declaration.y 

parser_2.tab.c: parser_2.y
	bison -d -t parser_2.y

parser_3.tab.c: parser_3.y
	bison parser_3.y

depend.o: depend.h depend.cpp
	g++ -c depend.cpp -o depend.o

clean:
	rm -f *.tab.c 
	rm -f *.tab.h 
	rm -f *.yy.c
	rm -f parser
	rm -f *.txt
	rm -f *.csv
	rm -f *.o
	rm -f *.s
	rm -f exe