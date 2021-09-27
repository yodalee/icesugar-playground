module imagesrc (
  input clk,
  input rst,
  input i_newframe,
  input i_newline,
  input i_enable,
  output logic [23:0] pixel
);

localparam WIDTH = 640;
localparam HEIGHT= 480;

shortint counterX, counterY;
logic [8:0] read_byte, write_byte;
assign write_byte = 9'b0;

bram #(
  .WIDTH(9),
  .DEPTH(17),
  .SIZE(76800)
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
    if (i_newframe) begin
      counterX <= 0;
      counterY <= 0;
    end
    else if (i_enable) begin
      counterX <= (counterX == WIDTH-1) ? 0 : counterX+1;
      counterY <= (counterX == WIDTH-1) ? counterY+1 : counterY;
    end
  end
end

assign pixel = {
  read_byte[8:6], 5'b0,
  read_byte[5:3], 5'b0,
  read_byte[2:0], 5'b0
};

endmodule
