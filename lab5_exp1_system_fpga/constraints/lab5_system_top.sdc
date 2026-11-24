# ============================================================================
# SDC Timing Constraints: Lab 5 Full System on DE10-Standard (50 MHz)
# ============================================================================

# 50 MHz board clock (20.000 ns period)
create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

derive_pll_clocks
derive_clock_uncertainty

# Asynchronous external switch/button inputs & visual LED outputs
# (SW[9] is synchronized internally via 2-FF synchronizer u_run_sync)
set_false_path -from [get_ports {KEY[0]}]
set_false_path -from [get_ports {SW[9]}]
set_false_path -to   [get_ports {LEDR[*]}]
