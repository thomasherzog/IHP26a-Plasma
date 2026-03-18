/*
 * Copyright (c) 2026 Thomas Herzog
 * SPDX-License-Identifier: Apache-2.0
 */

typedef enum logic [1:0] {
    MODE_DEFAULT = 2'b00,
    MODE_MATRIX = 2'b01,
    MODE_CYBERPUNK = 2'b10,
    MODE_ABYSS = 2'b11
} plasma_mode_t;

module plasma (
    input logic [9:0] hpos,
    input logic [9:0] vpos,
    input logic [11:0] counter,
    input logic [1:0] mode,
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

  assign w1 = sin4(phase1);
  assign w2 = sin4(phase2);
  assign w3 = sin4(phase3);
  assign w4 = sin4(phase4);

  logic [4:0] plasma_sum;
  assign plasma_sum = (w1 + w2) + (w3 + w4);

  // Color mapping
  logic [3:0] color_r_phase;
  logic [3:0] color_g_phase;
  logic [3:0] color_b_phase;

  always_comb begin
    case (mode)
      MODE_DEFAULT: begin
        color_r_phase = sin4(plasma_sum + counter[9:5]);
        color_g_phase = sin4(plasma_sum+ counter[10:6] + 5'd10);
        color_b_phase = sin4(plasma_sum - counter[9:5] + 5'd20);
      end
      MODE_MATRIX: begin
        color_g_phase = sin4(plasma_sum);
        color_r_phase = color_g_phase >> 2;
        color_b_phase = color_g_phase >> 2;
      end
      MODE_CYBERPUNK: begin
        color_r_phase = sin4(plasma_sum + counter[8:4]);
        color_g_phase = sin4(plasma_sum + 5'd16);
        color_b_phase = 4'd12;
      end
      MODE_ABYSS: begin
        color_r_phase = (plasma_sum > 5'd28) ? 4'd12 : 4'd0; 
        color_g_phase = (plasma_sum > 5'd24) ? plasma_sum[4:1] : 4'd2;
        color_b_phase = plasma_sum[4:1];
      end
      default: begin
        color_r_phase = sin4(plasma_sum + counter[9:5]);
        color_g_phase = sin4(plasma_sum + counter[10:6] + 5'd10);
        color_b_phase = sin4(plasma_sum - counter[9:5] + 5'd20);
      end
    endcase
  end

  assign plasma_r = color_r_phase[3:2];
  assign plasma_g = color_g_phase[3:2];
  assign plasma_b = color_b_phase[3:2];

  // Quantized Sine LUT
  function automatic logic [3:0] sin4(input logic [4:0] phase);
    case (phase)
      5'd00: sin4 = 4'd8;  5'd01: sin4 = 4'd9;  5'd02: sin4 = 4'd10; 5'd03: sin4 = 4'd12;
      5'd04: sin4 = 4'd13; 5'd05: sin4 = 4'd14; 5'd06: sin4 = 4'd14; 5'd07: sin4 = 4'd15;
      5'd08: sin4 = 4'd15; 5'd09: sin4 = 4'd15; 5'd10: sin4 = 4'd14; 5'd11: sin4 = 4'd14;
      5'd12: sin4 = 4'd13; 5'd13: sin4 = 4'd12; 5'd14: sin4 = 4'd10; 5'd15: sin4 = 4'd9;
      5'd16: sin4 = 4'd8;  5'd17: sin4 = 4'd6;  5'd18: sin4 = 4'd5;  5'd19: sin4 = 4'd3;
      5'd20: sin4 = 4'd2;  5'd21: sin4 = 4'd1;  5'd22: sin4 = 4'd1;  5'd23: sin4 = 4'd0;
      5'd24: sin4 = 4'd0;  5'd25: sin4 = 4'd0;  5'd26: sin4 = 4'd1;  5'd27: sin4 = 4'd1;
      5'd28: sin4 = 4'd2;  5'd29: sin4 = 4'd3;  5'd30: sin4 = 4'd5;  5'd31: sin4 = 4'd6;
      default: sin4 = 4'd8; 
    endcase
  endfunction

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