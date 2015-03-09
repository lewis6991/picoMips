//------------------------------------------------------------------------------
// File       : mul_ops.sv
// Author     : Lewis Russell
// Description: Collection of small modules that implement simple functions
//              using multipliers.
//------------------------------------------------------------------------------
`ifndef MUL_OPS
`define MUL_OPS
module mult #(
    parameter n = 8, // Input width
    parameter p = 0  // Pipelined
)(
    input  signed [n-1:0] A     ,
    input  signed [n-1:0] B     ,
    input                 Clock ,
    input                 nReset,
    output signed [n-1:0] Out
);
    logic [n-1:0] pOut, mOut;

    assign mOut = A * B;

    always_ff @ (posedge Clock, negedge nReset)
        if (~nReset)
            pOut <= 0;
        else
            pOut <= #20 mOut;

    assign Out = p ? pOut : mOut;

endmodule
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Out = A + B
module muladd #(parameter p = 0)(
    input        [7:0] A     ,
    input        [7:0] B     ,
    input              EnA   ,
    input              EnB   ,
    input              Clock ,
    input              nReset,
    output logic [7:0] Out
);

logic [7:0] tmp;

mult #(16, p) mul0(
    .A     ({        A,         B}),
    .B     ({7'd0, EnB, 7'd0, EnA}),
    .Clock (Clock                 ),
    .nReset(nReset                ),
    .Out   ({      Out,       tmp})
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
    .A     ({       A,        B}),
    .B     ({7'd0, SB, 7'd0, SA}),
    .Out   ({  subout,     tmp0}),
    .Clock (1'd0                ),
    .nReset(1'd0                )
);

mult #(16) mult1(
    .A     ({  subout,         C}),
    .B     ({7'd0, SC, 7'd0, ~SC}),
    .Out   ({     Out,      tmp1}),
    .Clock (1'd0                 ),
    .nReset(1'd0                 )
);

endmodule

`endif
