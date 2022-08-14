ghdl -a ../../sources/shift_reg_sipo.vhd ../../sources/shift_reg_sipo_tb.vhd
ghdl -s shift_reg_sipo.vhd shift_reg_sipo.vhd
ghdl -e shift_reg_sipo_tb
ghdl -r shift_reg_sipo_tb --vcd=shift_reg_sipo_tb.vcd --stop-time=500ns
gtkwave shift_reg_sipo_tb.vcd
