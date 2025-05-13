`include "slr.v"
module tb_shift_logical_right;

    reg [63:0] a;
    reg [5:0] b;
    wire [63:0] slr_ab;

    // Instantiate the shift_logical_left module
    shift_logical_right uut (
        .a(a),
        .b(b),
        .slr_ab(slr_ab)
    );

    initial begin
        // Monitor the outputs
        $monitor("Time = %0t, a = %b, b = %b, sll_ab = %b", $time, a, b, slr_ab);

        // Test case 1: Shift by 0 (no change)
        a = 64'h1234567890ABCDEF; // Some test value
        b = 6'b000000; // Shift by 0
        #10;

        // Test case 2: Shift by 1 (should shift left by 1)
        a = 64'h1234567890ABCDEF;
        b = 6'b000001; // Shift by 1
        #10;

        // Test case 3: Shift by 8 (shift left by 8 bits)
        a = 64'h1234567890ABCDEF;
        b = 6'b001000; // Shift by 8
        #10;

        // Test case 4: Shift by 32 (shift left by 32 bits)
        a = 64'h1234567890ABCDEF;
        b = 6'b100000; // Shift by 32
        #10;

        // Test case 5: Shift by 63 (maximum shift, only the leftmost bit remains)
        a = 64'h0000000000000001; // Set to 1
        b = 6'b111111; // Shift by 63
        #10;

        // Test case 6: Shift by 31 (half the bit width)
        a = 64'h1234567890ABCDEF;
        b = 6'b011111; // Shift by 31
        #10;

        // Test case 7: Shift by 2 (shift left by 2 bits)
        a = 64'h1234567890ABCDEF;
        b = 6'b000010; // Shift by 2
        #10;

        // Test case 8: Shift by 16 (shift left by 16 bits)
        a = 64'h1234567890ABCDEF;
        b = 6'b010000; // Shift by 16
        #10;

        // Test case 9: Shift by 63 with a number that has only the most significant bit set
        a = 64'h8000000000000000; // Only MSB is 1
        b = 6'b111111; // Shift by 63
        #10;

        // Test case 10: All bits set to 1 and shift by 0
        a = 64'hFFFFFFFFFFFFFFFF; // All ones
        b = 6'b000000; // Shift by 0
        #10;

        // Test case 11: All bits set to 0 and shift by 0
        a = 64'h0000000000000000; // All zeros
        b = 6'b000000; // Shift by 0
        #10;

        // Test case 12: Shift by 4 (shift left by 4 bits)
        a = 64'h1234567890ABCDEF;
        b = 6'b000100; // Shift by 4
        #10;

        // Test case 13: Random large value of 'a' with random shift
        a = 64'hFEDCBA9876543210; // Random value
        b = 6'b101101; // Shift by 45
        #10;

        // End simulation
        $finish;
    end

endmodule


