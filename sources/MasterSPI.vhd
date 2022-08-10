----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    
-- Design Name: 
-- Module Name:    -- Project Name: 
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
--use IEEE.NUMERIC_STD.ALL;
--use IEEE.math_real.all;


entity MasterSPI is
	 generic ( 	DATA_LENGTH 		: integer	:= 8;			-- Cantidad de bits del modulo
				CLOCK_SYS_FREQUENCY	: real		:= 50.0e6;	-- Frecuencia del reloj de sincronismo
				CLOCK_SPI_FREQUENCY	: real		:= 1.0e6		-- Frecuencia del modulo SPI
				);	
    port ( -- Señales de sincronismo
				clk_sys_i	: in  STD_LOGIC;	-- Reloj de sincronismo del sistema
				reset_sys_i	: in  STD_LOGIC;	-- Reset del sistema
           -- Interfaz de hardware
				SLCK_O		: out STD_LOGIC;		-- Reloj de salida
				MOSI_O		: out STD_LOGIC;		-- Datos serie de entrada	
				MISO_I		: in  STD_LOGIC;		-- Datos serie de salida	
				SS_O		: out STD_LOGIC;		-- Seleccion de dispositivo (Ship selec)
			  -- interfaz de operacion
				start_i		: in  STD_LOGIC;		-- Señal de inicio de transmision
				data_rd_o	: out STD_LOGIC;		-- Dato recibido/fin de operacion	
				data_wr_i 	: in  STD_LOGIC;		-- 
				data_tx_i	: in  STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0);	--Datos a transmitir
				data_rx_o	: out STD_LOGIC_VECTOR(DATA_LENGTH-1 downto 0)	--Datos recibidos
			  );
end MasterSPI;

architecture Behavioral of MasterSPI is

component div_frec_M
	generic ( frec_in : REAL := 5000000.0; frec_out : REAL := 1000000.0 );
	port
	(
		clk_in	: in std_logic;
		enable	: in std_logic;
		reset	: in std_logic;
		clk_out	: out std_logic
	);
end component;

component shift_reg is
	generic(
		LENGTH: integer := DATA_LENGTH
	);
	port(
		clk_i     	: in    std_logic;    -- Reloj del sistema
		rst_i      	: in    std_logic;    -- Señal de reset sincronica
		shift_en_i	: in    std_logic;    -- Señal que habilita el desplazamiento de datos 
		load_i      : in    std_logic;    -- Señal de carga del registro     
		data_reg_i  : in    std_logic_vector(LENGTH-1 downto 0);   -- Bus de datos para carga del registro
    	data_reg_o	: out   std_logic_vector(LENGTH-1 downto 0);   -- Bus de datos para lectura del registro
		Din_i		: in    std_logic;    -- Dato de entrada del registro de desplazamiento
    	Dout_o      : out   std_logic     -- Dato de salida del registro de desplazamiento       	
	);
end component shift_reg;

component register_N is
	generic(
		N: natural := DATA_LENGTH
	);
	port(
		clk_i	: in std_logic;		-- clock
		srst_i	: in std_logic;		-- reset sincronico
		arst_i	: in std_logic;		-- reset asincronico
		ena_i	: in std_logic;		-- habilitador
		d_i		: in std_logic_vector(N-1 downto 0);		-- dato de entrada
		q_o		: out std_logic_vector(N-1 downto 0)		-- dato de salida
	);
end component register_N;

begin

end Behavioral;
