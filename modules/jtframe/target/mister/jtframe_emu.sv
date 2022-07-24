//============================================================================
//  JTFRAME by Jose Tejada Gomez. Twitter: @topapate
//
//  Port to MiSTer
//  Thanks to Sorgelig for his continuous support
//  Original repository: http://github.com/jotego/jt_gng
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

`ifdef JTFRAME_VERTICAL
`define JTFRAME_MR_DDR
`endif

`ifdef JTFRAME_MR_DDRLOAD
`define JTFRAME_MR_DDR
`endif

module emu
(
    //Master input clock
    input         CLK_50M,

    //Async reset from top-level module.
    //Can be used as initial reset.
    input         RESET,

    //Must be passed to hps_io module
    inout  [48:0] HPS_BUS,

    //Base video clock. Usually equals to CLK_SYS.
    output        CLK_VIDEO,

    //Multiple resolutions are supported using different CE_PIXEL rates.
    //Must be based on CLK_VIDEO
    output        CE_PIXEL,

    output  [7:0] VGA_R,
    output  [7:0] VGA_G,
    output  [7:0] VGA_B,
    output        VGA_HS,
    output        VGA_VS,
    output        VGA_DE,    // = ~(VBlank | HBlank)
    output        VGA_F1,
    output  [1:0] VGA_SL,
    output        VGA_SCALER,

    input  [11:0] HDMI_WIDTH,
    input  [11:0] HDMI_HEIGHT,
    output        HDMI_FREEZE,

    //Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
    output [12:0] VIDEO_ARX,
    output [12:0] VIDEO_ARY,

    output        LED_USER,  // 1 - ON, 0 - OFF.

    // b[1]: 0 - LED status is system status OR'd with b[0]
    //       1 - LED status is controled solely by b[0]
    // hint: supply 2'b00 to let the system control the LED.
    output  [1:0] LED_POWER,
    output  [1:0] LED_DISK,

    // I/O board button press simulation (active high)
    // b[1]: user button
    // b[0]: osd button
    // output  [1:0] BUTTONS,

    input         CLK_AUDIO,
    output reg [15:0] AUDIO_L,
    output reg [15:0] AUDIO_R,
    output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned

    //SDRAM interface with lower latency
    output        SDRAM_CLK,
    output        SDRAM_CKE,
    output [12:0] SDRAM_A,
    output [ 1:0] SDRAM_BA,
    inout  [15:0] SDRAM_DQ,
    output        SDRAM_DQML,
    output        SDRAM_DQMH,
    output        SDRAM_nCS,
    output        SDRAM_nCAS,
    output        SDRAM_nRAS,
    output        SDRAM_nWE,

    `ifdef JTFRAME_VERTICAL
    output        FB_EN,
    output [ 4:0] FB_FORMAT,
    output [11:0] FB_WIDTH,
    output [11:0] FB_HEIGHT,
    output [31:0] FB_BASE,
    output [13:0] FB_STRIDE,
    input         FB_VBL,
    input         FB_LL,
    output        FB_FORCE_BLANK,

    // Palette control for 8bit modes.
    // Ignored for other video modes.
    output        FB_PAL_CLK,
    output [ 7:0] FB_PAL_ADDR,
    output [23:0] FB_PAL_DOUT,
    input  [23:0] FB_PAL_DIN,
    output        FB_PAL_WR,
`endif

    output        DDRAM_CLK,
    input         DDRAM_BUSY,
    output [ 7:0] DDRAM_BURSTCNT,
    output [28:0] DDRAM_ADDR,
    input  [63:0] DDRAM_DOUT,
    input         DDRAM_DOUT_READY,
    output        DDRAM_RD,
    output [63:0] DDRAM_DIN,
    output [ 7:0] DDRAM_BE,
    output        DDRAM_WE,

    // Open-drain User port.
    // 0 - D+/RX
    // 1 - D-/TX
    // 2..6 - USR2..USR6
    // Set USER_OUT to 1 to read from USER_IN.
    input   [6:0] USER_IN,
    output  [6:0] USER_OUT,
    output        db15_en,
    output        uart_en,
    output        show_osd
    `ifdef SIMULATION
    ,output       sim_pxl_cen,
    output        sim_pxl_clk,
    output        sim_vb,
    output        sim_hb
    `endif
);

`ifdef JTFRAME_SDRAM_LARGE
    localparam SDRAMW=23; // 64 MB
`else
    localparam SDRAMW=22; // 32 MB
`endif

`ifndef JTFRAME_INTERLACED
assign VGA_F1=1'b0;
`else
wire   field;
assign VGA_F1=field;
`endif

assign VGA_SCALER = 0;
assign HDMI_FREEZE = 0;

wire [3:0] hoffset, voffset;

////////////////////   CLOCKS   ///////////////////

wire clk_sys, clk_rom, clk96, clk96sh, clk48, clk48sh, clk24, clk6;
wire game_rst, game_service, rst, rst_n;
wire clk_pico;
wire pxl2_cen, pxl_cen;
wire rst96, rst48, rst24, rst6;
wire pll_locked;
reg  pll_rst = 1'b0;
wire sys_rst;

// Resets the PLL if it looses lock
jtframe_sync u_sync(
    .clk_in     ( CLK_50M   ),
    .clk_out    ( clk_sys   ),
    .raw        ( RESET     ),
    .sync       ( sys_rst   )
);

always @(posedge clk_sys or posedge sys_rst) begin : pll_controller
    reg last_locked;
    reg [7:0] rst_cnt;

    if( sys_rst ) begin
        pll_rst <= 1'b0;
        rst_cnt <= 8'hd0;
    end else begin
        last_locked <= pll_locked;
        if( last_locked && !pll_locked ) begin
            rst_cnt <= 8'hff; // keep reset high for 256 cycles
            pll_rst <= 1'b1;
        end else begin
            if( rst_cnt != 8'h00 )
                rst_cnt <= rst_cnt - 8'h1;
            else
                pll_rst <= 1'b0;
        end
    end
end

`ifndef JTFRAME_PLL
    `define JTFRAME_PLL pll
`endif

// There are many false paths defined in the
// SDC file between this PLL and the ones
// used in sys_top
`JTFRAME_PLL pll(
    .refclk     ( CLK_50M    ),
    .rst        ( pll_rst    ),
    .locked     ( pll_locked ),
    .outclk_0   ( clk48      ),
    .outclk_1   ( clk48sh    ),
    .outclk_2   ( clk24      ),
    .outclk_3   ( clk6       ),
    .outclk_4   ( clk96      ),
    .outclk_5   ( clk96sh    )
);

jtframe_rst_sync u_reset96(
    .rst        ( game_rst  ),
    .clk        ( clk96     ),
    .rst_sync   ( rst96     )
);

jtframe_rst_sync u_reset48(
    .rst        ( game_rst  ),
    .clk        ( clk48     ),
    .rst_sync   ( rst48     )
);

jtframe_rst_sync u_reset24(
    .rst        ( game_rst  ),
    .clk        ( clk24     ),
    .rst_sync   ( rst24     )
);

jtframe_rst_sync u_reset6(
    .rst        ( game_rst ),
    .clk        ( clk6     ),
    .rst_sync   ( rst6     )
);

`ifdef JTFRAME_SDRAM96
    assign clk_rom = clk96;
    assign clk_sys = clk96;
`else
    assign clk_rom = clk48;
    `ifdef JTFRAME_CLK96
    assign clk_sys = clk96;
    `else
    assign clk_sys = clk48;
    `endif
`endif

assign clk_pico = clk48;

`ifndef JTFRAME_180SHIFT
    `ifdef JTFRAME_SDRAM96
    assign SDRAM_CLK   = clk96sh;
    `else
    assign SDRAM_CLK   = clk48sh;
    `endif
`else
    altddio_out
    #(
        .extend_oe_disable("OFF"),
        .intended_device_family("Cyclone V"),
        .invert_output("OFF"),
        .lpm_hint("UNUSED"),
        .lpm_type("altddio_out"),
        .oe_reg("UNREGISTERED"),
        .power_up_high("OFF"),
        .width(1)
    )
    sdramclk_ddr
    (
        .datain_h(1'b0),
        .datain_l(1'b1),
        .outclock(clk_rom),
        .dataout(SDRAM_CLK),
        .aclr(1'b0),
        .aset(1'b0),
        .oe(1'b1),
        .outclocken(1'b1),
        .sclr(1'b0),
        .sset(1'b0)
    );
`endif

///////////////////////////////////////////////////

wire [63:0] status;
wire [ 1:0] buttons, game_led;

wire [ 1:0] dip_fxlevel;
wire        enable_fm, enable_psg;
wire        dip_pause, dip_flip, dip_test;
wire [31:0] dipsw;

wire        ioctl_wr;
wire [26:0] ioctl_addr; // up to 128MB
wire [ 7:0] ioctl_dout, ioctl_din;

wire [ 9:0] game_joy1, game_joy2, game_joy3, game_joy4;
wire [ 3:0] game_coin, game_start;
wire [ 3:0] gfx_en;
wire [ 7:0] debug_bus, debug_view;
wire [15:0] joyana_l1, joyana_l2, joyana_l3, joyana_l4,
            joyana_r1, joyana_r2, joyana_r3, joyana_r4;

wire        rst_req   = sys_rst | status[0] | buttons[1];
wire [15:0] snd_left, snd_right;

assign LED_DISK  = 2'b0;
assign LED_POWER = 2'b0;

// ROM download
wire          downloading, dwnld_busy;

wire [SDRAMW-1:0] prog_addr;
wire [15:0]   prog_data;
`ifndef JTFRAME_SDRAM_BANKS
wire [ 7:0]   prog_data8;
`endif
wire [ 1:0]   prog_mask, prog_ba;
wire          prog_we, prog_rd, prog_rdy, prog_ack, prog_dst, prog_dok;

// ROM access from game
wire [SDRAMW-1:0] ba0_addr, ba1_addr, ba2_addr, ba3_addr;
wire [ 3:0] ba_rd, ba_rdy, ba_ack, ba_dst, ba_dok;
wire        ba_wr;
wire [15:0] ba0_din;
wire [ 1:0] ba0_din_m;
wire [15:0] sdram_dout;

`ifndef JTFRAME_SDRAM_BANKS
    // tie down unused bank signals
    assign prog_data  = {2{prog_data8}};
    assign ba_rd[3:1] = 0;
    assign ba_wr      = 0;
    assign prog_ba    = 0;
    assign ba1_addr   = 0;
    assign ba2_addr   = 0;
    assign ba3_addr   = 0;
    assign ba0_din    = 0;
    assign ba0_din_m  = 3;
`endif

wire [ 7:0] st_addr, st_dout;
wire [15:0] mouse_1p, mouse_2p;

`ifndef JTFRAME_COLORW
`define JTFRAME_COLORW 4
`endif

`ifndef JTFRAME_BUTTONS
`define JTFRAME_BUTTONS 2
`endif

localparam COLORW=`JTFRAME_COLORW;
localparam GAME_BUTTONS=`JTFRAME_BUTTONS;

wire [COLORW-1:0] game_r, game_g, game_b;
wire              LHBL, LVBL;
wire              hs, vs, sample;
wire              ioctl_ram;
wire              game_rx, game_tx;

assign game_led[1] = 1'b1;

`ifndef JTFRAME_UART
    assign game_tx = 1;
`endif

`ifndef JTFRAME_SIGNED_SND
assign AUDIO_S = 1'b1; // Assume signed by default
`else
assign AUDIO_S = `JTFRAME_SIGNED_SND;
`endif

`ifndef JTFRAME_SDRAM_BANKS
assign prog_data = {2{prog_data8}};
`endif

reg pxl1_cen;

// this places the pxl1_cen in the pixel centre
always @(posedge clk_sys) pxl1_cen <= pxl2_cen & ~pxl_cen;

jtframe_mister #(
    .SDRAMW        ( SDRAMW         ),
    .BUTTONS       ( GAME_BUTTONS   ),
    .COLORW        ( COLORW         )
    `ifdef JTFRAME_WIDTH
    ,.VIDEO_WIDTH  ( `JTFRAME_WIDTH   )
    `endif
    `ifdef JTFRAME_HEIGHT
    ,.VIDEO_HEIGHT ( `JTFRAME_HEIGHT  )
    `endif
)
u_frame(
    .clk_sys        ( clk_sys        ),
    .clk_rom        ( clk_rom        ),
    .clk_pico       ( clk_pico       ),
    .pll_locked     ( pll_locked     ),
    // interface with microcontroller
    .status         ( status         ),
    .HPS_BUS        ( HPS_BUS        ),
    .buttons        ( buttons        ),
    // LED
    .game_led       ( game_led       ),
    // Extension port (fake USB3)
    .USER_OUT       ( USER_OUT       ),
    .USER_IN        ( USER_IN        ),
    .db15_en        ( db15_en        ),
    .uart_en        ( uart_en        ),
    .game_rx        ( game_rx        ), // core-specific UART
    .game_tx        ( game_tx        ),
    .show_osd       ( show_osd       ),
    // Base video
    .game_r         ( game_r         ),
    .game_g         ( game_g         ),
    .game_b         ( game_b         ),
    .LHBL           ( LHBL           ),
    .LVBL           ( LVBL           ),
    .hs             ( hs             ),
    .vs             ( vs             ),
    .pxl_cen        ( pxl1_cen       ),
    .pxl2_cen       ( pxl2_cen       ),

    // Audio
    .snd_lin        ( snd_left       ),
    .snd_rin        ( snd_right      ),
    .snd_sample     ( sample         ),
    .snd_rout       ( AUDIO_R        ),
    .snd_lout       ( AUDIO_L        ),

    `ifdef JTFRAME_VERTICAL
    // Screen rotation
    .FB_EN          ( FB_EN          ),
    .FB_FORMAT      ( FB_FORMAT      ),
    .FB_WIDTH       ( FB_WIDTH       ),
    .FB_HEIGHT      ( FB_HEIGHT      ),
    .FB_BASE        ( FB_BASE        ),
    .FB_STRIDE      ( FB_STRIDE      ),
    .FB_VBL         ( FB_VBL         ),
    .FB_LL          ( FB_LL          ),
    .FB_FORCE_BLANK ( FB_FORCE_BLANK ),

    .FB_PAL_CLK     ( FB_PAL_CLK     ),
    .FB_PAL_ADDR    ( FB_PAL_ADDR    ),
    .FB_PAL_DOUT    ( FB_PAL_DOUT    ),
    .FB_PAL_DIN     ( FB_PAL_DIN     ),
    .FB_PAL_WR      ( FB_PAL_WR      ),
    `endif

    // DDR interface
    .DDRAM_CLK      ( DDRAM_CLK      ), // same as clk_rom
    .DDRAM_BURSTCNT ( DDRAM_BURSTCNT ),
    .DDRAM_ADDR     ( DDRAM_ADDR     ),
    .DDRAM_BE       ( DDRAM_BE       ),
    .DDRAM_WE       ( DDRAM_WE       ),
    .DDRAM_BUSY     ( DDRAM_BUSY     ),
    .DDRAM_DOUT_READY(DDRAM_DOUT_READY ),
    .DDRAM_DOUT     ( DDRAM_DOUT     ),
    .DDRAM_RD       ( DDRAM_RD       ),
    .DDRAM_DIN      ( DDRAM_DIN      ),

    // SDRAM interface
    .SDRAM_CLK      ( SDRAM_CLK      ),
    .SDRAM_DQ       ( SDRAM_DQ       ),
    .SDRAM_A        ( SDRAM_A        ),
    .SDRAM_DQML     ( SDRAM_DQML     ),
    .SDRAM_DQMH     ( SDRAM_DQMH     ),
    .SDRAM_nWE      ( SDRAM_nWE      ),
    .SDRAM_nCAS     ( SDRAM_nCAS     ),
    .SDRAM_nRAS     ( SDRAM_nRAS     ),
    .SDRAM_nCS      ( SDRAM_nCS      ),
    .SDRAM_BA       ( SDRAM_BA       ),
    .SDRAM_CKE      ( SDRAM_CKE      ),
    // ROM access from game
    .ba0_addr   ( ba0_addr      ),
    .ba1_addr   ( ba1_addr      ),
    .ba2_addr   ( ba2_addr      ),
    .ba3_addr   ( ba3_addr      ),
    .ba_rd      ( ba_rd         ),
    .ba_wr      ({ 3'd0, ba_wr }),
    .ba_dst     ( ba_dst        ),
    .ba_dok     ( ba_dok        ),
    .ba_rdy     ( ba_rdy        ),
    .ba_ack     ( ba_ack        ),
    .ba0_din    ( ba0_din       ),
    .ba0_din_m  ( ba0_din_m     ),  // write mask

    // ROM-load interface
    .prog_addr  ( prog_addr     ),
    .prog_ba    ( prog_ba       ),
    .prog_rd    ( prog_rd       ),
    .prog_we    ( prog_we       ),
    .prog_data  ( prog_data     ),
    .prog_mask  ( prog_mask     ),
    .prog_ack   ( prog_ack      ),
    .prog_dst   ( prog_dst      ),
    .prog_dok   ( prog_dok      ),
    .prog_rdy   ( prog_rdy      ),

    .sdram_dout     ( sdram_dout     ),

    // ROM load
    .ioctl_addr     ( ioctl_addr     ),
    .ioctl_dout     ( ioctl_dout     ),
    .ioctl_rom_wr   ( ioctl_wr       ),
    .ioctl_ram      ( ioctl_ram      ),
    .ioctl_din      ( ioctl_din      ),

    .downloading    ( downloading    ),
    .dwnld_busy     ( dwnld_busy     ),
//////////// board
    .rst            ( rst            ),
    .rst_n          ( rst_n          ), // unused
    .game_rst       ( game_rst       ),
    .game_rst_n     (                ),
    // reset forcing signals:
    .rst_req        ( rst_req        ),
    // joystick
    .game_joystick1 ( game_joy1      ),
    .game_joystick2 ( game_joy2      ),
    .game_joystick3 ( game_joy3      ),
    .game_joystick4 ( game_joy4      ),
    .game_coin      ( game_coin      ),
    .game_start     ( game_start     ),
    .game_service   ( game_service   ),
    .joyana_l1      ( joyana_l1      ),
    .joyana_l2      ( joyana_l2      ),
    .joyana_l3      ( joyana_l3      ),
    .joyana_l4      ( joyana_l4      ),
    .joyana_r1      ( joyana_r1      ),
    .joyana_r2      ( joyana_r2      ),
    .joyana_r3      ( joyana_r3      ),
    .joyana_r4      ( joyana_r4      ),
    // Mouse inputs
    .mouse_1p       ( mouse_1p       ),
    .mouse_2p       ( mouse_2p       ),
    .LED            ( LED_USER       ),
    // DIP and OSD settings
    .enable_fm      ( enable_fm      ),
    .enable_psg     ( enable_psg     ),
    .dip_test       ( dip_test       ),
    .dip_pause      ( dip_pause      ),
    .dip_flip       ( dip_flip       ),
    .dip_fxlevel    ( dip_fxlevel    ),
    .dipsw          ( dipsw          ),
    // screen
    .rotate         (                ),
    // HDMI
    .hdmi_arx       ( VIDEO_ARX      ),
    .hdmi_ary       ( VIDEO_ARY      ),
    .hdmi_width     ( HDMI_WIDTH     ),
    .hdmi_height    ( HDMI_HEIGHT    ),
    // scan doubler output to VGA pins
    .scan2x_r       ( VGA_R          ),
    .scan2x_g       ( VGA_G          ),
    .scan2x_b       ( VGA_B          ),
    .scan2x_hs      ( VGA_HS         ),
    .scan2x_vs      ( VGA_VS         ),
    .scan2x_clk     ( CLK_VIDEO      ),
    .scan2x_cen     ( CE_PIXEL       ),
    .scan2x_de      ( VGA_DE         ),
    .scan2x_sl      ( VGA_SL         ),
    // status
    .st_addr        ( st_addr        ),
    .st_dout        ( st_dout        ),
    // Debug
    .gfx_en         ( gfx_en         ),
    .debug_bus      ( debug_bus      ),
    .debug_view     ( debug_view     )
);

`ifdef SIMULATION
assign sim_hb = ~LHBL;
assign sim_vb = ~LVBL;
assign sim_pxl_clk = clk_sys;
assign sim_pxl_cen = pxl_cen;
`endif

///////////////////////////////////////////////////////////////////

`ifdef SIMULATION
assign sim_pxl_clk = clk_sys;
assign sim_pxl_cen = pxl_cen;
`endif

`GAMETOP u_game
(
    .rst          ( game_rst         ),
    // clock inputs
    // By default clk is 48MHz, but JTFRAME_CLK96 overrides it to 96MHz
    .clk          ( clk_rom          ),
`ifdef JTFRAME_CLK96
    .clk96        ( clk96            ),
    .rst96        ( rst96            ),
`endif
`ifdef JTFRAME_CLK48
    .clk48        ( clk48            ),
    .rst48        ( rst48            ),
`endif
`ifdef JTFRAME_CLK24
    .clk24        ( clk24            ),
    .rst24        ( rst24            ),
`endif
`ifdef JTFRAME_CLK6
    .clk6         ( clk6             ),
    .rst6         ( rst6             ),
`endif
    .pxl2_cen     ( pxl2_cen         ),
    .pxl_cen      ( pxl_cen          ),

    .red          ( game_r           ),
    .green        ( game_g           ),
    .blue         ( game_b           ),
    .LHBL         ( LHBL             ), // Final timing
    .LVBL         ( LVBL             ),
    .HS           ( hs               ),
    .VS           ( vs               ),
`ifdef JTFRAME_INTERLACED
    .field        ( field            ),
`endif
    // LED
    .game_led    ( game_led[0]    ),

    .start_button ( game_start       ),
    .coin_input   ( game_coin        ),
    // Joysticks
    .joystick1    ( game_joy1[GAME_BUTTONS+3:0]   ),
    .joystick2    ( game_joy2[GAME_BUTTONS+3:0]   ),
    `ifdef JTFRAME_4PLAYERS
    .joystick3    ( game_joy3[GAME_BUTTONS+3:0]   ),
    .joystick4    ( game_joy4[GAME_BUTTONS+3:0]   ),
    `endif
`ifdef JTFRAME_MOUSE
    .mouse_1p     ( mouse_1p         ),
    .mouse_2p     ( mouse_2p         ),
`endif
`ifdef JTFRAME_ANALOG
    .joyana_l1    ( joyana_l1        ),
    .joyana_l2    ( joyana_l2        ),
    `ifdef JTFRAME_ANALOG_DUAL
        .joyana_r1    ( joyana_r1        ),
        .joyana_r2    ( joyana_r2        ),
    `endif
    `ifdef JTFRAME_4PLAYERS
        .joyana_l3( joyana_l3        ),
        .joyana_l4( joyana_l4        ),
        `ifdef JTFRAME_ANALOG_DUAL
            .joyana_r3( joyana_r3        ),
            .joyana_r4( joyana_r4        ),
        `endif
    `endif
`endif
    // Sound control
    .enable_fm    ( enable_fm        ),
    .enable_psg   ( enable_psg       ),
    // PROM programming
    .ioctl_addr   ( ioctl_addr       ),
    .ioctl_dout   ( ioctl_dout       ),
    .ioctl_wr     ( ioctl_wr         ),
`ifdef JTFRAME_IOCTL_RD
    .ioctl_ram    ( ioctl_ram        ),
    .ioctl_din    ( ioctl_din        ),
`endif

    // ROM load
    .downloading ( downloading    ),
    .dwnld_busy  ( dwnld_busy     ),
    .data_read   ( sdram_dout     ),

`ifdef JTFRAME_SDRAM_BANKS
    // Bank 0: allows R/W
    .ba0_addr   ( ba0_addr      ),
    .ba1_addr   ( ba1_addr      ),
    .ba2_addr   ( ba2_addr      ),
    .ba3_addr   ( ba3_addr      ),
    .ba_rd      ( ba_rd         ),
    .ba_wr      ( ba_wr         ),
    .ba_dst     ( ba_dst        ),
    .ba_dok     ( ba_dok        ),
    .ba_rdy     ( ba_rdy        ),
    .ba_ack     ( ba_ack        ),
    .ba0_din    ( ba0_din       ),
    .ba0_din_m  ( ba0_din_m     ),  // write mask

    .prog_ba    ( prog_ba       ),
    .prog_rdy   ( prog_rdy      ),
    .prog_ack   ( prog_ack      ),
    .prog_dok   ( prog_dok      ),
    .prog_dst   ( prog_dst      ),
    .prog_data  ( prog_data     ),
`else
    .sdram_req  ( ba_rd[0]      ),
    .sdram_addr ( ba0_addr      ),
    .data_dst   ( ba_dst[0] | prog_dst ),
    .data_rdy   ( ba_rdy[0] | prog_rdy ),
    .sdram_ack  ( ba_ack[0] | prog_ack ),

    .prog_data  ( prog_data8    ),
`endif

    // common ROM-load interface
    .prog_addr  ( prog_addr     ),
    .prog_rd    ( prog_rd       ),
    .prog_we    ( prog_we       ),
    .prog_mask  ( prog_mask     ),

    // DIP switches
    .status       ( status           ),
    .service      ( game_service     ),
    .dip_pause    ( dip_pause        ),
    .dip_flip     ( dip_flip         ),
    .dip_test     ( dip_test         ),
    .dip_fxlevel  ( dip_fxlevel      ),
    .dipsw        ( dipsw            ),

`ifdef JTFRAME_UART
    .uart_tx      ( game_tx          ),
    .uart_rx      ( game_rx          ),
`endif

`ifdef STEREO_GAME
    .snd_left     ( snd_left         ),
    .snd_right    ( snd_right        ),
`else
    .snd          ( snd_left         ),
`endif
    // unconnected
    .sample       ( sample           ),

    `ifdef JTFRAME_STATUS
        .st_addr  ( st_addr          ),
        .st_dout  ( st_dout          ),
    `endif
    .gfx_en       ( gfx_en           )
    `ifdef JTFRAME_DEBUG
    ,.debug_bus   ( debug_bus        )
    ,.debug_view  ( debug_view       )
    `endif);

`ifndef STEREO_GAME
    assign snd_right = snd_left;
`endif

`ifdef SIMULATION
integer fsnd;
initial begin
    fsnd=$fopen("sound.raw","wb");
end
always @(posedge sample) begin
    $fwrite(fsnd,"%u", {AUDIO_L, AUDIO_R});
end
`endif

endmodule
