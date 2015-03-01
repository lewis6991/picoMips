//------------------------------------------------------------------------------
// File       : registers.sv
// Author     : Lewis Russell
// Description: Register implementation for picoMips.
//------------------------------------------------------------------------------
module registers(
    input              Clock    ,
    input              Addr     ,
    input              Write    ,
    input        [7:0] WriteData,
    output logic [7:0] Data
);

logic signed [7:0] registers[0:1];

initial
    for (int i = 0; i < 2; ++i)
        registers[i] = 0;

// Synchronous Read/Write
always_ff @ (posedge Clock) begin
    if (Write)
        registers[Addr] <= #20 WriteData;
    Data <= #20 registers[Addr];
end

endmodule
