.equ GIC_DIST, 0x1000
.equ GIC_CPU , 0x2000

// GIC Definitions for CPU interface
.equ ICCICR  , 0x00
.equ ICCPMR  , 0x04
.equ ICCEOIR , 0x10
.equ ICCIAR  , 0x0C

// GIC Definitions for Distributor interface
.equ ICDDCR  , 0x00
.equ ICDISER , 0x100
.equ ICDIPTR , 0x800

.global GIC_dist_base
GIC_dist_base : .word 0 // address of GIC distributor
.global GIC_cpu_base
GIC_cpu_base  : .word 0 // address of GIC CPU interface

.global get_gic_base
get_gic_base:
   stmfd sp!,{r4-r5, lr}
   // get GIC base address
   mrc p15, 4, r0, c15, c0, 0

   // add distributor offset to GIC base
   add r2, r0, #GIC_DIST
   ldr r1, =GIC_dist_base
   str r2,[r1] // Store address of GIC distributor

   // add cpu interface offset to GIC base
   add r2, r0, #GIC_CPU // Calculate address
   ldr r1, =GIC_cpu_base
   str r2,[r1] // Store address of GIC CPU interface

   ldmfd sp!, {r4-r5, lr}

//config_interrupt (int ID , int CPU);
.global config_interrupt
config_interrupt:
    stmfd sp!,{r4-r5, lr}

    // Configure the distributor interrupt set-enable registers (ICDISERn)
    // enable the intterupt
    // reg_offset = (M/32)*4 (shift and clear some bits)
    // value = 1 << (N mod 32);
    ldr r2,=GIC_dist_base
    ldr r2,[r2] // Read GIC distributor base address
    add r2,r2,#ICDISER // r2 <- base address of ICDSER regs
    lsr r4,r0,#3 // calculate reg_offset
    bic r4,r4,#3 // r4 <- reg_offset
    add r4,r2,r4 // r4 <- address of ICDISERn

    // Create a bit mask
    and r2,r0,#0x1F // r2 <- N mod 32
    mov r5,#1 // need to set one bit
    lsl r2,r5,r2 // r2 <- value

    // Using address in r4 and value in r2 to set the correct bit in the GIC register
    ldr r3,[r4] // read ICDISERn
    orr r3, r3, r2 // set the enable bit
    str r3,[r4]  // store the new register value

    // Configure the distributor interrupt processor targets register (ICDIPTRn)
    // select target CPU(s)
    // reg_offset = (N/4)*4 (clear 2 bottom bits)
    // index = N mod 4;
    ldr r2,=GIC_dist_base
    ldr r2,[r2] // Read GIC distributor base address
    add r2,r2, #ICDIPTR // base address of ICDIPTR regs
    bic r4,r0,#3 // r4 <- reg_offset
    add r4,r2,r4 // r4 <- address of ICDIPTRn

    // Get the address of th ebyte wihtih ICDIPTRn
    and r2,r0,#0x3 // r2 <- index
    add r4,r2,r4 // r4 <- byte address to be set
    strb r1,[r4]

    ldmfd sp!, {r4-r5, lr}

// int get_inLerrupt_number();
// Get the interrupt ID for the current interrupt. This should be called al the
// beginning of ISR. It also changes the state of the interrupt from pending to
// active, which helps to prevent other CPUs from trying to handle it.
.global get_interrupt_number
get_interrupt_number:
    // Read the ICCIAR from the CPU Interface
    ldr r0,=GIC_cpu_base
    ldr r0,[r0]
    ldr r0,[r0,#ICCIAR]
    mov pc,lr

// void end_of_interrupt (int ID);
// Notify the GIC that the interrupt has been processed. The state goes from
// active to inactive, or it goes from active and pending to pending.
.global end_of_interrupt
end_of_interrupt:
    ldr r1,=GIC_cpu_base
    ldr r1,[r1]
    str r0,[r1,#ICCEOIR]
    mov pc, lr


