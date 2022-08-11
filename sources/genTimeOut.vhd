----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:19:40 05/23/2018 
-- Design Name: 
-- Module Name:    genTimeOut - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity genTimeOut is
	 Generic ( TIMEOUT : real := 100.0e-9 ;	-- TIMEOUT
				  Tclk 	 :	real := 10.0e-9	-- Periodo del reloj
				);	
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           time_out : out  STD_LOGIC);
end genTimeOut;

architecture Behavioral of genTimeOut is

constant modulo : integer:= integer(round( TIMEOUT / Tclk));	--Cantidad de pulsos que debe contar
constant N		 : integer:= integer(ceil(log2(real(modulo))));	--Cantidad de bits del contador
	
signal reg : unsigned(N-1 downto 0) := (others=>'0');

begin

process(clk)			-- Genera el contador
begin
	if rising_edge(clk) then
		if reset = '1' then
			reg <= (others=>'0');
		elsif enable ='1' then
				reg <= reg + 1;
		end if;
	 end if;	
end process;	



--Actualizar: process(clk,reset)
--	begin
--		if reset = '1' then
--			reg <= (others => '0');
--		elsif rising_edge(clk) then
--			reg <= reg_next;
--		end if;
--end process Actualizar;
--
--process(enable, reg)			-- Genera el contador
--begin
--	if enable = '0' then
--		reg_next <= reg ;
--	elsif reg < modulo then
--		reg_next <= reg + 1;
--	else
--		reg_next <= reg;
--	end if;
--end process;	
--
time_out <= '1' when reg >= modulo else '0';	-- Activa la salida

end Behavioral;

