`timescale 1ns/1ps
`include "hazard.v"
module HazardDetectionUnit_tb;

    // Testbench signals
    reg idex_memread;
    reg [4:0] idex_rd, ifid_rs1, ifid_rs2;
    wire stall;

    // Instantiate the module
    HazardDetectionUnit uut (
        .idex_memread(idex_memread),
        .idex_rd(idex_rd),
        .ifid_rs1(ifid_rs1),
        .ifid_rs2(ifid_rs2),
        .stall(stall)
    );

    // Test procedure
    initial begin
        // No hazard case: idex_memread = 0, stall should be 0
        idex_memread = 0; idex_rd = 5'd3; ifid_rs1 = 5'd1; ifid_rs2 = 5'd2;
        #10;

        // Hazard case: idex_memread = 1, idex_rd == ifid_rs1 (stall should be 1)
        idex_memread = 1; idex_rd = 5'd1; ifid_rs1 = 5'd1; ifid_rs2 = 5'd2;
        #10;

        // Hazard case: idex_memread = 1, idex_rd == ifid_rs2 (stall should be 1)
        idex_rd = 5'd2;
        #10;

        // No hazard case: idex_rd does not match Rs1 or Rs2 (stall should be 0)
        idex_rd = 5'd4;
        #10;

        // Hazard case: Both Rs1 and Rs2 match idex_rd (stall should be 1)
        idex_rd = 5'd5; ifid_rs1 = 5'd5; ifid_rs2 = 5'd5;
        #10;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | MEMRead=%b, IDEX_RD=%d, IFID_RS1=%d, IFID_RS2=%d | Stall=%b",
                 $time, idex_memread, idex_rd, ifid_rs1, ifid_rs2, stall);
    end

endmodule
