# XV6------CSE323
xv6-riscv: Multi-Level Feedback Queue (MLFQ) Scheduler
This repository contains a modified version of the MIT xv6-riscv operating system with an enhanced process scheduling mechanism.

The default Round Robin scheduler has been replaced with a Multi-Level Feedback Queue (MLFQ) scheduler to better distinguish between CPU-bound and I/O-bound processes, reduce starvation, and improve overall system responsiveness.

🚀 Project Overview

Traditional Round Robin scheduling treats all processes equally, which can lead to inefficient CPU usage and poor responsiveness for interactive tasks.
This project implements a 3-level MLFQ scheduler that dynamically adjusts process priority based on runtime behavior.
✅ Implemented Features (Milestone 1)

1. Multi-Level Feedback Queue (MLFQ) Scheduler
The scheduler consists of three priority queues:
Queue	Priority	Scheduling Policy	Time Slice
Q0	    High	     Round Robin	     4 ticks
Q1	    Medium	     Round Robin	     8 ticks
Q2	     Low	       FCFS	             Unlimited

• All newly created processes start in Q0
• The scheduler always prefers higher-priority queues
• Lower queues run only when higher queues are empty

2. Demotion & CPU Usage Tracking
• A process is demoted to the next lower queue if it uses its entire time slice
• CPU-bound processes gradually move from Q0 → Q1 → Q2
• I/O-bound and interactive processes usually finish early and remain in higher queues
• CPU usage is tracked in both:
   • usertrap()
   • kerneltrap()
   
3. Anti-Starvation: Global Priority Boost
To prevent starvation of long-running processes:
  • A global priority boost is triggered every 100 ticks
  • All runnable processes are reset to Priority 0 (Q0)
  • This guarantees fairness while preserving MLFQ behavior

4. Process Visualization & Debugging
The Ctrl + P process dump (procdump) has been enhanced to display:
  • Current priority level
  • Ticks spent in each queue (Q0, Q1, Q2)
  • This makes scheduler behavior easy to observe and verify during execution.

5. CPU-Intensive Test Program
A new user program, spin, was added:
 • Continuously consumes CPU cycles
 • Demonstrates:
    • Priority demotion
    • FCFS behavior in Q2
    • Priority reset during global boost

📂 Modified Files
  File	               Description
• kernel/param.h	   Time slice limits and boost interval
• kernel/proc.h	       Added priority and tick tracking fields
• kernel/proc.c	       MLFQ scheduler logic, priority boost, procdump
• kernel/trap.c	       CPU tick accounting and demotion logic
• user/spin.c	       CPU-bound test program
• Makefile	           Added _spin to user programs

🛠 How to Build & Test
1. Build and Run xv6
   
make qemu


2. Run the CPU-Intensive Test Program
Inside the xv6 shell, run:

$ spin &


3. Observe Scheduler Behavior
Press the following key combination:

Ctrl + P

You will observe:
• Process demotion from Q0 → Q1 → Q2
• FCFS scheduling behavior in Q2
• Periodic priority reset to Q0 due to global priority boost
