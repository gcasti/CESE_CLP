library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registro de desplazamiento con entrada de datos
-- paralela y salida serie

entity shift_reg_piso is
	generic(
		N: integer := 8
	);
	port(
		clk_i     	: in	std_logic;								-- Reloj del sistema
		rst_i     	: in  std_logic;								-- Señal de reset sincronica
		arst_i		: in	std_logic;								-- Señal de reset asincrónica
		shift_en_i	: in 	std_logic;  							-- Señal que habilita el desplazamiento de datos 
		load_i		: in	std_logic;								-- Carga del registro de desplamiento
		dout_o		: out	std_logic;								-- Dato de salida del registro de desplazamiento
		data_reg_i	: in	std_logic_vector(N-1 downto 0)   -- Bus de datos para carga del registro
	);
end entity shift_reg_piso;

architecture behavioral of shift_reg_piso is

signal reg : std_logic_vector(N-1 downto 0) := (others => '0');

begin
    
	reg_process : process(clk_i , rst_i , arst_i) is
	begin
		if arst_i = '1' then 
			reg <= (others => '0');
		elsif falling_edge(clk_i) then
			if rst_i = '1' then
				reg <= (others => '0');
			elsif load_i = '1' then
				reg <= data_reg_i;			
			elsif shift_en_i = '1' then
				reg <= reg(N-2 downto 0) & '0';
			else
				reg <= reg;
			end if;
		end if;
	end process reg_process;
	
	dout_o <= reg(N - 1);

end architecture behavioral;