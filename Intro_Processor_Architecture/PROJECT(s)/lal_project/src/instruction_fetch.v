module instruction_fetch (                        
    input [31:0] pc,       
    output reg [31:0] instruction
);
    reg [31:0] inst_mem [0:255]; 
    
    initial begin
        inst_mem[0] = 32'b0000000_00010_00001_000_00111_0110011; 
        inst_mem[1] = 32'b0000000_00100_00011_000_01000_0110011; 
        inst_mem[2] = 32'b0100000_00111_01000_000_00101_0110011; 
    end

    always @(*) begin
        instruction = inst_mem[pc[9:2]];
        $display("Fetching instruction: %b at PC: %d", instruction, pc);
        end
endmodule
