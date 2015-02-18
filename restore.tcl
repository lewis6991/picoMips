#
# ncverilog -sv +ncaccess+r +gui picoMips_tb.sv picoMips.sv +tcl+restore.tcl
#

simvision {
    # Open new waveform window
    window new WaveWindow  -name  "Waves for picoMips"
    window  geometry  "Waves for picoMips"  1010x410+0+25
    waveform  using  "Waves for picoMips"

    waveform add -signals picomips_tb.picomips_inst0.Clock
    waveform add -signals picomips_tb.picomips_inst0.nReset
    waveform add -signals picomips_tb.picomips_inst0.SW
    waveform add -signals picomips_tb.picomips_inst0.LED
    waveform add -signals picomips_tb.picomips_inst0.registers
    waveform add -signals picomips_tb.picomips_inst0.instruction
    waveform add -signals picomips_tb.picomips_inst0.A
    waveform add -signals picomips_tb.picomips_inst0.B
    waveform add -signals picomips_tb.picomips_inst0.Func
    waveform add -signals picomips_tb.picomips_inst0.Out
    waveform add -signals picomips_tb.picomips_inst0.Rd
    waveform add -signals picomips_tb.picomips_inst0.Rd_data
    waveform add -signals picomips_tb.picomips_inst0.Rd_write
    waveform add -signals picomips_tb.picomips_inst0.Rd_write_data
    waveform add -signals picomips_tb.picomips_inst0.Rs
    waveform add -signals picomips_tb.picomips_inst0.Rs_data
    waveform add -signals picomips_tb.picomips_inst0.immediate
    waveform add -signals picomips_tb.picomips_inst0.N_flag
    waveform add -signals picomips_tb.picomips_inst0.Z_flag
    waveform add -signals picomips_tb.picomips_inst0.pc_hold
    waveform add -signals picomips_tb.picomips_inst0.pc_jump
    waveform add -signals picomips_tb.picomips_inst0.pc_jump_addr
    waveform add -signals picomips_tb.picomips_inst0.program_counter
}
