module top (
  input clk,
  input rst,
  output reg uart_tx,
);

parameter clk_freq = 25_000_000;
parameter baudrate = 9600;

/* generate 9600 Hz clock from 25 MHz */
reg clk_9600 = 0;
reg [16:0] cnt_9600 = 32'b0;
localparam CNT_RESET_9600 = (clk_freq / baudrate / 2);

reg [7:0] bytes = "0";
reg uart_send = 1'b1; // always start transmit
wire uart_txed;

uart mod_uart (
  /* input */
  .clk_baud(clk_9600),
  .rst(rst),
  .tx_byte(bytes),
  .tx_send(uart_send),

  /* output */
  .tx(uart_tx),
  .tx_done(uart_txed),
);

always @(posedge clk) begin
  if (!rst) begin
    bytes <= "0";
  end
  else begin

  if (cnt_9600 == 0) begin
    clk_9600 <= ~clk_9600;
    cnt_9600 <= CNT_RESET_9600;
  end
  else begin
    cnt_9600 <= cnt_9600 - 1;
  end

  end
end

endmodule
