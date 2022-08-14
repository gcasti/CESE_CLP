library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_reg is
	generic(
		N: integer := 8
	);
	port(
		clk_i     		: in    std_logic;    -- Reloj del sistema
		rst_i      		: in    std_logic;    -- Señal de reset sincronica
		shift_en_i 	    : in    std_logic;    -- Señal que habilita el desplazamiento de datos 
        load_i          : in    std_logic;    -- Señal de carga del registro     
		data_reg_i      : in    std_logic_vector(N-1 downto 0);   -- Bus de datos para carga del registro
        data_reg_o		: out   std_logic_vector(N-1 downto 0);   -- Bus de datos para lectura del registro
		Din_i		    : in    std_logic;    -- Dato de entrada del registro de desplazamiento
        Dout_o          : out   std_logic     -- Dato de salida del registro de desplazamiento       	
	);
end entity shift_reg;

architecture Behavioral of shift_reg is

	signal reg : std_logic_vector(LENGTH-1 downto 0) := (others => '0');
begin
    main_process : process(clk_i, rst_i) is
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                reg <= (others => '0');
            elsif load_i = '1' then
                reg <= data_reg_i;
            else
                if shift_en_i = '1' then
                    reg <= reg(N-2 downto 0) & Din_i;
                else
                    reg <= reg;
                end if;
            end if;
        end if;
    end process main_process;
    
    Dout_o <= reg(N-1);
    data_reg_o <= reg;
end architecture Behavioral;