library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registro de desplazamiento con entrada serie y salida paralela

entity shift_reg_sipo is
	generic(
		LENGTH: integer := 8
	);
	port(
		clk_i     	: in	std_logic;	-- Reloj del sistema
		rst_i     	: in  std_logic;  -- Señal de reset sincronica
		arst_i		: in	std_logic;  -- Señal de reset asincrónica
		shift_en_i	: in  std_logic;  -- Señal que habilita el desplazamiento de datos 
		din_i		   : in  std_logic; 			   						-- Dato de entrada del registro de desplazamiento
		data_reg_o	: out	std_logic_vector(LENGTH-1 downto 0)    -- Bus de datos para lectura del registro
	);
end entity shift_reg_sipo;

architecture Behavioral of shift_reg is

signal reg : std_logic_vector(LENGTH-1 downto 0) := (others => '0');

begin
    
	reg_process : process(clk_i, rst_i) is
	begin
		if arst_i = '1' then 
			reg <= (others => '0');
		elsif rising_edge(clk_i) then
			if rst_i = '1' then
				reg <= (others => '0');
			elsif shift_en_i = '1' then
				reg <= reg(LENGTH-2 downto 0) & Din_i;
			else
			reg <= reg;
			end if;
		end if;
	end process reg_process;
	
	data_reg_o <= reg;

end architecture Behavioral;