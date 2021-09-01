
#include "Vuart_tx.h"
#include <memory>
#include <iostream>
#include <verilated.h>

int main()
{
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->debug(0);
  contextp->traceEverOn(true);

  std::unique_ptr<Vuart_tx> dut{new Vuart_tx{contextp.get(), "TOP"}};

  dut->clk = 1; dut->rst = 1; dut->eval();
  dut->rst = 0; dut->eval();
  dut->rst = 1; dut->eval();
  for (int i = 0; i < 200; ++i) {
    contextp->timeInc(1);
    dut->clk = !dut->clk;
    dut->eval();
  }
  dut->final();
  return 0;
}
