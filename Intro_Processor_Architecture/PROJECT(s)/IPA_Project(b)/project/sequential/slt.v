module signed_lt_comparator(
    input signed [63:0] reg1, 
    input signed [63:0] reg2, 
    output lt         
);
  wire  [62:0] helper,helper2,helper3,helper4,helper5,reg1_result,reg2_result;
  wire[63:0] helper6,helper7;
  assign helper6 [63]=0;
   assign helper7 [63]=0;
  generate
    genvar i;
    for (i = 62; i >=0; i = i - 1) begin: less_than_check
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
  wire  checker,laster,laster2,last,duplicate_helper,helper8;
  xor(checker,reg1[63],reg2[63]);
  and(laster,checker,reg1[63]);
  and(laster2,checker,reg2[63]);
  or(duplicate_helper,laster,helper7[0]);
  nand(helper8,laster2,63'b1);
  and(last,duplicate_helper,helper8);
assign lt =last;
endmodule