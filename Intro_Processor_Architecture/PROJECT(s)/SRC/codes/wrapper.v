
`include "all_in_one.v"

module wrapper (
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    output reg [63:0] result
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

ADD adder (.a(a), .b(b), .cin(1'b0), .sum(ADD_OUT), .cout(cout_adder));
SUB subtractor (.a(a), .b(b), .sum(SUB_OUT), .cout(cout_subtractor));
AND_64_bit and_gate (.a(a), .b(b), .and_ab(AND_OUT));
OR_64_bit or_gate (.a(a), .b(b), .or_ab(OR_OUT));
XOR_64_bit xor_gate (.a(a), .b(b), .xor_ab(XOR_OUT));
shift_logical_right slr (.a(a), .b(b[5:0]), .slr_ab(SLR_OUT));
shift_logical_left sll (.a(a), .b(b[5:0]), .sll_ab(SLL_OUT));
shift_Arithmetic_right sra (.a(a), .b(b[5:0]), .sra_ab(SRA_OUT));
set_less_than slt (.a(a), .b(b), .slt(SLT_OUT));
set_less_than_unsigned sltu (.a(a), .b(b), .sltu(SLTU_OUT));

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


// `include "add.v"
// `include "sub.v"
// `include "and.v"
// `include "or.v"
// `include "xor.v"
// `include "slr.v"
// `include "sll.v"
// `include "sra.v"
// `include "slt.v"
// `include "sltu.v"


// module wrapper (
//     input [63:0] a,
//     input [63:0] b,
//     input [3:0] op,
//     output [63:0] result
// );

// wire [63:0] ADD_OUT;
// wire [63:0] SUB_OUT;
// wire [63:0] AND_OUT;
// wire [63:0] OR_OUT;
// wire [63:0] XOR_OUT;
// wire [63:0] SLR_OUT;
// wire [63:0] SLL_OUT;
// wire [63:0] SRA_OUT;
// wire SLT_OUT;
// wire SLTU_OUT;
// wire cout_adder;
// wire cout_subtractor;


// ADD adder (.a(a), .b(b),.cin({1'b0}),.sum(ADD_OUT),.cout(cout_adder));
// SUB subtractor (.a(a), .b(b), .diff(SUB_OUT), .cout(cout_subtractor));
// AND_64_bit and_gate (.a(a), .b(b), .out(AND_OUT));
// OR_64_bit or_gate (.a(a), .b(b), .out(OR_OUT));
// XOR_64_bit xor_gate (.a(a), .b(b), .out(XOR_OUT));
// shift_logical_right slr (.a(a), .b(op), .slr_ab(SLR_OUT));
// shift_logical_left sll (.a(a), .b(op), .sll_ab(SLL_OUT));
// shift_arithmetic_right sra (.a(a), .b(op), .sra_ab(SRA_OUT));
// set_less_than slt (.a(a), .b(b), .slt(SLT_OUT));
// set_less_than_unsigned sltu (.a(a), .b(b), .sltu(SLTU_OUT));


// always @(*) begin
//     case(op)
//    4'b0000: result = ADD_OUT;
//    4'b0001: result = SUB_OUT;
//    4'b0010: result = AND_OUT;
//    4'b0011: result = OR_OUT;
//    4'b0100: result = XOR_OUT;
//    4'b0101: result = SLR_OUT;
//    4'b0110: result = SLL_OUT;
//    4'b0111: result = SRA_OUT;
//    4'b1000: result = {63'b0, SLT_OUT};  // Extend SLT_OUT to 64-bit
//    4'b1001: result = {63'b0, SLTU_OUT};  // Extend SLTU_OUT to 64-bit
//    default: result = 64'b0;
//     endcase
// end

// endmodule



// `include "add.v"
// `include "sub.v"
// `include "and.v"
// `include "or.v"
// `include "xor.v"
// `include "slr.v"
// `include "sll.v"
// `include "sra.v"
// `include "slt.v"
// `include "sltu.v"

// module wrapper (
//     input [63:0] a,
//     input [63:0] b,
//     input [3:0] op,
//     output [63:0] result
// );

// wire [63:0] ADD_OUT;
// wire [63:0] SUB_OUT;
// wire [63:0] AND_OUT;
// wire [63:0] OR_OUT;
// wire [63:0] XOR_OUT;
// wire [63:0] SLR_OUT;
// wire [63:0] SLL_OUT;
// wire [63:0] SRA_OUT;
// wire SLT_OUT;
// wire SLTU_OUT;


// add adder (.a(a), .b(b), ,.sum(ADD_OUT));
// sub subtractor (.a(a), .b(b), .diff(SUB_OUT));
// and and_gate (.a(a), .b(b), .out(AND_OUT));
// or or_gate (.a(a), .b(b), .out(OR_OUT));
// xor xor_gate (.a(a), .b(b), .out(XOR_OUT));
// shift_logical_right slr (.a(a), .b(op), .slr_ab(SLR_OUT));
// shift_left_logical sll (.a(a), .b(op), .sll_ab(SLL_OUT));
// shift_arithmetic_right sra (.a(a), .b(op), .sra_ab(SRA_OUT));
// set_less_than slt (.a(a), .b(b), .slt(SLT_OUT));
// set_less_than_unsigned sltu (.a(a), .b(b), .sltu(SLTU_OUT));


// always @(*) begin
//     case(op)
//         4'b0000: result = ADD_OUT;
//         4'b0001: result = SUB_OUT;
//         4'b0010: result = AND_OUT;
//         4'b0011: result = OR_OUT;
//         4'b0100: result = XOR_OUT;
//         4'b0101: result = SLR_OUT;
//         4'b0110: result = SLL_OUT;
//         4'b0111: result = SRA_OUT;
//         4'b1000: result = SLT_OUT;
//         4'b1001: result = SLTU_OUT;
//         default: result = 64'b0;
//     endcase
    
// end

// endmodule //wrapper
