`timescale 1ns / 1ps


/*

mode:

1'b0 for negedge
1'b1 for posedge


target = fclk / (fclkout * 2)

*/

module clock_divider(clk, reset, pause, clkout);

    input clk, reset, pause;
    
    output reg clkout;


    parameter MODE = 1'b1;
    
    
    parameter SIZE = 4;

    reg [ SIZE - 1 : 0 ] count;
    
    
    initial
    
    begin
    
        count <= 0;
        
        clkout <= MODE;
        
    end
    
                
    parameter TARGET = 2;
    
    
    always @(posedge clk, posedge reset)
    
        if (reset)
        
        begin
        
            count <= 0;
            
            clkout <= MODE;
            
        end
        
        else if (~pause)
        
        begin
        
            count <= count + 1;
        
            if (count == TARGET - 1)
            
            begin
            
                count <= 0;
                
                clkout <= ~clkout;
                
            end
                
        end

endmodule
