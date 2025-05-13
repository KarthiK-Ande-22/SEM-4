`include "sub.v"
`timescale 1ns / 1ps
module tb_SUB();

    reg signed [63:0] a;
    reg signed [63:0] b;
    wire signed [63:0] sum;
    wire cout;
    wire borrow;

    // Instantiate the SUB module
    SUB uut (
        .a(a),
        .b(b),
        .sum(sum),
        .cout(cout)
    );

    // Assign borrow signal (borrow is the negation of cout)
    assign borrow = ~cout;

    initial begin
        // Test case 1: Subtracting zero from zero
        a = 64'sd0; b = 64'sd0;
        #10;
        $display("Test 1: a=%d, b=%d => sum=%d, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Test case 2: Subtracting a smaller number from a larger number
        a = 64'sd15; b = 64'sd10;
        #10;
        $display("Test 2: a=%d, b=%d => sum=%d, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Test case 3: Subtracting a larger number from a smaller number
        a = 64'sd10; b = 64'sd15;
        #10;
        $display("Test 3: a=%d, b=%d => sum=%d, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Test case 4: Subtracting large numbers
        a = 64'shFFFFFFFFFFFFFFFF; b = 64'sd1;
        #10;
        $display("Test 4: a=%h, b=%d => sum=%h, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Test case 5: Subtracting numbers resulting in underflow
        a = 64'sd0; b = 64'sd1;
        #10;
        $display("Test 5: a=%d, b=%d => sum=%d, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Test case 6: Subtracting negative values
        a = 64'sd10; b = 64'sd20;
        #10;
        $display("Test 6: a=%d, b=%d => sum=%d, cout=%b, borrow=%b", a, b, sum, cout, borrow);

        // Finish simulation
        $finish;
    end

endmodule
