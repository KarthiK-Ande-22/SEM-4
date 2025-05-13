`include "Forwarding_unit.v"
`timescale 1ns / 1ps

module forwarding_unit_tb;

    // Inputs
    reg [4:0] id_ex_Rs1;
    reg [4:0] id_ex_Rs2;
    reg [4:0] ex_mem_rd;
    reg [4:0] mem_wb_rd;
    reg ex_mem_Regwrite;
    reg mem_wb_Regwrite;

    // Outputs
    wire [1:0] forwardA;
    wire [1:0] forwardB;

    // Instantiate the forwarding unit
    forwarding_unit uut (
        .id_ex_Rs1(id_ex_Rs1),
        .id_ex_Rs2(id_ex_Rs2),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_Regwrite(ex_mem_Regwrite),
        .mem_wb_Regwrite(mem_wb_Regwrite),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );

    // Stimulus
    initial begin
        $dumpfile("forwarding_unit_tb.vcd");  // VCD dump for waveform analysis
        $dumpvars(0, forwarding_unit_tb);

        // Test 1: No forwarding (Rs1 and Rs2 do not match EX/MEM or MEM/WB)
        id_ex_Rs1 = 5'd1; id_ex_Rs2 = 5'd2;
        ex_mem_rd = 5'd3; mem_wb_rd = 5'd4;
        ex_mem_Regwrite = 1'b0; mem_wb_Regwrite = 1'b0;
        #10;
        
        // Test 2: Forward from EX/MEM stage to Rs1
        ex_mem_rd = 5'd1; ex_mem_Regwrite = 1'b1;
        #10;

        // Test 3: Forward from EX/MEM stage to Rs2
        ex_mem_rd = 5'd2;
        #10;

        // Test 4: Forward from MEM/WB stage to Rs1 (EX/MEM doesn't match)
        ex_mem_rd = 5'd3; ex_mem_Regwrite = 1'b0;
        mem_wb_rd = 5'd1; mem_wb_Regwrite = 1'b1;
        #10;

        // Test 5: Forward from MEM/WB stage to Rs2 (EX/MEM doesn't match)
        mem_wb_rd = 5'd2;
        #10;

        // Test 6: EX/MEM has priority over MEM/WB (forwarding from EX/MEM)
        ex_mem_rd = 5'd1; ex_mem_Regwrite = 1'b1;
        mem_wb_rd = 5'd1; mem_wb_Regwrite = 1'b1;
        #10;

        // Test 7: Edge case where rd = 0 (No forwarding should happen)
        id_ex_Rs1 = 5'd0; id_ex_Rs2 = 5'd0;
        ex_mem_rd = 5'd0; mem_wb_rd = 5'd0;
        ex_mem_Regwrite = 1'b1; mem_wb_Regwrite = 1'b1;
        #10;

        // Test 8: Both Rs1 and Rs2 get forwarded from EX/MEM
        id_ex_Rs1 = 5'd5; id_ex_Rs2 = 5'd6;
        ex_mem_rd = 5'd5; mem_wb_rd = 5'd6;
        ex_mem_Regwrite = 1'b1; mem_wb_Regwrite = 1'b0;
        #10;

        // Test 9: Both Rs1 and Rs2 get forwarded from MEM/WB
        ex_mem_Regwrite = 1'b0; mem_wb_Regwrite = 1'b1;
        #10;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Rs1=%d, Rs2=%d | EX/MEM rd=%d, MEM/WB rd=%d | EX/MEM RW=%b, MEM/WB RW=%b | forwardA=%b, forwardB=%b",
                  $time, id_ex_Rs1, id_ex_Rs2, ex_mem_rd, mem_wb_rd, ex_mem_Regwrite, mem_wb_Regwrite, forwardA, forwardB);
    end

endmodule

// ######################### Expected outputs:------ ############################


// Time=0 | Rs1=1, Rs2=2 | EX/MEM rd=3, MEM/WB rd=4 | EX/MEM RW=0, MEM/WB RW=0 | forwardA=00, forwardB=00
// Time=10 | Rs1=1, Rs2=2 | EX/MEM rd=1, MEM/WB rd=4 | EX/MEM RW=1, MEM/WB RW=0 | forwardA=10, forwardB=00
// Time=20 | Rs1=1, Rs2=2 | EX/MEM rd=2, MEM/WB rd=4 | EX/MEM RW=1, MEM/WB RW=0 | forwardA=00, forwardB=10
// Time=30 | Rs1=1, Rs2=2 | EX/MEM rd=3, MEM/WB rd=1 | EX/MEM RW=0, MEM/WB RW=1 | forwardA=01, forwardB=00
// Time=40 | Rs1=1, Rs2=2 | EX/MEM rd=3, MEM/WB rd=2 | EX/MEM RW=0, MEM/WB RW=1 | forwardA=00, forwardB=01
// Time=50 | Rs1=1, Rs2=2 | EX/MEM rd=1, MEM/WB rd=1 | EX/MEM RW=1, MEM/WB RW=1 | forwardA=10, forwardB=00
// Time=60 | Rs1=0, Rs2=0 | EX/MEM rd=0, MEM/WB rd=0 | EX/MEM RW=1, MEM/WB RW=1 | forwardA=00, forwardB=00
// Time=70 | Rs1=5, Rs2=6 | EX/MEM rd=5, MEM/WB rd=6 | EX/MEM RW=1, MEM/WB RW=0 | forwardA=10, forwardB=00
// Time=80 | Rs1=5, Rs2=6 | EX/MEM rd=5, MEM/WB rd=6 | EX/MEM RW=0, MEM/WB RW=1 | forwardA=00, forwardB=01
