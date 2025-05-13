
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

