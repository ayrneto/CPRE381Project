library IEEE;
use IEEE.std_logic_1164.all;
-- Ayr Nasser Neto

entity ForwardingUnit is
    port(ID_EX_rs1	: in std_logic_vector(4 downto 0);
	 ID_EX_rs2	: in std_logic_vector(4 downto 0);
	 EX_Mem_rd	: in std_logic_vector(4 downto 0);
	 EX_Mem_RegWrite : in std_logic;
	 Mem_WB_rd	: in std_logic_vector(4 downto 0);
	 Mem_WB_RegWrite : in std_logic;
	 
	 ForwardA	: out std_logic_vector(1 downto 0);
	 ForwardB	: out std_logic_vector(1 downto 0));
end ForwardingUnit;

architecture Behavioral of ForwardingUnit is
begin
    process(ID_EX_rs1, ID_EX_rs2, EX_Mem_rd, EX_Mem_RegWrite, Mem_WB_rd, Mem_WB_RegWrite)
    begin
	ForwardA <= "00";
	ForwardB <= "00";

	-- ForwardA
	if(EX_Mem_RegWrite ='1' AND EX_Mem_rd /= "00000" AND EX_Mem_rd = ID_EX_rs1) then
	    ForwardA <= "10";
	
	elsif(Mem_WB_RegWrite ='1' AND Mem_WB_rd /= "00000" AND Mem_WB_rd = ID_EX_rs1) then
	    ForwardA <= "01";

	end if;

	-- ForwardB
	if(EX_Mem_RegWrite = '1' AND EX_Mem_rd /= "00000" AND EX_Mem_rd = ID_EX_rs2) then
	    ForwardB <= "10";

	elsif(Mem_WB_RegWrite = '1' AND Mem_WB_rd /= "00000" AND Mem_WB_rd = ID_EX_rs2) then
	    ForwardB <= "01";

	end if;
    end process;
end Behavioral;