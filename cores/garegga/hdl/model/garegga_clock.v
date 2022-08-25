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
module garegga_clock (
    input CLK, //48mhz
    input CLK96,
    output reg CEN675,
    output CEN675B,
    output CEN4,
    output CEN4B,
    output CEN2,
    output CEN2B,
    output reg CEN3p375,
    output reg CEN3p375B,
    output CEN1,
    output CENp7575,
    output CEN1B,
    output reg CEN1p6875,
    output CEN1p6875B,
    output reg CEN1350,
    output CEN1350B,
    input [7:0] GAME
);

localparam GAREGGA = 'h0, KINGDMGP = 'h2, SSTRIKER = 'h1;

// //6.75mhz for GP9001
// //96*(9/128) == 6.75

//13.50
reg	[31:0]	counter;
always @(posedge CLK96)
	{ CEN1350, counter } <= counter + 32'd603979776;

reg [31:0] counter2;
always @(posedge CLK96)
    {CEN675, counter2} <= counter2 + 32'd301989888;

//4mhz for Z80
//48*(1/12) == 4
jtframe_frac_cen u_frac_cen_4(
    .clk(CLK96),
    .n(1),
    .m(24),
    .cen(CEN4),
    .cenb(CEN4B)
);

//2mhz for OKI
//48*(1/24) == 2
jtframe_frac_cen u_frac_cen_2(
    .clk(CLK96),
    .n(1),
    .m(48),
    .cen(CEN2),
    .cenb(CEN2B)
);

//kingdmgp ym2151 3.375mhz
reg [31:0] counter3;
always @(posedge CLK96)
    {CEN3p375, counter3} <= counter3 + 32'd150994944;

//3.750
reg [31:0] counter5;
always @(posedge CLK96)
    {CEN3p375B, counter5} <= counter5 + 32'd159383552;

reg [31:0] counter4;
always @(posedge CLK96)
    {CEN1p6875, counter4} <= counter4 + 32'd75497472;

jtframe_frac_cen u_frac_cen_1(
    .clk(CLK96),
    .n(1),
    .m(96),
    .cen(CEN1),
    .cenb(CEN1B)
);


endmodule