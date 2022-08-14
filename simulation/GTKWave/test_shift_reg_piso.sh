ghdl -a ../../sources/shift_reg_piso.vhd ../../sources/shift_reg_piso_tb.vhd
ghdl -s shift_reg_piso.vhd shift_reg_piso.vhd
ghdl -e shift_reg_piso_tb
ghdl -r shift_reg_piso_tb --vcd=shift_reg_piso_tb.vcd --stop-time=500ns
gtkwave shift_reg_piso_tb.vcd
