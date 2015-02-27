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
//  A -|-------|            SC | SB | SA |  Out
//     |-------|             0    0    0 |   0
//  B -|--MUX--|-Out         0    0    1 |   A
//     |-------|             0    1    0 |   B
//  C -|-------|             0    1    1 |  A*B
//      |  |  |              1    0    0 |   C
//     SA SB SC              1    0    1 |  A*C
//                           1    1    0 |  B*C
//                           1    1    1 | A*B*C
module mul3mux(
    input        signed [7:0] A  ,
    input        signed [7:0] B  ,
    input        signed [7:0] C  ,
    input                     SA ,
    input                     SB ,
    input                     SC ,
    output logic signed [7:0] Out
);

logic [7:0] suba, subb, subc, subab, suba2;

mult mult0(
    .A  (A         ),
    .B  ({7'd0, SA}),
    .Out(suba2     )
);

assign suba = {suba2[7:1], (~SA | suba2[0]) & (SA | SB | SC)};

mul1mux mul1mux1 (.In(B   ), .En(SB   ), .Out(subb ));
mul1mux mul1mux2 (.In(C   ), .En(SC   ), .Out(subc ));
mult    mul0     (.A (suba), .B (subb ), .Out(subab));
mult    mul1     (.A (subc), .B (subab), .Out(Out  ));

endmodule
//------------------------------------------------------------------------------
