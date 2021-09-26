module bram (
  input clk,
  input re,
  input we,
  input [DEPTH-1:0] addr_rd,
  input [DEPTH-1:0] addr_wr,
  output logic [WIDTH-1:0] data_rd,
  input [WIDTH-1:0] data_wr
);

parameter WIDTH=8;
parameter DEPTH=8;
parameter SIZE=(1<<DEPTH);

initial begin
  $readmemh("data.hex", ram);
end

logic [WIDTH-1:0] ram [0:SIZE-1];

always_ff @(posedge clk) begin
  if (we) begin
    ram[addr_wr] = data_wr;
  end
end

always_ff @(posedge clk) begin
  if (re) begin
    data_rd <= ram[addr_rd];
  end
end

endmodule
