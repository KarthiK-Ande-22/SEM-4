`include "mux.v"

module shift_logical_left (input [63:0] a, input [5:0] b, output [63:0] sll_ab);
    wire [63:0] s0, s1, s2, s3, s4, s5;
    mux64to1 mux (.in0(a), .in1({a[62:0],1'b0}), .sel(b[0]), .out(s0));
    mux64to1 mux1 (.in0(s0), .in1({s0[61:0],2'b0}), .sel(b[1]), .out(s1));
    mux64to1 mux2 (.in0(s1), .in1({s1[59:0],4'b0}), .sel(b[2]), .out(s2));
    mux64to1 mux3 (.in0(s2), .in1({s2[55:0],8'b0}), .sel(b[3]), .out(s3));
    mux64to1 mux4 (.in0(s3), .in1({s3[47:0],16'b0}), .sel(b[4]), .out(s4));
    mux64to1 mux5 (.in0(s4), .in1({s4[31:0],32'b0}), .sel(b[5]), .out(s5));
    assign sll_ab = s5;
    
endmodule


// module tb_shift_logical_left;

//     reg [63:0] a;          // Input value to shift
//     reg [5:0] b;           // Shift amount
//     wire [63:0] sll_ab;    // Shifted output

//     // Instantiate the shift_logical_left module
//     shift_logical_left uut (
//         .a(a),
//         .b(b),
//         .sll_ab(sll_ab)
//     );

//     initial begin
//         // Monitor outputs
//         $monitor("Time: %0t | a = %b | b = %b | sll_ab = %b", $time, a, b, sll_ab);

//         // Test cases
//         a = 64'hFFFFFFFFFFFFFFFF; b = 6'd0;  #10; // No shift
//         a = 64'hFFFFFFFFFFFFFFFF; b = 6'd1;  #10; // Shift left by 1
//         a = 64'h000000000000FFFF; b = 6'd4;  #10; // Shift left by 4
//         a = 64'h123456789ABCDEF0; b = 6'd8;  #10; // Shift left by 8
//         a = 64'hFEDCBA9876543210; b = 6'd16; #10; // Shift left by 16
//         a = 64'h8000000000000000; b = 6'd32; #10; // Shift left by 32
//         a = 64'h0000000000000001; b = 6'd63; #10; // Shift left by 63
//         a = 64'hFFFFFFFFFFFFFFFF; b = 6'd64; #10; // Out of range, no shift

//         // Edge cases
//         a = 64'h0; b = 6'd10; #10;                // Shift zero value
//         a = 64'h1; b = 6'd63; #10;               // Shift by maximum valid amount
//         a = 64'h8000000000000000; b = 6'd2; #10; // Test MSB propagation

//         $finish;
//     end

// endmodule


    // mux64to1 mux1 (
    //     .in0(s0),      // Input 0
    //     .in1({s0[61:0],2'b0}),      // Input 1
    //     .sel(b[1]),       // Selection signal
    //     .out(s1)       // Output
    // );
    // mux64to1 mux2 (
    //     .in0(s1),      // Input 0
    //     .in1({s1[59:0],4'b0}),      // Input 1
    //     .sel(b[2]),       // Selection signal
    //     .out(s2)       // Output
    // );
    // mux64to1 mux3 (
    //     .in0(s2),      // Input 0
    //     .in1({s2[55:0],8'b0}),      // Input 1
    //     .sel(b[3]),       // Selection signal
    //     .out(s3)       // Output
    // );
    // mux64to1 mux4 (
    //     .in0(s3),      // Input 0
    //     .in1({s3[47:0],16'b0}),      // Input 1
    //     .sel(b[4]),       // Selection signal
    //     .out(s4)       // Output
    // );
    // mux64to1 mux5 (
    //     .in0(s4),      // Input 0
    //     .in1({s4[31:0],32'b0}),      // Input 1
    //     .sel(b[5]),       // Selection signal
    //     .out(s5)       // Output
    // );
    // assign sll_ab = s5;
    // assign s0 = (b[0])?{a[62:0],1'b0}:a;
    // assign s1 = (b[1])?{s0[61:0],2'b0}:s0;
    // assign s2 = (b[2])?{s1[59:0],4'b0}:s1;
    // assign s3 = (b[3])?{s2[55:0],8'b0}:s2;
    // assign s4 = (b[4])?{s3[47:0],16'b0}:s3;
    // assign s5 = (b[5])?{s4[31:0],32'b0}:s4;
    // assign sll_ab = s5;



