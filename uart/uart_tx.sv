module uart (
  /* input */
  input clk_baud,
  input rst,
  input [7:0] tx_byte,
  input start_send,

  /* output */
  output tx,
  output done
);

typedef enum logic [1:0] {
  STATE_IDLE  = 0,
  STATE_START = 1,
  STATE_TXING = 2,
  STATE_DONE  = 3
} State_t;
State_t state = STATE_IDLE;
byte tx_buf;
byte tx_cnt;
bit  tx_bit = 1'b1;
assign tx = tx_bit;

always_ff @(posedge clk_baud) begin
  if (!rst) begin
    state <= STATE_IDLE;
    tx_bit <= 1'b1;
    done <= 1'b0;
    tx_cnt <= 0;
  end
  else begin
    case (state)
      STATE_IDLE: begin
        tx_bit <= 1'b1;
        done <= 1'b0;
        if (start_send == 1'b1) begin
          state <= STATE_START;
          tx_buf <= tx_byte;
        end
      end
      STATE_START: begin
        state <= STATE_TXING;
        tx_bit <= 1'b0;
      end
      STATE_TXING: begin
        if (tx_cnt < 8'd8) begin
          tx_bit <= tx_buf[0];
          tx_buf <= tx_buf >> 1;
          tx_cnt <= tx_cnt+1;
        end
        else begin
          state  <= STATE_DONE;
          tx_bit <= 1'b1;
          tx_cnt <= 8'd0;
        end
      end
      STATE_DONE: begin
        done <= 1'b1;
        state <= STATE_IDLE;
      end
      default: begin
        state <= STATE_IDLE;
      end
    endcase
  end
end

endmodule
