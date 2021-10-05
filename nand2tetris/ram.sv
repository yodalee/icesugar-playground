module ram (
  input clk,

  // CPU rw side
  input we,
  input [DEPTH-1:0] addr,
  output logic [WIDTH-1:0] data_rd,
  input [WIDTH-1:0] data_wr,

  input [DEPTH-1:0] gpu_addr,
  output logic [WIDTH-1:0] gpu_data
);

localparam WIDTH = 16;
localparam DEPTH = 16;
localparam RAM_SIZE = (1<<14);
localparam SCREEN_SIZE = (1<<13);

// 16K cpu ram
logic [WIDTH-1:0] ram [0:RAM_SIZE-1];
// 8K screen ram
logic [WIDTH-1:0] screen [0:SCREEN_SIZE-1];

logic [WIDTH-1:0] ram_data;
logic [WIDTH-1:0] screen_data;

// CPU side
always_comb begin
  ram_data = ram[addr[13:0]];
end

always_ff @(posedge clk) begin
  if (we && addr[15:14] == 2'b00) begin
    ram[addr[13:0]] <= data_wr;
  end
end

always_comb begin
  screen_data = screen[addr[12:0]];
end

always_ff @(posedge clk) begin
  if (we && addr[15:14] == 2'b01) begin
    screen[addr[12:0]] <= data_wr;
  end
end

always_comb begin
  if (addr[15:14] == 2'b00) begin
    data_rd = ram_data;
  end
  else if (addr[15:14] == 2'b01) begin
    data_rd = screen_data;
  end
  else begin
    data_rd = 0;
  end
end

// GPU side
always_ff @(posedge clk) begin
  gpu_data <= screen[gpu_addr[12:0]];
end

endmodule
