`timescale 1ns / 1ns


// single-port RAM

module ram(clk, addr, in, out, enable, load);

    input clk;
    
    input enable, load;
    
    
    parameter ADDR_SIZE = 8;
    
    parameter DATA_SIZE = 8;
    
    
    input [ ADDR_SIZE - 1 : 0 ] addr;
    
    input [ DATA_SIZE - 1 : 0 ] in;
    output [ DATA_SIZE - 1 : 0 ] out;
    
    
    parameter SIZE = 1 << ADDR_SIZE;
    
     reg [ DATA_SIZE - 1 : 0 ] memory [ SIZE - 1 : 0 ];
    
    
    initial
    
        $readmemb("ram.mem", memory);
    
    
    always @(posedge clk)
    
    begin
    
        if (load)
        
            memory[addr] <= in;
        
    end
    
    
    assign out = enable ? memory[addr] : 'bz;
            
endmodule
