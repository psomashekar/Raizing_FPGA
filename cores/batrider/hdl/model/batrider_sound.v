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
module batrider_sound (
    input                CLK,
    input                CLK96,
    input                YM2151_CEN,
    input                YM2151_CEN2,
    input                Z80_CEN,
    input                OKI_CEN,
    input                RESET,
    input                RESET96,
    output reg           ROMZ80_CS,
	input                ROMZ80_OK,
	output reg    [17:0] ROMZ80_ADDR,
	input          [7:0] ROMZ80_DOUT, 
    output               PCM_CS,
    input                PCM_OK,
    output        [20:0] PCM_ADDR,
    input          [7:0] PCM_DOUT,
    output               PCM1_CS,
    input                PCM1_OK,
    output        [20:0] PCM1_ADDR,
    input          [7:0] PCM1_DOUT,
    output signed [15:0] left,
    output signed [15:0] right,
    output               sample,
    output reg           peak,

    //interface with m68k
    output               WAIT,
    output reg           SNDIRQ,
    input                CS,
    input                NMI,
    output reg     [7:0] SOUNDLATCH3,
    output reg     [7:0] SOUNDLATCH4,
    input          [7:0] SOUNDLATCH,
    input          [7:0] SOUNDLATCH2,
    input          [1:0] FX_LEVEL,
    input		 DIP_PAUSE
);

// assign ACK = 1'b1;
wire cpu_cen;
wire int_n;
wire m1_n, iorq_n, mreq_n;
wire rd_n;
wire wr_n, WRn;
wire [15:0] A;
reg [7:0] din, fm_din, oki0_din, oki1_din;
wire io_cs = !iorq_n;
reg [3:0] bank = 2; // init bank to 2
wire [7:0] ram_dout, dout, fm_dout, oki0_dout, oki1_dout;
assign WRn = wr_n | mreq_n;
wire signed [15:0] fm_left, fm_right;
wire peak_l, peak_r;

wire signed [13:0] oki0_pre, oki1_pre;
wire oki0_sample, oki1_sample;

reg [7:0] nmk112_data_0a, nmk112_data_1a;
reg [2:0] nmk112_offset_0a, nmk112_offset_1a;
wire [20:0] nmk112_bank_addr_0a, nmk112_bank_addr_1a;
wire [20:0] start0a, start1a;
wire [17:0] oki0_pcm_addr, oki1_pcm_addr;

//debugging 
 wire debug = 1'b1;
 integer fd;

 `ifdef SIMULATION
 initial fd = $fopen("logsound.txt", "w");
`endif

/*
0: pcmgain <= 8'h10 ;   // 100%
1: pcmgain <= 8'h20 ;   // 200%
2: pcmgain <= 8'h0c ;   // 75%
3: pcmgain <= 8'h08 ;   // 50%
*/

wire [7:0] fx_mult = FX_LEVEL == 2 ? 8'h10 :
                     FX_LEVEL == 3 ? 8'h20 :
                     FX_LEVEL == 1 ? 8'h0c :
                     FX_LEVEL == 0 ? 8'h08 :
                     8'h10; 
localparam [7:0] fmgain = 8'h08, pcmgain = 8'h10;
always @(posedge CLK96) begin
    peak <= peak_l | peak_r;
end

reg [7:0] gain1;
reg signed [15:0] final_left;
reg signed [13:0] final_oki0, final_oki1;
always @(posedge CLK96) begin
    final_left<=fm_left;
    final_oki0<=oki0_pre;
    final_oki1<=oki1_pre;
    gain1<=fx_mult;
end

assign right = left;
assign peak_r = peak_l;
jtframe_mixer #(.W0(16), .W1(14), .W2(14), .WOUT(16)) u_mix_left(
    .rst    ( RESET96       ),
    .clk    ( CLK96       ),
    .cen    ( 1'b1      ),
    // input signals
    .ch0    ( final_left   ),
    .ch1    ( final_oki0 ),
    .ch2    ( final_oki1 ),
    .ch3    ( 16'd0     ),
    // gain for each channel in 4.4 fixed point format
    .gain0  ( fmgain    ),
    .gain1  ( gain1 ),
    .gain2  ( gain1     ),
    .gain3  ( 8'd0     ),
    .mixed  ( left      ),
    .peak   ( peak_l    )
);

//io
wire nmi_n;
reg soundlatch3_wr,
    soundlatch4_wr,
    batrider_sndirq_w,
    batrider_clear_nmi_w,
    soundlatch_rd,
    soundlatch2_rd,
    ymsnd_sel_reg,
    ymsnd_rd,
    ymsnd_wr,
    okim6295_device_0_rd,
    okim6295_device_0_wr,
    okim6295_device_1_rd,
    okim6295_device_1_wr,
    raizing_z80_bankswitch_w,
    raizing_oki_bankswitch_w;

//address bus
reg ram_cs, fm_cs, oki0_cs, oki1_cs, nmk112_cs;
always @(posedge CLK96) begin
    if(RESET96) begin
        soundlatch3_wr <= 0;
        soundlatch4_wr <= 0;
        batrider_sndirq_w <= 0;
        batrider_clear_nmi_w <= 0;
        soundlatch_rd <= 0;
        soundlatch2_rd <= 0;
        ymsnd_sel_reg <= 0;
        ymsnd_rd <= 0;
        ymsnd_wr <= 0;
        okim6295_device_0_rd <= 0;
        okim6295_device_0_wr <= 0;
        okim6295_device_1_rd <= 0;
        okim6295_device_1_wr <= 0;
        raizing_z80_bankswitch_w <= 0;
        raizing_oki_bankswitch_w <= 0;
        ram_cs <= 0; // > 0xC000 to 0xdfff
        fm_cs <= 0;
        oki0_cs<=0;
        oki1_cs<= 0;
        nmk112_cs<=0;
        ROMZ80_CS <= 0;
        ROMZ80_ADDR<=0;
        SNDIRQ<=0;
    end else begin
            // if(debug) $display("address:%h, op:%b", A, {rd_n, wr_n, iorq_n, mreq_n, m1_n});
        soundlatch3_wr <= io_cs && !wr_n && A[7:0] == 8'h40;
        soundlatch4_wr <= io_cs && !wr_n && A[7:0] == 8'h42;
        batrider_sndirq_w <= io_cs && !wr_n && A[7:0] == 8'h44;
        batrider_clear_nmi_w <= io_cs && !wr_n && A[7:0] == 8'h46;
        soundlatch_rd <= io_cs && !rd_n && A[7:0] == 8'h48;
        soundlatch2_rd <= io_cs && !rd_n && A[7:0] == 8'h4a;
        ymsnd_sel_reg <= io_cs && !wr_n && A[7:0] == 8'h80;
        ymsnd_rd <= io_cs && !rd_n && A[7:0] == 8'h81;
        ymsnd_wr <= io_cs && !wr_n && A[7:0] == 8'h81;
        okim6295_device_0_rd <= io_cs && !rd_n && A[7:0] == 8'h82;
        okim6295_device_0_wr <= io_cs && !wr_n && A[7:0] == 8'h82;
        okim6295_device_1_rd <= io_cs && !rd_n && A[7:0] == 8'h84;
        okim6295_device_1_wr <= io_cs && !wr_n && A[7:0] == 8'h84;
        raizing_z80_bankswitch_w <= io_cs && !wr_n && A[7:0] == 8'h88;
        raizing_oki_bankswitch_w <= io_cs && !wr_n && (A[7:0] == 8'hC0 || A[7:0] == 8'hC2 || A[7:0] == 8'hC4 || A[7:0] == 8'hC6);
        ram_cs <= !mreq_n && A[15:13] == 4'b110; // > 0xC000 to 0xdfff
        fm_cs <= io_cs && (A[7:0] == 8'h80 || A[7:0] == 8'h81);
        nmk112_cs<=io_cs && A[7:4] == 'hC;
        ROMZ80_CS <= !mreq_n && !rd_n && (!A[15] || A[15:14]==2'b10);
        ROMZ80_ADDR<=A[15:14]==2'b10 ? (bank << 14) + (A-'h8000) : A;
        SNDIRQ<=io_cs && A[7:0] == 8'h44;
    end
end

//io switch
reg [3:0] rom0_bank_addrs [0:7];
reg [3:0] rom1_bank_addrs [0:7];

always @(posedge CLK96) begin  
    if(RESET96) begin
        SOUNDLATCH3 <= 8'h0;
        SOUNDLATCH4 <= 8'h0;
    end else begin
        //to z80
        case(1'b1)
            ROMZ80_CS: din <= ROMZ80_DOUT;
            ram_cs: din <= ram_dout;
            soundlatch_rd: din <= SOUNDLATCH;
            soundlatch2_rd: din <= SOUNDLATCH2;
            ymsnd_rd: din <= fm_dout;
            okim6295_device_0_rd: din <= oki0_dout;
            okim6295_device_1_rd: din <= oki1_dout;
            default: din <= 8'hFF;
        endcase

        if(debug) begin
            if(soundlatch_rd) $display("soundlatch_rd:%h", SOUNDLATCH);
            if(soundlatch2_rd) $display("soundlatch2_rd:%h", SOUNDLATCH2);
            // if(ymsnd_rd) $display("ymsnd_rd:%h", fm_dout);
            if(soundlatch3_wr) $display("soundlatch3_wr:%h", dout);
            if(soundlatch4_wr) $display("soundlatch4_wr:%h", dout);
            if(batrider_sndirq_w) $display("sndirq_w:%h", dout);
            if(batrider_clear_nmi_w) $display("clear_nmi:%h", dout);
        end

        if(soundlatch3_wr) begin
            SOUNDLATCH3 <= dout;
        end

        else if(soundlatch4_wr) begin
            SOUNDLATCH4 <= dout;
        end

        else if(ymsnd_sel_reg || ymsnd_wr) begin
            fm_din <= dout;
        end

        else if(okim6295_device_0_wr) begin
            oki0_din <= dout;
        end
        
        else if(okim6295_device_1_wr) begin
            oki1_din <= dout;
        end

        else if(raizing_oki_bankswitch_w) begin
            if(((A & 6) & 4) >> 2 == 0) begin
                nmk112_offset_0a<=(A & 6);
                nmk112_data_0a<=dout;
            end else if (((A & 6) & 4) >> 2 == 1) begin
                nmk112_offset_1a<=(A & 6);
                nmk112_data_1a<=dout;
            end
        end

        else if(raizing_z80_bankswitch_w) begin
            bank<=dout[3:0];  
        end
    end
end

NMK112 u_nmk112_0(
    .CLK(CLK96),
    .RESET(RESET96),
    .OFFSET(nmk112_offset_0a),
    .DATA(nmk112_data_0a),
    .REQ_ADDR(oki0_pcm_addr & 'h3FFFF),
    .REQ_DATA_ADDR(PCM_ADDR)
);

NMK112 #(.ROM_OFFS('h100000)) u_nmk112_1(
    .CLK(CLK96),
    .RESET(RESET96),
    .OFFSET(nmk112_offset_1a),
    .DATA(nmk112_data_1a),
    .REQ_ADDR(oki1_pcm_addr & 'h3FFFF),
    .REQ_DATA_ADDR(PCM1_ADDR)
);

jtframe_ff u_nmi_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( nmi_n       ),
    .set      ( 1'b0        ),    // active high
    .clr      ( batrider_clear_nmi_w ),    // active high
    .sigedge  ( CS ) // signal whose edge will trigger the FF
);

jtframe_ff u_m68wait_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        ( WAIT            ),
    .qn       (        ),
    .set      ( 1'b0        ),    // active high
    .clr      ( batrider_clear_nmi_w),    // active high
    .sigedge  ( CS     ) // signal whose edge will trigger the FF
);

jtframe_sysz80 #(.RAM_AW(13)) u_cpu(
    .rst_n      ( ~RESET96      ),
    .clk        ( CLK96         ),
    .cen        ( Z80_CEN     ), //5.333
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
    .cpu_din    ( din         ),
    .cpu_dout   ( dout        ),
    .ram_dout   ( ram_dout    ),
    .ram_cs     ( ram_cs      ),
    // manage access to ROM data from SDRAM
    .rom_cs     ( ROMZ80_CS   ),
    .rom_ok     ( ROMZ80_OK   )
); 

// assign PCM_ADDR = (oki0_pcm_addr>>8)<<8;
// assign PCM1_ADDR = oki1_pcm_addr+nmk112_offset_1a;
assign PCM_CS = 1'b1;
assign PCM1_CS = 1'b1;

jt6295 #(.INTERPOL(1)) u_adpcm_0(
    .rst        ( RESET96       ),
    .clk        ( CLK96       ),
    .cen        ( OKI_CEN & DIP_PAUSE   ),
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

jt6295 #(.INTERPOL(1)) u_adpcm_1(
    .rst        ( RESET96       ),
    .clk        ( CLK96       ),
    .cen        ( OKI_CEN & DIP_PAUSE   ),
    .ss         ( 1'b0      ),
    // CPU interface
    .wrn        ( ~okim6295_device_1_wr ),  // active low
    .din        ( oki1_din      ),
    .dout       ( oki1_dout  ),
    // ROM interface
    .rom_addr   ( oki1_pcm_addr ),
    .rom_data   ( PCM1_DOUT ),
    .rom_ok     ( PCM1_OK   ),
    // Sound output
    .sound      ( oki1_pre   ),
    .sample     ( oki1_sample)   // ~26kHz
);

jt51 u_jt51(
    .rst        ( RESET96       ), // reset
    .clk        ( CLK96       ), // main clock
    .cen        ( YM2151_CEN & DIP_PAUSE    ),
    .cen_p1     ( YM2151_CEN2 & DIP_PAUSE   ),
    .cs_n       ( !fm_cs    ), // chip select
    .wr_n       ( wr_n      ), // write
    .a0         ( A[0]     ),
    .din        ( dout      ), // data in
    .dout       ( fm_dout   ), // data out
    .ct1        (           ),
    .ct2        (           ),
    .irq_n      ( int_n     ),  // I do not synchronize this signal
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
