`default_nettype none
`timescale 1ns / 1ps

module tb ();

    parameter BITS = 32;
    parameter ADDRESS_BITS = 28;

    // Clock and Reset
    reg CLK;
    reg RSTb;

    // CPU Interface
    reg  [ADDRESS_BITS - 1:0]  cpu_addr;
    reg  [BITS - 1:0]          cpu_data_in;
    wire [BITS - 1:0]          cpu_data_out;
    reg  [3:0]                 cpu_wstrb;

    reg                       cpu_wr_valid;
    wire                      cpu_wr_ready;

    reg                       cpu_rd_ready;
    wire                      cpu_rd_valid;

    // DMA Interface
    reg  [ADDRESS_BITS - 1:0] dma_addr;
    reg  [BITS - 1:0]         dma_data_in;
    wire [BITS - 1:0]         dma_data_out;
    reg  [3:0]                dma_wstrb;

    reg                       dma_rd_ready;
    wire                      dma_rd_valid;

    // Instantiate the cache module
    cache #(
        .BITS(BITS),
        .ADDRESS_BITS(ADDRESS_BITS)
    ) uut (
        .CLK(CLK),
        .RSTb(RSTb),

        .cpu_addr(cpu_addr),
        .cpu_data_in(cpu_data_in),
        .cpu_data_out(cpu_data_out),
        .cpu_wstrb(cpu_wstrb),
        .cpu_wr_valid(cpu_wr_valid),
        .cpu_wr_ready(cpu_wr_ready),
        .cpu_rd_ready(cpu_rd_ready),
        .cpu_rd_valid(cpu_rd_valid),

        .dma_addr(dma_addr),
        .dma_data_in(dma_data_in),
        .dma_data_out(dma_data_out),
        .dma_wstrb(dma_wstrb),
        .dma_rd_ready(dma_rd_ready),
        .dma_rd_valid(dma_rd_valid)
    );

    initial begin
        integer j;
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end



endmodule
