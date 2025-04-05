/* vim: set et ts=4 sw=4: */

/*
  --  -- -- ----- ---- ----  -- -- --
 / / / / / / /o )/ \/ \| o )/  \|| //
 \ \/ / / / /  (/ ^  ^ \  (  o /||//
 / /  --\  / /\ \/ \/ \/ o )  / / /
 ----------------  -- --------  --

slurmboy_top.v: top level

License: MIT License

Copyright 2023 J.R.Sharp

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

module slurmboy_top (
    input CLK,
    input RSTb,

    /* buttons */
    input  [5:0] gpi,

    /* uart */
    output uart_tx

    /* Pins for external memory interfaces go here */


    /* Audio output */ 

    /* Display output */

);


wire trap;

wire        mem_axi_awvalid;
wire        mem_axi_awready;
wire [31:0] mem_axi_awaddr;
wire [ 2:0] mem_axi_awprot;

wire        mem_axi_wvalid;
wire        mem_axi_wready;
wire [31:0] mem_axi_wdata;
wire [ 3:0] mem_axi_wstrb;

wire        mem_axi_bvalid;
wire        mem_axi_bready;

wire        mem_axi_arvalid;
wire        mem_axi_arready;
wire [31:0] mem_axi_araddr;
wire [ 2:0] mem_axi_arprot;

wire         mem_axi_rvalid;
wire         mem_axi_rready;
wire  [31:0] mem_axi_rdata;

// Pico Co-Processor Interface (PCPI)
wire        pcpi_valid;
wire [31:0] pcpi_insn;
wire [31:0] pcpi_rs1;
wire [31:0] pcpi_rs2;
reg         pcpi_wr = 1'b0;
reg  [31:0] pcpi_rd = 32'd0;
reg         pcpi_wait = 1'b0;
reg         pcpi_ready = 1'b0;

// IRQ interface
reg  [31:0] irq;
wire [31:0] eoi;

// Trace Interface
wire        trace_valid;
wire [35:0] trace_data;


picorv32_axi #(
    	.ENABLE_COUNTERS(0),
		.ENABLE_COUNTERS64(0),
		.ENABLE_REGS_16_31(0),
		.ENABLE_REGS_DUALPORT(0),
		.TWO_STAGE_SHIFT(1),
		.BARREL_SHIFTER(0),
		.TWO_CYCLE_COMPARE(0),
		.TWO_CYCLE_ALU(0),
		.COMPRESSED_ISA(0),
		.CATCH_MISALIGN(0),
		.CATCH_ILLINSN(1),
		.ENABLE_PCPI(0),
		.ENABLE_MUL(0),
		.ENABLE_FAST_MUL(0),
		.ENABLE_DIV(0),
		.ENABLE_IRQ(0),
		.ENABLE_IRQ_QREGS(1),
		.ENABLE_IRQ_TIMER(1),
		.ENABLE_TRACE(0),
		.REGS_INIT_ZERO(0),
		.MASKED_IRQ(32'h 0000_0000),
		.LATCHED_IRQ(32'h 0000_0000),
		.PROGADDR_RESET(32'h 0000_0000),
		.PROGADDR_IRQ(32'h 0000_0010),
		.STACKADDR(32'h 1000_03fc)
)
cpu0
(
	CLK, RSTb,
	trap,

	// AXI4-lite master memory interface

	mem_axi_awvalid,
	mem_axi_awready,
	mem_axi_awaddr,
	mem_axi_awprot,

	mem_axi_wvalid,
	mem_axi_wready,
	mem_axi_wdata,
	mem_axi_wstrb,

	mem_axi_bvalid,
	mem_axi_bready,

	mem_axi_arvalid,
	mem_axi_arready,
	mem_axi_araddr,
	mem_axi_arprot,

	mem_axi_rvalid,
	mem_axi_rready,
	mem_axi_rdata,

	// Pico Co-Processor Interface (PCPI)
	pcpi_valid,
	pcpi_insn,
	pcpi_rs1,
	pcpi_rs2,
	pcpi_wr,
	pcpi_rd,
	pcpi_wait,
	pcpi_ready,

	// IRQ interface
	irq,
	eoi,

	// Trace Interface
	trace_valid,
	trace_data

);

memory_controller mem0 (
    CLK,
    RSTb,

    /* AXI4 Lite device memory interface to CPU */

    mem_axi_awvalid,
	mem_axi_awready,
	mem_axi_awaddr,
	mem_axi_awprot,

	mem_axi_wvalid,
	mem_axi_wready,
	mem_axi_wdata,
	mem_axi_wstrb,

	mem_axi_bvalid,
	mem_axi_bready,

	mem_axi_arvalid,
	mem_axi_arready,
	mem_axi_araddr,
	mem_axi_arprot,

	mem_axi_rvalid,
	mem_axi_rready,
	mem_axi_rdata,

    uart_tx

);


endmodule
