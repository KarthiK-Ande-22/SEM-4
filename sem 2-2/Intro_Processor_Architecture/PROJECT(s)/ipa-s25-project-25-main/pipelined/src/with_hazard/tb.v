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
        #600;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals

    // always @(posedge clk) begin
    //     $monitor("Time = %0t | clk = %d |pc = %d | rs1=%d | rs2=%d| reg2=%d|reg4=%d |reg5=%d", 
    //      $time,clk, uut.ifid_pc, uut.idex_rs1, uut.idex_rs2, uut.memory[2],uut.memory[4],uut.memory[5]);
    //     end
    // $dumpvars(0,cpu_top_tb);
    initial begin
        $dumpfile("cpu_top_tb.vcd");
        $dumpvars(0,cpu_top_tb);
    end

    initial begin
        $monitor("Time = %0t|fibonocci sequence=%d |pc=%d", 
         $time,uut.memory[4],uut.ifid_pc);
    end
    // initial begin
    //     $monitor("Time = %0t | pc = %d |stall=%d|forwardA=%d|forwardB=%d", 
    //      $time, uut.ifid_pc, uut.stall,uut.forwardA,uut.forwardB);       
    // end

    // initial begin
    //     $monitor("Time = %0t | pc = %d | rs4=%d | rs5=%d| rs6=%d | rs10=%d", 
    //      $time, uut.ifid_pc,uut.memory[4],uut.memory[5],uut.memory[6],uut.memory[10]);
    // end

    // initial begin
    //     $monitor("Time = %0t| rs1=%d ", 
    //      $time,uut.memory[1]);
    // end
    

endmodule
