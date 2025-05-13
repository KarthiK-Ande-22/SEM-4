module full_adder(input a, input b, input cin, output sum, output cout);

    wire axorb, and1, and2;
    xor (axorb, a, b);
    xor (sum, axorb, cin);

    and (and1, a, b);
    and (and2, axorb, cin);
    or (cout, and1, and2);
endmodule


module ADD (input [63:0] a, input [63:0] b, input cin, output [63:0] sum, output cout);
    genvar i;
    wire [64:0] carry;

    assign carry[0] = cin;

    generate
        for (i = 0; i < 64; i = i + 1) begin
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .sum(sum[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    assign cout = carry[64];
endmodule

