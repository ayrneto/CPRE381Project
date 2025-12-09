library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardMuxA is
    port(ReadData1	: in std_logic_vector(31 downto 0);
	 Mem_WB_Data	: in std_logic_vector(31 downto 0);
	 EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
	 Sel		: in std_logic_vector(1 downto 0);
	 
	 ALU_InputA	: out std_logic_vector(31 downto 0));
end ForwardMuxA;

architecture Behavioral of ForwardMuxA is
begin
    process(ReadData1, Mem_WB_Data, EX_Mem_ALUResult, Sel)
    begin
	case Sel is
	    when "00" =>
		ALU_InputA <= ReadData1;
	    when "01" =>
		ALU_InputA <= Mem_WB_Data;
	    when "10" =>
		ALU_InputA <= EX_Mem_ALUResult;
	    when others =>
		ALU_InputA <= ReadData1;

	end case;
    end process;
end Behavioral;