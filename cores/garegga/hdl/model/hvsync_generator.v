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
Video sync generator, used to drive a simulated CRT.
To use:
- Wire the hsync and vsync signals to top level outputs
- Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, clk96, pxl_cen, reset, reset96, hsync, vsync, display_on, hpos, vpos, lhbl, lvbl, vrender);

  input clk;
  input clk96;
  input pxl_cen;
  input reset;
  input reset96;
  output hsync, vsync;
  output display_on;
  output [8:0] hpos;
  output [8:0] vpos;
  output lhbl, lvbl;
  output [8:0] vrender;


jtframe_vtimer #(
  .V_START(0),
  .VB_START(239),
  .VB_END(262),
  .VS_START(244),
  .VS_END(248),
  .HB_END(431),
  .HB_START(319),
  .HS_START(360),
  .HS_END(379)
) u_vtimer(
  .clk(clk96),
  .pxl_cen(pxl_cen),
  .LHBL(lhbl),
  .LVBL(lvbl),
  .HS(hsync),
  .VS(vsync),
  .H(hpos),
  .vdump(vpos),
  .vrender(vrender)
);

assign display_on = (hpos<320) && (vpos<240);

endmodule