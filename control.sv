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
    output logic        UseA       ,
    output logic        SelReg
);

wire       hei_arg;
wire [5:0] func   ;

assign func       = Instruction[11:6];
assign hei_arg    = Instruction[0]   ;

assign Immediate = {Instruction[5], Instruction[5], Instruction[5:0]};
assign PCHold    = SelReg && SelImm ? (Handshake == hei_arg) : 1'b0  ;
assign ACCWE     = ~Stage[0] && Stage[1] && !(SelReg && SelImm)      ;
assign RegAddr   = Instruction[0];
assign UseA      = func[0];
assign SelSW     = func[1];
assign SelImm    = func[2];
assign UseMul    = func[3];
assign RegWrite  = func[4];
assign SelReg    = func[5];

endmodule
