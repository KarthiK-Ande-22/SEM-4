`include "control.v"
`timescale 1ns/1ps

module control_alucontrol_tb;

    // Testbench signals
    reg [31:0] instruction;
    reg clk;
    wire idex_branch;
    wire idex_memread;
    wire idex_memtoreg;
    wire [1:0] idex_ALUop;
    wire idex_memwrite;
    wire idex_alusrc;
    wire idex_regwrite;
    wire [3:0] idex_ALUctr;

    // Instantiate the control unit
    control_alucontrol uut (
        .instruction(instruction),
        .clk(clk),
        .idex_branch(idex_branch),
        .idex_memread(idex_memread),
        .idex_memtoreg(idex_memtoreg),
        .idex_ALUop(idex_ALUop),
        .idex_memwrite(idex_memwrite),
        .idex_alusrc(idex_alusrc),
        .idex_regwrite(idex_regwrite),
        .idex_ALUctr(idex_ALUctr)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize clock
        clk = 0;

        // Test R-type (ADD)
        instruction = 32'b0000000_00001_00010_000_00011_0110011; // ADD
        #10;
        
        // Test R-type (SUB)
        instruction = 32'b0100000_00001_00010_000_00011_0110011; // SUB
        #10;

        // Test Load (LW)
        instruction = 32'b000000000100_00001_010_00010_0000011; // LW
        #10;

        // Test Store (SW)
        instruction = 32'b0000000_00010_00001_010_00011_0100011; // SW
        #10;

        // Test Immediate (ADDI)
        instruction = 32'b000000000101_00001_000_00010_0010011; // ADDI
        #10;

        // Test Branch (BEQ)
        instruction = 32'b0000000_00001_00010_000_00011_1100011; // BEQ
        #10;

        // Default case (NOP)
        instruction = 32'b00000000000000000000000000000000;
        #10;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Instr=%b | Branch=%b | MemRead=%b | MemToReg=%b | ALUop=%b | MemWrite=%b | ALUSrc=%b | RegWrite=%b | ALUctr=%b",
                 $time, instruction, idex_branch, idex_memread, idex_memtoreg, idex_ALUop, idex_memwrite, idex_alusrc, idex_regwrite, idex_ALUctr);
    end

endmodule
