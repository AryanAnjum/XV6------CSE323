#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Simple spin loop to consume CPU
void spin(int count) {
    int i;
    volatile int x = 0;
    for (i = 0; i < count; i++) {
        x = x + 1; 
    }
}

void cpu_bound() {
    int pid = getpid();
    printf("CPU-Bound process (PID %d) started. Should drop to Priority 2.\n", pid);
    
    // Just spin forever
    while (1) {
        spin(1000000);
    }
}

void io_bound() {
    int pid = getpid();
    printf("I/O-Bound process (PID %d) started. Should stay High Priority (0/1).\n", pid);
    
    while (1) {
        // Sleep for a bit (simulating waiting for IO)
        sleep(1);
        
        // Do a TINY bit of work
        spin(20000000); // 20 million (was 100)
    }
}

void mixed_workload() {
    int pid = getpid();
    printf("Mixed Process (PID %d) started. Should oscillate.\n", pid);
    
    while (1) {
        // Burst of CPU
        spin(500000000); // 500 million (was 5 million)
        
        // Then sleep
        sleep(10);
    }
}

int main(int argc, char *argv[]) {
    int pid;

    printf("MLFQ Demo Starting...\n");
    printf("Use user/spin.c logic to stress test.\n");

    // 1. Create CPU Bound
    pid = fork();
    if (pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }
    if (pid == 0) {
        cpu_bound();
        exit(0);
    }

    // 2. Create I/O Bound
    pid = fork();
    if (pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }
    if (pid == 0) {
        io_bound();
        exit(0);
    }

    // 3. Create Mixed
    pid = fork();
    if (pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }
    if (pid == 0) {
        mixed_workload();
        exit(0);
    }
    
    // Parent just waits
    while(wait(0) != -1);

    exit(0);
}
