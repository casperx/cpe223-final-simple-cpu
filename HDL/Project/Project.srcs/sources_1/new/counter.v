`timescale 1ns / 1ps


module counter(clk, reset, in, out, count, enable, load);

    input clk, reset;


    parameter SIZE = 1;

    input [ SIZE - 1 : 0 ] in; 
    output [ SIZE - 1 : 0 ] out;

    input count, enable, load;

    
    reg [ SIZE - 1 : 0 ] buff;
    
    
    initial
    
        buff <= 0;


    always @(posedge clk, posedge reset)
    
        if (reset) 
        
            buff <= 0;
            
        else if (count) 
            
            buff <= buff + 1;
            
        else if (load)
        
            buff <= in;
            
            
    assign out = enable ? buff : 'bz;

endmodule
