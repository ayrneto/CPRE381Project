library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 32x32 register file with two asynchronous read ports and one synchronous write port.
-- Register x0 is hard-wired to zero per RISC-V specification.
entity RegisterFile is
    port(
        i_CLK       : in  std_logic;
        i_RST       : in  std_logic;
        i_RegWrite  : in  std_logic;
        i_ReadReg1  : in  std_logic_vector(4 downto 0);
        i_ReadReg2  : in  std_logic_vector(4 downto 0);
        i_WriteReg  : in  std_logic_vector(4 downto 0);
        i_WriteData : in  std_logic_vector(31 downto 0);
        o_ReadData1 : out std_logic_vector(31 downto 0);
        o_ReadData2 : out std_logic_vector(31 downto 0)
    );
end RegisterFile;

architecture rtl of RegisterFile is
    type reg_array is array (31 downto 0) of std_logic_vector(31 downto 0);
    signal s_regs : reg_array;
    constant ZERO_WORD : std_logic_vector(31 downto 0) := (others => '0');

    function read_port(regs : reg_array; addr : std_logic_vector(4 downto 0)) return std_logic_vector is
        variable idx : integer := to_integer(unsigned(addr));
    begin
        if idx = 0 then
            return ZERO_WORD;
        else
            return regs(idx);
        end if;
    end function;
begin
    process(i_CLK)
        variable idx : integer;
    begin
        if rising_edge(i_CLK) then
            if i_RST = '1' then
                for i in s_regs'range loop
                    s_regs(i) <= ZERO_WORD;
                end loop;
            elsif i_RegWrite = '1' then
                idx := to_integer(unsigned(i_WriteReg));
                if idx /= 0 then
                    s_regs(idx) <= i_WriteData;
                end if;
            end if;
        end if;
    end process;

    o_ReadData1 <= read_port(s_regs, i_ReadReg1);
    o_ReadData2 <= read_port(s_regs, i_ReadReg2);
end rtl;
