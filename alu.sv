//------------------------------------------------------------------------------
// File       : alu.sv
// Author     : Lewis Russell
// Description: Arithmetic logic unit for picoMips implementations.
//------------------------------------------------------------------------------
module alu(
    input               Clock  ,
    input  signed [7:0] Imm    ,
    input         [7:0] RegData,
    input         [7:0] SW     ,
    input         [2:0] Func   ,
    input               WE     ,
    input               SelSW  ,
    input               SelImm ,
    output logic signed [7:0] Out
);

wire signed [7:0] A;
assign A = (SelSW ) ? SW[7:0] :
           (SelImm) ? Imm     :
                      RegData ;

logic signed [7:0] acc;
assign Out = acc;

 // Dummy signal used to allign multiplier output. Gets optimised away by synthesiser.
logic signed [2:0] tmp;

always_ff @ (posedge Clock)
    if (WE)
        case (Func)
            OP_MULI        : {acc, tmp} <= #20 acc * Imm;
            OP_ADD, OP_ADDI:        acc <= #20 acc + A  ;
            OP_RTA, OP_LSW :        acc <= #20 A        ;
        endcase

endmodule

module alu2(
    input               Clock  ,
    input  signed [7:0] Imm    ,
    input         [7:0] RegData,
    input         [7:0] SW     ,
    input         [2:0] Func   ,
    input               WE     ,
    input               SelSW  ,
    input               SelImm ,
    output logic signed [7:0] Out
);


logic m1, m2, m3;
logic signed [7:0] mulb;
logic signed [7:0] mula;
logic signed [7:0] prod1;
logic signed [7:0] prod2;
logic signed [7:0] data;

assign data  = (SelSW) ? SW : (SelImm) ? Imm : RegData;
assign prod1 = (m1) ? Out : 8'd0;
assign prod2 = (m2) ? data : 8'd0;
assign mula  = prod1 + prod2;
assign mulb  = (m3) ? 8'd8 : Imm;

assign m1 = (Func == OP_MULI || Func == OP_ADD || Func == OP_ADDI);
assign m2 = !(Func == OP_MULI);
assign m3 = !(Func == OP_MULI);

 // Dummy signal used to allign multiplier output. Gets optimised away by synthesiser.
logic signed [2:0] tmp;

always_ff @ (posedge Clock)
    if (WE)
        {Out, tmp} <= #20 mula * mulb;

endmodule
