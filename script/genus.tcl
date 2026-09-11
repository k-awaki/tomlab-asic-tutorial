#### Template Script for RTL->Gate-Level Flow (generated from GENUS 21.12-s068_1) 

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

##############################################################################
## Preset global variables and attributes
##############################################################################
source script/genus_config.tcl

# set DESIGN diffeq
set GEN_EFF high
set MAP_OPT_EFF high
#set DATE [clock format [clock seconds] -format "%b%d-%T"] 
# set _OUTPUTS_PATH genus/outputs_power
# set _REPORTS_PATH genus/reports_power
# set _LOG_PATH     genus/logs_power
##set ET_WORKDIR <ET work directory>
#set_attribute init_lib_search_path {. ./lib} / 
#set_attribute script_search_path {. <path>} /
#set_attribute init_hdl_search_path {. ./rtl} /
##Uncomment and specify machine names to enable super-threading.
##set_attribute super_thread_servers {<machine names>} /
##For design size of 1.5M - 5M gates, use 8 to 16 CPUs. For designs > 5M gates, use 16 to 32 CPUs
set_attribute max_cpus_per_server 8 /

##Default undriven/unconnected setting is 'none'.  
##set_attribute hdl_unconnected_input_port_value 0 | 1 | x | none /
##set_attribute hdl_undriven_output_port_value   0 | 1 | x | none /
##set_attribute hdl_undriven_signal_value        0 | 1 | x | none /


##set_attribute wireload_mode <value> /
set_attribute information_level 9 /

###############################################################
## Library setup
###############################################################


set_attribute library $LIB
#set_attribute library lib/slow.lib
#set_attribute avoid true [find / -libcell CLK*]

## PLE
set_attribute lef_library $LEF
#set_attribute lef_library lef/all.lef
## Provide either cap_table_file or the qrc_tech_file
set_attribute cap_table_file $CAP /
#set_attribute qrc_tech_file <file> /
##generates <signal>_reg[<bit_width>] format
#set_attribute hdl_array_naming_style %s\[%d\] /  
##

# set_attribute lp_insert_clock_gating true /
# set_attribute lp_insert_discrete_clock_gating_logic true /
set_attribute lp_insert_clock_gating $IS_ICG
set_attribute lp_insert_discrete_clock_gating_logic $IS_ICG

## Power root attributes
#set_attribute lp_clock_gating_prefix <string> /
#set_attribute lp_power_unit mW /
#set_attribute lp_toggle_rate_unit /ns /

####################################################################
## Load Design
####################################################################
set_attribute hdl_max_memory_address_range 131072 /

foreach file $MODEL_LIST {
    read_hdl -v2001 $file
}

elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"
time_info Elaboration

# First verify that all RTL modules were resolved.
check_design -unresolved

# ============================================================
# PHASE 1: Protect sync_reset_mux hierarchy BEFORE synthesis
# (Run immediately after elaborate)
# ============================================================
# set rst_mux_inst [find / -instance *u_current_layer_reset_mux*]
set rst_mux_inst [find / -instance *reset_mux*]
set rst_mux_subd [find / -subdesign *sync_reset_mux*]

if {[llength $rst_mux_inst] == 0} {
    puts "ERROR: reset_mux was not found after elaborate"
    exit 1
}

if {[llength $rst_mux_subd] == 0} {
    puts "ERROR: sync_reset_mux subdesign was not found after elaborate"
    exit 1
}

puts "INFO: reset mux instance  = $rst_mux_inst"
puts "INFO: reset mux subdesign = $rst_mux_subd"

set_attribute ungroup_ok false $rst_mux_inst
set_attribute ungroup_ok false $rst_mux_subd
set_attribute boundary_opto false $rst_mux_subd
set_attribute merge_combinational_hier_instance false $rst_mux_inst

puts "INFO: Pre-synthesis hierarchy protection applied."
puts "INFO: ungroup_ok(inst) = [get_attribute ungroup_ok [lindex $rst_mux_inst 0]]"
puts "INFO: boundary_opto    = [get_attribute boundary_opto [lindex $rst_mux_subd 0]]"
puts "INFO: merge_comb       = [get_attribute merge_combinational_hier_instance [lindex $rst_mux_inst 0]]"
# ============================================================


####################################################################
## Constraints Setup
####################################################################

read_sdc $SDC
puts "The number of exceptions is [llength [find /designs/$DESIGN -exception *]]"


#set_attribute force_wireload <wireload name> "/designs/$DESIGN"

if {![file exists ${_LOG_PATH}]} {
  file mkdir ${_LOG_PATH}
  puts "Creating directory ${_LOG_PATH}"
}

if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}
report timing -lint


###################################################################################
## Define cost groups (clock-clock, clock-output, input-clock, input-output)
###################################################################################

## Uncomment to remove already existing costgroups before creating new ones.
## rm [find /designs/* -cost_group *]

if {[llength [all::all_seqs]] > 0} { 
  define_cost_group -name I2C -design $DESIGN
  define_cost_group -name C2O -design $DESIGN
  define_cost_group -name C2C -design $DESIGN
  path_group -from [all::all_seqs] -to [all::all_seqs] -group C2C -name C2C
  path_group -from [all::all_seqs] -to [all::all_outs] -group C2O -name C2O
  path_group -from [all::all_inps]  -to [all::all_seqs] -group I2C -name I2C
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all::all_inps]  -to [all::all_outs] -group I2O -name I2O
foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] >> $_REPORTS_PATH/${DESIGN}_pretim.rpt
}
#######################################################################################
## Leakage/Dynamic power/Clock Gating setup.
#######################################################################################

#set_attribute lp_clock_gating_cell [find /lib* -libcell <cg_libcell_name>] "/designs/$DESIGN"
#set_attribute design_power_effort <high or low> /
set_attribute design_power_effort high /
#set_attribute opt_leakage_to_dynamic_ratio <value from 0 to 1> /
set_attribute opt_leakage_to_dynamic_ratio 1 /
## read_tcf <TCF file name>
## read_saif <SAIF file name>
## read_vcd <VCD file name>



#### To turn off sequential merging on the design 
#### uncomment & use the following attributes.
##set_attribute optimize_merge_flops false /
##set_attribute optimize_merge_latches false /
#### For a particular instance use attribute 'optimize_merge_seqs' to turn off sequential merging. 



####################################################################################################
## Synthesizing to generic 
####################################################################################################

set_attribute syn_generic_effort $GEN_EFF /
syn_generic
puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC

# ============================================================
# Check after syn_generic
# ============================================================
# set rst_mux_inst_generic [find / -instance *u_current_layer_reset_mux*]
set rst_mux_inst_generic [find / -instance *reset_mux*]

if {[llength $rst_mux_inst_generic] == 0} {
    puts "ERROR: sync_reset_mux hierarchy disappeared during syn_generic"
    exit 1
}
puts "INFO: sync_reset_mux survived syn_generic."
puts "INFO: generic reset mux = $rst_mux_inst_generic"
# ============================================================

write_snapshot -outdir $_REPORTS_PATH -tag generic
report datapath > $_REPORTS_PATH/generic/${DESIGN}_datapath.rpt
report_summary -outdir $_REPORTS_PATH


#### Build RTL power models
##build_rtl_power_models -design $DESIGN -clean_up_netlist [-clock_gating_logic] [-relative <hierarchical instance>]
#report power -rtl



####################################################################################################
## Synthesizing to gates
####################################################################################################

set_attribute syn_map_effort $MAP_OPT_EFF /
syn_map
puts "Runtime & Memory after 'syn_map'"
time_info MAPPED

# ============================================================
# PHASE 2: Freeze mapped sync_reset_mux BEFORE syn_opt
# ============================================================
# set rst_mux_inst_mapped [find / -instance *u_current_layer_reset_mux*]
set rst_mux_inst_mapped [find / -instance *reset_mux*]

if {[llength $rst_mux_inst_mapped] == 0} {
    puts "ERROR: reset_mux disappeared during syn_map"
    exit 1
}

puts "INFO: Applying preserve after syn_map."
puts "INFO: mapped reset mux = $rst_mux_inst_mapped"

set_attribute preserve true $rst_mux_inst_mapped

# puts "INFO: preserve(inst) = [get_attribute preserve $rst_mux_inst_mapped]"
puts "INFO: preserve(inst) = [get_attribute preserve [lindex $rst_mux_inst_mapped 0]]"
# ============================================================

write_snapshot -outdir $_REPORTS_PATH -tag map
report_summary -outdir $_REPORTS_PATH
report datapath > $_REPORTS_PATH/map/${DESIGN}_datapath.rpt


foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_map.rpt
}


write_do_lec -revised_design fv_map -logfile ${_LOG_PATH}/rtl2intermediate.lec.log > ${_OUTPUTS_PATH}/rtl2intermediate.lec.do

## ungroup -threshold <value>

#######################################################################################################
## Optimize Netlist
#######################################################################################################

## Uncomment to remove assigns & insert tiehilo cells during Incremental synthesis
##set_attribute remove_assigns true /
##set_remove_assign_options -buffer_or_inverter <libcell> -design <design|subdesign> 
##set_attribute use_tiehilo_for_const <none|duplicate|unique> /
set_attribute syn_opt_effort $MAP_OPT_EFF /
syn_opt
write_snapshot -outdir $_REPORTS_PATH -tag syn_opt
report_summary -outdir $_REPORTS_PATH

puts "Runtime & Memory after 'syn_opt'"
time_info OPT

# ============================================================
# Verify reset-mux hierarchy after syn_opt
# ============================================================
# set rst_mux_inst_final [find / -instance *u_current_layer_reset_mux*]
set rst_mux_inst_final [find / -instance *reset_mux*]

if {[llength $rst_mux_inst_final] == 0} {
    puts "ERROR: reset_mux disappeared during syn_opt"
    exit 1
}

puts "INFO: sync_reset_mux survived syn_opt."
puts "INFO: final reset mux = $rst_mux_inst_final"
# ============================================================

foreach cg [find / -cost_group *] {
  report timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_opt.rpt
}

#######################################################################################################
## convert 1'b0/1'b1 to cells
#######################################################################################################
set_attribute avoid false [find / -libcell LOGIC*]
set_attribute dont_touch false [find / -libcell LOGIC*]
insert_tiehilo_cells -hi LOGIC1_X1 -lo LOGIC0_X1


######################################################################################################
## write backend file set (verilog, SDC, config, etc.)
######################################################################################################


report datapath > $_REPORTS_PATH/${DESIGN}_datapath_incr.rpt
report messages > $_REPORTS_PATH/${DESIGN}_messages.rpt
report area > $_REPORTS_PATH/${DESIGN}_area.rpt
report gates > $_REPORTS_PATH/${DESIGN}_gates.rpt 
report gates -power > $_REPORTS_PATH/${DESIGN}_gates_power.rpt
report timing > $_REPORTS_PATH/${DESIGN}_timing.rpt 
report power -depth 9 > $_REPORTS_PATH/${DESIGN}_power.rpt 
report clock_gating > $_REPORTS_PATH/${DESIGN}_clockgating.rpt
write_snapshot -outdir $_REPORTS_PATH -tag final
report_summary -outdir $_REPORTS_PATH
write_design -basename ${_OUTPUTS_PATH}/${DESIGN}_m
## write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_m.v
## write_script > ${_OUTPUTS_PATH}/${DESIGN}_m.script
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_m.sdc
write_sdf -version 3.0 > ${_OUTPUTS_PATH}/${DESIGN}.sdf
write_parasitics > ${_OUTPUTS_PATH}/${DESIGN}.spef


#################################
### write_do_lec
#################################


write_do_lec -golden_design fv_map -revised_design ${_OUTPUTS_PATH}/${DESIGN}_m.v -logfile  ${_LOG_PATH}/intermediate2final.lec.log > ${_OUTPUTS_PATH}/intermediate2final.lec.do
##Uncomment if the RTL is to be compared with the final netlist..
##write_do_lec -revised_design ${_OUTPUTS_PATH}/${DESIGN}_m.v -logfile ${_LOG_PATH}/rtl2final.lec.log > ${_OUTPUTS_PATH}/rtl2final.lec.do

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

file copy [get_attribute stdout_log /] ${_LOG_PATH}/.

quit
