library IEEE;
use IEEE.std_logic_1164.all;

entity register_N is
	generic(
		N: natural := 4
	);
	port(
		clk_i	: in std_logic;		-- clock
		srst_i	: in std_logic;		-- reset sincronico
		arst_i	: in std_logic;		-- reset asincronico
		ena_i	: in std_logic;		-- habilitador
		d_i		: in std_logic_vector(N-1 downto 0);		-- dato de entrada
		q_o		: out std_logic_vector(N-1 downto 0)		-- dato de salida
	);
end;

architecture register_N_arq of register_N is
begin
	process(clk_i, arst_i)
	begin
		if arst_i = '1' then
			q_o <= (others => '0');
		elsif rising_edge(clk_i) then
			if srst_i = '1' then
				q_o <= (others => '0');
			elsif ena_i = '1' then
				q_o <= d_i;
			end if;
		end if;
	end process;

end;