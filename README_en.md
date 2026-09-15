# ASIC Tutorial

[日本語版](README.md)

## 0. Environment Setup

### 0.1. Clone the tutorial repository

```bash
git clone https://github.com/k-awaki/tomlab-asic-tutorial.git
cd tomlab-asic-tutorial
```

### 0.2. Configure the Cadence tool paths

Configure the `.bashrc` file in your home directory so that the Cadence tools can be accessed.

First, check the current contents of `.bashrc`:

```bash
cat ~/.bashrc
```

If the following settings are not present at the end of the file, add them using `vi ~/.bashrc` or another text editor, and then run `source ~/.bashrc`.

```bash
# Cadence License
export CDS_LIC_FILE=/opt/cadence/license/license.dat
export CDS_AUTO_64BIT=ALL

# DDI
export DDI_INST_DIR=/opt/cadence/DDI/DDI231
export PATH=$DDI_INST_DIR/bin:$PATH

# SSV
export SSV_INST_DIR=/opt/cadence/SSV/SSV231
export PATH=$SSV_INST_DIR/bin:$PATH

# QUANTUS
export QUANTUS_INST_DIR=/opt/cadence/QUANTUS/QUANTUS231
export PATH=$QUANTUS_INST_DIR/bin:$PATH

# XCELIUM
export XCELIUM_INST_DIR=/opt/cadence/XCELIUM/XCELIUM2309
export PATH=$XCELIUM_INST_DIR/tools.lnx86/bin:$PATH
```

> Verification: Run `which genus`. If the path to the Genus executable is displayed, the environment setup is complete.

### 0.3. Check the directory structure

Run `tree.bash` to check the directory structure of the tutorial.

```bash
$ ./tree.bash
.
├── README.md                    # Japanese README for this repository
├── mmmc                         # MMMC (Multi-Mode Multi-Corner) configuration directory
│   └── enc_default.view         # MMMC view configuration for Innovus/Tempus
├── model                        # RTL design files
│   └── counter.v                # RTL description of the counter circuit
├── script                       # Scripts for the ASIC design flow
│   ├── genus.tcl                # Logic synthesis script for Cadence Genus
│   ├── genus_config.tcl         # Design and library configuration for Genus
│   ├── innovus.tcl              # Place & Route script for Cadence Innovus
│   ├── innovus_config.tcl       # Design and floorplan configuration for Innovus
│   ├── reports.tcl              # STA report generation script for Tempus
│   ├── run_xrun_gate            # Post-synthesis gate-level simulation script
│   ├── run_xrun_layout          # Post-layout simulation script
│   ├── run_xrun_rtl             # RTL simulation script
│   ├── tempus.tcl               # STA script for Cadence Tempus
│   ├── tempus_config.tcl        # Timing analysis configuration for Tempus
│   ├── wave_gate.tcl            # Waveform configuration for gate-level simulation
│   ├── wave_layout.tcl          # Waveform configuration for post-layout simulation
│   └── wave_rtl.tcl             # Waveform configuration for RTL simulation
├── sdc                          # Timing constraint files
│   └── clk.sdc                  # SDC timing constraints such as the clock definition
├── sim                          # Simulation results and waveform database directory
├── streamOut.map                # GDSII stream-out layer map for Innovus
├── tb                           # Testbench files
│   ├── counter_gate_tb.v        # Testbench for post-synthesis gate-level simulation
│   ├── counter_layout_tb.v      # Testbench for post-layout simulation
│   └── counter_rtl_tb.v         # Testbench for RTL simulation
└── tree.bash                    # Script for displaying the directory structure
```

## 1. RTL Simulation and Waveform Check

### 1.1. Run the RTL simulation

```bash
./script/run_xrun_rtl
```

After the simulation finishes, verify the following:

* [ ] Confirm that both the testbench (`tb`) and model report `errors: 0` in the log.
* [ ] Confirm that `... Done` is displayed at the end of the log.

Launch `SimVision` using the following command:

```bash
simvision &
```

> If an error such as "display not found" occurs, search for information about **TeraTerm & XLaunch** on Windows.

### Steps to View Waveforms

1. In the SimVision menu, click **File → Open Database...**
   (Icon: <img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />)
2. Open `sim/waves_rtl.shm`.
3. Select `counter_rtl_tb` from the **Design Browser** on the left.
4. Select the signals you want to inspect from the **Signals** list on the right, right-click them, and select **Send to Waveform Window**.
   (Icon: <img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)

## 2. Logic Synthesis with Genus

### 2.1. Generate a gate-level netlist from the RTL design

```bash
genus -legacy_ui -files script/genus.tcl
```

After synthesis finishes, verify the following:

* [ ] Confirm that `Synthesis Finished .........` is displayed in the log.
* [ ] Check `genus/logs_power/genus.log` and confirm that there are no `error` or `Error` messages.
* [ ] Check the timing report in `genus/reports_power/final.rpt` and confirm that there are no negative-slack timing violations.

### 2.2. Run the Pre-layout Gate-Level Simulation

```bash
./script/run_xrun_gate
```

After the simulation finishes, verify the following:

* [ ] Confirm that both the testbench (`tb`) and model report `errors: 0` in the log.
* [ ] Confirm that `... Done` is displayed at the end of the log.

> In this tutorial, the pre-layout gate-level simulation uses the netlist generated by Genus, but SDF back-annotation using `$sdf_annotate` is not performed. If SDF-based timing simulation is required, add `$sdf_annotate` to the testbench.

Launch `SimVision` using the following command if it is not already running:

```bash
# No need to execute this again if SimVision is already open
# simvision &
```

> If an error such as "display not found" occurs, search for information about **TeraTerm & XLaunch** on Windows.

### Steps to View Waveforms

1. In the SimVision menu, click **File → Open Database...**
   (Icon: <img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />)
2. Open `sim/waves_gate.shm`.
3. Select `counter_gate_tb` from the **Design Browser** on the left.
4. Select the signals you want to inspect from the **Signals** list on the right, right-click them, and select **Send to Waveform Window**.
   (Icon: <img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)

## 3. Place & Route with Innovus

### 3.1. Perform placement and routing

Use the gate-level netlist generated during logic synthesis to physically place the standard cells and route the connections on the chip.

```bash
innovus -files script/innovus.tcl
```

After Place & Route finishes, check the reports in the `innovus/reports/` directory and verify the following:

* [ ] **Geometry / Routing Check (Innovus Geometry/DRC Check):** Check `geomafterroute.rpt` and confirm that there are no routing-rule violations (`Total Violations : 0`).
* [ ] **Connectivity Check:** Check `connafterroute.rpt` and confirm that there are no shorts or unconnected nets (`Total Violations : 0`).
* [ ] **Timing Check:** Check the summary reports in `timingReports/` (such as `.summary.gz` files) and confirm that the setup and hold slack values are positive.

### 3.2. Post-Layout Gate-Level Simulation

Run a gate-level simulation using the SDF generated after Place & Route so that cell and interconnect delays are taken into account.

```bash
./script/run_xrun_layout
```

After the simulation finishes, verify the following:

* [ ] Confirm that both the testbench (`tb`) and model report `errors: 0` in the log.
* [ ] Confirm that `... Done` is displayed at the end of the log.

Launch `SimVision` using the following command if it is not already running:

```bash
# No need to execute this again if SimVision is already open
# simvision &
```

> If an error such as "display not found" occurs, search for information about **TeraTerm & XLaunch** on Windows.

### Steps to View Waveforms

1. In the SimVision menu, click **File → Open Database...**
   (Icon: <img width="30" height="25" alt="Image" src="https://github.com/user-attachments/assets/d521736f-7283-4964-a557-b95ecdc97440" />)
2. Open `sim/waves_layout.shm`.
3. Select `counter_layout_tb` from the **Design Browser** on the left.
4. Select the signals you want to inspect from the **Signals** list on the right, right-click them, and select **Send to Waveform Window**.
   (Icon: <img width="25" height="28" alt="Image" src="https://github.com/user-attachments/assets/639b4693-d5a0-4ddd-8d12-6fb3ef551944" />)

## 4. Static Timing Analysis with Tempus

### 4.1. Run Static Timing Analysis

Use Cadence Tempus to perform Static Timing Analysis (STA) on the post-layout design.

Tempus reads the post-layout netlist generated by Innovus together with the SPEF file, which contains parasitic resistance and capacitance information for the routed interconnects. It then analyzes setup and hold timing under the specified clock and timing constraints.

```bash
tempus -files script/tempus.tcl
```

After the analysis finishes, check the reports in the `tempus/reports/` directory and verify the following:

* [ ] **Timing Constraint Check:** Check `tempus/reports/check_timing.rpt` and confirm that there are no unintended issues that would make the timing analysis incomplete, such as undefined clocks or unintended unconstrained paths.
* [ ] **Analysis Coverage Check:** Check `tempus/reports/coverage.rpt` and confirm that there are no unintended `Untested` timing checks in the setup/hold analysis.
* [ ] **Setup Timing Check:** Check `tempus/reports/setup_1.rpt` and confirm that there are no setup violations (`Slack < 0`). If necessary, check the more detailed `setup_100.rpt.gz` report.
* [ ] **Hold Timing Check:** Check `tempus/reports/hold_1.rpt` and confirm that there are no hold violations (`Slack < 0`). If necessary, check the more detailed `hold_100.rpt.gz` report.

To check all timing constraint violations together, you can also inspect:

```bash
tempus/reports/allviol.rpt
```

If `allviol.rpt` contains no unintended constraint violations and there is no negative slack in either the setup or hold analysis, the design can be considered to meet timing under the specified timing conditions.
