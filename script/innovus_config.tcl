# innovus_config.tcl

set DESIGN   counter
set FREQ_MHz 100
set design   ${DESIGN}

set lef /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
set netlist genus/outputs_power/${design}_m.v
set mmmc_view mmmc/enc_default.view

set _OUTPUTS_PATH innovus/outputs
set _REPORTS_PATH innovus/reports

set core_util 0.60
set core_margin 20
set halo_size 10
