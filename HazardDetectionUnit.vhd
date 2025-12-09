library IEEE;
use IEEE.std_logic_1164.all;
-- Ayr Nasser Neto

entity HazardDetectionUnit is
    port(ID_EX_MemRead	: in std_logic;
	 ID_EX_rd	: in std_logic_vector(4 downto 0);
	 IF_ID_rs1	: in std_logic_vector(4 downto 0);
	 IF_ID_rs2	: in std_logic_vector(4 downto 0);
	 
	 PCWrite	: out std_logic;
	 IF_ID_Write	: out std_logic;
	 FlushMux_Sel	: out std_logic);
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is
begin
    process(ID_EX_MemRead, ID_EX_rd, IF_ID_rs1, IF_ID_rs2)
    begin
	PCWrite <= '1';
	IF_ID_Write <= '1';
	FlushMux_Sel <= '0';

	if(ID_EX_MemRead = '1' AND (ID_EX_rd = IF_ID_rs1 OR ID_EX_rd = IF_ID_rs2) AND ID_EX_rd /= "00000") then
	-- If MemRead is 1, Writing register is same as Reading register, and Writing reg isn't x0
	    PCWrite <= '0';
	    IF_ID_Write <= '0';
	    FlushMux_Sel <= '1';
	end if;
    end process;
end Behavioral;