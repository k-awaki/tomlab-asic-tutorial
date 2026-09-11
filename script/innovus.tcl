# innovus_config.tcl

set DESIGN   MLP
set FREQ_MHz 100
set design top${DESIGN}

set lef /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
set netlist genus/freq${FREQ_MHz}/outputs_power/${design}_m.v
set mmmc_view mmmc/enc_default_freq${FREQ_MHz}.view

set _OUTPUTS_PATH innovus/freq${FREQ_MHz}/outputs
set _REPORTS_PATH innovus/freq${FREQ_MHz}/reports

# 今まで、適当に値を与えていたが、今回はPnRも詰めていきたい
set core_util 0.60
set core_margin 20
set halo_size 10

# if {$FREQ_MHz == 100} {
#     set core_util 0.60
#     set core_margin 20
#     set halo_size 10
# } elseif {$FREQ_MHz == 200} {
#     set core_util 0.60
#     set core_margin 20
#     set halo_size 10
# } elseif {$FREQ_MHz == 400} {
#     set core_util 0.60
#     set core_margin 20
#     set halo_size 10
# }