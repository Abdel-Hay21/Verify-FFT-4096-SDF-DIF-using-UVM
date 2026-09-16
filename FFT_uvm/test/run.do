# QuestaSim compilation & execution script (Code Coverage)
vlib work
vmap work work

# 1. Compile Interfaces
vlog -work work +cover -covercells ../verif/interface/FFT_interface.sv

# 2. Compile RTL
set dut_v_files [glob -nocomplain ../rtl/*.v]
if {[llength $dut_v_files] > 0} { vlog -cover bcst -work work {*}$dut_v_files }
set dut_sv_files [glob -nocomplain ../rtl/*.sv]
if {[llength $dut_sv_files] > 0} { vlog -cover bcst -work work {*}$dut_sv_files }

# 3. Compile UVM Components
vlog -work work ../verif/config/FFT_config_obj.sv
vlog -work work ../verif/agent/FFT_seq_item.sv
vlog -work work ../verif/agent/FFT_driver.sv
vlog -work work ../verif/agent/FFT_monitor.sv
vlog -work work ../verif/agent/FFT_sequencer.sv
vlog -work work ../verif/agent/FFT_agent.sv
# SystemVerilog Golden Model Compilation
vlog -work work ../verif/reference_model/FFT_reference_model.sv
vlog -coveropt 3 +cover +acc -work work ../verif/environment/FFT_coverage.sv
vlog -coveropt 3 +cover +acc -work work ../verif/environment/FFT_scoreboard.sv
vlog -coveropt 3 +cover +acc -work work ../verif/environment/FFT_predictor.sv
vlog -work work ../verif/environment/FFT_virtual_sequencer.sv
vlog -work work ../verif/environment/FFT_environment.sv
vlog -work work ../verif/sequences/sequences/*.sv
vlog -work work ../verif/sequences/virtual/FFT_virtual_sequence.sv
vlog -work work ../verif/test/FFT_test.sv
vlog -work work ../verif/assertions/FFT_assertions.sv
vlog -work work ../verif/assertions/FFT_bind.sv

# 4. Compile Top Module
vlog -work work ../verif/top/FFT_top.sv

# 5. Run Simulation
vsim -coverage -voptargs=+acc work.FFT_top work.FFT_bind_sv_unit -ldflags "-lws2_32"
coverage save -onexit FFT_CodeCoverage.ucdb

if [file exists wave.do] { do wave.do } else { add wave -r /* }

run -all

coverage save FFT_uvm.ucdb -du fft_4096_dif
vcover report FFT_uvm.ucdb -details -annotate -all -output Code_Coverage_Report.txt
