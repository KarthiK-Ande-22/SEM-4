module mux2(
    input [31:0] in0, 
    input [31:0] in1, 
    input sel, 
    output [31:0] out
);
    assign out = sel ? in1 : in0;
endmodule



///////////////////////////////////////////////instruction memory block///////////////////////////////////////////////

module instr_mem(
    input [31:0] pc, 
    output reg [31:0] instr
);
    reg [31:0] memory [0:1023]; // 1K words of memory

    initial begin
        // Sample instructions for testing
        memory[0] = 32'h20020001; 
        memory[1] = 32'h20030002; 
        memory[2] = 32'h00621820; 
        memory[3] = 32'hac030004; 
        memory[4] = 32'h8c020004; 
        memory[5] = 32'h00000000; 
        memory[6] = 32'h20040005;
        memory[7] = 32'h20050006;
        memory[8] = 32'h00a42822;
        memory[9] = 32'hac050008;
        memory[10] = 32'h8c060008;
        memory[11] = 32'h00c63024;
        memory[12] = 32'h00c63825;
        memory[13] = 32'h00e74026;
        memory[14] = 32'hac08000C;
        memory[15] = 32'h8c09000C;
        memory[16] = 32'h01295027;
        memory[17] = 32'hac0A0010;
        memory[18] = 32'h08000000; // Jump to address 0
        

    end

    always @(*) begin
        instr = memory[pc[9:2]]; // Fetch instruction using word-aligned address
    end
endmodule








///////////////////////////////////////////////register block///////////////////////////////////////////////
module register_file (
    input clk, 
    input regwrite,
    input [4:0] rs1, rs2, rd,
    input [63:0] writedata,
    output reg [63:0] readdata1, readdata2
);
    reg [63:0] registers [0:63];

    always @(*) begin
        readdata1 = registers[rs1];
        readdata2 = registers[rs2];
    end

    always @(negedge clk) begin
        if (regwrite)
            registers[rd] <= writedata;
    end
endmodule




///////////////////////////////////////////////alu block///////////////////////////////////////////////

`include "all_in_one.v"

module execution (
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    input [63:0] imm,
    input alusrc,
    output reg [63:0] result,
    output reg zero
);

wire [63:0] ADD_OUT;
wire [63:0] SUB_OUT;
wire [63:0] AND_OUT;
wire [63:0] OR_OUT;
wire [63:0] XOR_OUT;
wire [63:0] SLR_OUT;
wire [63:0] SLL_OUT;
wire [63:0] SRA_OUT;
wire SLT_OUT;
wire SLTU_OUT;
wire cout_adder;
wire cout_subtractor;
wire[63:0] operb;
assign operb = alusrc ? imm : b;

ADD adder (.a(a), .b(operb), .cin(1'b0), .sum(ADD_OUT), .cout(cout_adder));
SUB subtractor (.a(a), .b(operb), .sum(SUB_OUT), .cout(cout_subtractor));
AND_64_bit and_gate (.a(a), .b(operb), .and_ab(AND_OUT));
OR_64_bit or_gate (.a(a), .b(operb), .or_ab(OR_OUT));
XOR_64_bit xor_gate (.a(a), .b(operb), .xor_ab(XOR_OUT));
shift_logical_right slr (.a(a), .b(operb[5:0]), .slr_ab(SLR_OUT));
shift_logical_left sll (.a(a), .b(operb[5:0]), .sll_ab(SLL_OUT));
shift_Arithmetic_right sra (.a(a), .b(operb[5:0]), .sra_ab(SRA_OUT));
set_less_than slt (.a(a), .b(b), .slt(SLT_OUT));
set_less_than_unsigned sltu (.a(a), .b(operb), .sltu(SLTU_OUT));

always @(*) begin
    case(op)
        4'b0000: result = ADD_OUT;
        4'b0001: result = SUB_OUT;
        4'b0010: result = AND_OUT;
        4'b0011: result = OR_OUT;
        4'b0100: result = XOR_OUT;
        4'b0101: result = SLR_OUT;
        4'b0110: result = SLL_OUT;
        4'b0111: result = SRA_OUT;
        4'b1000: result = {63'b0, SLT_OUT};  // Handle SLT as 64-bit result
        4'b1001: result = {63'b0, SLTU_OUT};  // Handle SLTU as 64-bit result
        default: result = 64'b0;
    endcase
end
endmodule




///////////////////////////////////////////////control block///////////////////////////////////////////////


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



////////////////////////////////imm_gen block///////////////////////////////////////////////


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












///////////////////////////////////////////////data memory block///////////////////////////////////////////////
module data_memory (
    input wire clk,                 
    input wire [63:0] address,         
    input wire [63:0] write_data,     
    input wire mem_write,             
    input wire mem_read,             
    output reg [63:0] read_data     
);

    // reg [63:0] memory [0:1023];
    reg [31:0] memory [0:255];

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






// module cpu_top(input wire clk,input wire reset);
//     reg [31:0] pc;
//     wire [31:0] instr;
//     wire branch, memread, memtoreg, memwrite, alusrc, regwrite;
//     wire [1:0] ALUop;
//     wire [3:0] ALUctr;
//     wire [63:0] imm;
//     reg [63:0] writedata;
//     wire [63:0] alures;
//     wire [63:0] readdata1, readdata2;
//     wire [63:0] opdata;
//     always@(posedge clk) begin
//         if(reset) begin
//             pc <= 32'b0;
//         end
//         else begin
//             pc <= pc + 4;
//         end
//     end
    
//     // Instantiate instruction memory
//     instr_mem imem (
//         .pc(pc),
//         .instr(instr)
//     );

//     // Instantiate control unit
//     control_alucontrol ctrl (
//         .instruction(instr),
//         .branch(branch),
//         .memread(memread),
//         .memtoreg(memtoreg),
//         .ALUop(ALUop),
//         .memwrite(memwrite),
//         .alusrc(alusrc),
//         .regwrite(regwrite),
//         .ALUctr(ALUctr)
//     );

//     // Instantiate register file
//     register_file regfile (
//         .clk(clk),
//         .regwrite(regwrite),
//         .rs1(instr[19:15]),
//         .rs2(instr[24:20]),
//         .rd(instr[11:7]),
//         .writedata(writedata),
//         .readdata1(readdata1),
//         .readdata2(readdata2)
//     );

//     imm_gen_all_types imm_gen (
//         .instruction(instr),
//         .immediate(imm)
//     );

//     execution alu (
//         .a(readdata1),
//         .b(readdata2),
//         .op(ALUctr),
//         .imm(imm),
//         .alusrc(alusrc),
//         .result(alures),
//         .zero()
//     );

//     data_memory dmem (
//         .clk(clk),
//         .address(alures),
//         .write_data(readdata2),
//         .mem_write(memwrite),
//         .mem_read(memread),
//         .read_data(opdata)
//     );
//     wire baz;
//     wire zero;
//     if(readdata1 == readdata2) begin
//         assign zero = 1;
//     end
//     else begin
//         assign zero = 0;
//     end
//     assign baz = zero & branch;
//     always@(posedge clk) begin
//         if(reset) begin
//             pc <= 32'b0;
//         end
//         if(baz) begin
//             pc <= pc + (imm << 2);
//         end
//         else begin
//             pc <= pc + 4;
//         end
//     end

// endmodule




module cpu_top(input wire clk, input wire reset);
    reg [31:0] pc;
    wire [31:0] instr;
    wire branch, memread, memtoreg, memwrite, alusrc, regwrite;
    wire [1:0] ALUop;
    wire [3:0] ALUctr;
    wire [63:0] imm;
    reg [63:0] writedata;
    wire [63:0] alures;
    wire [63:0] readdata1, readdata2;
    wire [63:0] opdata;
    wire zero;
    wire baz;

    // Program Counter (PC) Update
    always @(posedge clk or posedge reset) begin
        if (reset) 
            pc <= 32'b0;
        else if (baz) 
            pc <= pc + (imm << 2);  // Branching condition
        else 
            pc <= pc + 4;
    end

    // Instantiate instruction memory
    instr_mem imem (
        .pc(pc),
        .instr(instr)
    );

    // Instantiate control unit
    control_alucontrol ctrl (
        .instruction(instr),
        .branch(branch),
        .memread(memread),
        .memtoreg(memtoreg),
        .ALUop(ALUop),
        .memwrite(memwrite),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .ALUctr(ALUctr)
    );

    // Instantiate register file
    register_file regfile (
        .clk(clk),
        .regwrite(regwrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .writedata(writedata),
        .readdata1(readdata1),
        .readdata2(readdata2)
    );

    // Immediate Generator
    imm_gen_all_types imm_gen (
        .instruction(instr),
        .immediate(imm)
    );

    // ALU Execution
    execution alu (
        .a(readdata1),
        .b(readdata2),
        .op(ALUctr),
        .imm(imm),
        .alusrc(alusrc),
        .result(alures),
        .zero()
    );

    // Data Memory
    data_memory dmem (
        .clk(clk),
        .address(alures),
        .write_data(readdata2),
        .mem_write(memwrite),
        .mem_read(memread),
        .read_data(opdata)
    );

    // Zero flag for branching
    assign zero = (readdata1 == readdata2) ? 1'b1 : 1'b0;
    assign baz = zero & branch;

endmodule