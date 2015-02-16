//------------------------------------------------------------------------------
// File       : picoMips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module picomips(
    input              Clock ,
    input        [9:0] SW    ,
    output logic [7:0] LED
);

parameter OP_ADD = 3'b000;
parameter OP_SUB = 3'b001;
parameter OP_MUL = 3'b010;
parameter OP_LI  = 3'b011;
parameter OP_HEN = 3'b100;
parameter OP_HEQ = 3'b101;
parameter OP_J   = 3'b110;

logic nReset;
assign nReset = SW[9];

//------------------------------------------------------------------------------
// Program Counter -------------------------------------------------------------
//------------------------------------------------------------------------------
logic [31:0] program_counter;
wire         pc_branch      ;
wire  [31:0] pc_branch_addr ;

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        program_counter <= 32'b0;
    else if (pc_branch)
        program_counter <= #20 pc_branch_addr;
    else
        program_counter <= #20 program_counter + 1;
//------------------------------------------------------------------------------
// Program Memory --------------------------------------------------------------
//------------------------------------------------------------------------------
logic [15:0] instruction;
logic [15:0] program_memory [0:7] = {
    16'h0000,
    16'h0000,
    16'h0000,
    16'h0000,
    16'h0000,
    16'h0000,
    16'h0000,
    16'h0000
};
assign instruction = program_memory[program_counter];
//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] registers[0:30];
logic [3:0] Rs             ;
logic [3:0] Rd             ;
logic [3:0] Rd_write_data  ;
logic       Rd_write       ;
logic [7:0] Rd_data        ;
logic [7:0] Rs_data        ;

assign Rd = instruction[ 6:3];
assign Rs = instruction[10:7];

assign Rs_data = (Rs == 4'b0) ? 8'b0 : registers[Rs];
assign Rd_data = (Rd == 4'b0) ? 8'b0 : registers[Rd];

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        for (int i = 0; i < 32; ++i)
            registers[0] <= #20 32'b0;
    else if (Rd_write)
        registers[Rd] = Rd_write_data;
//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [ 2:0] Func     ;
logic [16:0] A        ;
logic [16:0] B        ;
logic [32:0] Out      ;
logic [ 7:0] immediate;

assign immediate = instruction[14:7]                    ;
assign Func      = instruction[2:0]                     ;
assign A         = Rd_data                              ;
assign B         = (Func == OP_LI) ? immediate : Rs_data;

always_comb begin
    case (Func)
        OP_ADD : Out = A + B;
        OP_SUB : Out = A - B;
        OP_MUL : Out = A * B;
        default: Out = B    ;
    endcase
end

//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
