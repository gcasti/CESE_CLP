ghdl -a ../../sources/counter_N.vhd ../../sources/counter_N_tb.vhd
ghdl -s ../../sources/counter_N.vhd ../../sources/counter_N_tb.vhd
ghdl -e counter_N_tb
ghdl -r counter_N_tb --vcd=counter_N_tb.vcd --stop-time=1000ns
gtkwave counter_N_tb.vcd
