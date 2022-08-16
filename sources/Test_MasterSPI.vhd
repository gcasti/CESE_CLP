library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.math_real.all;
use IEEE.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;



entity Test_MasterSPI is
	 generic (
				DATA_LENGTH 		: integer	:= 8;			-- Cantidad de bits del modulo
				CLOCK_SYS_FREQUENCY	: real		:= 50.0e6;	-- Frecuencia del reloj de sincronismo
				CLOCK_SPI_FREQUENCY	: real		:= 1.0e6		-- Frecuencia del modulo SPI
				);	
    port ( -- Señales de sincronismo
				clk_sys_i	: in  STD_LOGIC;	-- Reloj de sincronismo del sistema
				-- Señales de hardware para test
				test	 		: out std_logic_vector(2 downto 0);
				KEY			: in 	std_logic_vector(3 downto 0);
				LEDR			: out std_logic_vector(9 downto 0);
			  -- Interfaz de hardware
				SCLK_O		: out STD_LOGIC;		-- Reloj de salida
				MOSI_O		: out STD_LOGIC;		-- Datos serie de entrada	
				MISO_I		: in  STD_LOGIC;		-- Datos serie de salida	
				CS_O			: out STD_LOGIC		-- Seleccion de dispositivo (Ship selec)
			  -- interfaz de operacion
				--data_rd_o	: out STD_LOGIC;		-- Dato recibido/fin de operacion	
				--data_wr_i 	: in  STD_LOGIC;		-- 
				--data_tx_i	: in  STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0);	--Datos a transmitir
				--data_rx_o	: out STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0)	--Datos recibidos
			  );
end Test_MasterSPI;

architecture Behavioral of Test_MasterSPI is

signal clk_sys_s : std_logic;

component MasterSPI is
	 generic (
				DATA_LENGTH 		: integer	:= 8;			-- Cantidad de bits del modulo
				CLOCK_SYS_FREQUENCY	: real		:= 50.0e6;	-- Frecuencia del reloj de sincronismo
				CLOCK_SPI_FREQUENCY	: real		:= 1.0e6		-- Frecuencia del modulo SPI
				);	
    port ( -- Señales de sincronismo
				clk_sys_i	: in  STD_LOGIC;	-- Reloj de sincronismo del sistema
				rst_sys_i	: in  STD_LOGIC;	-- Reset del sistema
           -- Interfaz de hardware
				SCLK_O		: out STD_LOGIC;		-- Reloj de salida
				MOSI_O		: out STD_LOGIC;		-- Datos serie de entrada	
				MISO_I		: in  STD_LOGIC;		-- Datos serie de salida	
				CS_O			: out STD_LOGIC;		-- Seleccion de dispositivo (Ship selec)
			  -- interfaz de operacion
				start_i		: in  STD_LOGIC;		-- Señal de inicio de transmision
				data_rd_o	: out STD_LOGIC;		-- Dato recibido/fin de operacion	
				data_wr_i 	: in  STD_LOGIC;		-- 
				data_tx_i	: in  STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0);	--Datos a transmitir
				data_rx_o	: out STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0)	--Datos recibidos
			  );
end component MasterSPI;

component div_frec_M is
	generic(
		frec_in : real:= 50.0e6;
		frec_out : real := 1.0e6
	);	
	
	port(
		clk_in : in  STD_LOGIC;
		enable : in  STD_LOGIC;
		reset : in  STD_LOGIC;
		clk_out : out  STD_LOGIC
			  );
end component div_frec_M;

component test_pll is
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic         -- outclk0.clk
	);
end component test_pll;

begin

Inst_clk_spi : test_pll
		port map (
			refclk   => clk_sys_i,   --  refclk.clk
			rst      => not KEY(1),      --   reset.reset
			outclk_0 => clk_sys_s
		);
		
Inst_MasterSPI : MasterSPI
	 generic map (
				DATA_LENGTH => DATA_LENGTH ,
				CLOCK_SYS_FREQUENCY => CLOCK_SYS_FREQUENCY,
				CLOCK_SPI_FREQUENCY => CLOCK_SPI_FREQUENCY
				)
    port map( 
				clk_sys_i 	=> clk_sys_s,
				rst_sys_i 	=> not KEY(1),
				
				SCLK_O 		=> SCLK_O,
				MOSI_O 		=> MOSI_O,
				MISO_I 		=> MISO_I,
				CS_O	 		=> CS_O,
			  -- interfaz de operacion
				start_i		=> not KEY(0),		
				data_rd_o 	=> open,	
				data_wr_i 	=> '0',	
				data_tx_i 	=> "10101010",	
				data_rx_o 	=> open	
			  );
			  
Inst_div : div_frec_M
	generic map(
				frec_in => 25.0e6,		-- Frecuencia que proviene del PLL
				frec_out => 1.0 
				)		  
	port map (
				clk_in => clk_sys_s,
				enable => KEY(3),
				reset  => not KEY(1),
				clk_out => LEDR(0)
			  );
			  
test(0) <= clk_sys_i;
test(1) <= clk_sys_s;
test(2) <= not KEY(0);
	
LEDR(9 downto 1) <= (others => '0');
end Behavioral;