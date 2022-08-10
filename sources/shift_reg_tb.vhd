-------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:36:51 05/23/2018
-- Design Name:   
-- Module Name:   
-- Project Name:  
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
--
--------------------------------------------------------------------------------

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY shift_reg_tb IS
END shift_reg_tb;

ARCHITECTURE shift_reg_arch OF shift_reg_tb IS
	constant LENGTH : integer := 8;
	-- Component Declaration for the Unit Under Test (UUT)
	component shift_reg is
		generic(
			LENGTH: integer := 8
		);
		port(
			clk_i     		: in    std_logic;    -- Reloj del sistema
			rst_i      		: in    std_logic;    -- Señal de reset sincronica
			shift_en_i 	    : in    std_logic;    -- Señal que habilita el desplazamiento de datos 
			load_i          : in    std_logic;    -- Señal de carga del registro     
			data_reg_i      : in    std_logic_vector(LENGTH-1 downto 0);   -- Bus de datos para carga del registro
			data_reg_o		: out   std_logic_vector(LENGTH-1 downto 0);   -- Bus de datos para lectura del registro
			Din_i		    : in    std_logic;    -- Dato de entrada del registro de desplazamiento
			Dout_o          : out   std_logic     -- Dato de salida del registro de desplazamiento
		);
	end component shift_reg;
 
	-- constants                                                 
	-- Inputs                                                   
	signal clk_i 		: STD_LOGIC := '0';
	signal rst_i 		: STD_LOGIC := '0';
	signal shift_en_i   : STD_LOGIC := '0';
	signal load_i		: std_logic := '0';
	signal data_reg_i   : std_logic_vector(LENGTH-1 downto 0);
	signal Din_i		: std_logic := '0';

	-- Outputs
	signal Dout_o 	  : std_logic; 
	signal data_reg_o : std_logic_vector(LENGTH-1 downto 0);
	
	-- Clock period definitions
   constant clk_period : time := 20 ns;
	--constant length : integer := 8;	
begin
	-- Instantiate the Unit Under Test (UUT)
	
	uut : shift_reg
	port map (
	-- list connections between master ports and signals
		clk_i => clk_i,
		rst_i => rst_i,
		shift_en_i => shift_en_i,
		load_i => load_i,
		data_reg_i => data_reg_i,
		data_reg_o => data_reg_o,
		Din_i => Din_i,
		Dout_o => Dout_o	
		);
		
	-- Clock process definitions
   clk_process :process
   begin
		clk_i <= '0';
		wait for clk_period/2;
		clk_i <= '1';
		wait for clk_period/2;
   end process;
		
	init : process                                               
	-- variable declarations                                     
	begin                                                        
			  -- code that executes only once                      
	wait;                                                       
	end process init;                                           

   -- Stimulus process
	stim_proc : process                                              
	-- optional sensitivity list                                  
	-- (        )                                                 
	-- variable declarations                                      
	begin                                                         
		-- code executes for every event on sensitivity list  
     -- hold reset state for 10 ns.
      wait for 10 ns;	

      
      -- insert stimulus here
		
	 	data_reg_i <= "11100110";
	 	load_i <= '1';
		wait for clk_period;
		load_i <= '0';
		
		Din_i <= '1';
		wait for 5 ns;
		shift_en_i <= '1';
		wait for 5*clk_period;

		Din_i <= '0';		
		shift_en_i <= '0';
		wait for clk_period;
		shift_en_i <= '1';

		wait for clk_period;

--		reset <= '1';
--		wait for clk_period;
--		reset <= '0';

		
	wait;                                                        
	end process stim_proc;                                          
end shift_reg_arch;
