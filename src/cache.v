/* vim: set et ts=4 sw=4: */

/*
  --  -- -- ----- ---- ----  -- -- --
 / / / / / / /o )/ \/ \| o )/  \|| //
 \ \/ / / / /  (/ ^  ^ \  (  o /||//
 / /  --\  / /\ \/ \/ \/ o )  / / /
 ----------------  -- --------  --

cache.v: cache for external memories 

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

module cache
#(parameter BITS = 32, parameter ADDRESS_BITS = 28) 
(
    input CLK,
    input RSTb,

    input [ADDRESS_BITS - 1:0]  addr,
    input  [BITS - 1:0]         data_in,
    output [BITS - 1:0]         data_out,
    input  [3:0]                wstrb,
    output                      cache_hit,

    input                       wr_valid,
    output reg                  wr_ready

    /* External memory port */

    axi_ext_araddr
    axi_ext_arvalid
    axi_ext_arready
    
    axi_ext_rvalid
    axi_ext_rready
    axi_ext_rdata

    axi_ext_awaddr
    axi_ext_awvalid
    axi_ext_awready

    axi_ext_bvalid
    axi_ext_bready

    axi_ext_wdata
    axi_ext_wstrb

);

wire [BITS * 2 - 1 : 0] cache_line;
wire [BITS * 2 - 1 : 0] new_cache_line = {4'b0000, addr, data_in};
reg ram_WRb = 1'b0;

assign cache_hit = (cache_line[59:32] == prev_addr);

wire [3:0] ram_wstrb = 4'd0; /* TO DO: Flip this depending on state */

wire [13:0] cache_addr = addr[15:2]; /* TO DO: This has to be rewound on cache miss */ 

ram_64x16k ram0 (
    CLK,
    RSTb,

    cache_addr,
    new_cache_line,
    cache_line,
    ram_WRb,
    ram_wstrb                     
);

reg [ADDRESS_BITS - 1:0] prev_addr;

localparam state_idle                     = 4'd0;   /* waiting for address to change */
localparam state_is_cache_hit             = 4'd1;   /* address changed, do we have a cache hit? */
localparam state_r_cache_line_evict       = 4'd2;   /* cache miss, evict cache line */
localparam state_r_cache_line_reload      = 4'd3;   /* cache miss, reload cache line */
localparam state_w_cache_hit_write        = 4'd4;   /* cache write hit, write the new cache line  */
localparam state_w_cache_line_evict       = 4'd5;   /* cache write miss, evice the old cache line */
localparam state_w_cache_line_reload      = 4'd6;   /* cache write miss, reload the cache line    */
localparam state_w_cache_line_reload_wr   = 4'd7;   /* cache write miss, write the new data       */

always @(posedge CLK)
begin
    prev_addr <= addr; // Only do this in state idle
end

/* Process for state machine, check hit miss etc. */

/* Process to evict a cache line */

/* Process to reload a cache line */


endmodule
