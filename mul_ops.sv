//------------------------------------------------------------------------------
// File       : mul_ops.sv
// Author     : Lewis Russell
// Description: Collection of small modules that implement simple functions
//              using multipliers.
//------------------------------------------------------------------------------
module mult #(parameter n = 8)(
    input  signed [n-1:0] A  ,
    input  signed [n-1:0] B  ,
    output signed [n-1:0] Out
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
lpm_mult_component.lpm_widtha = n,
lpm_mult_component.lpm_widthb = n,
lpm_mult_component.lpm_widthp = n;
`endif
endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Out = A + B
module muladd(
    input        [7:0] A  ,
    input        [7:0] B  ,
    input              EnA,
    input              EnB,
    output logic [7:0] Out
);

logic [7:0] tmp;

mult #(16) mul0(
    .A  ({        A,         B}),
    .B  ({7'd0, EnB, 7'd0, EnA}),
    .Out({      Out,       tmp})
);

endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//  A -|-------|            SC | SB | SA |  Out
//     |-------|             0    0    0 |   0
//  B -|--MUX--|-Out         0    0    1 |   A
//     |-------|             0    1    0 |   B
//  C -|-------|             0    1    1 |  A+B
//      |  |  |              1    0    0 |   C
//     SA SB SC              1    0    1 |  A+C
//                           1    1    0 |  B+C
//                           1    1    1 | A+B+C
module mul3mux(
    input        signed [7:0] A  ,
    input        signed [7:0] B  ,
    input        signed [7:0] C  ,
    input                     SA ,
    input                     SB ,
    input                     SC ,
    output logic signed [7:0] Out
);

logic [7:0] tmp0, tmp1, subout;

mult #(16) mult0(
    .A  ({       A,        B}),
    .B  ({7'd0, SB, 7'd0, SA}),
    .Out({  subout,     tmp0})
);

mult #(16) mult1(
    .A  ({  subout,         C}),
    .B  ({7'd0, SC, 7'd0, ~SC}),
    .Out({     Out,      tmp1})
);

endmodule
