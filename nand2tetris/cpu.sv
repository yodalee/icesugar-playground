`include "alu.sv"
`include "pc.sv"
`include "register.sv"

module hack_cpu (
  input clk,
  input rst,
  input [WIDTH-1:0] instruction,
  input [WIDTH-1:0] i_memory,
  output logic o_we,
  output logic [WIDTH-1:0] o_out,
  output logic [WIDTH-1:0] o_addr,
  output logic [WIDTH-1:0] o_pc
);

localparam WIDTH = 16;

logic [WIDTH - 1:0] inx;
logic [WIDTH - 1:0] iny;
logic [WIDTH - 1:0] addr_instruction;
logic [WIDTH - 1:0] a_out;
logic [WIDTH - 1:0] alu_out;
logic [WIDTH - 1:0] next_pc;
logic f_zero;
logic f_negative;
logic jump;

logic is_A_inst, is_C_inst;
assign is_A_inst = (instruction[15] == 0);
assign is_C_inst = !is_A_inst;

assign addr_instruction = is_A_inst ? instruction : alu_out;
assign iny = instruction[12] ? i_memory : a_out;

always_comb begin
  if (is_C_inst) begin
    case ({instruction[2], instruction[1], instruction[0]})
      3'b000: jump = 0;
      3'b001: jump = !(f_negative || f_zero);
      3'b010: jump = f_zero;
      3'b011: jump = !f_negative;
      3'b100: jump = f_negative;
      3'b101: jump = !f_zero;
      3'b110: jump = f_negative || f_zero;
      3'b111: jump = 1;
    endcase
  end
  else begin
    jump = 0;
  end
end

// program counter
hack_pc #(
  .WIDTH(WIDTH)
) pc (
  .clk(clk), .rst(rst),
  .inc(1'b1), .load(jump),
  .in(a_out + 1), .out(next_pc)
);

register register_d (
  .clk(clk),
  .in(alu_out),
  .load(is_C_inst && instruction[4]),
  .out(inx)
);

register register_a (
  .clk(clk),
  .in(addr_instruction),
  .load(instruction[5] || is_A_inst),
  .out(a_out)
);

hack_alu alu (
  .i_zx(instruction[11]),
  .i_nx(instruction[10]),
  .i_zy(instruction[9]),
  .i_ny(instruction[8]),
  .i_f(instruction[7]),
  .i_no(instruction[6]),
  .inx(inx),
  .iny(iny),
  .o_zero(f_zero),
  .o_negative(f_negative),
  .out(alu_out)
);

assign o_out = alu_out;
assign o_addr = a_out;
assign o_we = !is_A_inst && instruction[3];
assign o_pc = jump ? a_out : next_pc;

endmodule
