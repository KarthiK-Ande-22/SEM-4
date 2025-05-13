`include "wrapper.v"
module cpu_top_tb;
    reg clk;
    reg reset;
    
    // Instantiate CPU Top Module
    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock Generation
    always #5 clk = ~clk; // 10ns clock period (100MHz)
    
    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;
        
        // Apply Reset
        #10;
        reset = 0;
        
        // Run simulation for some cycles
        #100;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals
    initial begin
        $monitor("Time = %0t | pc = %d | rs1=%d | rs2=%d | res=%d", 
         $time, uut.ifid_pc, uut.idex_rs1data,uut.idex_rs2data, uut.alu_result);
    end
endmodule