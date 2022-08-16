library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_N is
    generic(
            N: natural := 8        
        );    
    port (
            clk_sys_i	 : in std_logic;
            rst_sys_i    : in std_logic;
            load_value_i : in std_logic;
            init_value_i : in std_logic_vector(N-1 downto 0);
            enable_i     : in std_logic;
            count_o      : out std_logic_vector(N-1 downto 0)
        );
end counter_N;

architecture behavioral of counter_N is
begin
    process(clk_sys_i, rst_sys_i)
        variable count_i : unsigned(N-1 downto 0);
    begin
        if (rising_edge(clk_sys_i)) then
            if (rst_sys_i ='1') then
                count_i := (others => '0');
            elsif (load_value_i = '1') then
                count_i := unsigned(init_value_i);
            elsif enable_i = '1' then
                count_i := count_i + 1;
            end if;
        end if;
        count_o <= std_logic_vector(count_i);
    end process;
end architecture;