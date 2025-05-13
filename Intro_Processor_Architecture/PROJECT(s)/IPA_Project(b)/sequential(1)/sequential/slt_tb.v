`include "slt.v"
module tb_set_less_than;

    reg signed [63:0] a;
    reg signed [63:0] b;
    wire slt;

    // Instantiate the set_less_than module
    set_less_than uut (
        .a(a),
        .b(b),
        .slt(slt)
    );

    initial begin
        // Test case 1: a < b
        a = 64'sd10;
        b = 64'sd20;
        #10;
        $display("Test 1: a=%d, b=%d => slt=%b", a, b, slt);

        // Test case 2: a > b
        a = 64'sd20;
        b = 64'sd10;
        #10;
        $display("Test 2: a=%d, b=%d => slt=%b", a, b, slt);

        // Test case 3: a == b
        a = 64'sd16;
        b = 64'sd15;
        #10;
        $display("Test 3: a=%d, b=%d => slt=%b", a, b, slt);

        // Test case 4: a < b (negative values)
        a = -64'sd10;
        b = 64'sd5;
        #10;
        $display("Test 4: a=%d, b=%d => slt=%b", a, b, slt);

        // Test case 5: a > b (negative values)
        a = -64'sd5;
        b = -64'sd10;
        #10;
        $display("Test 5: a=%d, b=%d => slt=%b", a, b, slt);

        // Test case 6: a == b (negative values)
        a = -64'sd20;
        b = -64'sd20;
        #10;
        $display("Test 6: a=%d, b=%d => slt=%b", a, b, slt);

        // Finish simulation
        $stop;
    end

endmodule
