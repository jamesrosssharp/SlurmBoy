# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../../src
PROJECT_SOURCES = memory_controller.v	\
				  boot_rom.v			\
				  scratchpad_ram.v		\
				  slurmboy_top.v

SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

VERILOG_SOURCES += $(PWD)/tb.v

VERILOG_SOURCES += $(PWD)/../../modules/picorv32/picorv32.v

TOPLEVEL = tb

MODULE = test

GEN_MEM="$(PWD)/../../scripts/genmem.py"

.PHONY: my_all
my_all: rom_image.mem all

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: view
view:	tb.vcd config.gtkw 
	gtkwave tb.vcd config.gtkw

rom_image.mem: rom.bin
	python3 $(GEN_MEM) rom.bin rom_image.mem

rom.bin:	rom.o
	/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -O binary rom.o rom.bin

rom.o: 	rom.s
	/opt/riscv32i/bin/riscv32-unknown-elf-as rom.s -o rom.o


