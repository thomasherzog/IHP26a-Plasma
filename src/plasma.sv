/*
 * Copyright (c) 2026 Thomas Herzog
 * SPDX-License-Identifier: Apache-2.0
 */

module plasma (
    input logic [9:0] hpos,
    input logic [9:0] vpos,
    input logic [11:0] counter,
    output logic [1:0] plasma_r,
    output logic [1:0] plasma_g,
    output logic [1:0] plasma_b
);

  // Plasma logic
  logic [4:0] phase1;
  logic [4:0] phase2;
  logic [4:0] phase3;
  logic [4:0] phase4;

  assign phase1 = hpos[8:4] + counter[8:4];
  assign phase2 = vpos[8:4] - counter[9:5];
  assign phase3 = (hpos[8:4] + vpos[8:4]) + counter[7:3];
  assign phase4 = (hpos[8:4] - vpos[8:4]) - counter[8:4];

  logic [3:0] w1;
  logic [3:0] w2;
  logic [3:0] w3;
  logic [3:0] w4;

  assign w1 = SIN_LUT[phase1];
  assign w2 = SIN_LUT[phase2];
  assign w3 = SIN_LUT[phase3];
  assign w4 = SIN_LUT[phase4];

  logic [4:0] plasma_sum;
  assign plasma_sum = (w1 + w2) + (w3 + w4);

  // Color mapping
  logic [3:0] color_r_phase;
  logic [3:0] color_g_phase;
  logic [3:0] color_b_phase;

  assign color_r_phase = SIN_LUT[plasma_sum[4:0] + counter[9:5]];
  assign color_g_phase = SIN_LUT[plasma_sum[4:0] + counter[10:6] + 5'd10];
  assign color_b_phase = SIN_LUT[plasma_sum[4:0] - counter[9:5] + 5'd20];

  assign plasma_r = color_r_phase[3:2];
  assign plasma_g = color_g_phase[3:2];
  assign plasma_b = color_b_phase[3:2];

  // Quantized Sine LUT
  // verilator lint_off ASCRANGE
  localparam logic [0:31][3:0] SIN_LUT = {
    4'd8, 4'd9, 4'd10, 4'd12, 4'd13, 4'd14, 4'd14, 4'd15,
    4'd15, 4'd15, 4'd14, 4'd14, 4'd13, 4'd12, 4'd10, 4'd9,
    4'd8, 4'd6, 4'd5, 4'd3, 4'd2, 4'd1, 4'd1, 4'd0,
    4'd0, 4'd0, 4'd1, 4'd1, 4'd2, 4'd3, 4'd5, 4'd6
  };
  // verilator lint_on ASCRANGE

  // Recycle bin for unused variables
  wire _unused_ok = &{
    1'b0,
    color_r_phase[1:0],
    color_g_phase[1:0],
    color_b_phase[1:0],
    hpos[3:0],
    vpos[3:0],
    hpos[9],
    vpos[9]
  };

endmodule