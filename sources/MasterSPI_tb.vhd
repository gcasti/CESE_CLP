--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:26:55 08/11/2022
-- Design Name:   
-- Module Name:   C:/Users/Guillermo/Documents/MasterSPI/MasterSPI/MasterSPI_tb.vhd
-- Project Name:  MasterSPI
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MasterSPI
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY MasterSPI_tb IS
END MasterSPI_tb;
 
ARCHITECTURE behavior OF MasterSPI_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MasterSPI
    PORT(
         clk_sys_i : IN  std_logic;
         rst_sys_i : IN  std_logic;
         SCLK_O : OUT  std_logic;
         MOSI_O : OUT  std_logic;
         MISO_I : IN  std_logic;
         CS_O : OUT  std_logic;
         start_i : IN  std_logic;
         data_rd_o : OUT  std_logic;
         data_wr_i : IN  std_logic;
         data_tx_i : IN  std_logic_vector(7 downto 0);
         data_rx_o : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_sys_i : std_logic := '0';
   signal rst_sys_i : std_logic := '0';
   signal MISO_I : std_logic := '0';
   signal start_i : std_logic := '0';
   signal data_wr_i : std_logic := '0';
   signal data_tx_i : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal SCLK_O : std_logic;
   signal MOSI_O : std_logic;
   signal CS_O : std_logic;
   signal data_rd_o : std_logic;
   signal data_rx_o : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_sys_i_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MasterSPI PORT MAP (
          clk_sys_i => clk_sys_i,
          rst_sys_i => rst_sys_i,
          SCLK_O => SCLK_O,
          MOSI_O => MOSI_O,
          MISO_I => MISO_I,
          CS_O => CS_O,
          start_i => start_i,
          data_rd_o => data_rd_o,
          data_wr_i => data_wr_i,
          data_tx_i => data_tx_i,
          data_rx_o => data_rx_o
        );

   -- Clock process definitions
   clk_sys_i_process :process
   begin
		clk_sys_i <= '0';
		wait for clk_sys_i_period/2;
		clk_sys_i <= '1';
		wait for clk_sys_i_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_sys_i_period*10;
		
		data_tx_i <= "00101101";
		data_wr_i <= '1';
		wait for clk_sys_i_period;
		data_wr_i <= '0';
		
      -- insert stimulus here 
		start_i <= '1';
		wait for clk_sys_i_period;
		start_i <= '0';
		

      wait;
   end process;

END;
