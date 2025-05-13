module muxx (input wire a, input wire b, input wire sel, output wire y);
    wire not_sel, and_a, and_b;
    not u1 (not_sel, sel);
    and u2 (and_a, a, not_sel);
    and u3 (and_b, b, sel);
    or  u4 (y, and_a, and_b);
endmodule


module mux64to1 (
    input wire [63:0] in0,
    input wire [63:0] in1,
    input wire sel,
    output wire [63:0] out
);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            muxx mux1 (.a(in0[i]), .b(in1[i]), .sel(sel), .y(out[i]));
        end
    endgenerate

endmodule


module full_adder(input signed a, input signed b, input cin, output signed sum, output signed cout);
    wire axorb, and1, and2;
    xor (axorb, a, b);
    xor (sum, axorb, cin);

    and (and1, a, b);
    and (and2, axorb, cin);

    or (cout, and1, and2);
endmodule


module ADD (input signed [63:0] a, input signed [63:0] b, input cin, output signed [63:0] sum, output signed cout);
    genvar i;
    wire signed [64:0] carry;

    assign carry[0] = cin;

    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate


    assign cout = carry[64];
    wire overflow;
    wire val1,val2;
    // assign overflow = (a[63] == b[63]) && (sum[63] != a[63]);

    xnor u1 (val1, a[63], b[63]);  // a[63] == b[63]
    xor  u2 (val2, sum[63], a[63]); // sum[63] != a[63]
    and  u3 (overflow, val1, val2); // Final overflow condition

    // xor u1(overflow,carry[64], carry[63]);
    // xor u2 (overflow, carry[63], carry[62]);

endmodule

module SUB (input signed [63:0] a, input signed [63:0] b, output signed [63:0] sum, output signed cout);
    genvar i;
    wire signed [64:0] carry;
    wire signed cin;
    assign cin = 1'b1;
    assign carry[0] = cin;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(
                .a(a[i]),
                .b(~b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[64];
    wire borrow,overflow;
    assign borrow = ~cout;
    wire and1,and2,and3,and4;
    // xnor u1 (val1, a[63], b[63]);  // a[63] == b[63]
    // xor  u2 (val2, sum[63], a[63]); // sum[63] != a[63]
    // and  u3 (overflow, val1, val2); // Final overflow condition

    assign overflow = (~a[63] & b[63] & sum[63]) | (a[63] & ~b[63] & ~sum[63]);

    // and u1 (and1, ~a[63], b[63]);
    // and u2 (and2, and1, sum[63]);
    // and u3 (and3, a[63], ~b[63]);
    // and u4 (and4, and3, ~sum[63]);
    // or  u5 (overflow, and2, and4);




    // wire xor_ab,and_do,xor_awithd;
    // xor(xor_ab,a[63],b[63]);
    // xor(xor_awithd,a[63],sum[63]);
    // and(and_do,xor_ab,borrow);
    // assign overflow = and_do;


endmodule

module AND_64_bit (input signed [63:0] a, input signed [63:0] b, output signed [63:0] and_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            and(and_ab[i], a[i], b[i]);
        end
    endgenerate
endmodule

module OR_64_bit (input signed [63:0] a, input signed [63:0] b, output signed [63:0] or_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            or(or_ab[i], a[i], b[i]);
        end
    endgenerate
endmodule

module XOR_64_bit (input signed [63:0] a, input signed [63:0] b, output signed [63:0] xor_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            xor(xor_ab[i], a[i], b[i]);
        end
    endgenerate
endmodule

module shift_logical_left (input signed [63:0] a, input [5:0] b, output signed [63:0] sll_ab);
    wire signed [63:0] s0, s1, s2, s3, s4, s5;
    mux64to1 mux0 (.in0(a), .in1({a[62:0],1'b0}), .sel(b[0]), .out(s0));
    mux64to1 mux1 (.in0(s0), .in1({s0[61:0],2'b0}), .sel(b[1]), .out(s1));
    mux64to1 mux2 (.in0(s1), .in1({s1[59:0],4'b0}), .sel(b[2]), .out(s2));
    mux64to1 mux3 (.in0(s2), .in1({s2[55:0],8'b0}), .sel(b[3]), .out(s3));
    mux64to1 mux4 (.in0(s3), .in1({s3[47:0],16'b0}), .sel(b[4]), .out(s4));
    mux64to1 mux5 (.in0(s4), .in1({s4[31:0],32'b0}), .sel(b[5]), .out(s5));
    assign sll_ab = s5;
    wire overflow_detected;
    xor u1 (overflow_detected, a[63], sll_ab[63]);

    wire o1,o2,o3,o4,o5,o6;
    xor u2 (o1, a[63], s0[63]);
    xor u3 (o2, s0[63], s1[63]);
    xor u4 (o3, s1[63], s2[63]);
    xor u5 (o4, s2[63], s3[63]);
    xor u6 (o5, s3[63], s4[63]);
    xor u7 (o6, s4[63], s5[63]);
    assign overflow_detected = o1 | o2 | o3 | o4 | o5 | o6;




endmodule

module shift_logical_right (input signed [63:0] a, input [5:0] b, output signed [63:0] slr_ab);
    wire signed [63:0] s0, s1, s2, s3, s4, s5;
    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            mux64to1 mux0 (.in0(a), .in1({1'b0,a[63:1]}), .sel(b[0]), .out(s0));
            mux64to1 mux1 (.in0(s0), .in1({2'b0,s0[63:2]}), .sel(b[1]), .out(s1));
            mux64to1 mux2 (.in0(s1), .in1({4'b0,s1[63:4]}), .sel(b[2]), .out(s2));
            mux64to1 mux3 (.in0(s2), .in1({8'b0,s2[63:8]}), .sel(b[3]), .out(s3));
            mux64to1 mux4 (.in0(s3), .in1({16'b0,s3[63:16]}), .sel(b[4]), .out(s4));
            mux64to1 mux5 (.in0(s4), .in1({32'b0,s4[63:32]}), .sel(b[5]), .out(s5));
        end
    endgenerate
    assign slr_ab = s5;

endmodule

module shift_Arithmetic_right (input signed [63:0] a, input [5:0] b, output signed [63:0] sra_ab);
    wire signed [63:0] s0, s1, s2, s3, s4, s5;
    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            mux64to1 mux0 (.in0(a), .in1({{1{a[63]}},a[63:1]}), .sel(b[0]), .out(s0));
            mux64to1 mux1 (.in0(s0), .in1({{2{a[63]}},s0[63:2]}), .sel(b[1]), .out(s1));
            mux64to1 mux2 (.in0(s1), .in1({{4{a[63]}},s1[63:4]}), .sel(b[2]), .out(s2));
            mux64to1 mux3 (.in0(s2), .in1({{8{a[63]}},s2[63:8]}), .sel(b[3]), .out(s3));
            mux64to1 mux4 (.in0(s3), .in1({{16{a[63]}},s3[63:16]}), .sel(b[4]), .out(s4));
            mux64to1 mux5 (.in0(s4), .in1({{32{a[63]}},s4[63:32]}), .sel(b[5]), .out(s5));
        end
    endgenerate
    assign sra_ab = s5;
endmodule

module set_less_than (input signed [63:0] a, input signed [63:0] b, output slt);
wire signed cout;
wire signed [63:0] ans;
SUB sub_for_slt (
        .a(a),
        .b(b),
        .sum(ans),
        .cout(cout)
    );
wire signed temp=ans[63];
assign slt=temp;
endmodule

module set_less_than_unsigned (input [63:0] a, input [63:0] b, output sltu);
genvar i;
wire [63:0] ans;
wire [63:0] a_not;
wire [63:0] xor_ab;
wire [64:0] enabler;
wire [64:0] flag;
assign flag[64] = ans[63];
assign enabler[64] = 1'b0;

for (i = 63; i >=0; i = i - 1) begin
    wire select,not_enabler;
    xor u1 (xor_ab[i], a[i],b[i]);
    not u2 (a_not[i], a[i]);
    and u3 (ans[i], a_not[i], b[i]);
    or u4 (enabler[i], enabler[i+1], xor_ab[i]);
    not u5 (not_enabler, enabler[i+1]);
    and u6 (select, not_enabler, xor_ab[i]);

    muxx mux2 (.a(flag[i+1]), .b(ans[i]), .sel(select), .y(flag[i]));
end

assign sltu = flag[0];
endmodule



// module muxx (input wire a,input wire b,input wire sel,output wire y);
//     wire not_sel,and_a,and_b;    
//     not u1 (not_sel, sel);       
//     and u2 (and_a, a, not_sel);  
//     and u3 (and_b, b, sel);      
//     or  u4 (y, and_a, and_b);    
// endmodule

// module mux64to1 (
//     input wire [63:0] in0,      
//     input wire [63:0] in1,      
//     input wire sel,            
//     output wire [63:0] out    
// );
//     genvar i;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin : mux_loop
//             muxx mux (.a(in0[i]), .b(in1[i]), .sel(sel), .y(out[i]));
//         end
//     endgenerate

// endmodule

// module full_adder(input a, input b, input cin, output sum, output cout);
//     wire axorb, and1, and2;
//     xor (axorb, a, b);
//     xor (sum, axorb, cin);

//     and (and1, a, b);
//     and (and2, axorb, cin);

//     or (cout, and1, and2);
// endmodule

// module ADD (input [63:0] a, input [63:0] b, input cin, output [63:0] sum, output cout);
//     genvar i;
//     wire [64:0] carry;

//     assign carry[0] = cin;

//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             full_adder fa(
//                 .a(a[i]),
//                 .b(b[i]),
//                 .cin(carry[i]),
//                 .sum(sum[i]),
//                 .cout(carry[i+1])
//             );
//         end
//     endgenerate

//     assign cout = carry[64];
// endmodule

// module SUB (input [63:0] a, input [63:0] b, output [63:0] sum, output cout);
//     genvar i;
//     wire [64:0] carry; 
//     wire cin;
//     assign cin = 1'b1;
//     assign carry[0] = cin;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             full_adder fa(
//                 .a(a[i]),
//                 .b(~b[i]), 
//                 .cin(carry[i]),
//                 .sum(sum[i]),
//                 .cout(carry[i+1])
//             );
//         end
//     endgenerate

//     assign cout = carry[64];
//     wire borrow;
//     assign borrow = ~cout; 
// endmodule

// module AND_64_bit (input [63:0] a, input [63:0] b, output [63:0] and_ab);
//     genvar i;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             and(and_ab[i], a[i], b[i]);
//         end
//         endgenerate

// endmodule

// module OR_64_bit (input [63:0] a, input [63:0] b, output [63:0] or_ab);
//     genvar i;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             or(or_ab[i], a[i], b[i]);
//         end
//         endgenerate
// endmodule 

// module XOR_64_bit (input [63:0] a,input [63:0] b, output [63:0] xor_ab);
//     genvar i;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             xor(xor_ab[i], a[i], b[i]);
//         end
//         endgenerate

// endmodule

// module shift_logical_left (input [63:0] a, input [5:0] b, output [63:0] sll_ab);
//     wire [63:0] s0, s1, s2, s3, s4, s5;
//     mux64to1 mux0 (.in0(a), .in1({a[62:0],1'b0}), .sel(b[0]), .out(s0));
//     mux64to1 mux1 (.in0(s0), .in1({s0[61:0],2'b0}), .sel(b[1]), .out(s1));
//     mux64to1 mux2 (.in0(s1), .in1({s1[59:0],4'b0}), .sel(b[2]), .out(s2));
//     mux64to1 mux3 (.in0(s2), .in1({s2[55:0],8'b0}), .sel(b[3]), .out(s3));
//     mux64to1 mux4 (.in0(s3), .in1({s3[47:0],16'b0}), .sel(b[4]), .out(s4));
//     mux64to1 mux5 (.in0(s4), .in1({s4[31:0],32'b0}), .sel(b[5]), .out(s5));
//     assign sll_ab = s5;
    
// endmodule

// module shift_logical_right (input [63:0] a, input [5:0] b, output [63:0] slr_ab);
//     // wire [63:0] mux_out[5:0];
//     wire [63:0] s0, s1, s2, s3, s4, s5;
//     genvar i;

//     generate
//         for (i = 0; i < 64; i = i + 1) begin : mux_loop
//             mux64to1 mux0 (.in0(a), .in1({1'b0,a[63:1]}), .sel(b[0]), .out(s0));
//             mux64to1 mux1 (.in0(s0), .in1({2'b0,s0[63:2]}), .sel(b[1]), .out(s1));
//             mux64to1 mux2 (.in0(s1), .in1({4'b0,s1[63:4]}), .sel(b[2]), .out(s2));
//             mux64to1 mux3 (.in0(s2), .in1({8'b0,s2[63:8]}), .sel(b[3]), .out(s3));
//             mux64to1 mux4 (.in0(s3), .in1({16'b0,s3[63:16]}), .sel(b[4]), .out(s4));
//             mux64to1 mux5 (.in0(s4), .in1({32'b0,s4[63:32]}), .sel(b[5]), .out(s5));
//         end
//     endgenerate

//     assign slr_ab = s5;

// endmodule

// module shift_Arithmetic_right (input [63:0] a, input [5:0] b, output [63:0] sra_ab);
//     wire [63:0] s0, s1, s2, s3, s4, s5;
//     genvar i;

//     generate
//         for (i = 0; i < 64; i = i + 1) begin : mux_loop
//             mux64to1 mux0 (.in0(a), .in1({{1{a[63]}},a[63:1]}), .sel(b[0]), .out(s0));
//             mux64to1 mux1 (.in0(s0), .in1({{2{a[63]}},s0[63:2]}), .sel(b[1]), .out(s1));
//             mux64to1 mux2 (.in0(s1), .in1({{4{a[63]}},s1[63:4]}), .sel(b[2]), .out(s2));
//             mux64to1 mux3 (.in0(s2), .in1({{8{a[63]}},s2[63:8]}), .sel(b[3]), .out(s3));
//             mux64to1 mux4 (.in0(s3), .in1({{16{a[63]}},s3[63:16]}), .sel(b[4]), .out(s4));
//             mux64to1 mux5 (.in0(s4), .in1({{32{a[63]}},s4[63:32]}), .sel(b[5]), .out(s5));
//         end
//     endgenerate
//     assign sra_ab = s5;
// endmodule

// module set_less_than (input [63:0] a, input [63:0] b, output slt);
// wire cout;
// wire [63:0] ans;
// SUB sub_for_slt (
//         .a(a),
//         .b(b),
//         .sum(ans),
//         .cout(cout)
//     );
// wire temp=ans[63];
// assign slt=temp;
// endmodule

// module set_less_than_unsigned (input [63:0] a, input [63:0] b, output sltu);
// genvar i;
// wire [63:0] ans;
// wire [63:0] a_not;
// wire [63:0] xor_ab;
// wire [64:0] enabler;
// wire [64:0] flag;
// assign flag[64] = ans[63];
// assign enabler[64] = 1'b0;

// for (i = 63; i >=0; i = i - 1) begin
//     wire select,not_enabler;
//     xor u1 (xor_ab[i], a[i],b[i]);
//     not u2 (a_not[i], a[i]);
//     and u3 (ans[i], a_not[i], b[i]);
//     or u4 (enabler[i], enabler[i+1], xor_ab[i]);
//     not u5 (not_enabler, enabler[i+1]);
//     and u6 (select, not_enabler, xor_ab[i]);

//     muxx mux (.a(flag[i+1]), .b(ans[i]), .sel(select), .y(flag[i]));
// end

// assign sltu = flag[0];
// endmodule

