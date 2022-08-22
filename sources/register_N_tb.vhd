library IEEE;
use IEEE.std_logic_1164.all;


entity register_N_tb is
end;

architecture register_N_tb_arq of register_N_tb is

	-- Declaracion de componente
	component register_N is
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
	end component;	
	
	constant N_tb: natural := 5;
	
	-- Inputs    
	signal clk_sys_i	: std_logic := '0';
	signal rst_sys_i	: std_logic := '0';
	signal arst_sys_i	: std_logic := '0';
	signal enable_i		: std_logic := '0';
	signal data_i		: std_logic_vector(N_tb-1 downto 0) := "00111";

	-- Outputs
	signal data_o: std_logic_vector(N_tb-1 downto 0);
	
	-- constants                                                 
	-- Clock period definitions
	constant clk_period : time := 20 ns;
		
begin
	-- Instantiate the Unit Under Test (UUT)
	
	uut : register_N
	generic map(
		N => N_tb
		)
		port map(
			clk_sys_i 	=> clk_sys_i,
			rst_sys_i 	=> rst_sys_i,
			arst_sys_i	=> arst_sys_i,
			enable_i	=> enable_i,
			data_i		=> data_i,
			data_o		=> data_o
		);

	-- Clock process definitions
	clk_process :process
	begin
		 clk_sys_i <= '0';
		 wait for clk_period/2;
		 clk_sys_i <= '1';
		 wait for clk_period/2;
	end process;

	init : process                                               
	-- variable declarations                                     
	begin                                                        
		  -- code that executes only once                      
	wait;                                                       
	end process init;     

	stim_proc : process                                              
	begin 
	wait for 50 ns;	
		
	rst_sys_i <= '1';
    wait for clk_period;
	rst_sys_i <= '0';
      
	wait for clk_period;
    -- insert stimulus here
		
	enable_i <= '1';
    wait for clk_period;
	enable_i <= '0';
		
    wait for 4*clk_period;
	arst_sys_i <= '1';
	wait for 5*clk_period;
	arst_sys_i <= '0';
	

	end process stim_proc; 
end register_N_tb_arq;