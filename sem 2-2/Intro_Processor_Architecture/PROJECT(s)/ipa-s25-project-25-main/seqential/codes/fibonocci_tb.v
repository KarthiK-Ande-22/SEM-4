`include "fibonocci.v"
`timescale 1ns / 1ps


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
            #420;
            
            // End simulation
            $finish;
        end
        
    initial begin
        $dumpfile("cpu_top_tb.vcd"); // VCD (Value Change Dump) file
        $dumpvars(0, cpu_top_tb); // Dump all variables in this module
    end
    
        // Monitor important signals|add=%b|2ndadd=%b
        initial begin
            $monitor("Time = %0t | pc = %d |reg1=%d | reg2=%d | reg3=%d | reg4=%d| reg8=%d| reg15=%d", 
            $time, uut.pc, uut.memory[1],uut.memory[2],uut.memory[3],uut.memory[4],uut.memory[8],uut.memory[15]);

        end
    endmodule