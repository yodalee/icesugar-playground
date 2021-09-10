`default_nettype none

module hdmi(
  input clk_tmds,
  input clk_pixel,
  input rst,
  input [7:0] i_red, i_green, i_blue,
  output logic o_enable,
  output logic o_newline,
  output logic o_newframe,
  output logic o_red,
  output logic o_green,
  output logic o_blue);

  parameter WIDTH = 640;
  parameter HEIGHT = 480;
  parameter VWIDTH = 800;
  parameter VHEIGHT = 525;

  logic [9:0] CounterX, CounterY;

  // update counterX and counterY
  always_ff @(posedge clk_pixel or negedge rst) begin
    if (!rst) begin
      CounterX <= 0;
    end
    else begin
      CounterX <= (CounterX == VWIDTH-1) ? 0 : CounterX+1;
    end
  end

  always_ff @(posedge clk_pixel or negedge rst) begin
    if (!rst) begin
      CounterY <= 0;
    end
    else begin
      if (CounterX == VWIDTH-1) begin
        CounterY <= (CounterY == VHEIGHT-1) ? 0 : CounterY+1;
      end
    end
  end

  logic hSync, vSync, DrawArea;

  // Signal end of line, end of frame
  assign o_newline  = (CounterX == WIDTH-1);
  assign o_newframe = (CounterX == WIDTH-1) && (CounterY == HEIGHT-1);
  assign DrawArea   = (CounterX < WIDTH) && (CounterY < HEIGHT);
  assign o_enable   = rst & DrawArea;
  assign hSync = (CounterX >= 656) && (CounterX < 752);
  assign vSync = (CounterY >= 490) && (CounterY < 492);

  // Convert the 8-bit colours into 10-bit TMDS values
  logic [9:0] tmds_red, tmds_green, tmds_blue;
  logic [9:0] tmds_red_next, tmds_green_next, tmds_blue_next;
  TMDS_encoder encode_R(.clk(clk_pixel), .VD(i_red), .CD(2'b00),
    .VDE(DrawArea), .TMDS(tmds_red_next));
  TMDS_encoder encode_G(.clk(clk_pixel), .VD(i_green), .CD(2'b00),
    .VDE(DrawArea), .TMDS(tmds_green_next));
  TMDS_encoder encode_B(.clk(clk_pixel), .VD(i_blue), .CD({vSync,hSync}),
    .VDE(DrawArea), .TMDS(tmds_blue_next));

  // Strobe the TMDS_shift_load once every 10 i_tmdsclks
  // i.e. at the start of new pixel data
  logic [3:0] tmds_counter=0;
  always @(posedge clk_tmds) begin
    if (!rst) begin
      tmds_counter <= 0;
      tmds_red   <= 0;
      tmds_green <= 0;
      tmds_blue  <= 0;
    end else begin
      tmds_counter <= (tmds_counter==4'd9) ? 4'd0 : tmds_counter+4'd1;
      tmds_red   <= (tmds_counter == 4'd9)? tmds_red_next: tmds_red >> 1;
      tmds_green <= (tmds_counter == 4'd9)? tmds_green_next: tmds_green >> 1;
      tmds_blue  <= (tmds_counter == 4'd9)? tmds_blue_next: tmds_blue >> 1;
    end
  end

  // Finally output the LSB of each color bitstream
  assign o_red   = tmds_red[0];
  assign o_green = tmds_green[0];
  assign o_blue  = tmds_blue[0];

endmodule
