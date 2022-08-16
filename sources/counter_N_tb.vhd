library IEEE;
use IEEE.std_logic_1164.all;


entity counter_N_tb is
end;

architecture counter_N_tb_arq of counter_N_tb is
    constant N : integer := 8;
	-- Declaracion de componente
    component counter_N is
        generic(
                N: natural := 8        
            );    
        port (
                clk_sys_i       : in std_logic;
                rst_sys_i       : in std_logic;
                load_value_i    : in std_logic;
                init_value_i    : in std_logic_vector(N-1 downto 0);
                enable_i        : in std_logic;
                count_o         : out std_logic_vector(N-1 downto 0)
            );
    end component;

-- constants                                                 
	-- Inputs                                                   
	signal clk_sys_i    	: STD_LOGIC := '0';
	signal rst_sys_i 		: STD_LOGIC := '0';
	signal load_value_i	: STD_LOGIC := '0';
   signal enable_i     : std_logic := '0';
	signal init_value_i	: std_logic_vector(N-1 downto 0);
	
	-- Outputs
	signal count_o : std_logic_vector(N-1 downto 0);
	
	-- Clock period definitions
   constant clk_period : time := 20 ns;
		
begin
	-- Instantiate the Unit Under Test (UUT)
	
	uut : counter_N
	port map (
	-- list connections between master ports and signals
			clk_sys_i => clk_sys_i,
			rst_sys_i => rst_sys_i,
			load_value_i => load_value_i,
			enable_i => enable_i,
			init_value_i => init_value_i,
			count_o => count_o
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

   -- Stimulus process
	stim_proc : process                                              
	-- optional sensitivity list                                  
	-- (        )                                                 
	-- variable declarations                                      
	begin                                                         
		-- code executes for every event on sensitivity list  
     -- hold reset state for 10 ns.
     	wait for 50 ns;	
		
		rst_sys_i <= '1';
      wait for clk_period;
		rst_sys_i <= '0';
      
		wait for clk_period;
      -- insert stimulus here
		
	 	init_value_i <= "00100110";
		wait for clk_period;
		load_value_i <= '1';
      wait for clk_period;
		load_value_i <= '0';
		
      wait for 4*clk_period;
		enable_i <= '1';
		wait for 5*clk_period;
		enable_i <= '0';
		wait for 4*clk_period;
		enable_i <= '1';
		
		rst_sys_i <= '1' after 5 ns;
      wait for clk_period;
		rst_sys_i <= '0' after 5 ns;
		
		wait;                                                        
	end process stim_proc;                                          
end counter_N_tb_arq;