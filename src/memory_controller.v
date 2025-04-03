/* vim: set et ts=4 sw=4: */

/*
	$PROJECT

$FILE: $DESC

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

module memory_controller (
    input CLK,
    input RSTb,

    /* AXI4 Lite device memory interface to CPU */

    input         mem_axi_awvalid,
	output reg    mem_axi_awready,
	input  [31:0] mem_axi_awaddr,
	input  [ 2:0] mem_axi_awprot,

	input         mem_axi_wvalid,
	output reg    mem_axi_wready,
	input  [31:0] mem_axi_wdata,
	input  [ 3:0] mem_axi_wstrb,

	output        mem_axi_bvalid,
	input         mem_axi_bready,

	input         mem_axi_arvalid,
	output reg    mem_axi_arready,
	input  [31:0] mem_axi_araddr,
	input  [ 2:0] mem_axi_arprot,

	input             mem_axi_rvalid,
	output reg        mem_axi_rready,
	output reg [31:0] mem_axi_rdata

);

reg  [31:0] rd_addr;    /* the read address */
reg  [31:0] wr_addr;    /* the write address */
wire [31:0] rom_data;
wire [31:0] scratchpad_data_out;
wire rom_valid;

reg  scratchpad_write_b; /* the write flag to the scratchpad */

boot_rom rom0
(
    CLK,
    RSTb,

    rd_addr[11:2],
    rom_data,
    rom_valid
);

scratchpad_ram ram0
(
    CLK,
    RSTb,

    rd_addr[11:2],
    wr_addr[11:2],
    mem_axi_wdata,
    scratchpad_data_out,
    scratchpad_write_b
);


/* Process memory reads */

localparam state_r_idle                = 4'd0;
localparam state_r_latch_address       = 4'd1;
localparam state_r_wait_data_valid     = 4'd2;
localparam state_r_ready               = 4'd3;
localparam state_r_done                = 4'd4;

reg [3:0] state_r;

always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        state_r           <= state_r_idle;
        mem_axi_arready <= 1'b0;
    end else begin
        mem_axi_arready <= 1'b0;
        mem_axi_rready  <= 1'b0;

        case (state_r)
            state_r_idle: begin
                if (mem_axi_arvalid == 1'b1) begin
                    state_r <= state_r_latch_address;
                    mem_axi_arready <= 1'b1;
                end
            end
            state_r_latch_address: begin
                rd_addr <= mem_axi_araddr;       
                state_r <= state_r_wait_data_valid;
            end
            state_r_wait_data_valid: begin
                if (mem_axi_rvalid == 1'b1) begin
                    case (rd_addr[31:28])
                        4'd0: begin /* ROM */
                            if (rom_valid == 1'b1) begin
                                mem_axi_rdata <= rom_data;
                                state_r <= state_r_ready;
                            end
                        end
                        4'd1: begin /* Scratch pad RAM */
                            if (rom_valid == 1'b1) begin // HACK: If ROM is valid, scratchpad is too...
                                mem_axi_rdata <= scratchpad_data_out;
                                state_r <= state_r_ready;
                            end
                        end
                        default: begin
                            mem_axi_rdata <= 32'hdeadbeef;
                            state_r <= state_r_ready;
                        end    
                    endcase
                end
            end
            state_r_ready: begin
                mem_axi_rready <= 1'b1;
                state_r <= state_r_done;
            end
            state_r_done: begin
                if (mem_axi_rvalid == 1'b0)
                    state_r <= state_r_idle;
            end
        endcase
    end

end


/* Process memory writes */

localparam state_w_idle                = 4'd0;
localparam state_w_latch_address       = 4'd1;
localparam state_w_wait_data_valid     = 4'd2;
localparam state_w_done                = 4'd4;

reg [3:0] state_w;

always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        state_w           <= state_w_idle;
        mem_axi_awready <= 1'b0;
        scratchpad_write_b <= 1'b1;  
    end else begin
        mem_axi_awready <= 1'b0;
        mem_axi_wready  <= 1'b0;
        scratchpad_write_b <= 1'b1;  

        case (state_w)
            state_w_idle: begin
                if (mem_axi_awvalid == 1'b1) begin
                    state_w <= state_w_latch_address;
                    mem_axi_awready <= 1'b1;
                end
            end
            state_w_latch_address: begin
                wr_addr <= mem_axi_awaddr;     
                state_w <= state_w_wait_data_valid;
            end
            state_w_wait_data_valid: begin
                if (mem_axi_wvalid == 1'b1) begin
                    case (wr_addr[31:28])
                        4'd0: begin /* ROM */
                              state_w <= state_w_done;
                              mem_axi_wready <= 1'b1;
                        end
                        4'd1: begin /* Scratch pad RAM */
                              scratchpad_write_b <= 1'b0;  
                              mem_axi_wready <= 1'b1;
                              state_w <= state_w_done;
                        end
                        default: begin
                              state_w <= state_w_done;
                              mem_axi_wready <= 1'b1;
                        end    
                    endcase
                end
            end
            state_w_done: begin
                if (mem_axi_wvalid == 1'b0)
                    state_w <= state_w_idle;
            end
        endcase
    end

end




endmodule
