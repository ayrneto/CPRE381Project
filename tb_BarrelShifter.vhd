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
            i_Dir      : in  std_logic; -- '0' = left, '1' = right
            i_Arith    : in  std_logic; -- only for right shift
            o_Result   : out std_logic_vector(31 downto 0)
        );
    end component;

    signal i_Data     : std_logic_vector(31 downto 0);
    signal i_ShiftAmt : std_logic_vector(4 downto 0);
    signal i_Dir      : std_logic;
    signal i_Arith    : std_logic;
    signal o_Result   : std_logic_vector(31 downto 0);

begin
    uut: BarrelShifter
        port map (
            i_Data     => i_Data,
            i_ShiftAmt => i_ShiftAmt,
            i_Dir      => i_Dir,
            i_Arith    => i_Arith,
            o_Result   => o_Result
        );

    process
    begin
        -- Logical Right Shift
        i_Data     <= x"F000000F";
        i_ShiftAmt <= "00011";  -- shift by 3
        i_Dir      <= '1';
        i_Arith    <= '0';
        wait for 10 ns;

        -- Arithmetic Right Shift
        i_Data     <= x"F000000F"; -- MSB = 1
        i_ShiftAmt <= "00100";  -- shift by 4
        i_Dir      <= '1';
        i_Arith    <= '1';
        wait for 10 ns;

        -- Logical Left Shift
        i_Data     <= x"0000000F";
        i_ShiftAmt <= "00010";  -- shift by 2
        i_Dir      <= '0';
        i_Arith    <= '0';      -- ignored
        wait for 10 ns;

        wait;
    end process;
end testbench;
