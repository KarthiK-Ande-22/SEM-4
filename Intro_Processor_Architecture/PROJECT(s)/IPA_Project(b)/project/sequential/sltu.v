module unsigned_lt_comparator(
    input [63:0] reg1, 
    input [63:0] reg2, 
    output lt         
);
  wire  [63:0] helper,helper2,helper3,helper4,helper5,reg1_result,reg2_result;
  wire[64:0] helper6,helper7;
  assign helper6 [64]=0;
   assign helper7 [64]=0;
  generate
    genvar i;
    for (i = 63; i >=0; i = i - 1) begin: less_than_check
      xor(helper[i],reg1[i],reg2[i]);
      and(helper2[i],helper[i],reg2[i]);
      and(helper3[i],helper[i],reg1[i]);
      not(helper4[i],helper7[i+1]);
      not(helper5[i],helper6[i+1]);
      and(reg1_result[i],helper3[i],helper4[i]);
      and(reg2_result[i],helper2[i],helper5[i]);
      or(helper6[i],reg1_result[i],helper6[i+1]);
      or(helper7[i],reg2_result[i],helper7[i+1]);
    end
  endgenerate
assign lt =helper7[0];
endmodule