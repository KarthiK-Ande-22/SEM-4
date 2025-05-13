`include "mux.v"
module set_less_than_unsigned (input [63:0] a, input [63:0] b, output sltu);
genvar i;
wire [63:0] ans;
wire [63:0] a_not;
wire [63:0] xor_ab;
wire [64:0] enabler;
wire [64:0] flag;
assign flag[64] = ans[63];
assign enabler[64] = 1'b0;
for (i = 63; i >=0; i = i - 1) begin
    wire select,not_enabler;
    xor u1 (xor_ab[i], a[i],b[i]);
    not u2 (a_not[i], a[i]);
    and u3 (ans[i], a_not[i], b[i]);
    or u4 (enabler[i], enabler[i+1], xor_ab[i]);
    not u5 (not_enabler, enabler[i+1]);
    and u6 (select, not_enabler, xor_ab[i]);

    muxx mux (.a(flag[i+1]), .b(ans[i]), .sel(select), .y(flag[i]));
end
assign sltu = flag[0];
endmodule

`timescale 1ns/1ps

module tb_set_less_than_unsigned;

    reg [63:0] a, b;       // Test inputs
    wire sltu;             // Test output

    // Instantiate the module under test (MUT)
    set_less_than_unsigned mut (
        .a(a),
        .b(b),
        .sltu(sltu)
    );

    initial begin
        // Test Case 1: a < b
        a = 64'd5;         // 5 in decimal
        b = 64'd10;        // 10 in decimal
        #10;
        $display("Test 1: a=%d, b=%d, sltu=%b (Expected: 1)", a, b, sltu);

        // Test Case 2: a > b
        a = 64'd15;        // 15 in decimal
        b = 64'd10;        // 10 in decimal
        #10;
        $display("Test 2: a=%d, b=%d, sltu=%b (Expected: 0)", a, b, sltu);

        // Test Case 3: a == b
        a = 64'd25;        // 25 in decimal
        b = 64'd25;        // 25 in decimal
        #10;
        $display("Test 3: a=%d, b=%d, sltu=%b (Expected: 0)", a, b, sltu);

        // Test Case 4: Edge case - Both a and b are 0
        a = 64'd0;         // 0
        b = 64'd0;         // 0
        #10;
        $display("Test 4: a=%d, b=%d, sltu=%b (Expected: 0)", a, b, sltu);

        // Test Case 5: Edge case - Maximum value for b, a is smaller
        a = 64'd12345;     // Smaller value
        b = 64'hFFFFFFFFFFFFFFFF; // Maximum 64-bit unsigned value
        #10;
        $display("Test 5: a=%d, b=%d, sltu=%b (Expected: 1)", a, b, sltu);

        // Test Case 6: MSB difference - a is larger because MSB is 1
        a = 64'h8000000000000000; // Larger unsigned value
        b = 64'h7FFFFFFFFFFFFFFF; // Smaller unsigned value
        #10;
        $display("Test 6: a=%b, b=%b, sltu=%b (Expected: 0)", a, b, sltu);

        // Test Case 7: a and b differ in the lower bits
        a = 64'h00000000FFFFFFFF; // 32-bit ones
        b = 64'h0000000100000000; // One bit higher
        #10;
        $display("Test 7: a=%d, b=%d, sltu=%b (Expected: 1)", a, b, sltu);

        // End simulation
        $finish;
    end
endmodule

