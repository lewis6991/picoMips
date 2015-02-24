//------------------------------------------------------------------------------
// File       : mul_ops.sv
// Author     : Lewis Russell
// Description: Collection of small modules that implement simple functions
//              using multipliers.
//------------------------------------------------------------------------------
module mult(
    input  signed [7:0] A  ,
    input  signed [7:0] B  ,
    output signed [7:0] Out
);

`ifdef SIM
    assign Out = (A == 0 || B == 0) ? 0 : A * B;
`else
lpm_mult lpm_mult_component (
    .clken  (1'b0),
    .clock  (1'b0),
    .dataa  (A   ),
    .datab  (B   ),
    .result (Out ),
    .aclr   (1'b0),
    .sum    (1'b0)
);
defparam
lpm_mult_component.lpm_hint = "INPUT_B_IS_CONSTANT=NO,DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_AREA=1",
lpm_mult_component.lpm_pipeline = 0,
lpm_mult_component.lpm_representation = "SIGNED",
lpm_mult_component.lpm_type = "LPM_MULT",
lpm_mult_component.lpm_widtha = 8,
lpm_mult_component.lpm_widthb = 8,
lpm_mult_component.lpm_widthp = 8;
`endif
endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// In -|---|
//     |MUX|-Out
//  0 -|---|
//       |
//      En
module mul0mux(
    input  signed [7:0] In ,
    input               En ,
    output signed [7:0] Out
);

mult mult0(
    .A  (In        ),
    .B  ({7'd0, En}),
    .Out(Out       )
);

endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// In -|---|
//     |MUX|-Out
//  1 -|---|
//       |
//      En
module mul1mux(
    input  signed [7:0] In ,
    input               En ,
    output signed [7:0] Out
);

logic [7:0] subOut;

mult mult0(
    .A  (In        ),
    .B  ({7'd0, En}),
    .Out(subOut    )
);

assign Out = {subOut[7:1], ~En | subOut[0]};

endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//  A -|---|
//     |MUX|-Out
//  B -|---|
//       |
//      Sel
module mulmux(
    input        signed [7:0] A  ,
    input        signed [7:0] B  ,
    input        signed       Sel,
    output logic signed [7:0] Out
);

logic [7:0] suba, subb;

mul1mux mul1mux0 (.In(A), .En(Sel ), .Out(suba));
mul1mux mul1mux1 (.In(B), .En(~Sel), .Out(subb));
assign Out = suba * subb;

endmodule
//------------------------------------------------------------------------------