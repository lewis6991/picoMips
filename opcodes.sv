//------------------------------------------------------------------------------
// File       : opcodes.sv
// Author     : Lewis Russell
// Description: Definition of opcodes for picomips instructions set.
//------------------------------------------------------------------------------
parameter OP_LSW  = 7'b0000010; // Load Switches.
parameter OP_RTA  = 7'b1000000; // Register-to-Accumulator.
parameter OP_ATR  = 7'b0010001; // Accumulator-to-Register.
parameter OP_ADD  = 7'b1000001; // Add Register to Accumulator.
parameter OP_ADDI = 7'b0000101; // Add Immediate to Accumulator.
parameter OP_MULI = 7'b0001101; // Multiply Immediate to Accumulator.
parameter OP_HEI  = 7'b0100100; // Hold PC whilst SW[8] is equal to Immeidate.
