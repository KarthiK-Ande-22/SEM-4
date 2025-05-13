`include "data.v"
`include "execution.v"
`include "imm.v"
`include "instructions.v"
`include "control.v"
// `include "data.v"
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
    reg exmem_branch;
    reg exmem_zero;
    
    ///////memwb//////
    reg [63:0] memwb_alures, memwb_opdata;
    reg [4:0] memwb_rd;
    reg memwb_memtoreg, memwb_regwrite;

    // Add wires to connect module outputs to registers
    wire [63:0] imm;
    wire [63:0] immediate_generated;
    wire [1:0] forwardA, forwardB;
    wire [63:0] alu_result;
    reg baz;
    reg zero;
    
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
        memory[0] = 64'd1;
        memory[1] = 64'd2;
        memory[2] = 64'd3;
        memory[3] = 64'd4;
        memory[4] = 64'd5;
        memory[5] = 64'd5;
        memory[6] = 64'd7;
        memory[7] = 64'd8;
        memory[8] = 64'd9;
        memory[9] = 64'd10;
        memory[10] = 64'd11;
        memory[11] = 64'd12;
        memory[12] = 64'd13;
        memory[13] = 64'd14;
        memory[14] = 64'd15;
        memory[15] = 64'd16;
        memory[16] = 64'd17;
        memory[17] = 64'd18;
        memory[18] = 64'd19;
        memory[19] = 64'd20;
        memory[20] = 64'd21;
        memory[21] = 64'd22;
        memory[22] = 64'd23;
        memory[23] = 64'd24;
        memory[24] = 64'd25;
        memory[25] = 64'd26;
        memory[26] = 64'd27;
        memory[27] = 64'd28;
        memory[28] = 64'd29;
        memory[29] = 64'd30;
        memory[30] = 64'd31;
        memory[31] = 64'd32;
        // $readmemb("register.txt", memory);
    end

    // Program Counter (PC) Update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'b0;
            ifid_pc <= 32'b0;
            baz <= 1'b0;
        end else if (baz) begin
            pc <= pc + (imm << 2);  // branch condition
            ifid_pc <= pc + (imm << 2);
        end else begin
            pc <= pc + 4;
            ifid_pc <= pc + 4;
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
            
        end else begin
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

    always@(*)begin
        if(ifid_instr[6:0]==7'b1111111)begin
            $display("End of program");
            $finish;
        end
    end

    // Immediate Generator
    imm_gen_all_types imm_gen (
        .instruction(ifid_instr),
        .immediateclk(imm_gen_output),
        .immediate(imm),
        .clk(clk)
    );

    // Zero flag check for branching
    always @(*) begin
        if(memory[ifid_instr[19:15]] == memory[ifid_instr[24:20]]) begin
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

    // Register access logic
    always @(posedge clk) begin
        idex_rs1 <= ifid_instr[19:15];
        idex_rs2 <= ifid_instr[24:20];
        idex_rd <= ifid_instr[11:7];
        idex_rs1data <= memory[ifid_instr[19:15]];
        idex_rs2data <= memory[ifid_instr[24:20]];
    end

    

    // ALU Execution
    execution alu (
        .a(idex_rs1data),
        .b(idex_rs2data),
        .op(idex_ALUctr),
        .imm(idex_imm),
        .idex_alusrc(idex_alusrc),
        .result(alu_result)
    );

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
    always @(*) begin
        if (memwb_regwrite) begin
            if(memwb_memtoreg) 
                memory[memwb_rd] <= memwb_opdata;
            else
                memory[memwb_rd] <= memwb_alures;
        end
    end
endmodule
