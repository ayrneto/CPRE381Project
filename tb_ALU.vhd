library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ALU is
end tb_ALU;

architecture testbench of tb_ALU is
    component ALU
        port(i_A	      : in std_logic_vector(31 downto 0);
	     i_B   	      : in std_logic_vector(31 downto 0);
	     i_ALUControl     : in std_logic_vector(3 downto 0);
	     i_shamt          : in std_logic_vector(4 downto 0);
	     o_ALUOut         : out std_logic_vector(31 downto 0));
    end component;

    signal i_A           : std_logic_vector(31 downto 0);
    signal i_B           : std_logic_vector(31 downto 0);
    signal i_ALUControl  : std_logic_vector(3 downto 0);
    signal i_shamt       : std_logic_vector(4 downto 0);
    signal o_ALUOut      : std_logic_vector(31 downto 0);

    -- ALU control constants
    constant ALU_AND     : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR      : std_logic_vector(3 downto 0) := "0001";
    constant ALU_ADD     : std_logic_vector(3 downto 0) := "0010";
    constant ALU_XOR     : std_logic_vector(3 downto 0) := "0011";
    constant ALU_SLL     : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SRL     : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SUB     : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SLT     : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLTU    : std_logic_vector(3 downto 0) := "1000";
    constant ALU_SRA     : std_logic_vector(3 downto 0) := "1001";
    constant ALU_PASSIMM : std_logic_vector(3 downto 0) := "1010";
    constant ALU_NOR     : std_logic_vector(3 downto 0) := "1100";

begin
    uut: ALU
        port map (
            i_A         => i_A,
            i_B         => i_B,
            i_ALUControl => i_ALUControl,
            i_shamt     => i_shamt,
            o_ALUOut    => o_ALUOut
        );

    process
    begin
        -- Test ADD operation
        i_A <= x"00000005";
        i_B <= x"00000003";
        i_ALUControl <= ALU_ADD;
        i_shamt <= "00000";
        wait for 10 ns;
        -- Expected: 0x00000008

        -- Test SUB operation
        i_A <= x"00000008";
        i_B <= x"00000003";
        i_ALUControl <= ALU_SUB;
        wait for 10 ns;
        -- Expected: 0x00000005

        -- Test AND operation
        i_A <= x"0000000F";
        i_B <= x"000000AA";
        i_ALUControl <= ALU_AND;
        wait for 10 ns;
        -- Expected: 0x0000000A

        -- Test OR operation
        i_A <= x"0000000F";
        i_B <= x"000000A0";
        i_ALUControl <= ALU_OR;
        wait for 10 ns;
        -- Expected: 0x000000AF

        -- Test XOR operation
        i_A <= x"0000000F";
        i_B <= x"000000AA";
        i_ALUControl <= ALU_XOR;
        wait for 10 ns;
        -- Expected: 0x000000A5

        -- Test NOR operation
        i_A <= x"0000000F";
        i_B <= x"000000A0";
        i_ALUControl <= ALU_NOR;
        wait for 10 ns;
        -- Expected: 0xFFFFFF50

        -- Test SLL (Shift Left Logical)
        i_A <= x"00000001";
        i_shamt <= "00100"; -- shift by 4
        i_ALUControl <= ALU_SLL;
        wait for 10 ns;
        -- Expected: 0x00000010

        -- Test SRL (Shift Right Logical)
        i_A <= x"80000000";
        i_shamt <= "00001"; -- shift by 1
        i_ALUControl <= ALU_SRL;
        wait for 10 ns;
        -- Expected: 0x40000000

        -- Test SRA (Shift Right Arithmetic)
        i_A <= x"80000000";
        i_shamt <= "00001"; -- shift by 1
        i_ALUControl <= ALU_SRA;
        wait for 10 ns;
        -- Expected: 0xC0000000

        -- Test SLT (Set Less Than) - signed
        i_A <= x"FFFFFFFF"; -- -1 in signed
        i_B <= x"00000001"; -- +1 in signed
        i_ALUControl <= ALU_SLT;
        wait for 10 ns;
        -- Expected: 0x00000001 (true, -1 < 1)

        -- Test SLTU (Set Less Than Unsigned)
        i_A <= x"FFFFFFFF"; -- Large unsigned number
        i_B <= x"00000001"; -- Small unsigned number
        i_ALUControl <= ALU_SLTU;
        wait for 10 ns;
        -- Expected: 0x00000000 (false, 0xFFFFFFFF > 1)

        -- Test PASSIMM (for LUI instruction)
        i_A <= x"12345678";
        i_B <= x"ABCD0000";
        i_ALUControl <= ALU_PASSIMM;
        wait for 10 ns;
        -- Expected: 0xABCD0000 (passes B through)

        -- Test edge cases
        -- ADD with overflow
        i_A <= x"7FFFFFFF"; -- Maximum positive signed int
        i_B <= x"00000001";
        i_ALUControl <= ALU_ADD;
        wait for 10 ns;
        -- Expected: 0x80000000 (overflow to negative)

        -- SUB with underflow
        i_A <= x"80000000"; -- Minimum negative signed int
        i_B <= x"00000001";
        i_ALUControl <= ALU_SUB;
        wait for 10 ns;
        -- Expected: 0x7FFFFFFF (underflow to positive)

        wait;
    end process;
end testbench;