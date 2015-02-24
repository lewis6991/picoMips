//------------------------------------------------------------------------------
// File       : picomips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
`include "opcodes.sv"
`include "alu.sv"
module mulmux(
    input        [7:0] a,b,
	 input              sel,
	 output logic [7:0] out
);

logic [7:0] suba, subb, sa, sb;

mult mult0 (.A({7'd0, ~sel}), .B(a), .ACC(suba));
mult mult1 (.A({7'd0,  sel}), .B(b), .ACC(subb));
assign sa = {suba[7:1], suba[0] | ~sel};
assign sb = {subb[7:1], subb[0] |  sel};
assign out = sa * sb;

endmodule

module picomips(
    input               Clock,
    input         [9:0] SW   ,
    output signed [7:0] LED
);

// Reigsters
parameter REG_1 = 5'd0;
parameter REG_2 = 5'd1;

reg          [7:0] instruction;
wire         [2:0] Func       ;
logic signed [7:0] acc        ;
logic              pc_hold    ;
logic              acc_we     ;

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
    12: instruction = {OP_ATR , REG_1}; // Move x2 to $1
    13: instruction = {OP_LSW , 5'd0 }; // Load SW[7:0] (y1) to ACC
    14: instruction = {OP_MULI, 5'd3 }; // Multiply y1 by 0.75
    15: instruction = {OP_ADD , REG_2}; // Add (-0.5*x1) to (0.75*y1)
    16: instruction = {OP_ATR , REG_2}; // Move y2 to $2
    17: instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    18: instruction = {OP_RTA , REG_1}; // Load x2 into ACC
    19: instruction = {OP_ADDI, 5'd10}; // Add (20) to (0.75*x1 + 0.5*y1)
    20: instruction = {OP_HEI , 5'd0 }; // Wait for SW8 to become 1
    21: instruction = {OP_RTA , REG_2}; // Load y2 into ACC
    22: instruction = {OP_ADDI, 5'd22}; // Add (-20) to (-0.5*x1 + 0.75*y1)
    23: instruction = {OP_HEI , 5'd1 }; // Wait for SW8 to become 0
    default: instruction = 0;
endcase
//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------
wire hei_arg;

assign hei_arg   = instruction[0]                              ;
assign reg_write = (Func == OP_ATR)                            ;
assign pc_hold   = (Func == OP_HEI) ? (SW[8] == hei_arg) : 1'b0;
assign acc_we    = program_counter[0] && program_counter[1]
                        && !(Func == OP_HEI || Func == OP_ATR);
//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic signed [7:0] registers[0:1];
wire               reg_addr      ;
logic signed [7:0] reg_data      ;

assign reg_addr = instruction[0];
assign LED      = acc           ;

// Synchronous Read/Write
always_ff @ (posedge Clock) begin
    if (reg_write)
        registers[reg_addr] <= #20 acc;
    reg_data <= #20 registers[reg_addr];
end
//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
wire signed [7:0] immediate;

assign immediate = {instruction[4], instruction[4], instruction[4:0], 1'b0};
assign Func      = instruction[7:5]                                        ;

alu alu0(
    .Clock  (Clock    ),
    .Imm    (immediate),
    .Func   (Func     ),
    .WE     (acc_we   ),
    .ACC    (acc      ),
    .SelImm (Func[2]  ),
    .SelSW  (Func[1]  ),
    .UseMul (Func == OP_MULI),
    .UseACC (Func[0]  ),
    .SW     (SW[7:0]  ),
    .RegData(reg_data )
);

//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
