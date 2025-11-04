library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
-- Decoder that takes ALU Control as input, and outputs select signals for AddSub and LogicUnit
entity ALUDecoder is
    port(i_ALUControl	: in std_logic_vector(3 downto 0);
	 o_Out		: out std_logic_vector(1 downto 0));
end ALUDecoder;

architecture behavioral of ALUDecoder is
    begin
	with i_ALUControl select
	o_Out <= "00" when "0010", -- add
	"01" when "0110", -- sub
	"00" when "0000", -- and
	"01" when "0001", -- or
	"10" when "0011", -- xor
	"11" when "1100", -- nor
	"10" when "0111", -- slt
	"11" when "1000", -- sltu
	"00" when others;

end behavioral;