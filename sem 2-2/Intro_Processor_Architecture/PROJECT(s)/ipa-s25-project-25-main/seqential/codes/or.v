module OR_64_bit (input [63:0] a, input [63:0] b, output [63:0] or_ab);
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            or(or_ab[i], a[i], b[i]);
        end
        endgenerate
endmodule 

