ENTRY(_start)

SECTIONS {
    /* QEMU loads the kernel in Flash here. I strongly suggest you look at the
     * memory map provided in the CoreTile TRM (see below).
     */
    . = 0x80010000;

    /* Make sure our entry stub goes first */
    .stub   : { _start.o(.text) }
    .text   : { *(.text) }
    .rodata : { *(.rodata) }
    .data   : { *(.data) }
    .bss    : { *(.bss COMMON) }

    STACK_BASE = .;
    . += 0x1000;
    __irq_stack_top__ = .;
    . += 0x1000;
    __fiq_stack_top__ = .;
    . += 0x1000;
    __svc_stack_top__ = .;
    . += 0x1000;
    __und_stack_top__ = .;
    . += 0x1000;
    __abt_stack_top__ = .;
    . += 0x1000;
    __sys_stack_top__ = .;
    . += 0x1000;
    __usr_stack_top__ = .;
    . += 0x1000;
}
