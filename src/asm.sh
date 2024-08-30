gcc $1 -o exe -no-pie
valgrind ./exe --track-origin=yes --leak-check=full -s
./exe
