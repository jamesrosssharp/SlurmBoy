`default_nettype none
`timescale 1ns / 1ps

module tb ();

    initial begin
        integer j;
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        for (j = 0; j < 16; j = j + 1) begin
            $dumpvars(0, s0.cpu0.picorv32_core.cpuregs[j]);
        end
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
