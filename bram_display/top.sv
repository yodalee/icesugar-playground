module top (
  input clk,
  input rst,
  output logic [3:0] hdmi_dp, hdmi_dn,
  output logic [7:0] debug
);

  localparam WIDTH = 640;
  localparam HEIGHT= 480;

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

  diffio diffio_red   (.in(o_red),     .op(hdmi_dp[2]), .on(hdmi_dn[2]));
  diffio diffio_green (.in(o_green),   .op(hdmi_dp[1]), .on(hdmi_dn[1]));
  diffio diffio_blue  (.in(o_blue),    .op(hdmi_dp[0]), .on(hdmi_dn[0]));
  diffio diffio_clock (.in(clk_25MHz), .op(hdmi_dp[3]), .on(hdmi_dn[3]));

  int counterX, counterY;
  logic [7:0] read_byte, write_byte;
  bram #(
    .WIDTH(8),
    .DEPTH(17),
    .SIZE(77824)
  ) bram_i (
    .clk(clk),
    .re(1'b1),
    .we(1'b0),
    .addr_rd(((counterY >> 1) * 320) + (counterX >> 1)),
    .addr_wr(counterX),
    .data_rd(read_byte),
    .data_wr(write_byte)
  );

  always_ff @(posedge clk or negedge rst) begin
    if (!rst) begin
      counterX <= 0;
      counterY <= 0;
    end
    else begin
      if (o_newframe) begin
        counterX <= 0;
        counterY <= 0;
      end
      else if (o_enable) begin
        counterX <= (counterX == WIDTH-1) ? 0 : counterX+1;
        counterY <= (counterX == WIDTH-1) ? counterY+1 : counterY;
      end
    end
  end

  assign debug = read_byte;
  assign pixel = {
    read_byte[7:5], 5'b0,
    read_byte[4:2], 5'b0,
    read_byte[1:0], 6'b0
  };

endmodule

