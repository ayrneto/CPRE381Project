library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity Mem_WB is
	port(i_CLK      : in std_logic;
		 i_RST      : in std_logic;
		 i_Stall    : in std_logic;
		 i_Flush    : in std_logic;
		 i_DMem     : in std_logic_vector(31 downto 0);
		 i_ALUResult: in std_logic_vector(31 downto 0);
		 i_PC4      : in std_logic_vector(31 downto 0);
		 i_rd       : in std_logic_vector(4 downto 0);
		 i_RegWrite : in std_logic;
		 i_MemToReg : in std_logic;
		 i_AndLink  : in std_logic;
		 i_Halt     : in std_logic;
		 o_DMem     : out std_logic_vector(31 downto 0);
		 o_ALUResult: out std_logic_vector(31 downto 0);
		 o_PC4      : out std_logic_vector(31 downto 0);
		 o_rd       : out std_logic_vector(4 downto 0);
		 o_RegWrite : out std_logic;
		 o_MemToReg : out std_logic;
		 o_AndLink  : out std_logic;
		 o_Halt     : out std_logic);
end Mem_WB;

architecture behavioral of Mem_WB is
begin
	process(i_CLK, i_RST)
	begin
		if rising_edge(i_CLK) then
			if i_RST = '1' or i_Flush = '1' then
				o_DMem     <= (others => '0');
				o_ALUResult<= (others => '0');
				o_PC4      <= (others => '0');
				o_rd       <= (others => '0');
				o_RegWrite <= '0';
				o_MemToReg <= '0';
				o_AndLink  <= '0';
				o_Halt     <= '0';
			elsif i_Stall = '0' then
				o_DMem     <= i_DMem;
				o_ALUResult<= i_ALUResult;
				o_PC4      <= i_PC4;
				o_rd       <= i_rd;
				o_RegWrite <= i_RegWrite;
				o_MemToReg <= i_MemToReg;
				o_AndLink  <= i_AndLink;
				o_Halt     <= i_Halt;
			end if;
		end if;
	end process;
end behavioral;