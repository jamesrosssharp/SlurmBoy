`default_nettype none
`timescale 1ns / 1ps

module tb ();

    localparam BAUD_TICK = 1e9/115200;

    reg [7:0] UART_BYTE = 8'h00;
    reg UART_VALID = 1'b0;

    integer i;
    always begin
        @(negedge uart_tx);
        UART_VALID <= 1'b0;
        #(BAUD_TICK/2); // start bit
        UART_BYTE <= 8'h00;
        for (i = 0; i < 8; i += 1) begin
            #BAUD_TICK; // bits
            UART_BYTE <= {uart_tx, UART_BYTE[7:1]};	
        end
        #BAUD_TICK; // stop bit
        UART_VALID <= 1'b1;
    end

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

    wire uart_tx;

slurmboy_top s0 (
    CLK,
    RSTb,

    /* buttons */
    gpi,

    uart_tx 


);



endmodule
