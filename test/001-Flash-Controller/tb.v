`default_nettype none
`timescale 1ns / 1ps

module tb ();

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

    // Clock and reset
    reg CLK;
    reg RSTb;

    // QSPI Interface
    wire [1:0] qspi_sclk_ddr;
    wire       qspi_CSb;

    reg  [1:0] qspi_d0_ddr_in;
    reg  [1:0] qspi_d1_ddr_in;
    reg  [1:0] qspi_d2_ddr_in;
    reg  [1:0] qspi_d3_ddr_in;

    wire [1:0] qspi_d0_ddr_out;
    wire [1:0] qspi_d1_ddr_out;
    wire [1:0] qspi_d2_ddr_out;
    wire [1:0] qspi_d3_ddr_out;

    wire [3:0] qspi_io_dir;

    // Register interface
    reg  [1:0]  reg_addr;
    wire [31:0] reg_data_out;
    reg  [31:0] reg_data_in;

    reg  reg_WR_valid;
    wire reg_WR_ready;

    reg  reg_RD_ready;
    wire reg_RD_valid;

    // Memory mapped interface
    reg  [23:0] mem_addr;
    wire [31:0] mem_data_out;
    reg  [31:0] mem_data_in;

    reg  mem_RD_ready;
    wire mem_RD_valid;

    // Instantiate the DUT
    flash_controller dut (
        .CLK(CLK),
        .RSTb(RSTb),

        .qspi_sclk_ddr(qspi_sclk_ddr),
        .qspi_CSb(qspi_CSb),

        .qspi_d0_ddr_in(qspi_d0_ddr_in),
        .qspi_d1_ddr_in(qspi_d1_ddr_in),
        .qspi_d2_ddr_in(qspi_d2_ddr_in),
        .qspi_d3_ddr_in(qspi_d3_ddr_in),

        .qspi_d0_ddr_out(qspi_d0_ddr_out),
        .qspi_d1_ddr_out(qspi_d1_ddr_out),
        .qspi_d2_ddr_out(qspi_d2_ddr_out),
        .qspi_d3_ddr_out(qspi_d3_ddr_out),

        .qspi_io_dir(qspi_io_dir),

        .reg_addr(reg_addr),
        .reg_data_out(reg_data_out),
        .reg_data_in(reg_data_in),

        .reg_WR_valid(reg_WR_valid),
        .reg_WR_ready(reg_WR_ready),

        .reg_RD_ready(reg_RD_ready),
        .reg_RD_valid(reg_RD_valid),

        .mem_addr(mem_addr),
        .mem_data_out(mem_data_out),
        .mem_data_in(mem_data_in),

        .mem_RD_ready(mem_RD_ready),
        .mem_RD_valid(mem_RD_valid)
    );

endmodule
