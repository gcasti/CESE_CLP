ghdl -a ../../sources/counter_N.vhd ../../sources/counter_N_tb.vhd
ghdl -s counter_N.vhd counter_N.vhd
ghdl -e counter_N_tb
ghdl -r counter_N_tb --vcd=counter_N_tb.vcd --stop-time=500ns
gtkwave counter_N_tb.vcd
