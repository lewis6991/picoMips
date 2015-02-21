//------------------------------------------------------------------------------
// File       : picoMips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module picomips(
    input        Clock,
    input  [9:0] SW   ,
    output [7:0] LED
);

parameter OP_LSW  = 3'b001;
parameter OP_RTA  = 3'b010;
parameter OP_ATR  = 3'b011;
parameter OP_ADD  = 3'b100;
parameter OP_ADDI = 3'b101;
parameter OP_MULI = 3'b110;
parameter OP_HEI  = 3'b111;

// Reigsters
parameter LEDS  = 5'd0;
parameter REG_1 = 5'd1;
parameter REG_2 = 5'd2;
parameter REG_3 = 5'd3;

reg          [7:0] instruction;
wire         [2:0] Func       ;
logic signed [7:0] acc        ;
logic              pc_hold    ;

logic acc_we;


wire nReset;
assign nReset = SW[9];

//------------------------------------------------------------------------------
// Program Counter -------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] program_counter;

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        program_counter <= #20 0;
    else if (~pc_hold)
        program_counter <= #20 program_counter + 1;
//------------------------------------------------------------------------------
// Program Memory --------------------------------------------------------------
//------------------------------------------------------------------------------
always_ff @ (posedge Clock)
case (program_counter[7:2])
    0 : instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    1 : instruction = {OP_LSW , REG_1}; // Load SW[7:0] (x1) to REG_1
    2 : instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    3 : instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    4 : instruction = {OP_LSW , REG_2}; // Load SW[7:0] (y1) to REG_2
    5 : instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    // Calc x2
    6 : instruction = {OP_RTA , REG_1}; // Load x1 into ACC
    7 : instruction = {OP_MULI, 5'd3 }; // Multiply x1 by 0.75
    8 : instruction = {OP_ATR , REG_3}; // Move 0.75*x1 to $3
    9 : instruction = {OP_RTA , REG_2}; // Load y1 into ACC
    10: instruction = {OP_MULI, 5'd2 }; // Multiply y1 by 0.5
    11: instruction = {OP_ADD , REG_3}; // Add (0.75*x1) to (0.5*y1)
    12: instruction = {OP_ADDI, 5'd10}; // Add (20) to (0.75*x1 + 0.5*y1)
    13: instruction = {OP_ATR , LEDS }; // Move ACC (x2) to LED's
    // Calc y2
    14: instruction = {OP_RTA , REG_1}; // Load x1 into ACC
    15: instruction = {OP_MULI, 5'd30}; // Multiply x1 by -0.5
    16: instruction = {OP_ATR , REG_3}; // Move -0.5*x1 to $3
    17: instruction = {OP_RTA , REG_2}; // Load y1 into ACC
    18: instruction = {OP_MULI, 5'd3 }; // Multiply y1 by 0.75
    19: instruction = {OP_ADD , REG_3}; // Add (-0.5*x1) to (0.75*y1)
    20: instruction = {OP_ADDI, 5'd22}; // Add (-20) to (-0.5*x1 + 0.75*y1)
    21: instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    22: instruction = {OP_ATR , LEDS }; // Move ACC (y2) to LED's
    23: instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    default: instruction = 0;
endcase

//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------
wire hei_arg;

assign hei_arg   = instruction[0];
assign reg_write = (Func == OP_ATR || Func == OP_LSW);
assign pc_hold   = (Func == OP_HEI) ? (SW[8] == hei_arg) : 1'b0;
assign acc_we    = program_counter[0] && program_counter[1] && (Func == OP_RTA || Func == OP_MULI || Func == OP_ADDI || Func == OP_ADD);
//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] registers[0:3];
wire  [1:0] reg_addr      ;
wire  [7:0] reg_write_data;
logic [7:0] reg_data      ;

assign reg_addr       = instruction[1:0];
assign reg_write_data = (Func == OP_LSW) ? SW[7:0] : acc;
assign LED            = registers[0]    ;

// Synchronous Read/Write
always_ff @ (posedge Clock) begin
    if (reg_write)
        registers[reg_addr] <= #20 reg_write_data;
    reg_data <= #20 registers[reg_addr];
end

//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
wire signed [7:0] B        ;
wire        [7:0] immediate;

assign immediate = {instruction[4], instruction[4], instruction[4:0], 1'b0}  ;
assign Func      = instruction[7:5]                                          ;
assign B         = (Func == OP_MULI || Func == OP_ADDI) ? immediate: reg_data;

logic signed [2:0] tmp;

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        acc <= #20 0;
    else if (acc_we)
        case (Func)
            OP_MULI        : {acc, tmp} <= #20 acc * B;
            OP_ADD, OP_ADDI:        acc <= #20 acc + B;
            OP_RTA         :        acc <= #20 B      ;
        endcase
//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
