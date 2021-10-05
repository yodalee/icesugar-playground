
#include "Vtb_top.h"
#include <memory>
#include <iostream>
#include <vector>
#include <verilated.h>

int main()
{
  const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
  contextp->debug(0);
  contextp->traceEverOn(true);

  std::unique_ptr<Vtb_top> dut{new Vtb_top{contextp.get(), "TOP"}};

  dut->clk = 1; dut->rst = 1; dut->eval(); contextp->timeInc(1);
  dut->rst = 0; dut->eval(); contextp->timeInc(1);
  dut->rst = 1; dut->eval(); contextp->timeInc(1);
  for (int i = 0; i < 200; ++i) {
    contextp->timeInc(1);
    dut->clk = !dut->clk;
    dut->eval();
  }
  dut->final();
  return 0;
}
