//------------------------------------------------------------------------------
// File       : picoMips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module picomips(
    input               Clock,
    input         [9:0] SW   ,
    output signed [7:0] LED
);

parameter OP_LSW  = 3'b001;
parameter OP_RTA  = 3'b010;
parameter OP_ATR  = 3'b011;
parameter OP_ADD  = 3'b100;
parameter OP_ADDI = 3'b101;
parameter OP_MULI = 3'b110;
parameter OP_HEI  = 3'b111;

// Reigsters
parameter REG_1 = 5'd0;
parameter REG_2 = 5'd1;

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
logic [6:0] program_counter;

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        program_counter <= #20 0;
    else if (~pc_hold)
        program_counter <= #20 program_counter + 1;
//------------------------------------------------------------------------------
// Program Memory --------------------------------------------------------------
//------------------------------------------------------------------------------
always_ff @ (posedge Clock)
case (program_counter[6:2])
    0 : instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    1 : instruction = {OP_LSW , 5'd0 }; // Load SW[7:0] (x1) to ACC
    2 : instruction = {OP_MULI, 5'd3 }; // Multiply x1 by 0.75
    3 : instruction = {OP_ATR , REG_1}; // Move 0.75*x1 to $1
    4 : instruction = {OP_LSW , 5'd0 }; // Load SW[7:0] (x1) to ACC
    5 : instruction = {OP_MULI, 5'd30}; // Multiply x1 by -0.5
    6 : instruction = {OP_ATR , REG_2}; // Move 0.75*x1 to $2
    7 : instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    8 : instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    9 : instruction = {OP_LSW , 5'd0 }; // Load SW[7:0] (y1) to ACC
    10: instruction = {OP_MULI, 5'd2 }; // Multiply y1 by 0.5
    11: instruction = {OP_ADD , REG_1}; // Add (0.75*x1) to (0.5*y1)
    12: instruction = {OP_ADDI, 5'd10}; // Add (20) to (0.75*x1 + 0.5*y1)
    13: instruction = {OP_ATR , REG_1}; // Move x2 to $1
    14: instruction = {OP_LSW , 5'd0 }; // Load SW[7:0] (y1) to ACC
    15: instruction = {OP_MULI, 5'd3 }; // Multiply y1 by 0.75
    16: instruction = {OP_ADD , REG_2}; // Add (-0.5*x1) to (0.75*y1)
    17: instruction = {OP_ADDI, 5'd22}; // Add (-20) to (-0.5*x1 + 0.75*y1)
    18: instruction = {OP_ATR , REG_2}; // Move y2 to $2
    19: instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    20: instruction = {OP_RTA , REG_1}; // Load x2 into ACC
    21: instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    22: instruction = {OP_RTA , REG_2}; // Load y2 into ACC
    23: instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    default: instruction = 0;
endcase

//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------
wire hei_arg;

assign hei_arg   = instruction[0];
assign reg_write = (Func == OP_ATR);
assign pc_hold   = (Func == OP_HEI) ? (SW[8] == hei_arg) : 1'b0;
assign acc_we    = program_counter[0] && program_counter[1] && !(Func == OP_HEI || Func == OP_ATR);
//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic signed [7:0] registers[0:1] = {0,0};
wire               reg_addr      ;
wire  signed [7:0] reg_write_data;
logic signed [7:0] reg_data      ;

assign reg_addr       = instruction[0];
assign reg_write_data = acc           ;
assign LED            = acc           ;

// Synchronous Read/Write
always_ff @ (posedge Clock) begin
    if (reg_write)
        registers[reg_addr] <= #20 reg_write_data;
    reg_data <= #20 registers[reg_addr];
end

//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
wire signed [7:0] A        ;
wire signed [7:0] immediate;

assign immediate = {instruction[4], instruction[4], instruction[4:0], 1'b0}                                ;
assign Func      = instruction[7:5]                                                                        ;
assign A         = (Func == OP_LSW) ? SW[7:0] : (Func == OP_MULI || Func == OP_ADDI) ? immediate : reg_data;

logic signed [2:0] tmp;

always_ff @ (posedge Clock)
    if (acc_we)
        case (Func)
            OP_MULI        : {acc, tmp} <= #20 acc * A;
            OP_ADD, OP_ADDI:        acc <= #20 acc + A;
            OP_RTA, OP_LSW :        acc <= #20 A      ;
        endcase
//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
