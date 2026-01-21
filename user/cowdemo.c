#include "kernel/types.h"
#include "user/user.h"
#include "kernel/memlayout.h"

// Allocate a large chunk of memory
#define LARGE_SIZE (10 * 1024 * 1024) // 10 MB

void
test_cow()
{
  int pid;
  char *mem;
  int initial_free, after_alloc, after_fork, after_write;
  
  printf("--- Copy-on-Write (CoW) Demonstration ---\n\n");

  initial_free = freemem();
  printf("1. Initial Free Memory: %d KB\n", initial_free / 1024);

  // Allocate 10MB
  printf("   Allocating %d KB...\n", LARGE_SIZE / 1024);
  mem = malloc(LARGE_SIZE);
  if(mem == 0){
    printf("malloc failed\n");
    return;
  }
  // Determine physical memory usage by checking free memory drop
  memset(mem, 'A', LARGE_SIZE);
  after_alloc = freemem();
  printf("2. Free Memory after malloc (and writing to it): %d KB\n", after_alloc / 1024);
  printf("   (Dropped by ~%d KB)\n\n", (initial_free - after_alloc) / 1024);


  printf("3. Forking Process...\n");
  pid = fork();

  if(pid < 0){
    printf("fork failed\n");
    exit(1);
  }

  if(pid == 0){
    // CHILD PROCESS
    sleep(10); // Wait for parent to check stats
    
    // Trigger CoW
    printf("\n[Child] Writing to memory (Triggering CoW)...\n");
    mem[0] = 'B'; // Modify separate page
    
    printf("[Child] Done writing. Exiting.\n");
    exit(0);
  } else {
    // PARENT PROCESS
    
    // Check free memory immediately after fork
    // IF CoW works: Free memory should NOT drop significantly (only page table overhead)
    // IF Standard Fork: Free memory would drop by another 10MB
    after_fork = freemem();
    printf("4. Free Memory immediately after fork: %d KB\n", after_fork / 1024);
    printf("   Difference: %d KB\n", (after_alloc - after_fork) / 1024);
    
    if (after_alloc - after_fork < LARGE_SIZE / 2) {
        printf("   >> SUCCESS! Memory usage did NOT double. CoW is working.\n");
    } else {
        printf("   >> FAILURE! Memory usage doubled. Standard fork behavior.\n");
    }

    wait(0); // Wait for child
    
    // After child writes and exits...
    after_write = freemem();
    printf("5. Child exited. Memory reclaimed.\n");
    printf("   Final Free Memory: %d KB\n", after_write / 1024);
  }

  free(mem);
}

int
main(int argc, char *argv[])
{
  test_cow();
  exit(0);
}
