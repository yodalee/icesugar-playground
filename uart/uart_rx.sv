module uart_rx (
  /* input */
  input clk,
  input rst,
  input rx,

  /* output */
  output logic [7:0] rx_byte,
  output logic done
);

parameter CLK_PER_BAUD = 1;
localparam CLK_CNT_LIMIT = CLK_PER_BAUD-1;
localparam SAMPLE_CLK_CNT = CLK_CNT_LIMIT / 2;
localparam RX_LENGTH = 10; // start 1'b0, 1 byte, end 1'b1

typedef enum logic {
  STATE_IDLE  = 0,
  STATE_RXING = 1
} State_t;
State_t state = STATE_IDLE, state_next;
logic [9:0] rx_buf;
logic [3:0] rx_idx, rx_idx_next;
int  clk_cnt, clk_cnt_next;

/* output logic */
assign done = (rx_idx == RX_LENGTH - 1 && clk_cnt == CLK_CNT_LIMIT);
assign rx_byte = rx_buf[8:1];

/* next logic for clk_cnt */
always_comb begin
  clk_cnt_next = (state == STATE_IDLE || clk_cnt == CLK_CNT_LIMIT) ? 0 : clk_cnt+1;
end

/* next logic for state */
always_comb begin
  case (state)
    STATE_IDLE: begin
      state_next = (rx == 1'b0) ? STATE_RXING : state;
    end
    STATE_RXING: begin
      if (clk_cnt == CLK_CNT_LIMIT && rx_idx == RX_LENGTH-1) begin state_next = STATE_IDLE; end
      else begin state_next = state; end
    end
  endcase
end

/* next logic for rx_idx */
always_comb begin
  if (state == STATE_RXING && rx_idx < RX_LENGTH) begin
    if (clk_cnt == CLK_CNT_LIMIT) begin
      rx_idx_next = rx_idx+1;
    end
    else begin
      rx_idx_next = rx_idx;
    end
  end
  else begin
    rx_idx_next = 0;
  end
end

/* update state logic */
always_ff @(posedge clk or negedge rst) begin
  if (!rst) begin
    state   <= STATE_IDLE;
    rx_buf  <= 0;
    rx_idx  <= 0;
    clk_cnt <= 0;
  end
  else begin
    if (clk_cnt == SAMPLE_CLK_CNT) begin
      rx_buf[rx_idx] <= rx;
    end
    state   <= state_next;
    rx_idx  <= rx_idx_next;
    clk_cnt <= clk_cnt_next;
  end
end

endmodule
