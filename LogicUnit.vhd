library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
-- Unit inside the ALU. 0000 = AND, 0001 = OR, 0011 = XOR, 1100 = NOR
entity LogicUnit is
    port(i_A	: in std_logic_vector(31 downto 0);
	 i_B	: in std_logic_vector(31 downto 0);
	 i_Sel	: in std_logic_vector(1 downto 0);
	 o_Out	: out std_logic_vector(31 downto 0));
end LogicUnit;

architecture behavioral of LogicUnit is
    begin
	process(i_Sel, i_A, i_B)
	  begin
	    if i_Sel = "00" then
		o_Out <= (i_A AND i_B);
	
	    elsif i_Sel = "01" then
		o_Out <= (i_A OR i_B);

	    elsif i_Sel = "10" then
		o_Out <= (i_A XOR i_B);

    	    else
		o_Out <= (i_A NOR i_B);

	    end if;

	end process;
end behavioral;