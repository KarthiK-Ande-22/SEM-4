`include "sll.v"
module tb_shift_logical_left;

    reg [63:0] a;           // Input operand
    reg [5:0] b;            // Shift amount
    wire [63:0] sll_ab;     // Output after shift

    // Instantiate the shift_logical_left module
    shift_logical_left uut (
        .a(a),
        .b(b),
        .sll_ab(sll_ab)
    );

    initial begin
        // Monitor the inputs and outputs
        $monitor("Time = %0t | a = %b | b = %b | sll_ab = %b", $time, a, b, sll_ab);

        // Test case 1: Shift by 0 (no shift)
        a = 64'h1234567890ABCDEF;
        b = 6'd0; // Shift by 0
        #10;

        // Test case 2: Shift by 1
        a = 64'h1234567890ABCDEF;
        b = 6'd1; // Shift by 1
        #10;

        // Test case 3: Shift by 2
        a = 64'h1234567890ABCDEF;
        b = 6'd2; // Shift by 2
        #10;

        // Test case 4: Shift by 8
        a = 64'h1234567890ABCDEF;
        b = 6'd8; // Shift by 8
        #10;

        // Test case 5: Shift by 16
        a = 64'h1234567890ABCDEF;
        b = 6'd16; // Shift by 16
        #10;

        // Test case 6: Shift by 32
        a = 64'h1234567890ABCDEF;
        b = 6'd32; // Shift by 32
        #10;

        // Test case 7: Shift by 63 (maximum shift)
        a = 64'h1234567890ABCDEF;
        b = 6'd63; // Shift by 63
        #10;

        // Test case 8: Edge case - Shift an input with all 0s
        a = 64'h0000000000000000;
        b = 6'd10; // Shift by 10
        #10;

        // Test case 9: Edge case - Shift an input with all 1s
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 6'd15; // Shift by 15
        #10;

        // Test case 10: Random value and small shift
        a = 64'hFEDCBA9876543210;
        b = 6'd3; // Shift by 3
        #10;

        // Test case 11: Random value and large shift
        a = 64'hFEDCBA9876543210;
        b = 6'd45; // Shift by 45
        #10;

        // Test case 12: Large value, MSB is set, and a moderate shift
        a = 64'h8000000000000000; // Only MSB is 1
        b = 6'd20; // Shift by 20
        #10;

        // Test case 13: Shift by half the bit width (31)
        a = 64'h1234567890ABCDEF;
        b = 6'd31; // Shift by 31
        #10;

        // Test case 14: Shift by random value and check for loss of bits
        a = 64'h1234567890ABCDEF;
        b = 6'd33; // Shift by 33
        #10;

        // Test case 15: Edge case - Shift an alternating pattern of 1s and 0s
        a = 64'hAAAAAAAAAAAAAAAA; // Alternating 1s and 0s
        b = 6'd7; // Shift by 7
        #10;

        // Test case 16: Edge case - Shift an input with alternating 0s and 1s
        a = 64'h5555555555555555; // Alternating 0s and 1s
        b = 6'd6; // Shift by 6
        #10;

        // End simulation
        $finish;
    end

endmodule

