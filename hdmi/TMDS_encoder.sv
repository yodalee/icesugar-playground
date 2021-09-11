module TMDS_encoder(
	input clk, // 250 MHz
  input rst,
	input [7:0] data,  // video data (red, green or blue)
	input [1:0] control,  // control data
	input enable,  // enable == 1 ? data : control
	output logic [9:0] tmds
);

typedef enum logic [9:0] {
  CTRL_00 = 10'b1101010100,
  CTRL_01 = 10'b0010101011,
  CTRL_10 = 10'b0101010100,
  CTRL_11 = 10'b1010101011
} control_t;

logic signed [5:0] disparity;
logic [3:0] ones_d;
bit use_xor;
logic [7:0] qm;
logic [3:0] ones_qm;
logic signed [4:0] diff_qm;
bit invert_qm;

// stage 1: rolling_xor or rolling_xnor the data
assign ones_d = count_ones(data);
assign use_xor = ones_d < 4 || (ones_d == 4 && data[0] == 1'b1);
assign qm = (use_xor)? rolling_xor(data) : rolling_xnor(data);

// stage 2: invert bits to compensate diff in 1s or 0s
assign ones_qm = count_ones(qm);
assign diff_qm = (signed'(5'(ones_qm) << 1)) - 5'd8;

always_comb begin
  if (disparity == 0 && ones_qm == 4) begin
    // balanced, set invert_qm to compensate xor bit
    invert_qm = ~use_xor;
  end
  else begin
    invert_qm = (disparity > 0 && ones_qm > 4) || (disparity < 0 && ones_qm < 4);
  end
end

always_ff @(posedge clk or negedge rst) begin
  if (!rst) begin
    tmds <= 0;
    disparity <= 0;
  end
  else begin
    if (enable) begin
      tmds <= {invert_qm, use_xor, invert_qm ? ~qm : qm};
      disparity <= disparity +
        (invert_qm ? -($bits(disparity)'(diff_qm)) : $bits(disparity)'(diff_qm)) +
        (invert_qm ? $bits(disparity)'('sd1) : -($bits(disparity)'('sd1)));
    end
    else begin
      disparity <= 0;
      case (control)
        2'b00: tmds <= CTRL_00;
        2'b01: tmds <= CTRL_01;
        2'b10: tmds <= CTRL_10;
        2'b11: tmds <= CTRL_11;
      endcase
    end
  end
end

function automatic logic [3:0] count_ones(input logic [7:0] bits);
  count_ones = 0;
  int i;
  for (i = 0; i < 8; i++) begin
    count_ones += $bits(count_ones)'(bits[i]);
  end
endfunction

function automatic logic [7:0] rolling_xor(input logic [7:0] bits);
  rolling_xor[0] = bits[0];
  int i;
  for (i = 1; i < 8; i++) begin
    rolling_xor[i] = rolling_xor[i-1] ^ bits[i];
  end
endfunction

function automatic logic [7:0] rolling_xnor(input logic [7:0] bits);
  rolling_xnor[0] = bits[0];
  int i;
  for (i = 1; i < 8; i++) begin
    rolling_xnor[i] = rolling_xnor[i-1] ^~ bits[i];
  end
endfunction

endmodule
