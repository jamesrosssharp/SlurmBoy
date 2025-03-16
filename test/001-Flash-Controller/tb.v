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

    wire [1:0] qspi_sclk_ddr;
    wire qspi_CSb;
   
    reg  [1:0] qspi_d0_ddr_in;
    reg  [1:0] qspi_d1_ddr_in;
    reg  [1:0] qspi_d2_ddr_in;
    reg  [1:0] qspi_d3_ddr_in;

    wire [1:0] qspi_d0_ddr_out;
    wire [1:0] qspi_d1_ddr_out;
    wire [1:0] qspi_d2_ddr_out;
    wire [1:0] qspi_d3_ddr_out;

    wire [3:0] qspi_io_dir;

	reg         mem_axi_arvalid;
	wire        mem_axi_arready;
	reg  [31:0] mem_axi_araddr;
	reg  [ 2:0] mem_axi_arprot;

	wire        mem_axi_rvalid;
	reg         mem_axi_rready;
	reg  [31:0] mem_axi_rdata;

    reg         reg_axi_awvalid;
	wire        reg_axi_awready;
	reg  [31:0] reg_axi_awaddr;
	reg  [ 2:0] reg_axi_awprot;

	reg         reg_axi_wvalid;
	wire        reg_axi_wready;
	reg  [31:0] reg_axi_wdata;
	reg  [ 3:0] reg_axi_wstrb;

	wire        reg_axi_bvalid;
	reg         reg_axi_bready;

	reg         reg_axi_arvalid;
	wire        reg_axi_arready;
	reg  [31:0] reg_axi_araddr;
	reg  [ 2:0] reg_axi_arprot;

	wire        reg_axi_rvalid;
	reg         reg_axi_rready;
	reg  [31:0] reg_axi_rdata;


	flash_controller f0 (
        CLK,
        RSTb,

        qspi_sclk_ddr,
        qspi_CSb,
       
        qspi_d0_ddr_in,
        qspi_d1_ddr_in,
        qspi_d2_ddr_in,
        qspi_d3_ddr_in,

        qspi_d0_ddr_out,
        qspi_d1_ddr_out,
        qspi_d2_ddr_out,
        qspi_d3_ddr_out,

        qspi_io_dir,

        mem_axi_arvalid,
        mem_axi_arready,
        mem_axi_araddr,
        mem_axi_arprot,

        mem_axi_rvalid,
        mem_axi_rready,
        mem_axi_rdata,

        reg_axi_awvalid,
        reg_axi_awready,
        reg_axi_awaddr,
        reg_axi_awprot,

        reg_axi_wvalid,
        reg_axi_wready,
        reg_axi_wdata,
        reg_axi_wstrb,

        reg_axi_bvalid,
        reg_axi_bready,

        reg_axi_arvalid,
        reg_axi_arready,
        reg_axi_araddr,
        reg_axi_arprot,

        reg_axi_rvalid,
        reg_axi_rready,
        reg_axi_rdata

    );

endmodule
