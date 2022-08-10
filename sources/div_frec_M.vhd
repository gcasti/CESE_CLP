----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:35:14 05/15/2018 
-- Design Name: 
-- Module Name:    div_frec_M - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity div_frec_M is
	 Generic(frec_in : real:= 5.0e6;
				frec_out : real := 1.0e6 );	

    Port ( clk_in : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end div_frec_M;

architecture Behavioral of div_frec_M is

constant MOD_COUNTER : integer:= integer( round(frec_in/frec_out)); -- Relación entre frecuencias 
constant N : integer:= integer(ceil(log2(real(MOD_COUNTER))));		  -- Cantidad de bits del contador
signal reg : unsigned(N-1 downto 0) := (others=>'0');

begin

process(reset,reg, enable,clk_in)
begin
	if reset = '1' then
		reg <= (others =>'0');
	elsif rising_edge(clk_in) then
		if enable = '1' then
			reg <= reg+1;
		end if;
	end if;
	if	reg = MOD_COUNTER then
		reg <= (others =>'0');
	end if;
end process;

clk_out <= reg(N-1);

end Behavioral;

