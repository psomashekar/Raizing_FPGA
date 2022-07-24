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
/*
Raizing Text VRAM Controller & DMA Controller
*/
module TVRMCTL7 (
    input  CLK,
    input  CLK96,
    input  RESET,
    input  RESET96,
    input  BUSACK,
    output reg BUSREQ,

    //DMA commands
    input      BATRIDER_TEXTDATA_DMA_W,
    input      BATRIDER_PAL_TEXT_DMA_W,
    output reg BUSY,

    //in/out ports to write to DMA RAM from external sources.
    input             TVRAM_CS,
    input             TVRAM_WE,
    input       [1:0] TVRAM_DS,
    input      [13:0] TVRAM_WR_ADDR,
    input      [15:0] TVRAM_DIN,

    //main ram interface for DMA copy
    output reg        DMA_RAM_CS,
    output reg [13:0] DMA_RAM_ADDR,
    input      [15:0] DMA_RAM_DATA,

    //output ports for reading
    //text rom
    input [13:0] TEXTROM_ADDR,
    output [15:0] TEXTROM_DATA,

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

    //text scroll ram
    input [13:0] TEXTGFXRAM_ADDR,
    output [15:0] TEXTGFXRAM_DATA,

    //GP9001 data in
    input [10:0] GP9001OUT
);

reg text_rom_unpacked = 1'b0;
reg [15:0] pre_wr_dma_data;
reg [13:0] pre_wr_dma_addr;

wire textrom_we = TVRAM_WE && !text_rom_unpacked;
wire textvram_we = pre_wr_dma_addr < 14'h1000;
wire palram_we = pre_wr_dma_addr >= 14'h1000 && pre_wr_dma_addr < 14'h1800;
wire textselect_we = pre_wr_dma_addr >= 14'h1800 && pre_wr_dma_addr < 14'h1900;
wire textscroll_we = pre_wr_dma_addr >= 14'h1900 && pre_wr_dma_addr < 14'h1A00;
wire textgfxram_we = pre_wr_dma_addr >= 14'h1A00 && pre_wr_dma_addr <= 14'h3FFF; //it may not be used.

wire [15:0] wr_dma_data = (TVRAM_CS && !text_rom_unpacked) ? TVRAM_DIN : pre_wr_dma_data;
wire [13:0] wr_dma_addr = (TVRAM_CS && !text_rom_unpacked) ? TVRAM_WR_ADDR : pre_wr_dma_addr;

initial BUSREQ = 0;

//DMA commands from CPU
localparam text_pal_len = 13'h1A00;
integer counter = 0;

reg [1:0] st = 1'b0;
always @(posedge CLK96 or posedge RESET96) begin
    if(RESET96) begin
        counter <= 0;
        DMA_RAM_CS <= 1'b0;
        DMA_RAM_ADDR<=0;
        pre_wr_dma_addr<=0;
        st<=0;
    end else if(BATRIDER_TEXTDATA_DMA_W && BUSREQ && BUSACK) begin
        text_rom_unpacked <= 1'b1;
        BUSREQ <= 1'b0;
    end else if(BATRIDER_PAL_TEXT_DMA_W && BUSREQ && BUSACK) begin //called once every vblank interval. (palette and text ram)
        if(counter < text_pal_len) begin
            case(st)
                0: begin
                    DMA_RAM_CS <= 1'b1;
                    DMA_RAM_ADDR <= counter;
                    pre_wr_dma_addr <= counter;
                    st <= 2'b01;
                end

                1: begin
                    st <= 2'b10;
                end

                2: begin
                    pre_wr_dma_data <= DMA_RAM_DATA;
                    counter <= counter + 1;
                    st <= 2'b00;
                end
            endcase
        end else begin
            counter <= 0;
            DMA_RAM_CS <= 1'b0;
            BUSREQ <= 1'b0;
        end
    end else begin
		if(BATRIDER_TEXTDATA_DMA_W || BATRIDER_PAL_TEXT_DMA_W) BUSREQ <= 1'b1;
		else BUSREQ <= 1'b0;
	 end
end

//text rom
jtframe_dual_ram #(.dw(8), .aw(14)) u_textrom_lo(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data[7:0]),
    .addr0  (wr_dma_addr[13:0]),
    .we0    (textrom_we && (TVRAM_CS && TVRAM_DS[1])),
    .q0     (),
    // Port 1: read
    .data1  (~8'h0),
    .addr1  (TEXTROM_ADDR),
    .we1    (1'b0),
    .q1     (TEXTROM_DATA[7:0])
);

jtframe_dual_ram #(.dw(8), .aw(14)) u_textrom_hi(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data[15:8]),
    .addr0  (wr_dma_addr[13:0]),
    .we0    (textrom_we && (TVRAM_CS && TVRAM_DS[0])),
    .q0     (),
    // Port 1: read
    .data1  (~8'h0),
    .addr1  (TEXTROM_ADDR),
    .we1    (1'b0),
    .q1     (TEXTROM_DATA[15:8])
);

jtframe_dual_ram #(.dw(16), .aw(12)) u_textvram(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data),
    .addr0  (wr_dma_addr[11:0]),
    .we0    (textvram_we && DMA_RAM_CS && BATRIDER_PAL_TEXT_DMA_W),
    .q0     (),
    // Port 1: read
    .data1  (~16'h0),
    .addr1  (TEXTVRAM_ADDR),
    .we1    (1'b0),
    .q1     (TEXTVRAM_DATA)
);

jtframe_dual_ram #(.dw(16), .aw(11)) u_paletteram(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data),
    .addr0  (wr_dma_addr[10:0]),
    .we0    (palram_we && DMA_RAM_CS && BATRIDER_PAL_TEXT_DMA_W),
    .q0     (),
    // Port 1: read
    .data1  (~16'h0),
    .addr1  (PALRAM_ADDR),
    .we1    (1'b0),
    .q1     (PALRAM_DATA)
);

jtframe_dual_ram #(.dw(16), .aw(8)) u_textselect(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data),
    .addr0  (wr_dma_addr[7:0]),
    .we0    (textselect_we && DMA_RAM_CS && BATRIDER_PAL_TEXT_DMA_W),
    .q0     (),
    // Port 1: read
    .data1  (~16'h0),
    .addr1  (TEXTSELECT_ADDR),
    .we1    (1'b0),
    .q1     (TEXTSELECT_DATA)
);

jtframe_dual_ram #(.dw(16), .aw(8)) u_textscroll(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data),
    .addr0  (wr_dma_addr[7:0]),
    .we0    (textscroll_we && DMA_RAM_CS && BATRIDER_PAL_TEXT_DMA_W),
    .q0     (),
    // Port 1: read
    .data1  (~16'h0),
    .addr1  (TEXTSCROLL_ADDR),
    .we1    (1'b0),
    .q1     (TEXTSCROLL_DATA)
);

jtframe_dual_ram #(.dw(16), .aw(14)) u_textgfxram(
    .clk0(CLK96),
    .clk1(CLK96),
    .data0  (wr_dma_data),
    .addr0  (wr_dma_addr[13:0]),
    .we0    (textgfxram_we && DMA_RAM_CS && BATRIDER_PAL_TEXT_DMA_W),
    .q0     (),
    // Port 1: read
    .data1  (~16'h0),
    .addr1  (TEXTGFXRAM_ADDR),
    .we1    (1'b0),
    .q1     (TEXTGFXRAM_DATA)
);

endmodule