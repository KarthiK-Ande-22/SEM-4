module processor (
    input clk
);

       // Register and wire declarations
    reg [31:0] instruction;  // Changed from wire to reg since it's assigned in always block
    reg [63:0] rs1_val, rs2_val;  // Added these as registers
    reg [63:0] alu_result,mem_data;  // Changed from wire to reg
    wire [63:0] id_rs1_val, id_rs2_val, id_imm, ex_alu_result;
    reg [4:0] rs1, rs2, rd;  // Changed from wire to reg since assigned in always block
    reg [63:0] imm;  // Changed from wire to reg
    reg branch, alu_src;  // Changed from wire to reg
    reg [3:0] alu_op;  // Changed from wire to reg
    reg [2:0] funct3;  // Changed from wire to reg
    reg [6:0] funct7, opcode;  // Changed from wire to reg
    reg overflow, memread, memwrite, memtoreg, regwrite;  // Changed from wire to reg
    
    // Added state tracking
    reg memory_done;
    reg execute_done;

    // Storage elements
    reg [63:0] register_file [0:31];
    reg [31:0] pc;
    reg [31:0] inst_mem [0:255];
    reg [63:0] data_memory [0:255];

    // Initialization block
    initial begin
        pc = 32'b0;
        memory_done = 0;
        execute_done = 0;
    end

    // Instruction fetch
    always @(posedge clk) begin
        instruction <= inst_mem[pc[9:2]];
        $display("Fetching instruction: %b at PC: %d", instruction, pc);
    end
    // Instruction Fetch Stage
    // instruction_fetch if_stage (
    //     .clk(clk),
    //     .pc(pc),
    //     .instruction(if_instruction)
    // );
    always @(posedge clk) begin
        // Decode instruction fields
        opcode <= instruction[6:0];
        rd <= instruction[11:7];
        funct3 <= instruction[14:12];
        funct7 <= instruction[31:25];
        rs1 <= instruction[19:15];
        rs2 <= instruction[24:20];
        
        // Control signal generation
        branch <= 0;
        alu_op <= 4'b0000;
        alu_src <= 0;
        imm <= 64'b0;
        memwrite <= 0;
        memtoreg <= 0;
        memread <= 0;
        regwrite <= 0;
// Decode based on opcode
case (instruction[6:0])
    7'b0110011: begin // R-type
        regwrite <= 1;
        case (instruction[14:12])  // Using instruction bits directly instead of funct3
            3'b000: begin
                case (instruction[31:25])  // Using instruction bits directly instead of funct7
                    7'b0000000: alu_op <= 4'b0010; // ADD
                    7'b0100000: alu_op <= 4'b0110; // SUB
                endcase
            end
            3'b001: alu_op <= 4'b0011; // SLL
            3'b100: alu_op <= 4'b1001; // XOR
            3'b101: begin
                case (instruction[31:25])
                    7'b0000000: alu_op <= 4'b0100; // SRL
                    7'b0100000: alu_op <= 4'b0101; // SRA
                endcase
            end
            3'b110: alu_op <= 4'b0001; // OR
            3'b111: alu_op <= 4'b0000; // AND
        endcase
    end
    7'b0010011: begin // I-type
        regwrite <= 1;
        alu_src <= 1;
        imm <= {{52{instruction[31]}}, instruction[31:20]}; // Sign-extend
        case (instruction[14:12])  // Using instruction bits directly instead of funct3
            3'b000: alu_op <= 4'b0010; // ADDI
            3'b001: alu_op <= 4'b0011; // SLLI
            3'b100: alu_op <= 4'b1001; // XORI
            3'b101: begin
                case (instruction[31:25])  // Using instruction bits directly instead of funct7
                    7'b0000000: alu_op <= 4'b0100; // SRLI
                    7'b0100000: alu_op <= 4'b0101; // SRAI
                endcase
            end
            3'b110: alu_op <= 4'b0001; // ORI
            3'b111: alu_op <= 4'b0000; // ANDI
        endcase
    end
    7'b1100011: begin // Branch
        branch <= 1;
        alu_src <= 0;
        imm <= {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // Sign-extend
        case (instruction[14:12])  // Using instruction bits directly instead of funct3
            3'b000: alu_op <= 4'b1010; // BEQ
            3'b001: alu_op <= 4'b1011; // BNE
            3'b100: alu_op <= 4'b1010; // SLT
            3'b101: begin // BGE
                alu_op <= 4'b1010;
                rs1 <= instruction[24:20];
                rs2 <= instruction[19:15];
            end
            3'b111: begin // BGEU
                alu_op <= 4'b0111;
                rs1 <= instruction[24:20];
                rs2 <= instruction[19:15];
            end
        endcase
    end
    default: begin
        // Default case for undefined instructions
        branch <= 0;
        alu_op <= 4'b0000;
        alu_src <= 0;
        imm <= 64'b0;
        memwrite <= 0;
        memtoreg <= 0;
        memread <= 0;
        regwrite <= 0;
    end
endcase
    end
        always @(posedge clk) begin
        $display("Instruction: %d", instruction);
        $display("Opcode: %b", opcode);
        $display("RD: %d", rd);
        $display("Funct3: %b", funct3);
        $display("RS1: %d", rs1);
        $display("RS2: %d", rs2);
        $display("Funct7: %b", funct7);
        $display("Immediate: %d", imm);
        $display("Control Signals: Branch=%b, ALU_OP=%b, ALU_SRC=%b, MemRead=%b, MemWrite=%b, MemToReg=%b, RegWrite=%b", 
                 branch, alu_op, alu_src, memread, memwrite, memtoreg, regwrite);
    end

    // Decode Stage - only execute when fetch is done
    // decode id_stage (
    //     .clk(clk),
    //     .instruction(if_instruction),
    //     .rs1(id_rs1),
    //     .rs2(id_rs2),
    //     .rd(id_rd),
    //     .funct3(funct3),
    //     .funct7(funct7),
    //     .opcode(opcode),
    //     .branch(branch),
    //     .alu_op(alu_op),
    //     .alu_src(alu_src),
    //     .imm(imm),
    //     .memread(Memread),
    //     .memwrite(Memwrite),
    //     .memtoreg(MemtoReg),
    //     .regwrite(Regwrite)
    // );

always @(posedge(clk)) begin
    rs1_val <= register_file[rs1];
    rs2_val <= register_file[rs2];
    overflow <= 0;
end
    // Execution Stage - only execute when decode is done
    // ex_stage execute_stage (
    //     .clk(clk),
    //     .rs1_val(id_rs1_val),
    //     .rs2_val(id_rs2_val),
    //     .imm(imm),
    //     .alu_src(alu_src),
    //     .alu_op(alu_op),
    //     .branch(branch),
    //     .alu_result(ex_alu_result),
    //     .overflow(overflow)
    // );
    wire [63:0] operand_b;
    assign operand_b = alu_src ? imm : rs2_val;
    wire [63:0] add_result, sub_result, and_result, or_result, xor_result;
    wire [63:0] shifted_left, shifted_right_logical, shifted_right_arithmetic;
    wire lt_signed, lt_unsigned,compartor,not_compartor;
    wire add_overflow, shift_overflow;

    add adder_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(add_result), 
        .overflow(add_overflow)
    );

    sub sub_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(sub_result), 
        .overflow(sub_overflow)
    );

    and_gate and_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(and_result)
    );

    or_gate or_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(or_result)
    );

    xor_gate xor_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .reg3(xor_result)
    );

    left_shifter left_shift_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_left), 
        .overflow(shift_overflow)
    );

    right_shifter_logical right_shift_log_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_right_logical)
    );

    right_shifter_arthemetic right_shift_arith_inst (
        .data_in(rs1_val), 
        .shift_amt(operand_b[5:0]), 
        .data_out(shifted_right_arithmetic)
    );

    signed_lt_comparator slt_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .lt(lt_signed)
    );

    unsigned_lt_comparator ult_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .lt(lt_unsigned)
    );
    compartor comp_inst (
        .reg1(rs1_val), 
        .reg2(operand_b), 
        .eq(compartor)
    );
 not(not_compartor,comp_result);

    always @(posedge clk) begin
        alu_result <= 64'b0;
        overflow <= 1'b0;
        case (alu_op)
            4'b0000: begin
                alu_result <= and_result;
                overflow <= 1'b0;
            end
            4'b0001: begin
                alu_result <= or_result;
                overflow <= 1'b0;
            end
            4'b0010: begin
                alu_result <= add_result;
                overflow <= add_overflow;
            end
            4'b0011: begin
                alu_result <= shifted_left;
                overflow <= shift_overflow;
            end
            4'b0100: begin
                alu_result <= shifted_right_logical;
                overflow <= 1'b0;
            end
            4'b0101: begin
                alu_result <= shifted_right_arithmetic;
                overflow <= 1'b0;
            end
            4'b0110: begin
                alu_result <= sub_result;
                overflow <= sub_overflow;
            end
            4'b0111: begin
                alu_result <= {63'b0, lt_unsigned};
                overflow <= 1'b0;
            end
            4'b1000: begin
                alu_result <= {63'b0, lt_signed};
                overflow <= 1'b0;
            end
            4'b1001: begin
                alu_result <= xor_result;
                overflow <= 1'b0;
            end
            4'b1010: begin
                alu_result <= {63'b0, not_compartor};
                overflow <= 1'b0;
            end
            4'b1011: begin
                alu_result <= {63'b0, not_compartor};
                overflow <= 1'b0;
            end
            default: begin
                alu_result <= 64'b0;
                overflow <= 1'b0;
            end
        endcase
         execute_done <= 1;
    end
        always @(posedge clk) begin
        $display("ALU Output: %d, Overflow: %b", alu_result, overflow);
    end
        always @(posedge clk) begin
        if (memread) begin
            mem_data <= data_memory[alu_result[7:0]];
        end else if (memwrite) begin
            data_memory[alu_result[7:0]] <= rs2_val;  // Changed from rs2 to rs2_val
        end
        memory_done <= 1;
    end

    // Writeback Stage
    always @(posedge clk) begin
        if (memory_done) begin
            if (memtoreg) begin  // Changed from MemtoReg_reg to memtoreg
                register_file[rd] <= mem_data;  // Changed from id_rd to rd
            end else if (regwrite) begin  // Changed from Regwrite_reg to regwrite
                register_file[rd] <= alu_result;  // Changed from ex_alu_result to alu_result
            end
        end
    end

    // PC Update Logic
    reg pc_updater;
    wire pc_up;
    and(pc_up, branch, alu_result[0]);  // Changed from ex_alu_result to alu_result

    always @(posedge clk) begin
        if (execute_done) begin
            pc_updater <= pc_up;
        end
    end

    always @(posedge clk) begin
        if (execute_done) begin
            if (pc_updater)
                pc <= pc + (imm << 1);
            else
                pc <= pc + 4;
        end
    end

    always @(posedge clk) begin
        $display("Time: %0t | PC: %d | Instruction: %d | ALU Result: %d | Mem Data: %d", 
                 $time, pc, instruction, alu_result, mem_data);
    end

endmodule
