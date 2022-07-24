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

jtframe_frac_cen u_frac_cen_4(
    .clk(CLK96),
    .n(1),
    .m(24),
    .cen(CEN4),
    .cenb()
);

//ym2151 half clock
jtframe_cendiv u_cen2(
    .clk(CLK96),
    .cen_in(CEN4),
    .cen_div(CEN2)
);

// //6.75mhz for GP9001
// //96*(9/128) == 6.75
jtframe_frac_cen u_frac_cen_675(
    .clk(CLK96),
    .n(10'd9),
    .m(10'd128),
    .cen(CEN675),
    .cenb(CEN675B)
);

jtframe_frac_cen u_frac_cen_1350(
    .clk(CLK96),
    .n(10'd9),
    .m(10'd64),
    .cen(CEN1350),
    .cenb(CEN1350B)
);

//5.333mhz for Z80
//48*(1/9) == 5.333
jtframe_frac_cen u_frac_cen_5333(
    .clk(CLK96),
    .n(1),
    .m(18),
    .cen(CEN5333),
    .cenb(CEN5333B)
);

//3.2mhz for OKI6295
//48*(1/15) == 3.2
jtframe_frac_cen u_frac_cen_32 (
    .clk(CLK96),
    .n(1),
    .m(30),
    .cen(CEN3p2),
    .cenb(CEN3p2B)
);
endmodule