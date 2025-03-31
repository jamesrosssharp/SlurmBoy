`default_nettype none
`timescale 1ns / 1ps

module tb ();

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

    reg CLK;
    reg RSTb;

	reg         mem_axi_arvalid;
	wire        mem_axi_arready;
	reg  [31:0] mem_axi_araddr;
	reg  [ 2:0] mem_axi_arprot;

	reg          mem_axi_rvalid;
	wire         mem_axi_rready;
	wire  [31:0] mem_axi_rdata;

    reg         mem_axi_awvalid;
	wire        mem_axi_awready;
	reg  [31:0] mem_axi_awaddr;
	reg  [ 2:0] mem_axi_awprot;

	reg         mem_axi_wvalid;
	wire        mem_axi_wready;
	reg  [31:0] mem_axi_wdata;
	reg  [ 3:0] mem_axi_wstrb;

	wire mem_axi_bvalid;
	reg  mem_axi_bready;

memory_controller m0 (
    CLK,
    RSTb,

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
	mem_axi_rdata

);

endmodule
