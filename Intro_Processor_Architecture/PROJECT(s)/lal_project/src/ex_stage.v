// `include "add.v"
// `include "sub.v"
// `include "and_gate.v"
// `include "or_gate.v"
// `include "xor_gate.v"   
// `include "left_shifter.v"
// `include "right_shifter_logical.v"
// `include "right_shifter_arithmetic.v"
// `include "signed_lt_comparator.v"   
// `include "unsigned_lt_comparator.v"
// `include "comparator.v"


module ex_stage (
    input decoder,
    input [63:0] rs1_val,
    input [63:0] rs2_val,
    input [63:0] imm,
    input alu_src,
    input [3:0] alu_op,
    input branch,
    output reg [63:0] alu_result,
    output reg overflow
);

    wire [63:0] operand_b;
    assign operand_b = alu_src ? imm : rs2_val;
    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] shifted_left, shifted_right_logical, shifted_right_arithmetic;
    wire lt_signed, lt_unsigned,compartor,not_compartor;
    wire add_overflow, shift_overflow;

    add adder_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(add_result), 
        .overflow(add_overflow)
    );

    sub sub_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(sub_result), 
        .overflow(sub_overflow)
    );

    and_gate and_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(and_result)
    );

    or_gate or_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(or_result)
    );

    xor_gate xor_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(xor_result)
    );

    left_shifter left_shift_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_left), 
        .overflow(shift_overflow)
    );

    right_shifter_logical right_shift_log_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_right_logical)
    );

    right_shifter_arthemetic right_shift_arith_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_right_arithmetic)
    );

    signed_lt_comparator slt_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .lt(lt_signed)
    );

    unsigned_lt_comparator ult_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .lt(lt_unsigned)
    );
    compartor comp_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .eq(compartor)
    );
not(not_compartor,comp_result);

    always @(*) begin
        alu_result = 64'b0;
        overflow = 1'b0;
        case (alu_op)
            4'b0000: begin
                alu_result = and_result;
                overflow = 1'b0;
            end
            4'b0001: begin
                alu_result = or_result;
                overflow = 1'b0;
            end
            4'b0010: begin
                alu_result = add_result;
                overflow = add_overflow;
            end
            4'b0011: begin
                alu_result = shifted_left;
                overflow = shift_overflow;
            end
            4'b0100: begin
                alu_result = shifted_right_logical;
                overflow = 1'b0;
            end
            4'b0101: begin
                alu_result = shifted_right_arithmetic;
                overflow = 1'b0;
            end
            4'b0110: begin
                alu_result = sub_result;
                overflow = sub_overflow;
            end
            4'b0111: begin
                alu_result = {63'b0, lt_unsigned};
                overflow = 1'b0;
            end
            4'b1000: begin
                alu_result = {63'b0, lt_signed};
                overflow = 1'b0;
            end
            4'b1001: begin
                alu_result = xor_result;
                overflow = 1'b0;
            end
            4'b1010: begin
                alu_result = {63'b0, not_compartor};
                overflow = 1'b0;
            end
            4'b1011: begin
                alu_result = {63'b0, not_compartor};
                overflow = 1'b0;
            end
            default: begin
                alu_result = 64'b0;
                overflow = 1'b0;
            end
        endcase
    $display("ALU Output: %d, Overflow: %b", alu_result, overflow);
    end
    
endmodule
