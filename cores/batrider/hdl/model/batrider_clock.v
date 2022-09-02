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
module batrider_clock (
    input CLK, //48mhz
    input CLK96, 
    output CEN4,
    output CEN2,
    output CEN675,
    output CEN675B,
    output CEN5333,
    output CEN5333B,
    output CEN3p2,
    output CEN3p2B,
    output CEN1350,
    output CEN1350B
);

jtframe_frac_cen #(.W(2)) u_frac_cen_1350(
    .clk(CLK96),
    .n(1),
    .m(7),
    .cen({CEN675, CEN1350}),
    .cenb({CEN675B, CEN1350B})
);


jtframe_frac_cen #(.W(2)) u_frac_cen_4(
    .clk(CLK96),
    .n(8),
    .m(189),
    .cen({CEN2, CEN4}),
    .cenb()
);

jtframe_frac_cen #(.WC(20)) u_frac_cen_5333(
    .clk(CLK96),
    .n(5333),
    .m(94500),
    .cen(CEN5333),
    .cenb(CEN5333B)
);

jtframe_frac_cen u_frac_cen_32 (
    .clk(CLK96),
    .n(32),
    .m(945),
    .cen(CEN3p2),
    .cenb(CEN3p2B)
);
endmodule