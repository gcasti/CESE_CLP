--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:36:51 05/23/2018
-- Design Name:   
-- Module Name:   D:/Desarrollos_VHDL/Componentes/genTimeOut/genTimeOut_TB.vhd
-- Project Name:  genTimeOut
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: genTimeOut
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
 
ENTITY genTimeOut_TB IS
END genTimeOut_TB;
 
ARCHITECTURE behavior OF genTimeOut_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT genTimeOut
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         time_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';

 	--Outputs
   signal time_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: genTimeOut PORT MAP (
          clk => clk,
          reset => reset,
          enable => enable,
          time_out => time_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		enable <= '1';
		wait for 202 ns;
		reset <= '1';
		wait for clk_period;
		reset <= '0';

      wait;
   end process;

END;
