module instrut_mem(
    input [9:0] pc, 
    output reg [31:0] instr
);
    reg [31:0] memory[0:1023];

    always @(*) begin
        instr = memory[pc >> 2]; 
    end
endmodule
