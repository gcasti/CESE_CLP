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
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
--use IEEE.math_real.all;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use IEEE.std_logic_arith.all;



entity MasterSPI is
	 generic ( 
				DATA_LENGTH 		: integer	:= 8;			-- Cantidad de bits del modulo
				CLK_SYS_PERIOD		: real		:= 20.0e-9;
				SET_TIME_HOLD		: real		:= 0.5e-6;
				SET_TIME_SETUP		: real		:= 1.0e-6
				);	
    port ( -- Señales de sincronismo
				clk_sys_i	: in  STD_LOGIC;		-- Reloj de sincronismo del sistema
				rst_sys_i	: in  STD_LOGIC;		-- Reset del sistema
				arst_sys_i	: in 	STD_logic;
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


component shift_reg_piso is
	generic(
		N: integer := DATA_LENGTH
	);
	port(
		clk_i     	: in	std_logic;	-- Reloj del sistema
		rst_i     	: in  std_logic;  -- Señal de reset sincronica
		arst_i		: in	std_logic;  -- Señal de reset asincrónica
		shift_en_i	: in 	std_logic;  -- Señal que habilita el desplazamiento de datos 
		load_i		: in	std_logic;	-- Carga del registro de desplamiento
		dout_o		: out	std_logic;	-- Dato de salida del registro de desplazamiento
		data_reg_i	: in	std_logic_vector(N-1 downto 0)    -- Bus de datos para carga del registro
	);
end component shift_reg_piso;

component shift_reg_sipo is
	generic(
		N: integer := DATA_LENGTH
	);
	port(
		clk_i     	: in	std_logic;	-- Reloj del sistema
		rst_i     	: in  	std_logic;  -- Señal de reset sincronica
		arst_i		: in	std_logic;  -- Señal de reset asincrónica
		shift_en_i	: in  	std_logic;  -- Señal que habilita el desplazamiento de datos 
		din_i		: in  	std_logic; 			   			-- Dato de entrada del registro de desplazamiento
		data_reg_o	: out	std_logic_vector(N-1 downto 0)    -- Bus de datos para lectura del registro
	);
end component shift_reg_sipo;

component register_N is
	generic(
		N: natural := DATA_LENGTH
	);
	port(
		clk_sys_i	: in std_logic;		-- Reloj de sincronismo
		rst_sys_i	: in std_logic;		-- Reset sincronico del modulo
		arst_sys_i	: in std_logic;		-- Reset asincronico del modulo
		enable_i	: in std_logic;		-- Carga el valor del bus de entrada
		data_i		: in std_logic_vector(N-1 downto 0);	-- Dato de entrada
		data_o		: out std_logic_vector(N-1 downto 0)	-- Dato de salida
	);
end component register_N;

component genTimeOut
	generic ( 
		TIMEOUT : real := 100.0e-9 ;	-- TIMEOUT
		Tclk 	 :	real := 10.0e-9	-- Periodo del reloj
		);	
	port(
		clk : IN  std_logic;
		reset : IN  std_logic;
		enable : IN  std_logic;
		time_out : OUT  std_logic
	);
end component;

component counter_N is
	generic(
		N: natural := 8        
	);    
	port (
		clk_sys_i	 : in std_logic;
		rst_sys_i    : in std_logic;
		arst_sys_i	 : in std_logic;
		load_value_i : in std_logic;
		init_value_i : in std_logic_vector(N-1 downto 0);
		enable_i     : in std_logic;
		count_o      : out std_logic_vector(N-1 downto 0)
	);
end component;

-- Se�ales
type state_type is (IDLE, TIME_SETUP, DATA_TRANSFER, TIME_HOLD);
signal state_reg, state_next : state_type; 

-- calculo de la cantidad de flancos a contar
constant N_BITS_COUNTER : integer:= integer(ceil(log2(real(DATA_LENGTH))));	--Cantidad de bits del contador 
constant MOD_EDGE_COUNT : STD_LOGIC_VECTOR(N_BITS_COUNTER-1 downto 0) := std_logic_vector(to_unsigned(DATA_LENGTH-1,N_BITS_COUNTER));

signal counter_value_s : STD_LOGIC_VECTOR(N_BITS_COUNTER-1 downto 0):= (others=>'0');
signal load_tx_s , load_rx_s : std_logic := '0';
signal data_tx_s , data_rx_s : std_logic_vector(DATA_LENGTH-1 downto 0) := (others=>'0');
signal sclk_s, sclk_enable_s : std_logic := '0';
signal enable_setup_s , enable_hold_s : std_logic := '0';
signal timeout_setup_s , timeout_hold_s : std_logic := '0';
signal cs_reg , cs_next : std_logic := '1';
signal shift_en_s : std_logic := '0';
signal load_cout_s , rst_count_s , enable_count_s, rst_timer_s : std_logic;


begin


-- M�quina de estados para coordinaci�n
control: process(state_reg, start_i, cs_reg,timeout_setup_s,timeout_hold_s ,counter_value_s)

begin
	state_next <= state_reg;
	cs_next <= cs_reg;
	load_rx_s <= '0';
	load_tx_s <= '0';
	sclk_enable_s <= '0';
	enable_setup_s <= '0';
	enable_hold_s <= '0';
	shift_en_s <= '0';
	data_rd_o <= '0';
	enable_count_s <= '0';
	rst_count_s <= '0';
	rst_timer_s <= '0';
	load_cout_s <='0';
		
	case state_reg is
		when IDLE =>
			if start_i = '1' then
				state_next <= TIME_SETUP;
				load_tx_s <= '1';
				cs_next <= '0';
				rst_timer_s <= '1';				
			end if;
		
		when TIME_SETUP => 
			enable_setup_s <= '1';
			if timeout_setup_s = '1' then
				state_next <= DATA_TRANSFER;
				load_tx_s <= '1';
				rst_count_s <= '1';
				load_cout_s <= '1';
			end if;
			
		when DATA_TRANSFER =>
			sclk_enable_s <= '1';
			shift_en_s <= '1';
			enable_count_s <= '1';
			if counter_value_s = MOD_EDGE_COUNT then 
				load_rx_s <= '1';
				state_next <= TIME_HOLD;
			end if;
			
		when TIME_HOLD =>
			enable_hold_s <= '1';
			if timeout_hold_s = '1' then
				cs_next <= '1';
				data_rd_o <= '1';		
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
	end if;		
end process reloj;

-- Temporizador para implementar el tiempo de setup
Inst_time_setup: genTimeOut
	generic map( 
		TIMEOUT => SET_TIME_HOLD ,	-- Tiempo de setup
		Tclk 	 => CLK_SYS_PERIOD			-- Periodo del reloj de sincronismo
	)
	port map (
		clk 	=> clk_sys_i,
		reset 	=> rst_timer_s,
		enable 	=> enable_setup_s,
		time_out => timeout_setup_s
	);

-- Temporizador para implementar el tiempo de hold
Inst_time_hold : genTimeOut
	generic map( 
		TIMEOUT => SET_TIME_SETUP,	-- Tiempo de setup
		Tclk 	 => CLK_SYS_PERIOD			-- Periodo del reloj de sincronismo
	)
	port map (
		clk 	=> clk_sys_i,
		reset 	=> rst_timer_s,
		enable 	=> enable_hold_s,
		time_out => timeout_hold_s
	);	

-- Registro que almacena el dato a transmitir
Inst_TX_register: register_N
	generic map (
		N => DATA_LENGTH
	)
	port map (
		clk_sys_i 	=> clk_sys_i,
		rst_sys_i 	=> rst_sys_i,
		arst_sys_i	=> arst_sys_i,
		enable_i	=> data_wr_i,
		data_i		=> data_tx_i,
		data_o		=> data_tx_s
	);
-- Registro de desplazamiento de transmisión
Inst_TX_shift_register : shift_reg_piso
	generic map (
		N => DATA_LENGTH
	)
	port map (
		clk_i		=> clk_sys_i,
		rst_i		=> rst_sys_i,
		arst_i		=> arst_sys_i,
		shift_en_i 	=> shift_en_s,
		load_i		=> load_tx_s,
		dout_o		=> MOSI_O,
		data_reg_i	=> data_tx_s
	);

-- Registro que almacena el dato recibido
Inst_RX_register: register_N
	generic map (
		N => DATA_LENGTH
	)
	port map
	(
		clk_sys_i	=> clk_sys_i,
		rst_sys_i	=> rst_sys_i,
		arst_sys_i	=> arst_sys_i,
		enable_i	=> load_rx_s,
		data_i		=> data_rx_s,
		data_o		=> data_rx_o
	);

-- Registro de desplazamiento de recepci�n
Inst_RX_shift_register : shift_reg_sipo
	generic map (
		N => DATA_LENGTH
	)	
	port map (
		clk_i 		=> clk_sys_i,
		rst_i 		=> rst_sys_i,
		arst_i 		=> arst_sys_i,
		shift_en_i 	=> shift_en_s,
		data_reg_o	=> data_rx_s,
		din_i 		=> MISO_I
	);

Inst_counter : counter_N
generic map(
		N => N_BITS_COUNTER       
	)   
	port map(
		clk_sys_i	 => clk_sys_i,	
		rst_sys_i    => rst_count_s,
		arst_sys_i 	 => arst_sys_i,
		load_value_i => load_cout_s,
		init_value_i => (others => '0'),
		enable_i     => enable_count_s,
		count_o      => counter_value_s
	);

sclk_s <= clk_sys_i and sclk_enable_s;

CS_O <= cs_reg;
SCLK_O <= sclk_s;

end Behavioral;
