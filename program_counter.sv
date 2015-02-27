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

`ifdef SIM
always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        ProgramCounter <= #20 0;
    else if (~PCHold)
        ProgramCounter <= #20 ProgramCounter + 7'd1;
`else
lpm_mult lpm_mult_component (
    .clken (1'b0                                 ),
    .clock (Clock                                ),
    .dataa ({1'd0, ProgramCounter, 7'd0, ~PCHold}),
    .datab ({8'd1, 8'd1}                         ),
    .result({1'd0, ProgramCounter, tmp}          ),
    .aclr  (~nReset                              ),
    .sum   (1'b0                                 )
);
defparam
lpm_mult_component.lpm_hint = "INPUT_B_IS_CONSTANT=NO,DEDICATED_MULTIPLIER_CIRCUITRY=YES,MAXIMIZE_AREA=1",
lpm_mult_component.lpm_pipeline = 1,
lpm_mult_component.lpm_representation = "SIGNED",
lpm_mult_component.lpm_type = "LPM_MULT",
lpm_mult_component.lpm_widtha = 16,
lpm_mult_component.lpm_widthb = 16,
lpm_mult_component.lpm_widthp = 16;
`endif

endmodule
