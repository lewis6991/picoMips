//------------------------------------------------------------------------------
// File       : program_memory.sv
// Author     : Lewis Russell
// Description: Program memory for picoMips.
//------------------------------------------------------------------------------
module program_memory(
    input               Clock      ,
    input        [ 4:0] Addr       ,
    output logic [11:0] Instruction
);

// Registers
parameter REG_1 = 6'd0;
parameter REG_2 = 6'd1;

// Immediates
parameter IMM_05  = 6'd4 ; // 0.5
parameter IMM_075 = 6'd6 ; // 0.75
parameter IMM_20  = 6'd20; // 20

`include "opcodes.sv"

always_ff @ (posedge Clock)
case (Addr)
    0 : Instruction = {OP_HEI ,  6'd0   }; // Wait for SW8 to become 1
    1 : Instruction = {OP_LS  ,  6'd0   }; // Load SW[7:0] (x1) to ACC
    2 : Instruction = {OP_MULI,  IMM_075}; // Multiply x1 by 0.75
    3 : Instruction = {OP_AR  ,  REG_1  }; // Move 0.75*x1 to $1
    4 : Instruction = {OP_LS  ,  6'd0   }; // Load SW[7:0] (x1) to ACC
    5 : Instruction = {OP_MULI, -IMM_05 }; // Multiply x1 by -0.5
    6 : Instruction = {OP_AR  ,  REG_2  }; // Move 0.75*x1 to $2
    7 : Instruction = {OP_HEI ,  6'd1   }; // Wait for SW8 to become 0
    8 : Instruction = {OP_HEI ,  6'd0   }; // Wait for SW8 to become 1
    9 : Instruction = {OP_LS  ,  6'd0   }; // Load SW[7:0] (y1) to ACC
    10: Instruction = {OP_MULI,  IMM_05 }; // Multiply y1 by 0.5
    11: Instruction = {OP_ADDR,  REG_1  }; // Add (0.75*x1) to (0.5*y1)
    12: Instruction = {OP_AR  ,  REG_1  }; // Move x2 to $1
    13: Instruction = {OP_LS  ,  6'd0   }; // Load SW[7:0] (y1) to ACC
    14: Instruction = {OP_MULI,  IMM_075}; // Multiply y1 by 0.75
    15: Instruction = {OP_ADDR,  REG_2  }; // Add (-0.5*x1) to (0.75*y1)
    16: Instruction = {OP_AR  ,  REG_2  }; // Move y2 to $2
    17: Instruction = {OP_HEI ,  6'd1   }; // Wait for SW8 to become 0
    18: Instruction = {OP_LR  ,  REG_1  }; // Load x2 into ACC
    19: Instruction = {OP_ADDI,  IMM_20 }; // Add (20) to (0.75*x1 + 0.5*y1)
    20: Instruction = {OP_HEI ,  6'd0   }; // Wait for SW8 to become 1
    21: Instruction = {OP_LR  ,  REG_2  }; // Load y2 into ACC
    22: Instruction = {OP_ADDI, -IMM_20 }; // Add (-20) to (-0.5*x1 + 0.75*y1)
    23: Instruction = {OP_HEI ,  6'd1   }; // Wait for SW8 to become 0
    default: Instruction = 12'd0;
endcase

endmodule
