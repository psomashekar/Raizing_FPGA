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
    output CEN675,
    output CEN675B,
    output CEN4,
    output CEN4B,
    output CEN2,
    output CEN2B,
    output CEN3p375,
    output CEN3p375B,
    output CEN1,
    output CENp7575,
    output CEN1B,
    output CEN1p6875,
    output CEN1p6875B,
    output CEN1350,
    output CEN1350B,
    input [7:0] GAME
);

localparam GAREGGA = 'h0, KINGDMGP = 'h2, SSTRIKER = 'h1;

//13.50
jtframe_frac_cen #(.W(4)) u_frac_cen_1350(
    .clk(CLK96),
    .n(1),
    .m(7),
    .cen({CEN1p6875, CEN3p375, CEN675, CEN1350}),
    .cenb()
);

//4mhz for Z80
jtframe_frac_cen u_frac_cen_4(
    .clk(CLK96),
    .n(8),
    .m(189),
    .cen({CEN2,CEN4}),
    .cenb({CEN2B,CEN4B})
);

jtframe_frac_cen u_frac_cen_1(
    .clk(CLK96),
    .n(2),
    .m(189),
    .cen(CEN1),
    .cenb(CEN1B)
);


endmodule