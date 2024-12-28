#include "task.h"
#include "uart.h"

static unsigned int n_tasks = 0;
static int c_task = 0;
struct task tasks[4];

void start_task(unsigned int task_id)
{
   asm("mov r0, %0; swi #0x44;" : : "r"(task_id));
}

void task_func0(void)
{
   print_uart0("task id\n");
   print_hex(c_task);
   for(int i=0; i<4; ++i) {
      print_hex(i);
   }
   c_task++;
   if(c_task==4)
      c_task = 0;
   //start_task(c_task);
}

/*
Registers R0 to R12 are general purpose registers, R13 is stack pointer (SP), R14 is
subroutine link register and R15 is program counter (PC).
R16 is the current program status register (CPSR) this r
*/
int create_task(void)
{
   for(int i=0; i<16; ++i) {
      tasks[n_tasks].regs[i] = 0;
   }
   tasks[n_tasks].regs[13] = (unsigned int)&tasks[n_tasks].stack[63];
   tasks[n_tasks].regs[15] = (unsigned int)&task_func0;
   tasks[n_tasks].regs[16] = 0x60000110;
   n_tasks++;
   return n_tasks-1;

}
