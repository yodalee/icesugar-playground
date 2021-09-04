module uart (
  /* input */
  input clk,
  input rst,
  input [7:0] tx_byte,
  input start_send,

  /* output */
  output logic tx,
  output logic done
);

parameter CLK_PER_BAUD = 1;
localparam CLK_CNT_LIMIT = CLK_PER_BAUD-1;
localparam TX_LENGTH = 10; // start 1'b0, 1 byte, end 1'b1

typedef enum logic {
  STATE_IDLE  = 0,
  STATE_TXING = 1
} State_t;
State_t state = STATE_IDLE, state_next;
logic [9:0] tx_buf;
logic [3:0] tx_idx, tx_idx_next;
int  clk_cnt, clk_cnt_next;

/* output logic */
assign done = tx_idx == TX_LENGTH - 1;
assign tx = (state == STATE_IDLE) ? 1'b1 : tx_buf[tx_idx];

/* next logic for clk_cnt */
always_comb begin
  clk_cnt_next = (state == STATE_IDLE || clk_cnt == CLK_CNT_LIMIT) ? 0 : clk_cnt+1;
end

/* next logic for state */
always_comb begin
  case (state)
    STATE_IDLE: begin
      state_next = (start_send == 1'b1) ? STATE_TXING : state;
    end
    STATE_TXING: begin
      if (clk_cnt == CLK_CNT_LIMIT && tx_idx == TX_LENGTH-1) begin state_next = STATE_IDLE; end
      else begin state_next = state; end
    end
  endcase
end

/* next logic for tx_idx */
always_comb begin
  if (state == STATE_TXING && tx_idx < TX_LENGTH) begin
    if (clk_cnt == CLK_CNT_LIMIT) begin
      tx_idx_next = tx_idx+1;
    end
    else begin
      tx_idx_next = tx_idx;
    end
  end
  else begin
    tx_idx_next = 0;
  end
end

/* update state logic */
always_ff @(posedge clk or negedge rst) begin
  if (!rst) begin
    state   <= STATE_IDLE;
    tx_buf  <= 0;
    tx_idx  <= 0;
    clk_cnt <= 0;
  end
  else begin
    if (state == STATE_IDLE && start_send) begin
      tx_buf <= {1'b1, tx_byte, 1'b0};
    end
    state   <= state_next;
    tx_idx  <= tx_idx_next;
    clk_cnt <= clk_cnt_next;
  end
end

endmodule
