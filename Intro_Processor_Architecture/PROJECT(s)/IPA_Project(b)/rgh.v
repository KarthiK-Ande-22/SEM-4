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