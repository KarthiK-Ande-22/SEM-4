module left_shifter(
    input  signed [63:0] data_in,  
    input  [5:0] shift_amt,  
    output signed [63:0] data_out ,
    output overflow  
);
    
    wire [64:0] stage1, stage2, stage3, stage4, stage5, stage6;
    wire [63:0] temp1, temp2, temp3, temp4, temp5, temp6;
    wire overflow_stage1, overflow_stage2, overflow_stage3, overflow_stage4, overflow_stage5, overflow_stage6;
    wire overflow_stage1_helper, overflow_stage2_helper, overflow_stage3_helper, overflow_stage4_helper, overflow_stage5_helper, overflow_stage6_helper;
    assign stage1[0] = 0;
    generate
        genvar i;
        for (i = 0; i < 64; i=i+1) begin: shift_1
            assign stage1[i+1] = data_in[i];
        end
    endgenerate
    xor(overflow_stage1_helper, data_in[63], stage1[63]);
    and(overflow_stage1, overflow_stage1_helper, shift_amt[0]);
    assign temp1 = shift_amt[0] ? stage1[63:0] : data_in;

    assign stage2[1:0] = 2'b00;
    generate
        for (i = 0; i < 63; i=i+1) begin: shift_2
            assign stage2[i+2] = temp1[i];
        end
    endgenerate
    xor(overflow_stage2_helper, data_in[63], stage2[63]);
    and(overflow_stage2, overflow_stage2_helper, shift_amt[1]);
    assign temp2 = shift_amt[1] ? stage2[63:0] : temp1;

    assign stage3[3:0] = 4'b0000;
    generate
        for (i = 0; i < 61; i=i+1) begin: shift_3
            assign stage3[i+4] = temp2[i];
        end
    endgenerate
    xor(overflow_stage3_helper, data_in[63], stage3[63]);
    and(overflow_stage3, overflow_stage3_helper, shift_amt[2]);
    assign temp3 = shift_amt[2] ? stage3[63:0] : temp2;

    assign stage4[7:0] = 8'b00000000;
    generate
        for (i = 0; i < 57; i=i+1) begin: shift_4
            assign stage4[i+8] = temp3[i];
        end
    endgenerate
    xor(overflow_stage4_helper, data_in[63], stage4[63]);
    and(overflow_stage4, overflow_stage4_helper, shift_amt[3]);
    assign temp4 = shift_amt[3] ? stage4[63:0]: temp3;


    assign stage5[15:0] = 16'b0000000000000000;
    generate
        for (i = 0; i < 49; i=i+1) begin: shift_5
            assign stage5[i+16] = temp4[i];
        end
    endgenerate
    xor(overflow_stage5_helper, data_in[63], stage5[63]);
    and(overflow_stage5, overflow_stage5_helper, shift_amt[4]);
    assign temp5 = shift_amt[4] ? stage5[63:0] : temp4;

    assign stage6[31:0] = 32'b00000000000000000000000000000000;
    generate
        for (i = 0; i < 33; i=i+1) begin: shift_6
            assign stage6[i+32] = temp5[i];
        end
    endgenerate
    xor(overflow_stage6_helper, data_in[63], stage6[63]);
    and(overflow_stage6, overflow_stage6_helper, shift_amt[5]);
    assign temp6 = shift_amt[5] ? stage6[63:0] : temp5;

    wire helper1, helper2,helper3,helper4;
    or(helper1,overflow_stage1,overflow_stage2);
    or(helper2,overflow_stage3,overflow_stage4);
    or(helper3,overflow_stage5,overflow_stage6);
    or(helper4,helper1,helper2);
    or(overflow,helper3,helper4);
    assign data_out = temp6;
endmodule