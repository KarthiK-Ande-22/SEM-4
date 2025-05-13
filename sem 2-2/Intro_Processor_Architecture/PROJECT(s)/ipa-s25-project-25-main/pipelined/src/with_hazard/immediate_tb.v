`timescale 1ns/1ps
`include "immediate.v"
module imm_gen_all_types_tb;

    // Testbench signals
    reg [31:0] instruction;
    reg clk;
    wire [63:0] immediate, immediateclk;

    // Instantiate the module
    imm_gen_all_types uut (
        .instruction(instruction),
        .immediate(immediate),
        .immediateclk(immediateclk),
        .clk(clk)
    );

    // Clock generation
    always #5 clk = ~clk; // Toggle clock every 5 time units

    // Test procedure
    initial begin
        clk = 0;

        // Test Load Instruction (opcode 0000011)
        instruction = 32'b000000000001_00000_000_00000_0000011; // Example Load instruction
        #10;

        // Test Store Instruction (opcode 0100011)
        instruction = 32'b0000000_00001_00010_010_00010_0100011; // Example Store instruction
        #10;

        // Test Branch Instruction (opcode 1100011)
        instruction = 32'b0000000_00001_00010_000_00000_1100011; // Example Branch instruction
        #10;

        // Test another Load Instruction
        instruction = 32'b000000000101_00011_000_00101_0000011; // Example Load instruction
        #10;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Instr=%b | Immediate=%d | Immediateclk=%d",
                 $time, instruction, immediate, immediateclk);
    end

endmodule
