module uart (
  /* input */
  input clk_baud,
  input rst,
  input [7:0] tx_byte,
  input tx_send,

  /* output */
  output tx,
  output tx_done,
);

localparam STATE_IDLE    = 8'd0;
localparam STATE_STARTTX = 8'd1;
localparam STATE_TXING   = 8'd2;
localparam STATE_TXED    = 8'd3;
reg [7:0] state = 8'b0;
reg [7:0] tx_buf = 8'b0;
reg [7:0] tx_cnt = 8'b0;
reg tx_bit;
reg tx_done = 1'b0;

assign tx = tx_bit;

always @(posedge clk_baud) begin
  if (!rst) begin
    state = STATE_IDLE;
    tx_bit <= 1'b1;
    tx_done = 1'b0;
  end
  else begin

  if (tx_send == 1 && state == STATE_IDLE) begin
    state <= STATE_STARTTX;
    tx_buf <= tx_byte;
    tx_done <= 1'b0;
    tx_bit <= 1'b1;
  end
  else if (state == STATE_IDLE) begin
    tx_bit  <= 1'b1;
    tx_done <= 1'b0;
  end

  if (state == STATE_STARTTX) begin
    tx_bit  <= 1'b0;
    state <= STATE_TXING;
  end

  if (state == STATE_TXING && tx_cnt < 8'd8) begin
    tx_bit <= tx_buf[0];
    tx_buf <= tx_buf >> 1;
    tx_cnt = tx_cnt + 1;
  end
  else if (state == STATE_TXING) begin
    tx_bit <= 1'b1;
    tx_cnt <= 8'd0;
    state <= STATE_TXED;
  end

  if (state == STATE_TXED) begin
    tx_done <= 1'b1;
    state <= STATE_IDLE;
  end

  end
end

endmodule
