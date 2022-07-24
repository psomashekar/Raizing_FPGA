set_global_assignment -entity "plls16" -library "lib_plls16" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "plls16" -library "lib_plls16" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "plls16" -library "lib_plls16" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_plls16" -name SPD_FILE [file join $::quartus(sip_path) "plls16.spd"]

set_global_assignment -library "lib_plls16" -name MISC_FILE [file join $::quartus(sip_path) "plls16_sim/plls16.vo"]
