#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  int * ptr = malloc(1024);
  *ptr = 123123123;
}