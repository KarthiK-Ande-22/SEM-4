module instr_mem(
    input [31:0] pc, 
    output reg [31:0] instr,
    output reg [31:0] ifid_instr
);
    reg [31:0] memory [0:1023]; // 1K words of memory

    initial begin
        memory[0] = 32'b0000000_10000_00000_000_00001_0010011; // addi x1, x0, 16   (Initialize x1 = 1)
        memory[1] = 32'b0000000_10000_00000_000_00010_0010011; // addi x2, x0, 16  (Initialize x1 = 1)
        // memory[2] = 32'b0000000_00001_00010_000_01000_1100011; // beq x1, x2, loop (idex_branching example)
        memory[2] = 32'b0100000_01001_01101_000_01000_0110011; // sub x8, x13, x9
        memory[3] = 32'b0000000_01001_01101_000_01000_0110011; // add x8, x13, x9  
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
        if(!stall) begin
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

//////////////////////////////////////////imm_gen_all_types//////////////////////////////////////////////

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

//////////////////////////////////////hazard detection unit//////////////////////////////////////////////

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

///////////////////////////////////////forwarding unit//////////////////////////////////////////////
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
    if (ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs1)) begin
            forwardA = 2'b10;
    end
    if (ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs2)) begin
            forwardB = 2'b10;
    end

    if(mem_wb_Regwrite && (mem_wb_rd != 5'b00000) && !(ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs1)) && (mem_wb_rd==id_ex_Rs1)) begin
        forwardA = 2'b01;
    end
    if(mem_wb_Regwrite && (mem_wb_rd != 5'b00000) && !(ex_mem_Regwrite && (ex_mem_rd != 5'b00000) && (ex_mem_rd == id_ex_Rs2)) && (mem_wb_rd==id_ex_Rs2)) begin
        forwardB = 2'b01;
    end
end
endmodule

///////////////////////////////////////execution block//////////////////////////////////////////////

`include "all_in_one.v"

module execution (
    input [63:0] a,
    input [63:0] b,
    input [3:0] op,
    input [63:0] imm,
    input idex_alusrc,
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
assign operb = idex_alusrc ? imm : b;

ADD adder (.a(a), .b(operb), .cin(1'b0), .sum(ADD_OUT), .cout(cout_adder));
SUB subtractor (.a(a), .b(operb), .sum(SUB_OUT), .cout(cout_subtractor));
AND_64_bit and_gate (.a(a), .b(operb), .and_ab(AND_OUT));
OR_64_bit or_gate (.a(a), .b(operb), .or_ab(OR_OUT));
XOR_64_bit xor_gate (.a(a), .b(operb), .xor_ab(XOR_OUT));
shift_logical_right slr (.a(a), .b(operb[5:0]), .slr_ab(SLR_OUT));
shift_logical_left sll (.a(a), .b(operb[5:0]), .sll_ab(SLL_OUT));
shift_Arithmetic_right sra (.a(a), .b(operb[5:0]), .sra_ab(SRA_OUT));
set_less_than slt (.a(a), .b(operb), .slt(SLT_OUT));
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
    always @(negedge clk) begin
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
    reg [31:0] idex_pc;
    reg [31:0] ex_mem_pc;
    reg [31:0] mem_wb_pc;
    
    reg [63:0] writedata;
    reg [63:0] memory [0:31];

    wire [31:0] instr;
    wire [63:0] readdata1, readdata2, opdata;
    wire [63:0] memoryread_data;
    
    ////////ifid//////
    reg [31:0] ifid_pc;
    wire [31:0] ifid_instr;
    
    ////////idex//////
    reg [63:0] idex_imm;
    reg [4:0] idex_rs1, idex_rs2, idex_rd;
    reg [3:0] idex_ALUctr;
    reg [1:0] idex_ALUop;
    reg [63:0] idex_rs1data, idex_rs2data;
    reg idex_branch, idex_memread, idex_memtoreg, idex_memwrite, idex_alusrc, idex_regwrite;
    
    ///////exmem//////
    reg [63:0] exmem_alures;
    reg [4:0] exmem_rd;
    reg exmem_memtoreg;
    reg [63:0] exmem_rs2data;
    reg exmem_regwrite, exmem_memread, exmem_memwrite;
    reg exmem_branch; // Added missing register
    reg exmem_zero;
    
    ///////memwb//////
    reg [63:0] memwb_alures, memwb_opdata;
    reg [4:0] memwb_rd;
    reg memwb_memtoreg, memwb_regwrite;

    // Add wires to connect module outputs to registers
    wire stall;
    wire [63:0] imm;
    wire [63:0] immediate_generated;
    wire [1:0] forwardA, forwardB;
    wire [63:0] alu_result; // New wire for ALU result
    reg baz;
    reg zero;
    
    // Control wires
    wire ctrl_idex_branch, ctrl_idex_memread, ctrl_idex_memtoreg;
    wire [1:0] ctrl_idex_ALUop;
    wire ctrl_idex_memwrite, ctrl_idex_alusrc, ctrl_idex_regwrite;
    wire [3:0] ctrl_idex_ALUctr;
    wire [63:0] imm_gen_output;

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
            ifid_pc <= pc+(imm<<2);
        end else if (stall) begin
            pc <= pc;
            ifid_pc <= pc;
        end else begin
            pc <= pc + 4;
            ifid_pc <= pc+4;
        end
    end

    // Pipeline register updates
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline registers
            idex_pc <= 32'b0;
            idex_rs1data <= 64'b0;
            idex_rs2data <= 64'b0;
            idex_imm <= 64'b0;
            idex_rd <= 5'b0;
            idex_rs1 <= 5'b0;
            idex_rs2 <= 5'b0;
            
            // Reset control signals
            idex_branch <= 1'b0;
            idex_memread <= 1'b0;
            idex_memtoreg <= 1'b0;
            idex_ALUop <= 2'b00;
            idex_memwrite <= 1'b0;
            idex_alusrc <= 1'b0;
            idex_regwrite <= 1'b0;
            idex_ALUctr <= 4'b0000;
            
            ex_mem_pc <= 32'b0;
            exmem_alures <= 64'b0;
            exmem_rs2data <= 64'b0;
            exmem_rd <= 5'b0;
            
            exmem_branch <= 1'b0;
            exmem_memread <= 1'b0;
            exmem_memtoreg <= 1'b0;
            exmem_memwrite <= 1'b0;
            exmem_regwrite <= 1'b0;
            exmem_zero <= 1'b0;
            
            mem_wb_pc <= 32'b0;
            memwb_alures <= 64'b0;
            memwb_opdata <= 64'b0;
            memwb_rd <= 5'b0;
            
            memwb_memtoreg <= 1'b0;
            memwb_regwrite <= 1'b0;
            
        end else if (!stall) begin
            // ID/EX Stage Update
            idex_pc <= ifid_pc;
            
            // Update control signals from wire to register
            idex_branch <= ctrl_idex_branch;
            idex_memread <= ctrl_idex_memread;
            idex_memtoreg <= ctrl_idex_memtoreg;
            idex_ALUop <= ctrl_idex_ALUop;
            idex_memwrite <= ctrl_idex_memwrite;
            idex_alusrc <= ctrl_idex_alusrc;
            idex_regwrite <= ctrl_idex_regwrite;
            idex_ALUctr <= ctrl_idex_ALUctr;
            idex_imm <= imm_gen_output;

            // idex_rs1 <= ifid_instr[19:15];
            // idex_rs2 <= ifid_instr[24:20];
            // idex_rd <= ifid_instr[11:7];
            // idex_rs1data <= memory[ifid_instr[19:15]];
            // idex_rs2data <= memory[ifid_instr[24:20]];
            
            // EX/MEM Stage Update
            ex_mem_pc <= idex_pc;
            exmem_rs2data <= idex_rs2data;
            exmem_rd <= idex_rd;
            exmem_alures <= alu_result; // Take from wire
            
            exmem_branch <= idex_branch;
            exmem_memread <= idex_memread;
            exmem_memtoreg <= idex_memtoreg;
            exmem_memwrite <= idex_memwrite;
            exmem_regwrite <= idex_regwrite;
            exmem_zero <= zero;
            
            // MEM/WB Stage Update
            mem_wb_pc <= ex_mem_pc;
            memwb_alures <= exmem_alures;
            memwb_opdata <= opdata;
            memwb_rd <= exmem_rd;
            
            memwb_memtoreg <= exmem_memtoreg;
            memwb_regwrite <= exmem_regwrite;
        end
    end

    // Instantiate instruction memory
    instr_mem imem (
        .pc(pc),
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


    always @(posedge clk) begin
        if(stall)begin
            idex_branch <= 0;
            idex_memread <= 0;
            idex_memtoreg <= 0;
            idex_ALUop <= 0;
            idex_memwrite <= 0;
            idex_alusrc <= 0;
            idex_regwrite <= 0;
            idex_ALUctr <= 0;
        end
    end
    // Instantiate control unit (now connect to wires)
    control_alucontrol ctrl (
        .instruction(ifid_instr),
        .clk(clk),
        .idex_branch(ctrl_idex_branch),
        .idex_memread(ctrl_idex_memread),
        .idex_memtoreg(ctrl_idex_memtoreg),
        .idex_ALUop(ctrl_idex_ALUop),
        .idex_memwrite(ctrl_idex_memwrite),
        .idex_alusrc(ctrl_idex_alusrc),
        .idex_regwrite(ctrl_idex_regwrite),
        .idex_ALUctr(ctrl_idex_ALUctr),
        .stall(stall)
    );

    

    // Immediate Generator (now connect to wire)
    imm_gen_all_types imm_gen (
        .instruction(ifid_instr),
        .immediateclk(imm_gen_output),
        .immediate(imm),
        .clk(clk)
    );

    always @(*)begin
    if(memory[ifid_instr[19:15]]==memory[ifid_instr[24:20]])begin
        zero <= 1'b1;
    end
    else begin
        zero <= 1'b0;
    end
    end

    always @(*) begin
        baz = zero & ctrl_idex_branch;
    end

    // Register access logic
    always @(posedge clk) begin
        idex_rs1 <= ifid_instr[19:15];
        idex_rs2 <= ifid_instr[24:20];
        idex_rd <= ifid_instr[11:7];
        idex_rs1data <= memory[ifid_instr[19:15]];
        idex_rs2data <= memory[ifid_instr[24:20]];
    end

    // Forwarding unit
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
    reg [63:0] final_rs1data, final_rs2data;

    // Use a combinational always block instead of assign in conditional statements
    always @(*) begin
        case(forwardA)
            2'b10: final_rs1data = exmem_alures;
            2'b01: final_rs1data = memwb_alures;
            2'b00: final_rs1data = idex_rs1data;
            default: final_rs1data = idex_rs1data; // Good practice to have a default
        endcase
        
        case(forwardB)
            2'b10: final_rs2data = exmem_alures;
            2'b01: final_rs2data = memwb_alures;
            2'b00: final_rs2data = idex_rs2data;
            default: final_rs2data = idex_rs2data;
        endcase
    end

    // if(forwardA == 2'b10) begin
    //     assign final_rs1data = exmem_alures;
    // end
    // else if(forwardA == 2'b01) begin
    //     readdata1 = memwb_alures;
    // end
    // else if(forwardA == 2'b00) begin
    //     readdata1 = idex_rs1data;
    // end

    // if(forwardB == 2'b10) begin
    //     readdata2 = exmem_alures;
    // end
    // else if(forwardB == 2'b01) begin
    //     readdata2 = memwb_alures;
    // end
    // else if(forwardB == 2'b00) begin
    //     readdata2 = idex_rs2data;
    // end

    // ALU Execution (now connect to wire)
    execution alu (
        .a(final_rs1data),
        .b(final_rs2data),
        .op(idex_ALUctr),
        .imm(idex_imm),
        .idex_alusrc(idex_alusrc),
        .result(alu_result)
    );

    ////forwarding unit//////
    

    // Data Memory
    data_memory dmem (
        .clk(clk),
        .address(exmem_alures),
        .write_data(exmem_rs2data),
        .exmem_write(exmem_memwrite),
        .exmem_read(exmem_memread),
        .memwb_readdata(opdata)
    );

    // Write back logic
    always @(posedge clk) begin
        if (memwb_regwrite) begin
            if(memwb_memtoreg) 
                memory[memwb_rd] = memwb_opdata;
            else
                memory[memwb_rd] = memwb_alures;
        end
    end
    
    // Zero flag for branching
    
    

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
        #200;
        
        // End simulation
        $finish;
    end
    
    // Monitor important signals|add=%b|2ndadd=%b
    // initial begin
    //     $monitor("Time = %0t | pc = %d |reg1=%d | reg2=%d | reg3=%d | reg4=%d| reg8=%d| reg15=%d", 
    //      $time, uut.pc, uut.memory[1],uut.memory[2],uut.memory[3],uut.memory[4],uut.memory[8],uut.memory[15]);

    // end
    initial begin
        // $monitor("Time = %0t | pc = %d |reg1=%d | reg2=%d | reg8=%d", 
        //  $time, uut.ifid_pc, uut.memory[1],uut.memory[2],uut.memory[8]);

         $monitor("Time = %0t | pc = %d |stall=%d | rs2=%d | reg8=%d", 
         $time, uut.ifid_pc, uut.stall,uut.idex_rs2data,uut.alu_result);


    end
endmodule