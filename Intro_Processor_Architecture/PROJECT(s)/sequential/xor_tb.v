`include "xor.v"
module tb_XOR_64_bit;

    reg [63:0] a;
    reg [63:0] b;
    wire [63:0] xor_ab;

    // Instantiate the XOR_64_bit module
    XOR_64_bit uut (
        .a(a),
        .b(b),
        .xor_ab(xor_ab)
    );

    initial begin
        // Test case 1: Both inputs are all zeros
        a = 64'b0;
        b = 64'b0;
        #10;
        $display("Test 1: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 2: One input is all ones, the other is all zeros
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'b0;
        #10;
        $display("Test 2: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 3: Both inputs are all ones
        a = 64'hFFFFFFFFFFFFFFFF;
        b = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("Test 3: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 4: Random patterns
        a = 64'hAA55AA55AA55AA55;
        b = 64'h55AA55AA55AA55AA;
        #10;
        $display("Test 4: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 5: Alternating bits
        a = 64'hAAAAAAAAAAAAAAAA;
        b = 64'h5555555555555555;
        #10;
        $display("Test 5: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 6: MSB (most significant bit) different
        a = 64'h8000000000000000;
        b = 64'h0;
        #10;
        $display("Test 6: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 7: LSB (least significant bit) different
        a = 64'h1;
        b = 64'h0;
        #10;
        $display("Test 7: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 8: Half bits set in each input
        a = 64'hFFFF0000FFFF0000;
        b = 64'h0000FFFF0000FFFF;
        #10;
        $display("Test 8: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 9: One input is zero, other has random values
        a = 64'h0;
        b = 64'hDEADBEEFDEADBEEF;
        #10;
        $display("Test 9: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 10: Both inputs have random values
        a = 64'h123456789ABCDEF0;
        b = 64'hFEDCBA9876543210;
        #10;
        $display("Test 10: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 11: Inputs are complements of each other
        a = 64'hFFFFFFFF00000000;
        b = ~a;
        #10;
        $display("Test 11: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Test case 12: Only one bit different in both inputs
        a = 64'h7FFFFFFFFFFFFFFF;
        b = 64'hFFFFFFFFFFFFFFFF;
        #10;
        $display("Test 12: a=%b, b=%b => xor_ab=%b", a, b, xor_ab);

        // Finish simulation
        $finish;
    end

endmodule
