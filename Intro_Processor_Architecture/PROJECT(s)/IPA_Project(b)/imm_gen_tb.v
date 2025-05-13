`include "imm_gen.v"
`timescale 1ns / 1ps

module imm_gen_all_types_tb;
    // Testbench Inputs
    reg [31:0] instruction;
    // Testbench Output
    wire [63:0] immediate;

    // Instantiate the Unit Under Test (UUT)
    imm_gen_all_types uut (
        .instruction(instruction), 
        .immediate(immediate)
    );

    initial begin
        // Initialize Inputs
        instruction = 32'b0;

        // Wait for global reset
        #10;

        // Apply Test Cases

        // Test case 1: Branch Instruction (opcode = 1100011)
        instruction = 32'b0000000_00001_00001_000_00010_1100011;  // BEQ instruction
        #10;
        $display("Branch Instruction Immediate:%0d", $signed(immediate));  // Expected: 4



        // Test case 2: Load Instruction (opcode = 0000011)
        instruction = 32'b000000000101_00001_010_00010_0000011;  // LW instruction
        #10;
        $display("Load Instruction Immediate: %0d", $signed(immediate));  // Expected: 5

        // Test case 3: Store Instruction (opcode = 0100011)
        instruction = 32'b0000000_00101_00001_010_00010_0100011;  // SW instruction
        #10;
        $display("Store Instruction Immediate: %0d", $signed(immediate));  // Expected: 5

        // Test case 4: Immediate (I-type) Instruction (opcode = 0010011)
        instruction = 32'b000000000111_00001_000_00010_0010011;  // ADDI instruction
        #10;
        $display("Immediate Instruction (ADDI) Immediate: %0d", $signed(immediate));  // Expected: 7

        // Test case 5: Negative Branch Instruction
        instruction = 32'b1111111_00000_00001_000_00010_1100011;  // BEQ instruction with negative immediate
        #10;
        $display("Negative Branch Instruction Immediate: %0d", $signed(immediate));  // Expected: FFF0 (or -16)

        // Test case 6: Negative Load Instruction
        instruction = 32'b111111111000_00001_010_00010_0000011;  // LW instruction with negative immediate
        #10;
        $display("Negative Load Instruction Immediate: %0d", $signed(immediate));  // Expected: FFF8 (or -8)

        // Test case 7: Negative Store Instruction
        instruction = 32'b1111111_00101_00001_010_00010_0100011;  // SW instruction with negative immediate
        #10;
        $display("Negative Store Instruction Immediate: %0d", $signed(immediate));  // Expected: FFF3 (or -13)

        // Test case 8: Negative Immediate (ADDI)
        instruction = 32'b111110000000_00001_000_00010_0010011;  // ADDI instruction with negative immediate
        #10;
        $display("Negative ADDI Instruction Immediate: %0d", $signed(immediate));  // Expected: FF80 (or -128)

        // End simulation
        $finish;
    end

endmodule
