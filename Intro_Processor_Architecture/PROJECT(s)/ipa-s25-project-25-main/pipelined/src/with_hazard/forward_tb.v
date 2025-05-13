`timescale 1ns/1ps
`include "forward.v"
module forwarding_unit_tb;

    // Testbench signals
    reg [4:0] id_ex_Rs1, id_ex_Rs2, ex_mem_rd, mem_wb_rd;
    reg ex_mem_Regwrite, mem_wb_Regwrite;
    wire [1:0] forwardA, forwardB;

    // Instantiate the forwarding_unit module
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

    // Test procedure
    initial begin
        // Default case: No forwarding
        id_ex_Rs1 = 5'd1; id_ex_Rs2 = 5'd2;
        ex_mem_rd = 5'd0; mem_wb_rd = 5'd0;
        ex_mem_Regwrite = 0; mem_wb_Regwrite = 0;
        #10;

        // Case 1: Forward from EX/MEM to Rs1
        ex_mem_rd = 5'd1; ex_mem_Regwrite = 1;
        #10;

        // Case 2: Forward from EX/MEM to Rs2
        ex_mem_rd = 5'd2;
        #10;

        // Case 3: Forward from MEM/WB to Rs1
        ex_mem_Regwrite = 0;  // Disable EX/MEM forwarding
        mem_wb_rd = 5'd1; mem_wb_Regwrite = 1;
        #10;

        // Case 4: Forward from MEM/WB to Rs2
        mem_wb_rd = 5'd2;
        #10;

        // Case 5: Both EX/MEM and MEM/WB write to Rs1 (EX/MEM should take priority)
        ex_mem_rd = 5'd1; ex_mem_Regwrite = 1;
        mem_wb_rd = 5'd1; mem_wb_Regwrite = 1;
        #10;

        // Case 6: Both EX/MEM and MEM/WB write to Rs2 (EX/MEM should take priority)
        ex_mem_rd = 5'd2;
        mem_wb_rd = 5'd2;
        #10;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Rs1=%d, Rs2=%d | EX/MEM Rd=%d, MEM/WB Rd=%d | EX/MEM Regwrite=%b, MEM/WB Regwrite=%b | ForwardA=%b, ForwardB=%b",
                 $time, id_ex_Rs1, id_ex_Rs2, ex_mem_rd, mem_wb_rd, ex_mem_Regwrite, mem_wb_Regwrite, forwardA, forwardB);
    end

endmodule
