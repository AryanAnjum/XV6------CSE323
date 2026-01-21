// user/spin.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int i;
  int x = 0;

  printf("Spinning...\n");
  
  // Infinite loop to burn CPU time
  for(i = 0; ; i++) {
    x = x + 1;
  }
  
  exit(0);
}