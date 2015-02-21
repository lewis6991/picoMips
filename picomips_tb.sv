//------------------------------------------------------------------------------
// File       : picoMips_tb.sv
// Author     : Lewis Russell
// Description: picMips testbench.
//------------------------------------------------------------------------------
module picomips_tb();

parameter   clk_p = 10000;
logic       Clock = 0    ;
logic [7:0] LED   = 0    ;
logic [9:0] SW    = 0    ;

always #(clk_p/2) Clock <= ~Clock;

picomips picomips_inst0(.*);

task run_affine_trans(bit signed [7:0] x1, y1);
    bit signed [7:0] x2, x2_act;
    bit signed [7:0] y2, y2_act;

    $display("\tINFO: Running with x1 = %2d and y1 = %2d.", x1, y1);

    x2 = 0.75*x1 +  0.5*y1 + 20;
    y2 = -0.5*x1 + 0.75*y1 - 20;

    #(100.5*clk_p) SW[ 9 ] = 1  ;
                 SW[7:0] = x1 ;// Set x1
    #(  100*clk_p) SW[ 8 ] = 1  ;
    #(  100*clk_p) SW[ 8 ] = 0  ;
    #(  100*clk_p) SW[7:0] = y1 ;// Set y1
    #(  100*clk_p) SW[ 8 ] = 1  ;
    #(  100*clk_p) SW[ 8 ] = 0  ;// 4.
    #( 400*clk_p) x2_act  = LED;
                 SW[ 8 ] = 1  ;
    #(  100*clk_p) y2_act  = LED;
                 SW[ 8 ] = 0  ;

    #20
    assert(x2 inside {x2_act, x2_act + 1})
    else $error("\n\tERROR: X2 is incorrect(%0d != %0d).\n", x2, x2_act);
    assert(y2 inside {y2_act, y2_act + 1})
    else $error("\n\tERROR: Y2 is incorrect(%0d != %0d).\n", y2, y2_act);
    #( 800*clk_p);
endtask

initial begin
    run_affine_trans( 4,  6);
    run_affine_trans(40, 21);
    run_affine_trans(20, 55);
    run_affine_trans( 4,  6);
    run_affine_trans(11,  2);
    run_affine_trans( 4,  6);
    $finish;
end

endmodule
