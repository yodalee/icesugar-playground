`include "clock.sv"
`include "cpu.sv"
`include "gpu.sv"
`include "rom.sv"
`include "hdmi/diffio.sv"
`include "hdmi/hdmi.sv"
`include "hdmi/TMDS_encoder.sv"

module top (
  input clk,
  input rst,
  output logic [3:0] hdmi_dp, hdmi_dn,
  output logic [7:0] debug
);

  logic clk_25MHz, clk_250MHz;
  clock clock_instance(
      .clkin_25MHz(clk),
      .clk_25MHz(clk_25MHz),
      .clk_250MHz(clk_250MHz)
  );

  logic [7:0] pixelR, pixelG, pixelB;
  logic [23:0] pixel;
  assign pixelR = pixel[23:16];
  assign pixelG = pixel[15:8];
  assign pixelB = pixel[7:0];

  logic o_red, o_green, o_blue;
  logic o_enable, o_newline, o_newframe;

  hdmi hdmi_instance(
    .clk_tmds(clk_250MHz), .clk_pixel(clk_25MHz), .rst(rst),
    .i_red(pixelR), .i_green(pixelG), .i_blue(pixelB),
    .o_enable(o_enable), .o_newline(o_newline), .o_newframe(o_newframe),
    .o_red(o_red), .o_green(o_green), .o_blue(o_blue));

  diffio diffio_red   (.in(o_red),     .op(hdmi_dp[2]), .on(hdmi_dn[2]));
  diffio diffio_green (.in(o_green),   .op(hdmi_dp[1]), .on(hdmi_dn[1]));
  diffio diffio_blue  (.in(o_blue),    .op(hdmi_dp[0]), .on(hdmi_dn[0]));
  diffio diffio_clock (.in(clk_25MHz), .op(hdmi_dp[3]), .on(hdmi_dn[3]));

  logic [15:0] rom_addr;
  logic [15:0] instruction;

  rom #(
    .WIDTH(16),
    .DEPTH(14),
    .SIZE(1<<14),
    .FILE("rom.hack")
  ) rom_i (
    .clk(clk),
    .addr(rom_addr[13:0]), .data(instruction)
  );

  logic [15:0] mem_out;
  logic mem_we;
  logic [15:0] cpu_out, addr;
  logic [15:0] gpu_addr, gpu_data;

  hack_cpu cpu (
    .clk(clk), .rst(rst),
    .instruction(instruction), .i_memory(mem_out),
    .o_we(mem_we), .o_out(cpu_out),
    .o_addr(addr), .o_pc(rom_addr)
  );

  gpu gpu_i (
    .clk(clk),
    .rst(rst),
    .i_newframe(o_newframe),
    .i_newline(o_newline),
    .i_enable(o_enable),
    .pixel(pixel)
  );

  assign debug = rom_addr[7:0];

endmodule

