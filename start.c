#include <stdint.h>
#include "start.h"
#include "uart.h"
#include "task.h"

/* enable IRQ interrupts */
void enable_interrupts (void)
{
	unsigned long temp;
	__asm__ __volatile__("mrs %0, cpsr\n"
			     "bic %0, %0, #0x80\n"
			     "msr cpsr_c, %0"
			     : "=r" (temp)
			     :
			     : "memory");
}
/*
 * disable IRQ/FIQ interrupts
 * returns true if interrupts had been enabled before we disabled them
 */
int disable_interrupts (void)
{
	unsigned long old,temp;
	__asm__ __volatile__("mrs %0, cpsr\n"
			     "orr %1, %0, #0xc0\n"
			     "msr cpsr_c, %1"
			     : "=r" (old), "=r" (temp)
			     :
			     : "memory");
	return (old & 0x80) == 0;
}

//static inline void change_irq(unsigned int NewState)
//{
//  int my_cpsr;
//  asm("MRS %0, CPSR;ORR %0, %0, #0x80;BIC %0, %0, %1, LSL #7;MSR CPSR_c, %0;" : : "r"(my_cpsr), "r"(NewState));
//}

static inline void set_vbar(unsigned long val) {
   asm("mcr p15, 0, %0, c12, c0, 0" : : "r" (val) : "cc");
}
static inline void get_vbar() {
   asm("mrc p15, 0, r0, c12, c0, 0" : :  : "cc");
}

static inline void get_cbar(unsigned long *cbar) {
   unsigned long tmp;
   asm("MRC p15, 4, %0, c15, c0, 0;" : "=r"(tmp) : :);
   *cbar = tmp;
}


void start() {
   for(int i=0; i<4; ++i)
      create_task();

   enable_interrupts();

   print_uart0("hello world\n");

   start_task(0);
   // software interrupt
   asm("swi #0x42;");
   print_uart0("bb world\n");
   while(1) {
      //break;
   }
}

void handler_0() {
   print_uart0("handler_0\n");
}

void handler_x() {
   print_uart0("handler_x\n");
}

void handler_da() {
   print_uart0("handler_da\n");
}

void handler_pa() {
   print_uart0("handler_pa\n");
}

void handler_swi(int id, unsigned int* regs) {
   print_uart0("handler_swi\n");
   print_hex(id);

   if(id == 0x42) {
   // trigger new software interrupt
      asm("swi #0x43;");
   }
   if(id == 0x44) {
      int task_id = regs[0];
      kickstart(tasks[task_id].regs[13], tasks[task_id].regs[15], tasks[task_id].regs[16]);
   }
}

void handler_ui() {
   print_uart0("handler_ui\n");
}

void irq_handler() {
   print_uart0("irq_handler\n");
}
