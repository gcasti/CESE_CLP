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
				rst_sys_i	: in  STD_LOGIC;	-- Reset del sistema
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
type state_type is (IDLE, LOAD_SHIFT, DATA_TRANSFER, END_TRANSFER);
signal state_reg, state_next : state_type; 

--constant N : natural := natural(ceil(log2(real(MOD_MAX))));						-- Cantidad de bits del contador seg�n MOD_MAX
--signal count, count_next : stad_logic_vector(N-1 downto 0) := (others => '0');

signal load_tx_s , load_rx_s : std_logic;
signal data_tx_s , data_rx_s : std_logic_vector(DATA_LENGTH-1 downto 0);
signal shift_enable_s , load_shift_s : std_logic;
signal sclk_enable_s : std_logic;
signal time_out_s : std_logic;

begin

prueba: genTimeOut
	generic map( TIMEOUT => 1.0e-6 ,	-- TIMEOUT
				  Tclk 	 => 50.0e-9	-- Periodo del reloj
				)
PORT MAP (
	clk => clk_sys_i,
	reset => rst_sys_i,
	enable => sclk_enable_s,
	time_out => time_out_s
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
		clk_i 		=> clk_sys_i,
		rst_i 		=> rst_sys_i,
		shift_en_i  => shift_enable_s,
		load_i 		=> load_shift_s,
		data_reg_i 	=> data_tx_s,
		data_reg_o 	=> data_rx_s,
		Din_i			=> MISO_I,
		Dout_o 		=> MOSI_O
		);

sclk_gen: div_frec_M
	port map (
		clk_in 	=> clk_sys_i,
		enable 	=> sclk_enable_s,
		reset 	=> rst_sys_i,
		clk_out 	=> SLCK_O
	);

control: process(state_reg, start_i,time_out_s)
begin
	state_next <= state_reg;
	load_rx_s <= '0';
	load_tx_s <= '0';
	load_shift_s <= '0';
	shift_enable_s <= '0';
	sclk_enable_s <= '0';
	
	case state_reg is
		when IDLE =>
			if start_i = '1' then
				state_next <= LOAD_SHIFT;
				load_tx_s <= '1';				
			end if;
		
		when LOAD_SHIFT =>
			load_shift_s <= '1';
			state_next <= DATA_TRANSFER;
			
		when DATA_TRANSFER =>
			shift_enable_s <= '1';
			sclk_enable_s <= '1';
			if time_out_s = '1' then 
				state_next <= END_TRANSFER;
			end if;
			
		when END_TRANSFER =>
			state_next <= IDLE;
			load_rx_s <= '1';
			
		when others =>
			state_next <= IDLE;
		
	end case;	
end process control;

reloj: process(clk_sys_i)
begin
	if rising_edge(clk_sys_i) then
		state_reg <= state_next;
	end if;		
end process reloj;

end Behavioral;
