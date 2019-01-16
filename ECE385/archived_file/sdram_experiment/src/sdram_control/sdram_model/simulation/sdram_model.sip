set_global_assignment -entity "sdram_model" -library "lib_sdram_model" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "sdram_model" -library "lib_sdram_model" -name IP_TOOL_VERSION "18.0"
set_global_assignment -entity "sdram_model" -library "lib_sdram_model" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_sdram_model" -name SPD_FILE [file join $::quartus(sip_path) "../sdram_model.spd"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "../../sdram_model.qsys"]

set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "sdram_model.v"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.v"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_synchronizer.v"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_reset_controller.sdc"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_model_sdram_controller.v"]
set_global_assignment -library "lib_sdram_model" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sdram_model_sdram_controller_test_component.v"]
