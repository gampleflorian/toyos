#ifndef START_H
#define START_H

extern config_interrupt(int, int);
extern int get_interrupt_number();
extern kickstart(unsigned int sp, unsigned int pc, unsigned int cpsr);

#endif
