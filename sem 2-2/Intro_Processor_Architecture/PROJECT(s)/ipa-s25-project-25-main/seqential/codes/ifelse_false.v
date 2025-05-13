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
       

       

        // memory[0]  = 32'b0000000_00001_00000_000_00001_0010011; // addi x1, x0, 1   (Initialize x1 = 1)
        // memory[1]  = 32'b0000000_00001_00000_010_00001_0100011; // sd x1, 0(x0)     (Store Fib(1) = 1)
        // memory[2]  = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x1, x2
        // memory[3]  = 32'b0100000_00011_01001_000_00101_0110011; // sub x5, x9, x3
        // memory[4]  = 32'b0000000_00100_00000_010_01000_0100011; // sd x4, 8(x0)
        // memory[5]  = 32'b0000000_00101_00000_010_10000_0100011; // sd x5, 16(x0)
        // memory[6]  = 32'b0000000_01001_00011_000_00100_0110011; // add x4, x9, x3
        // memory[7]  = 32'b0100000_00010_00001_000_00101_0110011; // sub x5, x1, x2

        // memory[8] = 32'b0000000_01000_00000_010_00100_0000011; // ld x4, 8(x0)
        // memory[9] = 32'b0000000_10000_00000_010_00101_0000011; // ld x5, 16(x0)

        // memory[10] = 32'b0000000_00101_00100_111_00110_0110011; // and x6, x4, x5
        // memory[11] = 32'b0000000_00101_00100_110_00111_0110011; // or x7, x4, x5
        // memory[12] = 32'b0000000_00101_00100_100_01000_0110011; // xor x8, x4, x5
        // memory[13]  = 32'b0000000_01111_00000_000_01101_0010011; // addi x13, x0, 15
        // memory[14]  = 32'b0000000_01111_00000_000_01110_0010011; // addi x14, x0, 15
        // memory[15] = 32'b0000000_01101_01110_000_00100_1100011; // beq x14, x13, loop (branching example)
        // memory[16] = 32'b0000000_01111_00000_000_01111_0010011; // addi x15, x0, 15
        // memory[17] = 32'b0000000_00010_00001_111_00110_0110011; // and x6, x1, x2
        // memory[18] = 32'b0000000_00010_00001_110_00111_0110011; // or x7, x1, x2
        // memory[19] = 32'b0000000_00010_00010_100_01000_0110011; // xor x8, x2, x2
        // memory[20] = 32'b0000000_11000_00000_010_01000_0100011; // sd x8, 24(x0)
        // memory[21] = 32'b0000000_11000_00000_010_01001_0000011; // ld x9, 24(x0)


        memory[0] = 32'b0000000_10000_00000_000_00001_0010011; // addi x1, x0, 16   (Initialize x1 = 1)
        memory[1] = 32'b0000000_10001_00000_000_00010_0010011; // addi x2, x0, 17  (Initialize x1 = 1)
        memory[2] = 32'b0000000_00001_00010_000_00100_1100011; // beq x1, x2, loop (branching example)
        memory[3] = 32'b0100000_01001_01101_000_01000_0110011; // sub x8, x13, x9
        memory[4] =32'b0000000_01001_01101_000_01000_0110011; // add x8, x13, x9

        
    end

    always @(*) begin
        instr = memory[pc[6:0]>>2]; // Fetch instruction using word-aligned address
    end
endmodule








///////////////////////////////////////////////register block///////////////////////////////////////////////

// module Reg_memory (
//     input wire clk, 
//     input wire [31:0] instruction,   
//     input wire [63:0] write_data, 
//     input wire RegWrite,
//     input wire [63:0] memory [0:31],
//     output reg [63:0] Read_data1,
//     output reg [63:0] Read_data2
// );
//     // reg [63:0] memory [0:31];  // Declare memory inside module
//     reg [4:0] Read_Register1;
//     reg [4:0] Read_Register2;
//     reg [4:0] Write_Register;

//     always @(*) begin
//         Read_Register1 = instruction[19:15];
//         Read_Register2 = instruction[24:20];
//         Write_Register = instruction[11:7];
//     end

//     always @(*) begin
//         Read_data1 = memory[Read_Register1];
//         Read_data2 = memory[Read_Register2];
//     end

//     always @(posedge clk) begin
//         if (RegWrite) 
//             memory[Write_Register] = write_data;
//     end
// endmodule





///////////////////////////////////////////////alu block///////////////////////////////////////////////

`include "all_in_one.v"

module execution (
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    input [63:0] imm,
    input alusrc,
    output reg [63:0] result
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
// module data_memory (
//     input wire clk,                 
//     input wire [63:0] address,         
//     input wire [63:0] write_data,     
//     input wire mem_write,             
//     input wire mem_read,             
//     output reg [63:0] read_data     
// );

//     // reg [63:0] memory [0:1023];
//     reg [31:0] memory [0:255];

//     always @(posedge clk) begin
//             if (mem_write) begin
//                 // memory[address[11:3]] <= write_data;
//                 memory[address[7:0]] <= write_data;  
//             end
//             if (mem_read) begin
//                 // read_data <= memory[address[11:3]]; 
//                 read_data <= memory[address[7:0]]; 
//             end
//     end

// endmodule
module data_memory (
    input wire clk,                 
    input wire [63:0] address,         
    input wire [63:0] write_data,     
    input wire mem_write,             
    input wire mem_read,             
    output reg [63:0] read_data     
);

    reg [63:0] memory [0:255]; // 256 words of 64-bit memory

    // Asynchronous Memory Read (No clk)
    always @(*) begin
        if (mem_read) 
            read_data = memory[address[7:0]]; // Read directly (combinational)
    end

    // Synchronous Memory Write (Needs clk)
    always @(posedge clk) begin
        if (mem_write)
            memory[address[7:0]] <= write_data;  
    end

endmodule




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
    reg [63:0] memory [0:31];
    wire zero;
    wire baz;

    initial begin
        // Initialize memory
            memory[0] = 64'd0;
            memory[1] = 64'd1;
            memory[2] = 64'd2;
            memory[3] = 64'd3;
            memory[4] = 64'd4;
            memory[5] = 64'd5;
            memory[6] = 64'd6;
            memory[7] = 64'd7;
            memory[8] = 64'd8;
            memory[9] = 64'd9;
            memory[10] = 64'd10;
            memory[11] = 64'd11;
            memory[12] = 64'd12;
            memory[13] = 64'd13;
            memory[14] = 64'd14;
            memory[15] = 64'd15;
            memory[16] = 64'd16;
            memory[17] = 64'd17;
            memory[18] = 64'd18;
            memory[19] = 64'd19;
            memory[20] = 64'd20;
            memory[21] = 64'd21;
            memory[22] = 64'd22;
            memory[23] = 64'd23;
            memory[24] = 64'd24;
            memory[25] = 64'd25;
            memory[26] = 64'd26;
            memory[27] = 64'd27;
            memory[28] = 64'd28;
            memory[29] = 64'd29;
            memory[30] = 64'd30;
            memory[31] = 64'd1;
    end

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
    // Reg_memory Reg (
    //     .clk(clk),
    //     .memory(memory),
    //     .instruction(instr),
    //     .write_data(writedata),
    //     .RegWrite(regwrite),
    //     .Read_data1(readdata1),
    //     .Read_data2(readdata2)
    // );
    wire [4:0] Read_Register1;
    wire [4:0] Read_Register2;
    wire [4:0] Write_Register;


        assign Read_Register1 = instr[19:15];
        assign Read_Register2 = instr[24:20];
        assign Write_Register = instr[11:7];
    
        assign readdata1 = memory[Read_Register1];
        assign readdata2 = memory[Read_Register2];

        


    

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
        .result(alures) // Connect zero flag
    );
    assign zero = (readdata1 == readdata2) ? 1'b1 : 1'b0;
    // Data Memory
    data_memory dmem (
        .clk(clk),
        .address(alures),
        .write_data(readdata2),
        .mem_write(memwrite),
        .mem_read(memread),
        .read_data(opdata)
    );
    always @(*) begin
        if (regwrite) 
            if(memtoreg) 
                memory[Write_Register] <= opdata;
            else
                memory[Write_Register] <= alures;
    end
    
    

    // Zero flag for branching
    
    assign baz = zero & branch;

endmodule




module cpu_top_tb;
    reg clk;
    reg reset;
    
    // Instantiate CPU Top Module
    cpu_top uut (
        .clk(clk),
        .reset(reset)
    );
    
    // Clock Generation
    always #5 clk = ~clk; // 10ns clock period (100MHz)
    
    initial begin
        // Initialize Signals
        clk = 0;
        reset = 1;
        
        // Apply Reset
        #10;
        reset = 0;
        
        // Run simulation for some cycles
        #40;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals|add=%b|2ndadd=%b
    // initial begin
    //     $monitor("Time = %0t | pc = %d |reg1=%d | reg2=%d | reg3=%d | reg4=%d| reg8=%d| reg15=%d", 
    //      $time, uut.pc, uut.memory[1],uut.memory[2],uut.memory[3],uut.memory[4],uut.memory[8],uut.memory[15]);

    // end
    initial begin
        $monitor("Time = %0t | pc = %d |reg1=%d ", 
         $time, uut.pc, uut.memory[8]);

    end
endmodule