//------------------------------------------------------------------------------
// File       : picoMips.sv
// Author     : Lewis Russell
// Description: Implementation of a picoMips for ELEC6233 Assignment.
//------------------------------------------------------------------------------
module picomips(
    input        Clock,
    input  [9:0] SW   ,
    output [7:0] LED
);

parameter OP_ADD  = 3'b000;
parameter OP_MOV  = 3'b010;
parameter OP_MULI = 3'b100;
parameter OP_ADDI = 3'b101;
parameter OP_HEI  = 3'b110;

wire         [14:0] instruction;
wire         [ 2:0] Func       ;
logic signed [ 7:0] Out        ;
logic               Rd_write   ;
logic               pc_hold    ;

wire nReset;
assign nReset = SW[9];

//------------------------------------------------------------------------------
// Program Counter -------------------------------------------------------------
//------------------------------------------------------------------------------
logic [4:0] program_counter;

always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        program_counter <= 0;
    else if (~pc_hold)
        program_counter <= #20 program_counter + 1;
//------------------------------------------------------------------------------
// Program Memory --------------------------------------------------------------
//------------------------------------------------------------------------------
const logic [14:0] [0:21] program_memory = {
    {OP_HEI , 4'd0,  8'd0       }, // Wait for SW8 to become 1
    {OP_MOV , 4'd3,  4'd0 , 4'd0}, // Load SW[7:0] into $x1/$4
    {OP_HEI , 4'd0, -8'd      1 }, // Wait for SW8 to become 0
    {OP_HEI , 4'd0,  8'd0       }, // Wait for SW8 to become 1
    {OP_MOV , 4'd4,  4'd0 , 4'd0}, // Load SW[7:0] into $y1/$5
    {OP_HEI , 4'd0, -8'd1       }, // Wait for SW8 to become 0
    // Calc x2
    {OP_MOV , 4'd5,  4'd3 , 4'd0}, // Load $x1/$4 into $x2/$6
    {OP_MULI, 4'd5,  8'd96      }, // Multiply x1 by 0.75
    {OP_MOV , 4'd7,  4'd4 , 4'd0}, // Load y1 into $t5/$12
    {OP_MULI, 4'd7,  8'd64      }, // Multiply y1 by 0.5
    {OP_ADD , 4'd5,  4'd7 , 4'd0}, // Add (0.5*y1) to (0.75*x1)
    {OP_ADDI, 4'd5,  8'd20      }, // Add (20) to (0.5*y1 + 0.75*x1)
    // Calc y2
    {OP_MOV , 4'd6,  4'd4 , 4'd0}, // Load $y1/$5 into $y2/$7
    {OP_MULI, 4'd6,  8'd96      }, // Multiply y1 by 0.75
    {OP_MOV , 4'd8,  4'd3 , 4'd0}, // Load x1 into $t5/$13
    {OP_MULI, 4'd8, -8'd64      }, // Multiply x1 by -0.5
    {OP_ADD , 4'd6,  4'd8 , 4'd0}, // Add (-0.5*x1) from (0.75*y1)
    {OP_ADDI, 4'd6, -8'd20      }, // Add (-20) to (-0.5*x1 + 0.75*y1)
    // Output x2
    {OP_MOV , 4'd2,  4'd5 , 4'd0}, // Output x2 to LED's
    {OP_HEI , 4'd0,  8'd0       }, // Wait for SW8 to become 1
    // Output y2
    {OP_MOV , 4'd2,  4'd6 , 4'd0}, // Output y2 to LED's
    {OP_HEI , 4'd0, -8'd1       }  // Wait for SW8 to become 0
};
assign instruction = program_memory[program_counter];
//------------------------------------------------------------------------------
// Decoder ---------------------------------------------------------------------
//------------------------------------------------------------------------------
always_comb begin
    pc_hold  = 0;
    Rd_write = 0;
    if (Func == OP_HEI)
        pc_hold = (Out == 0); // Hold if output is zero.
    else
        Rd_write = 1;
end
//------------------------------------------------------------------------------
// Registers -------------------------------------------------------------------
//------------------------------------------------------------------------------
logic [7:0] registers[2:15];
wire  [3:0] Rs             ;
wire  [3:0] Rd             ;
wire  [7:0] Rd_write_data  ;
logic [7:0] Rd_data        ;
logic [7:0] Rs_data        ;

assign Rd            = instruction[11:8];
assign Rs            = instruction[ 7:4];
assign Rd_write_data = Out              ;
assign LED           = registers[2]     ;

// Asynchronous Read
always_comb begin
    case (Rd)
        0      : Rd_data = {7'b0, SW[8]};
        default: Rd_data = registers[Rd];
    endcase
    case (Rs)
        0      : Rs_data = SW[7:0]      ;
        default: Rs_data = registers[Rs];
    endcase
end

// Synchronous Write
always_ff @ (posedge Clock, negedge nReset)
    if (~nReset)
        for (int i = 2; i < 16; ++i)
            registers[i] <= #20 0;
    else if (Rd > 1 && Rd_write)
        registers[Rd] = Rd_write_data;
//------------------------------------------------------------------------------
// ALU -------------------------------------------------------------------------
//------------------------------------------------------------------------------
wire signed [7:0] A, B     ;
wire        [7:0] immediate;

assign immediate = instruction[7:0]  ;
assign Func      = instruction[14:12];
assign A         = Rd_data           ;
assign B         = (Func[2]) ? immediate : Rs_data;
assign Z_flag    = (Out == 16'b0)    ;

logic signed [6:0] tmp;

always_comb
    case (Func)
        OP_MULI : {Out, tmp} = A * B;
        OP_MOV  : Out = B    ;
        default : Out = A + B;
    endcase
//------------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
