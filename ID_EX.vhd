library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity ID_EX is
	port(i_CLK       : in std_logic;
		 i_RST       : in std_logic;
		 i_Stall     : in std_logic;
		 i_Flush     : in std_logic;
		 i_rd        : in std_logic_vector(4 downto 0);
		 i_rs1       : in std_logic_vector(4 downto 0);
		 i_rs2       : in std_logic_vector(4 downto 0);
		 i_ReadData1 : in std_logic_vector(31 downto 0);
		 i_ReadData2 : in std_logic_vector(31 downto 0);
		 i_PC        : in std_logic_vector(31 downto 0);
		 i_PC4       : in std_logic_vector(31 downto 0);
		 i_imm       : in std_logic_vector(31 downto 0);
		 i_Shamt     : in std_logic_vector(4 downto 0);
		 i_ALUControl: in std_logic_vector(3 downto 0);
		 i_ALUSrc    : in std_logic;
		 i_RegWrite  : in std_logic;
		 i_MemToReg  : in std_logic;
		 i_MemRead   : in std_logic;
		 i_MemWrite  : in std_logic;
		 i_LoadWidth : in std_logic_vector(1 downto 0);
		 i_LoadSigned: in std_logic;
		 i_StoreWidth: in std_logic_vector(1 downto 0);
		 i_AndLink   : in std_logic;
		 i_AUIPC     : in std_logic;
		 i_Halt      : in std_logic;
		 o_rd        : out std_logic_vector(4 downto 0);
		 o_rs1       : out std_logic_vector(4 downto 0);
		 o_rs2       : out std_logic_vector(4 downto 0);
		 o_ReadData1 : out std_logic_vector(31 downto 0);
		 o_ReadData2 : out std_logic_vector(31 downto 0);
		 o_PC        : out std_logic_vector(31 downto 0);
		 o_PC4       : out std_logic_vector(31 downto 0);
		 o_imm       : out std_logic_vector(31 downto 0);
		 o_Shamt     : out std_logic_vector(4 downto 0);
		 o_ALUControl: out std_logic_vector(3 downto 0);
		 o_ALUSrc    : out std_logic;
		 o_RegWrite  : out std_logic;
		 o_MemToReg  : out std_logic;
		 o_MemRead   : out std_logic;
		 o_MemWrite  : out std_logic;
		 o_LoadWidth : out std_logic_vector(1 downto 0);
		 o_LoadSigned: out std_logic;
		 o_StoreWidth: out std_logic_vector(1 downto 0);
		 o_AndLink   : out std_logic;
		 o_AUIPC     : out std_logic;
		 o_Halt      : out std_logic);
end ID_EX;

architecture behavioral of ID_EX is
begin
	process(i_CLK, i_RST)
	begin
		if rising_edge(i_CLK) then
			if i_RST = '1' or i_Flush = '1' then
				o_rd        <= (others => '0');
				o_rs1       <= (others => '0');
				o_rs2       <= (others => '0');
				o_ReadData1 <= (others => '0');
				o_ReadData2 <= (others => '0');
				o_PC        <= (others => '0');
				o_PC4       <= (others => '0');
				o_imm       <= (others => '0');
				o_Shamt     <= (others => '0');
				o_ALUControl<= (others => '0');
				o_ALUSrc    <= '0';
				o_RegWrite  <= '0';
				o_MemToReg  <= '0';
				o_MemRead   <= '0';
				o_MemWrite  <= '0';
				o_LoadWidth <= (others => '0');
				o_LoadSigned<= '0';
				o_StoreWidth<= (others => '0');
				o_AndLink   <= '0';
				o_AUIPC     <= '0';
				o_Halt      <= '0';
			elsif i_Stall = '0' then
				o_rd        <= i_rd;
				o_rs1       <= i_rs1;
				o_rs2       <= i_rs2;
				o_ReadData1 <= i_ReadData1;
				o_ReadData2 <= i_ReadData2;
				o_PC        <= i_PC;
				o_PC4       <= i_PC4;
				o_imm       <= i_imm;
				o_Shamt     <= i_Shamt;
				o_ALUControl<= i_ALUControl;
				o_ALUSrc    <= i_ALUSrc;
				o_RegWrite  <= i_RegWrite;
				o_MemToReg  <= i_MemToReg;
				o_MemRead   <= i_MemRead;
				o_MemWrite  <= i_MemWrite;
				o_LoadWidth <= i_LoadWidth;
				o_LoadSigned<= i_LoadSigned;
				o_StoreWidth<= i_StoreWidth;
				o_AndLink   <= i_AndLink;
				o_AUIPC     <= i_AUIPC;
				o_Halt      <= i_Halt;
			end if;
		end if;
	end process;
end behavioral;