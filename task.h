#ifndef TASK_H
#define TASK_H

struct task {
   unsigned int regs[16];
   unsigned int stack[64];
};

extern struct task tasks[4];
void start_task(unsigned int task_id);
int create_task(void);

#endif
