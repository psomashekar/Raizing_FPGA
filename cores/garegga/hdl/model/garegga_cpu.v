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
module garegga_cpu (
    input CLK,
    input CLK96,
    input RESET,
    input RESET96,
    input GP9001ACK,
    input Z80ACK,
    input VINT,
    input BR,
    input [8:0] V,
    output BUSACK,
    input LVBL,

    output [19:1] ADDR,
    output [15:0] DOUT,
    output RW,
    output RD,
    output LDS,
    output LDSWR,
    output GP9001CS,
    output LTABLECS,
    output VCOUNTCS,
    output Z80RST,
    output CEN16,
    output CEN16B,

    // cabinet I/O
    input [1:0]  JOYMODE,
    input [9:0]  JOYSTICK1,
    input [9:0]  JOYSTICK2,
    input [3:0]  START_BUTTON,
    input [3:0]  COIN_INPUT,
    input        SERVICE,
    input        TILT,

	 // DIP switches
    input        DIP_TEST,
    input        DIP_PAUSE,
    input [7:0]	 DIPSW_A,
    input [7:0]	 DIPSW_B,
    input [7:0]	 DIPSW_C,

    //68k rom interface
    output            CPU_PRG_CS,
    input             CPU_PRG_OK,
    output reg [18:0] CPU_PRG_ADDR, //16bit addressing
    input      [15:0] CPU_PRG_DATA,

    //gcu interface
    output reg       GP9001_OP_SELECT_REG,
    output reg       GP9001_OP_WRITE_REG,
    output reg       GP9001_OP_WRITE_RAM,
    output reg       GP9001_OP_READ_RAM_H,
    output reg       GP9001_OP_READ_RAM_L,
    output reg       GP9001_OP_SET_RAM_PTR,
    input     [15:0] GP9001_DOUT,
    input            HSYNC,
    input            VSYNC,
    input            FBLANK,
    input      [7:0] GAME,
    input            FLIP,

    //text VRAM interface
    //text vram
    input [11:0] TEXTVRAM_ADDR,
    output [15:0] TEXTVRAM_DATA,

    //palette ram
    input [10:0] PALRAM_ADDR,
    output [15:0] PALRAM_DATA,

    //text select ram
    input [7:0] TEXTSELECT_ADDR,
    output [15:0] TEXTSELECT_DATA,

    //text scroll ram
    input [7:0] TEXTSCROLL_ADDR,
    output [15:0] TEXTSCROLL_DATA,

    //z80 interface
    output reg [7:0] SOUNDLATCH,
    input [13:0] SRAM_ADDR,
    output [7:0] SRAM_DATA,
    input [7:0] SRAM_DIN,
    input SRAM_WE,
    input Z80WAIT,
    output reg Z80INT,
    output reg OKI_BANK,

    //hiscore interface
    output		   HISCORE_CS,
	output   [1:0] HISCORE_WE,
	output   [15:0] HISCORE_DIN,
	input    [15:0] HISCORE_DOUT,
	output   [6:0] HISCORE_ADDR 
);

localparam GAREGGA = 'h0, KINGDMGP = 'h2, SSTRIKER = 'h1;

//address bus
wire [23:1] A;
wire [23:0] addr_8 = {A[23:1], 1'b0}; //this makes it easier to follow the memory map.
wire [15:0] cpu_dout;
wire sel_ram, sel_sram, sel_rom, sel_ram2;
reg ram_ok = 1'b1;
reg sel_z80, sel_gp9001, sel_io;
reg dsn_dly;
reg pre_sel_ram, pre_sel_sram, pre_sel_rom, pre_sel_zrom,  
    reg_sel_ram, reg_sel_sram, reg_sel_rom, reg_sel_zrom;
reg pre_sel_palram,
    pre_sel_txvram,
    pre_sel_txlineselect,
    pre_sel_txlinescroll,
    pre_sel_ram2;
reg reg_sel_palram,
    reg_sel_txvram,
    reg_sel_txlineselect,
    reg_sel_txlinescroll,
    reg_sel_ram2;
wire sel_palram, sel_txvram, sel_txlineselect, sel_txlinescroll, sel_txram;
wire [15:0] wram_cpu_data = !RW && (sel_ram || sel_sram || sel_palram || 
                                    sel_txvram || sel_txlineselect || sel_txlinescroll || sel_ram2) ? cpu_dout : 16'h0000;
wire [15:0] main_ram_q0;
wire [7:0] main_sram_q0;
wire [15:0] main_palram_q0;
wire [15:0] main_txvram_q0;
wire [15:0] main_txlineselect_q0;
wire [15:0] main_txlinescroll_q0;
wire [15:0] main_ram2_q0;

wire [15:0] main_vram_q1;

//hiscore
reg sel_hiscore;
wire [23:0] addr_8_plus = {A[23:1], UDSn && !LDSn}; //makes it easier for odd address boundaries
assign HISCORE_CS = sel_hiscore;
assign HISCORE_ADDR = GAME == GAREGGA && (addr_8 >='h10CA4C) && (addr_8<'h10CA4C+'hEC) ? (addr_8-'h10CA4C)>>1 : //length:236
                      'hx;
assign HISCORE_DIN = cpu_dout;
assign HISCORE_WE = {sel_hiscore && !RW && !UDSn, sel_hiscore && !RW && !LDSn} & {2{hiscore_init}};

//the first 19 bits are used to address other devices (ie. ROM/RAM). The rest are used for selects.
assign ADDR[19:1] = A[19:1];
assign DOUT = cpu_dout;
reg [15:0] cpu_din;
wire BUSn, UDSn, LDSn, ASn, LDSWn, UDSWn;
assign LDS = LDSn;
assign LDSWR = LDSWn;
assign BUSn  = ASn | (UDSn & LDSn);
assign UDSWn = RW | UDSn;
assign LDSWn = RW | LDSn;

// ram_cs and vram_cs signals go down before DSWn signals
// that causes a false read request to the SDRAM. In order
// to avoid that a little bit of logic is needed:
assign sel_ram   = pre_sel_ram; //~BUSn & (dsn_dly ? reg_sel_ram  : pre_sel_ram);
assign sel_sram  = pre_sel_sram; //~BUSn & (dsn_dly ? reg_sel_sram : pre_sel_sram);
assign sel_rom   = ~BUSn & (dsn_dly ? reg_sel_rom : pre_sel_rom);
assign sel_palram = pre_sel_palram;
assign sel_txvram = pre_sel_txvram;
assign sel_txlineselect = pre_sel_txlineselect;
assign sel_txlinescroll = pre_sel_txlinescroll;
assign sel_ram2 = pre_sel_ram2;
assign CPU_PRG_CS = sel_rom;

always @(posedge CLK96, posedge RESET96) begin
    if( RESET96 ) begin
        reg_sel_rom <= 0;
        reg_sel_ram  <= 0;
        reg_sel_sram <= 0;
        reg_sel_palram <= 0;
        reg_sel_txvram <= 0;
        reg_sel_txlineselect <= 0;
        reg_sel_txlinescroll <= 0;
        reg_sel_ram2 <= 0;
        dsn_dly  <= 1;
    end else if(CEN16) begin
        reg_sel_rom <= pre_sel_rom;
        reg_sel_ram  <= pre_sel_ram;
        reg_sel_sram <= pre_sel_sram;
        reg_sel_palram <= pre_sel_palram;
        reg_sel_txvram <= pre_sel_txvram;
        reg_sel_txlineselect <= pre_sel_txlineselect;
        reg_sel_txlinescroll <= pre_sel_txlineselect;
        reg_sel_ram2 <= pre_sel_ram2;
        dsn_dly     <= &{UDSWn,LDSWn}; // low if any DSWn was low
    end
end

wire bus_legit = sel_z80 & Z80WAIT;

wire FC0, FC1, FC2;
wire VPAn = ~&{ FC0, FC1, FC2, ~ASn};
wire BRn, BGACKn, BGn, DTACKn;
wire bus_cs = |{ pre_sel_rom, pre_sel_ram, pre_sel_sram, pre_sel_palram, pre_sel_txvram, pre_sel_txlineselect,
                 pre_sel_txlinescroll, pre_sel_ram2, sel_gp9001, sel_io, sel_z80};
wire bus_busy = |{ (sel_ram || sel_sram || sel_palram || 
                    sel_txvram || sel_txlineselect || 
                    sel_txlinescroll || sel_ram2) & ~ram_ok, sel_rom & ~CPU_PRG_OK, sel_gp9001 & ~GP9001ACK, bus_legit};

//i/o bus ports
reg gp9001_vdp_device_r_cs, gp9001_vdp_device_w_cs, read_port_in1_r_cs, read_port_in2_r_cs, 
    read_port_sys_r_cs, read_port_dswa_r_cs, read_port_dswb_r_cs, read_port_jmpr_r_cs, 
    toaplan2_coinword_w_cs, soundlatch_w, video_count_r_cs;

//debugging 
 wire debug = 1'b1;
 integer fd;

 `ifdef SIMULATION
 initial fd = $fopen("log.txt", "w");
`endif

wire hiscore_init_end_0 = GAME == GAREGGA ? addr_8_plus=='h10CB36 && cpu_dout[15:8] == 'h2A :
                          'h0;

reg hiscore_init = 0;
reg last_hiscore_init_end_0 = 0;

always @(posedge CLK96 or posedge RESET96) begin
    if(RESET96) begin
        pre_sel_rom<=0;
        pre_sel_ram<=0;
        pre_sel_sram<=0;
        pre_sel_palram<=0;
        pre_sel_txvram<=0;
        pre_sel_txlineselect<=0;
        pre_sel_txlinescroll<=0;
        pre_sel_ram2<=0;
        sel_gp9001<=0;
        sel_io<=0;
        CPU_PRG_ADDR<=19'd0;
        sel_z80<=1'b0;
        last_hiscore_init_end_0 <= 0;
    end else begin
        
        if(!ASn && BGACKn) begin
            last_hiscore_init_end_0<=hiscore_init_end_0;
            //debugging 
            // $display("time: %t, addr: %h, uds: %h, lds: %h, rw: %h, cpu_dout: %h, cpu_din: %h, sel_status: %b\n", $time/1000, addr_8, UDSn, LDSn, RW, cpu_dout, cpu_din, {sel_rom, sel_ram, sel_sram, sel_z80, sel_gp9001, sel_io});
             if(debug) 
                $fwrite(fd, "time: %t, addr: %h, uds: %h, lds: %h, rw: %h, cpu_dout: %h, cpu_din: %h, sel_status: %b\n", $time/1000, addr_8, UDSn, LDSn, RW, cpu_dout, cpu_din, {sel_rom, sel_ram, sel_sram, sel_z80, sel_gp9001, sel_io});
            
            //68k ROM
            pre_sel_rom <= GAME == SSTRIKER ? addr_8 <= 'h7FFFF : 
                                              addr_8 <= 'hFFFFF; //0x0 - 0xFFFFF for GAREGGA and KINGDMGP, 0x0-0x7FFFF for SSTRIKER
            CPU_PRG_ADDR <= A[19:1];

            //RAM
            pre_sel_ram <= addr_8[23:16] == 8'b0001_0000; // 0x100000 - 0x10FFFF

            sel_hiscore <= GAME == GAREGGA && (addr_8 >='h10CA4C) && (addr_8 < 'h10CA4C+'hEC);
            //hiscore hook
            if(!hiscore_init && !hiscore_init_end_0 && last_hiscore_init_end_0) hiscore_init<=1;
            
            //Shared RAM
            pre_sel_sram <= addr_8[23:14] == 10'b0010_0001_10; //0x218000 - 0x21BFFF

            //GP9001
            sel_gp9001 <= addr_8[23:20] == 4'b0011; //0x300000 - 0x30000D

            //direct access to vtx ram, no dma controller
            pre_sel_palram <= addr_8[23:20] == 4'b0100; //0x400000 - 0x400FFF
            pre_sel_txvram <= GAME == GAREGGA ? addr_8 >= 'h500000 && addr_8 <= 'h501FFF :
                                                addr_8 >= 'h500000 && addr_8 <= 'h501FFF; //0x500000 - 0x501FFF
            pre_sel_txlineselect <= addr_8 >= 'h502000 && addr_8 <= 'h502FFF; //0x502000 - 0x502FFF //first 0x200 is lineselect
            pre_sel_txlinescroll <= addr_8 >= 'h503000 && addr_8 <= 'h503FFF; //0x503000 - 0x503FFF // first 0x200 is linescroll
            pre_sel_ram2 <= addr_8[23:12] == 12'b0100_0000_0001; //0x401000 - 0x4017FF

            //IO
            sel_io <= addr_8[23:12] == 12'b0010_0001_1100; //0x21C01C - 0x21C03D

            sel_z80 <= soundlatch_w;

        end else begin
            pre_sel_rom<=0;
            pre_sel_ram<=0;
            pre_sel_sram<=0;
            pre_sel_palram<=0;
            pre_sel_txvram<=0;
            pre_sel_txlineselect<=0;
            pre_sel_txlinescroll<=0;
            pre_sel_ram2<=0;
            sel_gp9001<=0;
            sel_io<=0;
            sel_z80<=1'b0;
        end
    end
end

// I/O
always @(*) begin
    //gp9001
    gp9001_vdp_device_r_cs = sel_gp9001 && RW; //0x300000-D Read
    gp9001_vdp_device_w_cs = sel_gp9001 && !RW; //0x300000-D Write
    
    //dips, controls
    read_port_in1_r_cs = sel_io && (addr_8[11:0] == 11'h020) && RW; // 0x21C020-21
    read_port_in2_r_cs = sel_io && (addr_8[11:0] == 11'h024) && RW; // 0x21C024-25
    read_port_sys_r_cs = sel_io && (addr_8[11:0] == 11'h028) && RW; // 0x21C028-29
    read_port_dswa_r_cs = sel_io && (addr_8[11:0] == 11'h02c) && RW; // 0x21C02c-2d
    read_port_dswb_r_cs = sel_io && (addr_8[11:0] == 11'h030) && RW; // 0x21C030-31
    read_port_jmpr_r_cs = sel_io && (addr_8[11:0] == 11'h034) && RW; // 0x21C034-35

    //vcount
    video_count_r_cs = sel_io && (addr_8[11:0] == 11'h03c) && RW; //0x21C03c-d

    //coin
    toaplan2_coinword_w_cs = sel_io && (addr_8[11:0] == 11'h01c); //0x21C01c-d

    //soundlatch
    soundlatch_w = addr_8[23:20] == 4'b0110 && !RW; //0x600001
end

wire [15:0] video_status_hs = (16'hFF00 & (!HSYNC ? ~16'h8000 : 16'hFFFF));
wire [15:0] video_status_vs = (16'hFF00 & (!VSYNC ? ~16'h4000 : 16'hFFFF));
wire [15:0] video_status_fb = (16'hFF00 & (!FBLANK ? ~16'h100 : 16'hFFFF));
wire [15:0] video_status = V < 256 ? (video_status_hs & video_status_vs & video_status_fb) | (V & 8'hFF) :
                                     (video_status_hs & video_status_vs & video_status_fb) | 8'hFF;

//JTFRAME is low active, but batrider is high active.

wire [7:0] p1_ctrl = {1'b0, ~JOYSTICK1[6],~JOYSTICK1[5],~JOYSTICK1[4],~JOYSTICK1[0],~JOYSTICK1[1],~JOYSTICK1[2],~JOYSTICK1[3]};
wire [7:0] p2_ctrl = {1'b0, ~JOYSTICK2[6],~JOYSTICK2[5],~JOYSTICK2[4],~JOYSTICK2[0],~JOYSTICK2[1],~JOYSTICK2[2],~JOYSTICK2[3]};

always @(posedge CLK96, posedge RESET96) begin
    if(RESET96) cpu_din <= 16'h0000;
    else begin
        cpu_din <= sel_gp9001 && RW ? GP9001_DOUT : //gcu
                   sel_rom ? CPU_PRG_DATA : //cpu program
                   
                   sel_hiscore && hiscore_init ? HISCORE_DOUT : //hiscore reads take precedence over ram.
                   sel_ram && RW ? main_ram_q0 ://ram reads
                   sel_sram && RW ? main_sram_q0 ://ram reads
                   sel_palram && RW ? main_palram_q0 :
                   sel_txvram && RW ? main_txvram_q0 :
                   sel_txlineselect && RW ? main_txlineselect_q0 :
                   sel_txlinescroll && RW ? main_txlinescroll_q0 :
                   sel_ram2 && RW ? main_ram2_q0 :

                   (GAME == KINGDMGP || GAME == SSTRIKER) && gp9001_vdp_device_r_cs && addr_8[3:0] == 'b1100 ? {15'b0, ~int1} :

                   read_port_in1_r_cs ? {2{p1_ctrl}} : //controller inputs
                   read_port_in2_r_cs ? {2{p2_ctrl}} :
                   read_port_sys_r_cs ? {2{DIPSW_C, 1'b0, ~START_BUTTON[1], ~START_BUTTON[0], ~COIN_INPUT[1], ~COIN_INPUT[0], ~DIP_TEST, 1'b0, ~SERVICE}} :
                   read_port_dswa_r_cs ? {2{DIPSW_A}} :
                   read_port_dswb_r_cs ? {2{DIPSW_B}} :
                   read_port_jmpr_r_cs ? {2{DIPSW_C}} :
                   video_count_r_cs ? video_status : // blanking trigger
                   toaplan2_coinword_w_cs ? 16'h0000 : //ignore coin counter.
                   16'h0000; //etc.
    end
end  

//cpu bus actions for IO
wire inta_n = ~&{ FC0, FC1, FC2, A[19:16] }; // ctrl like M68000's manual

always @(posedge CLK96) begin
    if(RESET96) begin
        SOUNDLATCH<=8'h0;
        GP9001_OP_SELECT_REG <= 1'b0;
        GP9001_OP_WRITE_REG <= 1'b0;
        GP9001_OP_WRITE_RAM <= 1'b0;
        GP9001_OP_READ_RAM_H <= 1'b0;
        GP9001_OP_READ_RAM_L <= 1'b0;
        GP9001_OP_SET_RAM_PTR <= 1'b0;
        Z80INT<=1'b0;
        OKI_BANK<=0;
    end else begin
        if(GAME == KINGDMGP && toaplan2_coinword_w_cs && !RW) begin
            OKI_BANK <= cpu_dout[4];
        end
        if(GAME == GAREGGA && soundlatch_w) begin
            SOUNDLATCH <= cpu_dout[7:0];
            Z80INT<=1'b1;
        end
        else if(gp9001_vdp_device_r_cs) begin
            case(addr_8[3:0])
                4'b0100: GP9001_OP_READ_RAM_H <= 1'b1; //4
                4'b0110: GP9001_OP_READ_RAM_L <= 1'b1; //6
            endcase
        end
        else if(gp9001_vdp_device_w_cs) begin
            case(addr_8[3:0])
                4'b1100: GP9001_OP_WRITE_REG <= 1'b1; //0
                4'b1000: GP9001_OP_SELECT_REG <= 1'b1; //8
                4'b0100, 4'b0110: GP9001_OP_WRITE_RAM <= 1'b1; //4 or 6
                4'b0000: GP9001_OP_SET_RAM_PTR <= 1'b1; //0
            endcase
        end
        else begin       
            Z80INT<=1'b0;     
            if(GP9001ACK) begin
                GP9001_OP_SELECT_REG <= 1'b0;
                GP9001_OP_WRITE_REG <= 1'b0;
                GP9001_OP_WRITE_RAM <= 1'b0;
                GP9001_OP_READ_RAM_H <= 1'b0;
                GP9001_OP_READ_RAM_L <= 1'b0;
                GP9001_OP_SET_RAM_PTR <= 1'b0;
            end
        end
    end
end

//address bits 19 to 23 go to the E68DEC1B chip.
wire vint_n, int1;
jtframe_ff u_int_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( vint_n       ),
    .set      ( 1'b0        ),    // active high
    .clr      ( ~inta_n ),    // active high
    .sigedge  ( VINT ) // signal whose edge will trigger the FF
);

jtframe_virq u_virq(
    .rst        ( RESET96       ),
    .clk        ( CLK96       ),
    .LVBL       ( LVBL      ),
    .dip_pause  ( DIP_PAUSE ),
    .skip_en    (    ),
    .skip_but   (    ),
    .clr        ( ~inta_n ),
    .custom_in  ( ),
    .blin_n     ( int1      ),
    .blout_n    (           ),
    .custom_n   (       )
);

//68k cpu running at 16mhz
jtframe_68kdtack #(.W(10)) u_dtack(
    .rst        (RESET96),
    .clk        (CLK96),
    .cpu_cen    (CEN16),
    .cpu_cenb   (CEN16B),
    .bus_cs     (bus_cs),
    .bus_busy   (bus_busy),
    .bus_legit  (1'b0),
    .ASn        (ASn),
    .DSn        ({UDSn, LDSn}),
    .num        (10'd32),
    .den        (10'd189),
    .DTACKn     (DTACKn),
    // unused
    .fave       (),
    .fworst     (),
    .frst       ()
);

assign BUSACK = ~BGACKn;

jtframe_68kdma #(.BW(1)) u_arbitration(
    .clk        (CLK96),
    .cen        (CEN16B),
    .rst        (RESET96),
    .cpu_BRn    (BRn),
    .cpu_BGACKn (BGACKn),
    .cpu_BGn    (BGn),
    .cpu_ASn    (ASn),
    .cpu_DTACKn (DTACKn),
    .dev_br     (BR)
);

fx68k u_011 (
    .clk        (CLK96),
    .extReset   (RESET96),
    .pwrUp      (RESET96),
    .enPhi1     (CEN16),
    .enPhi2     (CEN16B),

    // Buses
    .eab        (A),
    .iEdb       (cpu_din),
    .oEdb       (cpu_dout),

    .eRWn       (RW),
    .LDSn       (LDSn),
    .UDSn       (UDSn),
    .ASn        (ASn),
    .VPAn       (VPAn),
    .FC0        (FC0), 
    .FC1        (FC1),
    .FC2        (FC2),

    .BERRn      (1'b1),

    .HALTn      (DIP_PAUSE),
    .BRn        (BRn),
    .BGACKn     (BGACKn),
    .BGn        (BGn),

    .DTACKn     (DTACKn),
    .IPL0n      (1'b1),
    .IPL1n      (1'b1),
    .IPL2n      (int1),

    // Unused
    .oRESETn    (),
    .oHALTEDn   (),
    .VMAn       (),
    .E          ()
);

//CPU WRAM 0x100000-0x10FFFF
jtframe_dual_ram16 #(.aw(15)) u_cpu_wram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes & reads from 68k
    .data0(wram_cpu_data),
    .addr0(A[15:1]),
    .we0({sel_ram && !RW && !UDSn, sel_ram && !RW && !LDSn}),
    .q0(),
    // Port 1
    .data1(),
    .addr1(A[15:1]),
    .we1(2'b00),
    .q1(main_ram_q0)
);

//8 bit addressing
jtframe_dual_ram #(.dw(8), .aw(14)) u_sram_ram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes reads from 68k
    .data0(wram_cpu_data[7:0]),
    .addr0((addr_8>>1) & 'h3FFF),
    .we0(sel_sram && !RW),
    .q0(main_sram_q0),
    // Port 1 writes reads from z80
    .data1(SRAM_DIN),
    .addr1(SRAM_ADDR),
    .we1(SRAM_WE),
    .q1(SRAM_DATA)
);

//Palette RAM 0x400000 - 0x400FFF
jtframe_dual_ram16 #(.aw(11)) u_palram_ram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes
    .data0(wram_cpu_data),
    .addr0(A[11:1]),
    .we0({sel_palram && !RW && !UDSn, sel_palram && !RW && !LDSn}),
    .q0(main_palram_q0),
    // Port 1
    .data1(),
    .addr1(PALRAM_ADDR),
    .we1(2'b00),
    .q1(PALRAM_DATA)
);

//Text VRAM 0x500000 - 0x501FFF
jtframe_dual_ram16 #(.aw(12)) u_txvram_ram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes
    .data0(wram_cpu_data),
    .addr0(A[12:1]),
    .we0({sel_txvram && !RW && !UDSn, sel_txvram && !RW && !LDSn}),
    .q0(main_txvram_q0),
    // Port 1
    .data1(),
    .addr1(TEXTVRAM_ADDR),
    .we1(2'b00),
    .q1(TEXTVRAM_DATA)
);

//Text Lineselect 0x502000 - 0x502FFF (first 0x200)
jtframe_dual_ram16 #(.aw(11)) u_txlineselect_ram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes
    .data0(wram_cpu_data),
    .addr0(A[11:1]),
    .we0({sel_txlineselect && !RW && !UDSn, sel_txlineselect && !RW && !LDSn}),
    .q0(main_txlineselect_q0),
    // Port 1
    .data1(),
    .addr1(TEXTSELECT_ADDR),
    .we1(2'b00),
    .q1(TEXTSELECT_DATA)
);

//Text Linescroll 0x503000 - 0x503FFF (first 0x200)
jtframe_dual_ram16 #(.aw(11)) u_txlinescroll_ram(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes
    .data0(wram_cpu_data),
    .addr0(A[11:1]),
    .we0({sel_txlinescroll && !RW && !UDSn, sel_txlinescroll && !RW && !LDSn}),
    .q0(main_txlinescroll_q0),
    // Port 1
    .data1(),
    .addr1(TEXTSCROLL_ADDR),
    .we1(2'b00),
    .q1(TEXTSCROLL_DATA)
);

//RAM2, but not used 0x401000 - 0x4017FF
jtframe_dual_ram16 #(.aw(10)) u_cpu_wram2(
    .clk0(CLK96),
	.clk1(CLK96),
    // Port 0 writes
    .data0(wram_cpu_data),
    .addr0(A[10:1]),
    .we0({sel_ram2 && !RW && !UDSn, sel_ram2 && !RW && !LDSn}),
    .q0(main_ram2_q0),
    // Port 1
    .data1(),
    .addr1(),
    .we1(2'b00),
    .q1()
);

endmodule