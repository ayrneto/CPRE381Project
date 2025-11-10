library IEEE;
use IEEE.std_logic_1164.all;

-- Generic-width register with synchronous reset and write enable
entity NBitRegister is
    generic(N : integer := 32);
    port(
        i_CLK : in std_logic;
        i_RST : in std_logic;
        i_WE  : in std_logic;
        i_D   : in std_logic_vector(N-1 downto 0);
        o_Q   : out std_logic_vector(N-1 downto 0)
    );
end NBitRegister;

architecture rtl of NBitRegister is
    signal s_Q : std_logic_vector(N-1 downto 0) := (others => '0');
begin
    process(i_CLK)
    begin
        if rising_edge(i_CLK) then
            if i_RST = '1' then
                s_Q <= (others => '0');
            elsif i_WE = '1' then
                s_Q <= i_D;
            end if;
        end if;
    end process;

    o_Q <= s_Q;
end rtl;
