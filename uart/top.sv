module top (
  input clk,
  input rst,
  output uart_tx,
);

parameter clk_freq = 25_000_000;
parameter baudrate = 9600;

/* generate 9600 Hz clock from 25 MHz */
logic clk_9600;
int cnt_9600;
localparam CNT_RESET_9600 = (clk_freq / baudrate / 2);

byte bytes = "0";
logic uart_send = 1'b1; // always start transmit
logic uart_txed;

uart mod_uart (
  /* input */
  .clk_baud(clk_9600),
  .rst(rst),
  .tx_byte(bytes),
  .start_send(1'b1),

  /* output */
  .tx(uart_tx),
  .done(uart_txed),
);

always_ff @(posedge clk) begin
  if (cnt_9600 == 0) begin
    clk_9600 <= ~clk_9600;
    cnt_9600 <= CNT_RESET_9600;
  end
  else begin
    cnt_9600 <= cnt_9600 - 1;
  end
end

endmodule
