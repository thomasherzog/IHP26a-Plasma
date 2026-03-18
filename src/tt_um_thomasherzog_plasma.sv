/*
 * Copyright (c) 2026 Thomas Herzog
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_thomasherzog_plasma (
    input  logic [7:0] ui_in,    // Dedicated inputs
    output logic [7:0] uo_out,   // Dedicated outputs
    input  logic [7:0] uio_in,   // IOs: Input path
    output logic [7:0] uio_out,  // IOs: Output path
    output logic [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  logic       ena,      // always 1 when the design is powered, so you can ignore it
    input  logic       clk,      // clock
    input  logic       rst_n     // reset_n - low to reset
);

  // VGA signals
  logic hsync;
  logic vsync;
  logic [1:0] R;
  logic [1:0] G;
  logic [1:0] B;
  logic video_active;
  logic [9:0] pix_x;
  logic [9:0] pix_y;

  // Control signals
  logic show_about;
  assign show_about = ui_in[7]; // Use the dedicated input to toggle the "ABOUT" screen

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  // logic _unused = &{ena, clk, rst_n, 1'b0};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // Plasma background
  logic [1:0] plasma_r;
  logic [1:0] plasma_g;
  logic [1:0] plasma_b;

  plasma plasma_gen(
    .hpos(pix_x),
    .vpos(pix_y),
    .counter(counter_q),
    .plasma_r(plasma_r),
    .plasma_g(plasma_g),
    .plasma_b(plasma_b)
  );

  // Text renderer
  logic is_inner;
  logic is_border;

  text_renderer text_gen(
    .hpos(pix_x),
    .vpos(pix_y),
    .is_inner(is_inner),
    .is_border(is_border)
  );

  // Counter
  logic [11:0] counter_d, counter_q;
  assign counter_d = counter_q;

  always_ff @(posedge vsync, negedge rst_n) begin
    if (rst_n == 1'b0) begin
      counter_q <= 0;
    end else begin
      counter_q <= counter_d + 1;
    end
  end

  // Output
  always_comb begin
    if(!video_active) begin
      {R, G, B} = 6'b000000;
    end else if(show_about && is_inner) begin
      {R, G, B} = 6'b111111;
    end else if(show_about && is_border) begin
      {R, G, B} = 6'b000000; 
    end else begin
      {R, G, B} = {plasma_r, plasma_g, plasma_b};
    end
  end

endmodule
