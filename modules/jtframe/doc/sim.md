# Cabinet inputs during simulation
You can use a hex file with inputs for simulation. Enable this with the macro
SIM_INPUTS. The file must be called sim_inputs.hex. Each line has a hexadecimal
number with inputs coded. Active high only:

bit    |    meaning
-------|-------------
0      |    coin 1
1      |    coin 2
2      |    1P start
3      |    2P start
4      |    right   (may vary with each game)
5      |    left    (may vary with each game)
6      |    down    (may vary with each game)
7      |    up      (may vary with each game)
8      |    Button 1
9      |    Button 2
10     |    Test button

Each line will be applied on a new frame.

# Fast Load

## MiST
Starting from the Dec. 2020 firmware update, MiST can now delegate the ROM load to the FPGA. This makes the process 4x faster. This option is enabled by default. However, it can be a problem because the ROM transfer will be composed of full SD card sectors so there will be some garbage sent at the end of the ROM. If the core is not compatible with this and it relies on exact sizing of the ROM it needs to define the macro **JTFRAME_MIST_DIRECT** and set it to zero:

```
set_global_assignment -name VERILOG_MACRO "JTFRAME_MIST_DIRECT=0"
```

## MiSTer
In order to preserve the 8-bit ROM download interface with MiST, _jtframe_mister_ presents it too. However it can operate internally with 16-bit packets if the macro **JTFRAME_MR_FASTIO** is set to 1. This has only been tested with 96MHz clock. Indeed, if **JTFRAME_CLK96** is defined and **JTFRAME_MR_FASTIO** is not, then it will be defined to 1.

The measured speed for data transfers in MiSTer is about 1.2MHz (800ns) per request. If **JTFRAME_MR_FASTIO** is set, each request is 16-bit words, otherwise, 8 bits.

# SDRAM Simulation
A model for SDRAM mt48lc16m16a2 is included in JTFRAME. The model will load the contents of the file **sdram.hex** if available at the beginning of simulation.

The current contents of the SDRAM can be dumped at the beginning of each frame (falling edge of vertical blank) if **JTFRAME_SAVESDRAM** is defined. Because this is quite an overhead, it is possible to restrict it to dump only a certain **DUMP_START** frame count has been reached. All frames will be dumped after it. The macro **DUMP_START** is the same one used for setting the start of signal dump to the __VCD__ file.

To simulate the SDRAM load operation use **-load** on sim.sh. The normal download speed 1/270ns=3.7MHz. This is faster than the real systems but speeds up simulation. It is possible to slow it down by adding dead clock cycles to each transfer. The macro **JTFRAME_SIM_LOAD_EXTRA** can be defined with the required number of extra cycles.

# Modules with simulation files added automatically
Define and export the following environgment variables to have these
modules added to your simulation when using sim.sh

YM2203
YM2149
YM2151
MSM5205
M6801
M6809
I8051

Many modules are also added depending on the contents of the project qip file.