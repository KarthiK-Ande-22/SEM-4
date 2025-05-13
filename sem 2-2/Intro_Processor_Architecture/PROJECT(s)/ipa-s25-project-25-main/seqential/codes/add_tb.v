`include "add.v"
`timescale 1ns / 1ps

module tb_ADD();

    reg [63:0] a;
    reg [63:0] b;
    reg cin;
    wire [63:0] sum;
    wire cout;

    // Instantiate the ADD module
    ADD uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        // Test case 1: Adding zero to zero
        a = 64'd0; b = 64'd0; cin = 1'b0;
        #10;
        $display("Test 1: a=%d, b=%d, cin=%b => sum=%d, cout=%b", a, b, cin, sum, cout);

        // Test case 2: Adding two numbers without carry-in
        a = 64'd10; b = 64'd15; cin = 1'b0;
        #10;
        $display("Test 2: a=%d, b=%d, cin=%b => sum=%d, cout=%b", a, b, cin, sum, cout);

        // Test case 3: Adding two numbers with carry-in
        a = 64'd10; b = 64'd15; cin = 1'b1;
        #10;
        $display("Test 3: a=%d, b=%d, cin=%b => sum=%d, cout=%b", a, b, cin, sum, cout);

        // Test case 4: Adding large numbers
        a = 64'hFFFFFFFFFFFFFFFF; b = 64'd1; cin = 1'b0;
        #10;
        $display("Test 4: a=%h, b=%d, cin=%b => sum=%h, cout=%b", a, b, cin, sum, cout);

        // Test case 5: Adding numbers resulting in carry-out
        a = 64'd9223372036854775807; b = 64'd9223372036854775807; cin = 1'b0;
        #10;
        $display("Test 5: a=%d, b=%d, cin=%b => sum=%d, cout=%b", a, b, cin, sum, cout);

        // Finish simulation
        $finish;
    end

endmodule

