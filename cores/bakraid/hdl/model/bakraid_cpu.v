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
module bakraid_cpu (
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
    input FLIP,

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
    output reg [19:0] CPU_PRG_ADDR, //16bit addressing
    input      [15:0] CPU_PRG_DATA,

    //Z80 rom interface
    output            Z80_PRG_CS,
    input             Z80_PRG_OK,
    output reg [17:0] Z80_PRG_ADDR,
    input      [7:0] Z80_PRG_DATA, 

    //DMA RAM interface
    input         DMA_RAM_CS,
    output [15:0] DMA_RAM_DOUT,
    input  [13:0] DMA_RAM_ADDR,
    output reg    BATRIDER_TEXTDATA_DMA_W,
    output reg    BATRIDER_PAL_TEXT_DMA_W,
    input         TVRAMCTL_BUSY,
    //this is only really needed on bootup to copy the text rom.
    output        TVRAM_CS,
    output        TVRAM_WE,
    output [1:0]  TVRAM_DS,
    output [13:0] TVRAM_WR_ADDR,
    output [15:0] TVRAM_DIN,

    //gcu interface
    output reg       GP9001_OP_SELECT_REG,
    output reg       GP9001_OP_WRITE_REG,
    output reg       GP9001_OP_WRITE_RAM,
    output reg       GP9001_OP_READ_RAM_H,
    output reg       GP9001_OP_READ_RAM_L,
    output reg       GP9001_OP_SET_RAM_PTR,
    output reg       GP9001_OP_OBJECTBANK_WR,
    output reg [2:0] GP9001_OBJECTBANK_SLOT,
    input     [15:0] GP9001_DOUT,
    input            HSYNC,
    input            VSYNC,
    input            FBLANK,

    //z80 interface
    input [7:0] SOUNDLATCH3,
    input [7:0] SOUNDLATCH4,
    output reg [7:0] SOUNDLATCH,
    output reg [7:0] SOUNDLATCH2,
    input Z80WAIT,
    output Z80CS,
    output reg NMI,
    input SNDIRQ,
    output reg [1:0] SOUNDLATCH_ACK,
    input [1:0] SOUNDLATCH_ACK_INCOMING,

    //eeprom interface
    output reg         EEPROM_SCLK,
    output reg         EEPROM_SDI,
    input              EEPROM_SDO,
    output reg         EEPROM_SCS
);

//address bus
wire [23:1] A;
wire [23:0] addr_8 = {A[23:1], 1'b0}; //this makes it easier to follow the memory map.
wire [15:0] cpu_dout;
wire sel_ram, sel_vram, sel_rom, sel_zrom;
reg ram_ok = 1'b1;
reg sel_z80, sel_gp9001, sel_io;
reg dsn_dly;
reg pre_sel_ram, pre_sel_vram, pre_sel_rom, pre_sel_zrom, reg_sel_ram, reg_sel_vram, reg_sel_rom, reg_sel_zrom;
reg text_rom_unpacked = 1'b0;
wire [15:0] wram_cpu_data = !RW && (sel_ram || sel_vram) ? cpu_dout : 16'h0000;
assign {TVRAM_WE, TVRAM_CS} = {2{~text_rom_unpacked && sel_vram}};

assign TVRAM_DIN = cpu_dout;
assign TVRAM_WR_ADDR = addr_8[14:1];
wire [15:0] main_ram_q1;
wire [15:0] main_vram_q1;
// assign DMA_RAM_DOUT = main_vram_q1;

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
assign TVRAM_DS = {~UDSn, ~LDSn};

// ram_cs and vram_cs signals go down before DSWn signals
// that causes a false read request to the SDRAM. In order
// to avoid that a little bit of logic is needed:
assign sel_ram   = pre_sel_ram; //~BUSn & (dsn_dly ? reg_sel_ram  : pre_sel_ram);
assign sel_vram  = pre_sel_vram; //~BUSn & (dsn_dly ? reg_sel_vram : pre_sel_vram);
assign sel_rom   = ~BUSn & (dsn_dly ? reg_sel_rom : pre_sel_rom);
assign sel_zrom  = pre_sel_zrom; //~BUSn & (dsn_dly ? reg_sel_zrom : pre_sel_zrom);
assign CPU_PRG_CS = sel_rom;
assign Z80_PRG_CS = sel_zrom;

//interrupts
//line 2 == VLBANK
//line 4 == sound
//line 0 == dma controller
reg [2:0] intr = 3'b111;

always @(posedge CLK96, posedge RESET96) begin
    if( RESET96 ) begin
        reg_sel_rom <= 0;
        reg_sel_ram  <= 0;
        reg_sel_vram <= 0;
        reg_sel_zrom <= 0;
        dsn_dly  <= 1;
    end else if(CEN16) begin
        reg_sel_rom <= pre_sel_rom;
        reg_sel_ram  <= pre_sel_ram;
        reg_sel_vram <= pre_sel_vram;
        reg_sel_zrom <= pre_sel_zrom;
        dsn_dly     <= &{UDSWn,LDSWn}; // low if any DSWn was low
    end
end

wire FC0, FC1, FC2;
wire VPAn = ~&{ FC0, FC1, FC2, ~ASn};
wire BRn, BGACKn, BGn, DTACKn;
wire bus_cs = |{ pre_sel_rom, pre_sel_ram, pre_sel_vram, pre_sel_zrom, sel_gp9001, sel_io, sel_z80};
wire bus_busy = |{ (sel_ram | sel_vram) & ~ram_ok, sel_rom & ~CPU_PRG_OK, sel_zrom & ~Z80_PRG_OK, sel_gp9001 & ~GP9001ACK, sel_z80 & Z80WAIT};

//batrider i/o bus ports
reg gp9001_vdp_device_r_cs, gp9001_vdp_device_w_cs, read_port_in_r_cs, read_port_sys_dsw_r_cs, 
    read_port_dsw_r_cs, video_count_r_cs, soundlatch3_r_cs, soundlatch4_r_cs, 
    toaplan2_coinword_w_cs, batrider_soundlatch_w_cs, batrider_soundlatch2_w_cs,
    batrider_unk_sound_w_cs, batrider_clr_sndirq_w_cs, batrider_textdata_dma_w_cs,
    batrider_unk_dma_w, batrider_objectbank_w_cs, bakraid_eeprom_r, bakraid_eeprom_w;

//debugging 
 wire debug = 1'b1;
 integer fd;

 `ifdef SIMULATION
 initial fd = $fopen("log.txt", "w");
`endif

always @(posedge CLK96 or posedge RESET96) begin
    if(RESET96) begin
        pre_sel_rom<=0;
        pre_sel_ram<=0;
        pre_sel_vram<=0;
        pre_sel_zrom<=0;
        sel_gp9001<=0;
        sel_io<=0;
        CPU_PRG_ADDR<=20'd0;
    end else begin
        
        if(!ASn && BGACKn) begin
            //debugging 
            // $display("time: %t, addr: %h, uds: %h, lds: %h, rw: %h, cpu_dout: %h, cpu_din: %h, sel_status: %b\n", $time/1000, addr_8, UDSn, LDSn, RW, cpu_dout, cpu_din, {sel_rom, sel_ram, sel_vram, sel_z80, sel_gp9001, sel_io});
             if(debug) 
                $fwrite(fd, "time: %t, addr: %h, uds: %h, lds: %h, rw: %h, cpu_dout: %h, cpu_din: %h, sel_status: %b\n", $time/1000, addr_8, UDSn, LDSn, RW, cpu_dout, cpu_din, {sel_rom, sel_ram, sel_vram, sel_z80, sel_gp9001, sel_io});
            
            //68k ROM
            pre_sel_rom <= addr_8[23:21] == 3'b000; //0x0 - 0x1FFFFF
            CPU_PRG_ADDR <= A[20:1];

            //VRAM
            pre_sel_vram <= addr_8[23:15] == 9'b0010_0000_0; // 0x200000 - 0x207FFF
            
            //68k WRAM
            pre_sel_ram <= addr_8[23:15] == 9'b0010_0000_1; //0x208000 - 0x20FFFF

            //Z80 ROM
            pre_sel_zrom <= addr_8[23:20] == 4'b0011; // 0x300000 - 0x33FFFF
            Z80_PRG_ADDR <= ((addr_8 & 'h7FFFF) >> 1);

            //GP9001
            sel_gp9001 <= addr_8[23:20] == 4'b0100; //0x400000 - 0x40000D

            //IO
            sel_io <= addr_8[23:20] == 4'b0101; //0x500000 - 0x5000CF

        end else begin
            pre_sel_rom<=0;
            pre_sel_ram<=0;
            pre_sel_vram<=0;
            pre_sel_zrom<=0;
            sel_gp9001<=0;
            sel_io<=0;
        end
    end
end

// I/O
always @(*) begin
    gp9001_vdp_device_r_cs = sel_gp9001 && RW; //0x400000-D Read
    gp9001_vdp_device_w_cs = sel_gp9001 && !RW; //0x400000-D Write
    read_port_in_r_cs = sel_io && (addr_8[7:0] == 8'h0); //0x500000-1
    read_port_sys_dsw_r_cs = sel_io && (addr_8[7:0] == 8'h2); //0x500002-3
    read_port_dsw_r_cs = sel_io && (addr_8[7:0] == 8'h4); //0x500004-5
    video_count_r_cs = sel_io && (addr_8[7:0] == 8'h6); //0x500006-7
    toaplan2_coinword_w_cs = sel_io && (addr_8[7:0] == 8'h08); //0x500009
    soundlatch3_r_cs = sel_io && (addr_8[7:0] == 8'h10); //0x500010-11
    soundlatch4_r_cs = sel_io && (addr_8[7:0] == 8'h12); //0x500012-13
    batrider_soundlatch_w_cs = sel_io && (addr_8[7:0] == 8'h14) && !LDSn && !RW; //0x500015
    batrider_soundlatch2_w_cs = sel_io && (addr_8[7:0] == 8'h16) && !LDSn && !RW; //0x500017
    bakraid_eeprom_r = sel_io && (addr_8[7:0] == 8'h18) && RW; //0x500018-19
    batrider_unk_sound_w_cs = sel_io && (addr_8[7:0] == 8'h1a); //0x50001a-1b
    batrider_clr_sndirq_w_cs = sel_io && (addr_8[7:0] == 8'h1c); //0x50001c-1d
    bakraid_eeprom_w = sel_io && (addr_8[7:0] == 8'h1e) && !RW; //0x50001f
    batrider_textdata_dma_w_cs = sel_io && (addr_8[7:0] == 8'h80); //0x500080-81
    batrider_unk_dma_w = sel_io && (addr_8[7:0] == 8'h82); //0x500082
    batrider_objectbank_w_cs = sel_io && addr_8[7:4] == 4'hC; //0x5000C0-CF
end

assign Z80CS = sel_z80;

//storage registers
reg z80_bus_request;

// wire [7:0] fake_soundlatch_3 = shared_ram[0] == 16'h55 ? 16'hAA : shared_ram[0]; 
// wire [7:0] fake_soundlatch_4 = shared_ram[1]; 

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
        // if(soundlatch3_r_cs) $display("soundlatch:%h, soundlatch3_r:%h, fake_3:%h", SOUNDLATCH, SOUNDLATCH3, fake_soundlatch_3);
        // if(soundlatch4_r_cs) $display("soundlatch2:%h, soundlatch4_r:%h, fake_4:%h", SOUNDLATCH2, SOUNDLATCH4, fake_soundlatch_4);
        cpu_din <= sel_gp9001 && RW ? GP9001_DOUT : //gcu
                   sel_rom ? CPU_PRG_DATA : //cpu program
                   sel_ram ? main_ram_q1 ://ram reads
                   sel_vram ? main_vram_q1 ://ram reads
                   sel_zrom ? Z80_PRG_DATA : // z80 program
                   read_port_in_r_cs ? {p2_ctrl, p1_ctrl} : //controller inputs
                   read_port_sys_dsw_r_cs ? {DIPSW_C, 1'b0, ~START_BUTTON[1], ~START_BUTTON[0], ~COIN_INPUT[1], ~COIN_INPUT[0], ~DIP_TEST, 1'b0, ~SERVICE} : //dip switch c/ coins
                   read_port_dsw_r_cs ? {DIPSW_B, DIPSW_A} : //dip switch a and b.
                   video_count_r_cs ? video_status : // blanking trigger
                   soundlatch3_r_cs ? SOUNDLATCH3 : //soundlatch3
                   soundlatch4_r_cs ? SOUNDLATCH4 : //soundlatch4
                   bakraid_eeprom_r ? {11'h0, EEPROM_SDO, 3'b000, z80_bus_request} :
                   toaplan2_coinword_w_cs ? 16'h0000 : //ignore coin counter.
                   16'h0000; //etc.
    end
end  

//cpu bus actions for IO
wire inta_n = ~&{ FC0, FC1, FC2, A[19:16] }; // ctrl like M68000's manual
wire snd_irq_ack;

jtframe_ff u_nmi_ff(
    .clk      ( CLK96         ),
    .rst      ( RESET96         ),
    .cen      ( 1'b1        ),
    .din      ( 1'b1        ),
    .q        (             ),
    .qn       ( snd_irq_ack       ),
    .set      ( 1'b0        ),    // active high
    .clr      ( batrider_clr_sndirq_w_cs ),    // active high
    .sigedge  ( SNDIRQ ) // signal whose edge will trigger the FF
);

always @(posedge CLK96) begin
    if(RESET96) begin
        SOUNDLATCH<=8'h0;
        SOUNDLATCH2<=8'h0;
        EEPROM_SCLK<=0;
        EEPROM_SCS<=0;
        EEPROM_SDI<=0;
        z80_bus_request<=1'b0;
        GP9001_OP_SELECT_REG <= 1'b0;
        GP9001_OP_WRITE_REG <= 1'b0;
        GP9001_OP_WRITE_RAM <= 1'b0;
        GP9001_OP_READ_RAM_H <= 1'b0;
        GP9001_OP_READ_RAM_L <= 1'b0;
        GP9001_OP_SET_RAM_PTR <= 1'b0;
        GP9001_OP_OBJECTBANK_WR <= 1'b0;
        BATRIDER_TEXTDATA_DMA_W<=1'b0;
        BATRIDER_PAL_TEXT_DMA_W<=1'b0;
    end else begin
        if(CEN16) begin
            if(bakraid_eeprom_w && !LDSWn) begin
                z80_bus_request <= cpu_dout[4];
                EEPROM_SCLK<= cpu_dout[3];
                EEPROM_SDI<= cpu_dout[2];
                EEPROM_SCS<= cpu_dout[0];
            end
        end

        SOUNDLATCH_ACK<=SOUNDLATCH_ACK_INCOMING; // synchronize from z80

        sel_z80 <= batrider_soundlatch_w_cs || batrider_soundlatch2_w_cs;
        
        if(batrider_soundlatch_w_cs) begin
            SOUNDLATCH <= cpu_dout[7:0];
            SOUNDLATCH_ACK[0] <= 0;
            NMI <= 1;
        end
        else if(batrider_soundlatch2_w_cs) begin
            SOUNDLATCH2 <= cpu_dout[7:0];
            SOUNDLATCH_ACK[1] <= 0;
            NMI <= 1;
        end
        
        else if(batrider_textdata_dma_w_cs) begin 
            BATRIDER_TEXTDATA_DMA_W<=1'b1;
            text_rom_unpacked<=1'b1; //permanently bankswitch out the VRAM for TEXT ROM on bootup.
        end
        else if(batrider_unk_dma_w) begin
            BATRIDER_PAL_TEXT_DMA_W<=1'b1;
        end
        else if(batrider_objectbank_w_cs) begin
            GP9001_OBJECTBANK_SLOT<=addr_8[3:1];
            GP9001_OP_OBJECTBANK_WR<=1'b1;
        end //write to tile bank
        else if(gp9001_vdp_device_r_cs) begin
            case(addr_8[3:0])
                4'b1000: GP9001_OP_READ_RAM_H <= 1'b1; //8
                4'b1010: GP9001_OP_READ_RAM_L <= 1'b1; //A
            endcase
        end
        else if(gp9001_vdp_device_w_cs) begin
            case(addr_8[3:0])
                4'b0000: GP9001_OP_WRITE_REG <= 1'b1; //0
                4'b0100: GP9001_OP_SELECT_REG <= 1'b1; //4
                4'b1000, 4'b1010: GP9001_OP_WRITE_RAM <= 1'b1; //8 or A
                4'b1100: GP9001_OP_SET_RAM_PTR <= 1'b1; //C
            endcase
        end
        else begin
            NMI<=0;

            if(!TVRAMCTL_BUSY) begin
                BATRIDER_TEXTDATA_DMA_W<=1'b0;
                BATRIDER_PAL_TEXT_DMA_W<=1'b0;
            end
            
            if(GP9001ACK) begin
                GP9001_OP_SELECT_REG <= 1'b0;
                GP9001_OP_WRITE_REG <= 1'b0;
                GP9001_OP_WRITE_RAM <= 1'b0;
                GP9001_OP_READ_RAM_H <= 1'b0;
                GP9001_OP_READ_RAM_L <= 1'b0;
                GP9001_OP_SET_RAM_PTR <= 1'b0;
                GP9001_OP_OBJECTBANK_WR <= 1'b0;
            end
        end
    end
end

wire int1, int2;

//address bits 19 to 23 go to the E68DEC1B chip.

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
    .IPL0n      (VINT),
    .IPL1n      (snd_irq_ack),
    .IPL2n      (1'b1),

    // Unused
    .oRESETn    (),
    .oHALTEDn   (),
    .VMAn       (),
    .E          ()
);

//main ram (it might have scrambled addr?)
//wire [14:0] main_ram_addr_from_cpu = DMA_RAM_CS ? DMA_RAM_ADDR : {A[1], A[2], A[3], A[4], A[5], A[6], A[7], A[8], A[13], A[15:14], A[9], A[10], A[12], A[11]};
wire [13:0] main_ram_addr_mux = A[15:1] & 'h3FFF;
// wire [13:0] main_vram_addr_mux = DMA_RAM_CS ? DMA_RAM_ADDR : A[15:1] & 'h3FFF;

//main ram
jtframe_dual_ram #(.dw(8), .aw(14)) u_main_ram_lo_u025(
    .clk0   (CLK96),
    .clk1   (CLK96),
    // Port 0: write
    .data0  (wram_cpu_data[7:0]),
    .addr0  (main_ram_addr_mux),
    .we0    (sel_ram && !RW && !LDSn),
    .q0     (),
    // Port 1: read
    .data1  (),
    .addr1  (main_ram_addr_mux),
    .we1    (1'b0),
    .q1     (main_ram_q1[7:0])
);

jtframe_dual_ram #(.dw(8), .aw(14)) u_main_ram_hi_026(
    .clk0   (CLK96),
    .clk1   (CLK96),
    // Port 0: write
    .data0  (wram_cpu_data[15:8]),
    .addr0  (main_ram_addr_mux),
    .we0    (sel_ram && !RW && !UDSn),
    .q0     (),
    // Port 1: read
    .data1  (),
    .addr1  (main_ram_addr_mux),
    .we1    (1'b0),
    .q1     (main_ram_q1[15:8])
);

//main vram
jtframe_dual_ram #(.dw(8), .aw(14)) u_main_vram_lo_u025(
    .clk0   (CLK96),
    .clk1   (CLK96),
    // Port 0: write
    .data0  (wram_cpu_data[7:0]),
    .addr0  (A[15:1] & 'h3FFF),
    .we0    (sel_vram && !RW && !LDSn),
    .q0     (),
    // Port 1: read
    .data1  (),
    .addr1  (A[15:1] & 'h3FFF),
    .we1    (1'b0),
    .q1     (main_vram_q1[7:0])
);

jtframe_dual_ram #(.dw(8), .aw(14)) u_main_vram_hi_026(
    .clk0   (CLK96),
    .clk1   (CLK96),
    // Port 0: write
    .data0  (wram_cpu_data[15:8]),
    .addr0  (A[15:1] & 'h3FFF),
    .we0    (sel_vram && !RW && !UDSn),
    .q0     (),
    // Port 1: read
    .data1  (),
    .addr1  (A[15:1] & 'h3FFF),
    .we1    (1'b0),
    .q1     (main_vram_q1[15:8])
);

//vram copy for dma
jtframe_dual_ram16 #(.aw(14)) u_main_vram_dma_cpy(
    .clk0(CLK96),
    .clk1(CLK96),
    // Port 0
    .data0(wram_cpu_data),
    .addr0(A[15:1] & 'h3FFF),
    .we0({sel_vram && !RW && !UDSn, sel_vram && !RW && !LDSn}),
    .q0(),
    // Port 1
    .data1(),
    .addr1(DMA_RAM_ADDR),
    .we1(1'b0),
    .q1(DMA_RAM_DOUT)
);


endmodule