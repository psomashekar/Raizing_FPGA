# IOCTL Indexes

For I/O (SDRAM download, etc.) the following indexes are used

 Purpose          | MiST   | MiSTer
------------------|--------|--------
 Main ROM         |   0    |    0
 JTFRAME options  |   1    |    1
 NVRAM            | 255    |    2
 Cheat ROM        |  16    |   16
 Beta keys        |  N/A   |   17
 DIP switches     |  N/A   |  254
 Cheat switches   |  N/A   |  255

## core_mod (JTFRAME options)

Bit    |  Use
-------|---------
0      | High for vertical games
1      | 4-way joysticks

If JTFRAME_VERTICAL is defined, bit 0 is set during power up. The contents of core_mod can be set by defining a index=1 rom in the MRA file.

## Saving Data to the SD Card

It is possible to save information on the SD card. You have to follow these steps:

1. Define the macro **JTFRAME_IOCTL_RD** with the size of the dump
2. Define the **ioctl_ram** input signal and the 8-bit **ioctl_din** output bus as ports in the game module
3. Add a `<nvram index="2" size="your data size"/>` element to the MRA

When **ioctl_ram** is high, JTFRAME expects **ioctl_din** to have the contents matching the address at **ioctl_addr**. There is no read strobe and read speed is controlled by the platform firmware, so it may be too fast for direct dumping off the SDRAM contents. Note that **ioctl_ram** is also high when the firmware is sending the NVRAM data to the core during the downloading phase. You can distinguish between the two scenarios by checking the **downloading** signal.

The write operation is triggered from the OSD *save settings* (MiSTer) or *Save NVRAM* (MiST) option.

The TOML file for MRA generation supports a *nvram=size* statement in the *features* section. The value of **JTFRAME_IOCTL_RD** is only used in MiST. For MiSTer, it is enough to define the macro.

### Automatic SDRAM Dump

A fraction of bank zero's SDRAM contents can be dumped to the micro SD card on MiSTer using the NVRAM interface. You have to define two macros:

```
JTFRAME_SHADOW=0x10_0000
JTFRAME_SHADOW_LEN=10
```

The first one defines the start address, and the second the number of address bits to dump. The example above will dump 1k-word, i.e. 2kByte.

The MRA file must include `<nvram index="2" size="2048"/>`. MiSTer will create a dump file each time the `save settings` option is selected in the OSD.

At the time of writting, MiSTer firmware doesn't handle correctly NVRAM sizes equal or above 64kB.

# SDRAM Timing

SDRAM clock can be shifted with respect to the internal clock (clk_rom in the diagram).

![SDRAM clock forwarded](sdram_adv.png)

![SDRAM clock forwarded](sdram_dly.png)

# SDRAM Controller

There are three different SDRAM controllers in JTFRAME. They all work and are stable, however only the latest one is connected to jtframe_board. The others are left for reference.

## JTFRAME_SDRAM

**jtframe_sdram** is a generic SDRAM controller that runs upto 48MHz because it is designed for CL=2. It mainly serves for reading ROMs from the SDRAM but it has some support for writting (apart from the initial ROM download process).

This module may result in timing errors in MiSTer because sometimes the compiler does not assign the input flip flops from SDRAM_DQ at the pads. In order to avoid this, you can define the macro **JTFRAME_SDRAM_REPACK**. This will add one extra stage of data latching, which seems to allow the fitter to use the pad flip flops. This does delay data availability by one clock cycle. Some cores in MiSTer do synthesize with pad FF without the need of this option. Use it if you find setup timing violation about the SDRAM_DQ pins.

SDRAM is treated in top level modules as a read-only memory (except for the download process). If the game core needs to write to the SDRAM the **JTFRAME_WRITEBACK** macro must be defined.

By default only the first bank of the SDRAM is used, allowing for 8MB of data organized in 4 M x 16bits. In order to enable access to the other three banks the macro **JTFRAME_SDRAM_BANKS** is used. Once this macro is defined the game module is expected to provide the following signals

[1:0] prog_bank     bank used during SDRAM programming
[1:0] sdram_bank    bank used during regular SDRAM use

These signals should be used in combination with the rest of prog_ and sdram_ signals in order to control the SDRAM.

The data bus is held down all the time and only released when the SDRAM is expected to use it. This behaviour can be reverted using **JTFRAME_NOHOLDBUS**. When this macro is defined, the bus will only be held while writting data and released the rest of the time. For 48MHz operation, holding the bus works better. For 96MHz it doesn't seem to matter.

In simulation data from the SDRAM can be double checked in the jtframe_rom/ram_xslots modules if **JTFRAME_SDRAM_CHECK** is defined. The simulation will stop if the read data does not meet the expected values.

## JTFRAME_SDRAM_BANK

**jtframe_sdram_bank**  is a high-performance SDRAM controller that achieves high data throughput by using bank interleaving.

HF parameter should be set high if the clock frequency is above 64MHz

Performance results (MiST)

Frequency  |  Efficiency  |  Data throughput  | Latency (min)  | Latency (ave) | Latency (max)
-----------|--------------|-------------------|----------------|---------------|---------------
<64MHz     |  100%        | f*2     =128MB/s  |    7 (109ns)   |    9 (140ns)  |    29 (453ns)
96MHz      |  66.7%       | f*2*.667=128MB/s  |    9 ( 73ns)   |   11 (114ns)  |    30 (312ns)

Performance results (MiSTer - A lines shorted to DQM)

Frequency  |  Efficiency  |  Data throughput  | Latency (min)  | Latency (ave) | Latency (max)
-----------|--------------|-------------------|----------------|---------------|---------------
<64MHz     |   72%        | f*2*.72 = 92MB/s  |    7 (109ns)   |    9 (140ns)  |    32 (500ns)
96MHz      |   53.3%      | f*2*.533=102MB/s  |    9 ( 73ns)   |   12 (125ns)  |    36 (375ns)

Note that latency results are simulated with refresh and write cycles enabled.

## SDRAM Catalogue

ID  | Part No          | Units | Size
----|------------------|-------|-----
  1 | AS4C32M16SB-6TIN |    2  | 128
  2 | W9825G6KH-6      |    1  |  32
  3 | AS4C16M16SA-6TCN |    1  |  32
  4 | AS4C32M16SB-7TCN |    2  | 128
  5 | W9825G6KH-6      |    1  |  32
  6 | AS4C32M8SA -7TCN |    2  |  64
  7 | AS4C32M8SA -7TCN |    4  | 128
8,9 | AS4C32M16SB-6TIN |    2  | 128

All time values in ns, capacitance in pF

Part No           | Op. Current (mA) | Ci     | Ci/o | tRRD  | tRP    | tAC CL=2 | tOH | tHZ
------------------|------------------|--------|------|-------|--------|----------|-----|-----
AS4C16M16SA -6/-7 |  60/55 (1 bank)  | 2-4    |  4-6 | 12/14 | 18/21  | 6/6      | 2.5 | 5/5.4
AS4C32M16SA -6/-7 | 120/110(1 bank)  |3.5-5.5 |  4-6 | 12/14 | 18/21  | 6/6      | 2.5 | 5/5.4
AS4C32M8SA  -6/-7 |  60/55 (1 bank)  | 2-4    |  4-6 | 12/14 | 18/21  | 6/6      | 2.5 | 5/5.4
W9825G6KH-6       |   60             | <3.8   | <6.5 |  15   |  15    | 6        |  3  | 6

## Maximum Current (MiST)

MiST uses a single SDRAM module, with about 4pF per pin. In order to charge it up to 3.3V in 4ns we need 3.3mA. Current per pin is limited to 4mA in order to prevent noise.

## SDRAM Header (MiSTer)

Pin view with SDRAM on top, ethernet cable on the bottom right

DQ1 DQ3 DQ5 DQ7 DQ14 NC  DQ13 DQ11 DQ9 DQ12  A9 A7 A5 WE VDD CAS CS1 BA1 BA0 A2
DQ0 DQ2 DQ4 DQ6 DQ15 GND DQ12 DQ10 DQ3 CLK  A11 A8 A6 A4 GND RAS BA0 A10 A1  A3

## SDRAM Electrical Problems (MiSTer)

On MiSTer SDRAM modules as of December 2020 have a severe VDD ripple. VDD can go above 4V and reach 2.4V. 32MB modules are slightly better.

MiSTer SDRAM modules also suffer of intersymbol interference. Although it is not clear which lines couple more closely -no layout parasitics for any board are available- setting the DQ bus from the FPGA for a write at the time of RAS showed worse results than setting it at CAS time for Contra core using the sdram_bank controller (based on 7e93cc5 commit).

Measurements of A3 line and VDD (SDRAM module #4 with 10uF electrolytic added):

Slew Rate  |  Max V(A3)  | Min V(A3)  | tr/tf (ns)
-----------|-------------|------------|-----------
Fast (2)   | 3.92        | -0.92      |  3
Slow (0)   | 3.76        | -0.60      |  4

VDD ripple also improves with slower slew rates (module #8):

Slew Rate  | Max VDD  | Min VDD
-----------|----------|---------
Fast (2)   |   4.12   |  2.58
Slow (0)   |   3.98   |  2.74


Using the slowest slew rate fixes Contra load on all tested modules, regardless of when DQ is set at write time:

Module | DQ at RAS   |  DQ at CAS
-------|-------------|-------------
       | fast | slow | fast | slow
-------|------|------|------|------
1      |  NG  | OK   | OK   |  OK
2      |  NG  | OK   | NG   |  OK
3      |  OK  | OK   | NG   |  OK
4      |  NG  | OK   | OK   |  OK
7      |  NG  | OK   | NG   |  OK
8      |  NG  | OK   | OK   |  OK
9      |  NG  | OK   | OK   |  OK
-------|------|------|------|------
Fails  |   6  |  0   |  3   |   0

Faster slew rates mean more current going through the connector, thus more ripple at both the signal pin and VDD. So both problems become better. This doesn't mean they are completely solved. VDD ripple is still out of spec with the current capacitor set used. And slowing down further the bus should also help.

## SDRAM Clock Shift

I made a clock shift sweep using JTCONTRA commit 5633ee41. These are the results of valid values:

Module | Min  |  Max  | Remarks
-------|------|-------|---------
1      | 3.5  | 8.25  |
2      | 2.5  | 8.5   | 32MB
3      | 2.5  | 8.75  | 32MB
4      | 3.0  | 8.0   | 10uF added
7      | 4.0  | 8.25  | min improved to 3.5ns by adding 33uF
8      | 3.5  | 8.0   |
9      | 3.25 | 8.25  |
AV sys | 3.0  | 8.25  | Same results with fan on/off

The wider the difference is between max and min, the cleaner signals are.

Most cores in the official MiSTer repository seem to use a strategy of a full 180º clock shift. This has the advantage of providing an accurate value of the clock at the pin as it can be generated using an IO primitive. However, it means that the last word of the burst is read with the bus at high impedance, so it has a higher potential for failures. It helps when timing cannot be met as it simplifies internal routing. Enable it with **JTFRAME_180SHIFT**