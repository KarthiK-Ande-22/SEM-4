module compartor(
    input signed [63:0] reg1,
    input signed [63:0] reg2,
    output eq  
);
  wire [63:0] xnor_out;
  wire [64:0] and_result;
  assign and_result[64] = 1'b1;
  generate
    genvar i;
    for (i = 63; i >= 0; i = i - 1) begin: equality_check
        xnor x1 (xnor_out[i], reg1[i], reg2[i]); 
        and a1 (and_result[i], and_result[i+1], xnor_out[i]); 
    end
  endgenerate

  assign eq = and_result[0]; 

endmodule
