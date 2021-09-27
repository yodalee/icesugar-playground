module top (
  input clk,
  input rst,
  output logic [3:0] hdmi_dp, hdmi_dn,
  output logic [7:0] debug
);

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
  logic o_enable, o_newline, o_newframe;

  hdmi hdmi_instance(
    .clk_tmds(clk_250MHz), .clk_pixel(clk_25MHz), .rst(rst),
    .i_red(pixelR), .i_green(pixelG), .i_blue(pixelB),
    .o_enable(o_enable), .o_newline(o_newline), .o_newframe(o_newframe),
    .o_red(o_red), .o_green(o_green), .o_blue(o_blue));

  imagesrc imagesrc_i (
    .clk(clk), .rst(rst),
    .i_newframe(o_newframe), .i_newline(o_newline), .i_enable(o_enable),
    .pixel(pixel)
  );

  diffio diffio_red   (.in(o_red),     .op(hdmi_dp[2]), .on(hdmi_dn[2]));
  diffio diffio_green (.in(o_green),   .op(hdmi_dp[1]), .on(hdmi_dn[1]));
  diffio diffio_blue  (.in(o_blue),    .op(hdmi_dp[0]), .on(hdmi_dn[0]));
  diffio diffio_clock (.in(clk_25MHz), .op(hdmi_dp[3]), .on(hdmi_dn[3]));

endmodule

