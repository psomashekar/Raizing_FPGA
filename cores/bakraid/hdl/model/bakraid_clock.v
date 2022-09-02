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
module bakraid_clock (
    input CLK, //47.25
    input CLK96,
    output CEN675,
    output CEN675B,
    output CEN5333,
    output CEN5333B,
    output CEN1350,
    output CEN1350B,
    output CEN16p9344,
    output CEN16p9344B
);

jtframe_frac_cen #(.W(2)) u_frac_cen_1350(
    .clk(CLK96),
    .n(1),
    .m(7),
    .cen({CEN675, CEN1350}),
    .cenb({CEN675B, CEN1350B})
);

jtframe_frac_cen #(.WC(32)) u_frac_cen_5333(
    .clk(CLK),
    .n(484793213),
    .m((2**32) - 1),
    .cen(CEN5333),
    .cenb(CEN5333B)
);

//16.9344mhz for ymz280b
//48*(441/1250) == 16.9344
jtframe_frac_cen u_frac_cen_16p9344 (
    .clk(CLK96),
    .n(112),
    .m(625),
    .cen(CEN16p9344),
    .cenb(CEN16p9344B)
);
endmodule