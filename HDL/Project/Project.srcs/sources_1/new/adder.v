`timescale 1ns / 1ps


module halfadder(a, b, s, c);

    input a, b; output s;
    
    output c;
    
    
    assign s = a ^ b;
    
    assign c = a & b;

endmodule


module adder(a, b, s, cin, cout);

    input a, b;
    
    output s;
    
    input cin;
    output cout;
    
    wire s0, c0;
    
    halfadder halfadder0(a, b, s0, c0);
    
    wire c1;
    
    halfadder halfadder1(s0, cin, s, c1);
    
    assign cout = c0 | c1;

endmodule


module adder8(a, b, s, cin, cout, v);

    input [ 7 : 0 ] a, b; output [ 7 : 0 ] s;
    
    input cin; output cout;
    
    output v;
    
    wire c1, c2, c3, c4, c5, c6, c7;
    
    adder adder0(a[0], b[0], s[0], cin, c1);
    adder adder1(a[1], b[1], s[1], c1, c2);
    adder adder2(a[2], b[2], s[2], c2, c3);
    adder adder3(a[3], b[3], s[3], c3, c4);
    adder adder4(a[4], b[4], s[4], c4, c5);
    adder adder5(a[5], b[5], s[5], c5, c6);
    adder adder6(a[6], b[6], s[6], c6, c7);
    adder adder7(a[7], b[7], s[7], c7, cout);
    
    assign v = cout ^ c7;

endmodule