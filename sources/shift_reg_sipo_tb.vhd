LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY shift_reg_sipo_tb IS
END shift_reg_sipo_tb;

ARCHITECTURE shift_reg_arch OF shift_reg_sipo_tb IS
	constant N : integer := 8;
	-- Component Declaration for the Unit Under Test (UUT)
	component shift_reg_sipo is
		generic(
			N: integer := 8
		);
	port(
		clk_i     	: in	std_logic;										-- Reloj del sistema
		rst_i     	: in  std_logic;  									-- Se?al de reset sincronica
		arst_i		: in	std_logic;  									-- Se?al de reset asincrónica
		shift_en_i	: in  std_logic;  									-- Se?al que habilita el desplazamiento de datos 
		din_i			: in  std_logic; 			   						-- Dato de entrada del registro de desplazamiento
		data_reg_o	: out	std_logic_vector(N-1 downto 0)    -- Bus de datos para lectura del registro
	);

	end component shift_reg_sipo;
 
	-- constants                                                 
	-- Inputs                                                   
	signal clk_i 		: STD_LOGIC := '0';
	signal rst_i 		: STD_LOGIC := '0';
	signal arst_i 		: STD_LOGIC := '0';
	signal shift_en_i	: STD_LOGIC := '0';
	signal din_i		: std_logic := '0';

	-- Outputs
	signal data_reg_o : std_logic_vector(N-1 downto 0);
	
	-- Clock period definitions
   constant clk_period : time := 20 ns;
	--constant length : integer := 8;	
begin
	-- Instantiate the Unit Under Test (UUT)
	
	uut : shift_reg_sipo
	port map (
	-- list connections between master ports and signals
		clk_i => clk_i,
		rst_i => rst_i,
		arst_i => arst_i,
		shift_en_i => shift_en_i,
		data_reg_o => data_reg_o,
		din_i => Din_i
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
     	wait for 100 ns;	

      
      -- insert stimulus here
		rst_i <= '1';
		wait for clk_period;
		rst_i <= '0';

		wait for 2*clk_period;
		
	 	shift_en_i <= '1';
		din_i <= '1';
		wait for 2*clk_period;
		
		din_i <= '0';		
		
		wait for clk_period;
		shift_en_i <= '1';

		wait for clk_period;


		
	wait;                                                        
	end process stim_proc;                                          
end shift_reg_arch;
