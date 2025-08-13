vlib work
vlog -f list.txt 
vsim -voptargs=+acc work.UART_TX_tb
add wave *
add wave -position insertpoint  \
sim:/UART_TX_tb/DUT/fsm_inst/mux_sel \
sim:/UART_TX_tb/DUT/fsm_inst/current_state \
sim:/UART_TX_tb/DUT/fsm_inst/next_state
add wave -position insertpoint  \
sim:/UART_TX_tb/DUT/serializer_inst/ser_done \
sim:/UART_TX_tb/DUT/serializer_inst/ser_data
add wave -position insertpoint  \
sim:/UART_TX_tb/DUT/serializer_inst/ser_en
add wave -position insertpoint  \
sim:/UART_TX_tb/DUT/serializer_inst/bit_count \
sim:/UART_TX_tb/DUT/serializer_inst/shift_reg
run -all