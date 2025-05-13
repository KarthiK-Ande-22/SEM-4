`include "mux.v"
// module shift_Arithmetic_right (input [63:0] a, input [4:0] b, output [63:0] sll_ab);
//     genvar i;
//     wire temp;
//     temp = a[63];
//     for (i = 63; i >=(64-b); i = i - 1) begin
//         assign sll_ab[i]=temp;
//     end
//     for (i = 0; i < (64-b); i = i + 1) begin
//         assign sll_ab[i]=a[i+b];
//     end
// endmodule






// module shift_Arithmetic_right (input [63:0] a, input [5:0] b, output [63:0] sra_ab);
//     wire [63:0] s0, s1, s2, s3, s4, s5;
//     wire temp=a[63];
//     multiplexer
//     assign s0 = (b[0])?{1'b0,a[63:1]}:a;
//     assign s1 = (b[1])?{2'b0,s0[63:2]}:s0;
//     assign s2 = (b[2])?{4'b0,s1[63:4]}:s1;
//     assign s3 = (b[3])?{8'b0,s2[63:8]}:s2;
//     assign s4 = (b[4])?{16'b0,s3[63:16]}:s3;
//     assign s5 = (b[5])?{32'b0,s4[63:32]}:s4;
//     assign sra_ab = s5;

// endmodule


module shift_Arithmetic_right (input [63:0] a, input [5:0] b, output [63:0] sra_ab);
    wire [63:0] mux_out[5:0]; // Array of wires to store output of each level of muxes
    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_loop
            mux64to1 mux0 (.in0(a), .in1({{1{a[63]}},a[63:1]}), .sel(b[0]), .out(mux_out[0]));
            mux64to1 mux1 (.in0(mux_out[0]), .in1({{2{a[63]}},mux_out[0][63:2]}), .sel(b[1]), .out(mux_out[1]));
            mux64to1 mux2 (.in0(mux_out[1]), .in1({{4{a[63]}},mux_out[1][63:4]}), .sel(b[2]), .out(mux_out[2]));
            mux64to1 mux3 (.in0(mux_out[2]), .in1({{8{a[63]}},mux_out[2][63:8]}), .sel(b[3]), .out(mux_out[3]));
            mux64to1 mux4 (.in0(mux_out[3]), .in1({{16{a[63]}},mux_out[3][63:16]}), .sel(b[4]), .out(mux_out[4]));
            mux64to1 mux5 (.in0(mux_out[4]), .in1({{32{a[63]}},mux_out[4][63:32]}), .sel(b[5]), .out(mux_out[5]));
        end
    endgenerate

    // Output result from the final mux (shifted value)
    assign sra_ab = mux_out[5];

endmodule

`timescale 1ns/1ps

module tb_shift_Arithmetic_right;
    // Inputs
    reg [63:0] a;
    reg [5:0] b;

    // Outputs
    wire [63:0] sra_ab;

    // Instantiate the DUT (Device Under Test)
    shift_Arithmetic_right uut (
        .a(a),
        .b(b),
        .sra_ab(sra_ab)
    );

    // Task to display results
    task display_result;
        begin
            $display("a = %b, b = %d | Output: %b" , a, b, sra_ab);
        end
    endtask

    initial begin
        $dumpfile("tb_shift_Arithmetic_right.vcd");
        $dumpvars(0, tb_shift_Arithmetic_right);

        // Test cases
        // Positive numbers
        a = 64'd16; b = 6'd1; #10 display_result(a, b, 64'd8); // Shift 16 >> 1 = 8
        a = 64'd64; b = 6'd3; #10 display_result(a, b, 64'd8); // Shift 64 >> 3 = 8

        // Negative numbers
        a = -64'd8; b = 6'd1; #10 display_result(a, b, -64'd4); // Shift -8 >> 1 = -4
        a = -64'd64; b = 6'd3; #10 display_result(a, b, -64'd8); // Shift -64 >> 3 = -8

        // Edge cases
        a = 64'd0; b = 6'd5; #10 display_result(a, b, 64'd0);   // Shift 0 >> any = 0
        a = -64'd1; b = 6'd63; #10 display_result(a, b, -64'd1); // Shift -1 >> 63 = -1
        a = 64'd1; b = 6'd63; #10 display_result(a, b, 64'd0);  // Shift 1 >> 63 = 0

        // Max and Min values
        a = 64'h7FFFFFFFFFFFFFFF; b = 6'd1; #10 display_result(a, b, 64'h3FFFFFFFFFFFFFFF); // Max positive >> 1
        a = 64'h8000000000000000; b = 6'd1; #10 display_result(a, b, 64'hC000000000000000); // Min negative >> 1

        // Random negative and positive values
        a = -64'd100; b = 6'd2; #10 display_result(a, b, -64'd25); // Shift -100 >> 2 = -25
        a = 64'd12345; b = 6'd4; #10 display_result(a, b, 64'd771); // Shift 12345 >> 4 = 771

        $finish;
    end
endmodule


