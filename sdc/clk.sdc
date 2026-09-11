# 100MHz

set_units -time ns
create_clock -name clock -period 10.0000 -waveform {0 5.000} [get_ports clk]
