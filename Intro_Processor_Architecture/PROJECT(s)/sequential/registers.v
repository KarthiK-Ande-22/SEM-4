///////////////////////////////////////////////register block///////////////////////////////////////////////

module Reg_memory (
    input wire clk,
    input wire rst, // Reset signal
    input wire [31:0] instruction,
    input wire [63:0] write_data,
    input wire RegWrite,
    output reg [63:0] Read_data1,
    output reg [63:0] Read_data2
);
    // Register File (32 registers, each 64-bit)
    reg [63:0] memory [0:31];

    wire [4:0] Read_Register1;
    wire [4:0] Read_Register2;
    wire [4:0] Write_Register;

    // Initialize memory (for simulation)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            memory[i] =i;
    end

    // Decode instruction fields
    assign Read_Register1 = instruction[19:15];
    assign Read_Register2 = instruction[24:20];
    assign Write_Register = instruction[11:7];

    // Read operation (combinational)
    always @(*) begin
        Read_data1 = memory[Read_Register1];
        Read_data2 = memory[Read_Register2];
    end

    // Write operation (sequential, with reset)
    always @(posedge clk or posedge rst) begin
        if (RegWrite && Write_Register != 5'b00000) begin
            memory[Write_Register] <= write_data; // Non-blocking assignment
        end
    end
endmodule
