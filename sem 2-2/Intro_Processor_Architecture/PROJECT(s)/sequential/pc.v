module mux2(
    input [31:0] in0, 
    input [31:0] in1, 
    input sel, 
    output [31:0] out
);
    assign out = sel ? in1 : in0;
endmodule

module pc(
    input clk,
    input reset,
    input branch,
    input zero,
    input [31:0] pcbranch,
    input [31:0] pcupdate,
    output reg [31:0] pcupdated
);
    reg [31:0] pc_reg;
    wire select;
    assign select = branch & zero; // Corrected AND operation

    wire [31:0] x;
    mux2 m1(.in0(pcupdate), .in1(pcbranch), .sel(select), .out(x)); 

    always @(posedge clk or posedge reset) begin
        if (reset) 
            pcupdated  <= 32'h0;
        else 
            pcupdated <= x;
    end
    
    
endmodule

// module instr_mem(
//     input [31:0] pc, 
//     output reg [31:0] instr
// );
//     reg [31:0] memory [0:1023]; // 1K words of memory

//     initial begin
//         // Sample instructions for testing
//         memory[0] = 32'h20020001; 
//         memory[1] = 32'h20030002; 
//         memory[2] = 32'h00621820; 
//         memory[3] = 32'hac030004; 
//         memory[4] = 32'h8c020004; 
//         memory[5] = 32'h00000000; 
//         memory[6] = 32'h20040005;
//         memory[7] = 32'h20050006;
//         memory[8] = 32'h00a42822;
//         memory[9] = 32'hac050008;
//         memory[10] = 32'h8c060008;
//         memory[11] = 32'h00c63024;
//         memory[12] = 32'h00c63825;
//         memory[13] = 32'h00e74026;
//         memory[14] = 32'hac08000C;
//         memory[15] = 32'h8c09000C;
//         memory[16] = 32'h01295027;
//         memory[17] = 32'hac0A0010;
//         memory[18] = 32'h08000000; // Jump to address 0


//     end

//     always @(*) begin
//         instr = memory[pc[9:2]]; // Fetch instruction using word-aligned address
//     end
// endmodule


