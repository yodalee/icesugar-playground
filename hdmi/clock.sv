module clock
(
  input clkin_25MHz,
  output clk_25MHz,
  output clk_250MHz,
  output locked
);

logic clk_125MHz;

(* ICP_CURRENT="9" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL
#(
  .CLKOS_FPHASE(0),
  .CLKOP_FPHASE(0),
  .CLKOS_CPHASE(20),
  .CLKOP_CPHASE(2),
  .CLKOS_ENABLE("ENABLED"),
  .CLKOP_ENABLE("ENABLED"),
  .CLKI_DIV(1),
  .CLKOP_DIV(2),
  .CLKOS_DIV(20),
  .CLKFB_DIV(1),
  .FEEDBK_PATH("CLKOS")
)
pll_i
(
  .CLKI(clkin_25MHz),
  .CLKFB(clk_25MHz),
  .CLKOP(clk_250MHz),
  .CLKOS(clk_25MHz),
  .CLKOS2(),
  .CLKOS3(),
  .RST(1'b0),
  .STDBY(1'b0),
  .PHASESEL0(1'b0),
  .PHASESEL1(1'b0),
  .PHASEDIR(1'b0),
  .PHASESTEP(1'b0),
  .PLLWAKESYNC(1'b0),
  .ENCLKOP(1'b0),
  .ENCLKOS(1'b0),
  .ENCLKOS2(),
  .ENCLKOS3(),
  .LOCK(locked),
  .INTLOCK()
);
endmodule

