`timescale 1ns / 1ps


module register(clk, reset, in, out, enable, load);

    input clk, reset;


    parameter SIZE = 1;

    input [ SIZE - 1 : 0 ] in; 
    output [ SIZE - 1 : 0 ] out;

    input enable, load;

    
    reg [ SIZE - 1 : 0 ] buff;
    
    
    initial
    
        buff <= 0;


    always @(posedge clk, posedge reset)
    
        if (reset) 
        
            buff <= 0;
            
        else if (load)
            
            buff <= in;
    
    
    assign out = enable ? buff : 'bz;

endmodule
