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
	output        mem_axi_awready,
	input  [31:0] mem_axi_awaddr,
	input  [ 2:0] mem_axi_awprot,

	input         mem_axi_wvalid,
	output        mem_axi_wready,
	input  [31:0] mem_axi_wdata,
	input  [ 3:0] mem_axi_wstrb,

	output        mem_axi_bvalid,
	input         mem_axi_bready,

	input         mem_axi_arvalid,
	output reg    mem_axi_arready,
	input  [31:0] mem_axi_araddr,
	input  [ 2:0] mem_axi_arprot,

	input          mem_axi_rvalid,
	output         mem_axi_rready,
	output  [31:0] mem_axi_rdata

);

reg  [31:0] rd_addr;
wire [31:0] rom_data;
wire rom_valid;

boot_rom rom0
(
    CLK,
    RSTb,

    rd_addr[11:2],
    rom_data,
    rom_valid
);

/* Process memory reads */


reg [31:0] mem_rdata;
reg mem_rready;

assign mem_axi_rdata = mem_rdata;
assign mem_axi_rready = mem_rready;

task reg_read;
    input [1:0] reg_addr;
    begin
        case (reg_addr[31:28])
            4'b0000: begin /* read ROM space */
                mem_rdata <= rom_data;   
                mem_rready <= rom_valid;
            end    
            4'b0001:  /* read cacheable memory - SRAM */
            4'b0010:  /* QSPI flash                   */
            default:;    
        endcase    
    end        
endtask

always @(posedge CLK)
begin

    if (RSTb == 1'b0) begin
        mem_axi_arready <= 1'b0;
        mem_rready <= 1'b0;
        mem_rdata <= 32'h00000000;

    end else begin
        mem_axi_arready <= 1'b0;
        mem_rready <= 1'b0;

        if (mem_axi_arvalid == 1'b1) begin  /* If we have a read from register address */
            
            if (mem_axi_rvalid == 1'b1 && mem_axi_rready == 1'b0) begin /* And if we have a simultaneous read request */
                reg_read(mem_axi_araddr);    
            end

            if (mem_axi_arvalid && mem_axi_arready)
                rd_addr <= reg_axi_araddr; /* Store address */
            else
                reg_axi_arready <= 1'b1;    /* Assert ready on next cycle - create a "beat" */

        end else begin  /* No address write - but do we have a data write? */

           if (mem_axi_rvalid == 1'b1 && mem_rready == 1'b0) begin /* we have a read request */
                reg_read(rd_addr);    
           end
        end

    end 

end    

