module top (
  input clk,
  input rst,
  input rx,
  output logic tx
);

byte bytes = "0";
logic uart_send = 1'b1; // always start transmit
logic uart_txed;

localparam CLK_PER_BAUD = 4;

initial begin
  $dumpfile("uart_tx.vcd");
  $dumpvars(0, uart_tx);
end

uart_tx #(.CLK_PER_BAUD(CLK_PER_BAUD))
mod_uart (
  /* input */
  .clk(clk),
  .rst(rst),
  .tx_byte(bytes),
  .start_send(1'b1),

  /* output */
  .tx(tx),
  .done(uart_txed)
);

endmodule
