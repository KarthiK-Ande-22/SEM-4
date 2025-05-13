module add(
    input signed [63:0] reg1,  
    input signed [63:0] reg2,  
    output signed [63:0] reg3 ,
    output overflow
);
wire [63:0] x28, x29, x30, sum_result;
wire [64:0] x31;  
assign x31[0] = 0; 
generate
    genvar i;
    for (i = 0; i < 64; i = i + 1) begin: add
        xor a1 (x28[i], reg1[i], reg2[i]);   
        xor a2 (sum_result[i], x28[i], x31[i]); 
        and a3 (x29[i], reg1[i], reg2[i]);   
        and a4 (x30[i], x28[i], x31[i]);     
        or  a5 (x31[i+1], x29[i], x30[i]);   
    end
endgenerate

wire helper1,helper2;
xnor(helper1,reg1[63],reg2[63]);
xor(helper2,reg1[63],sum_result[63]);
and(overflow,helper1,helper2);
assign reg3 =  sum_result;
endmodule