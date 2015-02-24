//------------------------------------------------------------------------------
// File       : alu.sv
// Author     : Lewis Russell
// Description: Arithmetic logic unit for picoMips implementations.
//------------------------------------------------------------------------------
module alu(
    input                     Clock  ,
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

logic signed [7:0] mulb   ;
logic signed [7:0] mula   ;
logic signed [7:0] prod1  ;
logic signed [7:0] prod2  ;
logic signed [7:0] subdata;
logic signed [7:0] data   ;
logic signed [7:0] subimm ;

//assign data = (SelSW ) ? SW      :
//              (SelImm) ? Imm     :
//                         RegData ;

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

always_ff @ (posedge Clock)
    if (WE)
        {ACC, tmp} <= #20 mula * mulb;

endmodule
