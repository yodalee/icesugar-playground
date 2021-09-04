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

typedef enum logic [1:0] {
  STATE_IDLE  = 0,
  STATE_START = 1,
  STATE_TXING = 2,
  STATE_DONE  = 3
} State_t;
State_t state = STATE_IDLE, state_next;
byte tx_buf, tx_buf_next;
byte tx_cnt, tx_cnt_next;
int  clk_cnt, clk_cnt_next;

/* output logic */
assign done = state == STATE_DONE;
always_comb begin
  case (state)
    STATE_START: begin
      tx = 1'b0;
    end
    STATE_TXING: begin
      tx = tx_buf[0];
    end
    default: begin
      tx = 1'b1;
    end
  endcase
end

/* next logic for clk_cnt */
always_comb begin
  clk_cnt_next = (state == STATE_IDLE || clk_cnt == CLK_CNT_LIMIT) ? 0 : clk_cnt+1;
end

/* next logic for state */
always_comb begin
  case (state)
    STATE_IDLE: begin
      state_next = (start_send == 1'b1) ? STATE_START : state;
    end
    STATE_START: begin
      if (clk_cnt < CLK_CNT_LIMIT) begin state_next = state; end
      else begin state_next = STATE_TXING; end
    end
    STATE_TXING: begin
      if (clk_cnt == CLK_CNT_LIMIT && tx_cnt == 7) begin state_next = STATE_DONE; end
      else begin state_next = state; end
    end
    STATE_DONE: begin
      if (clk_cnt < CLK_CNT_LIMIT) begin state_next = state; end
      else begin state_next = STATE_IDLE; end
    end
  endcase
end

/* next logic for tx_buf */
always_comb begin
  if (state == STATE_IDLE && start_send == 1'b1) begin
    tx_buf_next = tx_byte;
  end
  else if (state == STATE_TXING && tx_cnt < 8 && clk_cnt == CLK_CNT_LIMIT) begin
    tx_buf_next = tx_buf >> 1;
  end
  else begin
    tx_buf_next = tx_buf;
  end
end

/* next logic for tx_cnt */
always_comb begin
  if (state == STATE_TXING && tx_cnt < 8) begin
    if (clk_cnt == CLK_CNT_LIMIT) begin
      tx_cnt_next = tx_cnt+1;
    end
    else begin
      tx_cnt_next = tx_cnt;
    end
  end
  else begin
    tx_cnt_next = 0;
  end
end

/* update state logic */
always_ff @(posedge clk or negedge rst) begin
  if (!rst) begin
    state   <= STATE_IDLE;
    tx_buf  <= 0;
    tx_cnt  <= 0;
    clk_cnt <= 0;
  end
  else begin
    state   <= state_next;
    tx_buf  <= tx_buf_next;
    tx_cnt  <= tx_cnt_next;
    clk_cnt <= clk_cnt_next;
  end
end

endmodule
