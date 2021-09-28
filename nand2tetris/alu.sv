module hack_alu (
  input i_zx,
  input i_nx,
  input i_zy,
  input i_ny,
  input i_f,
  input i_no,
  input [15:0] inx,
  input [15:0] iny,
  output logic o_zero,
  output logic o_negative,
  output logic [15:0] out
);

logic [15:0] zerox;
assign zerox = i_zx ? 0 : inx;
logic [15:0] notx;
assign notx = i_nx ? ~zerox : zerox;

logic [15:0] zeroy;
assign zeroy = i_zy ? 0 : iny;
logic [15:0] noty;
assign noty = i_ny ? ~zeroy : zeroy;

logic [15:0] fout;
assign fout = i_f ? notx + noty : notx & noty;

assign out = i_no ? ~fout : fout;

assign o_zero = out == 0;
assign o_negative = out[15] == 1;

endmodule
