module top (
  input clk,
  input rst,
  input  rx,
  output tx,
);

parameter CLK_FREQ = 25_000_000;
parameter BAUDRATE = 9600;
parameter CLK_PER_BAUD = CLK_FREQ / BAUDRATE;

byte rx_byte;
logic uart_rxed;

uart_tx # (.CLK_PER_BAUD(CLK_PER_BAUD))
mod_uart_tx (
  /* input */
  .clk(clk),
  .rst(rst),
  .tx_byte(rx_byte),
  .start_send(uart_rxed),

  /* output */
  .tx(tx),
  .done(uart_txed)
);

uart_rx # (.CLK_PER_BAUD(CLK_PER_BAUD))
mod_uart_rx (
  /* input */
  .clk(clk),
  .rst(rst),
  .rx(rx),

  /* output */
  .rx_byte(rx_byte),
  .done(uart_rxed)
);

endmodule
