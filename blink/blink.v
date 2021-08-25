module blink (output reg led,
              input clk);
  localparam CNT_RST = 25_000_000;
  reg [24:0] counter;
  always @(posedge clk) begin
    if (counter == 25'd0) begin
      led <= led + 1;
      counter <= CNT_RST;
    end
    else begin
      counter <= counter - 1;
    end
  end
endmodule
