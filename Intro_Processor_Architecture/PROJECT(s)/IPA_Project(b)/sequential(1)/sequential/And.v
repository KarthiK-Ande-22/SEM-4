module AND_64_bit (input [63:0] a, input [63:0] b, output [63:0] and_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            and(and_ab[i], a[i], b[i]);
        end
        endgenerate

endmodule
