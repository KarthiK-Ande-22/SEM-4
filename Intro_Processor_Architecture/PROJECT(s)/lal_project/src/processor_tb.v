`timescale 1ns / 1ps

module processor_tb();

    reg clk;
    reg [1:0] instr_count = 0; // Counter for executed instructions
    wire [31:0] pc;
    wire [31:0] if_instruction;
    wire [63:0] ex_alu_result;
    wire [63:0] mem_data;

    // Instantiate the processor module
    processor uut (
        .clk(clk)
    );

    always #10 clk = ~clk; // 10ns period

    // Initialize testbench
    initial begin
        clk = 1'b0;
        instr_count = 0; // Initialize counter

        // Wait for a few clock cycles to observe the operations
        #10;

        $display("Register x1 (a): %d", uut.register_file[1]);
        $display("Register x2 (b): %d", uut.register_file[2]);
        $display("Register x3 (b): %d", uut.register_file[3]);
        $display("Register x4 (b): %d", uut.register_file[4]);
        $display("Register x5 (result): %d", uut.register_file[5]);
        $display("Register x7 (result): %d", uut.register_file[7]);
        $display("Register x8 (result): %d", uut.register_file[8]);

        // End simulation after 3 instructions
        $finish;
    end

endmodule
