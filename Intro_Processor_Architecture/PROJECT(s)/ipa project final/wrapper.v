// `include "all_in_one.v"
`include "control.v"
`include "execution.v"
`include "branch.v"
`include "hazard.v"
`include "data.v"
`include "forward.v"
`include "immediate.v"
`include "instruction.v"


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
    reg [31:0] ifid_instr;
    reg ifid_write;
    ////////idex//////
    reg [63:0] idex_imm;
    reg [4:0] idex_rs1, idex_rs2, idex_rd;
    reg [3:0] idex_ALUctr;
    reg [1:0] idex_ALUop;
    reg [63:0] idex_rs1data, idex_rs2data;
    reg idex_branch, idex_memread, idex_memtoreg, idex_memwrite, idex_alusrc, idex_regwrite;
    reg idex_zero;
    reg valid_idex; // Valid bit for ID/EX stage
    
    ///////exmem//////
    reg [63:0] exmem_alures;
    reg [4:0] exmem_rd;
    reg exmem_memtoreg;
    reg [63:0] exmem_rs2data;
    reg exmem_regwrite, exmem_memread, exmem_memwrite;
    reg exmem_branch;
    reg exmem_zero;
    reg valid_exmem; // Valid bit for EX/MEM stage
    
    ///////memwb//////
    reg [63:0] memwb_alures, memwb_opdata;
    reg [4:0] memwb_rd;
    reg memwb_memtoreg, memwb_regwrite;
    reg valid_memwb; // Valid bit for MEM/WB stage

    // Branch target address calculation
    reg [31:0] branch_target;

    // Add wires to connect module outputs to registers
    wire [63:0] imm;
    wire [63:0] immediate_generated;
    wire [1:0] forwardA, forwardB;
    wire [63:0] alu_result;
    reg baz;
    reg zero;

    wire stall;
    wire flush_ifid, flush_idex, pc_src;
    wire alu_zero; // Zero flag from ALU
    
    // Control wires
    wire ctrl_idex_branch, ctrl_idex_memread, ctrl_idex_memtoreg;
    wire [1:0] ctrl_idex_ALUop;
    wire ctrl_idex_memwrite, ctrl_idex_alusrc, ctrl_idex_regwrite;
    wire [3:0] ctrl_idex_ALUctr;
    wire [63:0] imm_gen_output;
    
    // Forwarding signals
    reg [63:0] final_rs1data, final_rs2data;

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

     // Branch target address calculation - Modified to use ID/EX PC
    always @(*) begin
        branch_target = ifid_pc + (imm << 2);
    end


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
            ifid_pc <= 32'b0;
            // ifid_instr<=32'b0;
        end else if (stall) begin
            // Keep PC unchanged during stall
            pc <= pc;
            ifid_pc <= pc;
        end else if (baz) begin
            // Branch taken - load branch target address
            pc <= ifid_pc + (imm << 2);
            ifid_pc <= pc;
            ifid_instr<=32'b0;
        end
        
        else begin
            // Normal sequential execution
            pc <= pc + 4;
            ifid_pc <= pc;
            ifid_instr<=instr;
        end
    end

    // Program Counter (PC) Update
    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         pc <= 32'b0;
    //         ifid_pc <= 32'b0;
    //         baz <= 1'b0;
    //     end else if (baz) begin
    //         pc <= pc + (imm << 2);  // branch condition
    //         ifid_pc <= pc + (imm << 2);

    //     end 
    //     else if(stall)begin
    //         pc <= pc;
    //         ifid_pc <= pc;
    //     end
    //     else begin
    //         pc <= pc + 4;
    //         ifid_pc <= pc + 4;
    //     end
    // end

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

            // valid_ifid <= 1'b1;
            // valid_idex <= 1'b1;
            // valid_exmem <= 1'b1;
            // valid_memwb <= 1'b1;
            
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
            idex_zero <= zero;
            
            // EX/MEM Stage Update
            ex_mem_pc <= idex_pc;
            exmem_rs2data <= final_rs2data;
            exmem_rd <= idex_rd;
            exmem_alures <= alu_result; // Take from wire
            
            exmem_branch <= idex_branch;
            exmem_memread <= idex_memread;
            exmem_memtoreg <= idex_memtoreg;
            exmem_memwrite <= idex_memwrite;
            exmem_regwrite <= idex_regwrite;
            exmem_zero <= idex_zero;
            
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
        .stall(stall)
    );

    // Instantiate control unit
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
        .idex_ALUctr(ctrl_idex_ALUctr)
    );

    // Immediate Generator
    imm_gen_all_types imm_gen (
        .instruction(ifid_instr),
        .immediateclk(imm_gen_output),
        .immediate(imm),
        .clk(clk)
    );

    // Zero flag check for branching
    always @(*) begin
        if(memory[ifid_instr[19:15]]==memory[ifid_instr[24:20]]) begin
            zero <= 1'b1;
        end
        else begin
            zero <= 1'b0;
        end
    end

    // Branch decision logic
    always @(*) begin
        baz = zero & ctrl_idex_branch;
        
    end

     wire [6:0] opcode_decide;
    assign opcode_decide = ifid_instr[6:0];
    // Register access logic
    always @(posedge clk) begin
        // idex_rs1 <= ifid_instr[19:15];
        // idex_rs2 <= ifid_instr[24:20];
        // idex_rd <= ifid_instr[11:7];
        // idex_rs1data <= memory[ifid_instr[19:15]];
        // idex_rs2data <= memory[ifid_instr[24:20]];
        
            
        

        if(opcode_decide == 7'b1100011) begin  // Branch instruction
            idex_rs1 <= ifid_instr[19:15];
            idex_rs2 <= ifid_instr[24:20];
            idex_rd <= 0;
            idex_rs1data <= memory[ifid_instr[19:15]];
            idex_rs2data <= memory[ifid_instr[24:20]];
        end
        
        else if(opcode_decide == 7'b0000011) begin  // Load instruction I type
            idex_rs1 <= ifid_instr[19:15];
            idex_rs2 <= 0;
            idex_rd <= ifid_instr[11:7];
            idex_rs1data <= memory[ifid_instr[19:15]];
            idex_rs2data <=0;
        end
        
        else if(opcode_decide == 7'b0100011) begin // Store instruction
            idex_rs1 <= ifid_instr[19:15];
            idex_rs2 <= ifid_instr[24:20];
            idex_rd <= 0;
            idex_rs1data <= memory[ifid_instr[19:15]];
            idex_rs2data <= memory[ifid_instr[24:20]];
        end
        else begin
            idex_rs1 <= ifid_instr[19:15];
            idex_rs2 <= ifid_instr[24:20];
            idex_rd <= ifid_instr[11:7];
            idex_rs1data <= memory[ifid_instr[19:15]];
            idex_rs2data <= memory[ifid_instr[24:20]];
        end
        
    end

    // HazardDetectionUnit hazard (
    //     .ID_EX_MemRead(idex_memread),
    //     .ID_EX_RegisterRt(idex_rd[4:0]),
    //     .IF_ID_RegisterRs(ifid_instr[19:15]),
    //     .IF_ID_RegisterRt(ifid_instr[24:20]),
    //     .stall(stall)
    // );
    HazardDetectionUnit hazard(
        .idex_memread(idex_memread),
        .idex_rd(idex_rd),
        .ifid_rs1(ifid_instr[19:15]),
        .ifid_rs2(ifid_instr[24:20]),
        .stall(stall)
    );


    always @(posedge clk) begin
        if(stall && !reset)begin
            idex_branch <= 0;
            idex_memread <= 0;
            idex_memtoreg <= 0;
            idex_ALUop <= 0;
            idex_memwrite <= 0;
            idex_alusrc <= 0;
            idex_regwrite <= 0;
            idex_ALUctr <= 0;

            ex_mem_pc <= idex_pc;
            exmem_rs2data <= final_rs2data;
            exmem_rd <= idex_rd;
            exmem_alures <= alu_result; // Take from wire
            
            exmem_branch <= idex_branch;
            exmem_memread <= idex_memread;
            exmem_memtoreg <= idex_memtoreg;
            exmem_memwrite <= idex_memwrite;
            exmem_regwrite <= idex_regwrite;
            exmem_zero <= idex_zero;
            
            // MEM/WB Stage Update
            mem_wb_pc <= ex_mem_pc;
            memwb_alures <= exmem_alures;
            memwb_opdata <= opdata;
            memwb_rd <= exmem_rd;
            
            memwb_memtoreg <= exmem_memtoreg;
            memwb_regwrite <= exmem_regwrite;
            ifid_pc <= ifid_pc;

        end
        end
    

    

    // ALU Execution
    execution alu (
        .a(final_rs1data),
        .b(final_rs2data),
        .op(idex_ALUctr),
        .imm(idex_imm),
        .idex_alusrc(idex_alusrc),
        .result(alu_result)
    );

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
        //  reg [63:0] final_rs1data, final_rs2data;

    // Use a combinational always block instead of assign in conditional statements
    // always @(*) begin
    //     case(forwardA)
    //         2'b10: final_rs1data = exmem_alures;
    //         2'b01: final_rs1data = memwb_alures;
    //         2'b00: final_rs1data = idex_rs1data;
    //         default: final_rs1data = idex_rs1data; // Good practice to have a default
    //     endcase
        
    //     case(forwardB)
    //         2'b10: final_rs2data = exmem_alures;
    //         2'b01: final_rs2data = memwb_alures;
    //         2'b00: final_rs2data = idex_rs2data;
    //         default: final_rs2data = idex_rs2data;
    //     endcase
    // end

    always @(*) begin
        if(forwardA == 2'b10) begin
            final_rs1data = exmem_alures;
        end
        else if(forwardA == 2'b01) begin
            // final_rs1data = memwb_alures;

            if(memwb_memtoreg) begin
                final_rs1data = memwb_opdata;
            end
            else begin
                final_rs1data = memwb_alures;
            end
        end
        else begin
            final_rs1data = idex_rs1data;
        end

        if(forwardB == 2'b10) begin
            final_rs2data = exmem_alures;
        end
        else if(forwardB == 2'b01) begin
            if(memwb_memtoreg) begin
                final_rs2data = memwb_opdata;
            end
            else begin
                final_rs2data = memwb_alures;
        end
        end
        else begin
            final_rs2data = idex_rs2data;
        end
    end


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
                memory[memwb_rd] <= memwb_opdata;
            else
                memory[memwb_rd] <= memwb_alures;
        end
    end
endmodule


