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
NMK112 for bankswitching OKI6295 sample roms
*/

module NMK112 (
    input CLK,
    input RESET,
    input  [2:0] OFFSET,
    input  [7:0] DATA,
    input  [17:0] REQ_ADDR,
    output [20:0] REQ_DATA_ADDR
);

parameter TABLESIZE = 'h100;
parameter BANKSIZE = 'h10000;
parameter ROM_LENGTH = 'h100000;
parameter ROM_OFFS = 'h0;
parameter PAGE_MASK = 'hFF;

reg [3:0] bank_addrs [0:7];

//address map
wire bank_a = REQ_ADDR >= 'h0 && REQ_ADDR <='hFF, 
     bank_b = REQ_ADDR >= 'h100 && REQ_ADDR <='h1FF, 
     bank_c = REQ_ADDR >= 'h200 && REQ_ADDR <='h2FF, 
     bank_d = REQ_ADDR >= 'h300 && REQ_ADDR <='h3FF, 
     bank_e = REQ_ADDR >= 'h400 && REQ_ADDR <='hFFFF, 
     bank_f = REQ_ADDR >= 'h10000 && REQ_ADDR <='h1FFFF, 
     bank_g = REQ_ADDR >= 'h20000 && REQ_ADDR <='h2FFFF, 
     bank_h = REQ_ADDR >= 'h30000 && REQ_ADDR <='h3FFFF;

wire [17:0] bank_base = bank_a ? 'h0 :
                        bank_b ? 'h100 :
                        bank_c ? 'h200 :
                        bank_d ? 'h300 :
                        bank_e ? 'h400 :
                        bank_f ? 'h10000 :
                        bank_g ? 'h20000 :
                        bank_h ? 'h30000 :
                        0;

assign REQ_DATA_ADDR = (bank_a ? ('h100*0) + ((bank_addrs[0] * BANKSIZE) % ROM_LENGTH) :
                        bank_b ? ('h100*1) + ((bank_addrs[1] * BANKSIZE) % ROM_LENGTH) :
                        bank_c ? ('h100*2) + ((bank_addrs[2] * BANKSIZE) % ROM_LENGTH) :
                        bank_d ? ('h100*3) + ((bank_addrs[3] * BANKSIZE) % ROM_LENGTH) :
                        bank_e ? ('h400) + ((bank_addrs[4] * BANKSIZE) % ROM_LENGTH) :
                        bank_f ? ('h0) + ((bank_addrs[5] * BANKSIZE) % ROM_LENGTH) :
                        bank_g ? ('h0) + ((bank_addrs[6] * BANKSIZE) % ROM_LENGTH) :
                        bank_h ? ('h0) + ((bank_addrs[7] * BANKSIZE) % ROM_LENGTH) : 
                        0) + (REQ_ADDR - bank_base) + ROM_OFFS;
always @(posedge CLK, posedge RESET) begin
    if(RESET) begin
        bank_addrs[0] = 4'h0;
        bank_addrs[1] = 4'h0;
        bank_addrs[2] = 4'h0;
        bank_addrs[3] = 4'h0;
        bank_addrs[4] = 4'h0;
        bank_addrs[5] = 4'h0;
        bank_addrs[6] = 4'h0;
        bank_addrs[7] = 4'h0;
    end else begin
        bank_addrs[(OFFSET & 3)] = DATA[3:0];
        bank_addrs[4 + (OFFSET & 3)] = DATA[3:0];
        bank_addrs[(OFFSET + 1) & 3] = DATA[7:4];
        bank_addrs[4 + (((OFFSET + 1) & 3))] = DATA[7:4]; 
    end
end

endmodule