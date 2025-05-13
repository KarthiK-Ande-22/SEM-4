`include "all_in_one.v"

module excution (
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    input [63:0] imm,
    input alusrc.
    output reg [63:0] result,
    output reg zero
);

wire [63:0] ADD_OUT;
wire [63:0] SUB_OUT;
wire [63:0] AND_OUT;
wire [63:0] OR_OUT;
wire [63:0] XOR_OUT;
wire [63:0] SLR_OUT;
wire [63:0] SLL_OUT;
wire [63:0] SRA_OUT;
wire SLT_OUT;
wire SLTU_OUT;
wire cout_adder;
wire cout_subtractor;
wire[63:0] operb;
assign operb = alu_src ? imm : b;

ADD adder (.a(a), .b(operb), .cin(1'b0), .sum(ADD_OUT), .cout(cout_adder));
SUB subtractor (.a(a), .b(operb), .sum(SUB_OUT), .cout(cout_subtractor));
AND_64_bit and_gate (.a(a), .b(operb), .and_ab(AND_OUT));
OR_64_bit or_gate (.a(a), .b(operb), .or_ab(OR_OUT));
XOR_64_bit xor_gate (.a(a), .b(operb), .xor_ab(XOR_OUT));
shift_logical_right slr (.a(a), .b(operb[5:0]), .slr_ab(SLR_OUT));
shift_logical_left sll (.a(a), .b(operb[5:0]), .sll_ab(SLL_OUT));
shift_Arithmetic_right sra (.a(a), .b(operb[5:0]), .sra_ab(SRA_OUT));
set_less_than slt (.a(a), .b(b), .slt(SLT_OUT));
set_less_than_unsigned sltu (.a(a), .b(operb), .sltu(SLTU_OUT));

always @(*) begin
    case(op)
        4'b0000: result = ADD_OUT;
        4'b0001: result = SUB_OUT;
        4'b0010: result = AND_OUT;
        4'b0011: result = OR_OUT;
        4'b0100: result = XOR_OUT;
        4'b0101: result = SLR_OUT;
        4'b0110: result = SLL_OUT;
        4'b0111: result = SRA_OUT;
        4'b1000: result = {63'b0, SLT_OUT};  // Handle SLT as 64-bit result
        4'b1001: result = {63'b0, SLTU_OUT};  // Handle SLTU as 64-bit result
        default: result = 64'b0;
    endcase
end
endmodule