//------------------------------------------------------------------------------
// File       : control.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module control(
    input        [11:0] Instruction,
    input        [ 1:0] Stage      ,
    input               Handshake  ,
    output logic [ 7:0] Immediate  ,
    output logic        PCHold     ,
    output logic        RegWrite   ,
    output logic        ACCWE      ,
    output logic        RegAddr    ,
    output logic        SelImm     ,
    output logic        SelSW      ,
    output logic        UseMul     ,
    output logic        UseACC     ,
    output logic        SelRegData
);

wire       hei_arg;
wire [7:0] func   ;

assign func       = Instruction[11:5];
assign hei_arg    = Instruction[0]   ;

assign Immediate  = {Instruction[4], Instruction[4], Instruction[4:0], 1'b0};
assign PCHold     = func[5] ? (Handshake == hei_arg) : 1'b0                 ;
assign ACCWE      = Stage[0] && Stage[1] && !(func[5] || func[4])           ;
assign RegAddr    = Instruction[0];
assign UseACC     = func[0];
assign SelSW      = func[1];
assign SelImm     = func[2];
assign UseMul     = func[3];
assign RegWrite   = func[4];
assign SelRegData = func[6];

endmodule
