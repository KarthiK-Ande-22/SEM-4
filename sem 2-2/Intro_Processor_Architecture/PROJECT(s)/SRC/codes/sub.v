`include "add.v"
// module SUB (input [63:0] a, input [63:0] b,input cin, output [63:0] sum, output cout);
//     genvar i;
//     wire temp;
//     assign temp = 1'b1;
//     generate
//         for (i = 0; i < 64; i = i + 1) begin
//             full_adder fa(a[i], ~b[i], temp, sum[i], cout); //2's complement cheyyali
//             assign temp = cout;

//         end
//         endgenerate

// endmodule 

module SUB (input [63:0] a, input [63:0] b, output [63:0] sum, output cout);
    genvar i;
    wire [64:0] carry; 
    wire cin;
    assign cin = 1'b1; // 2's complement of b
    assign carry[0] = cin;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(
                .a(a[i]),
                .b(~b[i]), // Taking 2's complement of b
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[64]; // Final carry-out
    wire borrow;
    assign borrow = ~cout; // Borrow signal
endmodule
