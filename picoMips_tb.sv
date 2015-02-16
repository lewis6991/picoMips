//------------------------------------------------------------------------------
// File       : picoMips_tb.sv
// Author     : Lewis Russell
// Description: picMips testbench.
//------------------------------------------------------------------------------
module picomips_tb();

parameter clk_p = 10000;

logic       Clock = 0;

logic [7:0] LED   = 0;

logic [9:0] SW    = 0;

always #(clk_p/2) Clock <= ~Clock;

picomips picomips_inst0(.*);

initial begin
    #(5.5*clk_p) SW[9]   = 1;
                 SW[7:0] = 4; // Set x1
    #(  2*clk_p) SW[8]   = 1;
    #(  2*clk_p) SW[8]   = 0;
    #(  2*clk_p) SW[7:0] = 6; // Set y1
    #(  2*clk_p) SW[8]   = 1;
    #(  2*clk_p) SW[8]   = 0;
    #( 15*clk_p) SW[8]   = 1;
    #(  5*clk_p) SW[8]   = 0;
    #(  5*clk_p) $finish;
end

endmodule
