transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/ece385-fa18/sdram_experiment/src {C:/ece385-fa18/sdram_experiment/src/main_pll.v}
vlog -vlog01compat -work work +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_fifo.v}
vlog -vlog01compat -work work +incdir+C:/ece385-fa18/sdram_experiment/db {C:/ece385-fa18/sdram_experiment/db/main_pll_altpll.v}
vlib sdram_model
vmap sdram_model sdram_model
vlog -vlog01compat -work sdram_model +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/sdram_model.v}
vlog -vlog01compat -work sdram_model +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules/altera_reset_controller.v}
vlog -vlog01compat -work sdram_model +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work sdram_model +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_model/synthesis/submodules/sdram_model_sdram_controller.v}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src/camera_control {C:/ece385-fa18/sdram_experiment/src/camera_control/simulate_camera.sv}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src/sdram_control {C:/ece385-fa18/sdram_experiment/src/sdram_control/sdram_control.sv}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src {C:/ece385-fa18/sdram_experiment/src/sdram_experiment.sv}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src/vga_control {C:/ece385-fa18/sdram_experiment/src/vga_control/vga_signal.sv}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src/vga_control {C:/ece385-fa18/sdram_experiment/src/vga_control/vga_color.sv}
vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src/vga_control {C:/ece385-fa18/sdram_experiment/src/vga_control/vga_control.sv}

vlog -sv -work work +incdir+C:/ece385-fa18/sdram_experiment/src {C:/ece385-fa18/sdram_experiment/src/sdram_control_sim.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -L sdram_model -voptargs="+acc"  sdram_control

add wave *
view structure
view signals
run 2000 ns