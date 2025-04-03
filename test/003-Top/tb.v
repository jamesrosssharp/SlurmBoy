`default_nettype none
`timescale 1ns / 1ps

module tb ();

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

    reg CLK;
    reg RSTb;

    wire [5:0] gpi;

slurmboy_top s0 (
    CLK,
    RSTb,

    /* buttons */
    gpi 

    /* Pins for external memory interfaces go here */


    /* Audio output */ 

    /* Display output */

);


endmodule
