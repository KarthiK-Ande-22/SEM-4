module memory (
    input [63:0] alu_result,
    input clk,
    input memread,
    input memwrite,
    input [63:0] rs2,
    output reg [63:0] mem_data
);

    reg [63:0] data_memory [0:255];

    initial begin
        // Initialize memory with some values (if needed)
    end

    always @(*) begin
        if (memread) begin
            // Read memory data from the address specified by alu_result
            mem_data = data_memory[alu_result[7:0]]; // Taking lower 8 bits for address
        end else begin
            mem_data = 64'd0; 
        end
        if (memwrite) begin
            data_memory[alu_result[7:0]] <= rs2;
        end
    end
endmodule
