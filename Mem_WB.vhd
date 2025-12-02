library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity Mem_WB is
    port(i_CLK	: in std_logic;
	 i_RST	: in std_logic;
	 i_DMem : in std_logic_vector(31 downto 0);
	 i_ALUResult : in std_logic_vector(31 downto 0);
	 i_rd	: in std_logic_vector(4 downto 0);
	 -- i_control signals

	 -- o_control signals
	 o_DMem : out std_logic_vector(31 downto 0);
	 o_ALUResult : out std_logic_vector(31 downto 0);
	 o_rd	: out std_logic_vector(4 downto 0));
end Mem_WB;

architecture behavioral of Mem_WB is 
    begin
	process(i_CLK, i_RST)
	    begin
		if rising_edge(i_CLK) then
		    if i_RST = '1' then
			o_DMem <= (others => '0');
			o_ALUResult <= (others => '0');
			o_rd <= (others => '0');

		    else
			o_DMem <= i_DMem;
			o_ALUResult <= i_ALUResult;
			o_rd <= i_rd;

		    end if;
		end if;
	end process;
end behavioral;