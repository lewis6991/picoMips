simvision {
    # Open new waveform window
    window new WaveWindow  -name  "Waves for picomips"
    window  geometry  "Waves for picomips"  1010x610+0+25
    waveform  using  "Waves for picomips"

    waveform add -signals picomips_tb.picomips_inst0.Clock
    waveform add -signals picomips_tb.picomips_inst0.nReset
    waveform add -signals picomips_tb.picomips_inst0.SW
    waveform add -signals picomips_tb.picomips_inst0.LED
    waveform add -signals picomips_tb.picomips_inst0.registers0.registers
    waveform add -signals picomips_tb.picomips_inst0.instruction
    waveform add -signals picomips_tb.picomips_inst0.acc
    waveform add -signals picomips_tb.picomips_inst0.data
    waveform add -signals picomips_tb.picomips_inst0.reg_addr
    waveform add -signals picomips_tb.picomips_inst0.reg_data
    waveform add -signals picomips_tb.picomips_inst0.reg_write
    waveform add -signals picomips_tb.picomips_inst0.reg_write_data
    waveform add -signals picomips_tb.picomips_inst0.immediate
    waveform add -signals picomips_tb.picomips_inst0.pc_hold
    waveform add -signals picomips_tb.picomips_inst0.program_counter
    waveform add -signals picomips_tb.picomips_inst0.sel_imm
    waveform add -signals picomips_tb.picomips_inst0.sel_sw
    waveform add -signals picomips_tb.picomips_inst0.sel_reg
    waveform add -signals picomips_tb.picomips_inst0.use_mul
    waveform add -signals picomips_tb.picomips_inst0.use_a
}
