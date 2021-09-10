module top (
  input clk,
  input rst,
  output logic [3:0] hdmi_dp, hdmi_dn,
  output logic [7:0] debug
);

  assign debug = 8'h5a;

  logic clk_25MHz, clk_250MHz;
  clock clock_instance(
      .clkin_25MHz(clk),
      .clk_25MHz(clk_25MHz),
      .clk_250MHz(clk_250MHz)
  );

  logic [7:0] pixelR, pixelG, pixelB;
  logic [23:0] pixel;
  assign pixelR = pixel[23:16];
  assign pixelG = pixel[15:8];
  assign pixelB = pixel[7:0];

  logic o_red, o_green, o_blue;
  logic o_rd, o_newline, o_newframe;

  llhdmi llhdmi_instance(
    .i_tmdsclk(clk_250MHz), .i_pixclk(clk_25MHz),
    .i_reset(!rst), .i_red(pixelR), .i_grn(pixelG), .i_blu(pixelB),
    .o_rd(o_rd), .o_newline(o_newline), .o_newframe(o_newframe),
    .o_red(o_red), .o_grn(o_green), .o_blu(o_blue));

  vgatestsrc #(.BITS_PER_COLOR(8))
    vgatestsrc_instance(
      .i_pixclk(clk_25MHz), .i_reset(!rst),
      .i_width(640), .i_height(480),
      .i_rd(o_rd), .i_newline(o_newline), .i_newframe(o_newframe),
      .o_pixel(pixel));

  diffio diffio_red   (.in(o_red),     .op(hdmi_dp[2]), .on(hdmi_dn[2]));
  diffio diffio_green (.in(o_green),   .op(hdmi_dp[1]), .on(hdmi_dn[1]));
  diffio diffio_blue  (.in(o_blue),    .op(hdmi_dp[0]), .on(hdmi_dn[0]));
  diffio diffio_clock (.in(clk_25MHz), .op(hdmi_dp[3]), .on(hdmi_dn[3]));

endmodule

