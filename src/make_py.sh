#!/bin/bash

# Variable Names
output_file_flag=0
input_file_flag=0
VERBOSE=0

# HELP FUNCTION
help ()
{
cat << EndOfMessage

### HELP MESSAGE ###

Usage:
 ./make_ast.sh [options] <inputfile> <outputfile>

Options:
 -v, --verbose                  enable verbose
 -i, --input <inputfile>        set the input python file as <inputfile>
 -o, --output <outputprefix>      set the common output prefix as <outputfile>
 -h, --help                     display this help

Example:
 ./make_ast.sh test1.py myoutput
 ./make_ast.sh -v --input test1.py -o test1_output

####################

EndOfMessage
}

# DO NOT TOUCH
TEMP=$(getopt -o 'hvi:o:' --long 'help,verbose,input:,output:' -n 'make_ast.sh' -- "$@")

if [ $? -ne 0 ]; then
	help
	echo 'Terminating...' >&2
	exit 1
fi

# Note the quotes around "$TEMP": they are essential!
eval set -- "$TEMP"
unset TEMP

while true; do
	case "$1" in
        '-h'|'--help')
            help
			shift
			exit 0
		;;
		'-v'|'--verbose')
            VERBOSE=1
			shift
			continue
		;;
		'-i'|'--input')
			input_file_flag=1
			INPUT_FILE=$2
			shift 2
			continue
        ;;
		'-o'|'--output')
			output_file_flag=1
			OUTPUT_PFX=$2
			shift 2
			continue
		;;
		'--')
			shift
			break
		;;
		*)
			echo 'Internal error!' >&2
			exit 1
		;;
	esac
done

# Checking Number of Arguments
files_left=0
if [ $input_file_flag -eq 0 ]; then
	let "files_left++"
fi
if [ $output_file_flag -eq 0 ]; then
	let "files_left++"
fi
if [ $# -ne $files_left ]; then
	help
	echo 'Terminating...' >&2
	exit 1
fi

# Assigning the remaining arguments
if [ $files_left -eq 2 ]; then
	INPUT_FILE=$1
	OUTPUT_PFX=$2
fi
if [ $files_left -eq 1 ]; then
	if [ $input_file_flag -eq 0 ]; then
		INPUT_FILE=$1
	fi
	if [ $output_file_flag -eq 0 ]; then
		OUTPUT_PFX=$1
	fi
fi
make
./parser $VERBOSE $INPUT_FILE $OUTPUT_PFX
./asm.sh $OUTPUT_PFX.s