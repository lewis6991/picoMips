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

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        ProgramCounter <= #20 0;
    else if (~PCHold)
        ProgramCounter <= #20 ProgramCounter + 7'd1;

endmodule
