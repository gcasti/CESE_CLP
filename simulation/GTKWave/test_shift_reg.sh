ghdl -a ../../sources/shift_reg.vhd ../../sources/shift_reg_tb.vhd
ghdl -s shift_reg.vhd shift_reg.vhd
ghdl -e shift_reg_tb
ghdl -r shift_reg_tb --vcd=shift_reg_tb.vcd --stop-time=500ns
gtkwave shift_reg_tb.vcd
