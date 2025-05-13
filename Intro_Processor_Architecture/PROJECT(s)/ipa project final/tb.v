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
        #70;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals

    // always @(posedge clk) begin
    //     $monitor("Time = %0t | clk = %d |pc = %d | rs1=%d | rs2=%d| reg2=%d|reg4=%d |reg5=%d", 
    //      $time,clk, uut.ifid_pc, uut.idex_rs1, uut.idex_rs2, uut.memory[2],uut.memory[4],uut.memory[5]);
    //     end

    initial begin
        $monitor("Time = %0t | pc=%d|ifidpc = %d | inst=%b| reg2=%d|reg4=%d|reg5=%d|fwdA=%d|fwdB=%d|rs2data=%d|", 
         $time, uut.ifid_pc,uut.pc, uut.ifid_instr,uut.memory[2],uut.memory[4],uut.memory[5],uut.forwardA,uut.forwardB,uut.exmem_rs2data);
    end
    // initial begin
    //     $monitor("Time = %0t | pc = %d |stall=%d|forwardA=%d|forwardB=%d", 
    //      $time, uut.ifid_pc, uut.stall,uut.forwardA,uut.forwardB);       
    // end

    // initial begin
    //     $monitor("Time = %0t | pc = %d | idexrs1=%d | idexrs2=%d| exmemrd=%d|memwbrd=%d|finalrs1=%d|finalrs2=%d|frwdA=%d|frwdB=%d", 
    //      $time, uut.ifid_pc,uut.idex_rs1,uut.idex_rs2,uut.exmem_rd,uut.memwb_rd,uut.final_rs1data,uut.final_rs2data,uut.forwardA,uut.forwardB);
    // end

endmodule