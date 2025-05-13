
//////////////////////////////////////////////////////Data Memory//////////////////////////////////////////////
module data_memory (
    input wire clk,                 
    input wire [63:0] address,         
    input wire [63:0] write_data,     
    input wire exmem_write,             
    input wire exmem_read,             
    output reg [63:0] memwb_readdata     
);

    reg [63:0] memory [0:255]; // 256 words of 64-bit memory
    initial begin
        // memory[0] = 64'd1;
        // memory[1] = 64'd2;
        // memory[2] = 64'd3;
        // memory[3] = 64'd4;
        // memory[4] = 64'd5;
        // memory[5] = 64'd6;
        // memory[6] = 64'd7;
        // memory[7] = 64'd8;
        $readmemb("data.txt", memory);
    end

    // Asynchronous Memory Read (No clk)
    always @(negedge clk) begin
        if (exmem_read) 
            memwb_readdata <= memory[address[7:0]]; // Read directly (combinational)
    end

    // Synchronous Memory Write (Needs clk)
    always @(posedge clk) begin
        if (exmem_write)
            memory[address[7:0]] <= write_data;  
    end

endmodule

