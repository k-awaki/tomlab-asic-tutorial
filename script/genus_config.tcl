# genus_config.tcl

# Design Setting
set DESIGN      counter
set LIB         /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Front_End/Liberty/ECSM/NangateOpenCellLibrary_slow_ecsm.lib
set LEF         /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
set CAP         /opt/cadence/nangate45/captables/NCSU_FreePDK_45nm.capTbl
set SDC         ./sdc/clk.sdc

set MODEL_LIST {
    ./model/counter.v
}

set _OUTPUTS_PATH genus/outputs_power
set _REPORTS_PATH genus/reports_power
set _LOG_PATH     genus/logs_power


