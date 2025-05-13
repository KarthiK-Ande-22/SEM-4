

module decode (
    input [31:0] instruction,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [6:0] opcode,
    output reg branch,
    output reg [3:0] alu_op,
    output reg alu_src,
    output reg [63:0] imm,
    output reg memread,
    output reg memwrite,
    output reg memtoreg,
    output reg regwrite
);

    always @(*) begin
        opcode = instruction[6:0];
        rd     = instruction[11:7];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        rs1    = instruction[19:15];
        rs2    = instruction[24:20];

        // Initialize control signals
        branch   = 0;
        alu_op   = 4'b0000;
        alu_src  = 0;
        imm      = 64'b0;
        memwrite = 0;
        memtoreg = 0;
        memread  = 0;
        regwrite = 0;

        // Decode based on opcode
        case (opcode)
            7'b0110011: begin // R-type
                regwrite = 1;
                case (funct3)
                    3'b000: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0010; // ADD
                            7'b0100000: alu_op = 4'b0110; // SUB
                        endcase
                    end
                    3'b001: alu_op = 4'b0011; // SLL
                    3'b100: alu_op = 4'b1001; // XOR
                    3'b101: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0100; // SRL
                            7'b0100000: alu_op = 4'b0101; // SRA
                        endcase
                    end
                    3'b110: alu_op = 4'b0001; // OR
                    3'b111: alu_op = 4'b0000; // AND
                endcase
            end
            7'b0010011: begin // I-type
                regwrite = 1;
                alu_src  = 1;
                imm      = {{52{instruction[31]}}, instruction[31:20]}; // Sign-extend
                case (funct3)
                    3'b000: alu_op = 4'b0010; // ADDI
                    3'b001: alu_op = 4'b0011; // SLLI
                    3'b100: alu_op = 4'b1001; // XORI
                    3'b101: begin
                        case (funct7)
                            7'b0000000: alu_op = 4'b0100; // SRLI
                            7'b0100000: alu_op = 4'b0101; // SRAI
                        endcase
                    end
                    3'b110: alu_op = 4'b0001; // ORI
                    3'b111: alu_op = 4'b0000; // ANDI
                endcase
            end
            7'b1100011: begin // Branch
                branch   = 1;
                alu_src  = 0;
                imm      = {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // Sign-extend
                case (funct3)
                    3'b000: alu_op = 4'b1010; // BEQ
                    3'b001: alu_op = 4'b1011; // BNE
                    3'b100: alu_op = 4'b1010; // SLT
                    3'b101: begin // BGE
                        alu_op = 4'b1010;
                        rs1    = instruction[24:20];
                        rs2    = instruction[19:15];
                    end
                    3'b111: begin // BGEU
                        alu_op = 4'b0111;
                        rs1    = instruction[24:20];
                        rs2    = instruction[19:15];
                    end
                endcase
            end
            default: begin
                // Default case for undefined instructions
                branch   = 0;
                alu_op   = 4'b0000;
                alu_src  = 0;
                imm      = 64'b0;
                memwrite = 0;
                memtoreg = 0;
                memread  = 0;
                regwrite = 0;
            end
        endcase
        $display("Instruction: %h", instruction);
$display("Opcode: %b", opcode);
$display("RD: %d", rd);
$display("Funct3: %b", funct3);
$display("RS1: %d", rs1);
$display("RS2: %d", rs2);
$display("Funct7: %b", funct7);
$display("Immediate: %h", imm);
$display("Control Signals: Branch=%b, ALU_OP=%b, ALU_SRC=%b, MemRead=%b, MemWrite=%b, MemToReg=%b, RegWrite=%b", 
         branch, alu_op, alu_src, memread, memwrite, memtoreg, regwrite);
        end
endmodule
