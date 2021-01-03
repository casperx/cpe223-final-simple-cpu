`timescale 1ns / 1ps


module file(clk, rs, rd, in, out, rs_enable, rd_enable, rd_load, rs_out, rd_out);

    input clk;
    
    parameter ADDR_SIZE = 4;
    
    parameter DATA_SIZE = 8;
    
    
    input [ ADDR_SIZE - 1 : 0 ] rs, rd;
    
    input [ DATA_SIZE - 1 : 0 ] in;
    output [ DATA_SIZE - 1 : 0 ] out;
    
    output [ DATA_SIZE - 1 : 0 ] rs_out, rd_out;
    
    
    input rs_enable, rd_enable, rd_load;
    
    
    localparam SIZE = 1 << ADDR_SIZE;
    
    parameter START = 0, END = SIZE - 1;
    
    reg [ DATA_SIZE - 1 : 0 ] memory [ END : START ];
    
    
    always @(posedge clk)
    
    begin
    
        if (rd_load)
        
            memory[rd] <= in;
    
    end
    
    
    assign rs_out = memory[rs];
    assign rd_out = memory[rd];
    
    
    assign out = rs_enable ? rs_out : 'bz;
    assign out = rd_enable ? rd_out : 'bz;

endmodule
