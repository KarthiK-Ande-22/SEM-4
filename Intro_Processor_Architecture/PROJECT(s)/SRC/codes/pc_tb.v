`include "pc.v"
module tb_pc;
    // Inputs
    reg clk;
    reg reset;
    reg branch;
    reg zero;
    reg [31:0] pcbranch;
    reg [31:0] pcupdate;

    // Outputs
    wire [31:0] pcupdated;

    // Instantiate the pc module
    pc uut (
        .clk(clk),
        .reset(reset),
        .branch(branch),
        .zero(zero),
        .pcbranch(pcbranch),
        .pcupdate(pcupdate),
        .pcupdated(pcupdated)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // 10ns period, 50MHz clock
    end

    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        branch = 0;
        zero = 0;
        pcbranch = 32'h0000_0004;
        pcupdate = 32'h0000_0008;

        // Apply reset
        #5 reset = 1;
        #10 reset = 0;

        // Test case 1: No branch (branch = 0)
        #10 branch = 0;
        zero = 0;  // pcupdate should be selected
        #10;

        // Test case 2: Branch taken (branch = 1, zero = 1)
        #10 branch = 1;
        zero = 1;  // pcbranch should be selected
        #10;

        // Test case 3: Branch not taken (branch = 1, zero = 0)
        #10 branch = 1;
        zero = 0;  // pcupdate should be selected
        #10;

        // Test case 4: Reset again
        #10 reset = 1;
        #10 reset = 0;

        // Finish the simulation
        #10 $finish;
    end

    // Monitor the outputs
    initial begin
        $monitor("Time: %0t, Reset: %b, Branch: %b, Zero: %b, pcupdated: %h", $time, reset, branch, zero, pcupdated);
    end

endmodule
