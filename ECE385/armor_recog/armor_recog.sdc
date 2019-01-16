## Generated SDC file "armor_recog.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions
## and other software and tools, and its AMPP partner logic
## functions, and any output files from any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Intel Program License
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"

## DATE    "Wed Dec 05 17:32:17 2018"

##
## DEVICE  "EP4CE115F29C7"
##


#**************************************************************
# Time Information
#**************************************************************
set_time_format -unit ns -decimal_places 3

#**************************************************************
# Create Clock
#**************************************************************
create_clock -name {CLOCK2_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports {CLOCK2_50}]
create_clock -name {camera_control:camera_control|camera_config:cam_config|mI2C_CTRL_CLK} -period 1.000 -waveform { 0.000 0.500 } [get_registers {camera_control:camera_control|camera_config:cam_config|mI2C_CTRL_CLK}]
create_clock -name {D5M_PIXLCLK} -period 1.000 -waveform { 0.000 0.500 } [get_ports {D5M_PIXLCLK}]

#**************************************************************
# Create Generated Clock
#**************************************************************
create_generated_clock -name {sdram_pll|altpll_component|auto_generated|pll1|clk[0]} -source [get_pins {sdram_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -master_clock {CLOCK2_50} [get_pins {sdram_pll|altpll_component|auto_generated|pll1|clk[0]}]
create_generated_clock -name {sdram_pll|altpll_component|auto_generated|pll1|clk[1]} -source [get_pins {sdram_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 2 -phase -108.000 -master_clock {CLOCK2_50} [get_pins {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]
create_generated_clock -name {sdram_pll|altpll_component|auto_generated|pll1|clk[2]} -source [get_pins {sdram_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {CLOCK2_50} [get_pins {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]
create_generated_clock -name {sdram_pll|altpll_component|auto_generated|pll1|clk[3]} -source [get_pins {sdram_pll|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {CLOCK2_50} [get_pins {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]

#**************************************************************
# Set Clock Latency
#**************************************************************

#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty

#**************************************************************
# Set Input Delay
#**************************************************************
#------------------------------KEY------------------------------
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {KEY[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {KEY[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {KEY[2]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {KEY[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {KEY[3]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {KEY[3]}]
#------------------------------SW------------------------------
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[0]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[1]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[2]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[3]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[3]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[4]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[4]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[5]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[5]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[6]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[6]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[7]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[7]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[8]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[8]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[9]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[9]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[10]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[10]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[11]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[11]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[12]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[12]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[13]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[13]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[14]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[14]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[15]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[15]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[16]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[16]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK2_50}]  3.000 [get_ports {SW[17]}]
set_input_delay -add_delay -min -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {SW[17]}]
#------------------------------SDRAM------------------------------
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[0]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[0]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[1]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[1]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[2]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[2]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[3]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[3]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[4]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[4]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[5]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[5]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[6]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[6]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[7]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[7]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[8]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[8]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[9]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[9]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[10]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[10]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[11]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[11]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[12]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[12]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[13]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[13]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[14]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[14]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[15]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[15]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[16]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[16]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[17]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[17]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[18]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[18]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[19]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[19]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[20]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[20]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[21]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[21]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[22]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[22]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[23]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[23]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[24]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[24]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[25]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[25]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[26]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[26]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[27]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[27]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[28]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[28]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[29]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[29]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[30]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[30]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  3.000 [get_ports {DRAM_DQ[31]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[31]}]
#------------------------------CCD------------------------------
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[0]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[0]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[1]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[1]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[2]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[2]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[3]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[3]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[4]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[4]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[5]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[5]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[6]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[6]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[7]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[7]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[8]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[8]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[9]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[9]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[10]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[10]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_D[11]}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_D[11]}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_FVAL}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_FVAL}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_LVAL}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_LVAL}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_SDATA}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_SDATA}]
set_input_delay -add_delay -max -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  3.000 [get_ports {D5M_STROBE}]
set_input_delay -add_delay -min -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_STROBE}]

#**************************************************************
# Set Output Delay
#**************************************************************
#------------------------------LED------------------------------
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDG[7]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[13]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[14]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[15]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[16]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {LEDR[17]}]
#------------------------------HEX------------------------------
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX0[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX1[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX2[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX3[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX4[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX5[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX6[6]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[0]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[1]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[2]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[3]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[4]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[5]}]
set_output_delay -add_delay  -clock [get_clocks {CLOCK2_50}]  2.000 [get_ports {HEX7[6]}]
#------------------------------VGA------------------------------
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[4]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[5]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[6]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_R[7]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[4]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[5]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[6]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_G[7]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[4]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[5]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[6]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_B[7]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_BLANK_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_CLK}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_HS}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[3]}]  2.000 [get_ports {VGA_VS}]
#------------------------------SDRAM------------------------------
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[4]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[5]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[6]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[7]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[8]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[9]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[10]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[11]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_ADDR[12]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_BA[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_BA[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_CAS_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_CKE}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_CS_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQM[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQM[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQM[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQM[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[0]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[1]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[2]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[3]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[4]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[5]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[6]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[7]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[8]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[9]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[10]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[11]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[12]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[13]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[14]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[15]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[16]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[17]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[18]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[19]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[20]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[21]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[22]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[23]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[24]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[25]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[26]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[27]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[28]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[29]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[30]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_DQ[31]}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_RAS_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_WE_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[1]}]  2.000 [get_ports {DRAM_CLK}]
#------------------------------CCD------------------------------
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_RESET_N}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_SCLK}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_SDATA}]
set_output_delay -add_delay  -clock [get_clocks {sdram_pll|altpll_component|auto_generated|pll1|clk[2]}]  2.000 [get_ports {D5M_TRIGGER}]

#**************************************************************
# Set Clock Groups
#**************************************************************

#**************************************************************
# Set False Path
#**************************************************************
set_false_path -from * -to [get_ports {LEDG[0]}]
set_false_path -from * -to [get_ports {LEDG[1]}]
set_false_path -from * -to [get_ports {LEDG[2]}]
set_false_path -from * -to [get_ports {LEDG[3]}]
set_false_path -from * -to [get_ports {LEDG[4]}]
set_false_path -from * -to [get_ports {LEDG[5]}]
set_false_path -from * -to [get_ports {LEDG[6]}]
set_false_path -from * -to [get_ports {LEDG[7]}]
set_false_path -from * -to [get_ports {KEY[0]}]
set_false_path -from * -to [get_ports {KEY[1]}]
set_false_path -from * -to [get_ports {KEY[2]}]
set_false_path -from * -to [get_ports {KEY[3]}]
set_false_path -from * -to [get_ports {HEX0[0]}]
set_false_path -from * -to [get_ports {HEX0[1]}]
set_false_path -from * -to [get_ports {HEX0[2]}]
set_false_path -from * -to [get_ports {HEX0[3]}]
set_false_path -from * -to [get_ports {HEX0[4]}]
set_false_path -from * -to [get_ports {HEX0[5]}]
set_false_path -from * -to [get_ports {HEX0[6]}]
set_false_path -from * -to [get_ports {HEX1[0]}]
set_false_path -from * -to [get_ports {HEX1[1]}]
set_false_path -from * -to [get_ports {HEX1[2]}]
set_false_path -from * -to [get_ports {HEX1[3]}]
set_false_path -from * -to [get_ports {HEX1[4]}]
set_false_path -from * -to [get_ports {HEX1[5]}]
set_false_path -from * -to [get_ports {HEX1[6]}]
set_false_path -from * -to [get_ports {HEX2[0]}]
set_false_path -from * -to [get_ports {HEX2[1]}]
set_false_path -from * -to [get_ports {HEX2[2]}]
set_false_path -from * -to [get_ports {HEX2[3]}]
set_false_path -from * -to [get_ports {HEX2[4]}]
set_false_path -from * -to [get_ports {HEX2[5]}]
set_false_path -from * -to [get_ports {HEX2[6]}]
set_false_path -from * -to [get_ports {HEX3[0]}]
set_false_path -from * -to [get_ports {HEX3[1]}]
set_false_path -from * -to [get_ports {HEX3[2]}]
set_false_path -from * -to [get_ports {HEX3[3]}]
set_false_path -from * -to [get_ports {HEX3[4]}]
set_false_path -from * -to [get_ports {HEX3[5]}]
set_false_path -from * -to [get_ports {HEX3[6]}]
set_false_path -from * -to [get_ports {HEX4[0]}]
set_false_path -from * -to [get_ports {HEX4[1]}]
set_false_path -from * -to [get_ports {HEX4[2]}]
set_false_path -from * -to [get_ports {HEX4[3]}]
set_false_path -from * -to [get_ports {HEX4[4]}]
set_false_path -from * -to [get_ports {HEX4[5]}]
set_false_path -from * -to [get_ports {HEX4[6]}]
set_false_path -from * -to [get_ports {HEX5[0]}]
set_false_path -from * -to [get_ports {HEX5[1]}]
set_false_path -from * -to [get_ports {HEX5[2]}]
set_false_path -from * -to [get_ports {HEX5[3]}]
set_false_path -from * -to [get_ports {HEX5[4]}]
set_false_path -from * -to [get_ports {HEX5[5]}]
set_false_path -from * -to [get_ports {HEX5[6]}]
set_false_path -from * -to [get_ports {HEX6[0]}]
set_false_path -from * -to [get_ports {HEX6[1]}]
set_false_path -from * -to [get_ports {HEX6[2]}]
set_false_path -from * -to [get_ports {HEX6[3]}]
set_false_path -from * -to [get_ports {HEX6[4]}]
set_false_path -from * -to [get_ports {HEX6[5]}]
set_false_path -from * -to [get_ports {HEX6[6]}]
set_false_path -from * -to [get_ports {HEX7[0]}]
set_false_path -from * -to [get_ports {HEX7[1]}]
set_false_path -from * -to [get_ports {HEX7[2]}]
set_false_path -from * -to [get_ports {HEX7[3]}]
set_false_path -from * -to [get_ports {HEX7[4]}]
set_false_path -from * -to [get_ports {HEX7[5]}]
set_false_path -from * -to [get_ports {HEX7[6]}]

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
