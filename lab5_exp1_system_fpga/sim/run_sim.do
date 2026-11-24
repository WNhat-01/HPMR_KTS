# ModelSim simulation script for Lab 5 Full System (Processor + 128x9 RAM + LEDs)
# Usage in ModelSim GUI: cd to lab5_exp1_system_fpga/sim, then type: do run_sim.do

if {[file exists work]} {
    vdel -lib work -all
}
vlib work

vlog -sv ../rtl/regn.sv
vlog -sv ../rtl/dec3to8.sv
vlog -sv ../rtl/addsub.sv
vlog -sv ../rtl/pc_counter.sv
vlog -sv ../rtl/proc_enhanced.sv
vlog -sv ../rtl/run_sync.sv
vlog -sv ../rtl/ram128x9.sv
vlog -sv ../rtl/lab5_system_top.sv
vlog -sv tb_lab5_system.sv

vsim -voptargs=+acc work.tb_lab5_system

if {![batch_mode]} {
    add wave -divider "Board I/O (DE10-Standard)"
    add wave -radix binary   /tb_lab5_system/CLOCK_50
    add wave -radix binary   /tb_lab5_system/KEY
    add wave -radix binary   /tb_lab5_system/SW
    add wave -radix binary   /tb_lab5_system/dut/Run_sync
    add wave -radix unsigned /tb_lab5_system/LEDR
    add wave -radix binary   /tb_lab5_system/LEDR

    add wave -divider "Memory & Address Decode"
    add wave -radix hex      /tb_lab5_system/dut/ADDR
    add wave -radix hex      /tb_lab5_system/dut/DOUT
    add wave -radix octal    /tb_lab5_system/dut/DIN
    add wave -radix binary   /tb_lab5_system/dut/W
    add wave -radix binary   /tb_lab5_system/dut/mem_wr_en
    add wave -radix binary   /tb_lab5_system/dut/led_en

    add wave -divider "Processor State & Registers"
    add wave -radix symbolic /tb_lab5_system/dut/u_proc/Tstep_Q
    add wave -radix octal    /tb_lab5_system/dut/u_proc/IR
    add wave -radix hex      /tb_lab5_system/dut/u_proc/R7
    add wave -radix unsigned /tb_lab5_system/dut/u_proc/R2
    add wave -radix unsigned /tb_lab5_system/dut/u_proc/R3
    add wave -radix unsigned /tb_lab5_system/dut/u_proc/R4
    add wave -radix unsigned /tb_lab5_system/dut/u_proc/G
    add wave -radix binary   /tb_lab5_system/dut/Done
}

run -all

if {![batch_mode]} {
    wave zoom full
}
