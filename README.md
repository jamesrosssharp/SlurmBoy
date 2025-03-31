# SlurmBoy
Goal: make A small handheld games console with an OLED display targeting iCE40UP5K FPGAs.

We will use PicoRV32 at first, and develop the memory interface, cache, and GPU.

Then swap out PicoRV32 for either a custom RISC-V core with configurable datapath size, or some other core, e.g. tinyQV.

We will use AXI4 Lite interconnect for our memory interface and memory mapped peripherals.

Development plan
================

- Develop boot ROM (block RAM)
- Develop external memory cache
- Develop flash interface
- Develop memory arbiter
- Interface to CPU, boot some code
- Develop PSRAM interface
- Develop GPU
