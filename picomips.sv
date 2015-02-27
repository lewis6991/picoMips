//------------------------------------------------------------------------------
// File       : picomips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
`include "program_counter.sv"
`include "program_memory.sv"
`include "control.sv"
`include "registers.sv"
`include "alu.sv"
module picomips(
    input               Clock,
    input         [9:0] SW   ,
    output signed [7:0] LED
);

wire                nReset         ;
wire         [11:0] instruction    ;
wire  signed [ 7:0] acc            ;
wire         [ 6:0] program_counter;
wire                pc_hold        ;
wire                acc_we         ;
wire                reg_write      ;
wire  signed [ 7:0] immediate      ;
wire                reg_addr       ;
wire  signed [ 7:0] reg_data       ;
wire                use_mul        ;
wire                use_acc        ;
wire                sel_imm        ;
wire                sel_sw         ;
wire                sel_reg_data   ;

assign nReset = SW[9];
assign LED    = acc  ;

program_counter program_counter0(
    .Clock         (Clock          ),
    .nReset        (nReset         ),
    .PCHold        (pc_hold        ),
    .ProgramCounter(program_counter)
);

program_memory program_memory0(
    .Clock      (Clock               ),
    .Addr       (program_counter[6:2]),
    .Instruction(instruction         )
);

control control0(
    .Instruction(instruction         ),
    .Stage      (program_counter[1:0]),
    .Immediate  (immediate           ),
    .PCHold     (pc_hold             ),
    .RegWrite   (reg_write           ),
    .ACCWE      (acc_we              ),
    .RegAddr    (reg_addr            ),
    .SelImm     (sel_imm             ),
    .SelSW      (sel_sw              ),
    .UseMul     (use_mul             ),
    .UseACC     (use_acc             ),
    .SelRegData (sel_reg_data        ),
    .Handshake  (SW[8]               )
);

registers registers0(
    .Clock    (Clock    ),
    .Addr     (reg_addr ),
    .Write    (reg_write),
    .WriteData(acc      ),
    .Data     (reg_data )
);

alu alu0(
    .Clock     (Clock       ),
    .nReset    (nReset      ),
    .Imm       (immediate   ),
    .WE        (acc_we      ),
    .ACC       (acc         ),
    .UseMul    (use_mul     ),
    .SelImm    (sel_imm     ),
    .SelSW     (sel_sw      ),
    .SelRegData(sel_reg_data),
    .UseACC    (use_acc     ),
    .SW        (SW[7:0]     ),
    .RegData   (reg_data    )
);

endmodule
