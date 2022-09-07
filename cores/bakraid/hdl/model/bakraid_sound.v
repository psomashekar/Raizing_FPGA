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
module bakraid_sound (
    input                CLK,
    input                CLK96,
    input                Z80_CEN,
    input                YMZ_CEN,
    input                RESET,
    input                RESET96,
    output reg           ROMZ80_CS,
	input                ROMZ80_OK,
	output        [17:0] ROMZ80_ADDR,
	input          [7:0] ROMZ80_DOUT, 
    output               PCM_CS,
    input                PCM_OK,
    output        [21:0] PCM_ADDR,
    input          [7:0] PCM_DOUT,
    output               PCM1_CS,
    input                PCM1_OK,
    output        [21:0] PCM1_ADDR,
    input          [7:0] PCM1_DOUT,
    output               PCM2_CS,
    input                PCM2_OK,
    output        [21:0] PCM2_ADDR,
    input          [7:0] PCM2_DOUT,
    output signed [15:0] left,
    output signed [15:0] right,
    output reg              sample,
    output reg           peak,

    //interface with m68k
    output               WAIT,
    output               SNDIRQ,
    input                CS,
    input                NMI,
    output reg     [7:0] SOUNDLATCH3,
    output reg     [7:0] SOUNDLATCH4,
    input          [7:0] SOUNDLATCH,
    input          [7:0] SOUNDLATCH2,
    input          [1:0] FX_LEVEL,
    input		 DIP_PAUSE,
    output reg     [1:0] SOUNDLATCH_ACK,
    input          [1:0] SOUNDLATCH_ACK_INCOMING
);
//clock freq/88200 -1
`define YMZ280B_SAMPLE_RATE ((47250000/88200)-1)

// assign ACK = 1'b1;
wire cpu_cen;
reg int_n;
wire ymz_io_irq;
wire m1_n, iorq_n, mreq_n;
wire rd_n;
wire wr_n, WRn;
wire [15:0] A;
reg [7:0] din;
wire io_cs = !iorq_n;
wire [7:0] ram_dout, dout, fm_dout;
assign WRn = wr_n | mreq_n;
reg [15:0] fm_left, fm_right;
wire peak_l;
wire peak_r = peak_l;
assign right = left;
//debugging 
 wire debug = 1'b1;
 integer fd;

 `ifdef SIMULATION
 initial fd = $fopen("logsound.txt", "w");
`endif

//clock divider for sound irq
integer c = 0, cen444 = 'd12000;
wire c_over = c==(cen444-1);

always @(posedge CLK, posedge RESET) begin
    if(RESET) begin
        int_n <= 1;
        c <= 0;
    end else if(Z80_CEN) begin 
        c <= c_over ? 0 : (c+1);
        if(!iorq_n && !m1_n) int_n <= 1;
        else if(c_over) int_n<=0;
    end
end

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
localparam [7:0] pcmgain = 8'h10;
always @(posedge CLK) begin
    peak <= peak_l | peak_r;
end

jtframe_mixer #(.W0(16), .W1(16), .WOUT(16)) u_mix_left(
    .rst    ( RESET       ),
    .clk    ( CLK       ),
    .cen    ( 1'b1      ),
    // input signals
    .ch0    ( fm_left   ),
    .ch1    ( fm_right ),
    .ch2    ( 16'd0 ),
    .ch3    ( 16'd0     ),
    // gain for each channel in 4.4 fixed point format
    .gain0  ( fx_mult    ),
    .gain1  ( fx_mult   ),
    .gain2  ( 8'd0     ),
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
    ram_we,
    ram_rd;

//address bus
reg ram_cs, fm_cs, oki0_cs, oki1_cs, nmk112_cs;
assign SNDIRQ = batrider_sndirq_w;
assign ROMZ80_ADDR = A & 16'hBFFF;
wire ymzwr = ymsnd_sel_reg | ymsnd_wr;
wire ymzrd = ymsnd_rd;
reg [7:0] fm_din;

always @(posedge CLK, posedge RESET) begin
    if(RESET) begin
        soundlatch3_wr <= 0;
        soundlatch4_wr <= 0;
        batrider_sndirq_w <= 0;
        batrider_clear_nmi_w <= 0;
        soundlatch_rd <= 0;
        soundlatch2_rd <= 0;
        ram_cs <= 0; // > 0xC000 to 0xdfff
        ROMZ80_CS <= 0;
        ymsnd_sel_reg<=0;
        ymsnd_rd<=0;
        ymsnd_wr<=0;
    end else begin
        if(io_cs) begin
            soundlatch3_wr <= !wr_n && A[7:0] == 8'h40;
            soundlatch4_wr <= !wr_n && A[7:0] == 8'h42;
            batrider_sndirq_w <= !wr_n && A[7:0] == 8'h44;
            batrider_clear_nmi_w <= !wr_n && A[7:0] == 8'h46;
            soundlatch_rd <= !rd_n && A[7:0] == 8'h48;
            soundlatch2_rd <= !rd_n && A[7:0] == 8'h4a;

            ymsnd_sel_reg <= !wr_n && A[7:0] == 8'h80;
            ymsnd_rd <= !rd_n && A[7:0] == 8'h81;
            ymsnd_wr <= !wr_n && A[7:0] == 8'h81;
            fm_din <= dout;
        end else begin
            soundlatch3_wr <= 0;
            soundlatch4_wr <= 0;
            batrider_sndirq_w <= 0;
            batrider_clear_nmi_w <= 0;
            soundlatch_rd <= 0;
            soundlatch2_rd <= 0;

            ymsnd_sel_reg <= 0;
            ymsnd_rd <= 0;
            ymsnd_wr <= 0;
            fm_din <= 0;
        end 
        
        if(!mreq_n) begin
            ram_cs <= A >= 'hC000 && A <= 'hFFFF;
            ROMZ80_CS <= !rd_n && (!A[15] || A[15:14]==2'b10);
        end else begin
            ram_cs<=0;
            ROMZ80_CS<=0;
        end
    end
end

always @(posedge CLK, posedge RESET) begin  
    if(RESET) begin
        SOUNDLATCH3 <= 8'h0;
        SOUNDLATCH4 <= 8'h0;
    end else begin
        //to z80
        case(1'b1)
            ROMZ80_CS: din <= ROMZ80_DOUT;
            ram_cs: din <= ram_dout;
            soundlatch_rd: din <= SOUNDLATCH;
            soundlatch2_rd: din <= SOUNDLATCH2;
            ymzrd: din<=fm_dout;
            default: din <= 8'hFF;
        endcase
        
        SOUNDLATCH_ACK<=SOUNDLATCH_ACK_INCOMING; //synchronize with 68k

        if(soundlatch3_wr) begin
            SOUNDLATCH3 <= dout;
            SOUNDLATCH_ACK[0] <= 1;
        end

        else if(soundlatch4_wr) begin
            SOUNDLATCH4 <= dout;
            SOUNDLATCH_ACK[1] <= 1;
        end
    end
end

jtframe_ff u_nmi_ff(
    .clk      ( CLK         ),
    .rst      ( RESET         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( nmi_n       ),
    .set      ( 1'b0        ),    // active high
    .clr      ( batrider_clear_nmi_w ),    // active high
    .sigedge  ( NMI ) // signal whose edge will trigger the FF
);

jtframe_ff u_m68wait_ff(
    .clk      ( CLK         ),
    .rst      ( RESET         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        ( WAIT            ),
    .qn       (        ),
    .set      ( 1'b0        ),    // active high
    .clr      ( |SOUNDLATCH_ACK ),    // release hold on 68k when all ack finished.
    .sigedge  ( CS     ) // signal whose edge will trigger the FF
);

jtframe_sysz80 #(.RAM_AW(14)) u_cpu(
    .rst_n      ( ~RESET    ),
    .clk        ( CLK       ),
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

//sdram bank switch rom 7/8 or 6
wire [23:0] ymz_mem_addr;
reg [23:0] last_ymz_mem_addr = 0;
reg new_addr = 0;
reg [23:0] cur_rom_addr = 0;
wire ymz_io_rd;
wire [15:0] io_audio_bits_left, io_audio_bits_right;
wire audio_valid;

reg [1:0] st = 0;

wire [1:0] sd_bank = PCM2_CS ? 2 :
                     PCM1_CS ? 1 :
                     0;
assign PCM_CS=ymz_mem_addr>=0 && ymz_mem_addr<'h400000 && ymz_io_rd;
assign PCM1_CS=ymz_mem_addr>='h400000 && ymz_mem_addr<'h800000 && ymz_io_rd;
assign PCM2_CS=ymz_mem_addr>='h800000 && ymz_mem_addr<'hC00000 && ymz_io_rd;
assign PCM_ADDR=PCM_CS ? ymz_mem_addr[21:0] : PCM_ADDR;
assign PCM1_ADDR=PCM1_CS ? ymz_mem_addr[21:0] : PCM1_ADDR;
assign PCM2_ADDR=PCM2_CS ? ymz_mem_addr[21:0] : PCM2_ADDR;
wire over_cs = ymz_mem_addr >= 'hC00000 && ymz_io_rd;

wire [7:0] io_rom_dout = PCM_CS && PCM_OK ? PCM_DOUT :
                         PCM1_CS && PCM1_OK ? PCM1_DOUT :
                         PCM2_CS && PCM2_OK ? PCM2_DOUT :
                         0;
wire io_rom_valid = (PCM_CS && PCM_OK) ||
                    (PCM1_CS && PCM1_OK) ||
                    (PCM2_CS && PCM2_OK) ||
                    over_cs;
wire io_rom_waitReq = 1;

always @(posedge CLK) begin
    fm_left <= audio_valid ? io_audio_bits_left : fm_left;
    fm_right <= audio_valid ? io_audio_bits_right : fm_right;
    sample <= audio_valid;
end

YMZ280B u_ymz280b (
    .clock(CLK & DIP_PAUSE), //aligned to sdram
    .reset(RESET),
    .io_cpu_rd(ymzrd),
    .io_cpu_wr(ymzwr),
    .io_cpu_addr(A[0]),
    .io_cpu_din(fm_din),
    .io_cpu_dout(fm_dout),
    .io_rom_rd(ymz_io_rd),
    .io_rom_addr(ymz_mem_addr),
    .io_rom_dout(io_rom_dout),
    .io_rom_valid(io_rom_valid),
    .io_rom_waitReq(io_rom_waitReq),
    .io_audio_valid(audio_valid),
    .io_audio_bits_left(io_audio_bits_left),
    .io_audio_bits_right(io_audio_bits_right),
    .io_irq()
);

endmodule
