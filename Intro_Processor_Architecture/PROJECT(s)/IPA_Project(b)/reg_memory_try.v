

reg [63:0] memory [0:31];

module Reg_memory (
    input wire clk, 
    input wire [63:0] memory [0:31],
    input wire [31:0] instruction,   

    input wire [63:0] write_data, 
    input wire RegWrite, 
    output reg [63:0] Read_data1,
    output reg [63:0] Read_data2
);
    reg [4:0] Read_Register1;
    reg [4:0] Read_Register2;
    reg [4:0] Write_Register;

    always @(*) begin
        Read_Register1 = instruction[19:15];
        Read_Register2 = instruction[24:20];
        Write_Register = instruction[11:7];
    end

    always @(*) begin
        Read_data1 = memory[Read_Register1];
        Read_data2 = memory[Read_Register2];
    end

    always @(posedge clk) begin
            if (RegWrite) begin
                memory[Write_Register] <= write_data;
            end
    end

endmodule

reg [4:0] Write_Register;
Write_Register=instruction[11:7];
if(RegWrite) begin
    if(mem_to_reg) begin
        memory[Write_Register] <= read_data;
    end
    else begin
        memory[Write_Register] <= Alu_output;
    end
end