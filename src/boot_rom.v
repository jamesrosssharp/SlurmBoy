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

module boot_rom
#(parameter BITS = 32, parameter ADDRESS_BITS = 10) 
(
    input CLK,
    input RSTb,

    /* 1 kiB x 32 bit ROM */
    input [ADDRESS_BITS - 1:0] addr,
    output [BITS - 1:0] data,
    output reg data_valid
);

reg [BITS - 1:0] MEM [(1 << ADDRESS_BITS) - 1:0];
reg [BITS - 1:0] dout;

assign data = dout;

reg [ADDRESS_BITS - 1:0] prev_addr;

assign data_valid = (prev_addr == addr);

initial begin
        $display("Loading rom.");
        $readmemh("rom_image.mem", MEM);
end

always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin
        prev_addr <= {ADDRESS_BITS{1'b0}};
    end else begin
        prev_addr <= addr;
	    dout <= MEM[addr];
    end
end

endmodule
