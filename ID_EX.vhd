library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity ID_EX is
    port(i_CLK	: in std_logic;
	 i_RST	: in std_logic;
	 i_rd	: in std_logic_vector(4 downto 0);
	 i_rs1	: in std_logic_vector(4 downto 0);
	 i_rs2	: in std_logic_vector(4 downto 0);
	 i_ReadData1	: std_logic_vector(31 downto 0);
	 i_ReadData2	: std_logic_vector(31 downto 0);
	 i_PC	: in std_logic_vector(31 downto 0);
	 i_imm	: in std_logic_vector(31 downto 0);
	 -- i_control signals

	 -- o_control signals
	 o_imm	: out std_logic_vector(31 downto 0);
	 o_PC	: out std_logic_vector(31 downto 0);
	 o_ReadData1	: out std_logic_vector(31 downto 0);
	 o_ReadData2	: out std_logic_vector(31 downto 0);
	 o_rs1	: out std_logic_vector(4 downto 0);
	 o_rs2	: out std_logic_vector(4 downto 0);
	 o_rd	: out std_logic_vector(4 downto 0));
end ID_EX;

architecture behavioral of ID_EX is 
    begin
	process(i_CLK, i_RST)
	    begin
		if rising_edge(i_CLK) then
		    if i_RST = '1' then
			o_imm <= (others => '0');
			o_PC <= (others => '0');
			o_ReadData1 <= (others => '0');
			o_ReadData2 <= (others => '0');
			o_rs1 <= (others => '0');
			o_rs2 <= (others => '0');
			o_rd <= (others => '0');

		    else
			o_imm <= i_imm;
			o_PC <= i_PC;
			o_ReadData1 <= i_ReadData1;
			o_ReadData2 <= i_ReadData2;
			o_rs1 <= i_rs1;
			o_rs2 <= i_rs2;
			o_rd <= i_rd;

		    end if;
		end if;
	end process;
end behavioral;