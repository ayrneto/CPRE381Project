library IEEE;
use IEEE.std_logic_1164.all;

-- Ayr Nasser Neto
-- PC (Program Counter): A register, that has Write Enable always on and holds the value of the next instruction's address as input, and outputs the current address
entity PC is
	port(i_CLK	: in std_logic;
		 i_RST	: in std_logic;
	 i_WE	: in std_logic;
	 i_D	: in std_logic_vector(31 downto 0);
	 o_Q	: out std_logic_vector(31 downto 0));
	end PC;

architecture rtl of PC is
	constant C_RESET_ADDR : std_logic_vector(31 downto 0) := x"00400000"; -- Start execution at standard RISC-V text base
	signal s_Q : std_logic_vector(31 downto 0) := C_RESET_ADDR;
begin
	process(i_CLK)
	begin
		if rising_edge(i_CLK) then
			if i_RST = '1' then
				s_Q <= C_RESET_ADDR; -- Force PC to reset to the canonical text segment base
			elsif i_WE = '1' then
				s_Q <= i_D;
			end if;
		end if;
	end process;

	o_Q <= s_Q;
end rtl;