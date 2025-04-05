
CFLAGS=-c -mabi=ilp32 -march=rv32ic -Os --std=c99 -ffreestanding -nostdlib

rom.bin:	rom.o
	/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -O binary rom.o rom.bin

rom.o:		link.ld rom.so rom.co
	/opt/riscv32i/bin/riscv32-unknown-elf-ld -T link.ld rom.so rom.co -o rom.o

rom.so: 	rom.s
	/opt/riscv32i/bin/riscv32-unknown-elf-as -mabi=ilp32 -march=rv32ic rom.s -o rom.so

rom.co: 	rom.c
	/opt/riscv32i/bin/riscv32-unknown-elf-gcc $(CLAGS) rom.c -c -o rom.co

clean:
	rm -rf rom.co rom.so rom.bin
