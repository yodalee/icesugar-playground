module top (
  input clk,
  output reg uart_tx,
);

parameter clk_freq = 25_000_000;
parameter baudrate = 9600;

/* generate 9600 Hz clock from 25 MHz */
reg clk_9600 = 0;
reg [16:0] cnt_9600 = 32'b0;
localparam CNT_RESET_9600 = (clk_freq / baudrate / 2);

always @(posedge clk) begin
  if (cnt_9600 == 0) begin
    clk_9600 <= ~clk_9600;
    cnt_9600 <= CNT_RESET_9600;
  end
  else begin
    cnt_9600 <= cnt_9600 - 1;
  end
end

endmodule
