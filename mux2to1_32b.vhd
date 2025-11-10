library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_32b is
    port(i_A	: in std_logic_vector(31 downto 0);
	 i_B	: in std_logic_vector(31 downto 0);
	 i_Sel	: in std_logic;
	 o_Out	: out std_logic_vector(31 downto 0));
end mux2to1_32b;

architecture rtl of mux2to1_32b is
begin
    o_Out <= i_A when i_Sel = '0' else i_B;
end rtl;