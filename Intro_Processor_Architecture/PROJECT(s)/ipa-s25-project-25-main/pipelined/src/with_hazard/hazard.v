
//////////////////////////////////////hazard detection unit//////////////////////////////////////////////

module HazardDetectionUnit(
    input wire idex_memread,         // Memory read signal in EX stage
    input wire [4:0] idex_rd, // Destination register in EX stage
    input wire [4:0] ifid_rs1, // Source register in ID stage
    input wire [4:0] ifid_rs2, // Destination register in ID stage
    output reg stall              // Stall control signal
);

    always@(*) begin
        // Default: No stall
        stall = 1'b0;

        // If the instruction in the EX stage is reading from memory and
        // the next instruction is using that register, insert a stall
        if (idex_memread && ((idex_rd == ifid_rs1) || (idex_rd == ifid_rs2))) begin
            stall = 1'b1;
        end
    end

endmodule