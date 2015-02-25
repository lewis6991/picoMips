//------------------------------------------------------------------------------
// File       : alu.sv
// Author     : Lewis Russell
// Description: Arithmetic logic unit for picoMips implementations.
//------------------------------------------------------------------------------
module alu(
    input                     Clock  ,
    input                     nReset ,
    input        signed [7:0] Imm    ,
    input               [7:0] RegData,
    input               [7:0] SW     ,
    input               [2:0] Func   ,
    input                     WE     ,
    input                     SelSW  ,
    input                     SelImm ,
    input                     UseMul ,
    input                     UseACC ,
    output logic signed [7:0] ACC
);

wire signed [7:0] mulb   ;
wire signed [7:0] mula   ;
wire signed [7:0] prod1  ;
wire signed [7:0] prod2  ;
wire signed [7:0] subdata;
wire signed [7:0] data   ;
wire signed [7:0] subimm ;

mulmux mulmux0(
    .A  (SW     ),
    .B  (subdata),
    .Sel(SelSW  ),
    .Out(data   )
);

mulmux mulmux1(
    .A  (Imm    ),
    .B  (RegData),
    .Sel(SelImm ),
    .Out(subdata)
);

assign mula  = prod1 + prod2;

mul0mux mul0mux0(
    .In (ACC   ),
    .En (UseACC),
    .Out(prod1 )
);

mul0mux mul0mux1(
    .In (data   ),
    .En (~UseMul),
    .Out(prod2  )
);

mult mult0(
    .A  ({7'b0, UseMul}),
    .B  (Imm           ),
    .Out(subimm        )
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
