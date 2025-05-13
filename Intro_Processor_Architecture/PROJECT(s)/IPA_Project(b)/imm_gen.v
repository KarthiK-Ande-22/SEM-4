
    module imm_gen_all_types (
        input wire [31:0] instruction,
        output reg [63:0] immediate
    );
        wire [6:0] opcode_decide;
        reg [11:0] imm;  

        assign opcode_decide = instruction[6:0];

        always @(*) begin
            imm = instruction[31:20];

            if(opcode_decide == 7'b1100011) begin  // Branch instruction
                imm[11] = instruction[31];
                imm[10] = instruction[7];
                imm[9:4] = instruction[30:25];
                imm[3:0] = instruction[11:8];
            end
        
            else if(opcode_decide == 7'b0000011) begin  // Load instruction
                imm = instruction[31:20];
            end
            
            else if(opcode_decide == 7'b0100011) begin // Store instruction
                imm[11:5] = instruction[31:25];
                imm[4:0] = instruction[11:7];
            end
        end

        always @(*) begin
            immediate = {{52{imm[11]}}, imm}; 
        end
    endmodule

