module hack_pc (
  input clk,
  input rst,
  input inc,
  input load,
  input [WIDTH-1:0] in,
  output logic [WIDTH-1:0] out
);

parameter WIDTH = 16;

always_ff @(posedge clk or negedge rst) begin
  if (!rst) begin
    out <= 0;
  end
  else if (load) begin
    out <= in;
  end
  else if (inc) begin
    out <= out + 1;
  end
  else begin
    out <= out;
  end
end

endmodule
