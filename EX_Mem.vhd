library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity EX_Mem is
    port(i_CLK		: in std_logic;
	 i_RST		: in std_logic;
	 i_ALUResult	: in std_logic_vector(31 downto 0);
	 i_ForwardMux	: in std_logic_vector(31 downto 0); -- (Could contain ReadData2)
	 i_rd		: in std_logic_vector(4 downto 0);
	 -- i_control signals

	 -- o_control signals
	 o_ALUResult	: out std_logic_vector(31 downto 0);
	 o_ForwardMux	: out std_logic_vector(31 downto 0);
	 o_rd		: out std_logic_vector(4 downto 0));
	 
end EX_Mem;

architecture behavioral of EX_Mem is 
    begin
	process(i_CLK, i_RST)
	    begin
		if rising_edge(i_CLK) then
		    if i_RST = '1' then
			o_ALUResult <= (others => '0');
			o_ForwardMux <= (others => '0');
			o_rd <= (others => '0');

		    else
			o_ALUResult <= o_ALUResult;
			o_ForwardMux <= i_ForwardMux;
			o_rd <= i_rd;

		    end if;
		end if;
	end process;
end behavioral;