module instr_mem(
    input [31:0] pc, 
    output reg [31:0] instr,
    output reg [31:0] ifid_instr
);
    reg [31:0] memory [0:1023]; // 1K words of memory

    initial begin
        memory[0] = 32'b0000000_10000_00000_000_00001_0010011; // addi x1, x0, 16   (Initialize x1 = 1)
        memory[1] = 32'b0000000_10000_00000_000_00010_0010011; // addi x2, x0, 16  (Initialize x1 = 1)
        memory[2] = 32'b0000000_00001_00010_000_00100_1100011; // beq x1, x2, loop (idex_branching example)
        memory[3]  = 32'b0100000_01001_01101_000_01000_0110011; // sub x8, x13, x9
        memory[4]  =32'b0000000_01001_01101_000_01000_0110011; // add x8, x13, x9  
    end

    always @(*) begin
        instr = memory[pc[6:0]>>2]; // Fetch instruction using word-aligned address
        ifid_instr = instr;
    end
endmodule


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
    output reg [3:0] idex_ALUctr, // Changed to 4-bit
    input wire stall
);
        wire [2:0] funct3;
        wire funct7;
        wire [6:0] opcode;
        assign opcode = instruction[6:0];
        assign funct3 = instruction[14:12];
        assign funct7 = instruction[30];
    
    always @(posedge clk) begin


        
        if(!stall)begin
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
            7'b1100011: begin // idex_branch (e.g., BEQ)
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
        else begin
            idex_branch = 0;
            idex_memread = 0;
            idex_memtoreg = 0;
            idex_ALUop = 2'b00;
            idex_memwrite = 0;
            idex_alusrc = 0;
            idex_regwrite = 0;
            idex_ALUctr = 4'b0000;
        end
    end
endmodule




module imm_gen_all_types (
    input wire [31:0] instruction,
    output reg [63:0] immediate,
    output reg [63:0] immediateclk,
    input wire clk
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
    always @(posedge clk) begin
        immediateclk <= immediate;
    end
endmodule



module HazardDetectionUnit(
    input wire ID_EX_MemRead,         // Memory read signal in EX stage
    input wire [4:0] ID_EX_RegisterRt, // Destination register in EX stage
    input wire [4:0] IF_ID_RegisterRs, // Source register in ID stage
    input wire [4:0] IF_ID_RegisterRt, // Destination register in ID stage
    output reg stall              // Stall control signal
);

    always@(*) begin
        // Default: No stall
        stall = 1'b0;

        // If the instruction in the EX stage is reading from memory and
        // the next instruction is using that register, insert a stall
        if (ID_EX_MemRead && ((ID_EX_RegisterRt == IF_ID_RegisterRs) || (ID_EX_RegisterRt == IF_ID_RegisterRt))) begin
            stall = 1'b1;
        end
    end

endmodule


module forwarding_unit(
    input [4:0] id_ex_Rs1, 
    input [4:0] id_ex_Rs2, 
    input [4:0] ex_mem_rd,
    input [4:0] mem_wb_rd,
    input ex_mem_Regwrite,
    input mem_wb_Regwrite,

    output reg [1:0] forwardA,  
    output reg [1:0] forwardB
);

always @(*) begin
    // Default forwarding values (no forwarding)
    forwardA = 2'b00;
    forwardB = 2'b00;

    // Check for EX hazard (forward from EX/MEM stage)
    if (ex_mem_Regwrite && (ex_mem_rd != 5'b00000)) begin
        if (ex_mem_rd == id_ex_Rs1) begin
            forwardA = 2'b10;
        end
        if (ex_mem_rd == id_ex_Rs2) begin
            forwardB = 2'b10;
        end
    end

    // Check for MEM hazard (forward from MEM/WB stage)
    if (mem_wb_Regwrite && (mem_wb_rd != 5'b00000)) begin
        if ((mem_wb_rd == id_ex_Rs1) && 
            !(ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs1))) begin
            forwardA = 2'b01;
        end

        if ((mem_wb_rd == id_ex_Rs2) && 
            !(ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs2))) begin
            forwardB = 2'b01;
        end
    end
end
endmodule









//////////////////////////////////////////////////////Data Memory//////////////////////////////////////////////
module data_memory (
    input wire clk,                 
    input wire [63:0] address,         
    input wire [63:0] write_data,     
    input wire exmem_write,             
    input wire exmem_read,             
    output reg [63:0] memwb_readdata     
);

    reg [63:0] memory [0:255]; // 256 words of 64-bit memory

    // Asynchronous Memory Read (No clk)
    always @(*) begin
        if (exmem_read) 
            memwb_readdata = memory[address[7:0]]; // Read directly (combinational)
    end

    // Synchronous Memory Write (Needs clk)
    always @(posedge clk) begin
        if (exmem_write)
            memory[address[7:0]] <= write_data;  
    end

endmodule




















module cpu_top(input wire clk, input wire reset);
    reg [31:0] pc;
    
    reg [63:0] writedata;
    reg [63:0] memory [0:31];

    wire [31:0] instr;
    wire [63:0] readdata1, readdata2, opdata, alures;
    ////////ifid//////
    reg [31:0] ifid_pc;
    wire [31:0] ifid_instr;
    ////////idex//////
    wire [63:0] idex_imm;
    wire [4:0] idex_rs1, idex_rs2, idex_rd;
    wire [3:0] idex_ALUctr;
    wire [1:0] idex_ALUop;
    wire[63:0] idex_rs1data, idex_rs2data;
    wire idex_branch, idex_memread, idex_memtoreg, idex_memwrite, idex_alusrc, idex_regwrite;
    ///////exmem//////
    wire [63:0] exmem_alures, exmem_opdata;
    wire [4:0] exmem_rd;
    wire exmem_regwrite, exmem_memread, exmem_memwrite;
    ///////memwb//////
    wire [63:0] memwb_alures, memwb_opdata;
    wire [4:0] memwb_rd;
    wire memwb_memtoreg, memwb_regwrite;

    wire  stall;
    wire [63:0] imm;
    wire [1:0] forwardA, forwardB;
    reg baz;
    reg zero;






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
    if (reset) begin
        pc <= 32'b0;
        ifid_pc <= 32'b0;
        baz <= 1'b0;
    end else if (baz) begin
        pc <= pc + (imm << 2);  // branch condition
        ifid_pc <= pc;
    end else if (stall) begin
        pc <= pc;
        ifid_pc <= pc;
    end else begin
        pc <= pc + 4;
        ifid_pc <= pc;
    end
end
    // Instantiate instruction memory
    instr_mem imemr (
        .pc(ifid_pc),
        .instr(instr),
        .ifid_instr(ifid_instr)
    );

    HazardDetectionUnit hazard (
        .ID_EX_MemRead(idex_memread),
        .ID_EX_RegisterRt(idex_rd[4:0]),
        .IF_ID_RegisterRs(ifid_instr[19:15]),
        .IF_ID_RegisterRt(ifid_instr[24:20]),
        .stall(stall)
    );

    // Instantiate control unit
    control_alucontrol ctrl (
        .instruction(ifid_instr),
        .clk(clk),
        .idex_branch(idex_branch),
        .idex_memread(idex_memread),
        .idex_memtoreg(idex_memtoreg),
        .idex_ALUop(idex_ALUop),
        .idex_memwrite(idex_memwrite),
        .idex_alusrc(idex_alusrc),
        .idex_regwrite(idex_regwrite),
        .idex_ALUctr(idex_ALUctr),
        .stall(stall)
    );

    // Instantiate register file
    // Reg_memory Reg (
    //     .clk(clk),
    //     .memory(memory),
    //     .instruction(instr),
    //     .write_data(writedata),
    //     .idex_regwrite(idex_regwrite),
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

        


    

    // // Immediate Generator
    imm_gen_all_types imm_gen (
        .instruction(ifid_instr),
        .immediateclk(idex_imm),
        .immediate(imm),
        .clk(clk)
    );

    // // ALU Execution
    // execution alu (
    //     .a(readdata1),
    //     .b(readdata2),
    //     .op(idex_ALUctr),
    //     .imm(idex_imm),
    //     .idex_alusrc(idex_alusrc),
    //     .result(alures) // Connect zero flag
    // );
    // assign zero = (readdata1 == readdata2) ? 1'b1 : 1'b0;


    ////forwarding unit//////
    forwarding_unit forward (
        .id_ex_Rs1(idex_rs1),
        .id_ex_Rs2(idex_rs2),
        .ex_mem_rd(exmem_rd),
        .mem_wb_rd(memwb_rd),
        .ex_mem_Regwrite(exmem_regwrite),
        .mem_wb_Regwrite(memwb_regwrite),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    







    // // Data Memory
    data_memory dmem (
        .clk(clk),
        .address(alures),
        .write_data(writedata),
        .exmem_write(idex_memwrite),
        .exmem_read(idex_memread),
        .memwb_readdata(opdata)
    );

    always @(*) begin
        if (memwb_regwrite) 
            if(memwb_memtoreg) 
                memory[memwb_rd] <= memwb_opdata;
            else
                memory[memwb_rd] <= memwb_alures;
    end
    
    

    // // Zero flag for idex_branching
    always @(*) begin
        zero = (readdata1 == readdata2) ? 1'b1 : 1'b0;
    end
    always @(*) begin
        baz <= zero & idex_branch;
    end

endmodule
