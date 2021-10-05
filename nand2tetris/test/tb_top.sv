`include "cpu.sv"

module tb_top (
  input clk,
  input rst
);

initial begin
  $dumpfile("top.vcd");
  $dumpvars(0, tb_top);
end

logic [15:0] gpu_addr;
logic [15:0] gpu_data;
logic [15:0] instruction;
logic [15:0] rom_addr;
logic [15:0] dummy;

rom #(
  .WIDTH(16),
  .DEPTH(14),
  .SIZE(1<<14),
  .FILE("rom.hack")
) rom_i (
  .clk(clk),
  .addr(rom_addr[13:0]), .data(instruction)
);


logic [15:0] addr;
logic [15:0] cpu_out, ram_out;
logic ram_we;

hack_cpu cpu (
  .clk(clk), .rst(rst),
  .instruction(instruction), .i_memory(ram_out),
  .o_we(ram_we), .o_out(cpu_out), .o_addr(addr), .o_pc(rom_addr)
);

ram ram_i (
  .clk(clk),
  .we(ram_we),
  .addr(addr), .data_rd(ram_out), .data_wr(cpu_out),
  .gpu_addr(gpu_addr), .gpu_data(gpu_data)
);


endmodule
