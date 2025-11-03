library IEEE;
use IEEE.std_logic_1164.all;

-- Ayr Nasser Neto
-- Extends immediate to 32b immediate
-- If Sel is 000: I-Type: Inst 31:20 bits = Output 11:0, Sign Extend
-- If Sel is 001: S-Type: Inst 31:25 + 11:7 bits = Output 11:0, Sign Extend
-- If Sel is 010: B-Type: Inst 31 + 7 + 30:25 + 11:8 bits = Output 12:1, Sign Extend, Last bit = 0
-- If Sel is 011: U-Type: Inst 31:12 = Output 31:12, 11:0 Output equals to 0
-- If Sel is 100: J-Type: Inst 31 + 19:12 + 20 + 30:21 = Output 20:1, Sign Extend, Last bit = 0

entity Extender is
    port(i_Inst	: in std_logic_vector(31 downto 0);
	 i_Sel	: in std_logic_vector(2 downto 0);
	 o_Out	: out std_logic_vector(31 downto 0));
end Extender;


architecture dataflow of Extender is
    begin
	process(i_Inst, i_Sel)
	begin

		if i_Sel = "000" then
			o_Out(11 downto 0)	<= i_Inst(31 downto 20);
			o_Out(31 downto 12)	<= (others => i_Inst(31));

		elsif i_Sel = "001" then
			o_Out(11 downto 5)	<= i_Inst(31 downto 25);
			o_Out(4 downto 0)	<= i_Inst(11 downto 7);
			o_Out(31 downto 12)	<= (others => i_Inst(31));

		elsif i_Sel = "010" then
			o_Out(31 downto 12)	<= (others => i_Inst(31));
			o_Out(11)		<= i_Inst(7);
			o_Out(10 downto 5)	<= i_Inst(30 downto 25);
			o_Out(4 downto 1)	<= i_Inst(11 downto 8);
			o_Out(0)		<= '0';

		elsif i_Sel = "011" then
			o_Out(31 downto 12)	<= i_Inst(31 downto 12);
			o_Out(11 downto 0)	<= "000000000000";

		else
			o_Out(31 downto 20)	<= (others => i_Inst(31));
			o_Out(19 downto 12)	<= i_Inst(19 downto 12);
			o_Out(11)		<= i_Inst(20);
			o_Out(10 downto 1)	<= i_Inst(30 downto 21);
			o_Out(0)		<= '0';
			

		end if;
	end process;
end dataflow;