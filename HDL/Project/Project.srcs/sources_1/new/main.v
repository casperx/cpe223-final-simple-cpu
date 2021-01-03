`timescale 1ns / 1ns


module main(sysclk, reset, anode, seg);

    input sysclk, reset;
    
    
    // clock divider
    
    (* dont_touch = "true" *) wire pause;
    
    wire clk; 
    
    clock_divider #(1'b0, 32, 50) cpuclk(sysclk, reset, pause, clk); // negedge, 100 MHz -> 1 MHz
    
    
    // external bus
    
    wire [ 7 : 0 ] addr;
    
    wire [ 7 : 0 ] data;
    
    (* dont_touch = "true" *) wire ext_enable, ext_load;
    
    
    // external bus view
    
    wire clkdisp;
    
    clock_divider #(1'b1, 32, 250_000) sevensegclk(sysclk, 1'b0, 1'b0, clkdisp); // posedge, 100 MHz -> 200 Hz
    
    
    output [ 3 : 0 ] anode;
    
    sevenseg_selector sevenseg_selector(clkdisp, anode);
    
    
    output [ 7 : 0 ] seg;
    
    hex_sevenseg seg3(addr[7:4], 1'b0, anode[3], seg);
    hex_sevenseg seg2(addr[3:0], 1'b0, anode[2], seg);
    
    hex_sevenseg seg1(data[7:4], 1'b0, anode[1], seg);
    hex_sevenseg seg0(data[3:0], clk, anode[0], seg);
    
    
    
    // instruction pointer counter
    
    (* dont_touch = "true" *) wire ip_count, ip_enable, ip_load;
    
    counter #(8) ip(clk, reset, data, data, ip_count, ip_enable, ip_load);
    
    
    // instruction register
    
    (* dont_touch = "true" *) wire ir_load;
    
    wire [ 7 : 0 ] instruction; 
    
    register #(8) ir(clk, reset, data, instruction, 1'b1, ir_load);
    
    
    // memory address register
    
    (* dont_touch = "true" *) wire mar_load;
    
    register #(8) mar(clk, reset, data, addr, 1'b1, mar_load);
    
    
    // memory
    
    ram #(8, 8) ram(clk, addr, data, data, ext_enable, ext_load);
    
    
    // register
    
    (* dont_touch = "true" *) wire [ 1 : 0 ] rs, rd;
    
    wire [ 7 : 0 ] rs_out, rd_out;
    
    (* dont_touch = "true" *) wire rs_enable, rd_enable;
    
    (* dont_touch = "true" *) wire rd_load;
    
    file #(2, 8, 1, 3) register(clk, rs, rd, data, data, rs_enable, rd_enable, rd_load, rs_out, rd_out);
    
    
    // ALU & flags
    
    (* dont_touch = "true" *) wire flag_load;
    
    
    (* dont_touch = "true" *) wire c, cout;
    
    register carry(clk, reset, cout, c, 1'b1, flag_load);
    
    
    (* dont_touch = "true" *) wire v, vout;
    
    register overflow(clk, reset, vout, v, 1'b1, flag_load);
        
    
    (* dont_touch = "true" *) wire n, nout;
    
    register negative(clk, reset, nout, n, 1'b1, flag_load);
        
    
    (* dont_touch = "true" *) wire z, zout;
    
    register zero(clk, reset, zout, z, 1'b1, flag_load);
    
    
    (* dont_touch = "true" *) wire alu_add, alu_sub, alu_and, alu_or, alu_xor, alu_rl, alu_rr;
    
    alu alu(
        rd_out, 
        rs_out, 
        
        data, 
        
        alu_add, 
        alu_sub, 
        
        alu_and, 
        alu_or, 
        alu_xor, 
        
        alu_rl, 
        alu_rr, 
        
        c, 
        cout,
        
        vout,
        nout,
        
        zout
    );
    
    
    // control
    
    wire again;
    
    reg [ 2 : 0 ] step;
    
    initial
    
        step <= 0;
    
    always @(negedge clk, posedge again)
        
        if (again)
        
            step <= 0;
            
        else
    
            step <= step + 1;
    
    
    wire [ 3 : 0 ] op;
    
    assign {op, rd, rs} = instruction;
    
    
    wire NOP = (op == 4'b0000) & (rd == 2'b00) & (rs == 2'b00);
    
    wire LD_immediate = (op == 4'b0010) & (rd != 2'b00) & (rs == 2'b00);
    
    wire LD_direct = (op == 4'b0000) & (rd != 2'b00) & (rs == 2'b00);
    wire ST_direct = (op == 4'b0001) & (rd == 2'b00) & (rs != 2'b00);
    
    wire LD_indirect = (op == 4'b0000) & (rd != 2'b00) & (rs != 2'b00);
    wire ST_indirect = (op == 4'b0001) & (rd != 2'b00) & (rs != 2'b00);
    
    wire TRANSFER = (op == 4'b0010) & (rd != 2'b00) & (rs != 2'b00);
    
    wire SC = (op == 4'b1110) & (rd == 2'b00) & (rs == 2'b00);
    wire CC = (op == 4'b1101) & (rd == 2'b00) & (rs == 2'b00);
    
    wire ADC = (op == 4'b0101) & (rd != 2'b00) & (rs != 2'b00);
    wire SBC = (op == 4'b0110) & (rd != 2'b00) & (rs != 2'b00);
    
    wire CMP = (op == 4'b0100) & (rd != 2'b00) & (rs != 2'b00);
    
    wire AND = (op == 4'b1000) & (rd != 2'b00) & (rs != 2'b00);
    wire OR = (op == 4'b1001) & (rd != 2'b00) & (rs != 2'b00);
    wire XOR = (op == 4'b1010) & (rd != 2'b00) & (rs != 2'b00);
    
    wire RL = (op == 4'b1100) & (rd != 2'b00) & (rs == 2'b00);
    wire RR = (op == 4'b1101) & (rd != 2'b00) & (rs == 2'b00);
    
    wire J = (op == 4'b0100) & (rd == 2'b00) & (rs == 2'b00);
    
    wire JC = (op == 4'b1100) & (rd == 2'b00) & (rs == 2'b00);
    wire JV = (op == 4'b0101) & (rd == 2'b00) & (rs == 2'b00);
    wire JN = (op == 4'b0110) & (rd == 2'b00) & (rs == 2'b00);
    wire JZ = (op == 4'b1000) & (rd == 2'b00) & (rs == 2'b00);
    
    wire HALT = (op == 4'b1111) & (rd == 2'b00) & (rs == 2'b00);
    
    
    wire INVALID = ~(
        NOP | 
        LD_immediate | 
        LD_direct | 
        ST_direct | 
        LD_indirect | 
        ST_indirect | 
        TRANSFER | 
        SC | CC | 
        CMP | 
        SBC | ADC | 
        AND | OR | XOR | 
        RL | RR | 
        J | JC | JV | JN | JZ | 
        HALT
    );


    assign again = 
        (step == 2 & INVALID) | 
        
        (step == 2 & NOP) | 
        
        (step == 4 & LD_immediate) | 
        
        (step == 5 & LD_direct) | 
        (step == 5 & ST_direct) | 
        
        (step == 4 & LD_indirect) | 
        (step == 4 & ST_indirect) | 
        (step == 3 & TRANSFER) | 
        
        (step == 3 & ADC) | 
        (step == 3 & SBC) | 
        
        (step == 3 & CMP) | 
        
        (step == 3 & AND) | 
        (step == 3 & OR) | 
        (step == 3 & XOR) | 
        
        (step == 3 & RL) | 
        (step == 3 & RR) | 
        
        (step == 3 & SC) | 
        (step == 3 & CC) | 
        
        (step == 4 & J) | 
        
        (step == 4 & JC & c) | 
        (step == 4 & JV & v) | 
        (step == 4 & JN & n) | 
        (step == 4 & JZ & z) | 
        
        (step == 3 & JC & ~c) | 
        (step == 3 & JV & ~v) | 
        (step == 3 & JN & ~n) | 
        (step == 3 & JZ & ~z);
    
    assign pause = 
        (step == 2 & HALT);
    
    assign alu_add = 
        (step == 2 & ADC);
    assign alu_sub = 
        (step == 2 & SBC) | 
        (step == 2 & CMP);
    
    assign alu_and = 
        (step == 2 & AND);
    assign alu_or = 
        (step == 2 & OR);
    assign alu_xor = 
        (step == 2 & XOR);
    
    assign alu_rl = 
        (step == 2 & RL);
    assign alu_rr = 
        (step == 2 & RR);
    
    assign cout = 
        (step == 2 & SC) ? 1'b1 : 1'bz;
    assign cout = 
        (step == 2 & CC) ? 1'b0 : 1'bz;
    
    assign flag_load = 
        (step == 2 & ADC) | 
        (step == 2 & SBC) | 
        
        (step == 2 & CMP) | 
        
        (step == 2 & AND) | 
        (step == 2 & OR) | 
        (step == 2 & XOR) | 
        
        (step == 2 & RL) | 
        (step == 2 & RR) | 
        
        (step == 2 & SC) | 
        (step == 2 & CC);
    
    assign ext_enable = 
        (step == 3 & LD_immediate) | 
        
        (step == 3 & LD_direct) | 
        (step == 4 & LD_direct) | 
        
        (step == 3 & ST_direct) | 
        
        (step == 3 & LD_indirect) | 
        
        (step == 3 & J) | 
        
        (step == 3 & JC & c) | 
        (step == 3 & JV & v) | 
        (step == 3 & JN & n) | 
        (step == 3 & JZ & z) | 
        
        (step == 1);
    assign ext_load = 
        (step == 4 & ST_direct) | 
        (step == 3 & ST_indirect);
    
    assign ip_count = 
        (step == 3 & LD_immediate) | 
        
        (step == 3 & LD_direct) | 
        (step == 3 & ST_direct) | 
        
        (step == 2 & JC & ~c) | 
        (step == 2 & JV & ~v) | 
        (step == 2 & JN & ~n) | 
        (step == 2 & JZ & ~z) | 
        
        (step == 1);
    assign ip_enable = 
        (step == 2 & LD_immediate) | 
        
        (step == 2 & LD_direct) | 
        (step == 2 & ST_direct) | 
        
        (step == 2 & J) | 
        
        (step == 2 & JC & c) | 
        (step == 2 & JV & v) | 
        (step == 2 & JN & n) | 
        (step == 2 & JZ & z) | 
        
        (step == 0);
    assign ip_load = 
        (step == 3 & J) | 
        
        (step == 3 & JC & c) | 
        (step == 3 & JV & v) | 
        (step == 3 & JN & n) | 
        (step == 3 & JZ & z);
    
    assign ir_load = 
        (step == 1);
    
    assign mar_load = 
        (step == 2 & LD_immediate) | 
        
        (step == 2 & LD_direct) | 
        (step == 3 & LD_direct) | 
        
        (step == 2 & ST_direct) | 
        (step == 3 & ST_direct) | 
        
        (step == 2 & LD_indirect) | 
        (step == 2 & ST_indirect) | 
        
        (step == 2 & J) | 
        
        (step == 2 & JC & c) | 
        (step == 2 & JV & v) | 
        (step == 2 & JN & n) | 
        (step == 2 & JZ & z) | 
        
        (step == 0);
    
    assign rs_enable = 
        (step == 4 & ST_direct) | 
        
        (step == 2 & LD_indirect) | 
        (step == 3 & ST_indirect) | 
        
        (step == 2 & TRANSFER);
    assign rd_enable = 
        (step == 2 & ST_indirect);
    
    assign rd_load = 
        (step == 3 & LD_immediate) | 
        (step == 4 & LD_direct) | 
        (step == 3 & LD_indirect) | 
        
        (step == 2 & TRANSFER) | 
        
        (step == 2 & ADC) | 
        (step == 2 & SBC) | 
        
        (step == 2 & AND) | 
        (step == 2 & OR) | 
        (step == 2 & XOR) | 
        
        (step == 2 & RL) | 
        (step == 2 & RR);
    
endmodule
