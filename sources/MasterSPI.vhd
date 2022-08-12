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
use IEEE.math_real.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_arith.all;



entity MasterSPI is
	 generic ( 	DATA_LENGTH 		: integer	:= 8;			-- Cantidad de bits del modulo
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
end MasterSPI;

architecture Behavioral of MasterSPI is

--component div_frec_M
--	generic ( frec_in : REAL := 5000000.0; frec_out : REAL := 1000000.0 );
--	port
--	(
--		clk_in	: in std_logic;
--		enable	: in std_logic;
--		reset	: in std_logic;
--		clk_out	: out std_logic
--	);
--end component;

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
		Din_i			: in    std_logic;    -- Dato de entrada del registro de desplazamiento
    	Dout_o      : out   std_logic     -- Dato de salida del registro de desplazamiento       	
	);
end component shift_reg;

component register_N is
	generic(
		N: natural := DATA_LENGTH
	);
	port(
		clk_i		: in std_logic;		-- clock
		srst_i	: in std_logic;		-- reset sincronico
		arst_i	: in std_logic;		-- reset asincronico
		ena_i		: in std_logic;		-- habilitador
		d_i		: in std_logic_vector(N-1 downto 0);		-- dato de entrada
		q_o		: out std_logic_vector(N-1 downto 0)		-- dato de salida
	);
end component register_N;

component genTimeOut
	generic ( TIMEOUT : real := 100.0e-9 ;	-- TIMEOUT
				  Tclk 	 :	real := 10.0e-9	-- Periodo del reloj
				);	
	port(
		clk : IN  std_logic;
		reset : IN  std_logic;
		enable : IN  std_logic;
		time_out : OUT  std_logic
	);
end component;

-- Se�ales
type state_type is (IDLE, TIME_SETUP, DATA_TRANSFER, TIME_HOLD);
signal state_reg, state_next : state_type; 

constant N : natural := 8; -- Cantidad de bits del contador seg�n MOD_MAX
constant MOD_NBITS : STD_LOGIC_VECTOR(N-1 downto 0) := CONV_STD_LOGIC_VECTOR(8,N);


signal count, count_next : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
signal load_tx_s , load_rx_s : std_logic;
signal data_tx_s , data_rx_s : std_logic_vector(DATA_LENGTH-1 downto 0);
signal sclk_s, sclk_enable_s : std_logic;
signal enable_setup_s , enable_hold_s : std_logic;
signal timeout_setup_s , timeout_hold_s : std_logic;
signal cs_reg , cs_next : std_logic;

begin

-- Temporizador para implementar el tiempo de setup
Inst_time_setup: genTimeOut
	generic map( 
		TIMEOUT => 100.0e-9 ,	-- Tiempo de setup
		Tclk 	 => 20.0e-9			-- Periodo del reloj de sincronismo
	)
	PORT MAP (
		clk 		=> clk_sys_i,
		reset 	=> rst_sys_i,
		enable 	=> enable_setup_s,
		time_out => timeout_setup_s
	);

-- Temporizador para implementar el tiempo de hold
Inst_time_hold : genTimeOut
	generic map( 
		TIMEOUT => 150.0e-9 ,	-- Tiempo de setup
		Tclk 	 => 20.0e-9			-- Periodo del reloj de sincronismo
	)
	PORT MAP (
		clk 		=> clk_sys_i,
		reset 	=> rst_sys_i,
		enable 	=> enable_hold_s,
		time_out => timeout_hold_s
	);	


-- Registro que almacena el dato a transmitir
register_TX: register_N
	generic map(
		N => DATA_LENGTH
	)
	port map(
		clk_i		=> clk_sys_i,
		srst_i	=>	rst_sys_i,
		arst_i 	=> '0',
		ena_i		=> data_wr_i,
		d_i		=> data_tx_i,
		q_o		=> data_tx_s
	);

-- Registro que almacena el dato recibido
register_RX: register_N
	generic map(
		N => DATA_LENGTH
	)
	port map(
		clk_i		=> clk_sys_i,
		srst_i	=>	rst_sys_i,
		arst_i 	=> '0',
		ena_i		=> load_rx_s,
		d_i		=> data_rx_s,
		q_o		=> data_rx_o
	);

shift_register : shift_reg
	port map (
		clk_i 		=> sclk_s,
		rst_i 		=> rst_sys_i,
		shift_en_i  => '1',
		load_i 		=> load_tx_s,
		data_reg_i 	=> data_tx_s,
		data_reg_o 	=> data_rx_s,
		Din_i			=> MISO_I,
		Dout_o 		=> MOSI_O
		);
sclk_s <= clk_sys_i and sclk_enable_s;

control: process(state_reg, start_i, cs_reg,timeout_setup_s,timeout_hold_s,count )
begin
	state_next <= state_reg;
	cs_next <= cs_reg;
	count_next <= count;
	load_rx_s <= '0';
	load_tx_s <= '0';
	sclk_enable_s <= '0';
	enable_setup_s <= '0';
	enable_hold_s <= '0';
		
	case state_reg is
		when IDLE =>
			if start_i = '1' then
				state_next <= TIME_SETUP;
				load_tx_s <= '1';
				cs_next <= '0';				
			end if;
		
		when TIME_SETUP => 
			enable_setup_s <= '1';
			if timeout_setup_s = '1' then
				state_next <= DATA_TRANSFER;
			end if;
			
		when DATA_TRANSFER =>
			sclk_enable_s <= '1';
			count_next <= count + 1 ;
			if count = MOD_NBITS then 
				load_rx_s <= '1';
				state_next <= TIME_HOLD;
			end if;
			
		when TIME_HOLD =>
			enable_hold_s <= '1';
			if timeout_hold_s = '1' then
				cs_next <= '1';
				state_next <= IDLE;
			end if;
			
		when others =>
			state_next <= IDLE;
		
	end case;	
end process control;

reloj: process(clk_sys_i)
begin
	if rising_edge(clk_sys_i) then
		state_reg <= state_next;
		cs_reg <= cs_next;
		count <= count_next;
	end if;		
end process reloj;

CS_O <= cs_reg;
SCLK_O <= sclk_s;

end Behavioral;
