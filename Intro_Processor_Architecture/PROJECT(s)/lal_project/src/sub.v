module sub(
    input signed [63:0] reg1,  
    input signed [63:0] reg2,  
    output signed [63:0] reg3 ,
    output overflow
);

wire [63:0] reg2_neg; 
generate
    genvar i;
    for (i = 0; i < 64; i = i + 1) begin: sub
        not n1 (reg2_neg[i], reg2[i]);  
    end
endgenerate
wire [63:0] reg2_out; 
wire normal;
add add_one (
    .reg1(64'sd1),       
    .reg2(reg2_neg),      
    .reg3(reg2_out),
    .overflow(normal)      
);
add add_subtract (
    .reg1(reg1),          
    .reg2(reg2_out),     
    .reg3(reg3),
    .overflow(overflow)       
);
endmodule