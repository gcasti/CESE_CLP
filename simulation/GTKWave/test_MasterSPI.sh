ghdl -a --ieee=synopsys ../../sources/MasterSPI.vhd ../../sources/shift_reg_sipo.vhd ../../sources/shift_reg_piso.vhd ../../sources/genTimeOut.vhd ../../sources/register_N.vhd ../../sources/MasterSPI_tb.vhd 
ghdl -s MasterSPI.vhd MasterSPI.vhd
ghdl -e MasterSPI_tb
ghdl -r MasterSPI_tb --vcd=MasterSPI_tb.vcd --stop-time=500ns
gtkwave MasterSPI_tb.vcd
