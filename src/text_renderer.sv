/*
 * Copyright (c) 2026 Thomas Herzog
 * SPDX-License-Identifier: Apache-2.0
 */

module text_renderer (
    input logic [9:0] hpos,
    input logic [9:0] vpos,
    output logic is_inner,
    output logic is_border
);

  // 8x8 font LUT
  function automatic logic [7:0] get_font_row(input logic [7:0] char, input logic [2:0] row);
    case (char)
      "A": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h7E; 4:get_font_row=8'h66; 5:get_font_row=8'h66; 6:get_font_row=8'h66; 7:get_font_row=8'h00; endcase
      "C": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h66; 2:get_font_row=8'h60; 3:get_font_row=8'h60; 4:get_font_row=8'h60; 5:get_font_row=8'h66; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "E": case(row) 0:get_font_row=8'h7E; 1:get_font_row=8'h60; 2:get_font_row=8'h60; 3:get_font_row=8'h78; 4:get_font_row=8'h60; 5:get_font_row=8'h60; 6:get_font_row=8'h7E; 7:get_font_row=8'h00; endcase
      "F": case(row) 0:get_font_row=8'h7E; 1:get_font_row=8'h60; 2:get_font_row=8'h60; 3:get_font_row=8'h78; 4:get_font_row=8'h60; 5:get_font_row=8'h60; 6:get_font_row=8'h60; 7:get_font_row=8'h00; endcase
      "G": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h66; 2:get_font_row=8'h60; 3:get_font_row=8'h6E; 4:get_font_row=8'h66; 5:get_font_row=8'h66; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "H": case(row) 0:get_font_row=8'h66; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h7E; 4:get_font_row=8'h66; 5:get_font_row=8'h66; 6:get_font_row=8'h66; 7:get_font_row=8'h00; endcase
      "I": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h18; 2:get_font_row=8'h18; 3:get_font_row=8'h18; 4:get_font_row=8'h18; 5:get_font_row=8'h18; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "K": case(row) 0:get_font_row=8'h66; 1:get_font_row=8'h6C; 2:get_font_row=8'h78; 3:get_font_row=8'h70; 4:get_font_row=8'h78; 5:get_font_row=8'h6C; 6:get_font_row=8'h66; 7:get_font_row=8'h00; endcase
      "M": case(row) 0:get_font_row=8'hC3; 1:get_font_row=8'hE7; 2:get_font_row=8'hFF; 3:get_font_row=8'hDB; 4:get_font_row=8'hC3; 5:get_font_row=8'hC3; 6:get_font_row=8'hC3; 7:get_font_row=8'h00; endcase
      "N": case(row) 0:get_font_row=8'h66; 1:get_font_row=8'h76; 2:get_font_row=8'h7E; 3:get_font_row=8'h7E; 4:get_font_row=8'h6E; 5:get_font_row=8'h66; 6:get_font_row=8'h66; 7:get_font_row=8'h00; endcase
      "O": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h66; 4:get_font_row=8'h66; 5:get_font_row=8'h66; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "P": case(row) 0:get_font_row=8'h7C; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h7C; 4:get_font_row=8'h60; 5:get_font_row=8'h60; 6:get_font_row=8'h60; 7:get_font_row=8'h00; endcase
      "R": case(row) 0:get_font_row=8'h7C; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h7C; 4:get_font_row=8'h6C; 5:get_font_row=8'h66; 6:get_font_row=8'h66; 7:get_font_row=8'h00; endcase
      "S": case(row) 0:get_font_row=8'h3C; 1:get_font_row=8'h66; 2:get_font_row=8'h60; 3:get_font_row=8'h3C; 4:get_font_row=8'h06; 5:get_font_row=8'h66; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "T": case(row) 0:get_font_row=8'h7E; 1:get_font_row=8'h18; 2:get_font_row=8'h18; 3:get_font_row=8'h18; 4:get_font_row=8'h18; 5:get_font_row=8'h18; 6:get_font_row=8'h18; 7:get_font_row=8'h00; endcase
      "U": case(row) 0:get_font_row=8'h66; 1:get_font_row=8'h66; 2:get_font_row=8'h66; 3:get_font_row=8'h66; 4:get_font_row=8'h66; 5:get_font_row=8'h66; 6:get_font_row=8'h3C; 7:get_font_row=8'h00; endcase
      "W": case(row) 0:get_font_row=8'hC3; 1:get_font_row=8'hC3; 2:get_font_row=8'hC3; 3:get_font_row=8'hDB; 4:get_font_row=8'hFF; 5:get_font_row=8'hE7; 6:get_font_row=8'hC3; 7:get_font_row=8'h00; endcase
      "Z": case(row) 0:get_font_row=8'h7E; 1:get_font_row=8'h06; 2:get_font_row=8'h0C; 3:get_font_row=8'h18; 4:get_font_row=8'h30; 5:get_font_row=8'h60; 6:get_font_row=8'h7E; 7:get_font_row=8'h00; endcase
      "!": case(row) 0:get_font_row=8'h18; 1:get_font_row=8'h18; 2:get_font_row=8'h18; 3:get_font_row=8'h18; 4:get_font_row=8'h18; 5:get_font_row=8'h00; 6:get_font_row=8'h18; 7:get_font_row=8'h00; endcase
      default: get_font_row = 8'h00; // Space
    endcase
  endfunction

  // Get the pixel value for a given screen coordinate based on the text layout
  function automatic logic get_text_pixel(input logic [9:0] x, input logic [9:0] y);
    logic [7:0] char_code;
    logic [9:0] font_x;
    logic [9:0] font_y;
    logic [7:0] current_font_row;

    char_code = 8'h20;
    font_x = 0;
    font_y = 0;
    get_text_pixel = 1'b0;

    // 1. Center: "THANKS FOR SPONSORING!" (Scale x2 -> 16x16 px)
    // 22 chars * 16px = 352px wide. To center on 640px, start at x=144, end at x=496.
    if (y >= 10'd190 && y < 10'd206 && x >= 10'd144 && x < 10'd496) begin
      font_x = (x - 10'd144) >> 1;
      font_y = (y - 10'd190) >> 1;
      case (5'((x - 10'd144) >> 4))
        5'd0:  char_code = "T";
        5'd1:  char_code = "H";
        5'd2:  char_code = "A";
        5'd3:  char_code = "N";
        5'd4:  char_code = "K";
        5'd5:  char_code = "S";
        5'd6:  char_code = " ";
        5'd7:  char_code = "F";
        5'd8:  char_code = "O";
        5'd9:  char_code = "R";
        5'd10: char_code = " ";
        5'd11: char_code = "S";
        5'd12: char_code = "P";
        5'd13: char_code = "O";
        5'd14: char_code = "N";
        5'd15: char_code = "S";
        5'd16: char_code = "O";
        5'd17: char_code = "R";
        5'd18: char_code = "I";
        5'd19: char_code = "N";
        5'd20: char_code = "G";
        5'd21: char_code = "!";
        default: char_code = " ";
      endcase
      current_font_row = get_font_row(char_code, font_y[2:0]);
      get_text_pixel = current_font_row[7 - font_x];
    end

    // 2. Below Center: "SWISSCHIPS" (Scale x4 -> 32x32 px)
    else if (y >= 10'd240 && y < 10'd272 && x >= 10'd160 && x < 10'd480) begin
      font_x = (x - 10'd160) >> 2;
      font_y = (y - 10'd240) >> 2;
      case (4'((x - 10'd160) >> 5))
        4'd0: char_code = "S";
        4'd1: char_code = "W";
        4'd2: char_code = "I";
        4'd3: char_code = "S";
        4'd4: char_code = "S";
        4'd5: char_code = "C";
        4'd6: char_code = "H";
        4'd7: char_code = "I";
        4'd8: char_code = "P";
        4'd9: char_code = "S";
        default: char_code = " ";
      endcase
      current_font_row = get_font_row(char_code, font_y[2:0]);
      get_text_pixel = current_font_row[7 - font_x];
    end

    // 3. Bottom Left: "ETH ZURICH" (Scale x2 -> 16x16 px)
    else if (y >= 10'd440 && y < 10'd456 && x >= 10'd32 && x < 10'd192) begin
      font_x = (x - 10'd32) >> 1; 
      font_y = (y - 10'd440) >> 1;
      case (4'((x - 10'd32) >> 4))
        4'd0: char_code = "E";
        4'd1: char_code = "T";
        4'd2: char_code = "H";
        4'd3: char_code = " ";
        4'd4: char_code = "Z";
        4'd5: char_code = "U";
        4'd6: char_code = "R";
        4'd7: char_code = "I";
        4'd8: char_code = "C";
        4'd9: char_code = "H";
        default: char_code = " ";
      endcase
      current_font_row = get_font_row(char_code, font_y[2:0]);
      get_text_pixel = current_font_row[7 - font_x];
    end
    
    // 4. Bottom Right: "THOMAS HERZOG" (Scale x2 -> 16x16 px)
    else if (y >= 10'd440 && y < 10'd456 && x >= 10'd400 && x < 10'd608) begin
      font_x = (x - 10'd400) >> 1; 
      font_y = (y - 10'd440) >> 1;
      case (4'((x - 10'd400) >> 4))
        4'd0:  char_code = "T";
        4'd1:  char_code = "H";
        4'd2:  char_code = "O";
        4'd3:  char_code = "M";
        4'd4:  char_code = "A";
        4'd5:  char_code = "S";
        4'd6:  char_code = " ";
        4'd7:  char_code = "H";
        4'd8:  char_code = "E";
        4'd9:  char_code = "R";
        4'd10: char_code = "Z";
        4'd11: char_code = "O";
        4'd12: char_code = "G";
        default: char_code = " ";
      endcase
      current_font_row = get_font_row(char_code, font_y[2:0]);
      get_text_pixel = current_font_row[7 - font_x];
    end
  endfunction

  // Calculate pixel and its neighbors for border detection
  logic neighbor_pixels [7:0];

  assign is_inner = get_text_pixel(hpos, vpos);
  assign neighbor_pixels[0] = get_text_pixel(hpos, vpos - 10'd1);
  assign neighbor_pixels[1] = get_text_pixel(hpos, vpos + 10'd1);
  assign neighbor_pixels[2] = get_text_pixel(hpos - 10'd1, vpos);
  assign neighbor_pixels[3] = get_text_pixel(hpos + 10'd1, vpos);
  assign neighbor_pixels[4] = get_text_pixel(hpos - 10'd1, vpos - 10'd1);
  assign neighbor_pixels[5] = get_text_pixel(hpos + 10'd1, vpos - 10'd1);
  assign neighbor_pixels[6] = get_text_pixel(hpos - 10'd1, vpos + 10'd1);
  assign neighbor_pixels[7] = get_text_pixel(hpos + 10'd1, vpos + 10'd1);

  // A pixel is a border if the center is empty, but any neighbor has text
  assign is_border = (
    neighbor_pixels[0] 
    | neighbor_pixels[1] 
    | neighbor_pixels[2] 
    | neighbor_pixels[3] 
    | neighbor_pixels[4] 
    | neighbor_pixels[5] 
    | neighbor_pixels[6] 
    | neighbor_pixels[7]
  ) & ~is_inner;

endmodule