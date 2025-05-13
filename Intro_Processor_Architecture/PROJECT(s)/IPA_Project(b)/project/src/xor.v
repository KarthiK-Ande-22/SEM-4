module xor_gate(
    input signed [63:0] reg1,  
    input signed [63:0] reg2,  
    output signed [63:0] reg3  
);

generate
    genvar i;
    for (i = 0; i < 64; i = i + 1) begin: xor_logic
        xor a1 (reg3[i], reg1[i], reg2[i]); 
    end
endgenerate

endmodule
