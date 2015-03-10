//------------------------------------------------------------------------------
// File       : picoMips_tb.sv
// Author     : Lewis Russell
// Description: picMips testbench.
//------------------------------------------------------------------------------
module picomips_tb();

parameter   clk_p = 1000;
logic       Clock = 0   ;
logic [7:0] LED   = 0   ;
logic [9:0] SW    = 0   ;
logic [7:0] x           ;
logic [7:0] y           ;

always #(clk_p/2) Clock = ~Clock;

picomips picomips_inst0(.*);

task run_affine_trans(bit signed [7:0] x1, y1);
    bit signed [7:0] x2, x2_act;
    bit signed [7:0] y2, y2_act;

    x2 = 0.75*x1 +  0.5*y1 + 20;
    y2 = -0.5*x1 + 0.75*y1 - 20;

    #(20*clk_p) SW[7:0] = x1 ;
    #(20*clk_p) SW[ 8 ] = 1  ;
    #(20*clk_p) SW[ 8 ] = 0  ;
    #(20*clk_p) SW[7:0] = y1 ;
    #(20*clk_p) SW[ 8 ] = 1  ;
    #(20*clk_p) SW[ 8 ] = 0  ;
    #(40*clk_p) x2_act  = LED;
                SW[ 8 ] = 1  ;
    #(40*clk_p) y2_act  = LED;
                SW[ 8 ] = 0  ;

    assert(x2 inside {x2_act, x2_act + 1} || x2 == -128 && x2_act == 127)
    else $error("\n\tERROR: X2 is incorrect(%0d != %0d) (x1 = %d, y1 = %d).\n",
        x2, x2_act, x1, y1);
    assert(y2 inside {y2_act, y2_act + 1} || y2 == -128 && y2_act == 127)
    else $error("\n\tERROR: Y2 is incorrect(%0d != %0d) (x1 = %d, y1 = %d).\n",
        y2, y2_act, x1, y1);
endtask

initial begin
    #(2.2*clk_p) SW[9] = 1; // De-assert reset.
    repeat(1000) begin
        x = $urandom_range(255, 0);
        y = $urandom_range(255, 0);
        run_affine_trans(x, y);
    end
    $finish;
end

endmodule
