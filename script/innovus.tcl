source script/innovus_config.tcl


if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}

setMessageLimit 10000
set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
set init_gnd_net VSS
#set init_pwr_net {VDD VNW}
set init_pwr_net VDD
#set init_gnd_net {VSS VPW}

#set init_lef_file "/opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.lef
#                   /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.macro.lef
#				   /opt/cadence/nangate45/NangateOpenCellLibrary_PDKv1_3_v2010_12/Back_End/lef/NangateOpenCellLibrary.tech.lef"
set init_lef_file  [list $lef]

set init_verilog [list $netlist]

# set init_mmmc_file mmmc/enc_default.view
set init_mmmc_file $mmmc_view
#set init_io_file pad.io


## init design
init_design
setDesignMode -process 45


## check design
checkDesign -io -netlist -physicalLibrary -tieHiLo -timingLibrary -noHtml -outfile ${_REPORTS_PATH}/checkDesign.rpt


## global net
#clearGlobalNets
#globalNetConnect VDD -type pgpin -pin VDD -inst *
#globalNetConnect VSS -type pgpin -pin VSS -inst *
#globalNetConnect VDD -type pgpin -pin vdd! -inst *
#globalNetConnect VSS -type pgpin -pin gnd! -inst *
#globalNetConnect VDD -type tiehi -inst *
#globalNetConnect VSS -type tielo -inst *
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
#globalNetConnect VDD -type pgpin -pin VNW -inst * -verbose
globalNetConnect VDD -type tiehi -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose
#globalNetConnect VSS -type pgpin -pin VPW -inst * -verbose
globalNetConnect VSS -type tielo -inst * -verbose

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_globalNet.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_globalNet.rpt

## floorplan
# floorPlan -site FreePDK45_38x28_10R_NP_162NW_34O -r 1 0.75 10 10 10 10
floorPlan -site FreePDK45_38x28_10R_NP_162NW_34O -r 1 $core_util $core_margin $core_margin $core_margin $core_margin 
fit
checkFPlan -reportUtil -outFile ${_REPORTS_PATH}/checkFPlan.rpt


## halo
set top_layer    M6
set bottom_layer M1

deletehalofromblock  -allBlock
deleteroutinghalo -allBlocks
redraw

set size ${halo_size};#set size 5
addRoutingHalo -space ${size} -top ${top_layer} -bottom ${bottom_layer} -allBlocks
set size ${halo_size};#set size 5
addHaloToBlock ${size} ${size} ${size} ${size} -allBlock

redraw
deselectAll


## end tap
#addEndCap -preCap TAPCELL -postCap TAPCELL -prefix ENDCAP


## core ring
cutRow
deselectAll

setAddRingMode -stacked_via_top_layer ${top_layer}
setAddRingMode -stacked_via_bottom_layer ${bottom_layer}


set offset    3
set threshold 1
set jdistance 1
set spacing   3
set width     2

addRing -skip_via_on_wire_shape Noshape -skip_via_on_pin Standardcell \
    -type core_rings -jog_distance ${jdistance} \
    -threshold ${threshold} -nets {VSS VDD} -follow core  \
    -layer {bottom M5 top M5 right M6 left M6} \
    -width ${width} -spacing ${spacing} -offset ${offset}

saveDesign ${_OUTPUTS_PATH}/${design}_ring.enc


## add stripe
set width     1
set spacing   2
set distance  15
set layer     M6

setAddStripeMode -stacked_via_top_layer ${top_layer}
setAddStripeMode -stacked_via_bottom_layer ${bottom_layer}

addStripe \
    -nets                         {VSS VDD} \
    -layer                       ${layer}   \
    -width                         ${width} \
    -spacing                     ${spacing} \
    -set_to_set_distance        ${distance} \
    -merge_stripes_value                1.0 \
    -max_same_layer_jog_length          1.0 \
    -block_ring_top_layer_limit      ${top_layer} \
    -block_ring_bottom_layer_limit     ${bottom_layer} \
    -padcore_ring_top_layer_limit    ${top_layer} \
    -padcore_ring_bottom_layer_limit   ${bottom_layer}

saveDesign ${_OUTPUTS_PATH}/${design}_stripe.enc

sroute -nets {VSS VDD} -connect {corePin blockPin padRing floatingStripe}  -targetViaLayerRange    "${bottom_layer} ${top_layer}" -crossoverViaLayerRange "${bottom_layer} ${top_layer}" -layerChangeRange  "${bottom_layer} ${top_layer}" -allowJogging 1 -allowLayerChange 1 -padPinPortConnect { allPort oneGeom } -blockPin useLef  -blockPinTarget {nearestRingStripe nearestTarget}

saveDesign ${_OUTPUTS_PATH}/${design}_sroute.enc

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_sroute.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_sroute.rpt

#for scan
#specifyScanChain top_chain -start scan_in -stop scan_out
#scanTrace


## Placement
setPlaceMode -reset
set delaycal_use_default_delay_limit 1000

setPlaceMode \
    -congEffort            high \
    -timingDriven             1 \
    -doCongOpt                1 \
    -clkGateAware             0 \
    -powerDriven              1 \
    -ignoreSpare              0 \
    -placeIOPins              1 \
    -moduleAwareSpare         0 \
    -preserveRouting          0 \
    -rmAffectedRouting        0 \
    -checkRoute               1 \
    -swapEEQ                  0 \
    -prerouteAsObs {1 2 3 4 5 6}

setAnalysisMode -clkSrcPath false
setAnalysisMode -clockGatingCheck false
setAnalysisMode -clockPropagation forcedIdeal

setOptMode -allEndPoints true
setOptMode -verbose true
placeDesign -prePlaceOpt
checkPlace ${_REPORTS_PATH}/checkPlace.rpt

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_place.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_place.rpt


## pre-CTS
clearClockDomains
setClockDomains -all
timeDesign -preCTS -idealClock -pathReports -drvReports -slackReports -numPaths 50 -prefix ${design}_preCTS -outDir ${_REPORTS_PATH}/timingReports

setAnalysisMode -honorClockDomains true
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
setOptMode -allEndPoints true
setOptMode -fixDRC true
optDesign -preCTS
optDesign -preCTS -drv
setOptMode -allEndPoints false

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_preCTS.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_preCTS.rpt

## CTS
#clockDesign -specFile script/Clock.ctstch 
#clockDesign -specFile lib/clock.ctstch -outDir ${_REPORTS_PATH}/clock_report

set_ccopt_property buffer_cells {CLKBUF_X1 CLKBUF_X2 CLKBUF_X3}
#set_ccopt_property inverter_cells {CLKINVX1 CLKINVX12 CLKINVX16 CLKINVX2 CLKINVX20 CLKINVX3 CLKINVX4 CLKINVX8 CLKINVXL}
#set_ccopt_property use_inverters true
#create_ccopt_clock_tree_spec -file ${_OUTPUTS_PATH}/ccopt.spec
#create_clock_tree_spec -file script/cts.spec

clock_opt_design -cts
report_ccopt_clock_trees -file ${_REPORTS_PATH}/clock_trees.rpt
report_ccopt_skew_groups -file ${_REPORTS_PATH}/skew_groups.rpt

set_interactive_constraint_modes [all_constraint_modes -active]
set_propagated_clock [all_clocks]

## post-CTS
# redraw
# setLayerPreference net -isVisible 1
# setOptMode \
#     -effort           high  \
#     -powerEffort      none  \
#     -yieldEffort      none  \
#     -simplifyNetlist  false \
#     -setupTargetSlack 0.5   \
#     -holdTargetSlack  0.5   \
#     -maxDensity       0.95  \
#     -drcMargin        0     \

# 追加した: Setup, Hold viaolation countermeasure
setOptMode \
    -effort           high \
    -fixDRC           true \
    -setupTargetSlack 0.05 \
    -holdTargetSlack  0.05

setAnalysisMode -usefulSkew true

optDesign -postCTS
optDesign -postCTS -hold
optDesign -postCTS -drv

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_postCTS.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_postCTS.rpt

editTrim -all
editSelectVia -floating_via
editDelete -floating_via
deselectAll

## Routing
setNanoRouteMode -reset
setNanoRouteMode -quiet -routeInsertAntennaDiode true
routeDesign -globalDetail

#globalRoute
#setNanoRouteMode -drouteEndIteration 0
#detailRoute
#setNanoRouteMode -drouteEndIteration 1
#detailRoute
#setNanoRouteMode -drouteEndIteration 19
#detailRoute
#setNanoRouteMode -drouteEndIteration default
#detailRoute
#saveDesign droute

verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/conn_nanoroute.rpt
violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/viol_nanoroute.rpt

setDelayCalMode -siAware false
setAnalysisMode -analysisType onChipVariation


## post-Route
# setOptMode 
#     -effort           high \
#     -fixDRC           true \
#     -setupTargetSlack 0.05 \
#     -holdTargetSlack  0.05

# 追加: 最適化の方針を設定
setOptMode \
    -effort                           high \
    -fixDRC                           true \
    -opt_setup_target_slack           0.000 \
    -opt_hold_target_slack            0.020 \
    -opt_hold_slack_threshold        -0.100 \
    -opt_hold_allow_setup_tns_degradation false

optDesign -postRoute
optDesign -postRoute -hold

# 追加: postRoute の timing チェック
timeDesign -postRoute -hold
timeDesign -postRoute -setup


# add filler
getFillerMode
findCoreFillerCells
addFiller -cell FILLCELL_X1 FILLCELL_X2 FILLCELL_X4 FILLCELL_X8 FILLCELL_X16 FILLCELL_X32 -prefix FILLER -markFixed

## DRC check after routing
verifyGeometry -report ${_REPORTS_PATH}/geomafterroute.rpt
verifyConnectivity -type all -error 1000 -warning 50 -report ${_REPORTS_PATH}/connafterroute.rpt

violationBrowserReport -all -no_display_false -report ${_REPORTS_PATH}/violrout.rpt
summaryReport -noHtml -outfile ${_REPORTS_PATH}/summaryReport.rpt

## RC
#setExtractRCMode -engine postRoute -effortLevel high -coupled false
setExtractRCMode -engine postRoute -effortLevel low -coupled false;
extractRC
rcOut -spef ${_OUTPUTS_PATH}/${design}.spef -rc_corner RcCorner

## Report and Output
saveNetlist ${_OUTPUTS_PATH}/${design}_enc.v
streamOut ${_OUTPUTS_PATH}/${design} -mapFile streamOut.map -libName DesignLib -units 2000 -mode ALL
saveDesign ${_OUTPUTS_PATH}/${design}.enc

reportGateCount -level 5 -limit 1 -outfile ${_OUTPUTS_PATH}/${design}.gateCount
write_sdf -target_application verilog ${_OUTPUTS_PATH}/${design}.sdf
report_power -hierarchy 3 -outfile ${_OUTPUTS_PATH}/${design}_power_hier.rep

#convert_lib_clock_tree_latencies -latency_file_prefix lat_ -views AnalysisView

defOut -routing ${_OUTPUTS_PATH}/${design}.def

puts "Final Runtime & Memory."
puts "============================"
puts "Placement and Routing Finished ........."
puts "============================"

win
# exit
