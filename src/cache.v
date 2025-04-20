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

    /* Port to CPU */

    input [ADDRESS_BITS - 1:0]  cpu_addr,
    input  [BITS - 1:0]         cpu_data_in,
    output [BITS - 1:0]         cpu_data_out,
    input  [3:0]                cpu_wstrb,

    input                       cpu_wr_valid,
    output reg                  cpu_wr_ready,

    input                       cpu_rd_ready,
    output reg                  cpu_rd_valid,

    /* DMA port - DMA is read only */

    input [ADDRESS_BITS - 1:0]  dma_addr,
    input  [BITS - 1:0]         dma_data_in,
    output [BITS - 1:0]         dma_data_out,
    input  [3:0]                dma_wstrb,

    input                       dma_rd_ready,
    output reg                  dma_rd_valid

    /* External memory ports */


);

wire [BITS * 2 - 1 : 0] cache_line;
wire [BITS * 2 - 1 : 0] new_cache_line = {4'b0000, cpu_addr, cpu_data_in};
reg ram_WRb = 1'b0;

assign cache_hit = (cache_line[59:32] == prev_addr);

assign cpu_data_out = cache_line[31:0];

wire [3:0] ram_wstrb = 4'd0; /* TO DO: Flip this depending on state */

wire [13:0] cache_addr = cpu_addr[15:2]; /* TO DO: This has to be rewound on cache miss */ 

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

localparam state_idle                     = 4'd0;   /* waiting for address to change              */
localparam state_cpu_r_is_cache_hit           = 4'd1;   /* read requested, do we have a cache hit?    */
localparam state_cpu_r_cache_line_evict       = 4'd2;   /* cache miss, evict cache line               */
localparam state_cpu_r_cache_line_reload      = 4'd3;   /* cache miss, reload cache line              */
localparam state_cpu_w_is_cache_hit           = 4'd4;   /* write requested, do we have a cache hit?   */
localparam state_cpu_w_cache_hit_write        = 4'd5;   /* cache write hit, write the new cache line  */
localparam state_cpu_w_cache_line_evict       = 4'd6;   /* cache write miss, evice the old cache line */
localparam state_cpu_w_cache_line_reload      = 4'd7;   /* cache write miss, reload the cache line    */
localparam state_cpu_w_cache_line_reload_wr   = 4'd8;   /* cache write miss, write the new data       */

reg [3:0] state = state_idle;

always @(posedge CLK)
begin
    prev_addr <= cpu_addr; // Only do this in state idle
end

/* Process for state machine, check hit miss etc. */

reg go_evict_cacheline = 1'b0;

always @(posedge CLK)
begin
    if (RSTb == 1'b0) begin

        state <= state_idle;

    end else begin
        cpu_rd_valid <= 1'b0;    
        case (state)
            state_idle: begin
                if (cpu_rd_ready == 1'b1)
                    state <= state_cpu_r_is_cache_hit;
                else if (cpu_wr_valid == 1'b1)
                    state <= state_cpu_w_is_cache_hit;
            end    
            state_cpu_r_is_cache_hit: begin
                if (cache_hit == 1'b1) begin    /* Cache hit, we can tell the CPU that the memory is valid */
                    cpu_rd_valid <= 1'b1;
                    state <= state_idle;     
                end   
                else begin
                    state <= state_cpu_r_cache_line_evict;
                end 
            end
            default:
                state <= state_idle;
        endcase

    end

end

/* Process to evict a cache line */

/* Process to reload a cache line */


endmodule
