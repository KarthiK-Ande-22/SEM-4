


// module imm_generation (
//     input wire [31:0] instruction,
//     output reg [63:0] immediate
// );
    
//     wire [11:0] imm;
//     assign imm = instruction[31:20];

//     always @(*) begin
//         immediate = {{52{imm[11]}}, imm}; 
//     end

// endmodule


// module imm_branch (
//     input wire [31:0] instruction,
//     output reg [63:0] immediate
// );
    
//     wire [11:0] imm;
//     assign imm[11] = instruction[31];
//     assign imm[10]= instruction[7];
//     assign imm[9:4] = instruction[30:25];
//     assign imm[3:0] = instruction[11:8];

//     always @(*) begin
//         immediate = {{52{imm[11]}}, imm}; 
//     end

// endmodule

// module imm_store (
//     input wire [31:0] instruction,
//     output reg [63:0] immediate
// );
    
//     wire [11:0] imm;
//     assign imm[11:5] = instruction[31:25];
//     assign imm[4:0] = instruction[11:7];

//     always @(*) begin
//         immediate = {{52{imm[11]}}, imm}; 
//     end 

// endmodule



// module imm_gen_all_types (
//     input wire [31:0] instruction,
//     output reg [63:0] immediate
// );
//     wire [6:0] opcode_decide;
//     wire [11:0] imm;

//     assign opcode_decide = instruction[6:0];


//     if(opcode_decide == 7'b1100011) begin // branch  
//     // need to think about the index values of imm

//         assign imm[11] = instruction[31];
//         assign imm[10]= instruction[7];
//         assign imm[9:4] = instruction[30:25];   
//         assign imm[3:0] = instruction[11:8];
//     end
//     else if(opcode_decide == 7'b0000011) begin // load
//         assign imm= instruction[31:20];
//     end
//     else if(opcode_decide == 7'b0100011) begin // store
//         assign imm[11:5] = instruction[31:25];
//         assign imm[4:0] = instruction[11:7];
//     end
//     else begin // imm_gen
//         assign imm = instruction[31:20];
//     end



//     always @(*) begin
//         immediate = {{52{imm[11]}}, imm}; 
//     end


    
// endmodule


    module imm_gen_all_types (
        input wire [31:0] instruction,
        output reg [63:0] immediate
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
    endmodule



    // module imm_gen_all_types (
    //     input wire [31:0] instruction,
    //     output reg [63:0] immediate
    // );
    //     wire [6:0] opcode_decide;
    //     reg [12:0] imm;  

    //     assign opcode_decide = instruction[6:0];

    //     always @(*) begin
    //         imm[12] = 1'b0;
    //         imm[11:0] = instruction[31:20];

    //         if(opcode_decide == 7'b1100011) begin  // Branch instruction
    //             imm[12] = instruction[31];
    //             imm[11] = instruction[7];
    //             imm[10:5] = instruction[30:25];
    //             imm[4:1] = instruction[11:8];
    //             imm[0] = 1'b0;
    //         end
            
    //         else if(opcode_decide == 7'b0000011) begin  // Load instruction
    //             imm[11:0] = instruction[31:20];
    //         end
            
    //         else if(opcode_decide == 7'b0100011) begin // Store instruction
                
    //             imm[11:5] = instruction[31:25];
    //             imm[4:0] = instruction[11:7];
    //         end
    //     end

    //     always @(*) begin
    //         if(opcode_decide == 7'b1100011) begin
    //             immediate = {{51{imm[12]}}, imm}; 
    //         end
    //         else begin
    //         immediate = {{52{imm[11]}}, imm[11:0]}; 
    //         end
    //     end
    // endmodule


// module imm_gen_all_types (
//     input wire [31:0] instruction,
//     output reg [63:0] immediate
// );
//     wire [6:0] opcode_decide;
//     reg [12:0] imm;  

//     assign opcode_decide = instruction[6:0];

//     always @(*) begin
//         case (opcode_decide)
//             7'b1100011: begin // Branch (B-type)
//                 imm[12]  = instruction[31];
//                 imm[11]  = instruction[7];
//                 imm[10:5] = instruction[30:25];
//                 imm[4:1]  = instruction[11:8];
//                 imm[0]    = 1'b0;  // Always zero for branch
//             end
//             7'b0000011, // Load (I-type)
//             7'b0010011, // Immediate (I-type)
//             7'b1100111: begin // JALR
//                 imm = instruction[31:20]; 
//             end
//             7'b0100011: begin // Store (S-type)
//                 imm[11:5] = instruction[31:25];
//                 imm[4:0]  = instruction[11:7];
//             end
//             default: imm = 12'b0; // Default case (avoid latches)
//         endcase
//     end

//     always @(*) begin
//         if (opcode_decide == 7'b1100011) begin
//             immediate = {{51{imm[12]}}, imm[12:0]};  // Sign extend for B-type
//         end
//         else begin
//             immediate = {{52{imm[11]}}, imm[11:0]};  // Sign extend for I & S types
//         end
//     end
// endmodule
