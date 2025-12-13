library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity IF_ID is
    port(i_CLK	: in std_logic;
	 i_RST	: in std_logic;
	
	 i_Flush : in std_logic;
	 i_Stall : in std_logic;

	 i_PC	: in std_logic_vector(31 downto 0);
	 i_PC4	: in std_logic_vector(31 downto 0);
	 i_inst	: in std_logic_vector(31 downto 0);
	 o_inst	: out std_logic_vector(31 downto 0);
	 o_PC4	: out std_logic_vector(31 downto 0);
	 o_PC	: out std_logic_vector(31 downto 0));
end IF_ID;

architecture behavioral of IF_ID is 
    begin
	process(i_CLK, i_RST)
	    begin
		if i_RST = '1' then
			o_inst <= (others => '0');
			o_PC4 <= (others => '0');
			o_PC <= (others => '0');

		elsif rising_edge(i_CLK) then
		    if i_Flush = '1' then
			o_inst <= (others => '0');
			o_PC4 <= (others => '0');
			o_PC <= (others => '0');

		    elsif i_Stall = '0' then
			o_inst <= i_inst;
			o_PC4 <= i_PC4;
			o_PC <= i_PC;

		    end if;
		end if;
	end process;
end behavioral;