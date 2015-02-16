//------------------------------------------------------------------------------
// File       : picoMips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module picomips(
    input              Clock,
    input        [9:0] SW   ,
    output logic [7:0] LED
);

parameter OP_ADD = 3'b000;
parameter OP_SUB = 3'b001;
parameter OP_MUL = 3'b010;
parameter OP_LI  = 3'b011;
parameter OP_HEN = 3'b100;
parameter OP_HEQ = 3'b101;
parameter OP_J   = 3'b110;
parameter OP_MOV = 3'b111;

logic [15:0] instruction;
logic [ 2:0] Func       ;
logic [16:0] Out        ;
logic        Rd_write   ;

//ALU Flags
logic N_flag; // Output is negative.
logic Z_flag; // Output is zero.

logic nReset;
assign nReset = SW[9];

//------------------------------------------------------------------------------
// Program Counter -------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] program_counter;
logic       pc_jump        ;
logic       pc_hold        ;
logic [7:0] pc_jump_addr   ;

assign pc_jump_addr = instruction[12:5];

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        program_counter <= 32'b0;
    else if (pc_jump)
        program_counter <= #20 pc_jump_addr;
    else if (~pc_hold)
        program_counter <= #20 program_counter + 1;
//------------------------------------------------------------------------------
// Program Memory --------------------------------------------------------------
//------------------------------------------------------------------------------
logic [15:0] program_memory [0:26] = {
    {OP_HEQ, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 1
    {OP_MOV, 4'd4 , 4'd2 , 5'b0}, // Load SW[7:0] into $x1/$4
    {OP_HEN, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 0
    {OP_HEQ, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 1
    {OP_MOV, 4'd5 , 4'd2 , 5'b0}, // Load SW[7:0] into $y1/$5
    {OP_HEN, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 0
    {OP_LI , 4'd8 , 8'd42, 1'b0}, // Load 0.75 into $t1/$8
    {OP_LI , 4'd9 , 8'd35, 1'b0}, // Load  0.5 into $t2/$9
    {OP_LI , 4'd10, 8'd96, 1'b0}, // Load    5 into $t3/$10
    {OP_LI , 4'd11, 8'd51, 1'b0}, // Load   12 into $t4/$11
    // Calc x2
    {OP_MOV, 4'd6 , 4'd4 , 5'b0}, // Load $x1/$4 into $x2/$6
    {OP_MUL, 4'd6 , 4'd8 , 5'b0}, // Multiply x1 by 0.75
    {OP_MOV, 4'd12, 4'd5 , 5'b0}, // Load y1 into $t5/$12
    {OP_MUL, 4'd12, 4'd9 , 5'b0}, // Multiply y1 by 0.5
    {OP_ADD, 4'd6 , 4'd12, 5'b0}, // Add (0.5*y1) to (0.75*x1)
    {OP_ADD, 4'd6 , 4'd10, 5'b0}, // Add (5) to (0.5*y1 + 0.75*x1)
    // Output x2
    {OP_MOV, 4'd3 , 4'd6 , 5'b0}, // Output x2 to LED's
    {OP_HEQ, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 1
    // Calc y2
    {OP_MOV, 4'd7 , 4'd5 , 5'b0}, // Load $y1/$5 into $y2/$7
    {OP_MUL, 4'd7 , 4'd8 , 5'b0}, // Multiply y1 by 0.75
    {OP_MOV, 4'd13, 4'd4 , 5'b0}, // Load x1 into $t5/$13
    {OP_MUL, 4'd13, 4'd9 , 5'b0}, // Multiply x1 by 0.5
    {OP_SUB, 4'd7 , 4'd13, 5'b0}, // Subtract (0.5*x1) from (0.75*y1)
    {OP_ADD, 4'd7 , 4'd11, 5'b0}, // Add (12) to (-0.5*x1 + 0.75*y1)
    // Output y2
    {OP_MOV, 4'd3 , 4'd7 , 5'b0}, // Output y2 to LED's
    {OP_HEN, 4'd0 , 4'd1 , 5'b0}, // Wait for SW8 to become 0
    {OP_J  , 13'd0             } // Jump to beginning.
};
assign instruction = program_memory[program_counter];
//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------
always_comb begin
    pc_hold  = 0;
    Rd_write = 0;
    pc_jump  = 0;
    case (Func)
        OP_LI , OP_MOV: Rd_write = 1      ;
        OP_ADD        : Rd_write = 1      ;
        OP_SUB        : Rd_write = 1      ;
        OP_MUL        : Rd_write = 1      ;
        OP_HEQ        : pc_hold  =  Z_flag; // Hold if output is zero.
        OP_HEN        : pc_hold  = ~Z_flag; // Hold if output is NOT zero.
        OP_J          : pc_jump  = 1      ;
    endcase
end

//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] registers[3:15];
logic [3:0] Rs             ;
logic [3:0] Rd             ;
logic [7:0] Rd_write_data  ;
logic [7:0] Rd_data        ;
logic [7:0] Rs_data        ;

assign Rd            = instruction[12:9];
assign Rs            = instruction[ 8:5];
assign Rd_write_data = Out[8:0]         ;
assign LED           = registers[3]     ;

// Asynchronous Read
always_comb begin
    case (Rd)
        0      : Rd_data = 8'b0         ;
        1      : Rd_data = {7'b0, SW[8]};
        2      : Rd_data = SW[7:0]      ;
        default: Rd_data = registers[Rd];
    endcase
    case (Rs)
        0      : Rs_data = 8'b0         ;
        1      : Rs_data = {7'b0, SW[8]};
        2      : Rs_data = SW[7:0]      ;
        default: Rs_data = registers[Rs];
    endcase
end

// Synchronous Write
always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        for (int i = 3; i < 16; ++i)
            registers[i] <= #20 32'b0;
    else if (Rd > 2 && Rd_write)
        registers[Rd] = Rd_write_data;
//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [ 8:0] A, B     ;
logic [ 7:0] immediate;

assign immediate = instruction[8:1]                     ;
assign Func      = instruction[15:13]                   ;
assign A         = Rd_data                              ;
assign B         = (Func == OP_LI) ? immediate : Rs_data;
assign N_flag    = Out[15]                              ;
assign Z_flag    = (Out == 16'b0)                       ;

always_comb
    case (Func)
        OP_ADD                : Out = A + B;
        OP_SUB, OP_HEQ, OP_HEN: Out = A - B;
        OP_MUL                : Out = A * B;
        OP_LI , OP_J  , OP_MOV: Out = B    ;
    endcase
//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
