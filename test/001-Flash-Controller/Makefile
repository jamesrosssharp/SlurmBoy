# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../../src
PROJECT_SOURCES = qspi_flash_controller.v 

SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS 		+= -I$(SRC_DIR)

VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

MODULE = test

include $(shell cocotb-config --makefiles)/Makefile.sim

.PHONY: view
view:	tb.vcd config.gtkw 
	gtkwave tb.vcd config.gtkw
