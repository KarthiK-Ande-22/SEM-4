
//////////////////////////////////////////////Control block//////////////////////////////////////////////

module control_alucontrol(
    input [31:0] instruction,
    input clk,
    output reg idex_branch,
    output reg idex_memread,
    output reg idex_memtoreg,
    output reg [1:0] idex_ALUop,
    output reg idex_memwrite,
    output reg idex_alusrc,
    output reg idex_regwrite,
    output reg [3:0] idex_ALUctr
);
    wire [2:0] funct3;
    wire funct7;
    wire [6:0] opcode;
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[30];
    
    always @(*) begin
        
            case (opcode)
                7'b0110011: begin // R-type
                    idex_branch = 0;
                    idex_memread = 0;
                    idex_memtoreg = 0;
                    idex_ALUop = 2'b10;
                    idex_memwrite = 0;
                    idex_alusrc = 0;
                    idex_regwrite = 1;
                    case ({funct7, funct3})
                        4'b0000: idex_ALUctr = 4'b0000; // ADD
                        4'b1000: idex_ALUctr = 4'b0001; // SUB
                        4'b0111: idex_ALUctr = 4'b0010; // AND
                        4'b0110: idex_ALUctr = 4'b0011; // OR
                        4'b0100: idex_ALUctr = 4'b0100; // XOR
                        4'b0001: idex_ALUctr = 4'b0110; // SLL
                        default: idex_ALUctr = 4'b0000; // Default to AND
                    endcase
                end
                7'b0000011: begin // Load (e.g., lw)
                    idex_branch = 0;
                    idex_memread = 1;
                    idex_memtoreg = 1;
                    idex_ALUop = 2'b00;
                    idex_memwrite = 0;
                    idex_alusrc = 1;
                    idex_regwrite = 1;
                    idex_ALUctr = 4'b0000; // ADD (for address calculation)
                end
                7'b0100011: begin // Store (e.g., sw)
                    idex_branch = 0;
                    idex_memread = 0;
                    idex_memtoreg = 0;
                    idex_ALUop = 2'b00;
                    idex_memwrite = 1;
                    idex_alusrc = 1;
                    idex_regwrite = 0;
                    idex_ALUctr = 4'b0000; // ADD (for address calculation)
                end
                7'b0010011: begin // I-type ALU (Immediate)
                    idex_branch = 0;
                    idex_memread = 0;
                    idex_memtoreg = 0;
                    idex_ALUop = 2'b10;
                    idex_memwrite = 0;
                    idex_alusrc = 1;
                    idex_regwrite = 1;
                    case (funct3)
                        3'b000: idex_ALUctr = 4'b0000; // ADDI
                        3'b010: idex_ALUctr = 4'b0110; // SLTI
                        3'b011: idex_ALUctr = 4'b0100; // XORI
                        3'b100: idex_ALUctr = 4'b0011; // ORI
                        3'b110: idex_ALUctr = 4'b0010; // ANDI
                        default: idex_ALUctr = 4'b0000;
                    endcase
                end
                7'b1100011: begin // Branch (e.g., BEQ)
                    idex_branch = 1;
                    idex_memread = 0;
                    idex_memtoreg = 0;
                    idex_ALUop = 2'b01;
                    idex_memwrite = 0;
                    idex_alusrc = 0;
                    idex_regwrite = 0;
                    idex_ALUctr = 4'b0001; // SUB for comparison
                end
                default: begin
                    idex_branch = 0;
                    idex_memread = 0;
                    idex_memtoreg = 0;
                    idex_ALUop = 2'b00;
                    idex_memwrite = 0;
                    idex_alusrc = 0;
                    idex_regwrite = 0;
                    idex_ALUctr = 4'b0000;
                end
            endcase
        
        
    end
endmodule