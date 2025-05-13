`include "registers.v"
`timescale 1ns / 1ps

module Reg_memory_tb;
    // Testbench signals
    reg clk;
    reg rst;
    reg [31:0] instruction;
    reg [63:0] write_data;
    reg RegWrite;
    wire [63:0] Read_data1;
    wire [63:0] Read_data2;

    // Instantiate the module under test
    Reg_memory uut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .write_data(write_data),
        .RegWrite(RegWrite),
        .Read_data1(Read_data1),
        .Read_data2(Read_data2)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period clock

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        RegWrite = 0;
        instruction = 0;
        write_data = 0;

        // Apply reset
        #10 rst = 0;

        // Read from registers 1 and 2
        #10; instruction = {7'b0, 5'b00001, 5'b00010, 15'b0}; #10;
        $display("Reg1: %h, Reg2: %h", Read_data2, Read_data1);

        // Read from registers 3 and 4
        #10; instruction = {7'b0, 5'b00011, 5'b00100, 15'b0}; #10;
        $display("Reg3: %h, Reg4: %h",  Read_data2, Read_data1);

        // Read from registers 5 and 6
        #10; instruction = {7'b0, 5'b00101, 5'b00110, 15'b0}; #10;
        $display("Reg5: %h, Reg6: %h",  Read_data2, Read_data1);

        // Read from registers 7 and 8
        #10; instruction = {7'b0, 5'b00111, 5'b01000, 15'b0}; #10;
        $display("Reg7: %h, Reg8: %h",  Read_data2, Read_data1);
        
        // Finish simulation
        #20;
        $finish;
    end
endmodule

