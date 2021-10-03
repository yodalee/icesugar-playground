module register (
  input clk,
  input [15:0] in,
  input load,
  output logic [15:0] out
);

always_ff @(posedge clk) begin
  if (load) begin
    out <= in;
  end
end

endmodule
