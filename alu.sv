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
    input              WE     , // Write Enable for ACC.
    input              UseMul , // Use Multiply operation.
    input              UseA   , // Use ACC as an argument for operation.
    input        [7:0] DataA  ,
    input        [7:0] DataB  ,
    output logic [7:0] ACC      // Accumulator.
);

wire signed [7:0] mulb    ;
wire signed [7:0] mula    ;
wire signed [7:0] subdatab;

muladd muladd0(
    .A     (DataA  ),
    .B     (DataB  ),
    .EnA   (UseA   ),
    .EnB   (~UseMul),
    .Out   (mula   ),
    .Clock (1'd0   ),
    .nReset(1'd0   )
);

mult mult0(
    .A     ({7'b0, UseMul}),
    .B     (DataB         ),
    .Out   (subdatab      ),
    .Clock (1'd0          ),
    .nReset(1'd0          )
);

assign mulb = {subdatab[7:3], ~UseMul | subdatab[2], subdatab[1:0]};

// Dummy signal used to allign multiplier output. Gets optimised away by synthesiser.
bit [1:0] tmp;

always_ff @ (posedge Clock, negedge nReset)
   if (~nReset)
	   ACC <= 8'd0;
	else if (WE)
        {ACC, tmp} <= #20 mula * mulb;

endmodule
