`include "control.v"
`timescale 1ns / 1ps

module control_alucontrol_tb;
    reg [31:0] instruction;
    wire branch;
    wire memread;
    wire memtoreg;
    wire [1:0] ALUop;
    wire memwrite;
    wire alusrc;
    wire regwrite;
    wire [3:0] ALUctr;

    // Instantiate the DUT (Device Under Test)
    control_alucontrol dut (
        .instruction(instruction),
        .branch(branch),
        .memread(memread),
        .memtoreg(memtoreg),
        .ALUop(ALUop),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .ALUctr(ALUctr)
    );

    initial begin
        $dumpfile("control_alucontrol_tb.vcd");
        $dumpvars(0, control_alucontrol_tb);
        
        // Monitor all signals
        $monitor("Time=%0t | Inst=%b | branch=%b memread=%b memtoreg=%b ALUop=%b memwrite=%b alusrc=%b regwrite=%b ALUctr=%b",
                 $time, instruction, branch, memread, memtoreg, ALUop, memwrite, alusrc, regwrite, ALUctr);

        // Test R-type (ADD)
        instruction = 32'b0000000_00000_00000_000_00000_0110011; // ADD
        #10;
        
        // Test R-type (SUB)
        instruction = 32'b1000000_00000_00000_000_00000_0110011; // SUB
        #10;
        
        // Test Load (LW)
        instruction = 32'b000000000000_00000_010_00000_0000011; // LW
        #10;
        
        // Test Store (SW)
        instruction = 32'b0000000_00000_00000_010_00000_0100011; // SW
        #10;
        
        // Test I-type ALU (ADDI)
        instruction = 32'b000000000000_00000_000_00000_0010011; // ADDI
        #10;
        
        // Test Branch (BEQ)
        instruction = 32'b0000000_00000_00000_000_00000_1100011; // BEQ
        #10;
        
        // Default case (Invalid opcode)
        instruction = 32'b0000000_00000_00000_000_00000_1111111; // Invalid
        #10;

        $display("Test completed.");
        $finish;
    end
endmodule






            // imm[11] = instruction[31];//0
            // imm[10] = instruction[7];//0
            // imm[9:4] = instruction[30:25];//0
            // imm[3:0] = instruction[11:8];//
