module mux_64bit (
    input [63:0] in0, in1,
    input sel,
    output [63:0] out
);
    genvar i;
    wire [63:0] sel_and_in1, not_sel_and_in0;
    wire not_sel;

    not (not_sel, sel);

    generate
        for (i = 0; i < 64; i = i + 1) begin : mux_logic
            and (sel_and_in1[i], sel, in1[i]);
            and (not_sel_and_in0[i], not_sel, in0[i]);
            or (out[i], sel_and_in1[i], not_sel_and_in0[i]);
        end
    endgenerate
endmodule