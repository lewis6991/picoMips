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
`include "mul_ops.sv"
module picomips(
    input               Clock,
    input         [9:0] SW   ,
    output signed [7:0] LED
);

wire               nReset         ;
wire         [9:0] instruction    ;
wire  signed [7:0] acc            ;
wire         [6:0] program_counter;
wire               pc_hold        ;
wire               acc_we         ;
wire               reg_write      ;
wire  signed [7:0] immediate      ;
wire  signed [7:0] data           ;
wire               reg_addr       ;
wire  signed [7:0] reg_data       ;
wire               use_mul        ;
wire               use_a          ;
wire               sel_imm        ;
wire               sel_sw         ;
wire               sel_reg        ;

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
    .UseA       (use_a               ),
    .SelReg     (sel_reg             ),
    .Handshake  (SW[8]               )
);

registers registers0(
    .Clock    (Clock    ),
    .Addr     (reg_addr ),
    .Write    (reg_write),
    .WriteData(acc      ),
    .Data     (reg_data )
);

mul3mux mul3mux0(
    .A  (immediate),
    .B  (SW[7:0]  ),
    .C  (reg_data ),
    .SA (sel_imm  ),
    .SB (sel_sw   ),
    .SC (sel_reg  ),
    .Out(data     )
);

alu alu0(
    .Clock (Clock  ),
    .nReset(nReset ),
    .WE    (acc_we ),
    .ACC   (acc    ),
    .DataA (acc    ),
    .DataB (data   ),
    .UseMul(use_mul),
    .UseA  (use_a  )
);

endmodule
