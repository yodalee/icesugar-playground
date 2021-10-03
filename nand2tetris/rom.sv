module rom (
  input clk,
  input [DEPTH-1:0] addr,
  output logic [WIDTH-1:0] data
);

parameter WIDTH=16;
parameter DEPTH=14;
parameter SIZE=(1<<DEPTH);
parameter FILE="rom.hack";

logic [WIDTH-1:0] ram [0:SIZE-1];

`ifdef verilator
initial begin
  $readmemb("rom.hack", ram);
end
`else
initial begin
  if (FILE) begin
    $readmemb(FILE, ram);
  end
end
`endif

always_ff @(posedge clk) begin
  data <= ram[addr];
end

endmodule
