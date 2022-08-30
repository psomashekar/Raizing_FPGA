set_global_assignment -entity "raizingpll" -library "lib_raizingpll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "raizingpll" -library "lib_raizingpll" -name IP_TOOL_VERSION "17.0"
set_global_assignment -entity "raizingpll" -library "lib_raizingpll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_raizingpll" -name SPD_FILE [file join $::quartus(sip_path) "raizingpll.spd"]

set_global_assignment -library "lib_raizingpll" -name MISC_FILE [file join $::quartus(sip_path) "raizingpll_sim/raizingpll.vo"]
