
GEN_MEM="../../scripts/genmem.py"

all: rom.mem

rom.mem: rom.bin
	python3 $(GEN_MEM) rom.bin rom.mem

rom.bin:	rom.o
	/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -O binary rom.o rom.bin

rom.o: 	rom.s
	/opt/riscv32i/bin/riscv32-unknown-elf-as rom.s -o rom.o

clean:
	rm rom.o rom.bin rom.mem
