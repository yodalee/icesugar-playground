TARGET = top
TOP = top

SRCS = top.sv \
	alu.sv clock.sv pc.sv \
	hdmi/diffio.sv hdmi/hdmi.sv hdmi/TMDS_encoder.sv

ALL: $(TARGET).bin

.PHONY: clean prog

$(TARGET).json: $(SRCS)
	yosys -p "synth_ecp5 -json $@" top.sv

$(TARGET)_out.config: $(TARGET).json $(TARGET).lpf
	nextpnr-ecp5 --25k --package CABGA256 --speed 6 --json $< --textcfg $@ --lpf $(TARGET).lpf

$(TARGET).bin: $(TARGET)_out.config
	ecppack $< $@

prog:
	iceprog -d i:0x1d50:0x602b $(TARGET).bin

clean:
	rm -f *.blif *.bin *.json

