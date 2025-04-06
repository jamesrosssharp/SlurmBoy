PROJ 	= slurmboy_ice40
PIN_DEF = slurmboy_ice40.pcf
DEVICE 	= up5k

SRCDIR=../../src

SOURCE = slurmboy_ice40.v 	\
		 $(SRCDIR)/memory_controller.v	\
		 $(SRCDIR)/scratchpad_ram.v	\
		 $(SRCDIR)/boot_rom.v	\
		 $(SRCDIR)/uart.v	\
		 $(SRCDIR)/uart_tx.v	\
		 $(SRCDIR)/baudgen.v	\
		 $(SRCDIR)/slurmboy_top.v	\
		 ../../modules/picorv32/picorv32.v

ICEPACK = icepack
ICETIME = icetime
ICEPROG = iceprog

all: $(PROJ).bin

$(PROJ).json: $(SOURCE) rom_image.mem
	yosys -p 'debug synth_ice40 -top top -json $@' $(SOURCE)

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --freq 25.125 --up5k --json $(PROJ).json --pcf $(PROJ).pcf --asc $@

%.bin: %.asc
	$(ICEPACK) $< $@

%.rpt: %.asc
	$(ICETIME) -d $(DEVICE) -mtr $@ $<

prog: $(PROJ).bin
	$(ICEPROG) -S $(PROJ).bin

sudo-prog: $(PROJ).bin
	@echo 'Executing prog as root!!!'
	sudo $(ICEPROG) -S $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).rpt $(PROJ).bin $(PROJ).h 

.SECONDARY:
.PHONY: all prog clean
