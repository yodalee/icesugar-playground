module top (
  input clk,
  input rst,
  output uart_tx,
);

parameter CLK_FREQ = 25_000_000;
parameter BAUDRATE = 9600;
parameter CLK_PER_BAUD = CLK_FREQ / BAUDRATE;

byte bytes = "0";
logic uart_send = 1'b1; // always start transmit
logic uart_txed;

uart # (.CLK_PER_BAUD(CLK_PER_BAUD))
mod_uart (
  /* input */
  .clk(clk),
  .rst(rst),
  .tx_byte(bytes),
  .start_send(1'b1),

  /* output */
  .tx(uart_tx),
  .done(uart_txed),
);

endmodule
