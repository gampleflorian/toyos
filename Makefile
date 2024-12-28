all: start.bin

_start.o: _start.s gic.s
	arm-none-eabi-as -mcpu=cortex-a15 -g _start.s gic.s -o _start.o

task.o: task.c
	arm-none-eabi-gcc -ffreestanding -c -mcpu=cortex-a15 -g task.c -o task.o

uart.o: uart.c
	arm-none-eabi-gcc -ffreestanding -c -mcpu=cortex-a15 -g uart.c -o uart.o

start.o: start.c
	arm-none-eabi-gcc -ffreestanding -c -mcpu=cortex-a15 -g start.c -o start.o

start.elf: start.o _start.o uart.o task.o
	arm-none-eabi-ld -T start.ld start.o _start.o uart.o task.o -o start.elf

start.bin: start.elf
	arm-none-eabi-objcopy -O binary start.elf start.bin

qemu-gdb: $(TARGET)
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo
	qemu-system-arm -M vexpress-a15 -cpu cortex-a15 -nographic -s -kernel start.bin -S

qemu: $(TARGET)
	@echo "Press Ctrl-A and then X to exit QEMU"
	@echo
	qemu-system-arm -M vexpress-a15 -cpu cortex-a15 -nographic -s -kernel start.bin


clean:
	rm -f *.o *.bin *.elf *.list
