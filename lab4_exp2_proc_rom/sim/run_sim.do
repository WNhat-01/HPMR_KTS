# ModelSim simulation script for Lab 4 Experiment 2 (Processor + 32x9 ROM + 5-bit Counter)
# Usage in ModelSim GUI: cd to lab4_exp2_proc_rom/sim, then type: do run_sim.do

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

vlog -sv ../rtl/regn.sv
vlog -sv ../rtl/dec3to8.sv
vlog -sv ../rtl/addsub.sv
vlog -sv ../rtl/proc.sv
vlog -sv ../rtl/counter5.sv
vlog -sv ../rtl/my_rom.sv
vlog -sv ../rtl/lab4_exp2_top.sv
vlog -sv tb_lab4_exp2.sv

vsim -voptargs=+acc work.tb_lab4_exp2

if {![batch_mode]} {
    add wave -divider "Clocks & Control"
    add wave -radix binary   /tb_lab4_exp2/Resetn
    add wave -radix binary   /tb_lab4_exp2/Run
    add wave -radix binary   /tb_lab4_exp2/MClock
    add wave -radix binary   /tb_lab4_exp2/PClock
    add wave -radix binary   /tb_lab4_exp2/Done

    add wave -divider "Counter & ROM"
    add wave -radix unsigned /tb_lab4_exp2/dut/rom_addr
    add wave -radix octal    /tb_lab4_exp2/dut/rom_data

    add wave -divider "Processor Internals"
    add wave -radix octal    /tb_lab4_exp2/dut/u_proc/IR
    add wave -radix symbolic /tb_lab4_exp2/dut/u_proc/Tstep_Q
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/R1
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/R2
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/R3
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/R4
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/A
    add wave -radix hex      /tb_lab4_exp2/dut/u_proc/G
    add wave -radix hex      /tb_lab4_exp2/Bus
}

run -all

if {![batch_mode]} {
    wave zoom full
}
