.global _start
_start:
    b   reset     ;@ 0x00000000 reset
    b   handler_ui_stub   ;@ 0x00000004 undefined instruction
    b   handler_swi_stub   ;@ 0x00000008 software interrupt swi
    b   handler_pa   ;@ 0x0000000C prefetch abort
    b   handler_da   ;@ 0x00000010 data abort
    b   handler_x   ;@ 0x00000014 dont know
    b   irq_handler   ;@ 0x00000018 irq
    b   handler_0   ;@ 0x000000

.equ NO_IRQ  , 0x80
.equ NO_FIQ  , 0x40
.equ NO_INT  , (NO_IRQ | NO_FIQ)
.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ ABT_MODE, 0x13
.equ SVC_MODE, 0x17
.equ UND_MODE, 0x1b
.equ SYS_MODE, 0x1f

reset:
   // set interrupt vector table base (vbar)
   ldr r0, =_start               // _start = vector table base
   mcr p15, 0, r0, c12, c0, 0    // move _start into vbar register

   /* set the SVC stack pointer */
   mov r0, #(SVC_MODE)
   msr cpsr_c, r0
   ldr sp,=__svc_stack_top__

   // gets the generic interrupt controller base address
   bl get_gic_base

   /* set the IRQ stack pointer */
   mov r0, #(IRQ_MODE | NO_IRQ | NO_FIQ)
   msr cpsr_c, r0
   ldr sp,=__irq_stack_top__

   /* set the FIQ stack pointer */
   mov r0, #(FIQ_MODE | NO_IRQ | NO_FIQ)
   msr cpsr_c, r0
   ldr sp,=__fiq_stack_top__

   /* set the ABT stack pointer */
   mov r0, #(ABT_MODE | NO_IRQ | NO_FIQ)
   msr cpsr_c, r0
   ldr sp,=__abt_stack_top__

   /* set the UND stack pointer */
   mov r0, #(UND_MODE | NO_IRQ | NO_FIQ)
   msr cpsr_c, r0
   ldr sp,=__und_stack_top__

   /* set the SYS stack pointer */
   mov r0, #(SYS_MODE | NO_IRQ | NO_FIQ)
   msr cpsr_c, r0
   ldr sp,=__sys_stack_top__

   /* set the USR stack pointer */
   mov r0, #(USR_MODE)
   msr cpsr_c, r0
   ldr sp,=__usr_stack_top__

   // we will start in svc (supervisor) mode
   mov r0, #(SVC_MODE)
   msr cpsr_c, r0

   bl start
1:
    b 1b

.global handler_ui_stub
handler_ui_stub:

    STMFD   sp!, {r0-r3, r12, lr}  // Store registers
    MOV     r1, sp                 // Set pointer to parameters
    MRS     r0, spsr               // Get spsr
    STMFD   sp!, {r0, r3}          // Store spsr onto stack and another
                                   // register to maintain 8-byte-aligned stack
    TST     r0, #0x20             // Occurred in Thumb state?
    LDRNEH  r0, [lr,#-2]           // Yes: Load halfword and...
    BICNE   r0, r0, #0xFF00        // ...extract comment field
    LDREQ   r0, [lr,#-4]           // No: Load word and...
    BICEQ   r0, r0, #0xFF000000    // ...extract comment field

    // r0 now contains SVC number
    // r1 now contains pointer to stacked registers

    bl handler_ui

    LDMFD   sp!, {r0, r3}          // Get spsr from stack
    MSR     SPSR_cxsf, r0          // Restore spsr
    LDMFD   sp!, {r0-r3, r12, pc}^ // Restore registers and return



.global handler_swi_stub
handler_swi_stub:

    STMFD   sp!, {r0-r3, r12, lr}  // Store registers
    MOV     r1, sp                 // Set pointer to parameters
    MRS     r0, spsr               // Get spsr
    STMFD   sp!, {r0, r3}          // Store spsr onto stack and another
                                   // register to maintain 8-byte-aligned stack
    TST     r0, #0x20             // Occurred in Thumb state?
    LDRNEH  r0, [lr,#-2]           // Yes: Load halfword and...
    BICNE   r0, r0, #0xFF00        // ...extract comment field
    LDREQ   r0, [lr,#-4]           // No: Load word and...
    BICEQ   r0, r0, #0xFF000000    // ...extract comment field

    // r0 now contains SVC number
    // r1 now contains pointer to stacked registers

    // disable interrupts (nesting)
    //cpsid if
    bl handler_swi
    //cpsie if

    LDMFD   sp!, {r0, r3}          // Get spsr from stack
    MSR     SPSR_cxsf, r0          // Restore spsr
    LDMFD   sp!, {r0-r3, r12, pc}^ // Restore registers and return

// r0: sp
// r1: pc
// r2: cpsr
.global kickstart
kickstart:
    MSR     SPSR_cxsf, r2          // Restore spsr
    mov     sp, r0
    movs    pc, r1

.size _start, . - _start

