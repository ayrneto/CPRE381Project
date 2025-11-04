library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_BarrelShifter is
end tb_BarrelShifter;

architecture testbench of tb_BarrelShifter is
    component BarrelShifter
        port (
            i_Data     : in  std_logic_vector(31 downto 0);
            i_ShiftAmt : in  std_logic_vector(4 downto 0);
            i_Mode     : in  std_logic_vector(3 downto 0);
            o_Result   : out std_logic_vector(31 downto 0)
        );
    end component;

    signal i_Data     : std_logic_vector(31 downto 0);
    signal i_ShiftAmt : std_logic_vector(4 downto 0);
    signal i_Mode     : std_logic_vector(3 downto 0);
    signal o_Result   : std_logic_vector(31 downto 0);

    constant ALU_SLL : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRA : std_logic_vector(3 downto 0) := "1001";

begin
    uut: BarrelShifter
        port map (
            i_Data     => i_Data,
            i_ShiftAmt => i_ShiftAmt,
            i_Mode     => i_Mode,
            o_Result   => o_Result
        );

    process
    begin
        -- Test 1: Logical Right Shift
        i_Data     <= x"F000000F";
        i_ShiftAmt <= "00011";  -- shift by 3
        i_Mode     <= ALU_SRL;
        wait for 10 ns;
        -- Expected: 0x1E000001 (zeros shifted in from left)

        -- Test 2: Arithmetic Right Shift (negative number)
        i_Data     <= x"F000000F"; -- MSB = 1 (negative)
        i_ShiftAmt <= "00100";  -- shift by 4
        i_Mode     <= ALU_SRA;
        wait for 10 ns;
        -- Expected: 0xFF000000 (sign bit replicated)

        -- Test 3: Logical Left Shift
        i_Data     <= x"0000000F";
        i_ShiftAmt <= "00010";  -- shift by 2
        i_Mode     <= ALU_SLL;
        wait for 10 ns;
        -- Expected: 0x0000003C

        -- Test 4: SRL with zero shift
        i_Data     <= x"AAAAAAAA";
        i_ShiftAmt <= "00000";  -- no shift
        i_Mode     <= ALU_SRL;
        wait for 10 ns;
        -- Expected: 0xAAAAAAAA (unchanged)

        -- Test 5: SRA with positive number
        i_Data     <= x"7FFFFFFF"; -- MSB = 0 (positive)
        i_ShiftAmt <= "00001";  -- shift by 1
        i_Mode     <= ALU_SRA;
        wait for 10 ns;
        -- Expected: 0x3FFFFFFF (zero shifted in)

        -- Test 6: SLL with maximum shift
        i_Data     <= x"00000001";
        i_ShiftAmt <= "11111";  -- shift by 31
        i_Mode     <= ALU_SLL;
        wait for 10 ns;
        -- Expected: 0x80000000

        -- Test 7: Non-shift operation (should pass data through)
        i_Data     <= x"12345678";
        i_ShiftAmt <= "01010";  -- shift amount should be ignored
        i_Mode     <= "0000";   -- Non-shift ALU operation
        wait for 10 ns;
        -- Expected: 0x12345678 (unchanged)

        -- Test 8: SRL with large shift
        i_Data     <= x"FFFFFFFF";
        i_ShiftAmt <= "10000";  -- shift by 16
        i_Mode     <= ALU_SRL;
        wait for 10 ns;
        -- Expected: 0x0000FFFF

        report "BarrelShifter testbench completed";
        wait;
    end process;
end testbench;
