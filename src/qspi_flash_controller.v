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

    /* AXI4 Lite device memory interface (to arbiter / cache) */

    /* -- Disable write lane -- 
    input         mem_axi_awvalid,
	output        mem_axi_awready,
	input  [31:0] mem_axi_awaddr,
	input  [ 2:0] mem_axi_awprot,

	input         mem_axi_wvalid,
	output        mem_axi_wready,
	input  [31:0] mem_axi_wdata,
	input  [ 3:0] mem_axi_wstrb,

	output        mem_axi_bvalid,
	input         mem_axi_bready,
    */

	input         mem_axi_arvalid,
	output        mem_axi_arready,
	input  [31:0] mem_axi_araddr,
	input  [ 2:0] mem_axi_arprot,

	input         mem_axi_rvalid,
	output        mem_axi_rready,
	output  [31:0] mem_axi_rdata,

    /* AXI4 Lite peripheral interface (for device registers) */

    input         reg_axi_awvalid,
	output  reg   reg_axi_awready,
	input  [31:0] reg_axi_awaddr,
	input  [ 2:0] reg_axi_awprot,

	input         reg_axi_wvalid,
	output reg    reg_axi_wready,
	input  [31:0] reg_axi_wdata,
	input  [ 3:0] reg_axi_wstrb,

	output reg    reg_axi_bvalid,
	input         reg_axi_bready,

	input         reg_axi_arvalid,
	output reg    reg_axi_arready,
	input  [31:0] reg_axi_araddr,
	input  [ 2:0] reg_axi_arprot,

	input         reg_axi_rvalid,
	output reg    reg_axi_rready,
	output reg [31:0] reg_axi_rdata

);

reg [1:0]  reg_sel;
reg [1:0]  rd_reg_sel;
reg [31:0] cmd;
reg [31:0] data;

/* AXI Reg writes */

task reg_write;
    input [1:0] reg_addr;
    begin
        if (reg_axi_wvalid && reg_axi_wready) begin
            case (reg_addr)
                2'b00:  /* write command register */
                    cmd <= reg_axi_wdata;   
                2'b01:  /* write data register */
                    data <= reg_axi_wdata;
                default:;    
            endcase    
            reg_axi_wready <= 1'b0; /* Assert ready on next cycle */
        end
    end        
endtask


always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        reg_axi_awready <= 1'b0;
        reg_axi_wready <= 1'b0;

    end else begin
        reg_axi_awready <= 1'b0;
        reg_axi_wready <= 1'b0;

        if (reg_axi_awvalid == 1'b1) begin  /* If we have a write to register address */
            
            if (reg_axi_wvalid == 1'b1) begin /* And if we have a simultaneous write request */
                reg_axi_wready <= 1'b1; /* Assert ready on next cycle */
            
                reg_write(reg_axi_awaddr[1:0]);    
            end

            if (reg_axi_awvalid && reg_axi_awready)
                reg_sel <= reg_axi_awaddr[1:0]; /* Store address */
            else
                reg_axi_awready <= 1'b1;    /* Assert ready on next cycle - create a "beat" */

        end else begin  /* No address write - but do we have a data write? */

           if (reg_axi_wvalid == 1'b1) begin /* we have a write request */
                reg_axi_wready <= 1'b1; /* Assert ready on next cycle */
                
                reg_write(reg_sel);    
           end
        end

    end    
end

/* AXI Reg reads */

task reg_read;
    input [1:0] reg_addr;
    begin
        case (reg_addr)
            2'b00:  /* read command register */
                reg_axi_rdata <= cmd;   
            2'b01:  /* read data register */
                reg_axi_rdata <= data;
            default:;    
        endcase    
        reg_axi_rready <= 1'b1; /* Assert ready on next cycle */
    end        
endtask


always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        reg_axi_arready <= 1'b0;
        reg_axi_rready <= 1'b0;
        reg_axi_rdata <= 32'h00000000;

    end else begin
        reg_axi_arready <= 1'b0;
        reg_axi_rready <= 1'b0;

        if (reg_axi_arvalid == 1'b1) begin  /* If we have a read from register address */
            
            if (reg_axi_rvalid == 1'b1 && reg_axi_rready == 1'b0) begin /* And if we have a simultaneous read request */
                reg_read(reg_axi_araddr[1:0]);    
            end

            if (reg_axi_arvalid && reg_axi_arready)
                rd_reg_sel <= reg_axi_araddr[1:0]; /* Store address */
            else
                reg_axi_arready <= 1'b1;    /* Assert ready on next cycle - create a "beat" */

        end else begin  /* No address write - but do we have a data write? */

           if (reg_axi_rvalid == 1'b1 && reg_axi_rready == 1'b0) begin /* we have a read request */
                reg_read(rd_reg_sel);    
           end
        end

    end    
end



endmodule
