library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardMuxB is
    port(ReadData2	: in std_logic_vector(31 downto 0);
	 Mem_WB_Data	: in std_logic_vector(31 downto 0);
	 EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
	 Sel		: in std_logic_vector(1 downto 0);
	 
	 ALU_InputB	: out std_logic_vector(31 downto 0));
end ForwardMuxB;

architecture Behavioral of ForwardMuxB is
begin
    process(ReadData2, Mem_WB_Data, EX_Mem_ALUResult, Sel)
    begin
	case Sel is
	    when "00" =>
		ALU_InputB <= ReadData2;
	    when "01" =>
		ALU_InputB <= Mem_WB_Data;
	    when "10" =>
		ALU_InputB <= EX_Mem_ALUResult;
	    when others =>
		ALU_InputB <= ReadData2;

	end case;
    end process;
end Behavioral;