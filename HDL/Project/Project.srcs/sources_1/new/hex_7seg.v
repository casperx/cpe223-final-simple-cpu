`timescale 1ns / 1ps


module hex_sevenseg(q, dot, anode, seg);

    input [ 3 : 0 ] q;
    
    input dot;
    
    
    input anode;
    
    
    output [ 7 : 0 ] seg;
    
    
    reg [ 6 : 0 ] buff;


    always @(q)
            
        case (q)
        
            4'h0 : buff <= 7'b1111110;
            4'h1 : buff <= 7'b0110000;
            4'h2 : buff <= 7'b1101101;
            4'h3 : buff <= 7'b1111001;
            4'h4 : buff <= 7'b0110011;
            4'h5 : buff <= 7'b1011011;
            4'h6 : buff <= 7'b1011111;
            4'h7 : buff <= 7'b1110000;
            4'h8 : buff <= 7'b1111111;
            4'h9 : buff <= 7'b1111011;
            4'hA : buff <= 7'b1110111;
            4'hB : buff <= 7'b0011111;
            4'hC : buff <= 7'b1001110;
            4'hD : buff <= 7'b0111101;
            4'hE : buff <= 7'b1001111;
            4'hF : buff <= 7'b1000111;
            
        endcase
            
    // 0 = Light, 1 = Dark
    
    assign seg = ~anode ? {~dot, ~buff} : 'bz;
    
endmodule
