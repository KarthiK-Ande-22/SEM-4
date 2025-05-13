// ============================
// Instruction Memory
// ============================
module instruction_memory (
    input [31:0] pc,
    output reg [31:0] instruction
);
    reg [31:0] mem [0:255]; // 256 32-bit instructions

    initial begin
        $readmemb("instructions.mem", mem); // Load instructions from file
    end

    always @(*) begin
        instruction = mem[pc >> 2]; // Fetch instruction
    end
endmodule

// ============================
// Register File
// ============================
module register_file (
    input clk, 
    input regwrite,
    input [4:0] rs1, rs2, rd,
    input [31:0] writedata,
    output reg [31:0] readdata1, readdata2
);
    reg [31:0] registers [0:31];

    always @(*) begin
        readdata1 = registers[rs1];
        readdata2 = registers[rs2];
    end

    always @(posedge clk) begin
        if (regwrite)
            registers[rd] <= writedata;
    end
endmodule

// ============================
// ALU
// ============================
module alu (
    input [31:0] a, b,
    input [2:0] ALUctr,
    output reg [31:0] result,
    output zero
);
    assign zero = (result == 0);

    always @(*) begin
        case (ALUctr)
            3'b000: result = a + b;  // ADD
            3'b001: result = a - b;  // SUB
            3'b010: result = a & b;  // AND
            3'b011: result = a | b;  // OR
            3'b100: result = a ^ b;  // XOR
            3'b101: result = a << b; // SLL
            3'b110: result = (a < b) ? 1 : 0; // SLT
            default: result = 0;
        endcase
    end
endmodule

// ============================
// Control Unit
// ============================
module control (
    input [6:0] opcode,
    output reg branch, memread, memtoreg,
    output reg [1:0] ALUop,
    output reg memwrite, alusrc, regwrite
);
    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                branch = 0; memread = 0; memtoreg = 0; ALUop = 2'b10;
                memwrite = 0; alusrc = 0; regwrite = 1;
            end
            7'b0000011: begin // Load
                branch = 0; memread = 1; memtoreg = 1; ALUop = 2'b00;
                memwrite = 0; alusrc = 1; regwrite = 1;
            end
            7'b0010011: begin // I-type ALU
                branch = 0; memread = 0; memtoreg = 0; ALUop = 2'b10;
                memwrite = 0; alusrc = 1; regwrite = 1;
            end
            7'b1100011: begin // Branch
                branch = 1; memread = 0; memtoreg = 0; ALUop = 2'b01;
                memwrite = 0; alusrc = 0; regwrite = 0;
            end
            default: begin
                branch = 0; memread = 0; memtoreg = 0; ALUop = 2'b00;
                memwrite = 0; alusrc = 0; regwrite = 0;
            end
        endcase
    end
endmodule

// ============================
// ALU Control
// ============================
module alucontrol (
    input [6:0] opcode,
    input [31:0] instruction,
    output reg [2:0] ALUctr
);
    wire [2:0] funct3 = instruction[14:12];
    wire funct7 = instruction[30];

    always @(*) begin
        case (opcode)
            7'b0110011: begin // R-type
                case ({funct7, funct3})
                    4'b0000: ALUctr = 4'b000; // ADD
                    4'b1000: ALUctr = 3'b001; // SUB
                    4'b0111: ALUctr = 3'b010; // AND
                    4'b0110: ALUctr = 3'b011; // OR
                    4'b0100: ALUctr = 3'b100; // XOR
                    4'b0001: ALUctr = 3'b101; // SLL
                    4'b0010: ALUctr = 3'b110; // SLT
                    default: ALUctr = 3'b000;
                endcase
            end
            7'b0010011: begin // I-type
                case (funct3)
                    3'b000: ALUctr = 3'b000; // ADDI
                    3'b010: ALUctr = 3'b110; // SLTI
                    3'b011: ALUctr = 3'b100; // XORI
                    3'b100: ALUctr = 3'b011; // ORI
                    3'b110: ALUctr = 3'b010; // ANDI
                    default: ALUctr = 3'b000;
                endcase
            end
            7'b1100011: ALUctr = 3'b001; // Branch
            default: ALUctr = 3'b000;
        endcase
    end
endmodule

// ============================
// Data Memory
// ============================
module data_memory (
    input clk, memwrite, memread,
    input [31:0] address, writedata,
    output reg [31:0] readdata
);
    reg [31:0] memory [0:255];

    always @(posedge clk) begin
        if (memwrite) memory[address >> 2] <= writedata;
    end

    always @(*) begin
        if (memread) readdata = memory[address >> 2];
    end
endmodule

// ============================
// Top Module
// ============================
module processor (
    input clk, reset
);
    reg [31:0] pc;
    wire [31:0] instruction, readdata1, readdata2, writedata, imm, aluresult, memdata;
    wire branch, memread, memtoreg, memwrite, alusrc, regwrite, zero;
    wire [1:0] ALUop;
    wire [2:0] ALUctr;

    instruction_memory im(pc, instruction);
    control ctrl(instruction[6:0], branch, memread, memtoreg, ALUop, memwrite, alusrc, regwrite);
    register_file rf(clk, regwrite, instruction[19:15], instruction[24:20], instruction[11:7], writedata, readdata1, readdata2);
    alucontrol alu_ctrl(instruction[6:0], instruction, ALUctr);
    alu myalu(readdata1, alusrc ? imm : readdata2, ALUctr, aluresult, zero);
    data_memory dm(clk, memwrite, memread, aluresult, readdata2, memdata);

    assign writedata = memtoreg ? memdata : aluresult;

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 0;
        else
            pc <= pc + 4;
    end
endmodule



module processor_tb;
    reg clk, reset;
    
    // Instantiate the processor
    processor uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock generation
    always #5 clk = ~clk; // Generate a clock with a period of 10 time units
    
    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        #10 reset = 0; // Release reset after some time
        
        // Run simulation for a few cycles
        #200;
        
        // End simulation
        $finish;
    end
    
    initial begin
        $dumpfile("processor_tb.vcd"); // VCD file for waveform analysis
        $dumpvars(0, processor_tb);
    end
endmodule