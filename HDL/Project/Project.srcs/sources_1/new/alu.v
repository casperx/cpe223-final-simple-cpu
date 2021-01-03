`timescale 1ns / 1ps


module alu(
    a,
    b,

    out,

    ADD,
    SUB,

    AND,
    OR,
    XOR,

    RL,
    RR,

    cin,
    cout,

    v,
    n,

    z
);

    input [ 7 : 0 ] a, b; output [ 7 : 0 ] out;


    input cin; output cout;

    output v;

    output n;

    output z;


    input ADD, SUB, AND, OR, XOR, RL, RR;


    wire [ 7 : 0 ] adder_s;

    wire adder_cout;

    wire adder_v;

    adder8 adder(a, SUB ? ~b : b, adder_s, SUB ^ cin, adder_cout, adder_v);


    assign v = (ADD | SUB) ? adder_v : 'b0;

    assign n = (ADD | SUB) ? adder_v ^ adder_s[7] : 'b0;


    assign out = (ADD | SUB) ? adder_s : 'bz, cout = (ADD | SUB) ? adder_cout : 'bz;


    assign out = AND ? a & b : 'bz;
    assign out = OR ? a | b : 'bz;
    assign out = XOR ? a ^ b : 'bz;


    // assign out = RL ? { a[6:0], cin } : 'bz, cout = RL ? a[7] : 'bz;
    assign { cout, out } = RL ? { a, cin } : 'bz;
    // assign out = RR ? { cin, a[7:1] } : 'bz, cout = RR ? a[0] : 'bz;
    assign { out, cout } = RR ? { cin, a } : 'bz;

    assign z = out == 0;

endmodule
