library IEEE;
use IEEE.std_logic_1164.all;

entity register_N is
	generic(
		N: natural := 4
	);
	port(
		clk_sys_i	: in std_logic;		-- Reloj de sincronismo
		rst_sys_i	: in std_logic;		-- Reset sincronico del modulo
		arst_sys_i	: in std_logic;		-- Reset asincronico del modulo
		enable_i	: in std_logic;		-- Carga el valor del bus de entrada
		data_i		: in std_logic_vector(N-1 downto 0);	-- Dato de entrada
		data_o		: out std_logic_vector(N-1 downto 0)	-- Dato de salida
	);
end;

architecture register_N_arq of register_N is
begin
	process(clk_sys_i, arst_sys_i)
	begin
		if arst_sys_i = '1' then
			data_o <= (others => '0');
		elsif rising_edge(clk_sys_i) then
			if rst_sys_i = '1' then
				data_o <= (others => '0');
			elsif enable_i = '1' then
				data_o <= data_i;
			end if;
		end if;
	end process;

end;