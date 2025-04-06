/* vim: set et ts=4 sw=4: */

/*
  --  -- -- ----- ---- ----  -- -- --
 / / / / / / /o )/ \/ \| o )/  \|| //
 \ \/ / / / /  (/ ^  ^ \  (  o /||//
 / /  --\  / /\ \/ \/ \/ o )  / / /
 ----------------  -- --------  --

ram_64x16k: 64 bit x 16k single port RAM block

This is a place holder for simulation, in iCE40
implementation we 

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

module ram_64x16k
#(parameter BITS = 64, parameter ADDRESS_BITS = 14) 
(
    input CLK,
    input RSTb,

    input  [ADDRESS_BITS - 1:0] addr,
    input  [BITS - 1:0]         data_in,
    output reg [BITS - 1:0]     data_out,
    input                       WRb,
    input  [3:0]                wstrb                     
);

reg [BITS - 1:0] MEM [(1 << ADDRESS_BITS) - 1:0];

always @(posedge CLK)
begin
    if (WRb == 1'b0)
    begin
        if (wstrb[0])    
            MEM[addr][7:0] <= data_in[7:0];
        if (wstrb[1])    
            MEM[addr][15:8] <= data_in[15:8];
        if (wstrb[2])    
            MEM[addr][23:16] <= data_in[23:16];
        if (wstrb[3])    
            MEM[addr][31:24] <= data_in[31:24];
    end
    data_out <= MEM[addr];

end



endmodule
