module gpu (
  input clk,
  input rst,
  input i_newframe,
  input i_newline,
  input i_enable,
  output logic [15:0] o_addr,
  input [15:0] i_data,
  output logic [23:0] o_pixel
);

localparam WIDTH  = 640;
localparam HEIGHT = 480;

shortint counterX, counterY;

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

assign o_addr = (counterY << 5) + (counterX >> 4);

always_comb begin
  if (counterX >= 512 || counterY >= 256) begin
    o_pixel = 24'd0;
  end
  else begin
    o_pixel = (i_data[counterX & 4'hf]) ? 24'hffffff : 0;
  end
end

endmodule
