
module data_memory (
    input wire clk,                 
    input wire [63:0] address,         
    input wire [63:0] write_data,     
    input wire mem_write,             
    input wire mem_read,             
    output reg [63:0] read_data     
);

    // reg [63:0] memory [0:1023];
    reg [63:0] memory [0:255];

    always @(posedge clk) begin
            if (mem_write) begin
                // memory[address[11:3]] <= write_data;
                memory[address[7:0]] <= write_data;  
            end
            if (mem_read) begin
                // read_data <= memory[address[11:3]]; 
                read_data <= memory[address[7:0]]; 
            end
    end

endmodule



