library IEEE;
use IEEE.std_logic_1164.all;
-- Ayr Nasser Neto

entity HazardDetectionUnit is
    port(ID_EX_MemRead	: in std_logic;
	 ID_EX_rd	: in std_logic_vector(4 downto 0);
	 IF_ID_rs1	: in std_logic_vector(4 downto 0);
	 IF_ID_rs2	: in std_logic_vector(4 downto 0);
	 ID_Branch	: in std_logic;
	 ID_Jump	: in std_logic;
	 EX_Branch	: in std_logic;
	 
	 PCWrite	: out std_logic;
	 IF_ID_Write	: out std_logic;
	 FlushMux_Sel	: out std_logic;
	 IF_ID_Flush	: out std_logic);
end HazardDetectionUnit;

architecture Behavioral of HazardDetectionUnit is
    signal LoadUseHazard : std_logic;
    signal ControlHazard : std_logic;
begin
    LoadUseHazard <= '1' when (ID_EX_MemRead = '1' AND (ID_EX_rd = IF_ID_rs1 OR ID_EX_rd = IF_ID_rs2) AND ID_EX_rd /= "00000")
			else '0';

    ControlHazard <= '1' when (ID_Branch = '1' AND EX_Branch = '1') OR (ID_Jump = '1')
			else '0';

    process(LoadUseHazard, ControlHazard)
    begin
	PCWrite <= '1';
	IF_ID_Write <= '1';
	FlushMux_Sel <= '0';
	IF_ID_Flush <= '0';

	if(LoadUseHazard = '1') then
	    PCWrite <= '0';
	    IF_ID_Write <= '0';
	    FlushMux_Sel <= '1';
	end if;

	if(ControlHazard = '1') then
	    IF_ID_Flush <= '1';
	    FlushMux_Sel <= '1';
	    PCWrite <= '1';
	    IF_ID_Write <= '1';
	end if;
    end process;
end Behavioral;