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
        $dumpfile("cpu_top_tb.vcd");  // Output VCD file
        $dumpvars(0, cpu_top_tb);     // Dump all signals
    end
    
    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;
        
        // Apply Reset
        #10;
        reset = 0;
        
        // Run simulation for some cycles
        #300;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals
    // initial begin
    //     $monitor("Time = %0t | pc = %d | rs1=%d | rs2=%d | res=%d", 
    //      $time, uut.ifid_pc, uut.idex_rs1data,uut.idex_rs2data, uut.alu_result);
    // end
    initial begin
        $monitor("Time = %0t | pc=%d|ifidpc = %d | inst=%b| reg1=%d|reg2=%d|reg3=%d|reg4=%d|reg5=%d|reg6=%d|reg7=%d|reg8=%d|reg9=%d|reeg10=%d|reg15=%d", 
         $time, uut.ifid_pc,uut.pc, uut.ifid_instr,uut.memory[1],uut.memory[2],uut.memory[3],uut.memory[4],uut.memory[5],uut.memory[6],uut.memory[7],uut.memory[8],uut.memory[9],uut.memory[10],uut.memory[15]);
    end
endmodule