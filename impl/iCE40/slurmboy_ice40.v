module top
(
	output UART_TX,

	input CLK12

);

wire clk;

localparam CLOCKFREQ = 25125000;
wire locked;

SB_PLL40_PAD #(
   .FEEDBACK_PATH("SIMPLE"),
   .PLLOUT_SELECT("GENCLK"),
   .DIVR(4'b0000),
   .DIVF(7'b1000010),
   .DIVQ(3'b101),
   .FILTER_RANGE(3'b001),
 ) SB_PLL40_CORE_inst (
   .RESETB(1'b1),
   .BYPASS(1'b0),
   .PACKAGEPIN(CLK12),
   .PLLOUTCORE(clk),
);

reg [20:0] COUNT = 0;
wire RSTb = (COUNT < 10000) ? 1'b0 : 1'b1;

always @(posedge clk)
begin
	if (COUNT < 100000)
		COUNT <= COUNT + 1;	
end

reg [5:0] gpi = 6'd0;

slurmboy_top #(.CLK_FREQ(CLOCKFREQ)) s0 (
    clk,
    RSTb,

    /* buttons */
    gpi,

    UART_TX 
);



endmodule
