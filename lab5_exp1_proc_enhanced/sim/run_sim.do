# ModelSim simulation script for Lab 5 Project 1 (Enhanced Processor)
# Usage in ModelSim GUI: cd to lab5_exp1_proc_enhanced/sim, then type: do run_sim.do

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

vlog -sv ../rtl/regn.sv
vlog -sv ../rtl/dec3to8.sv
vlog -sv ../rtl/addsub.sv
vlog -sv ../rtl/pc_counter.sv
vlog -sv ../rtl/proc_enhanced.sv
vlog -sv tb_proc_enhanced.sv

vsim -voptargs=+acc work.tb_proc_enhanced

if {![batch_mode]} {
    add wave -divider "System Signals"
    add wave -radix binary   /tb_proc_enhanced/Resetn
    add wave -radix binary   /tb_proc_enhanced/Clock
    add wave -radix binary   /tb_proc_enhanced/Run
    add wave -radix binary   /tb_proc_enhanced/Done

    add wave -divider "Memory Interface"
    add wave -radix hex      /tb_proc_enhanced/ADDR
    add wave -radix hex      /tb_proc_enhanced/DOUT
    add wave -radix binary   /tb_proc_enhanced/W
    add wave -radix octal    /tb_proc_enhanced/DIN
    add wave -radix hex      /tb_proc_enhanced/led_reg

    add wave -divider "Processor Internals"
    add wave -radix symbolic /tb_proc_enhanced/dut/Tstep_Q
    add wave -radix octal    /tb_proc_enhanced/dut/IR
    add wave -radix hex      /tb_proc_enhanced/dut/R7
    add wave -radix hex      /tb_proc_enhanced/dut/R0
    add wave -radix hex      /tb_proc_enhanced/dut/R1
    add wave -radix hex      /tb_proc_enhanced/dut/R2
    add wave -radix hex      /tb_proc_enhanced/dut/R3
    add wave -radix hex      /tb_proc_enhanced/dut/R4
    add wave -radix hex      /tb_proc_enhanced/dut/R5
    add wave -radix hex      /tb_proc_enhanced/dut/R6
    add wave -radix hex      /tb_proc_enhanced/dut/G
    add wave -radix hex      /tb_proc_enhanced/dut/BusWires
}

run -all

if {![batch_mode]} {
    wave zoom full
}
