module imm_generation (
    input wire [31:0] instruction,
    output reg [63:0] immediate
);
    
    wire [11:0] imm;
    assign imm = instruction[31:20];

    always @(*) begin
        immediate = {{52{imm[11]}}, imm}; 
    end

endmodule

