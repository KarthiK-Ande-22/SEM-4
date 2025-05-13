module processor_tb;
    reg clk;
    integer i;
    
    processor uut (.clk(clk));

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Generate a clock signal
    end

    initial begin
        // Initialize register values
        #10;
        uut.register_file[1] = 64'd10;
        uut.register_file[2] = 64'd20;
        uut.register_file[3] = 64'd30;

        // Load instructions
        uut.inst_mem[0] = 32'b0000000_00010_00001_000_00111_0110011;
        uut.inst_mem[1] = 32'b0000000_00100_00011_000_01000_0110011;

        // Wait until all instructions are executed
        wait (uut.pc > 8); // Assuming 4-byte instructions, adjust as needed

        #10; // Small delay before stopping
        $finish;
    end
endmodule
