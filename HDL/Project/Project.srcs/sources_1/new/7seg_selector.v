`timescale 1ns / 1ps


module sevenseg_selector(clk, anode);

    input clk;
    
    
    parameter size = 2;
    
    reg [ size - 1 : 0 ] current;
    

    parameter digit = 4;
    
    output [ digit - 1 : 0 ] anode;
    
    
    reg [ digit - 1 : 0 ] anode;
    
    
    initial
    
    begin
    
        current <= 0;
    
        anode <= 'b0;
    
    end
    
    
    always @(posedge clk)
    
    begin
    
        current <= current + 1;
        
        anode <= ~(1 << current);
        
    end
    
endmodule
