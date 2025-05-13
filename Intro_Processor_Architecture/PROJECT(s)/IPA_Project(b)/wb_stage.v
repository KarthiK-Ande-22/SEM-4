


module write_back (
    input wire clk,
    input reg [63:0] memory [0:31];
    input wire [4:0] Write_Register,      
    input wire [63:0] read_data, 
    input wire [63:0] Alu_output,               
    input wire mem_to_reg, 
    output reg [63:0] write_data
);

always @(*) begin
    if(mem_to_reg) begin
        write_data = read_data; // Read data to write_data
        memory[Write_Register] <= write_data;
    end
    else begin
        write_data = Alu_output; // ALU output to write_data
        memory[Write_Register] <= write_data;
    end
end
endmodule



// module write_back (
//     input wire clk,                 
//     input wire [63:0] read_data, 
//     input wire [63:0] Alu_output,               
//     input wire mem_to_reg, 
//     output reg [63:0] write_data
// );


//     // mux64to1 mux5 (.in0(Alu_output), .in1(read_data), .sel(mem_to_reg), .out(write_data));

// always @(*) begin
//     if(mem_to_reg) begin
//         write_data = read_data; // Read data to write_data
//     end
//     else begin
//         write_data = Alu_output; // ALU output to write_data
//     end
// end

// endmodule

