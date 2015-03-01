//------------------------------------------------------------------------------
// File       : program_counter.sv
// Author     : Lewis Russell
// Description: Program counter for picoMips.
//------------------------------------------------------------------------------
module program_counter(
    input              Clock         ,
    input              nReset        ,
    input              PCHold        ,
    output logic [6:0] ProgramCounter
);

logic tmp;

muladd #(1) muladd0(
    .Clock (Clock                 ),
    .A     ({1'd0, ProgramCounter}),
    .B     (8'd1                  ),
    .EnA   (1'b1                  ),
    .EnB   (~PCHold               ),
    .Out   ({ tmp, ProgramCounter}),
    .nReset(nReset                )
);

endmodule
