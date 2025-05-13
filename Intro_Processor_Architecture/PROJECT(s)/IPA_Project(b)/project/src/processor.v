module processor (
    input clk
);

    wire [31:0]  if_instruction;
    wire [63:0] id_rs1_val, id_rs2_val, id_imm, ex_alu_result,mem_data;
    wire [4:0] id_rs1, id_rs2, id_rd;
    wire [63:0] imm;
    wire branch, alu_src;   
    wire [3:0] alu_op;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [6:0] opcode;
    wire overflow,Memread,Memwrite,MemtoReg,Regwrite;

    reg [63:0] register_file [0:31];
    reg [31:0] pc;
    initial begin
    // Assign random values to registers
    register_file[1] = 64'd10;  // x1 = 10
    register_file[2] = 64'd20;  // x2 = 20~
    register_file[3] = 64'd15;  // x3 = 15
    register_file[4] = 64'd5;   // x4 = 5
    register_file[5] = 64'd0;   // x5 will store the result
    pc = 32'b0;                
    end
    assign id_rs1_val = register_file[id_rs1];
    assign id_rs2_val = register_file[id_rs2];
    genvar i;
    generate
    for(i=2;i<7;i=i+1) begin
        if(i==2) begin
        instruction_fetch if_stage (
        .pc(pc),
        .instruction(if_instruction)
        );
        end
        if(i==3) begin
        decode id_stage (
        .instruction(if_instruction),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(id_rd),
        .funct3(funct3),
        .funct7(funct7),
        .opcode(opcode),
        .branch(branch),
        .alu_op(alu_op),
        .alu_src(alu_src),
        .imm(imm),
        .memread(Memread),
        .memwrite(Memwrite),
        .memtoreg(MemtoReg),
        .regwrite(Regwrite)
        );
        end
        if(i==4) begin
        ex_stage execute_stage (
        .rs1_val(id_rs1_val),
        .rs2_val(id_rs2_val),
        .imm(imm),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .alu_result(ex_alu_result),
        .overflow(overflow)
        );
        end
        if(i==5) begin
        memory mem_stage(
        .alu_result(ex_alu_result),
        .memread(Memread),
        .memwrite(Memwrite),
        .rs2(id_rs2_val),
        .mem_data(mem_data)
        );
        end
    end
    endgenerate
    //writting back to the register file
   reg Regwrite_reg, MemtoReg_reg;

always @(*) begin
    Regwrite_reg <= Regwrite;   // Latch control signals
    MemtoReg_reg <= MemtoReg; 
end

// Use the latched values in sequential logic
always @(*) begin
    if (MemtoReg_reg) begin
        register_file[id_rd] <= mem_data;
    end else if (Regwrite_reg) begin
        register_file[id_rd] <= ex_alu_result;
    end
end

    //updating the pc according to branch
    reg pc_updater;
    wire pc_up;
    and(pc_up,branch,ex_alu_result[0]);
    always @(posedge clk) begin
        pc_updater <= pc_up;
    end
    always @(posedge clk) begin
           if(opcode==7'b1111111)
              $stop;
           else if(pc_updater)
           pc<=pc+(imm<<1);
           else
            pc <= pc + 4;
    end
    // always @(posedge clk) begin
    //     $display("Time: %0t | PC: %0h | Instruction: %0h | ALU Result: %0h | Mem Data: %0h", 
    //              $time, pc, if_instruction, ex_alu_result, mem_data);
    // end


endmodule


  



