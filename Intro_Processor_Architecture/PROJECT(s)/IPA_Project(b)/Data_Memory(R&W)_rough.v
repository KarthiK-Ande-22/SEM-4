// module Data_Memory (
    
//     input [63:0] address ,
//     input [63:0] write_data ,
//     input memWrite ,
//     input memRead ,
//     output reg [63:0] data_read 
// );

// reg [63:0] datamemory [0:1023];

// // how many bits address is needed to access 256 locations ?

// always @ (*) begin
//     if(memRead) begin
//         data_read = datamemory[address];
//     end

//     if(memWrite) begin
//         datamemory[address] = write_data;
//     end

// end
// endmodule 



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



