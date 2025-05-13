`include "mux.v"
// module shift_logical_right (input [63:0] a, input [5:0] b, output [63:0] slr_ab);
//     wire [63:0] s0, s1, s2, s3, s4, s5;
//     assign s0 = (b[0])?{1'b0,a[63:1]}:a;
//     assign s1 = (b[1])?{2'b0,s0[63:2]}:s0;
//     assign s2 = (b[2])?{4'b0,s1[63:4]}:s1;
//     assign s3 = (b[3])?{8'b0,s2[63:8]}:s2;
//     assign s4 = (b[4])?{16'b0,s3[63:16]}:s3;
//     assign s5 = (b[5])?{32'b0,s4[63:32]}:s4;
//     assign slr_ab = s5;

// endmodule

// module muxx (input wire a, input wire b, input wire sel, output wire y);
//     wire not_sel, and_a, and_b;
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

module shift_logical_right (input [63:0] a, input [5:0] b, output [63:0] slr_ab);
    wire [63:0] mux_out[5:0]; // Array of wires to store output of each level of muxes
    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            mux64to1 mux0 (.in0(a), .in1({1'b0,a[63:1]}), .sel(b[0]), .out(mux_out[0]));
            mux64to1 mux1 (.in0(mux_out[0]), .in1({2'b0,mux_out[0][63:2]}), .sel(b[1]), .out(mux_out[1]));
            mux64to1 mux2 (.in0(mux_out[1]), .in1({4'b0,mux_out[1][63:4]}), .sel(b[2]), .out(mux_out[2]));
            mux64to1 mux3 (.in0(mux_out[2]), .in1({8'b0,mux_out[2][63:8]}), .sel(b[3]), .out(mux_out[3]));
            mux64to1 mux4 (.in0(mux_out[3]), .in1({16'b0,mux_out[3][63:16]}), .sel(b[4]), .out(mux_out[4]));
            mux64to1 mux5 (.in0(mux_out[4]), .in1({32'b0,mux_out[4][63:32]}), .sel(b[5]), .out(mux_out[5]));
        end
    endgenerate

    // Output result from the final mux (shifted value)
    assign slr_ab = mux_out[5];

endmodule


module tb_shift_logical_right();
    reg signed [63:0] a; // Input operand (signed)
    reg [5:0] b;  // Shift amount
    wire [63:0] slr_ab; // Output result

    // Instantiate the DUT (Device Under Test)
    shift_logical_right dut (
        .a(a),
        .b(b),
        .slr_ab(slr_ab)
    );

    initial begin
        // Display headers
        $display("Time\t\t a\t\t\t b\t slr_ab");
        $monitor("%0t\t %b\t %d\t %b", $time, a, b, slr_ab);

        // Test case 1: Small positive number
        a = 16; b = 6'd2; #10;

        // Test case 2: Small negative number
        a = -8; b = 6'd3; #10;

        // Test case 3: Zero input
        a = 0; b = 6'd5; #10;

        // Test case 4: Maximum positive value
        a = 127; b = 6'd3; #10;

        // Test case 5: Negative boundary value
        a = -64; b = 6'd6; #10;

        // Test case 6: Shift by zero
        a = -42; b = 6'd0; #10;

        // Test case 7: Negative large shift
        a = -128; b = 6'd7; #10;

        // Test case 8: Positive boundary value
        a = 64; b = 6'd6; #10;

        // Finish simulation
        $finish;
    end
endmodule


// module tb_shift_logical_right();
//     reg [63:0] a; // Input operand
//     reg [5:0] b;  // Shift amount
//     wire [63:0] slr_ab; // Output result

//     // Instantiate the DUT (Device Under Test)
//     shift_logical_right dut (
//         .a(a),
//         .b(b),
//         .slr_ab(slr_ab)
//     );

//     initial begin
//         // Display headers
//         $display("Time\t\t a\t\t\t\t\t\t\t\t b\t slr_ab");
//         $monitor("%0t\t %d\t %d\t %d", $time, a, b, slr_ab);

//         // Test case 1: All zeros input
//         a = 64'b0; b = 6'b0; #10;

//         // Test case 2: All ones input
//         a = 64'hFFFFFFFFFFFFFFFF; b = 6'b0; #10;

//         // Test case 3: Maximum shift
//         a = 64'h8000000000000000; b = 6'b111111; #10;

//         // Test case 4: Minimum shift
//         a = 64'h123456789ABCDEF0; b = 6'b000000; #10;

//         // Test case 5: Shift with mixed pattern
//         a = 64'b1010101010101010101010101010101010101010101010101010101010101010; b = 6'b000011; #10;

//         // Test case 6: Shift exactly halfway
//         a = 64'hFEDCBA9876543210; b = 6'b100000; #10;

//         // Test case 7: Random large shift
//         a = 64'h0F0F0F0F0F0F0F0F; b = 6'b011101; #10;

//         // Test case 8: MSB-only input
//         a = 64'h8000000000000000; b = 6'b000001; #10;

//         // Test case 9: LSB-only input
//         a = 64'h0000000000000001; b = 6'b000010; #10;

//         // Test case 10: Alternating bits
//         a = 64'hAAAAAAAAAAAAAAAA; b = 6'b000101; #10;

//         // Finish simulation
//         $finish;
//     end
// endmodule


// module tb_shift_logical_right();
//     reg [63:0] a; // Input operand
//     reg [5:0] b;  // Shift amount
//     wire [63:0] slr_ab; // Output result

//     // Instantiate the DUT (Device Under Test)
//     shift_logical_right dut (
//         .a(a),
//         .b(b),
//         .slr_ab(slr_ab)
//     );

//     initial begin
//         // Initialize signals
//         $display("Starting testbench...");
//         $monitor("Time=%0d | a=%b | b=%b | slr_ab=%b", $time, a, b, slr_ab);

//         // Test case 1: No shift
//         a = 64'b1010101010101010101010101010101010101010101010101010101010101010;
//         b = 6'b000000;
//         #10;

//         // Test case 2: Shift by 1
//         b = 6'b000001;
//         #10;

//         // Test case 3: Shift by 8
//         b = 6'b001000;
//         #10;

//         // Test case 4: Shift by 16
//         b = 6'b010000;
//         #10;

//         // Test case 5: Shift by 32
//         b = 6'b100000;
//         #10;

//         // Test case 6: Maximum shift (63)
//         b = 6'b111111;
//         #10;

//         // Finish simulation
//         $stop;
//     end
// endmodule
