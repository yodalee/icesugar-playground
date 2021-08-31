module uart (
  /* input */
  input clk_baud,
  input rst,
  input [7:0] tx_byte,
  input start_send,

  /* output */
  output logic tx,
  output logic done
);

typedef enum logic [1:0] {
  STATE_IDLE  = 0,
  STATE_START = 1,
  STATE_TXING = 2,
  STATE_DONE  = 3
} State_t;
State_t state = STATE_IDLE, state_next;
byte tx_buf, tx_buf_next;
byte tx_cnt, tx_cnt_next;

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

/* next state */
always_comb begin
  case (state)
    STATE_IDLE: begin
      if (start_send == 1'b1) begin
        state_next = STATE_START;
        tx_buf_next = tx_byte;
        tx_cnt_next = 8'b0;
      end
      else begin
        state_next = STATE_IDLE;
        tx_buf_next = 8'b0;
        tx_cnt_next = 8'b0;
      end
    end
    STATE_START: begin
      state_next = STATE_TXING;
      tx_buf_next = tx_buf;
      tx_cnt_next = 8'b0;
    end
    STATE_TXING: begin
      if (tx_cnt < 8'd8) begin
        state_next = STATE_TXING;
        tx_buf_next = tx_buf >> 1;
        tx_cnt_next = tx_cnt+1;
      end
      else begin
        state_next = STATE_DONE;
        tx_buf_next = 8'b0;
        tx_cnt_next = 8'b0;
      end
    end
    default: begin
      state_next = STATE_IDLE;
      tx_buf_next = 8'b0;
      tx_cnt_next = 8'b0;
    end
  endcase
end

/* update state logic */
always_ff @(posedge clk_baud or negedge rst) begin
  if (!rst) begin
    state <= STATE_IDLE;
    tx_buf <= 8'b0;
    tx_cnt <= 8'b0;
  end
  else begin
    state <= state_next;
    tx_buf <= tx_buf_next;
    tx_cnt <= tx_cnt_next;
  end
end

endmodule
