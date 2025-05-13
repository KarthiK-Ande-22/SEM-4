`include "sub.v"
module set_less_than (input [63:0] a, input [63:0] b, output slt);
wire cout;
wire [63:0] ans;
// SUB(a, b, ans, cout);
SUB sub_for_slt (
        .a(a),
        .b(b),
        .sum(ans),
        .cout(cout)
    );
wire temp=ans[63];
assign slt=temp;

endmodule
