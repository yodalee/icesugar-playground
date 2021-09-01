
ARG = --cc --build --trace
ALL: uart_tx

uart_tx: tb_uart_tx.sv tb_uart_tx.cpp
	verilator -sv ../uart_tx.sv tb_uart_tx.sv --exe tb_uart_tx.cpp ${ARG}
