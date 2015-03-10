//------------------------------------------------------------------------------
// File       : control.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module control(
    input        [9:0] Instruction,
    input        [1:0] Stage      ,
    input              Handshake  ,
    output logic [7:0] Immediate  ,
    output logic       PCHold     ,
    output logic       RegWrite   ,
    output logic       ACCWE      ,
    output logic       RegAddr    ,
    output logic       SelImm     ,
    output logic       SelSW      ,
    output logic       UseMul     ,
    output logic       UseA       ,
    output logic       SelReg
);

logic       hei    ;
wire        hei_arg;
wire  [5:0] func   ;

assign func      = Instruction[9:4];
assign hei       = SelReg && SelImm ;
assign hei_arg   = Instruction[0]   ;

assign Immediate = {Instruction[3], Instruction[3], Instruction[3], Instruction[3], Instruction[3:0]};
assign PCHold    = hei && (Handshake == hei_arg);
assign ACCWE     = (Stage == 2'b10) && !hei     ;
assign RegAddr   = Instruction[0];
assign UseA      = func[0];
assign SelSW     = func[1];
assign SelImm    = func[2];
assign UseMul    = func[3];
assign RegWrite  = func[4];
assign SelReg    = func[5];

endmodule
