module debouncer(clk, reset, in, out);

    input clk, reset, in;

    output out;

    wire slowclk;

    reg stage, out;

    clock_divider #(1'b1, 32, 50) (clk, reset, 1'b0, slowclk); // posedge, 100 MHz -> 1 MHz

    always @(posesge slowclk)

        { out, stage } <= { stage, in }

endmodule