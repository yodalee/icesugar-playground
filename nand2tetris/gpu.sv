module gpu (
  input clk,
  input rst,
  input i_newframe,
  input i_newline,
  input i_enable,
  output logic [23:0] pixel
);

localparam WIDTH  = 640;
localparam HEIGHT = 480;
localparam BASE   = 16 * 1024; // GPU memory offset 16K, 16

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

always_comb begin
  if (counterX >= 512 || counterY >= 256) begin
    pixel = 24'd0;
  end
  else begin
    pixel = 24'hffffff;
  end
end

endmodule
