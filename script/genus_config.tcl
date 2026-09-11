# genus_config.tcl

set FREQ_MHz 100

# Design Setting
set DESIGN      MLP_core
set LIB         /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Front_End/Liberty/ECSM/NangateOpenCellLibrary_slow_ecsm.lib
set LEF         /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
set CAP         /opt/cadence/nangate45/captables/NCSU_FreePDK_45nm.capTbl
set SDC         ./sdc/${DESIGN}_freq${FREQ_MHz}.sdc

set MODEL_LIST {
    ./model/Counter.v
    ./model/counter_reg_ce.v
    ./model/Deserializer.v
    ./model/fifo_ringbuf.v
    ./model/FixedMulShiftRound.v
    ./model/LayerController.v
    ./model/leaky_relu.v
    ./model/LoopChecker.v
    ./model/loop_reg_ce.v
    ./model/MLP_core.v
    ./model/MUX.v
    ./model/NonZeroChecker.v
    ./model/OPU.v
    ./model/ReadAddressGenerationUnit.v
    ./model/ReadAddressGenerationUnitController.v
    ./model/ReadAddressGenerationUnitCounter.v
    ./model/ReadAddressGenerators.v
    ./model/reg_ce.v
    ./model/SA2RQ.v
    ./model/SA2RQAccumulator.v
    ./model/SA2RQController.v
    ./model/saturate.v
    ./model/Sequencer.v
    ./model/Serializer.v
    ./model/sync_reset_mux.v
    ./model/vec_reg_ce.v
    ./model/waddress_generator.v
    ./model/wmem_addr_reg_ce.v
    ./model/WriteAddressGenerationUnit.v
    ./model/WriteAddressGenerationUnitController.v
    ./model/WriteAddressGenerator.v
    ./model/xaddress_generator.v
    ./model/xmem_addr_reg_ce.v
    ./model/ZeroSkipDNNComputer.v
    ./model/ZeroSkipDNNController.v
    ./model/ZeroSkipOPU.v
}

# set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power
# set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power
# set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power

# set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power_no_cg
# set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power_no_cg
# set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power_no_cg

# set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power_no_cg_asym
# set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power_no_cg_asym
# set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power_no_cg_asym

# set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power_resetmux
# set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power_resetmux
# set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power_resetmux

# set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power_no_icg_resetmux
# set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power_no_icg_resetmux
# set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power_no_icg_resetmux

set _OUTPUTS_PATH genus/freq${FREQ_MHz}/outputs_power_no_icg_resetmux_exp
set _REPORTS_PATH genus/freq${FREQ_MHz}/reports_power_no_icg_resetmux_exp
set _LOG_PATH     genus/freq${FREQ_MHz}/logs_power_no_icg_resetmux_exp

# option
set IS_ICG false; # default: true