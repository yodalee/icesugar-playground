
ARG = --cc --build --trace
ALL: top

top: tb_top.cpp
	verilator -I.. -sv tb_top.sv --exe tb_top.cpp ${ARG}
