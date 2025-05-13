`include "data.v"
`timescale 1ns/1ps

module data_memory_tb;

    // Testbench signals
    reg clk;
    reg [63:0] address;
    reg [63:0] write_data;
    reg exmem_write;
    reg exmem_read;
    wire [63:0] memwb_readdata;

    // Instantiate the data_memory module
    data_memory uut (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .exmem_write(exmem_write),
        .exmem_read(exmem_read),
        .memwb_readdata(memwb_readdata)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize clock
        clk = 0;

        // Test 1: Read from memory (address = 3)
        address = 64'd3;
        exmem_read = 1;
        exmem_write = 0;
        #10;
        exmem_read = 0;

        // Test 2: Write to memory (address = 5, data = 100)
        address = 64'd5;
        write_data = 64'd100;
        exmem_write = 1;
        #10;
        exmem_write = 0;

        // Test 3: Read back the written value
        address = 64'd5;
        exmem_read = 1;
        #10;
        exmem_read = 0;

        // Test 4: Write to memory (address = 10, data = 200)
        address = 64'd10;
        write_data = 64'd200;
        exmem_write = 1;
        #10;
        exmem_write = 0;

        // Test 5: Read back the written value
        address = 64'd10;
        exmem_read = 1;
        #10;
        exmem_read = 0;

        // End simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t | Addr=%d | WriteData=%d | ReadData=%d | WriteEnable=%b | ReadEnable=%b", 
                 $time, address, write_data, memwb_readdata, exmem_write, exmem_read);
    end

endmodule
