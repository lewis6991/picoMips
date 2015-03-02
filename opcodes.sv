//------------------------------------------------------------------------------
// File       : opcodes.sv
// Author     : Lewis Russell
// Description: Definition of opcodes for picomips instructions set.
//------------------------------------------------------------------------------
parameter OP_LR    = 6'b100000; // Load register into accumulator.
parameter OP_LI    = 6'b000100; // Load immediate into accumulator.
parameter OP_LS    = 6'b000010; // Load switches into accumulator.
parameter OP_ADDR  = 6'b100001; // Add register to accumulator.
parameter OP_ADDI  = 6'b000101; // Add immediate to accumulator.
parameter OP_ADDS  = 6'b000011; // Add switches to accumulator.
parameter OP_MULR  = 6'b101001; // Multiply register to accumulator.
parameter OP_MULI  = 6'b001101; // Multiply immediate to accumulator.
parameter OP_MULS  = 6'b001011; // Multiply switches to accumulator.
parameter OP_CA    = 6'b000000; // Clear accumulator.
parameter OP_CR    = 6'b010000; // Clear register and accumulator.
parameter OP_NOP   = 6'b000001; // No operation.
parameter OP_AR    = 6'b010001; // Accumulator-to-register.
parameter OP_HEI   = 6'b100100; // Hold PC whilst SW[8] is equal to immediate.

// Obscure instructions
parameter OP_ASWI  = 6'b000110; // Add switches and immediate.
parameter OP_ASR   = 6'b100010; // Add switches and register.
parameter OP_ASIA  = 6'b000111; // Add switches, immediate and accumulator.
parameter OP_ASRA  = 6'b100011; // Add switches, register and accumulator.
parameter OP_AMSIA = 6'b001111; // Add switches and immediate then multiply to accumulator.
parameter OP_AMSRA = 6'b101011; // Add switches and register then multiply to accumulator.
