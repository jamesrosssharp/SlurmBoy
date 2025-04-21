/* vim: set et ts=4 sw=4: */

/*
	SlurmBoy

qspi_flash_controller.v: QSPI Flash controller

License: MIT License

Copyright 2025 J.R.Sharp

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

module flash_controller (
    input CLK,
    input RSTb,

    /* QSPI interface is to DDR IOs */

    output [1:0] qspi_sclk_ddr,
    output qspi_CSb,
   
    input  [1:0] qspi_d0_ddr_in,
    input  [1:0] qspi_d1_ddr_in,
    input  [1:0] qspi_d2_ddr_in,
    input  [1:0] qspi_d3_ddr_in,

    output reg [1:0] qspi_d0_ddr_out,
    output reg [1:0] qspi_d1_ddr_out,
    output reg [1:0] qspi_d2_ddr_out,
    output reg [1:0] qspi_d3_ddr_out,

    /* data direction */
    output reg [3:0] qspi_io_dir,

    /* Register interface */

    input   [1:0] reg_addr,
    output reg [31:0] reg_data_out,
    input  [31:0] reg_data_in,

    input  reg_WR_valid,
    output reg reg_WR_ready,

    input  reg_RD_ready,
    output reg reg_RD_valid,

    /* memory mapped interface */

    input  [23:0] mem_addr,
    output [31:0] mem_data_out,
    input  [31:0] mem_data_in,

    input  mem_RD_ready,
    output reg mem_RD_valid

);

reg [31:0] cmd_reg;
reg [31:0] data_wr_reg;
reg [31:0] data_rd_reg;


/* Register reads */
always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        reg_RD_valid <= 1'b0;
    end else begin
        reg_RD_valid <= 1'b0;
    
        if (reg_RD_ready == 1'b1 && reg_RD_valid == 1'b0) begin
            case (reg_addr)
                2'b00:  begin /* command reg */
                    reg_data_out <= cmd_reg;
                    reg_RD_valid <= 1'b1;
                end
                2'b01:  begin /* data wr reg */
                    reg_data_out <= data_wr_reg;
                    reg_RD_valid <= 1'b1;
                end
                2'b10: begin /* data rd reg */
                    reg_data_out <= data_rd_reg;
                    reg_RD_valid <= 1'b1;
                end
                default:
                    reg_RD_valid <= 1'b1;
            endcase    
        end    
    end    
end

/* Register writes */
always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        cmd_reg <= 32'd0;
        data_wr_reg <= 32'd0;
        reg_WR_ready <= 1'b0;
    end else begin
        reg_WR_ready <= 1'b0;
    
        if (reg_WR_valid == 1'b1 && reg_WR_ready == 1'b0) begin
            case (reg_addr)
                2'b00:  begin /* command reg */
                    cmd_reg <= reg_data_in;
                    reg_WR_ready <= 1'b1;
                end
                2'b01:  begin /* data wr reg */
                    data_wr_reg <= reg_data_in;
                    reg_WR_ready <= 1'b1;
                end
                default:
                    reg_WR_ready <= 1'b1;
            endcase    
        end    
    end    
end




endmodule
