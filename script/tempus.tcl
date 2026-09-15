################################################################
# Purpose:  Show a simple Tempus STA script
# Purpose:  Hightlight the order of operations and simple commands
# Author:   John Schritz   Nov 2015
# EXEC CMD: tempus -files scripts/tempus.tcl
################################################################
source script/tempus_config.tcl
set DesignName $DESIGN

################################
# Setup threading and client counts
################################
#set_multi_cpu_usage -localCpu 1

################################
# Setup some global variables or report settings
################################
set_table_style -no_frame_fix_width -nosplit

################################
# Read a view file
################################
read_view_definition $MMMC

################################
# Read the netlist in a gzipped format
################################
read_verilog $INNOVUS_OUTPUT/${DesignName}_enc.v

################################
# Link the design
################################
set_top_module ${DesignName} -ignore_undefined_cell

################################
# Check the size of the testcase
################################
set cellCnt [sizeof_collection [get_cells -hier *]]
puts "Your design has: $cellCnt instances"

################################
# Load netlist parasitics
################################
read_spef -rc_corner RcCorner $INNOVUS_OUTPUT/${DesignName}.spef

#set_interactive_constraint_modes [all_constraint_modes -active]
#set_propagated_clock [all_clocks]
#source script/latency.sdc

################################
# Adjust timer settings
################################
set_delay_cal_mode -siAware false   ;# Turn on SI when true
setSIMode -enable_glitch_report 0   ;# Turn on glitch analysis when set to 1

###################################
# Run timing
###################################
update_timing -full

###################################
# Run a whole list of common reports
###################################
set reportDir $TEMPUS_REPORT
file mkdir $reportDir

source script/reports.tcl

###################################
# Save the design and timing information
###################################
save_design tempus/${DesignName}_sta.session -overwrite

puts "All done"
###################################
# If in interactive session, return to the Tempus prompt
# If in batch session, return to the Linux prompt
###################################
# return
exit

# quit

