//------------------------------------------------------------------------------
// File       : program_memory.sv
// Author     : Lewis Russell
// Description: Program memory for picoMips.
//------------------------------------------------------------------------------
module program_memory(
    input              Clock      ,
    input        [4:0] Addr       ,
    output logic [9:0] Instruction
);

// Multiplier immediates
parameter I_05  = 4'd2; // 0.5
parameter I_075 = 4'd3; // 0.75

`include "opcodes.sv"

always_ff @ (posedge Clock)
case (Addr)
    0 : Instruction = {OP_HEI ,  4'd0 }; // Wait for SW8 to become 1
    1 : Instruction = {OP_LS  ,  4'd0 }; // Load SW[7:0] (x1) to ACC
    2 : Instruction = {OP_MULI,  I_075}; // Multiply x1 by 0.75
    3 : Instruction = {OP_AR  ,  4'd0 }; // Move 0.75*x1 to $1
    4 : Instruction = {OP_LS  ,  4'd0 }; // Load SW[7:0] (x1) to ACC
    5 : Instruction = {OP_MULI, -I_05 }; // Multiply x1 by -0.5
    6 : Instruction = {OP_AR  ,  4'd1 }; // Move 0.75*x1 to $2
    7 : Instruction = {OP_HEI ,  4'd1 }; // Wait for SW8 to become 0
    8 : Instruction = {OP_HEI ,  4'd0 }; // Wait for SW8 to become 1
    9 : Instruction = {OP_LS  ,  4'd0 }; // Load SW[7:0] (y1) to ACC
    10: Instruction = {OP_MULI,  I_05 }; // Multiply y1 by 0.5
    11: Instruction = {OP_ADDR,  4'd0 }; // Add (0.75*x1) to (0.5*y1)
    12: Instruction = {OP_AR  ,  4'd0 }; // Move x2 to $1
    13: Instruction = {OP_LS  ,  4'd0 }; // Load SW[7:0] (y1) to ACC
    14: Instruction = {OP_MULI,  I_075}; // Multiply y1 by 0.75
    15: Instruction = {OP_ADDR,  4'd1 }; // Add (-0.5*x1) to (0.75*y1)
    16: Instruction = {OP_AR  ,  4'd1 }; // Move y2 to $2
    17: Instruction = {OP_HEI ,  4'd1 }; // Wait for SW8 to become 0
    18: Instruction = {OP_LR  ,  4'd0 }; // Load x2 into ACC
    19: Instruction = {OP_ADDI,  4'd7 }; // \
    20: Instruction = {OP_ADDI,  4'd7 }; // Add 20 (7+7+6) to (0.75*x1 + 0.5*y1)
    21: Instruction = {OP_ADDI,  4'd6 }; // /
    22: Instruction = {OP_HEI ,  4'd0 }; // Wait for SW8 to become 1
    23: Instruction = {OP_LR  ,  4'd1 }; // Load y2 into ACC
    24: Instruction = {OP_ADDI, -4'd7 }; // \
    25: Instruction = {OP_ADDI, -4'd7 }; // Add -20 (-7-7-6) to (-0.5*x1 + 0.75*y1)
    26: Instruction = {OP_ADDI, -4'd6 }; // /
    27: Instruction = {OP_HEI ,  4'd1 }; // Wait for SW8 to become 0
    default: Instruction = 10'd0;
endcase

endmodule
