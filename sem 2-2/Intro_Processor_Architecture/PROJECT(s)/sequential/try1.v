module full_adder(input a, input b, input cin, output sum, output cout);
    wire 
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule


module ADD (input [63:0] a, input [63:0] b, input cin, output [63:0] sum, output cout);
    genvar i;
    wire temp;
    assign temp = cin;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(a[i], b[i], temp, sum[i], cout);
            assign temp = cout;

        end
        endgenerate

endmodule


module SUB (input [63:0] a, input [63:0] b,input cin, output [63:0] sum, output cout);
    genvar i;
    wire temp;
    assign temp = 1'b1;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(a[i], ~b[i], temp, sum[i], cout); //2's complement cheyyali
            assign temp = cout;

        end
        endgenerate

endmodule 

module XOR_64_bit (input [63:0] a,input [63:0] b, output [63:0] xor_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            // assign sum[i] = a[i] ^ b[i];
            xor(xor_ab[i], a[i], b[i]);
        end
        endgenerate

endmodule

module AND_64_bit (input [63:0] a, input [63:0] b, output [63:0] and_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            // assign andab[i] = a[i] & b[i];
            and(and_ab[i], a[i], b[i]);
        end
        endgenerate

endmodule 

module OR_64_bit (input [63:0] a, input [63:0] b, output [63:0] or_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            // assign orab[i] = a[i] | b[i];
            or(or_ab[i], a[i], b[i]);
        end
        endgenerate
endmodule 

// module SLTU_64_bit (input [63:0] a, input [63:0] b, output sltu_ab);
//  genvar i;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
            
//         end
//         endgenerate
//     assign sltu_ab = or_ab[63];

// endmodule 

// module SLT_64_bit (input [63:0] a, input [63:0] b, output slt_ab);

// endmodule 


// using 6 bits for shift



// module shift_logical_left (input [63:0] a, input [4:0] b, output [63:0] sll_ab);
//     genvar i;
    
// endmodule 

// module shift_logical_right (input [63:0] a, input [4:0] b, output [63:0] slr_ab);
//     genvar i;
//     wire temp;
//     temp = 1'b0;
//     genvar j;
//     wire num;
//     number_decimal(b,num);
//     generate
//         for (j = 0; j < num; j = j + 1) begin
//             // assign value = a[63];
//             for (i = 63; i > 0; i = i - 1) begin
//                 assign slr_ab[i] = a[i-1];
//             end
//             assign slr_ab[0] = temp;
//             assign a = slr_ab;
//         end
//         endgenerate
//     // assign slr_ab[0] = temp;
//     // generate
//     //     for (i = 1; i < 64; i = i + 1) begin
//     //         assign sll_ab[i] = a[i-1];
//     //     end
//     //     endgenerate

// endmodule 

// module shift_Arithmetic_right (input [63:0] a, input [4:0] b, output [63:0] sar_ab);
//     genvar i;
//     genvar j;
//     wire num;
//     number_decimal(b,num);
//     generate
//         for (j = 0; j < num; j = j + 1) begin
//             assign value = a[0];
//             for (i = 63; i > 0; i = i - 1) begin
//                 assign sar_ab[i] = a[i-1];
//             end
//             assign sar_ab[0] = temp;
//             assign a = sar_ab;
//         end
//         endgenerate

// endmodule 


