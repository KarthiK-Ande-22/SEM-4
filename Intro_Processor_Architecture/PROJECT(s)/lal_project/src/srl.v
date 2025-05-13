module right_shifter_logical(
    input  signed [63:0] data_in,  // Unsigned input for logical shift
    input   [5:0] shift_amt,  
    output signed[63:0] data_out
);
    
    wire [63:0] stage1, stage2, stage3, stage4, stage5, stage6;
    wire [63:0] temp1, temp2, temp3, temp4, temp5, temp6;

    assign stage1[63:62] = 2'b00; // Fill with 0 instead of sign bit
    generate
        genvar i;
        for (i = 61; i >= 0; i = i - 1) begin: shift_1
            assign stage1[i] = data_in[i+1]; 
        end
    endgenerate
    assign temp1 = shift_amt[0] ? stage1 : data_in;

    assign stage2[63:61] = 3'b000; 
    generate
        for (i = 60; i >= 0; i = i - 1) begin: shift_2
            assign stage2[i] = temp1[i+2]; 
        end
    endgenerate
    assign temp2 = shift_amt[1] ? stage2 : temp1;

    assign stage3[63:59] = 5'b00000;
    generate
        for (i = 58; i >= 0; i = i - 1) begin: shift_3
            assign stage3[i] = temp2[i+4]; 
        end
    endgenerate
    assign temp3 = shift_amt[2] ? stage3 : temp2;

    assign stage4[63:55] = 9'b000000000;
    generate
        for (i = 54; i >= 0; i = i - 1) begin: shift_4
            assign stage4[i] = temp3[i+8]; 
        end
    endgenerate
    assign temp4 = shift_amt[3] ? stage4 : temp3;

    assign stage5[63:47] = 17'b00000000000000000;
    generate
        for (i = 46; i >= 0; i = i - 1) begin: shift_5
            assign stage5[i] = temp4[i+16]; 
        end
    endgenerate
    assign temp5 = shift_amt[4] ? stage5 : temp4;

    assign stage6[63:31] = 33'b000000000000000000000000000000000;
    generate
        for (i = 30; i >= 0; i = i - 1) begin: shift_6
            assign stage6[i] = temp5[i+32]; 
        end
    endgenerate
    assign temp6 = shift_amt[5] ? stage6 : temp5;

    assign data_out = temp6;

endmodule