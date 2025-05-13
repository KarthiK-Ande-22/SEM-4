module instr_mem(
    input [31:0] pc, 
    output reg [31:0] instr,
    output reg [31:0] ifid_instr
);
    reg [31:0] memory [0:1023]; // 1K words of memory

    initial begin
        // memory[3] = 32'b0000000_00100_00000_000_00001_0110011; // addi x1, x0, 16   (Initialize x1 = 1)
        // memory[2] = 32'b0000000_10000_00000_000_00010_0010011; // addi x2, x0, 16  (Initialize x1 = 1)

        memory[1] = 32'b0100000_01001_01101_000_01001_0110011; // sub x9, x13, x9
        memory[0] = 32'b0000000_01001_01101_000_01001_0110011; // add x9, x13, x9  
        
    end

    always @(*) begin
        instr = memory[pc[6:0]>>2]; // Fetch instruction using word-aligned address
        ifid_instr = instr;
    end
endmodule