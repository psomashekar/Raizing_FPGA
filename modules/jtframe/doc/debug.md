# Debugging

If JTFRAME_RELEASE is not defined, the debug features can be used. Also check [the NVRAM saving](doc/sdram.md) procedure as it can be useful for debugging.

## GFX Enable Bus

keys F7-F10 will toggle bits in the gfx_en bus. After reset all bits are high. These bits are meant to be used to enable/disable graphic layers.

## Generic 8-bit Debug bus

If JTFRAME_DEBUG is defined, keys + and - (in a Spanish keyboard layout) will increase and decrease the 8-bit debug_bus.

By default, debug_bus is increased (decreased) by 1. If SHIFT is pressed with +/-, then the step is 16 instead. This can be used to control different signals with each *debug_bus* nibble. However, the bus is always increased as a byte, so be aware of it. Pressing CTRL with +/- will reset the *debug_bus* to zero. Press shift+1-0 keys (main keyboard, not keypad) to individually togle each bit of the debug bus.

The game module must define the *debug_bus* input if **JTFRAME_DEBUG** is used. Becareful because if you don't define JTFRAME_DEBUG and use the *debug_bus* in the game module, Quartus will not warn you of the missing connection and you may get unexpected behaviour after synthesis.

The game must also define an output bus called *debug_view*, which will be shown on screen, binary encoded. This is a quick way to check signal values. Assign it to 8'h0 if you don't need it. For most sophisticated probe needs, it is better to use the [cheat engine](cheat.md) or the FPGA signal tap facilities.

It is recommended to remove the *debug_bus* once the core is stable. When the core is compiled with **JTFRAME_RELEASE** the *debug_bus* has a permanent zero value and there is no on-screen debug values.

## Generic SDRAM Dump

The SDRAM bank0 can be partially shadowed in BRAM and download as NVRAM via the NVRAM interface. This requires the macros JTFRAME_SHADOW and JTFRAME_SHADOW_LEN to be defined. The MRA file should also enable NVRAM with a statement such as:

```
<nvram index="2" size="1024"/>
```

It is not possible to use JTFRAME_SHADOW and JTFRAME_IOCTL_RD at the same time.

## Frequency counter

Sometimes it is useful to measure an internal frequency. The module [jtframe_freqinfo](../hdl/clocking/jtframe_freqinfo.v) provides this information. It needs to know the clock frequency in kHz and it provides the measured frequency in kHz too.