/*
 *   __   __     __  __     __         __
 *  /\ "-.\ \   /\ \/\ \   /\ \       /\ \
 *  \ \ \-.  \  \ \ \_\ \  \ \ \____  \ \ \____
 *   \ \_\\"\_\  \ \_____\  \ \_____\  \ \_____\
 *    \/_/ \/_/   \/_____/   \/_____/   \/_____/
 *   ______     ______       __     ______     ______     ______
 *  /\  __ \   /\  == \     /\ \   /\  ___\   /\  ___\   /\__  _\
 *  \ \ \/\ \  \ \  __<    _\_\ \  \ \  __\   \ \ \____  \/_/\ \/
 *   \ \_____\  \ \_____\ /\_____\  \ \_____\  \ \_____\    \ \_\
 *    \/_____/   \/_____/ \/_____/   \/_____/   \/_____/     \/_/
 *
 * https://joshbassett.info
 * https://twitter.com/nullobject
 * https://github.com/nullobject
 *
 * Copyright (c) 2022 Josh Bassett
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
 
module ADPCM(
  input  [3:0]  io_data,
  input  [16:0] io_in_step,
  input  [16:0] io_in_sample,
  output [16:0] io_out_step,
  output [16:0] io_out_sample
);
  wire [10:0] _GEN_4 = 3'h4 == io_data[2:0] ? $signed(11'sh133) : $signed(11'she6); // @[ADPCM.scala 75:{27,27}]
  wire [10:0] _GEN_5 = 3'h5 == io_data[2:0] ? $signed(11'sh199) : $signed(_GEN_4); // @[ADPCM.scala 75:{27,27}]
  wire [10:0] _GEN_6 = 3'h6 == io_data[2:0] ? $signed(11'sh200) : $signed(_GEN_5); // @[ADPCM.scala 75:{27,27}]
  wire [10:0] _GEN_7 = 3'h7 == io_data[2:0] ? $signed(11'sh266) : $signed(_GEN_6); // @[ADPCM.scala 75:{27,27}]
  wire [27:0] _step_T_1 = $signed(io_in_step) * $signed(_GEN_7); // @[ADPCM.scala 75:27]
  wire [19:0] step = _step_T_1[27:8]; // @[ADPCM.scala 75:48]
  wire [19:0] _io_out_step_T_1 = $signed(step) < 20'sh7f ? $signed(20'sh7f) : $signed(step); // @[Util.scala 246:51]
  wire [19:0] _io_out_step_T_3 = $signed(_io_out_step_T_1) < 20'sh6000 ? $signed(_io_out_step_T_1) : $signed(20'sh6000); // @[Util.scala 246:60]
  wire [4:0] _GEN_9 = 4'h1 == io_data ? $signed(5'sh3) : $signed(5'sh1); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_10 = 4'h2 == io_data ? $signed(5'sh5) : $signed(_GEN_9); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_11 = 4'h3 == io_data ? $signed(5'sh7) : $signed(_GEN_10); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_12 = 4'h4 == io_data ? $signed(5'sh9) : $signed(_GEN_11); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_13 = 4'h5 == io_data ? $signed(5'shb) : $signed(_GEN_12); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_14 = 4'h6 == io_data ? $signed(5'shd) : $signed(_GEN_13); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_15 = 4'h7 == io_data ? $signed(5'shf) : $signed(_GEN_14); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_16 = 4'h8 == io_data ? $signed(-5'sh1) : $signed(_GEN_15); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_17 = 4'h9 == io_data ? $signed(-5'sh3) : $signed(_GEN_16); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_18 = 4'ha == io_data ? $signed(-5'sh5) : $signed(_GEN_17); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_19 = 4'hb == io_data ? $signed(-5'sh7) : $signed(_GEN_18); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_20 = 4'hc == io_data ? $signed(-5'sh9) : $signed(_GEN_19); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_21 = 4'hd == io_data ? $signed(-5'shb) : $signed(_GEN_20); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_22 = 4'he == io_data ? $signed(-5'shd) : $signed(_GEN_21); // @[ADPCM.scala 79:{28,28}]
  wire [4:0] _GEN_23 = 4'hf == io_data ? $signed(-5'shf) : $signed(_GEN_22); // @[ADPCM.scala 79:{28,28}]
  wire [21:0] _delta_T = $signed(io_in_step) * $signed(_GEN_23); // @[ADPCM.scala 79:28]
  wire [18:0] delta = _delta_T[21:3]; // @[ADPCM.scala 79:50]
  wire [18:0] _GEN_24 = {{2{io_in_sample[16]}},io_in_sample}; // @[ADPCM.scala 80:44]
  wire [19:0] _io_out_sample_T = $signed(_GEN_24) + $signed(delta); // @[ADPCM.scala 80:44]
  wire [19:0] _io_out_sample_T_2 = $signed(_io_out_sample_T) < -20'sh8000 ? $signed(-20'sh8000) : $signed(
    _io_out_sample_T); // @[Util.scala 246:51]
  wire [19:0] _io_out_sample_T_4 = $signed(_io_out_sample_T_2) < 20'sh7fff ? $signed(_io_out_sample_T_2) : $signed(20'sh7fff
    ); // @[Util.scala 246:60]
  assign io_out_step = _io_out_step_T_3[16:0]; // @[ADPCM.scala 76:15]
  assign io_out_sample = _io_out_sample_T_4[16:0]; // @[ADPCM.scala 80:17]
endmodule
module LERP(
  input  [16:0] io_samples_0,
  input  [16:0] io_samples_1,
  input  [9:0]  io_index,
  output [16:0] io_out
);
  wire [17:0] slope = $signed(io_samples_1) - $signed(io_samples_0); // @[LERP.scala 54:29]
  wire [10:0] _offset_T = {1'b0,$signed(io_index)}; // @[LERP.scala 55:25]
  wire [28:0] _offset_T_1 = $signed(slope) * $signed(_offset_T); // @[LERP.scala 55:25]
  wire [27:0] offset = _offset_T_1[27:0]; // @[LERP.scala 55:25]
  wire [16:0] _io_out_T_1 = offset[25:9]; // @[LERP.scala 56:66]
  assign io_out = $signed(_io_out_T_1) + $signed(io_samples_0); // @[LERP.scala 56:73]
endmodule
module AudioPipeline(
  input         clock,
  input         reset,
  output        io_in_ready,
  input         io_in_valid,
  input  [15:0] io_in_bits_state_samples_0,
  input  [15:0] io_in_bits_state_samples_1,
  input         io_in_bits_state_underflow,
  input  [15:0] io_in_bits_state_adpcmStep,
  input  [9:0]  io_in_bits_state_lerpIndex,
  input         io_in_bits_state_loopEnable,
  input  [15:0] io_in_bits_state_loopStep,
  input  [15:0] io_in_bits_state_loopSample,
  input  [7:0]  io_in_bits_pitch,
  input  [7:0]  io_in_bits_level,
  input  [3:0]  io_in_bits_pan,
  output        io_out_valid,
  output [15:0] io_out_bits_state_samples_0,
  output [15:0] io_out_bits_state_samples_1,
  output        io_out_bits_state_underflow,
  output [15:0] io_out_bits_state_adpcmStep,
  output [9:0]  io_out_bits_state_lerpIndex,
  output        io_out_bits_state_loopEnable,
  output [15:0] io_out_bits_state_loopStep,
  output [15:0] io_out_bits_state_loopSample,
  output [16:0] io_out_bits_audio_left,
  output [16:0] io_out_bits_audio_right,
  output        io_pcmData_ready,
  input         io_pcmData_valid,
  input  [3:0]  io_pcmData_bits,
  input         io_loopStart
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
`endif // RANDOMIZE_REG_INIT
  wire [3:0] adpcm_io_data; // @[AudioPipeline.scala 104:21]
  wire [16:0] adpcm_io_in_step; // @[AudioPipeline.scala 104:21]
  wire [16:0] adpcm_io_in_sample; // @[AudioPipeline.scala 104:21]
  wire [16:0] adpcm_io_out_step; // @[AudioPipeline.scala 104:21]
  wire [16:0] adpcm_io_out_sample; // @[AudioPipeline.scala 104:21]
  wire [16:0] lerp_io_samples_0; // @[AudioPipeline.scala 113:20]
  wire [16:0] lerp_io_samples_1; // @[AudioPipeline.scala 113:20]
  wire [9:0] lerp_io_index; // @[AudioPipeline.scala 113:20]
  wire [16:0] lerp_io_out; // @[AudioPipeline.scala 113:20]
  reg [2:0] stateReg; // @[AudioPipeline.scala 97:25]
  wire  _inputReg_T = io_in_ready & io_in_valid; // @[Decoupled.scala 50:35]
  reg [15:0] inputReg_state_samples_0; // @[Reg.scala 16:16]
  reg [15:0] inputReg_state_samples_1; // @[Reg.scala 16:16]
  reg  inputReg_state_underflow; // @[Reg.scala 16:16]
  reg [15:0] inputReg_state_adpcmStep; // @[Reg.scala 16:16]
  reg [9:0] inputReg_state_lerpIndex; // @[Reg.scala 16:16]
  reg  inputReg_state_loopEnable; // @[Reg.scala 16:16]
  reg [15:0] inputReg_state_loopStep; // @[Reg.scala 16:16]
  reg [15:0] inputReg_state_loopSample; // @[Reg.scala 16:16]
  reg [7:0] inputReg_pitch; // @[Reg.scala 16:16]
  reg [7:0] inputReg_level; // @[Reg.scala 16:16]
  reg [3:0] inputReg_pan; // @[Reg.scala 16:16]
  wire [15:0] _GEN_0 = _inputReg_T ? $signed(io_in_bits_state_samples_0) : $signed(inputReg_state_samples_0); // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_1 = _inputReg_T ? $signed(io_in_bits_state_samples_1) : $signed(inputReg_state_samples_1); // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_3 = _inputReg_T ? $signed(io_in_bits_state_adpcmStep) : $signed(inputReg_state_adpcmStep); // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_5 = _inputReg_T ? io_in_bits_state_loopEnable : inputReg_state_loopEnable; // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_6 = _inputReg_T ? $signed(io_in_bits_state_loopStep) : $signed(inputReg_state_loopStep); // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_7 = _inputReg_T ? $signed(io_in_bits_state_loopSample) : $signed(inputReg_state_loopSample); // @[Reg.scala 16:16 17:{18,22}]
  reg [16:0] sampleReg; // @[AudioPipeline.scala 99:22]
  reg [16:0] audioReg_left; // @[AudioPipeline.scala 100:21]
  reg [16:0] audioReg_right; // @[AudioPipeline.scala 100:21]
  wire  _pcmDataReg_T = io_pcmData_ready & io_pcmData_valid; // @[Decoupled.scala 50:35]
  reg [3:0] pcmDataReg; // @[Reg.scala 16:16]
  wire  _GEN_12 = io_loopStart & ~inputReg_state_loopEnable | _GEN_5; // @[AudioPipeline.scala 126:54 127:33]
  wire [16:0] _GEN_13 = io_loopStart & ~inputReg_state_loopEnable ? $signed(adpcm_io_out_step) : $signed({{1{_GEN_6[15
    ]}},_GEN_6}); // @[AudioPipeline.scala 126:54 128:31]
  wire [16:0] _GEN_14 = io_loopStart & ~inputReg_state_loopEnable ? $signed(adpcm_io_out_sample) : $signed({{1{_GEN_7[15
    ]}},_GEN_7}); // @[AudioPipeline.scala 126:54 129:33]
  wire  _step_T = io_loopStart & inputReg_state_loopEnable; // @[AudioPipeline.scala 131:33]
  wire [16:0] step = io_loopStart & inputReg_state_loopEnable ? $signed({{1{inputReg_state_loopStep[15]}},
    inputReg_state_loopStep}) : $signed(adpcm_io_out_step); // @[AudioPipeline.scala 131:19]
  wire [16:0] sample = _step_T ? $signed({{1{inputReg_state_loopSample[15]}},inputReg_state_loopSample}) : $signed(
    adpcm_io_out_sample); // @[AudioPipeline.scala 132:21]
  wire [16:0] _GEN_16 = stateReg == 3'h3 ? $signed(_GEN_13) : $signed({{1{_GEN_6[15]}},_GEN_6}); // @[AudioPipeline.scala 125:35]
  wire [16:0] _GEN_17 = stateReg == 3'h3 ? $signed(_GEN_14) : $signed({{1{_GEN_7[15]}},_GEN_7}); // @[AudioPipeline.scala 125:35]
  wire [16:0] _GEN_18 = stateReg == 3'h3 ? $signed(step) : $signed({{1{_GEN_3[15]}},_GEN_3}); // @[AudioPipeline.scala 125:35 AudioPipelineState.scala 57:15]
  wire [16:0] _WIRE_0 = {{1{inputReg_state_samples_1[15]}},inputReg_state_samples_1}; // @[AudioPipelineState.scala 58:{23,23}]
  wire [16:0] _GEN_19 = stateReg == 3'h3 ? $signed(_WIRE_0) : $signed({{1{_GEN_0[15]}},_GEN_0}); // @[AudioPipeline.scala 125:35 AudioPipelineState.scala 58:13]
  wire [16:0] _GEN_20 = stateReg == 3'h3 ? $signed(sample) : $signed({{1{_GEN_1[15]}},_GEN_1}); // @[AudioPipeline.scala 125:35 AudioPipelineState.scala 58:13]
  wire [9:0] _GEN_40 = {{2'd0}, inputReg_pitch}; // @[AudioPipelineState.scala 63:27]
  wire [9:0] _index_T_1 = inputReg_state_lerpIndex + _GEN_40; // @[AudioPipelineState.scala 63:27]
  wire [9:0] index = _index_T_1 + 10'h1; // @[AudioPipelineState.scala 63:35]
  wire [8:0] _sampleReg_T = inputReg_level + 8'h1; // @[AudioPipeline.scala 144:46]
  wire [9:0] _sampleReg_T_1 = {1'b0,$signed(_sampleReg_T)}; // @[AudioPipeline.scala 144:28]
  wire [26:0] _sampleReg_T_2 = $signed(sampleReg) * $signed(_sampleReg_T_1); // @[AudioPipeline.scala 144:28]
  wire [25:0] _sampleReg_T_4 = _sampleReg_T_2[25:0]; // @[AudioPipeline.scala 144:28]
  wire [16:0] _sampleReg_T_5 = _sampleReg_T_4[25:9]; // @[AudioPipeline.scala 144:54]
  wire [2:0] t = inputReg_pan[2:0]; // @[AudioPipeline.scala 150:25]
  wire [2:0] _left_T = ~t; // @[AudioPipeline.scala 156:20]
  wire [3:0] _left_T_1 = {1'b0,$signed(_left_T)}; // @[AudioPipeline.scala 156:17]
  wire [20:0] _left_T_2 = $signed(sampleReg) * $signed(_left_T_1); // @[AudioPipeline.scala 156:17]
  wire [19:0] _left_T_4 = _left_T_2[19:0]; // @[AudioPipeline.scala 156:17]
  wire [16:0] _left_T_5 = _left_T_4[19:3]; // @[AudioPipeline.scala 156:31]
  wire [3:0] _right_T = {1'b0,$signed(t)}; // @[AudioPipeline.scala 158:18]
  wire [20:0] _right_T_1 = $signed(sampleReg) * $signed(_right_T); // @[AudioPipeline.scala 158:18]
  wire [19:0] _right_T_3 = _right_T_1[19:0]; // @[AudioPipeline.scala 158:18]
  wire [16:0] _right_T_4 = _right_T_3[19:3]; // @[AudioPipeline.scala 158:22]
  wire [2:0] _GEN_31 = io_pcmData_valid ? 3'h3 : stateReg; // @[AudioPipeline.scala 175:{30,41} 97:25]
  wire [2:0] _GEN_32 = 3'h7 == stateReg ? 3'h0 : stateReg; // @[AudioPipeline.scala 164:20 191:31 97:25]
  wire [2:0] _GEN_33 = 3'h6 == stateReg ? 3'h7 : _GEN_32; // @[AudioPipeline.scala 164:20 188:30]
  wire [2:0] _GEN_34 = 3'h5 == stateReg ? 3'h6 : _GEN_33; // @[AudioPipeline.scala 164:20 185:32]
  wire [2:0] _GEN_35 = 3'h4 == stateReg ? 3'h5 : _GEN_34; // @[AudioPipeline.scala 164:20 182:38]
  wire [2:0] _GEN_36 = 3'h3 == stateReg ? 3'h4 : _GEN_35; // @[AudioPipeline.scala 164:20 179:33]
  ADPCM adpcm ( // @[AudioPipeline.scala 104:21]
    .io_data(adpcm_io_data),
    .io_in_step(adpcm_io_in_step),
    .io_in_sample(adpcm_io_in_sample),
    .io_out_step(adpcm_io_out_step),
    .io_out_sample(adpcm_io_out_sample)
  );
  LERP lerp ( // @[AudioPipeline.scala 113:20]
    .io_samples_0(lerp_io_samples_0),
    .io_samples_1(lerp_io_samples_1),
    .io_index(lerp_io_index),
    .io_out(lerp_io_out)
  );
  assign io_in_ready = stateReg == 3'h0; // @[AudioPipeline.scala 195:27]
  assign io_out_valid = stateReg == 3'h7; // @[AudioPipeline.scala 196:28]
  assign io_out_bits_state_samples_0 = inputReg_state_samples_0; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_samples_1 = inputReg_state_samples_1; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_underflow = inputReg_state_underflow; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_adpcmStep = inputReg_state_adpcmStep; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_lerpIndex = inputReg_state_lerpIndex; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_loopEnable = inputReg_state_loopEnable; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_loopStep = inputReg_state_loopStep; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_state_loopSample = inputReg_state_loopSample; // @[AudioPipeline.scala 197:21]
  assign io_out_bits_audio_left = audioReg_left; // @[AudioPipeline.scala 198:21]
  assign io_out_bits_audio_right = audioReg_right; // @[AudioPipeline.scala 198:21]
  assign io_pcmData_ready = stateReg == 3'h2; // @[AudioPipeline.scala 199:32]
  assign adpcm_io_data = pcmDataReg; // @[AudioPipeline.scala 108:17]
  assign adpcm_io_in_step = {{1{inputReg_state_adpcmStep[15]}},inputReg_state_adpcmStep}; // @[AudioPipeline.scala 109:20]
  assign adpcm_io_in_sample = {{1{inputReg_state_samples_1[15]}},inputReg_state_samples_1}; // @[AudioPipeline.scala 110:22]
  assign lerp_io_samples_0 = {{1{inputReg_state_samples_0[15]}},inputReg_state_samples_0}; // @[AudioPipeline.scala 117:19]
  assign lerp_io_samples_1 = {{1{inputReg_state_samples_1[15]}},inputReg_state_samples_1}; // @[AudioPipeline.scala 117:19]
  assign lerp_io_index = inputReg_state_lerpIndex; // @[AudioPipeline.scala 118:17]
  always @(posedge clock) begin
    if (reset) begin // @[AudioPipeline.scala 97:25]
      stateReg <= 3'h0; // @[AudioPipeline.scala 97:25]
    end else if (3'h0 == stateReg) begin // @[AudioPipeline.scala 164:20]
      if (io_in_valid) begin // @[AudioPipeline.scala 167:25]
        stateReg <= 3'h1; // @[AudioPipeline.scala 167:36]
      end
    end else if (3'h1 == stateReg) begin // @[AudioPipeline.scala 164:20]
      if (inputReg_state_underflow) begin // @[AudioPipeline.scala 171:38]
        stateReg <= 3'h2;
      end else begin
        stateReg <= 3'h4;
      end
    end else if (3'h2 == stateReg) begin // @[AudioPipeline.scala 164:20]
      stateReg <= _GEN_31;
    end else begin
      stateReg <= _GEN_36;
    end
    inputReg_state_samples_0 <= _GEN_19[15:0];
    inputReg_state_samples_1 <= _GEN_20[15:0];
    if (stateReg == 3'h4) begin // @[AudioPipeline.scala 137:40]
      inputReg_state_underflow <= index[9]; // @[AudioPipelineState.scala 64:15]
    end else if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_state_underflow <= io_in_bits_state_underflow; // @[Reg.scala 17:22]
    end
    inputReg_state_adpcmStep <= _GEN_18[15:0];
    if (stateReg == 3'h4) begin // @[AudioPipeline.scala 137:40]
      inputReg_state_lerpIndex <= {{1'd0}, index[8:0]}; // @[AudioPipelineState.scala 65:15]
    end else if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_state_lerpIndex <= io_in_bits_state_lerpIndex; // @[Reg.scala 17:22]
    end
    if (stateReg == 3'h3) begin // @[AudioPipeline.scala 125:35]
      inputReg_state_loopEnable <= _GEN_12;
    end else if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_state_loopEnable <= io_in_bits_state_loopEnable; // @[Reg.scala 17:22]
    end
    inputReg_state_loopStep <= _GEN_16[15:0];
    inputReg_state_loopSample <= _GEN_17[15:0];
    if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_pitch <= io_in_bits_pitch; // @[Reg.scala 17:22]
    end
    if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_level <= io_in_bits_level; // @[Reg.scala 17:22]
    end
    if (_inputReg_T) begin // @[Reg.scala 17:18]
      inputReg_pan <= io_in_bits_pan; // @[Reg.scala 17:22]
    end
    if (stateReg == 3'h5) begin // @[AudioPipeline.scala 143:34]
      sampleReg <= _sampleReg_T_5; // @[AudioPipeline.scala 144:15]
    end else if (stateReg == 3'h4) begin // @[AudioPipeline.scala 137:40]
      sampleReg <= lerp_io_out; // @[AudioPipeline.scala 139:15]
    end
    if (stateReg == 3'h6) begin // @[AudioPipeline.scala 148:32]
      if (inputReg_pan > 4'h8) begin // @[AudioPipeline.scala 155:30]
        audioReg_left <= _left_T_5; // @[AudioPipeline.scala 156:12]
      end else begin
        audioReg_left <= sampleReg; // @[AudioPipeline.scala 153:10]
      end
    end
    if (stateReg == 3'h6) begin // @[AudioPipeline.scala 148:32]
      if (inputReg_pan > 4'h8) begin // @[AudioPipeline.scala 155:30]
        audioReg_right <= sampleReg; // @[AudioPipeline.scala 154:11]
      end else if (inputReg_pan < 4'h7) begin // @[AudioPipeline.scala 157:36]
        audioReg_right <= _right_T_4; // @[AudioPipeline.scala 158:13]
      end else begin
        audioReg_right <= sampleReg; // @[AudioPipeline.scala 154:11]
      end
    end
    if (_pcmDataReg_T) begin // @[Reg.scala 17:18]
      pcmDataReg <= io_pcmData_bits; // @[Reg.scala 17:22]
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,
            "AudioPipeline(state: %d, pcmData: 0x%x, pipelineState: AudioPipelineState(samples -> Vec(%d, %d), underflow -> %d, adpcmStep -> %d, lerpIndex -> %d, loopEnable -> %d, loopStep -> %d, loopSample -> %d))\n"
            ,stateReg,pcmDataReg,inputReg_state_samples_0,inputReg_state_samples_1,inputReg_state_underflow,
            inputReg_state_adpcmStep,inputReg_state_lerpIndex,inputReg_state_loopEnable,inputReg_state_loopStep,
            inputReg_state_loopSample); // @[AudioPipeline.scala 209:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  stateReg = _RAND_0[2:0];
  _RAND_1 = {1{`RANDOM}};
  inputReg_state_samples_0 = _RAND_1[15:0];
  _RAND_2 = {1{`RANDOM}};
  inputReg_state_samples_1 = _RAND_2[15:0];
  _RAND_3 = {1{`RANDOM}};
  inputReg_state_underflow = _RAND_3[0:0];
  _RAND_4 = {1{`RANDOM}};
  inputReg_state_adpcmStep = _RAND_4[15:0];
  _RAND_5 = {1{`RANDOM}};
  inputReg_state_lerpIndex = _RAND_5[9:0];
  _RAND_6 = {1{`RANDOM}};
  inputReg_state_loopEnable = _RAND_6[0:0];
  _RAND_7 = {1{`RANDOM}};
  inputReg_state_loopStep = _RAND_7[15:0];
  _RAND_8 = {1{`RANDOM}};
  inputReg_state_loopSample = _RAND_8[15:0];
  _RAND_9 = {1{`RANDOM}};
  inputReg_pitch = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  inputReg_level = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  inputReg_pan = _RAND_11[3:0];
  _RAND_12 = {1{`RANDOM}};
  sampleReg = _RAND_12[16:0];
  _RAND_13 = {1{`RANDOM}};
  audioReg_left = _RAND_13[16:0];
  _RAND_14 = {1{`RANDOM}};
  audioReg_right = _RAND_14[16:0];
  _RAND_15 = {1{`RANDOM}};
  pcmDataReg = _RAND_15[3:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module ChannelController(
  input         clock,
  input         reset,
  input  [7:0]  io_regs_0_pitch,
  input         io_regs_0_flags_keyOn,
  input         io_regs_0_flags_loop,
  input  [7:0]  io_regs_0_level,
  input  [3:0]  io_regs_0_pan,
  input  [23:0] io_regs_0_startAddr,
  input  [23:0] io_regs_0_loopStartAddr,
  input  [23:0] io_regs_0_loopEndAddr,
  input  [23:0] io_regs_0_endAddr,
  input  [7:0]  io_regs_1_pitch,
  input         io_regs_1_flags_keyOn,
  input         io_regs_1_flags_loop,
  input  [7:0]  io_regs_1_level,
  input  [3:0]  io_regs_1_pan,
  input  [23:0] io_regs_1_startAddr,
  input  [23:0] io_regs_1_loopStartAddr,
  input  [23:0] io_regs_1_loopEndAddr,
  input  [23:0] io_regs_1_endAddr,
  input  [7:0]  io_regs_2_pitch,
  input         io_regs_2_flags_keyOn,
  input         io_regs_2_flags_loop,
  input  [7:0]  io_regs_2_level,
  input  [3:0]  io_regs_2_pan,
  input  [23:0] io_regs_2_startAddr,
  input  [23:0] io_regs_2_loopStartAddr,
  input  [23:0] io_regs_2_loopEndAddr,
  input  [23:0] io_regs_2_endAddr,
  input  [7:0]  io_regs_3_pitch,
  input         io_regs_3_flags_keyOn,
  input         io_regs_3_flags_loop,
  input  [7:0]  io_regs_3_level,
  input  [3:0]  io_regs_3_pan,
  input  [23:0] io_regs_3_startAddr,
  input  [23:0] io_regs_3_loopStartAddr,
  input  [23:0] io_regs_3_loopEndAddr,
  input  [23:0] io_regs_3_endAddr,
  input  [7:0]  io_regs_4_pitch,
  input         io_regs_4_flags_keyOn,
  input         io_regs_4_flags_loop,
  input  [7:0]  io_regs_4_level,
  input  [3:0]  io_regs_4_pan,
  input  [23:0] io_regs_4_startAddr,
  input  [23:0] io_regs_4_loopStartAddr,
  input  [23:0] io_regs_4_loopEndAddr,
  input  [23:0] io_regs_4_endAddr,
  input  [7:0]  io_regs_5_pitch,
  input         io_regs_5_flags_keyOn,
  input         io_regs_5_flags_loop,
  input  [7:0]  io_regs_5_level,
  input  [3:0]  io_regs_5_pan,
  input  [23:0] io_regs_5_startAddr,
  input  [23:0] io_regs_5_loopStartAddr,
  input  [23:0] io_regs_5_loopEndAddr,
  input  [23:0] io_regs_5_endAddr,
  input  [7:0]  io_regs_6_pitch,
  input         io_regs_6_flags_keyOn,
  input         io_regs_6_flags_loop,
  input  [7:0]  io_regs_6_level,
  input  [3:0]  io_regs_6_pan,
  input  [23:0] io_regs_6_startAddr,
  input  [23:0] io_regs_6_loopStartAddr,
  input  [23:0] io_regs_6_loopEndAddr,
  input  [23:0] io_regs_6_endAddr,
  input  [7:0]  io_regs_7_pitch,
  input         io_regs_7_flags_keyOn,
  input         io_regs_7_flags_loop,
  input  [7:0]  io_regs_7_level,
  input  [3:0]  io_regs_7_pan,
  input  [23:0] io_regs_7_startAddr,
  input  [23:0] io_regs_7_loopStartAddr,
  input  [23:0] io_regs_7_loopEndAddr,
  input  [23:0] io_regs_7_endAddr,
  input         io_enable,
  output        io_done,
  output [2:0]  io_index,
  output        io_audio_valid,
  output [15:0] io_audio_bits_left,
  output [15:0] io_audio_bits_right,
  output        io_rom_rd,
  output [23:0] io_rom_addr,
  input  [7:0]  io_rom_dout,
  input         io_rom_waitReq,
  input         io_rom_valid
);
`ifdef RANDOMIZE_MEM_INIT
  reg [127:0] _RAND_0;
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
`endif // RANDOMIZE_REG_INIT
  reg [120:0] channelStateMem [0:7]; // @[ChannelController.scala 99:36]
  wire  channelStateMem_channelState_MPORT_en; // @[ChannelController.scala 99:36]
  wire [2:0] channelStateMem_channelState_MPORT_addr; // @[ChannelController.scala 99:36]
  wire [120:0] channelStateMem_channelState_MPORT_data; // @[ChannelController.scala 99:36]
  wire [120:0] channelStateMem_MPORT_data; // @[ChannelController.scala 99:36]
  wire [2:0] channelStateMem_MPORT_addr; // @[ChannelController.scala 99:36]
  wire  channelStateMem_MPORT_mask; // @[ChannelController.scala 99:36]
  wire  channelStateMem_MPORT_en; // @[ChannelController.scala 99:36]
  reg  channelStateMem_channelState_MPORT_en_pipe_0;
  reg [2:0] channelStateMem_channelState_MPORT_addr_pipe_0;
  wire  audioPipeline_clock; // @[ChannelController.scala 104:29]
  wire  audioPipeline_reset; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_in_ready; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_in_valid; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_in_bits_state_samples_0; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_in_bits_state_samples_1; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_in_bits_state_underflow; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_in_bits_state_adpcmStep; // @[ChannelController.scala 104:29]
  wire [9:0] audioPipeline_io_in_bits_state_lerpIndex; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_in_bits_state_loopEnable; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_in_bits_state_loopStep; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_in_bits_state_loopSample; // @[ChannelController.scala 104:29]
  wire [7:0] audioPipeline_io_in_bits_pitch; // @[ChannelController.scala 104:29]
  wire [7:0] audioPipeline_io_in_bits_level; // @[ChannelController.scala 104:29]
  wire [3:0] audioPipeline_io_in_bits_pan; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_out_valid; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_out_bits_state_samples_0; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_out_bits_state_samples_1; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_out_bits_state_underflow; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_out_bits_state_adpcmStep; // @[ChannelController.scala 104:29]
  wire [9:0] audioPipeline_io_out_bits_state_lerpIndex; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_out_bits_state_loopEnable; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_out_bits_state_loopStep; // @[ChannelController.scala 104:29]
  wire [15:0] audioPipeline_io_out_bits_state_loopSample; // @[ChannelController.scala 104:29]
  wire [16:0] audioPipeline_io_out_bits_audio_left; // @[ChannelController.scala 104:29]
  wire [16:0] audioPipeline_io_out_bits_audio_right; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_pcmData_ready; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_pcmData_valid; // @[ChannelController.scala 104:29]
  wire [3:0] audioPipeline_io_pcmData_bits; // @[ChannelController.scala 104:29]
  wire  audioPipeline_io_loopStart; // @[ChannelController.scala 104:29]
  reg [3:0] stateReg; // @[ChannelController.scala 88:25]
  reg [16:0] accumulatorReg_left; // @[ChannelController.scala 89:27]
  reg [16:0] accumulatorReg_right; // @[ChannelController.scala 89:27]
  wire  _T = stateReg == 4'h0; // @[ChannelController.scala 92:99]
  wire  _T_2 = stateReg == 4'h0 | stateReg == 4'h8; // @[ChannelController.scala 92:114]
  reg [2:0] channelCounter; // @[Counter.scala 40:34]
  wire  wrap_wrap = channelCounter == 3'h7; // @[Counter.scala 45:24]
  wire [2:0] _wrap_value_T_1 = channelCounter + 3'h1; // @[Counter.scala 46:22]
  wire  channelCounterWrap = _T_2 & wrap_wrap; // @[Counter.scala 86:{48,55}]
  reg [10:0] outputCounterWrap_value; // @[Counter.scala 40:34]
  wire  outputCounterWrap_wrap_wrap = outputCounterWrap_value == `YMZ280B_SAMPLE_RATE; // @[Counter.scala 45:24]
  wire [10:0] _outputCounterWrap_wrap_value_T_1 = outputCounterWrap_value + 11'h1; // @[Counter.scala 46:22]
  wire [120:0] _channelState_WIRE_1 = channelStateMem_channelState_MPORT_data;
  wire [15:0] channelState_audioPipelineState_loopSample = _channelState_WIRE_1[15:0]; // @[ChannelController.scala 100:92]
  wire [15:0] channelState_audioPipelineState_loopStep = _channelState_WIRE_1[31:16]; // @[ChannelController.scala 100:92]
  wire  channelState_audioPipelineState_loopEnable = _channelState_WIRE_1[32]; // @[ChannelController.scala 100:92]
  wire [9:0] channelState_audioPipelineState_lerpIndex = _channelState_WIRE_1[42:33]; // @[ChannelController.scala 100:92]
  wire [15:0] channelState_audioPipelineState_adpcmStep = _channelState_WIRE_1[58:43]; // @[ChannelController.scala 100:92]
  wire  channelState_audioPipelineState_underflow = _channelState_WIRE_1[59]; // @[ChannelController.scala 100:92]
  wire [15:0] channelState_audioPipelineState_samples_0 = _channelState_WIRE_1[75:60]; // @[ChannelController.scala 100:92]
  wire [15:0] channelState_audioPipelineState_samples_1 = _channelState_WIRE_1[91:76]; // @[ChannelController.scala 100:92]
  wire  channelState_loopStart = _channelState_WIRE_1[92]; // @[ChannelController.scala 100:92]
  wire [23:0] channelState_addr = _channelState_WIRE_1[116:93]; // @[ChannelController.scala 100:92]
  wire  channelState_nibble = _channelState_WIRE_1[117]; // @[ChannelController.scala 100:92]
  wire  channelState_done = _channelState_WIRE_1[118]; // @[ChannelController.scala 100:92]
  wire  channelState_active = _channelState_WIRE_1[119]; // @[ChannelController.scala 100:92]
  wire  channelState_enable = _channelState_WIRE_1[120]; // @[ChannelController.scala 100:92]
  wire  _channelStateReg_T = stateReg == 4'h3; // @[ChannelController.scala 101:58]
  reg  channelStateReg_enable; // @[Reg.scala 16:16]
  reg  channelStateReg_active; // @[Reg.scala 16:16]
  reg  channelStateReg_done; // @[Reg.scala 16:16]
  reg  channelStateReg_nibble; // @[Reg.scala 16:16]
  reg [23:0] channelStateReg_addr; // @[Reg.scala 16:16]
  reg  channelStateReg_loopStart; // @[Reg.scala 16:16]
  reg [15:0] channelStateReg_audioPipelineState_samples_0; // @[Reg.scala 16:16]
  reg [15:0] channelStateReg_audioPipelineState_samples_1; // @[Reg.scala 16:16]
  reg  channelStateReg_audioPipelineState_underflow; // @[Reg.scala 16:16]
  reg [15:0] channelStateReg_audioPipelineState_adpcmStep; // @[Reg.scala 16:16]
  reg [9:0] channelStateReg_audioPipelineState_lerpIndex; // @[Reg.scala 16:16]
  reg  channelStateReg_audioPipelineState_loopEnable; // @[Reg.scala 16:16]
  reg [15:0] channelStateReg_audioPipelineState_loopStep; // @[Reg.scala 16:16]
  reg [15:0] channelStateReg_audioPipelineState_loopSample; // @[Reg.scala 16:16]
  wire  _GEN_13 = _channelStateReg_T ? channelState_enable : channelStateReg_enable; // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_14 = _channelStateReg_T ? channelState_active : channelStateReg_active; // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_15 = _channelStateReg_T ? channelState_done : channelStateReg_done; // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_16 = _channelStateReg_T ? channelState_nibble : channelStateReg_nibble; // @[Reg.scala 16:16 17:{18,22}]
  wire [23:0] _GEN_17 = _channelStateReg_T ? channelState_addr : channelStateReg_addr; // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_18 = _channelStateReg_T ? channelState_loopStart : channelStateReg_loopStart; // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_19 = _channelStateReg_T ? $signed(channelState_audioPipelineState_samples_0) : $signed(
    channelStateReg_audioPipelineState_samples_0); // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_20 = _channelStateReg_T ? $signed(channelState_audioPipelineState_samples_1) : $signed(
    channelStateReg_audioPipelineState_samples_1); // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_21 = _channelStateReg_T ? channelState_audioPipelineState_underflow :
    channelStateReg_audioPipelineState_underflow; // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_22 = _channelStateReg_T ? $signed(channelState_audioPipelineState_adpcmStep) : $signed(
    channelStateReg_audioPipelineState_adpcmStep); // @[Reg.scala 16:16 17:{18,22}]
  wire [9:0] _GEN_23 = _channelStateReg_T ? channelState_audioPipelineState_lerpIndex :
    channelStateReg_audioPipelineState_lerpIndex; // @[Reg.scala 16:16 17:{18,22}]
  wire  _GEN_24 = _channelStateReg_T ? channelState_audioPipelineState_loopEnable :
    channelStateReg_audioPipelineState_loopEnable; // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_25 = _channelStateReg_T ? $signed(channelState_audioPipelineState_loopStep) : $signed(
    channelStateReg_audioPipelineState_loopStep); // @[Reg.scala 16:16 17:{18,22}]
  wire [15:0] _GEN_26 = _channelStateReg_T ? $signed(channelState_audioPipelineState_loopSample) : $signed(
    channelStateReg_audioPipelineState_loopSample); // @[Reg.scala 16:16 17:{18,22}]
  wire [7:0] _GEN_28 = 3'h1 == channelCounter ? io_regs_1_pitch : io_regs_0_pitch; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_29 = 3'h2 == channelCounter ? io_regs_2_pitch : _GEN_28; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_30 = 3'h3 == channelCounter ? io_regs_3_pitch : _GEN_29; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_31 = 3'h4 == channelCounter ? io_regs_4_pitch : _GEN_30; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_32 = 3'h5 == channelCounter ? io_regs_5_pitch : _GEN_31; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_33 = 3'h6 == channelCounter ? io_regs_6_pitch : _GEN_32; // @[ChannelController.scala 107:{34,34}]
  wire [7:0] _GEN_36 = 3'h1 == channelCounter ? io_regs_1_level : io_regs_0_level; // @[ChannelController.scala 108:{34,34}]
  wire [7:0] _GEN_37 = 3'h2 == channelCounter ? io_regs_2_level : _GEN_36; // @[ChannelController.scala 108:{34,34}]
  wire [7:0] _GEN_38 = 3'h3 == channelCounter ? io_regs_3_level : _GEN_37; // @[ChannelController.scala 108:{34,34}]
  wire [7:0] _GEN_39 = 3'h4 == channelCounter ? io_regs_4_level : _GEN_38; // @[ChannelController.scala 108:{34,34}]
  wire [7:0] _GEN_40 = 3'h5 == channelCounter ? io_regs_5_level : _GEN_39; // @[ChannelController.scala 108:{34,34}]
  wire [7:0] _GEN_41 = 3'h6 == channelCounter ? io_regs_6_level : _GEN_40; // @[ChannelController.scala 108:{34,34}]
  wire [3:0] _GEN_44 = 3'h1 == channelCounter ? io_regs_1_pan : io_regs_0_pan; // @[ChannelController.scala 109:{32,32}]
  wire [3:0] _GEN_45 = 3'h2 == channelCounter ? io_regs_2_pan : _GEN_44; // @[ChannelController.scala 109:{32,32}]
  wire [3:0] _GEN_46 = 3'h3 == channelCounter ? io_regs_3_pan : _GEN_45; // @[ChannelController.scala 109:{32,32}]
  wire [3:0] _GEN_47 = 3'h4 == channelCounter ? io_regs_4_pan : _GEN_46; // @[ChannelController.scala 109:{32,32}]
  wire [3:0] _GEN_48 = 3'h5 == channelCounter ? io_regs_5_pan : _GEN_47; // @[ChannelController.scala 109:{32,32}]
  wire [3:0] _GEN_49 = 3'h6 == channelCounter ? io_regs_6_pan : _GEN_48; // @[ChannelController.scala 109:{32,32}]
  wire  _GEN_52 = 3'h1 == channelCounter ? io_regs_1_flags_keyOn : io_regs_0_flags_keyOn; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_53 = 3'h2 == channelCounter ? io_regs_2_flags_keyOn : _GEN_52; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_54 = 3'h3 == channelCounter ? io_regs_3_flags_keyOn : _GEN_53; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_55 = 3'h4 == channelCounter ? io_regs_4_flags_keyOn : _GEN_54; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_56 = 3'h5 == channelCounter ? io_regs_5_flags_keyOn : _GEN_55; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_57 = 3'h6 == channelCounter ? io_regs_6_flags_keyOn : _GEN_56; // @[ChannelController.scala 115:{66,66}]
  wire  _GEN_58 = 3'h7 == channelCounter ? io_regs_7_flags_keyOn : _GEN_57; // @[ChannelController.scala 115:{66,66}]
  wire  start = ~channelStateReg_enable & ~channelStateReg_active & _GEN_58; // @[ChannelController.scala 115:66]
  wire  stop = channelStateReg_enable & ~_GEN_58; // @[ChannelController.scala 116:37]
  wire  active = channelStateReg_active | start; // @[ChannelController.scala 117:39]
  wire  _pendingReg_T_1 = audioPipeline_io_pcmData_ready & ~io_rom_waitReq; // @[ChannelController.scala 121:66]
  reg  pendingReg; // @[Util.scala 200:28]
  wire  _GEN_59 = _pendingReg_T_1 | pendingReg; // @[Util.scala 200:28 201:{54,66}]
  wire  _T_4 = stateReg == 4'h4; // @[ChannelController.scala 129:17]
  wire [23:0] _GEN_64 = 3'h1 == channelCounter ? io_regs_1_startAddr : io_regs_0_startAddr; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_65 = 3'h2 == channelCounter ? io_regs_2_startAddr : _GEN_64; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_66 = 3'h3 == channelCounter ? io_regs_3_startAddr : _GEN_65; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_67 = 3'h4 == channelCounter ? io_regs_4_startAddr : _GEN_66; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_68 = 3'h5 == channelCounter ? io_regs_5_startAddr : _GEN_67; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_69 = 3'h6 == channelCounter ? io_regs_6_startAddr : _GEN_68; // @[ChannelState.scala 61:{10,10}]
  wire [23:0] _GEN_70 = 3'h7 == channelCounter ? io_regs_7_startAddr : _GEN_69; // @[ChannelState.scala 61:{10,10}]
  wire  _GEN_71 = channelStateReg_done ? 1'h0 : _GEN_15; // @[ChannelController.scala 134:22 ChannelState.scala 97:10]
  wire  _GEN_72 = stop ? 1'h0 : _GEN_13; // @[ChannelController.scala 132:22 ChannelState.scala 68:12]
  wire  _GEN_73 = stop ? 1'h0 : _GEN_14; // @[ChannelController.scala 132:22 ChannelState.scala 69:12]
  wire  _GEN_74 = stop ? 1'h0 : _GEN_71; // @[ChannelController.scala 132:22 ChannelState.scala 70:10]
  wire  _GEN_75 = start | _GEN_72; // @[ChannelController.scala 130:17 ChannelState.scala 57:12]
  wire  _GEN_76 = start | _GEN_73; // @[ChannelController.scala 130:17 ChannelState.scala 58:12]
  wire  _GEN_77 = start ? 1'h0 : _GEN_74; // @[ChannelController.scala 130:17 ChannelState.scala 59:10]
  wire [23:0] _GEN_79 = start ? _GEN_70 : _GEN_17; // @[ChannelController.scala 130:17 ChannelState.scala 61:10]
  wire  _GEN_83 = start | _GEN_21; // @[ChannelController.scala 130:17 ChannelState.scala 63:24]
  wire  _GEN_90 = stateReg == 4'h4 ? _GEN_76 : _GEN_14; // @[ChannelController.scala 129:34]
  wire  _GEN_91 = stateReg == 4'h4 ? _GEN_77 : _GEN_15; // @[ChannelController.scala 129:34]
  wire [23:0] _GEN_93 = stateReg == 4'h4 ? _GEN_79 : _GEN_17; // @[ChannelController.scala 129:34]
  wire  _T_5 = audioPipeline_io_pcmData_ready & audioPipeline_io_pcmData_valid; // @[Decoupled.scala 50:35]
  wire [23:0] _GEN_104 = 3'h1 == channelCounter ? io_regs_1_loopStartAddr : io_regs_0_loopStartAddr; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_105 = 3'h2 == channelCounter ? io_regs_2_loopStartAddr : _GEN_104; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_106 = 3'h3 == channelCounter ? io_regs_3_loopStartAddr : _GEN_105; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_107 = 3'h4 == channelCounter ? io_regs_4_loopStartAddr : _GEN_106; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_108 = 3'h5 == channelCounter ? io_regs_5_loopStartAddr : _GEN_107; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_109 = 3'h6 == channelCounter ? io_regs_6_loopStartAddr : _GEN_108; // @[ChannelState.scala 81:{48,48}]
  wire [23:0] _GEN_110 = 3'h7 == channelCounter ? io_regs_7_loopStartAddr : _GEN_109; // @[ChannelState.scala 81:{48,48}]
  wire  _GEN_112 = 3'h1 == channelCounter ? io_regs_1_flags_loop : io_regs_0_flags_loop; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_113 = 3'h2 == channelCounter ? io_regs_2_flags_loop : _GEN_112; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_114 = 3'h3 == channelCounter ? io_regs_3_flags_loop : _GEN_113; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_115 = 3'h4 == channelCounter ? io_regs_4_flags_loop : _GEN_114; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_116 = 3'h5 == channelCounter ? io_regs_5_flags_loop : _GEN_115; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_117 = 3'h6 == channelCounter ? io_regs_6_flags_loop : _GEN_116; // @[ChannelState.scala 81:{40,40}]
  wire  _GEN_118 = 3'h7 == channelCounter ? io_regs_7_flags_loop : _GEN_117; // @[ChannelState.scala 81:{40,40}]
  wire  _channelStateReg_loopStart_T_2 = ~channelStateReg_nibble; // @[ChannelState.scala 81:80]
  wire [23:0] _GEN_120 = 3'h1 == channelCounter ? io_regs_1_loopEndAddr : io_regs_0_loopEndAddr; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_121 = 3'h2 == channelCounter ? io_regs_2_loopEndAddr : _GEN_120; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_122 = 3'h3 == channelCounter ? io_regs_3_loopEndAddr : _GEN_121; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_123 = 3'h4 == channelCounter ? io_regs_4_loopEndAddr : _GEN_122; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_124 = 3'h5 == channelCounter ? io_regs_5_loopEndAddr : _GEN_123; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_125 = 3'h6 == channelCounter ? io_regs_6_loopEndAddr : _GEN_124; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_126 = 3'h7 == channelCounter ? io_regs_7_loopEndAddr : _GEN_125; // @[ChannelState.scala 84:{42,42}]
  wire [23:0] _GEN_128 = 3'h1 == channelCounter ? io_regs_1_endAddr : io_regs_0_endAddr; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_129 = 3'h2 == channelCounter ? io_regs_2_endAddr : _GEN_128; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_130 = 3'h3 == channelCounter ? io_regs_3_endAddr : _GEN_129; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_131 = 3'h4 == channelCounter ? io_regs_4_endAddr : _GEN_130; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_132 = 3'h5 == channelCounter ? io_regs_5_endAddr : _GEN_131; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_133 = 3'h6 == channelCounter ? io_regs_6_endAddr : _GEN_132; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _GEN_134 = 3'h7 == channelCounter ? io_regs_7_endAddr : _GEN_133; // @[ChannelState.scala 86:{23,23}]
  wire [23:0] _channelStateReg_addr_T_1 = channelStateReg_addr + 24'h1; // @[ChannelState.scala 90:22]
  wire  _GEN_136 = channelStateReg_addr == _GEN_134 | _GEN_91; // @[ChannelState.scala 86:47 88:14]
  wire [16:0] accumulatorReg_sample_1_left = $signed(accumulatorReg_left) + $signed(audioPipeline_io_out_bits_audio_left
    ); // @[Audio.scala 51:47]
  wire [16:0] accumulatorReg_sample_1_right = $signed(accumulatorReg_right) + $signed(
    audioPipeline_io_out_bits_audio_right); // @[Audio.scala 51:71]
  wire  _T_10 = stateReg == 4'h7; // @[ChannelController.scala 152:44]
  wire  data_enable = _T_10 & channelStateReg_enable; // @[ChannelController.scala 153:19]
  wire  data_active = _T_10 & channelStateReg_active; // @[ChannelController.scala 153:19]
  wire  data_done = _T_10 & channelStateReg_done; // @[ChannelController.scala 153:19]
  wire  data_nibble = _T_10 & channelStateReg_nibble; // @[ChannelController.scala 153:19]
  wire [23:0] data_addr = _T_10 ? channelStateReg_addr : 24'h0; // @[ChannelController.scala 153:19]
  wire  data_loopStart = _T_10 & channelStateReg_loopStart; // @[ChannelController.scala 153:19]
  wire  data_audioPipelineState_underflow = _T_10 ? channelStateReg_audioPipelineState_underflow : 1'h1; // @[ChannelController.scala 153:19]
  wire [9:0] data_audioPipelineState_lerpIndex = _T_10 ? channelStateReg_audioPipelineState_lerpIndex : 10'h0; // @[ChannelController.scala 153:19]
  wire  data_audioPipelineState_loopEnable = _T_10 & channelStateReg_audioPipelineState_loopEnable; // @[ChannelController.scala 153:19]
  wire [15:0] _T_12 = _T_10 ? $signed(channelStateReg_audioPipelineState_loopSample) : $signed(16'sh0); // @[ChannelController.scala 154:48]
  wire [15:0] _T_13 = _T_10 ? $signed(channelStateReg_audioPipelineState_loopStep) : $signed(16'sh0); // @[ChannelController.scala 154:48]
  wire [15:0] _T_14 = _T_10 ? $signed(channelStateReg_audioPipelineState_adpcmStep) : $signed(16'sh7f); // @[ChannelController.scala 154:48]
  wire [15:0] _T_15 = _T_10 ? $signed(channelStateReg_audioPipelineState_samples_0) : $signed(16'sh0); // @[ChannelController.scala 154:48]
  wire [15:0] _T_16 = _T_10 ? $signed(channelStateReg_audioPipelineState_samples_1) : $signed(16'sh0); // @[ChannelController.scala 154:48]
  wire [75:0] lo = {_T_15,data_audioPipelineState_underflow,_T_14,data_audioPipelineState_lerpIndex,
    data_audioPipelineState_loopEnable,_T_13,_T_12}; // @[ChannelController.scala 154:48]
  wire [44:0] hi = {data_enable,data_active,data_done,data_nibble,data_addr,data_loopStart,_T_16}; // @[ChannelController.scala 154:48]
  wire [3:0] _stateReg_T = active ? 4'h5 : 4'h7; // @[ChannelController.scala 176:38]
  wire [3:0] _GEN_166 = audioPipeline_io_in_ready ? 4'h6 : stateReg; // @[ChannelController.scala 180:{39,50} 88:25]
  wire [3:0] _GEN_167 = audioPipeline_io_out_valid ? 4'h7 : stateReg; // @[ChannelController.scala 185:{40,51} 88:25]
  wire [3:0] _stateReg_T_1 = channelCounterWrap ? 4'h9 : 4'h2; // @[ChannelController.scala 192:37]
  wire [3:0] _GEN_168 = outputCounterWrap_wrap_wrap ? 4'h1 : stateReg; // @[ChannelController.scala 196:{31,42} 88:25]
  wire [3:0] _GEN_169 = 4'h9 == stateReg ? _GEN_168 : stateReg; // @[ChannelController.scala 158:20 88:25]
  wire [3:0] _GEN_170 = 4'h8 == stateReg ? _stateReg_T_1 : _GEN_169; // @[ChannelController.scala 158:20 192:31]
  wire [3:0] _GEN_171 = 4'h7 == stateReg ? 4'h8 : _GEN_170; // @[ChannelController.scala 158:20 189:32]
  wire [3:0] _GEN_172 = 4'h6 == stateReg ? _GEN_167 : _GEN_171; // @[ChannelController.scala 158:20]
  wire [3:0] _GEN_173 = 4'h5 == stateReg ? _GEN_166 : _GEN_172; // @[ChannelController.scala 158:20]
  wire [3:0] _GEN_174 = 4'h4 == stateReg ? _stateReg_T : _GEN_173; // @[ChannelController.scala 158:20 176:32]
  wire [3:0] _GEN_175 = 4'h3 == stateReg ? 4'h4 : _GEN_174; // @[ChannelController.scala 158:20 173:32]
  wire [16:0] _io_audio_bits_T_1 = $signed(accumulatorReg_left) < -17'sh8000 ? $signed(-17'sh8000) : $signed(
    accumulatorReg_left); // @[Util.scala 246:51]
  wire [16:0] io_audio_bits_sample_left = $signed(_io_audio_bits_T_1) < 17'sh7fff ? $signed(_io_audio_bits_T_1) :
    $signed(17'sh7fff); // @[Util.scala 246:60]
  wire [16:0] _io_audio_bits_T_5 = $signed(accumulatorReg_right) < -17'sh8000 ? $signed(-17'sh8000) : $signed(
    accumulatorReg_right); // @[Util.scala 246:51]
  wire [16:0] io_audio_bits_sample_right = $signed(_io_audio_bits_T_5) < 17'sh7fff ? $signed(_io_audio_bits_T_5) :
    $signed(17'sh7fff); // @[Util.scala 246:60]
  AudioPipeline audioPipeline ( // @[ChannelController.scala 104:29]
    .clock(audioPipeline_clock),
    .reset(audioPipeline_reset),
    .io_in_ready(audioPipeline_io_in_ready),
    .io_in_valid(audioPipeline_io_in_valid),
    .io_in_bits_state_samples_0(audioPipeline_io_in_bits_state_samples_0),
    .io_in_bits_state_samples_1(audioPipeline_io_in_bits_state_samples_1),
    .io_in_bits_state_underflow(audioPipeline_io_in_bits_state_underflow),
    .io_in_bits_state_adpcmStep(audioPipeline_io_in_bits_state_adpcmStep),
    .io_in_bits_state_lerpIndex(audioPipeline_io_in_bits_state_lerpIndex),
    .io_in_bits_state_loopEnable(audioPipeline_io_in_bits_state_loopEnable),
    .io_in_bits_state_loopStep(audioPipeline_io_in_bits_state_loopStep),
    .io_in_bits_state_loopSample(audioPipeline_io_in_bits_state_loopSample),
    .io_in_bits_pitch(audioPipeline_io_in_bits_pitch),
    .io_in_bits_level(audioPipeline_io_in_bits_level),
    .io_in_bits_pan(audioPipeline_io_in_bits_pan),
    .io_out_valid(audioPipeline_io_out_valid),
    .io_out_bits_state_samples_0(audioPipeline_io_out_bits_state_samples_0),
    .io_out_bits_state_samples_1(audioPipeline_io_out_bits_state_samples_1),
    .io_out_bits_state_underflow(audioPipeline_io_out_bits_state_underflow),
    .io_out_bits_state_adpcmStep(audioPipeline_io_out_bits_state_adpcmStep),
    .io_out_bits_state_lerpIndex(audioPipeline_io_out_bits_state_lerpIndex),
    .io_out_bits_state_loopEnable(audioPipeline_io_out_bits_state_loopEnable),
    .io_out_bits_state_loopStep(audioPipeline_io_out_bits_state_loopStep),
    .io_out_bits_state_loopSample(audioPipeline_io_out_bits_state_loopSample),
    .io_out_bits_audio_left(audioPipeline_io_out_bits_audio_left),
    .io_out_bits_audio_right(audioPipeline_io_out_bits_audio_right),
    .io_pcmData_ready(audioPipeline_io_pcmData_ready),
    .io_pcmData_valid(audioPipeline_io_pcmData_valid),
    .io_pcmData_bits(audioPipeline_io_pcmData_bits),
    .io_loopStart(audioPipeline_io_loopStart)
  );
  assign channelStateMem_channelState_MPORT_en = channelStateMem_channelState_MPORT_en_pipe_0;
  assign channelStateMem_channelState_MPORT_addr = channelStateMem_channelState_MPORT_addr_pipe_0;
  assign channelStateMem_channelState_MPORT_data = channelStateMem[channelStateMem_channelState_MPORT_addr]; // @[ChannelController.scala 99:36]
  assign channelStateMem_MPORT_data = {hi,lo};
  assign channelStateMem_MPORT_addr = channelCounter;
  assign channelStateMem_MPORT_mask = 1'h1;
  assign channelStateMem_MPORT_en = _T | _T_10;
  assign io_done = _T_4 & channelStateReg_done; // @[ChannelController.scala 203:39]
  assign io_index = channelCounter; // @[ChannelController.scala 201:12]
  assign io_audio_valid = outputCounterWrap_value == `YMZ280B_SAMPLE_RATE; // @[Counter.scala 45:24]
  assign io_audio_bits_left = io_audio_bits_sample_left[15:0]; // @[ChannelController.scala 205:17]
  assign io_audio_bits_right = io_audio_bits_sample_right[15:0]; // @[ChannelController.scala 205:17]
  assign io_rom_rd = audioPipeline_io_pcmData_ready & ~pendingReg; // @[ChannelController.scala 122:48]
  assign io_rom_addr = channelStateReg_addr; // @[ChannelController.scala 207:15]
  assign audioPipeline_clock = clock;
  assign audioPipeline_reset = reset;
  assign audioPipeline_io_in_valid = stateReg == 4'h5; // @[ChannelController.scala 105:41]
  assign audioPipeline_io_in_bits_state_samples_0 = channelStateReg_audioPipelineState_samples_0; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_samples_1 = channelStateReg_audioPipelineState_samples_1; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_underflow = channelStateReg_audioPipelineState_underflow; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_adpcmStep = channelStateReg_audioPipelineState_adpcmStep; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_lerpIndex = channelStateReg_audioPipelineState_lerpIndex; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_loopEnable = channelStateReg_audioPipelineState_loopEnable; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_loopStep = channelStateReg_audioPipelineState_loopStep; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_state_loopSample = channelStateReg_audioPipelineState_loopSample; // @[ChannelController.scala 106:34]
  assign audioPipeline_io_in_bits_pitch = 3'h7 == channelCounter ? io_regs_7_pitch : _GEN_33; // @[ChannelController.scala 107:{34,34}]
  assign audioPipeline_io_in_bits_level = 3'h7 == channelCounter ? io_regs_7_level : _GEN_41; // @[ChannelController.scala 108:{34,34}]
  assign audioPipeline_io_in_bits_pan = 3'h7 == channelCounter ? io_regs_7_pan : _GEN_49; // @[ChannelController.scala 109:{32,32}]
  assign audioPipeline_io_pcmData_valid = io_rom_valid; // @[ChannelController.scala 110:34]
  assign audioPipeline_io_pcmData_bits = channelStateReg_nibble ? io_rom_dout[3:0] : io_rom_dout[7:4]; // @[ChannelController.scala 111:39]
  assign audioPipeline_io_loopStart = channelStateReg_loopStart; // @[ChannelController.scala 112:30]
  always @(posedge clock) begin
    if (channelStateMem_MPORT_en & channelStateMem_MPORT_mask) begin
      channelStateMem[channelStateMem_MPORT_addr] <= channelStateMem_MPORT_data; // @[ChannelController.scala 99:36]
    end
    channelStateMem_channelState_MPORT_en_pipe_0 <= stateReg == 4'h2;
    if (stateReg == 4'h2) begin
      channelStateMem_channelState_MPORT_addr_pipe_0 <= channelCounter;
    end
    if (reset) begin // @[ChannelController.scala 88:25]
      stateReg <= 4'h0; // @[ChannelController.scala 88:25]
    end else if (4'h0 == stateReg) begin // @[ChannelController.scala 158:20]
      if (channelCounterWrap) begin // @[ChannelController.scala 161:32]
        stateReg <= 4'h1; // @[ChannelController.scala 161:43]
      end
    end else if (4'h1 == stateReg) begin // @[ChannelController.scala 158:20]
      if (io_enable) begin // @[ChannelController.scala 166:23]
        stateReg <= 4'h2; // @[ChannelController.scala 166:34]
      end
    end else if (4'h2 == stateReg) begin // @[ChannelController.scala 158:20]
      stateReg <= 4'h3; // @[ChannelController.scala 170:31]
    end else begin
      stateReg <= _GEN_175;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      accumulatorReg_left <= accumulatorReg_sample_1_left; // @[ChannelController.scala 145:20]
    end else if (stateReg == 4'h1) begin // @[ChannelController.scala 126:33]
      accumulatorReg_left <= 17'sh0; // @[ChannelController.scala 126:50]
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      accumulatorReg_right <= accumulatorReg_sample_1_right; // @[ChannelController.scala 145:20]
    end else if (stateReg == 4'h1) begin // @[ChannelController.scala 126:33]
      accumulatorReg_right <= 17'sh0; // @[ChannelController.scala 126:50]
    end
    if (reset) begin // @[Counter.scala 40:34]
      channelCounter <= 3'h0; // @[Counter.scala 40:34]
    end else if (_T_2) begin // @[Counter.scala 86:48]
      channelCounter <= _wrap_value_T_1; // @[Counter.scala 46:13]
    end
    if (reset) begin // @[Counter.scala 40:34]
      outputCounterWrap_value <= 11'h0; // @[Counter.scala 40:34]
    end else if (outputCounterWrap_wrap_wrap) begin // @[Counter.scala 48:20]
      outputCounterWrap_value <= 11'h0; // @[Counter.scala 48:28]
    end else begin
      outputCounterWrap_value <= _outputCounterWrap_wrap_value_T_1; // @[Counter.scala 46:13]
    end
    if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      channelStateReg_enable <= _GEN_75;
    end else if (_channelStateReg_T) begin // @[Reg.scala 17:18]
      channelStateReg_enable <= channelState_enable; // @[Reg.scala 17:22]
    end
    if (_T_5) begin // @[ChannelController.scala 140:39]
      if (channelStateReg_nibble) begin // @[ChannelState.scala 83:18]
        if (_GEN_118 & channelStateReg_addr == _GEN_126) begin // @[ChannelState.scala 84:70]
          channelStateReg_active <= _GEN_90;
        end else if (channelStateReg_addr == _GEN_134) begin // @[ChannelState.scala 86:47]
          channelStateReg_active <= 1'h0; // @[ChannelState.scala 87:16]
        end else begin
          channelStateReg_active <= _GEN_90;
        end
      end else begin
        channelStateReg_active <= _GEN_90;
      end
    end else begin
      channelStateReg_active <= _GEN_90;
    end
    if (_T_5) begin // @[ChannelController.scala 140:39]
      if (channelStateReg_nibble) begin // @[ChannelState.scala 83:18]
        if (_GEN_118 & channelStateReg_addr == _GEN_126) begin // @[ChannelState.scala 84:70]
          channelStateReg_done <= _GEN_91;
        end else begin
          channelStateReg_done <= _GEN_136;
        end
      end else begin
        channelStateReg_done <= _GEN_91;
      end
    end else begin
      channelStateReg_done <= _GEN_91;
    end
    if (_T_5) begin // @[ChannelController.scala 140:39]
      channelStateReg_nibble <= _channelStateReg_loopStart_T_2; // @[ChannelState.scala 82:12]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_nibble <= 1'h0; // @[ChannelState.scala 60:12]
      end else begin
        channelStateReg_nibble <= _GEN_16;
      end
    end else begin
      channelStateReg_nibble <= _GEN_16;
    end
    if (_T_5) begin // @[ChannelController.scala 140:39]
      if (channelStateReg_nibble) begin // @[ChannelState.scala 83:18]
        if (_GEN_118 & channelStateReg_addr == _GEN_126) begin // @[ChannelState.scala 84:70]
          if (3'h7 == channelCounter) begin // @[ChannelState.scala 81:48]
            channelStateReg_addr <= io_regs_7_loopStartAddr; // @[ChannelState.scala 81:48]
          end else begin
            channelStateReg_addr <= _GEN_109;
          end
        end else if (channelStateReg_addr == _GEN_134) begin // @[ChannelState.scala 86:47]
          channelStateReg_addr <= _GEN_93;
        end else begin
          channelStateReg_addr <= _channelStateReg_addr_T_1; // @[ChannelState.scala 90:14]
        end
      end else begin
        channelStateReg_addr <= _GEN_93;
      end
    end else begin
      channelStateReg_addr <= _GEN_93;
    end
    if (_T_5) begin // @[ChannelController.scala 140:39]
      channelStateReg_loopStart <= _GEN_118 & channelStateReg_addr == _GEN_110 & ~channelStateReg_nibble; // @[ChannelState.scala 81:15]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_loopStart <= 1'h0; // @[ChannelState.scala 62:15]
      end else begin
        channelStateReg_loopStart <= _GEN_18;
      end
    end else begin
      channelStateReg_loopStart <= _GEN_18;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_samples_0 <= audioPipeline_io_out_bits_state_samples_0; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_samples_0 <= 16'sh0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_samples_0 <= _GEN_19;
      end
    end else begin
      channelStateReg_audioPipelineState_samples_0 <= _GEN_19;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_samples_1 <= audioPipeline_io_out_bits_state_samples_1; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_samples_1 <= 16'sh0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_samples_1 <= _GEN_20;
      end
    end else begin
      channelStateReg_audioPipelineState_samples_1 <= _GEN_20;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_underflow <= audioPipeline_io_out_bits_state_underflow; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      channelStateReg_audioPipelineState_underflow <= _GEN_83;
    end else if (_channelStateReg_T) begin // @[Reg.scala 17:18]
      channelStateReg_audioPipelineState_underflow <= channelState_audioPipelineState_underflow; // @[Reg.scala 17:22]
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_adpcmStep <= audioPipeline_io_out_bits_state_adpcmStep; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_adpcmStep <= 16'sh7f; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_adpcmStep <= _GEN_22;
      end
    end else begin
      channelStateReg_audioPipelineState_adpcmStep <= _GEN_22;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_lerpIndex <= audioPipeline_io_out_bits_state_lerpIndex; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_lerpIndex <= 10'h0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_lerpIndex <= _GEN_23;
      end
    end else begin
      channelStateReg_audioPipelineState_lerpIndex <= _GEN_23;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_loopEnable <= audioPipeline_io_out_bits_state_loopEnable; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_loopEnable <= 1'h0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_loopEnable <= _GEN_24;
      end
    end else begin
      channelStateReg_audioPipelineState_loopEnable <= _GEN_24;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_loopStep <= audioPipeline_io_out_bits_state_loopStep; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_loopStep <= 16'sh0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_loopStep <= _GEN_25;
      end
    end else begin
      channelStateReg_audioPipelineState_loopStep <= _GEN_25;
    end
    if (audioPipeline_io_out_valid) begin // @[ChannelController.scala 143:36]
      channelStateReg_audioPipelineState_loopSample <= audioPipeline_io_out_bits_state_loopSample; // @[ChannelController.scala 148:40]
    end else if (stateReg == 4'h4) begin // @[ChannelController.scala 129:34]
      if (start) begin // @[ChannelController.scala 130:17]
        channelStateReg_audioPipelineState_loopSample <= 16'sh0; // @[ChannelState.scala 63:24]
      end else begin
        channelStateReg_audioPipelineState_loopSample <= _GEN_26;
      end
    end else begin
      channelStateReg_audioPipelineState_loopSample <= _GEN_26;
    end
    if (reset) begin // @[Util.scala 200:28]
      pendingReg <= 1'h0; // @[Util.scala 200:28]
    end else if (io_rom_valid) begin // @[Util.scala 201:17]
      pendingReg <= 1'h0; // @[Util.scala 201:29]
    end else begin
      pendingReg <= _GEN_59;
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,
            "ChannelController(state: %d, index: %d (%d), channelState: ChannelState(enable -> %d, active -> %d, done -> %d, nibble -> %d, addr -> %d, loopStart -> %d, audioPipelineState -> AudioPipelineState(samples -> Vec(%d, %d), underflow -> %d, adpcmStep -> %d, lerpIndex -> %d, loopEnable -> %d, loopStep -> %d, loopSample -> %d)), audio: Audio(left -> %d, right -> %d) (%d))\n"
            ,stateReg,channelCounter,channelCounterWrap,channelStateReg_enable,channelStateReg_active,
            channelStateReg_done,channelStateReg_nibble,channelStateReg_addr,channelStateReg_loopStart,
            channelStateReg_audioPipelineState_samples_0,channelStateReg_audioPipelineState_samples_1,
            channelStateReg_audioPipelineState_underflow,channelStateReg_audioPipelineState_adpcmStep,
            channelStateReg_audioPipelineState_lerpIndex,channelStateReg_audioPipelineState_loopEnable,
            channelStateReg_audioPipelineState_loopStep,channelStateReg_audioPipelineState_loopSample,
            accumulatorReg_left,accumulatorReg_right,outputCounterWrap_wrap_wrap); // @[ChannelController.scala 220:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_MEM_INIT
  _RAND_0 = {4{`RANDOM}};
  for (initvar = 0; initvar < 8; initvar = initvar+1)
    channelStateMem[initvar] = _RAND_0[120:0];
`endif // RANDOMIZE_MEM_INIT
`ifdef RANDOMIZE_REG_INIT
  _RAND_1 = {1{`RANDOM}};
  channelStateMem_channelState_MPORT_en_pipe_0 = _RAND_1[0:0];
  _RAND_2 = {1{`RANDOM}};
  channelStateMem_channelState_MPORT_addr_pipe_0 = _RAND_2[2:0];
  _RAND_3 = {1{`RANDOM}};
  stateReg = _RAND_3[3:0];
  _RAND_4 = {1{`RANDOM}};
  accumulatorReg_left = _RAND_4[16:0];
  _RAND_5 = {1{`RANDOM}};
  accumulatorReg_right = _RAND_5[16:0];
  _RAND_6 = {1{`RANDOM}};
  channelCounter = _RAND_6[2:0];
  _RAND_7 = {1{`RANDOM}};
  outputCounterWrap_value = _RAND_7[10:0];
  _RAND_8 = {1{`RANDOM}};
  channelStateReg_enable = _RAND_8[0:0];
  _RAND_9 = {1{`RANDOM}};
  channelStateReg_active = _RAND_9[0:0];
  _RAND_10 = {1{`RANDOM}};
  channelStateReg_done = _RAND_10[0:0];
  _RAND_11 = {1{`RANDOM}};
  channelStateReg_nibble = _RAND_11[0:0];
  _RAND_12 = {1{`RANDOM}};
  channelStateReg_addr = _RAND_12[23:0];
  _RAND_13 = {1{`RANDOM}};
  channelStateReg_loopStart = _RAND_13[0:0];
  _RAND_14 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_samples_0 = _RAND_14[15:0];
  _RAND_15 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_samples_1 = _RAND_15[15:0];
  _RAND_16 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_underflow = _RAND_16[0:0];
  _RAND_17 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_adpcmStep = _RAND_17[15:0];
  _RAND_18 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_lerpIndex = _RAND_18[9:0];
  _RAND_19 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_loopEnable = _RAND_19[0:0];
  _RAND_20 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_loopStep = _RAND_20[15:0];
  _RAND_21 = {1{`RANDOM}};
  channelStateReg_audioPipelineState_loopSample = _RAND_21[15:0];
  _RAND_22 = {1{`RANDOM}};
  pendingReg = _RAND_22[0:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
module YMZ280B(
  input         clock,
  input         reset,
  input         io_cpu_rd,
  input         io_cpu_wr,
  input         io_cpu_addr,
  input         io_cpu_mask,
  input  [7:0]  io_cpu_din,
  output [7:0]  io_cpu_dout,
  output        io_rom_rd,
  output [23:0] io_rom_addr,
  input  [7:0]  io_rom_dout,
  input         io_rom_waitReq,
  input         io_rom_valid,
  output        io_audio_valid,
  output [15:0] io_audio_bits_left,
  output [15:0] io_audio_bits_right,
  output        io_irq,
  output [7:0]  io_debug_channels_0_pitch,
  output        io_debug_channels_0_flags_keyOn,
  output [1:0]  io_debug_channels_0_flags_quantizationMode,
  output        io_debug_channels_0_flags_loop,
  output [7:0]  io_debug_channels_0_level,
  output [3:0]  io_debug_channels_0_pan,
  output [23:0] io_debug_channels_0_startAddr,
  output [23:0] io_debug_channels_0_loopStartAddr,
  output [23:0] io_debug_channels_0_loopEndAddr,
  output [23:0] io_debug_channels_0_endAddr,
  output [7:0]  io_debug_channels_1_pitch,
  output        io_debug_channels_1_flags_keyOn,
  output [1:0]  io_debug_channels_1_flags_quantizationMode,
  output        io_debug_channels_1_flags_loop,
  output [7:0]  io_debug_channels_1_level,
  output [3:0]  io_debug_channels_1_pan,
  output [23:0] io_debug_channels_1_startAddr,
  output [23:0] io_debug_channels_1_loopStartAddr,
  output [23:0] io_debug_channels_1_loopEndAddr,
  output [23:0] io_debug_channels_1_endAddr,
  output [7:0]  io_debug_channels_2_pitch,
  output        io_debug_channels_2_flags_keyOn,
  output [1:0]  io_debug_channels_2_flags_quantizationMode,
  output        io_debug_channels_2_flags_loop,
  output [7:0]  io_debug_channels_2_level,
  output [3:0]  io_debug_channels_2_pan,
  output [23:0] io_debug_channels_2_startAddr,
  output [23:0] io_debug_channels_2_loopStartAddr,
  output [23:0] io_debug_channels_2_loopEndAddr,
  output [23:0] io_debug_channels_2_endAddr,
  output [7:0]  io_debug_channels_3_pitch,
  output        io_debug_channels_3_flags_keyOn,
  output [1:0]  io_debug_channels_3_flags_quantizationMode,
  output        io_debug_channels_3_flags_loop,
  output [7:0]  io_debug_channels_3_level,
  output [3:0]  io_debug_channels_3_pan,
  output [23:0] io_debug_channels_3_startAddr,
  output [23:0] io_debug_channels_3_loopStartAddr,
  output [23:0] io_debug_channels_3_loopEndAddr,
  output [23:0] io_debug_channels_3_endAddr,
  output [7:0]  io_debug_channels_4_pitch,
  output        io_debug_channels_4_flags_keyOn,
  output [1:0]  io_debug_channels_4_flags_quantizationMode,
  output        io_debug_channels_4_flags_loop,
  output [7:0]  io_debug_channels_4_level,
  output [3:0]  io_debug_channels_4_pan,
  output [23:0] io_debug_channels_4_startAddr,
  output [23:0] io_debug_channels_4_loopStartAddr,
  output [23:0] io_debug_channels_4_loopEndAddr,
  output [23:0] io_debug_channels_4_endAddr,
  output [7:0]  io_debug_channels_5_pitch,
  output        io_debug_channels_5_flags_keyOn,
  output [1:0]  io_debug_channels_5_flags_quantizationMode,
  output        io_debug_channels_5_flags_loop,
  output [7:0]  io_debug_channels_5_level,
  output [3:0]  io_debug_channels_5_pan,
  output [23:0] io_debug_channels_5_startAddr,
  output [23:0] io_debug_channels_5_loopStartAddr,
  output [23:0] io_debug_channels_5_loopEndAddr,
  output [23:0] io_debug_channels_5_endAddr,
  output [7:0]  io_debug_channels_6_pitch,
  output        io_debug_channels_6_flags_keyOn,
  output [1:0]  io_debug_channels_6_flags_quantizationMode,
  output        io_debug_channels_6_flags_loop,
  output [7:0]  io_debug_channels_6_level,
  output [3:0]  io_debug_channels_6_pan,
  output [23:0] io_debug_channels_6_startAddr,
  output [23:0] io_debug_channels_6_loopStartAddr,
  output [23:0] io_debug_channels_6_loopEndAddr,
  output [23:0] io_debug_channels_6_endAddr,
  output [7:0]  io_debug_channels_7_pitch,
  output        io_debug_channels_7_flags_keyOn,
  output [1:0]  io_debug_channels_7_flags_quantizationMode,
  output        io_debug_channels_7_flags_loop,
  output [7:0]  io_debug_channels_7_level,
  output [3:0]  io_debug_channels_7_pan,
  output [23:0] io_debug_channels_7_startAddr,
  output [23:0] io_debug_channels_7_loopStartAddr,
  output [23:0] io_debug_channels_7_loopEndAddr,
  output [23:0] io_debug_channels_7_endAddr,
  output [7:0]  io_debug_utilReg_irqMask,
  output        io_debug_utilReg_flags_keyOnEnable,
  output        io_debug_utilReg_flags_memEnable,
  output        io_debug_utilReg_flags_irqEnable,
  output [7:0]  io_debug_statusReg
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
  reg [31:0] _RAND_3;
  reg [31:0] _RAND_4;
  reg [31:0] _RAND_5;
  reg [31:0] _RAND_6;
  reg [31:0] _RAND_7;
  reg [31:0] _RAND_8;
  reg [31:0] _RAND_9;
  reg [31:0] _RAND_10;
  reg [31:0] _RAND_11;
  reg [31:0] _RAND_12;
  reg [31:0] _RAND_13;
  reg [31:0] _RAND_14;
  reg [31:0] _RAND_15;
  reg [31:0] _RAND_16;
  reg [31:0] _RAND_17;
  reg [31:0] _RAND_18;
  reg [31:0] _RAND_19;
  reg [31:0] _RAND_20;
  reg [31:0] _RAND_21;
  reg [31:0] _RAND_22;
  reg [31:0] _RAND_23;
  reg [31:0] _RAND_24;
  reg [31:0] _RAND_25;
  reg [31:0] _RAND_26;
  reg [31:0] _RAND_27;
  reg [31:0] _RAND_28;
  reg [31:0] _RAND_29;
  reg [31:0] _RAND_30;
  reg [31:0] _RAND_31;
  reg [31:0] _RAND_32;
  reg [31:0] _RAND_33;
  reg [31:0] _RAND_34;
  reg [31:0] _RAND_35;
  reg [31:0] _RAND_36;
  reg [31:0] _RAND_37;
  reg [31:0] _RAND_38;
  reg [31:0] _RAND_39;
  reg [31:0] _RAND_40;
  reg [31:0] _RAND_41;
  reg [31:0] _RAND_42;
  reg [31:0] _RAND_43;
  reg [31:0] _RAND_44;
  reg [31:0] _RAND_45;
  reg [31:0] _RAND_46;
  reg [31:0] _RAND_47;
  reg [31:0] _RAND_48;
  reg [31:0] _RAND_49;
  reg [31:0] _RAND_50;
  reg [31:0] _RAND_51;
  reg [31:0] _RAND_52;
  reg [31:0] _RAND_53;
  reg [31:0] _RAND_54;
  reg [31:0] _RAND_55;
  reg [31:0] _RAND_56;
  reg [31:0] _RAND_57;
  reg [31:0] _RAND_58;
  reg [31:0] _RAND_59;
  reg [31:0] _RAND_60;
  reg [31:0] _RAND_61;
  reg [31:0] _RAND_62;
  reg [31:0] _RAND_63;
  reg [31:0] _RAND_64;
  reg [31:0] _RAND_65;
  reg [31:0] _RAND_66;
  reg [31:0] _RAND_67;
  reg [31:0] _RAND_68;
  reg [31:0] _RAND_69;
  reg [31:0] _RAND_70;
  reg [31:0] _RAND_71;
  reg [31:0] _RAND_72;
  reg [31:0] _RAND_73;
  reg [31:0] _RAND_74;
  reg [31:0] _RAND_75;
  reg [31:0] _RAND_76;
  reg [31:0] _RAND_77;
  reg [31:0] _RAND_78;
  reg [31:0] _RAND_79;
  reg [31:0] _RAND_80;
  reg [31:0] _RAND_81;
  reg [31:0] _RAND_82;
  reg [31:0] _RAND_83;
  reg [31:0] _RAND_84;
  reg [31:0] _RAND_85;
  reg [31:0] _RAND_86;
  reg [31:0] _RAND_87;
  reg [31:0] _RAND_88;
  reg [31:0] _RAND_89;
  reg [31:0] _RAND_90;
  reg [31:0] _RAND_91;
  reg [31:0] _RAND_92;
  reg [31:0] _RAND_93;
  reg [31:0] _RAND_94;
  reg [31:0] _RAND_95;
  reg [31:0] _RAND_96;
  reg [31:0] _RAND_97;
  reg [31:0] _RAND_98;
  reg [31:0] _RAND_99;
  reg [31:0] _RAND_100;
  reg [31:0] _RAND_101;
  reg [31:0] _RAND_102;
  reg [31:0] _RAND_103;
  reg [31:0] _RAND_104;
  reg [31:0] _RAND_105;
  reg [31:0] _RAND_106;
  reg [31:0] _RAND_107;
  reg [31:0] _RAND_108;
  reg [31:0] _RAND_109;
  reg [31:0] _RAND_110;
  reg [31:0] _RAND_111;
  reg [31:0] _RAND_112;
  reg [31:0] _RAND_113;
  reg [31:0] _RAND_114;
  reg [31:0] _RAND_115;
  reg [31:0] _RAND_116;
  reg [31:0] _RAND_117;
  reg [31:0] _RAND_118;
  reg [31:0] _RAND_119;
  reg [31:0] _RAND_120;
  reg [31:0] _RAND_121;
  reg [31:0] _RAND_122;
  reg [31:0] _RAND_123;
  reg [31:0] _RAND_124;
  reg [31:0] _RAND_125;
  reg [31:0] _RAND_126;
  reg [31:0] _RAND_127;
  reg [31:0] _RAND_128;
  reg [31:0] _RAND_129;
  reg [31:0] _RAND_130;
  reg [31:0] _RAND_131;
  reg [31:0] _RAND_132;
`endif // RANDOMIZE_REG_INIT
  wire  channelCtrl_clock; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_reset; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_0_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_0_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_0_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_0_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_0_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_0_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_0_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_0_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_0_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_1_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_1_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_1_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_1_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_1_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_1_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_1_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_1_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_1_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_2_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_2_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_2_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_2_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_2_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_2_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_2_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_2_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_2_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_3_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_3_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_3_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_3_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_3_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_3_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_3_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_3_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_3_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_4_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_4_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_4_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_4_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_4_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_4_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_4_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_4_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_4_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_5_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_5_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_5_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_5_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_5_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_5_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_5_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_5_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_5_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_6_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_6_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_6_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_6_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_6_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_6_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_6_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_6_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_6_endAddr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_7_pitch; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_7_flags_keyOn; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_regs_7_flags_loop; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_regs_7_level; // @[YMZ280B.scala 117:27]
  wire [3:0] channelCtrl_io_regs_7_pan; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_7_startAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_7_loopStartAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_7_loopEndAddr; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_regs_7_endAddr; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_enable; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_done; // @[YMZ280B.scala 117:27]
  wire [2:0] channelCtrl_io_index; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_audio_valid; // @[YMZ280B.scala 117:27]
  wire [15:0] channelCtrl_io_audio_bits_left; // @[YMZ280B.scala 117:27]
  wire [15:0] channelCtrl_io_audio_bits_right; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_rom_rd; // @[YMZ280B.scala 117:27]
  wire [23:0] channelCtrl_io_rom_addr; // @[YMZ280B.scala 117:27]
  wire [7:0] channelCtrl_io_rom_dout; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_rom_waitReq; // @[YMZ280B.scala 117:27]
  wire  channelCtrl_io_rom_valid; // @[YMZ280B.scala 117:27]
  reg [7:0] addrReg; // @[YMZ280B.scala 105:24]
  reg [7:0] dataReg; // @[YMZ280B.scala 106:24]
  reg [7:0] statusReg; // @[YMZ280B.scala 107:26]
  reg [7:0] registerFile_0; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_1; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_2; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_3; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_4; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_5; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_6; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_7; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_8; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_9; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_10; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_11; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_12; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_13; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_14; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_15; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_16; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_17; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_18; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_19; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_20; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_21; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_22; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_23; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_24; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_25; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_26; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_27; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_28; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_29; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_30; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_31; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_32; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_33; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_34; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_35; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_36; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_37; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_38; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_39; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_40; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_41; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_42; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_43; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_44; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_45; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_46; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_47; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_48; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_49; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_50; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_51; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_52; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_53; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_54; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_55; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_56; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_57; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_58; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_59; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_60; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_61; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_62; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_63; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_64; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_65; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_66; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_67; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_68; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_69; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_70; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_71; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_72; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_73; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_74; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_75; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_76; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_77; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_78; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_79; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_80; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_81; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_82; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_83; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_84; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_85; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_86; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_87; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_88; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_89; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_90; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_91; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_92; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_93; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_94; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_95; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_96; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_97; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_98; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_99; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_100; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_101; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_102; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_103; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_104; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_105; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_106; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_107; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_108; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_109; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_110; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_111; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_112; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_113; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_114; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_115; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_116; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_117; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_118; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_119; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_120; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_121; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_122; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_123; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_124; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_125; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_126; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_127; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_254; // @[YMZ280B.scala 108:29]
  reg [7:0] registerFile_255; // @[YMZ280B.scala 108:29]
  wire [63:0] channelRegs_lo = {registerFile_65,registerFile_97,registerFile_34,registerFile_66,registerFile_98,
    registerFile_35,registerFile_67,registerFile_99}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_2 = {registerFile_0,registerFile_1[7:4],registerFile_2,registerFile_3[3:0],registerFile_32
    ,registerFile_64,registerFile_96,registerFile_33,channelRegs_lo}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_1 = {registerFile_69,registerFile_101,registerFile_38,registerFile_70,registerFile_102,
    registerFile_39,registerFile_71,registerFile_103}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_15 = {registerFile_4,registerFile_5[7:4],registerFile_6,registerFile_7[3:0],
    registerFile_36,registerFile_68,registerFile_100,registerFile_37,channelRegs_lo_1}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_2 = {registerFile_73,registerFile_105,registerFile_42,registerFile_74,registerFile_106,
    registerFile_43,registerFile_75,registerFile_107}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_28 = {registerFile_8,registerFile_9[7:4],registerFile_10,registerFile_11[3:0],
    registerFile_40,registerFile_72,registerFile_104,registerFile_41,channelRegs_lo_2}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_3 = {registerFile_77,registerFile_109,registerFile_46,registerFile_78,registerFile_110,
    registerFile_47,registerFile_79,registerFile_111}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_41 = {registerFile_12,registerFile_13[7:4],registerFile_14,registerFile_15[3:0],
    registerFile_44,registerFile_76,registerFile_108,registerFile_45,channelRegs_lo_3}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_4 = {registerFile_81,registerFile_113,registerFile_50,registerFile_82,registerFile_114,
    registerFile_51,registerFile_83,registerFile_115}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_54 = {registerFile_16,registerFile_17[7:4],registerFile_18,registerFile_19[3:0],
    registerFile_48,registerFile_80,registerFile_112,registerFile_49,channelRegs_lo_4}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_5 = {registerFile_85,registerFile_117,registerFile_54,registerFile_86,registerFile_118,
    registerFile_55,registerFile_87,registerFile_119}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_67 = {registerFile_20,registerFile_21[7:4],registerFile_22,registerFile_23[3:0],
    registerFile_52,registerFile_84,registerFile_116,registerFile_53,channelRegs_lo_5}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_6 = {registerFile_89,registerFile_121,registerFile_58,registerFile_90,registerFile_122,
    registerFile_59,registerFile_91,registerFile_123}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_80 = {registerFile_24,registerFile_25[7:4],registerFile_26,registerFile_27[3:0],
    registerFile_56,registerFile_88,registerFile_120,registerFile_57,channelRegs_lo_6}; // @[Cat.scala 31:58]
  wire [63:0] channelRegs_lo_7 = {registerFile_93,registerFile_125,registerFile_62,registerFile_94,registerFile_126,
    registerFile_63,registerFile_95,registerFile_127}; // @[Cat.scala 31:58]
  wire [119:0] _channelRegs_T_93 = {registerFile_28,registerFile_29[7:4],registerFile_30,registerFile_31[3:0],
    registerFile_60,registerFile_92,registerFile_124,registerFile_61,channelRegs_lo_7}; // @[Cat.scala 31:58]
  wire [10:0] _utilReg_T_3 = {registerFile_254,registerFile_255[7],registerFile_255[6],registerFile_255[4]}; // @[Cat.scala 31:58]
  wire  utilReg_flags_irqEnable = _utilReg_T_3[0]; // @[UtilReg.scala 65:15]
  wire [7:0] utilReg_irqMask = _utilReg_T_3[10:3]; // @[UtilReg.scala 65:15]
  wire  writeAddr = io_cpu_wr & ~io_cpu_addr; // @[YMZ280B.scala 124:29]
  wire  writeData = io_cpu_wr & io_cpu_addr; // @[YMZ280B.scala 125:29]
  wire  readStatus = io_cpu_rd & io_cpu_addr; // @[YMZ280B.scala 126:30]
  wire [7:0] _statusReg_T = 8'h1 << channelCtrl_io_index; // @[YMZ280B.scala 135:60]
  wire [7:0] _statusReg_T_1 = statusReg | _statusReg_T; // @[YMZ280B.scala 135:60]
  wire [7:0] _io_irq_T = statusReg & utilReg_irqMask; // @[YMZ280B.scala 145:51]
  ChannelController channelCtrl ( // @[YMZ280B.scala 117:27]
    .clock(channelCtrl_clock),
    .reset(channelCtrl_reset),
    .io_regs_0_pitch(channelCtrl_io_regs_0_pitch),
    .io_regs_0_flags_keyOn(channelCtrl_io_regs_0_flags_keyOn),
    .io_regs_0_flags_loop(channelCtrl_io_regs_0_flags_loop),
    .io_regs_0_level(channelCtrl_io_regs_0_level),
    .io_regs_0_pan(channelCtrl_io_regs_0_pan),
    .io_regs_0_startAddr(channelCtrl_io_regs_0_startAddr),
    .io_regs_0_loopStartAddr(channelCtrl_io_regs_0_loopStartAddr),
    .io_regs_0_loopEndAddr(channelCtrl_io_regs_0_loopEndAddr),
    .io_regs_0_endAddr(channelCtrl_io_regs_0_endAddr),
    .io_regs_1_pitch(channelCtrl_io_regs_1_pitch),
    .io_regs_1_flags_keyOn(channelCtrl_io_regs_1_flags_keyOn),
    .io_regs_1_flags_loop(channelCtrl_io_regs_1_flags_loop),
    .io_regs_1_level(channelCtrl_io_regs_1_level),
    .io_regs_1_pan(channelCtrl_io_regs_1_pan),
    .io_regs_1_startAddr(channelCtrl_io_regs_1_startAddr),
    .io_regs_1_loopStartAddr(channelCtrl_io_regs_1_loopStartAddr),
    .io_regs_1_loopEndAddr(channelCtrl_io_regs_1_loopEndAddr),
    .io_regs_1_endAddr(channelCtrl_io_regs_1_endAddr),
    .io_regs_2_pitch(channelCtrl_io_regs_2_pitch),
    .io_regs_2_flags_keyOn(channelCtrl_io_regs_2_flags_keyOn),
    .io_regs_2_flags_loop(channelCtrl_io_regs_2_flags_loop),
    .io_regs_2_level(channelCtrl_io_regs_2_level),
    .io_regs_2_pan(channelCtrl_io_regs_2_pan),
    .io_regs_2_startAddr(channelCtrl_io_regs_2_startAddr),
    .io_regs_2_loopStartAddr(channelCtrl_io_regs_2_loopStartAddr),
    .io_regs_2_loopEndAddr(channelCtrl_io_regs_2_loopEndAddr),
    .io_regs_2_endAddr(channelCtrl_io_regs_2_endAddr),
    .io_regs_3_pitch(channelCtrl_io_regs_3_pitch),
    .io_regs_3_flags_keyOn(channelCtrl_io_regs_3_flags_keyOn),
    .io_regs_3_flags_loop(channelCtrl_io_regs_3_flags_loop),
    .io_regs_3_level(channelCtrl_io_regs_3_level),
    .io_regs_3_pan(channelCtrl_io_regs_3_pan),
    .io_regs_3_startAddr(channelCtrl_io_regs_3_startAddr),
    .io_regs_3_loopStartAddr(channelCtrl_io_regs_3_loopStartAddr),
    .io_regs_3_loopEndAddr(channelCtrl_io_regs_3_loopEndAddr),
    .io_regs_3_endAddr(channelCtrl_io_regs_3_endAddr),
    .io_regs_4_pitch(channelCtrl_io_regs_4_pitch),
    .io_regs_4_flags_keyOn(channelCtrl_io_regs_4_flags_keyOn),
    .io_regs_4_flags_loop(channelCtrl_io_regs_4_flags_loop),
    .io_regs_4_level(channelCtrl_io_regs_4_level),
    .io_regs_4_pan(channelCtrl_io_regs_4_pan),
    .io_regs_4_startAddr(channelCtrl_io_regs_4_startAddr),
    .io_regs_4_loopStartAddr(channelCtrl_io_regs_4_loopStartAddr),
    .io_regs_4_loopEndAddr(channelCtrl_io_regs_4_loopEndAddr),
    .io_regs_4_endAddr(channelCtrl_io_regs_4_endAddr),
    .io_regs_5_pitch(channelCtrl_io_regs_5_pitch),
    .io_regs_5_flags_keyOn(channelCtrl_io_regs_5_flags_keyOn),
    .io_regs_5_flags_loop(channelCtrl_io_regs_5_flags_loop),
    .io_regs_5_level(channelCtrl_io_regs_5_level),
    .io_regs_5_pan(channelCtrl_io_regs_5_pan),
    .io_regs_5_startAddr(channelCtrl_io_regs_5_startAddr),
    .io_regs_5_loopStartAddr(channelCtrl_io_regs_5_loopStartAddr),
    .io_regs_5_loopEndAddr(channelCtrl_io_regs_5_loopEndAddr),
    .io_regs_5_endAddr(channelCtrl_io_regs_5_endAddr),
    .io_regs_6_pitch(channelCtrl_io_regs_6_pitch),
    .io_regs_6_flags_keyOn(channelCtrl_io_regs_6_flags_keyOn),
    .io_regs_6_flags_loop(channelCtrl_io_regs_6_flags_loop),
    .io_regs_6_level(channelCtrl_io_regs_6_level),
    .io_regs_6_pan(channelCtrl_io_regs_6_pan),
    .io_regs_6_startAddr(channelCtrl_io_regs_6_startAddr),
    .io_regs_6_loopStartAddr(channelCtrl_io_regs_6_loopStartAddr),
    .io_regs_6_loopEndAddr(channelCtrl_io_regs_6_loopEndAddr),
    .io_regs_6_endAddr(channelCtrl_io_regs_6_endAddr),
    .io_regs_7_pitch(channelCtrl_io_regs_7_pitch),
    .io_regs_7_flags_keyOn(channelCtrl_io_regs_7_flags_keyOn),
    .io_regs_7_flags_loop(channelCtrl_io_regs_7_flags_loop),
    .io_regs_7_level(channelCtrl_io_regs_7_level),
    .io_regs_7_pan(channelCtrl_io_regs_7_pan),
    .io_regs_7_startAddr(channelCtrl_io_regs_7_startAddr),
    .io_regs_7_loopStartAddr(channelCtrl_io_regs_7_loopStartAddr),
    .io_regs_7_loopEndAddr(channelCtrl_io_regs_7_loopEndAddr),
    .io_regs_7_endAddr(channelCtrl_io_regs_7_endAddr),
    .io_enable(channelCtrl_io_enable),
    .io_done(channelCtrl_io_done),
    .io_index(channelCtrl_io_index),
    .io_audio_valid(channelCtrl_io_audio_valid),
    .io_audio_bits_left(channelCtrl_io_audio_bits_left),
    .io_audio_bits_right(channelCtrl_io_audio_bits_right),
    .io_rom_rd(channelCtrl_io_rom_rd),
    .io_rom_addr(channelCtrl_io_rom_addr),
    .io_rom_dout(channelCtrl_io_rom_dout),
    .io_rom_waitReq(channelCtrl_io_rom_waitReq),
    .io_rom_valid(channelCtrl_io_rom_valid)
  );
  assign io_cpu_dout = dataReg; // @[YMZ280B.scala 144:15]
  assign io_rom_rd = channelCtrl_io_rom_rd; // @[YMZ280B.scala 121:22]
  assign io_rom_addr = channelCtrl_io_rom_addr; // @[YMZ280B.scala 121:22]
  assign io_audio_valid = channelCtrl_io_audio_valid; // @[YMZ280B.scala 120:24]
  assign io_audio_bits_left = channelCtrl_io_audio_bits_left; // @[YMZ280B.scala 120:24]
  assign io_audio_bits_right = channelCtrl_io_audio_bits_right; // @[YMZ280B.scala 120:24]
  assign io_irq = utilReg_flags_irqEnable & |_io_irq_T; // @[YMZ280B.scala 145:37]
  assign io_debug_channels_0_pitch = _channelRegs_T_2[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_flags_keyOn = _channelRegs_T_2[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_flags_quantizationMode = _channelRegs_T_2[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_flags_loop = _channelRegs_T_2[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_level = _channelRegs_T_2[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_pan = _channelRegs_T_2[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_startAddr = _channelRegs_T_2[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_loopStartAddr = _channelRegs_T_2[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_loopEndAddr = _channelRegs_T_2[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_0_endAddr = _channelRegs_T_2[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_pitch = _channelRegs_T_15[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_flags_keyOn = _channelRegs_T_15[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_flags_quantizationMode = _channelRegs_T_15[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_flags_loop = _channelRegs_T_15[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_level = _channelRegs_T_15[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_pan = _channelRegs_T_15[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_startAddr = _channelRegs_T_15[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_loopStartAddr = _channelRegs_T_15[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_loopEndAddr = _channelRegs_T_15[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_1_endAddr = _channelRegs_T_15[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_pitch = _channelRegs_T_28[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_flags_keyOn = _channelRegs_T_28[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_flags_quantizationMode = _channelRegs_T_28[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_flags_loop = _channelRegs_T_28[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_level = _channelRegs_T_28[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_pan = _channelRegs_T_28[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_startAddr = _channelRegs_T_28[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_loopStartAddr = _channelRegs_T_28[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_loopEndAddr = _channelRegs_T_28[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_2_endAddr = _channelRegs_T_28[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_pitch = _channelRegs_T_41[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_flags_keyOn = _channelRegs_T_41[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_flags_quantizationMode = _channelRegs_T_41[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_flags_loop = _channelRegs_T_41[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_level = _channelRegs_T_41[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_pan = _channelRegs_T_41[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_startAddr = _channelRegs_T_41[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_loopStartAddr = _channelRegs_T_41[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_loopEndAddr = _channelRegs_T_41[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_3_endAddr = _channelRegs_T_41[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_pitch = _channelRegs_T_54[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_flags_keyOn = _channelRegs_T_54[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_flags_quantizationMode = _channelRegs_T_54[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_flags_loop = _channelRegs_T_54[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_level = _channelRegs_T_54[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_pan = _channelRegs_T_54[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_startAddr = _channelRegs_T_54[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_loopStartAddr = _channelRegs_T_54[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_loopEndAddr = _channelRegs_T_54[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_4_endAddr = _channelRegs_T_54[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_pitch = _channelRegs_T_67[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_flags_keyOn = _channelRegs_T_67[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_flags_quantizationMode = _channelRegs_T_67[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_flags_loop = _channelRegs_T_67[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_level = _channelRegs_T_67[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_pan = _channelRegs_T_67[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_startAddr = _channelRegs_T_67[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_loopStartAddr = _channelRegs_T_67[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_loopEndAddr = _channelRegs_T_67[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_5_endAddr = _channelRegs_T_67[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_pitch = _channelRegs_T_80[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_flags_keyOn = _channelRegs_T_80[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_flags_quantizationMode = _channelRegs_T_80[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_flags_loop = _channelRegs_T_80[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_level = _channelRegs_T_80[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_pan = _channelRegs_T_80[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_startAddr = _channelRegs_T_80[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_loopStartAddr = _channelRegs_T_80[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_loopEndAddr = _channelRegs_T_80[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_6_endAddr = _channelRegs_T_80[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_pitch = _channelRegs_T_93[119:112]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_flags_keyOn = _channelRegs_T_93[111]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_flags_quantizationMode = _channelRegs_T_93[110:109]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_flags_loop = _channelRegs_T_93[108]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_level = _channelRegs_T_93[107:100]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_pan = _channelRegs_T_93[99:96]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_startAddr = _channelRegs_T_93[95:72]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_loopStartAddr = _channelRegs_T_93[71:48]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_loopEndAddr = _channelRegs_T_93[47:24]; // @[ChannelReg.scala 101:15]
  assign io_debug_channels_7_endAddr = _channelRegs_T_93[23:0]; // @[ChannelReg.scala 101:15]
  assign io_debug_utilReg_irqMask = _utilReg_T_3[10:3]; // @[UtilReg.scala 65:15]
  assign io_debug_utilReg_flags_keyOnEnable = _utilReg_T_3[2]; // @[UtilReg.scala 65:15]
  assign io_debug_utilReg_flags_memEnable = _utilReg_T_3[1]; // @[UtilReg.scala 65:15]
  assign io_debug_utilReg_flags_irqEnable = _utilReg_T_3[0]; // @[UtilReg.scala 65:15]
  assign io_debug_statusReg = statusReg; // @[YMZ280B.scala 148:22]
  assign channelCtrl_clock = clock;
  assign channelCtrl_reset = reset;
  assign channelCtrl_io_regs_0_pitch = _channelRegs_T_2[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_flags_keyOn = _channelRegs_T_2[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_flags_loop = _channelRegs_T_2[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_level = _channelRegs_T_2[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_pan = _channelRegs_T_2[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_startAddr = _channelRegs_T_2[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_loopStartAddr = _channelRegs_T_2[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_loopEndAddr = _channelRegs_T_2[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_0_endAddr = _channelRegs_T_2[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_pitch = _channelRegs_T_15[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_flags_keyOn = _channelRegs_T_15[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_flags_loop = _channelRegs_T_15[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_level = _channelRegs_T_15[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_pan = _channelRegs_T_15[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_startAddr = _channelRegs_T_15[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_loopStartAddr = _channelRegs_T_15[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_loopEndAddr = _channelRegs_T_15[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_1_endAddr = _channelRegs_T_15[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_pitch = _channelRegs_T_28[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_flags_keyOn = _channelRegs_T_28[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_flags_loop = _channelRegs_T_28[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_level = _channelRegs_T_28[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_pan = _channelRegs_T_28[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_startAddr = _channelRegs_T_28[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_loopStartAddr = _channelRegs_T_28[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_loopEndAddr = _channelRegs_T_28[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_2_endAddr = _channelRegs_T_28[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_pitch = _channelRegs_T_41[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_flags_keyOn = _channelRegs_T_41[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_flags_loop = _channelRegs_T_41[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_level = _channelRegs_T_41[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_pan = _channelRegs_T_41[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_startAddr = _channelRegs_T_41[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_loopStartAddr = _channelRegs_T_41[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_loopEndAddr = _channelRegs_T_41[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_3_endAddr = _channelRegs_T_41[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_pitch = _channelRegs_T_54[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_flags_keyOn = _channelRegs_T_54[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_flags_loop = _channelRegs_T_54[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_level = _channelRegs_T_54[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_pan = _channelRegs_T_54[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_startAddr = _channelRegs_T_54[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_loopStartAddr = _channelRegs_T_54[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_loopEndAddr = _channelRegs_T_54[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_4_endAddr = _channelRegs_T_54[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_pitch = _channelRegs_T_67[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_flags_keyOn = _channelRegs_T_67[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_flags_loop = _channelRegs_T_67[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_level = _channelRegs_T_67[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_pan = _channelRegs_T_67[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_startAddr = _channelRegs_T_67[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_loopStartAddr = _channelRegs_T_67[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_loopEndAddr = _channelRegs_T_67[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_5_endAddr = _channelRegs_T_67[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_pitch = _channelRegs_T_80[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_flags_keyOn = _channelRegs_T_80[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_flags_loop = _channelRegs_T_80[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_level = _channelRegs_T_80[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_pan = _channelRegs_T_80[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_startAddr = _channelRegs_T_80[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_loopStartAddr = _channelRegs_T_80[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_loopEndAddr = _channelRegs_T_80[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_6_endAddr = _channelRegs_T_80[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_pitch = _channelRegs_T_93[119:112]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_flags_keyOn = _channelRegs_T_93[111]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_flags_loop = _channelRegs_T_93[108]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_level = _channelRegs_T_93[107:100]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_pan = _channelRegs_T_93[99:96]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_startAddr = _channelRegs_T_93[95:72]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_loopStartAddr = _channelRegs_T_93[71:48]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_loopEndAddr = _channelRegs_T_93[47:24]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_regs_7_endAddr = _channelRegs_T_93[23:0]; // @[ChannelReg.scala 101:15]
  assign channelCtrl_io_enable = _utilReg_T_3[2]; // @[UtilReg.scala 65:15]
  assign channelCtrl_io_rom_dout = io_rom_dout; // @[YMZ280B.scala 121:22]
  assign channelCtrl_io_rom_waitReq = io_rom_waitReq; // @[YMZ280B.scala 121:22]
  assign channelCtrl_io_rom_valid = io_rom_valid; // @[YMZ280B.scala 121:22]
  always @(posedge clock) begin
    if (reset) begin // @[YMZ280B.scala 105:24]
      addrReg <= 8'h0; // @[YMZ280B.scala 105:24]
    end else if (writeAddr) begin // @[YMZ280B.scala 129:19]
      addrReg <= io_cpu_din; // @[YMZ280B.scala 129:29]
    end
    if (reset) begin // @[YMZ280B.scala 106:24]
      dataReg <= 8'h0; // @[YMZ280B.scala 106:24]
    end else if (readStatus) begin // @[YMZ280B.scala 138:20]
      dataReg <= statusReg; // @[YMZ280B.scala 139:13]
    end
    if (reset) begin // @[YMZ280B.scala 107:26]
      statusReg <= 8'h0; // @[YMZ280B.scala 107:26]
    end else if (readStatus) begin // @[YMZ280B.scala 138:20]
      statusReg <= 8'h0; // @[YMZ280B.scala 140:15]
    end else if (channelCtrl_io_done) begin // @[YMZ280B.scala 135:29]
      statusReg <= _statusReg_T_1; // @[YMZ280B.scala 135:41]
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_0 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h0 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_0 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_1 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_1 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_2 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_2 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_3 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_3 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_4 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_4 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_5 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_5 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_6 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_6 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_7 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_7 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_8 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h8 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_8 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_9 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h9 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_9 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_10 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'ha == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_10 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_11 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hb == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_11 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_12 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hc == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_12 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_13 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hd == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_13 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_14 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'he == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_14 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_15 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hf == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_15 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_16 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h10 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_16 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_17 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h11 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_17 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_18 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h12 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_18 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_19 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h13 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_19 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_20 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h14 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_20 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_21 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h15 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_21 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_22 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h16 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_22 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_23 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h17 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_23 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_24 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h18 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_24 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_25 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h19 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_25 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_26 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_26 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_27 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_27 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_28 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_28 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_29 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_29 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_30 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_30 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_31 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h1f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_31 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_32 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h20 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_32 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_33 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h21 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_33 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_34 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h22 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_34 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_35 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h23 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_35 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_36 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h24 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_36 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_37 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h25 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_37 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_38 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h26 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_38 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_39 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h27 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_39 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_40 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h28 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_40 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_41 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h29 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_41 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_42 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_42 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_43 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_43 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_44 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_44 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_45 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_45 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_46 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_46 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_47 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h2f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_47 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_48 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h30 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_48 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_49 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h31 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_49 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_50 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h32 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_50 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_51 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h33 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_51 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_52 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h34 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_52 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_53 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h35 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_53 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_54 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h36 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_54 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_55 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h37 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_55 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_56 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h38 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_56 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_57 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h39 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_57 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_58 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_58 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_59 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_59 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_60 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_60 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_61 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_61 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_62 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_62 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_63 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h3f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_63 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_64 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h40 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_64 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_65 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h41 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_65 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_66 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h42 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_66 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_67 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h43 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_67 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_68 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h44 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_68 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_69 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h45 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_69 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_70 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h46 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_70 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_71 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h47 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_71 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_72 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h48 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_72 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_73 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h49 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_73 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_74 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_74 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_75 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_75 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_76 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_76 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_77 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_77 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_78 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_78 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_79 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h4f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_79 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_80 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h50 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_80 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_81 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h51 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_81 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_82 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h52 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_82 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_83 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h53 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_83 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_84 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h54 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_84 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_85 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h55 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_85 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_86 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h56 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_86 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_87 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h57 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_87 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_88 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h58 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_88 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_89 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h59 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_89 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_90 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_90 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_91 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_91 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_92 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_92 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_93 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_93 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_94 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_94 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_95 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h5f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_95 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_96 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h60 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_96 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_97 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h61 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_97 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_98 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h62 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_98 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_99 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h63 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_99 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_100 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h64 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_100 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_101 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h65 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_101 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_102 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h66 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_102 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_103 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h67 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_103 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_104 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h68 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_104 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_105 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h69 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_105 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_106 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_106 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_107 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_107 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_108 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_108 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_109 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_109 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_110 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_110 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_111 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h6f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_111 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_112 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h70 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_112 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_113 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h71 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_113 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_114 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h72 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_114 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_115 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h73 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_115 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_116 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h74 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_116 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_117 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h75 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_117 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_118 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h76 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_118 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_119 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h77 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_119 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_120 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h78 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_120 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_121 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h79 == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_121 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_122 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7a == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_122 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_123 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7b == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_123 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_124 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7c == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_124 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_125 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7d == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_125 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_126 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7e == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_126 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_127 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'h7f == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_127 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_254 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hfe == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_254 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    if (reset) begin // @[YMZ280B.scala 108:29]
      registerFile_255 <= 8'h0; // @[YMZ280B.scala 108:29]
    end else if (writeData) begin // @[YMZ280B.scala 132:19]
      if (8'hff == addrReg) begin // @[YMZ280B.scala 132:43]
        registerFile_255 <= io_cpu_din; // @[YMZ280B.scala 132:43]
      end
    end
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,"YMZ280B(addrReg: %d, status: %d)\n",addrReg,statusReg); // @[YMZ280B.scala 150:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  addrReg = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  dataReg = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  statusReg = _RAND_2[7:0];
  _RAND_3 = {1{`RANDOM}};
  registerFile_0 = _RAND_3[7:0];
  _RAND_4 = {1{`RANDOM}};
  registerFile_1 = _RAND_4[7:0];
  _RAND_5 = {1{`RANDOM}};
  registerFile_2 = _RAND_5[7:0];
  _RAND_6 = {1{`RANDOM}};
  registerFile_3 = _RAND_6[7:0];
  _RAND_7 = {1{`RANDOM}};
  registerFile_4 = _RAND_7[7:0];
  _RAND_8 = {1{`RANDOM}};
  registerFile_5 = _RAND_8[7:0];
  _RAND_9 = {1{`RANDOM}};
  registerFile_6 = _RAND_9[7:0];
  _RAND_10 = {1{`RANDOM}};
  registerFile_7 = _RAND_10[7:0];
  _RAND_11 = {1{`RANDOM}};
  registerFile_8 = _RAND_11[7:0];
  _RAND_12 = {1{`RANDOM}};
  registerFile_9 = _RAND_12[7:0];
  _RAND_13 = {1{`RANDOM}};
  registerFile_10 = _RAND_13[7:0];
  _RAND_14 = {1{`RANDOM}};
  registerFile_11 = _RAND_14[7:0];
  _RAND_15 = {1{`RANDOM}};
  registerFile_12 = _RAND_15[7:0];
  _RAND_16 = {1{`RANDOM}};
  registerFile_13 = _RAND_16[7:0];
  _RAND_17 = {1{`RANDOM}};
  registerFile_14 = _RAND_17[7:0];
  _RAND_18 = {1{`RANDOM}};
  registerFile_15 = _RAND_18[7:0];
  _RAND_19 = {1{`RANDOM}};
  registerFile_16 = _RAND_19[7:0];
  _RAND_20 = {1{`RANDOM}};
  registerFile_17 = _RAND_20[7:0];
  _RAND_21 = {1{`RANDOM}};
  registerFile_18 = _RAND_21[7:0];
  _RAND_22 = {1{`RANDOM}};
  registerFile_19 = _RAND_22[7:0];
  _RAND_23 = {1{`RANDOM}};
  registerFile_20 = _RAND_23[7:0];
  _RAND_24 = {1{`RANDOM}};
  registerFile_21 = _RAND_24[7:0];
  _RAND_25 = {1{`RANDOM}};
  registerFile_22 = _RAND_25[7:0];
  _RAND_26 = {1{`RANDOM}};
  registerFile_23 = _RAND_26[7:0];
  _RAND_27 = {1{`RANDOM}};
  registerFile_24 = _RAND_27[7:0];
  _RAND_28 = {1{`RANDOM}};
  registerFile_25 = _RAND_28[7:0];
  _RAND_29 = {1{`RANDOM}};
  registerFile_26 = _RAND_29[7:0];
  _RAND_30 = {1{`RANDOM}};
  registerFile_27 = _RAND_30[7:0];
  _RAND_31 = {1{`RANDOM}};
  registerFile_28 = _RAND_31[7:0];
  _RAND_32 = {1{`RANDOM}};
  registerFile_29 = _RAND_32[7:0];
  _RAND_33 = {1{`RANDOM}};
  registerFile_30 = _RAND_33[7:0];
  _RAND_34 = {1{`RANDOM}};
  registerFile_31 = _RAND_34[7:0];
  _RAND_35 = {1{`RANDOM}};
  registerFile_32 = _RAND_35[7:0];
  _RAND_36 = {1{`RANDOM}};
  registerFile_33 = _RAND_36[7:0];
  _RAND_37 = {1{`RANDOM}};
  registerFile_34 = _RAND_37[7:0];
  _RAND_38 = {1{`RANDOM}};
  registerFile_35 = _RAND_38[7:0];
  _RAND_39 = {1{`RANDOM}};
  registerFile_36 = _RAND_39[7:0];
  _RAND_40 = {1{`RANDOM}};
  registerFile_37 = _RAND_40[7:0];
  _RAND_41 = {1{`RANDOM}};
  registerFile_38 = _RAND_41[7:0];
  _RAND_42 = {1{`RANDOM}};
  registerFile_39 = _RAND_42[7:0];
  _RAND_43 = {1{`RANDOM}};
  registerFile_40 = _RAND_43[7:0];
  _RAND_44 = {1{`RANDOM}};
  registerFile_41 = _RAND_44[7:0];
  _RAND_45 = {1{`RANDOM}};
  registerFile_42 = _RAND_45[7:0];
  _RAND_46 = {1{`RANDOM}};
  registerFile_43 = _RAND_46[7:0];
  _RAND_47 = {1{`RANDOM}};
  registerFile_44 = _RAND_47[7:0];
  _RAND_48 = {1{`RANDOM}};
  registerFile_45 = _RAND_48[7:0];
  _RAND_49 = {1{`RANDOM}};
  registerFile_46 = _RAND_49[7:0];
  _RAND_50 = {1{`RANDOM}};
  registerFile_47 = _RAND_50[7:0];
  _RAND_51 = {1{`RANDOM}};
  registerFile_48 = _RAND_51[7:0];
  _RAND_52 = {1{`RANDOM}};
  registerFile_49 = _RAND_52[7:0];
  _RAND_53 = {1{`RANDOM}};
  registerFile_50 = _RAND_53[7:0];
  _RAND_54 = {1{`RANDOM}};
  registerFile_51 = _RAND_54[7:0];
  _RAND_55 = {1{`RANDOM}};
  registerFile_52 = _RAND_55[7:0];
  _RAND_56 = {1{`RANDOM}};
  registerFile_53 = _RAND_56[7:0];
  _RAND_57 = {1{`RANDOM}};
  registerFile_54 = _RAND_57[7:0];
  _RAND_58 = {1{`RANDOM}};
  registerFile_55 = _RAND_58[7:0];
  _RAND_59 = {1{`RANDOM}};
  registerFile_56 = _RAND_59[7:0];
  _RAND_60 = {1{`RANDOM}};
  registerFile_57 = _RAND_60[7:0];
  _RAND_61 = {1{`RANDOM}};
  registerFile_58 = _RAND_61[7:0];
  _RAND_62 = {1{`RANDOM}};
  registerFile_59 = _RAND_62[7:0];
  _RAND_63 = {1{`RANDOM}};
  registerFile_60 = _RAND_63[7:0];
  _RAND_64 = {1{`RANDOM}};
  registerFile_61 = _RAND_64[7:0];
  _RAND_65 = {1{`RANDOM}};
  registerFile_62 = _RAND_65[7:0];
  _RAND_66 = {1{`RANDOM}};
  registerFile_63 = _RAND_66[7:0];
  _RAND_67 = {1{`RANDOM}};
  registerFile_64 = _RAND_67[7:0];
  _RAND_68 = {1{`RANDOM}};
  registerFile_65 = _RAND_68[7:0];
  _RAND_69 = {1{`RANDOM}};
  registerFile_66 = _RAND_69[7:0];
  _RAND_70 = {1{`RANDOM}};
  registerFile_67 = _RAND_70[7:0];
  _RAND_71 = {1{`RANDOM}};
  registerFile_68 = _RAND_71[7:0];
  _RAND_72 = {1{`RANDOM}};
  registerFile_69 = _RAND_72[7:0];
  _RAND_73 = {1{`RANDOM}};
  registerFile_70 = _RAND_73[7:0];
  _RAND_74 = {1{`RANDOM}};
  registerFile_71 = _RAND_74[7:0];
  _RAND_75 = {1{`RANDOM}};
  registerFile_72 = _RAND_75[7:0];
  _RAND_76 = {1{`RANDOM}};
  registerFile_73 = _RAND_76[7:0];
  _RAND_77 = {1{`RANDOM}};
  registerFile_74 = _RAND_77[7:0];
  _RAND_78 = {1{`RANDOM}};
  registerFile_75 = _RAND_78[7:0];
  _RAND_79 = {1{`RANDOM}};
  registerFile_76 = _RAND_79[7:0];
  _RAND_80 = {1{`RANDOM}};
  registerFile_77 = _RAND_80[7:0];
  _RAND_81 = {1{`RANDOM}};
  registerFile_78 = _RAND_81[7:0];
  _RAND_82 = {1{`RANDOM}};
  registerFile_79 = _RAND_82[7:0];
  _RAND_83 = {1{`RANDOM}};
  registerFile_80 = _RAND_83[7:0];
  _RAND_84 = {1{`RANDOM}};
  registerFile_81 = _RAND_84[7:0];
  _RAND_85 = {1{`RANDOM}};
  registerFile_82 = _RAND_85[7:0];
  _RAND_86 = {1{`RANDOM}};
  registerFile_83 = _RAND_86[7:0];
  _RAND_87 = {1{`RANDOM}};
  registerFile_84 = _RAND_87[7:0];
  _RAND_88 = {1{`RANDOM}};
  registerFile_85 = _RAND_88[7:0];
  _RAND_89 = {1{`RANDOM}};
  registerFile_86 = _RAND_89[7:0];
  _RAND_90 = {1{`RANDOM}};
  registerFile_87 = _RAND_90[7:0];
  _RAND_91 = {1{`RANDOM}};
  registerFile_88 = _RAND_91[7:0];
  _RAND_92 = {1{`RANDOM}};
  registerFile_89 = _RAND_92[7:0];
  _RAND_93 = {1{`RANDOM}};
  registerFile_90 = _RAND_93[7:0];
  _RAND_94 = {1{`RANDOM}};
  registerFile_91 = _RAND_94[7:0];
  _RAND_95 = {1{`RANDOM}};
  registerFile_92 = _RAND_95[7:0];
  _RAND_96 = {1{`RANDOM}};
  registerFile_93 = _RAND_96[7:0];
  _RAND_97 = {1{`RANDOM}};
  registerFile_94 = _RAND_97[7:0];
  _RAND_98 = {1{`RANDOM}};
  registerFile_95 = _RAND_98[7:0];
  _RAND_99 = {1{`RANDOM}};
  registerFile_96 = _RAND_99[7:0];
  _RAND_100 = {1{`RANDOM}};
  registerFile_97 = _RAND_100[7:0];
  _RAND_101 = {1{`RANDOM}};
  registerFile_98 = _RAND_101[7:0];
  _RAND_102 = {1{`RANDOM}};
  registerFile_99 = _RAND_102[7:0];
  _RAND_103 = {1{`RANDOM}};
  registerFile_100 = _RAND_103[7:0];
  _RAND_104 = {1{`RANDOM}};
  registerFile_101 = _RAND_104[7:0];
  _RAND_105 = {1{`RANDOM}};
  registerFile_102 = _RAND_105[7:0];
  _RAND_106 = {1{`RANDOM}};
  registerFile_103 = _RAND_106[7:0];
  _RAND_107 = {1{`RANDOM}};
  registerFile_104 = _RAND_107[7:0];
  _RAND_108 = {1{`RANDOM}};
  registerFile_105 = _RAND_108[7:0];
  _RAND_109 = {1{`RANDOM}};
  registerFile_106 = _RAND_109[7:0];
  _RAND_110 = {1{`RANDOM}};
  registerFile_107 = _RAND_110[7:0];
  _RAND_111 = {1{`RANDOM}};
  registerFile_108 = _RAND_111[7:0];
  _RAND_112 = {1{`RANDOM}};
  registerFile_109 = _RAND_112[7:0];
  _RAND_113 = {1{`RANDOM}};
  registerFile_110 = _RAND_113[7:0];
  _RAND_114 = {1{`RANDOM}};
  registerFile_111 = _RAND_114[7:0];
  _RAND_115 = {1{`RANDOM}};
  registerFile_112 = _RAND_115[7:0];
  _RAND_116 = {1{`RANDOM}};
  registerFile_113 = _RAND_116[7:0];
  _RAND_117 = {1{`RANDOM}};
  registerFile_114 = _RAND_117[7:0];
  _RAND_118 = {1{`RANDOM}};
  registerFile_115 = _RAND_118[7:0];
  _RAND_119 = {1{`RANDOM}};
  registerFile_116 = _RAND_119[7:0];
  _RAND_120 = {1{`RANDOM}};
  registerFile_117 = _RAND_120[7:0];
  _RAND_121 = {1{`RANDOM}};
  registerFile_118 = _RAND_121[7:0];
  _RAND_122 = {1{`RANDOM}};
  registerFile_119 = _RAND_122[7:0];
  _RAND_123 = {1{`RANDOM}};
  registerFile_120 = _RAND_123[7:0];
  _RAND_124 = {1{`RANDOM}};
  registerFile_121 = _RAND_124[7:0];
  _RAND_125 = {1{`RANDOM}};
  registerFile_122 = _RAND_125[7:0];
  _RAND_126 = {1{`RANDOM}};
  registerFile_123 = _RAND_126[7:0];
  _RAND_127 = {1{`RANDOM}};
  registerFile_124 = _RAND_127[7:0];
  _RAND_128 = {1{`RANDOM}};
  registerFile_125 = _RAND_128[7:0];
  _RAND_129 = {1{`RANDOM}};
  registerFile_126 = _RAND_129[7:0];
  _RAND_130 = {1{`RANDOM}};
  registerFile_127 = _RAND_130[7:0];
  _RAND_131 = {1{`RANDOM}};
  registerFile_254 = _RAND_131[7:0];
  _RAND_132 = {1{`RANDOM}};
  registerFile_255 = _RAND_132[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
