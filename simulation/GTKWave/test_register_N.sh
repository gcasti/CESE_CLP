ghdl -a ../../sources/register_N.vhd ../../sources/register_N_tb.vhd
ghdl -s ../../sources/register_N.vhd ../../sources/register_N_tb.vhd
ghdl -e register_N_tb
ghdl -r register_N_tb --vcd=register_N_tb.vcd --stop-time=1000ns
gtkwave register_N_tb.vcd
