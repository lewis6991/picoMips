//------------------------------------------------------------------------------
// File       : alu.sv
// Author     : Lewis Russell
// Description: Arithmetic logic unit for picoMips implementations.
//------------------------------------------------------------------------------
`include "opcodes.sv"
`include "mul_ops.sv"
module alu(
    input              Clock  ,
    input              nReset ,
    input        [7:0] Imm    , // Immediate sign extended from instruction.
    input        [7:0] RegData, // Data from register file.
    input        [7:0] SW     , // Input switches.
    input              WE     , // Write Enable for ACC.
    input              SelSW  , // Select switches as an argument.
    input              SelImm , // Select immediate as an argument.
    input              SelReg , // Select regdata as an argument.
    input              UseMul , // Use Multiply operation.
    input              UseACC , // Use ACC as an argument for operation.
    output logic [7:0] ACC      // Accumulator.
);

wire signed [7:0] mulb  ;
wire signed [7:0] mula  ;
wire signed [7:0] data  ;
wire signed [7:0] subimm;

mul3mux mul3mux0(
    .A  (Imm    ),
    .B  (SW     ),
    .C  (RegData),
    .SA (SelImm ),
    .SB (SelSW  ),
    .SC (SelReg ),
    .Out(data   )
);

muladd muladd0(
    .A     (ACC   ),
    .B     (data  ),
    .EnA   (UseACC),
    .EnB   (1'b1  ),
    .Out   (mula  ),
    .Clock (1'd0  ),
    .nReset(1'd0  )
);

mult mult0(
    .A     ({7'b0, UseMul}),
    .B     (Imm           ),
    .Out   (subimm        ),
    .Clock (1'd0          ),
    .nReset(1'd0          )
);

assign mulb = {subimm[7:4], ~UseMul | subimm[3], subimm[2:0]};

// Dummy signal used to allign multiplier output. Gets optimised away by synthesiser.
logic signed [2:0] tmp;

always_ff @ (posedge Clock, negedge nReset)
   if (~nReset)
	   ACC <= 8'd0;
	else if (WE)
        {ACC, tmp} <= #20 mula * mulb;

endmodule
