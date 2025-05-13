`include "branch.v"
`timescale 1ns/1ps

module branch_hazard_unit_tb;

    // Testbench signals
    reg branch;
    reg zero;
    reg clk;
    wire flush_ifid;
    wire flush_idex;
    wire pc_src;

    // Instantiate the branch hazard unit
    branch_hazard_unit uut (
        .branch(branch),
        .zero(zero),
        .clk(clk),
        .flush_ifid(flush_ifid),
        .flush_idex(flush_idex),
        .pc_src(pc_src)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize signals
        clk = 0;
        branch = 0;
        zero = 0;
        
        // Apply test cases
        #10 branch = 0; zero = 0; // No branch, no zero -> No flush, PC+4
        #10 branch = 1; zero = 0; // Branch but zero not set -> No flush, PC+4
        #10 branch = 0; zero = 1; // No branch but zero set -> No flush, PC+4
        #10 branch = 1; zero = 1; // Branch and zero set -> Flush, branch target
        
        // End simulation
        #10 $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Branch=%b | Zero=%b | Flush_IFID=%b | Flush_IDEX=%b | PC_SRC=%b",
                 $time, branch, zero, flush_ifid, flush_idex, pc_src);
    end

endmodule
