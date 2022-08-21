/*
* <-- pr4m0d -->
* https://pram0d.com
* https://twitter.com/pr4m0d
* https://github.com/psomashekar
*
* Copyright (c) 2022 Pramod Somashekar
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
module garegga_sdram #(
    //8 bit addressing
    parameter GAREGGA_ROM01_PRG_LEN = 25'h100000,
			  GAREGGA_ROMZ80_PRG_LEN = 25'h20000,
			  GAREGGA_GP9001_TILE_LEN = 25'h800000,
			  GAREGGA_TEXTROM_LEN = 25'h8000,
			  GAREGGA_PCM_DATA_LEN = 25'h100000,

			  KINGDMGP_ROM01_PRG_LEN = 25'h100000,
			  KINGDMGP_ROMZ80_PRG_LEN = 25'h10000,
			  KINGDMGP_GP9001_TILE_LEN = 25'h400000,
			  KINGDMGP_TEXTROM_LEN = 25'h8000,
			  KINGDMGP_PCM_DATA_LEN = 25'h80000,

			  SSTRIKER_ROM01_PRG_LEN = 25'h80000,
			  SSTRIKER_ROMZ80_PRG_LEN = 25'h10000,
			  SSTRIKER_GP9001_TILE_LEN = 25'h200000,
			  SSTRIKER_TEXTROM_LEN = 25'h8000,
			  SSTRIKER_PCM_DATA_LEN = 25'h40000
)(
    input RESET48,
    input CLK48,
	input CLK,
	input RESET,
    input CLK_GFX,

    //ROM loader
	input  [25:0] IOCTL_ADDR,
	input  [7:0]  IOCTL_DOUT,
	output [7:0]  IOCTL_DIN,
	input 		  IOCTL_WR,
	input 		  IOCTL_RAM,
	output [21:0] PROG_ADDR,
	output [15:0] PROG_DATA,
	output [1:0]  PROG_MASK,
	output [1:0]  PROG_BA,
	output reg	  PROG_WE,
	output 		  PROG_RD,
	input 		  PROG_RDY,
    input         DOWNLOADING,
    output        DWNLD_BUSY,

    // Bank 0: allows R/W
    output [21:0] BA0_ADDR,
    output [21:0] BA1_ADDR,
    output [21:0] BA2_ADDR,
    output [21:0] BA3_ADDR,
    output [ 3:0] BA_RD,
    output        BA_WR,
    output [15:0] BA0_DIN,
    output [ 1:0] BA0_DIN_M,  // write mask
    input  [ 3:0] BA_ACK,
    input  [ 3:0] BA_DST,
    input  [ 3:0] BA_DOK,
    input  [ 3:0] BA_RDY,
	input  [15:0] DATA_READ,

    //main cpu prg (Read)
	input 		  ROM68K_CS,
	output 		  ROM68K_OK,
	input  [18:0] ROM68K_ADDR,
	output [15:0] ROM68K_DOUT,
	
	//snd prg (Read)
	input 		  ROMZ80_CS,
	output 		  ROMZ80_OK,
	input  [16:0] ROMZ80_ADDR,
	output  [7:0] ROMZ80_DOUT,
	
	//tile data (Read) (it is split across 2 banks)
	input 	  	  GFX_CS,
	output 	 	  GFX_OK,
	input  [21:0] GFX0_ADDR,
	output [31:0] GFX0_DOUT,

	//extra port for scroll0
	input 	 	  GFXSCR0_CS,
	output 	 	  GFXSCR0_OK,
	input  [21:0] GFX0SCR0_ADDR,
	output [31:0] GFX0SCR0_DOUT,

	//extra port for scroll1
	input 	 	  GFXSCR1_CS,
	output 	 	  GFXSCR1_OK,
	input  [21:0] GFX0SCR1_ADDR,
	output [31:0] GFX0SCR1_DOUT,

	//extra port for scroll2
	input 		  GFXSCR2_CS,
	output 		  GFXSCR2_OK,
	input  [21:0] GFX0SCR2_ADDR,
	output [31:0] GFX0SCR2_DOUT,
	
	//PCM data (Read, 6)
	input 		  PCM_CS,
	output 		  PCM_OK,
	input  [19:0] PCM_ADDR,
	output [7:0]  PCM_DOUT,

	//Text ROM
	input  [13:0] TEXTROM_ADDR,
	output [15:0] TEXTROM_DOUT,

	output reg [7:0] GAME,

	//hiscores
	input		  HISCORE_CS,
	input    [1:0] HISCORE_WE,
	input   [15:0] HISCORE_DIN,
	output  [15:0] HISCORE_DOUT,
	input    [6:0] HISCORE_ADDR 
);

//loader
assign DWNLD_BUSY = DOWNLOADING;
localparam GAREGGA = 0, KINGDMGP = 2, SSTRIKER = 1;

wire [24:0] ROM01_PRG_LEN = GAME == KINGDMGP ? KINGDMGP_ROM01_PRG_LEN :
							GAME == SSTRIKER ? SSTRIKER_ROM01_PRG_LEN :
							GAREGGA_ROM01_PRG_LEN,
		   ROMZ80_PRG_LEN = GAME == KINGDMGP ? KINGDMGP_ROMZ80_PRG_LEN :
							GAME == SSTRIKER ? SSTRIKER_ROMZ80_PRG_LEN :
							GAREGGA_ROMZ80_PRG_LEN,
		   GP9001_TILE_LEN = GAME == KINGDMGP ? KINGDMGP_GP9001_TILE_LEN :
							GAME == SSTRIKER ? SSTRIKER_GP9001_TILE_LEN :
							GAREGGA_GP9001_TILE_LEN,
		   TEXTROM_LEN = GAME == KINGDMGP ? KINGDMGP_TEXTROM_LEN :
							GAME == SSTRIKER ? SSTRIKER_TEXTROM_LEN :
							GAREGGA_TEXTROM_LEN,
		   PCM_DATA_LEN = GAME == KINGDMGP ? KINGDMGP_PCM_DATA_LEN :
							GAME == SSTRIKER ? SSTRIKER_PCM_DATA_LEN :
							GAREGGA_PCM_DATA_LEN;

wire [25:0] ROM_BASE = 26'h1,
		    SND_BASE = ROM_BASE + ROM01_PRG_LEN,
		    TILE_BASE = SND_BASE + ROMZ80_PRG_LEN,
		    TEXTROM_BASE = TILE_BASE + GP9001_TILE_LEN,
		    PCM_BASE = TEXTROM_BASE + TEXTROM_LEN,
		    ROM_END = PCM_BASE + PCM_DATA_LEN;

wire is_cpu = IOCTL_ADDR >= ROM_BASE && IOCTL_ADDR < SND_BASE;
wire is_snd = IOCTL_ADDR >= SND_BASE && IOCTL_ADDR < TILE_BASE;
wire is_tile = IOCTL_ADDR >= TILE_BASE && IOCTL_ADDR < TEXTROM_BASE;
wire is_textrom = IOCTL_ADDR >= TEXTROM_BASE && IOCTL_ADDR < PCM_BASE;
wire is_pcm = IOCTL_ADDR >= PCM_BASE && IOCTL_ADDR < ROM_END;
wire is_game = IOCTL_ADDR == 0;

reg [7:0] pre_data;
reg [1:0] pre_mask;
reg [21:0] pre_addr;
reg [1:0] pre_ba;

//where it loads to in sdram
localparam cpu_offs=0, snd_offs='h100000, pcm_offs='h120000;
wire [25:0] bulk_addr = IOCTL_ADDR;
wire [25:0] cpu_addr = (bulk_addr - ROM_BASE) + cpu_offs;
wire [25:0] snd_addr = (bulk_addr - SND_BASE) + snd_offs;
wire [25:0] pcm_addr = (bulk_addr - PCM_BASE) + pcm_offs;
wire [25:0] tile_addr = bulk_addr - TILE_BASE;
wire [25:0] textrom_addr = bulk_addr - TEXTROM_BASE; //this goes to a dpram

assign PROG_DATA = {2{pre_data}};
assign PROG_MASK = pre_mask;
assign PROG_BA = pre_ba;
assign PROG_ADDR = pre_addr;
assign PROG_RD = 0;

//textrom loader
reg [15:0] textrom_ldr_din;
reg [1:0] textrom_ldr_we;
reg [13:0] textrom_ldr_addr;

// main loader for ROM data

always @(posedge CLK) begin
    if(IOCTL_WR && !IOCTL_RAM) begin
		if(is_game) begin
			GAME<=IOCTL_DOUT;
		end else if(is_textrom) begin //textrom goes to dpram below.
			textrom_ldr_din <= {2{IOCTL_DOUT}};
			textrom_ldr_we <= ~IOCTL_ADDR[0] ? 2'b01 : 2'b10;
			textrom_ldr_addr <= textrom_addr>>1;
		end else begin
			PROG_WE<=1'b1;
			pre_data <= IOCTL_DOUT;
			pre_mask <= ~IOCTL_ADDR[0] ? 2'b10 : 2'b01;
			pre_addr <= is_cpu ? cpu_addr>>1 :
						is_snd ? snd_addr>>1 :
						is_pcm ? pcm_addr>>1 :
						is_tile ? tile_addr >>1 :
						'hxx;
			pre_ba <=  is_cpu ? 2'h0 : //cpu program
					is_snd ? 2'h0 : //snd program
					is_pcm ? 2'h0 : //pcm data
					is_tile ? 2'h1 : //tiles/gfx
					2'hxx; //nothing
			// $display("%h, %h, %h", pre_addr, IOCTL_ADDR, IOCTL_DOUT);
			
		end
	end else begin
		if(!DOWNLOADING || PROG_RDY) PROG_WE<=1'b0;
	end
end

//PROMS
assign BA_WR = 1'b0;

`ifdef SIMULATION

//the snd rom
reg  [7:0] z80prg [0:2**16-1];
initial $readmemh("rom/z80prg.hex",  z80prg, 0, 'hFFFF);

//the 68k rom
reg  [7:0] prg [0:2**19-1];
initial $readmemh("rom/68kprg.hex",  prg, 0, 'hFFFFF);

assign ROM68K_OK=1'b1;
assign ROM68K_DOUT={prg[ROM68K_ADDR<<1], prg[(ROM68K_ADDR<<1)+1]};
assign ROMZ80_OK=1'b1;
assign ROMZ80_DOUT = z80prg[ROMZ80_ADDR];

`else
jtframe_rom_3slots #(
	.SDRAMW(22),

	.SLOT0_AW    (19), //68k rom (16 bit addressing)
	.SLOT0_DW    (16),
	.SLOT0_LATCH (1),
	.SLOT0_DOUBLE(1),

	.SLOT1_AW    (17), //z80 rom (8 bit addressing)
	.SLOT1_DW    (8),
	.SLOT1_LATCH (1),
	.SLOT1_DOUBLE(1),


	.SLOT2_AW    (20), //PCM rom
	.SLOT2_DW    (8),
	.SLOT2_LATCH (1),
	.SLOT2_DOUBLE(1),

	.SLOT0_OFFSET(0),
	.SLOT1_OFFSET(snd_offs>>1),
	.SLOT2_OFFSET(pcm_offs>>1)
) u_bank0 (
	.rst         (RESET),
	.clk         (CLK),

	.slot0_cs    (ROM68K_CS),
	.slot0_ok    (ROM68K_OK),
	.slot0_addr  (ROM68K_ADDR),
	.slot0_dout  (ROM68K_DOUT),

	.slot1_cs    (ROMZ80_CS),
	.slot1_ok    (ROMZ80_OK),
	.slot1_addr  (ROMZ80_ADDR ^ 1),
	.slot1_dout  (ROMZ80_DOUT),

	.slot2_cs    (PCM_CS),
	.slot2_ok    (PCM_OK),
	.slot2_addr  (PCM_ADDR ^ 1),
	.slot2_dout  (PCM_DOUT),

	.sdram_addr  (BA0_ADDR),
	.sdram_req   (BA_RD[0]),
	.sdram_ack   (BA_ACK[0]),
	.data_dst    (BA_DST[0]),
	.data_rdy    (BA_RDY[0]),
	.data_read   (DATA_READ)
);
`endif

//garegga's gfx is only 8mb, so only 1 bank needed.
jtframe_rom_4slots #(
    .SDRAMW      (22),
	.SLOT0_AW    (22), //gfx (8MB) (16 bit addressing, but the words are swapped.)
	.SLOT0_DW    (32),
	.SLOT0_DOUBLE(1),
	.SLOT0_LATCH (0),

	.SLOT1_AW    (22), //gfx (8MB) (16 bit addressing, but the words are swapped.)
	.SLOT1_DW    (32),
	.SLOT1_DOUBLE(1),
	.SLOT1_LATCH (0),

	.SLOT2_AW    (22), //gfx (8MB) (16 bit addressing, but the words are swapped.)
	.SLOT2_DW    (32),
	.SLOT2_DOUBLE(1),
	.SLOT2_LATCH (0),

	.SLOT3_AW    (22), //gfx (8MB) (16 bit addressing, but the words are swapped.)
	.SLOT3_DW    (32),
	.SLOT3_DOUBLE(1),
	.SLOT3_LATCH (0)
) u_bank1 (
    .rst         (RESET),
	.clk         (CLK),

	.slot0_cs    (GFX_CS),
	.slot0_ok    (GFX_OK),
	.slot0_addr  (GFX0_ADDR),
	.slot0_dout  (GFX0_DOUT),

	.slot1_cs    (GFXSCR0_CS),
	.slot1_ok    (GFXSCR0_OK),
	.slot1_addr  (GFX0SCR0_ADDR),
	.slot1_dout  (GFX0SCR0_DOUT),

	.slot2_cs    (GFXSCR1_CS),
	.slot2_ok    (GFXSCR1_OK),
	.slot2_addr  (GFX0SCR1_ADDR),
	.slot2_dout  (GFX0SCR1_DOUT),

	.slot3_cs    (GFXSCR2_CS),
	.slot3_ok    (GFXSCR2_OK),
	.slot3_addr  (GFX0SCR2_ADDR),
	.slot3_dout  (GFX0SCR2_DOUT),

	.sdram_addr  (BA1_ADDR),
	.sdram_req   (BA_RD[1]),
	.sdram_ack   (BA_ACK[1]),
	.data_dst    (BA_DST[1]),
	.data_rdy    (BA_RDY[1]),
	.data_read   (DATA_READ)
);

//TEXT ROM
jtframe_dual_ram16 #(.aw(14)) u_textrom(
	.clk0(CLK),
	.clk1(CLK),
    // loader
    .data0(textrom_ldr_din),
    .addr0(textrom_ldr_addr),
    .we0(textrom_ldr_we),
    .q0(),
    // Port 1
    .data1(16'd0),
    .addr1(TEXTROM_ADDR),
    .we1(2'b00),
    .q1(TEXTROM_DOUT)
);

//hiscore table
wire dump_we = IOCTL_WR & IOCTL_RAM;
wire [15:0] hiscore_q1;
assign IOCTL_DIN = IOCTL_ADDR[0] ? hiscore_q1[7:0] : hiscore_q1[15:8];

jtframe_dual_ram16 #(.aw(7)) u_hiscore_table(
    .clk0   ( CLK  ),
    .clk1   ( CLK  ),
    // First port: internal use
    .addr0  ( HISCORE_ADDR  ),
    .data0  ( HISCORE_DIN   ),
    .we0    ( HISCORE_WE    ),
    .q0     ( HISCORE_DOUT  ),
    // Second port: dump
    .addr1  ( IOCTL_ADDR[7:0]>>1 ),
    .data1  ( {2{IOCTL_DOUT}}  ),
    .we1    ( {dump_we && !IOCTL_ADDR[0], dump_we && IOCTL_ADDR[0]} ),
    .q1     ( hiscore_q1 )
);

endmodule