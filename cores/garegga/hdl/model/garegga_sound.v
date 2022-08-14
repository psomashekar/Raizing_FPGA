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
module garegga_sound (
    input                CLK,
    input                CLK96,
    input                RESET,
    input                RESET96,
    input                YM2151_CEN,
    input                YM2151_CEN2,
    input                Z80_CEN,
    input                OKI_CEN,
    
    output reg           ROMZ80_CS,
	input                ROMZ80_OK,
	output reg    [16:0] ROMZ80_ADDR,
	input          [7:0] ROMZ80_DOUT, 
    output               PCM_CS,
    input                PCM_OK,
    output        [19:0] PCM_ADDR,
    input          [7:0] PCM_DOUT,
    output signed [15:0] left,
    output signed [15:0] right,
    output               sample,
    output reg           peak,

    //interface with m68k
    output               WAIT,
    input                Z80INT,
    input          [7:0] SOUNDLATCH,
    output        [13:0] SRAM_ADDR,
    input          [7:0] SRAM_DATA,
    output         [7:0] SRAM_DIN,
    output               SRAM_WE,

    input          [7:0] OKI_BANK,
    input          [7:0] GAME,
    input          [1:0] FX_LEVEL,
    input		 DIP_PAUSE
);

localparam GAREGGA = 'h0, KINGDMGP = 'h2, SSTRIKER = 'h1;
// assign ACK = 1'b1;
wire cpu_cen;
wire int_n;
wire ym_irq_n;
wire m1_n, iorq_n, mreq_n;
wire rd_n;
wire wr_n, WRn;
wire [15:0] A;
reg [7:0] din, fm_din, oki0_din;
wire io_cs = !iorq_n;
reg [3:0] bank = 2; // init bank to 2
wire [7:0] ram_dout, dout, fm_dout, oki0_dout;
assign WRn = wr_n | mreq_n;
wire signed [15:0] fm_left, fm_right;
wire peak_l, peak_r;

wire signed [13:0] oki0_pre;
wire oki0_sample;

reg [7:0] nmk112_data_0a;
reg [2:0] nmk112_offset_0a;
wire [20:0] nmk112_bank_addr_0a;
wire [20:0] start0a;
wire [17:0] oki0_pcm_addr;

//debugging 
 wire debug = 1'b1;
 integer fd;

 `ifdef SIMULATION
 initial fd = $fopen("logsound.txt", "w");
`endif

wire [7:0] 
fmgain = GAME == GAREGGA ? 8'h08 :
         8'h10, 
pcmgain = GAME == GAREGGA ? 8'h10 : 
          GAME == SSTRIKER ? 8'h10 :
          8'h10;
always @(posedge CLK) begin
    peak <= peak_l | peak_r;
end

reg [7:0] gain1;
reg signed [15:0] final_left;
reg signed [13:0] final_oki0;
always @(posedge CLK96) begin
    final_left<=fm_left;
    final_oki0<=oki0_pre;
    gain1<=pcmgain + (FX_LEVEL<<1);
end

assign right = left;
assign peak_r = peak_l;
jtframe_mixer #(.W0(16), .W1(14), .WOUT(16)) u_mix_left(
    .rst    ( RESET96       ),
    .clk    ( CLK96       ),
    .cen    ( 1'b1      ),
    // input signals
    .ch0    ( final_left   ),
    .ch1    ( final_oki0 ),
    .ch2    ( 16'd0 ),
    .ch3    ( 16'd0     ),
    // gain for each channel in 4.4 fixed point format
    .gain0  ( fmgain    ),
    .gain1  ( gain1 ),
    .gain2  ( 8'd0     ),
    .gain3  ( 8'd0     ),
    .mixed  ( left      ),
    .peak   ( peak_l    )
);

//io
wire nmi_n = 1'b1;
reg soundlatch_rd,
    soundlatch_ack,
    ymsnd_sel_reg,
    ymsnd_rd,
    ymsnd_wr,
    okim6295_device_0_rd,
    okim6295_device_0_wr,
    raizing_z80_bankswitch_w,
    raizing_oki_bankswitch_w,
    e01d_rd;

//address bus
reg ram_cs, fm_cs;
always @(posedge CLK96) begin
    if(RESET96) begin
        soundlatch_rd <= 0;
        soundlatch_ack <= 0;
        ymsnd_sel_reg <= 0;
        ymsnd_rd <= 0;
        ymsnd_wr <= 0;
        okim6295_device_0_rd <= 0;
        okim6295_device_0_wr <= 0;
        raizing_z80_bankswitch_w <= 0;
        raizing_oki_bankswitch_w <= 0;
        e01d_rd<=0;
        ram_cs <= 0; // > 0xC000 to 0xdfff
        fm_cs <= 0;
        ROMZ80_CS <= 0;
        ROMZ80_ADDR<=0;
    end else begin
        if(debug) 
            $fwrite(fd, "time: %t, addr: %h, int_n: %h, m1_n: %h, iorq_n: %h, dout: %h, din: %h\n", $time/1000, A, int_n, m1_n, iorq_n, dout, din);
        soundlatch_rd <= !rd_n && A == 16'hE01C;
        soundlatch_ack <= !wr_n && A == 16'hE00C;
        ymsnd_sel_reg <= !wr_n && A == 16'hE000;
        ymsnd_rd <= !rd_n && A == 16'hE001;
        ymsnd_wr <= !wr_n && A == 16'hE001;
        okim6295_device_0_rd <= !rd_n && A == 16'hE004;
        okim6295_device_0_wr <= !wr_n && A == 16'hE004;
        raizing_z80_bankswitch_w <= !wr_n && A == 16'hE00A;
        raizing_oki_bankswitch_w <= !wr_n && (A == 16'hE006 || A == 16'hE008);
        e01d_rd <= !rd_n && A == 16'hE01D;

        ram_cs <= !mreq_n && A[15:13] == 4'b110; // > 0xC000 to 0xdfff
        fm_cs <= (A == 16'hE000 || A == 16'hE001);
        ROMZ80_CS <= !mreq_n && !rd_n && (!A[15] || A[15:14]==2'b10);
        ROMZ80_ADDR<=A[15:14]==2'b10 ? (bank << 14) + (A-'h8000) : A;
    end
end

//io switch

//ram
assign SRAM_WE = ram_cs && !wr_n;
assign SRAM_DIN = dout;
assign SRAM_ADDR = {1'b0,A[12:0]};

always @(posedge CLK96) begin  
    if(RESET96) begin
    end else begin
        //to z80
        case(1'b1)
            ROMZ80_CS: din <= ROMZ80_DOUT;
            (ram_cs && !rd_n): din <= SRAM_DATA;
            soundlatch_rd: din <= SOUNDLATCH;
            ymsnd_rd: din <= fm_dout;
            okim6295_device_0_rd: din <= oki0_dout;
            e01d_rd : din<=0;
            default: din <= 8'hFF;
        endcase

        if(ymsnd_sel_reg || ymsnd_wr) begin
            fm_din <= dout;
        end

        else if(okim6295_device_0_wr) begin
            oki0_din <= dout;
        end

        if(raizing_oki_bankswitch_w) begin
            nmk112_offset_0a <= A[3:0] == 8 ? 2 : 0;
            nmk112_data_0a <= dout;
        end

        if(raizing_z80_bankswitch_w) begin
            bank<=dout[3:0];  
        end
    end
end
wire [20:0] nmk_pcm_addr;
assign PCM_ADDR = GAME == KINGDMGP ? (OKI_BANK[4] << 14) + (oki0_pcm_addr & 'h3FFFF) : 
                  GAME == SSTRIKER ? (oki0_pcm_addr & 'h3FFFF) :
                  nmk_pcm_addr;


NMK112 u_nmk112_0(
    .CLK(CLK96),
    .RESET(RESET96),
    .OFFSET(nmk112_offset_0a),
    .DATA(nmk112_data_0a),
    .REQ_ADDR(oki0_pcm_addr & 'h3FFFF),
    .REQ_DATA_ADDR(nmk_pcm_addr)
);

jtframe_ff u_int_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( int_n       ),
    .set      ( 1'b0 ),    // active high
    .clr      ( !iorq_n && !m1_n ),    // active high
    .sigedge  ( Z80INT ) // signal whose edge will trigger the FF
);

jtframe_ff u_m68wait_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        ( WAIT            ),
    .qn       (        ),
    .set      ( 1'b0        ),    // active high
    .clr      ( soundlatch_ack ),    // active high
    .sigedge  ( Z80INT     ) // signal whose edge will trigger the FF
);

jtframe_z80_romwait u_cpu(
    .rst_n      ( ~RESET96      ),
    .clk        ( CLK96         ),
    .cen        ( Z80_CEN     ), //4
    .cpu_cen    ( cpu_cen     ),
    .int_n      ( int_n       ),
    .nmi_n      ( nmi_n       ),
    .busrq_n    ( 1'b1        ),
    .m1_n       ( m1_n        ),
    .mreq_n     ( mreq_n      ),
    .iorq_n     ( iorq_n      ),
    .rd_n       ( rd_n        ),
    .wr_n       ( wr_n        ),
    .rfsh_n     (             ),
    .halt_n     (             ),
    .busak_n    (             ),
    .A          ( A           ),
    .din    ( din         ),
    .dout   ( dout        ),
    // .ram_dout   ( ram_dout    ),
    // .ram_cs     ( ram_cs      ),
    // manage access to ROM data from SDRAM
    .rom_cs     ( ROMZ80_CS   ),
    .rom_ok     ( ROMZ80_OK   )
); 

assign PCM_CS = 1'b1;

jt6295 #(.INTERPOL(1)) u_adpcm_0(
    .rst        ( RESET96       ),
    .clk        ( CLK96       ),
    .cen        ( OKI_CEN & DIP_PAUSE ),
    .ss         ( 1'b1      ),
    // CPU interface
    .wrn        ( ~okim6295_device_0_wr ),  // active low
    .din        ( oki0_din      ),
    .dout       ( oki0_dout  ),
    // ROM interface
    .rom_addr   ( oki0_pcm_addr ),
    .rom_data   ( PCM_DOUT),
    .rom_ok     ( PCM_OK  ),
    // Sound output
    .sound      ( oki0_pre   ),
    .sample     ( oki0_sample)   // ~26kHz
);

jt51 u_jt51(
    .rst        ( RESET96       ), // reset
    .clk        ( CLK96       ), // main clock
    .cen        ( YM2151_CEN & DIP_PAUSE    ), // 4mhz
    .cen_p1     ( YM2151_CEN2 & DIP_PAUSE   ), //2mhz, half clock
    .cs_n       ( !fm_cs    ), // chip select
    .wr_n       ( wr_n      ), // write
    .a0         ( A[0]     ),
    .din        ( dout    ), // data in
    .dout       ( fm_dout   ), // data out
    .ct1        (           ),
    .ct2        (           ),
    .irq_n      ( ym_irq_n     ),  // I do not synchronize this signal
    // Low resolution output (same as real chip)
    .sample     ( sample    ), // marks new output sample
    .left       (           ),
    .right      (           ),
    // Full resolution output
    .xleft      ( fm_left   ),
    .xright     (   ),
    // unsigned outputs for sigma delta converters, full resolution
    .dacleft    (           ),
    .dacright   (           )
);

endmodule
