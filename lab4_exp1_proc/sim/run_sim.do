# ModelSim simulation script for Lab 4 Experiment 1 (Simple Processor)
# Usage in ModelSim GUI: cd to lab4_exp1_proc/sim, then type: do run_sim.do

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

vlog -sv ../rtl/regn.sv
vlog -sv ../rtl/dec3to8.sv
vlog -sv ../rtl/addsub.sv
vlog -sv ../rtl/proc.sv
vlog -sv tb_proc.sv

vsim -voptargs=+acc work.tb_proc

if {![batch_mode]} {
    add wave -divider "Inputs & Control"
    add wave -radix binary /tb_proc/Resetn
    add wave -radix binary /tb_proc/Clock
    add wave -radix binary /tb_proc/Run
    add wave -radix octal  /tb_proc/DIN
    add wave -radix binary /tb_proc/Done

    add wave -divider "Processor Internals"
    add wave -radix octal  /tb_proc/dut/IR
    add wave -radix symbolic /tb_proc/dut/Tstep_Q
    add wave -radix hex    /tb_proc/dut/R0
    add wave -radix hex    /tb_proc/dut/R1
    add wave -radix hex    /tb_proc/dut/R2
    add wave -radix hex    /tb_proc/dut/A
    add wave -radix hex    /tb_proc/dut/G
    add wave -radix hex    /tb_proc/BusWires
}

run -all

if {![batch_mode]} {
    wave zoom full
}
