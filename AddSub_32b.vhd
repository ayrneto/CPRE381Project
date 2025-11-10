library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
-- Normal AddSub, but with a nAdd_Sub extension of 1 bit. Functions the same.
entity AddSub_32b is 
	generic(N : integer := 32);
	port(i_A        : in std_logic_vector(N-1 downto 0);
		 i_B        : in std_logic_vector(N-1 downto 0);
		 nAdd_Sub   : in std_logic_vector(1 downto 0);
		 o_Result   : out std_logic_vector(N-1 downto 0);
		 o_CarryOut : out std_logic);
end AddSub_32b;

architecture rtl of AddSub_32b is
	signal s_A        : unsigned(N-1 downto 0);
	signal s_B        : unsigned(N-1 downto 0);
	signal s_Subtract : std_logic;
	signal s_ExtA     : unsigned(N downto 0);
	signal s_ExtB     : unsigned(N downto 0);
	signal s_Sum      : unsigned(N downto 0);
begin
	s_A        <= unsigned(i_A);
	s_B        <= unsigned(i_B);
	s_Subtract <= '1' when nAdd_Sub = "01" else '0';

	s_ExtA <= ('0' & s_A);
	s_ExtB <= ('0' & (not s_B)) when s_Subtract = '1' else ('0' & s_B);

	process(s_ExtA, s_ExtB, s_Subtract)
		variable v_sum : unsigned(N downto 0);
	begin
		if s_Subtract = '1' then
			v_sum := s_ExtA + s_ExtB + 1;
		else
			v_sum := s_ExtA + s_ExtB;
		end if;
		s_Sum <= v_sum;
	end process;

	o_Result   <= std_logic_vector(s_Sum(N-1 downto 0));
	o_CarryOut <= s_Sum(N);
end rtl;











 