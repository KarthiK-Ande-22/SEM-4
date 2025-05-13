





module control_alucontrol(
    input [31:0] instruction,
    output reg branch,
    output reg memread,
    output reg memtoreg,
    output reg [1:0] ALUop,
    output reg memwrite,
    output reg alusrc,
    output reg regwrite,
    output reg [3:0] ALUctr // Changed to 4-bit
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
                branch = 0;
                memread = 0;
                memtoreg = 0;
                ALUop = 2'b10;
                memwrite = 0;
                alusrc = 0;
                regwrite = 1;
                case ({funct7, funct3})
                    4'b0000: ALUctr = 4'b0000; // ADD
                    4'b1000: ALUctr = 4'b0001; // SUB
                    4'b0111: ALUctr = 4'b0010; // AND
                    4'b0110: ALUctr = 4'b0011; // OR
                    4'b0100: ALUctr = 4'b0100; // XOR
                    4'b0001: ALUctr = 4'b0110; // SLL
                    default: ALUctr = 4'b0000; // Default to AND
                endcase
            end
            7'b0000011: begin // Load (e.g., lw)
                branch = 0;
                memread = 1;
                memtoreg = 1;
                ALUop = 2'b00;
                memwrite = 0;
                alusrc = 1;
                regwrite = 1;
                ALUctr = 4'b0000; // ADD (for address calculation)
            end
            7'b0100011: begin // Store (e.g., sw)
                branch = 0;
                memread = 0;
                memtoreg = 0;
                ALUop = 2'b00;
                memwrite = 1;
                alusrc = 1;
                regwrite = 0;
                ALUctr = 4'b0000; // ADD (for address calculation)
            end
            7'b0010011: begin // I-type ALU (Immediate)
                branch = 0;
                memread = 0;
                memtoreg = 0;
                ALUop = 2'b10;
                memwrite = 0;
                alusrc = 1;
                regwrite = 1;
                case (funct3)
                    3'b000: ALUctr = 4'b0000; // ADDI
                    3'b010: ALUctr = 4'b0110; // SLTI
                    3'b011: ALUctr = 4'b0100; // XORI
                    3'b100: ALUctr = 4'b0011; // ORI
                    3'b110: ALUctr = 4'b0010; // ANDI
                    default: ALUctr = 4'b0000;
                endcase
            end
            7'b1100011: begin // Branch (e.g., BEQ)
                branch = 1;
                memread = 0;
                memtoreg = 0;
                ALUop = 2'b01;
                memwrite = 0;
                alusrc = 0;
                regwrite = 0;
                ALUctr = 4'b0001; // SUB for comparison
            end
            default: begin
                branch = 0;
                memread = 0;
                memtoreg = 0;
                ALUop = 2'b00;
                memwrite = 0;
                alusrc = 0;
                regwrite = 0;
                ALUctr = 4'b0000;
            end
        endcase
    end
endmodule