//------------------------------------------------------------------------------
// File       : alu.sv
// Author     : Lewis Russell
// Description: Arithmetic logic unit for picoMips implementations.
//------------------------------------------------------------------------------

module mult(
    input  signed [7:0] A     ,
    input  signed [7:0] B     ,
    output signed [7:0] Out
);

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
endmodule

module alu(
    input                     Clock  ,
    input        signed [7:0] Imm    ,
    input               [7:0] RegData,
    input               [7:0] SW     ,
    input               [2:0] Func   ,
    input                     WE     ,
    input                     SelSW  ,
    input                     SelImm ,
    input                     UseMul ,
    input                     UseACC ,
    output logic signed [7:0] ACC
);

logic signed [7:0] mulb  ;
logic signed [7:0] mula  ;
logic signed [7:0] prod1 ;
logic signed [7:0] prod2 ;
logic signed [7:0] data  ;
logic signed [7:0] subimm;

assign data = (SelSW ) ? SW      :
              (SelImm) ? Imm     :
                         RegData ;

assign mula  = prod1 + prod2;

//assign prod1 = (UseACC) ? ACC : 8'd0;
mult mult0(.A({7'b0,  UseACC}), .B(ACC ), .Out(prod1));

//assign prod2 = (UseMul) ? 8'd0 : data;
mult mult1(.A({7'b0, ~UseMul}), .B(data), .Out(prod2));

//assign mulb  = (UseMul) ? Imm : 8'd8;
mult mult2(.A({7'b0, ~UseMul}), .B(Imm ), .Out(subimm));
assign mulb = {subimm[7:4], UseMul | subimm[3], subimm[2:0]};

// Dummy signal used to allign multiplier output. Gets optimised away by synthesiser.
logic signed [2:0] tmp;

always_ff @ (posedge Clock)
    if (WE)
        {ACC, tmp} <= #20 mula * mulb;

endmodule
