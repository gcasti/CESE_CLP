--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:50:31 05/16/2018
-- Design Name:   
-- Module Name:   D:/Desarrollos_VHDL/Componentes/div_frec_M/div_frec_M_TB.vhd
-- Project Name:  div_frec_M
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: div_frec_M
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
 
ENTITY div_frec_M_TB IS
END div_frec_M_TB;
 
ARCHITECTURE behavior OF div_frec_M_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT div_frec_M
    PORT(
         clk_in : IN  std_logic;
         enable : IN  std_logic;
         reset : IN  std_logic;
         clk_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal enable : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal clk_out : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 20 ns;
  
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: div_frec_M PORT MAP (
          clk_in => clk_in,
          enable => enable,
          reset => reset,
          clk_out => clk_out
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_in_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
