
module branch_hazard_unit (
    input wire branch,           // Branch signal from EX/MEM stage
    input wire zero,             // Zero flag from ALU in EX/MEM stage
    input wire clk,              // Clock signal
    output reg flush_ifid,       // Signal to flush IF/ID pipeline register
    output reg flush_idex,       // Signal to flush ID/EX pipeline register
    output reg pc_src            // Signal to select PC source (0 for PC+4, 1 for branch target)
);

    // Branch decision logic
    always @(*) begin
        // If branch instruction and condition is met (zero flag is set)
        if (branch && zero) begin
            flush_ifid = 1'b1;   // Flush the pipeline
            flush_idex = 1'b1;   // Flush ID/EX stage as well
            pc_src = 1'b1;       // Select branch target
        end else begin
            flush_ifid = 1'b0;   // No flush
            flush_idex = 1'b0;   // No flush for ID/EX
            pc_src = 1'b0;       // Continue with sequential execution
        end
    end

endmodule