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

    constant ALU_SLL : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRL : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SRA : std_logic_vector(3 downto 0) := "0111";

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
        -- Logical Right Shift
        i_Data     <= x"F000000F";
        i_ShiftAmt <= "00011";  -- shift by 3
        i_Mode     <= ALU_SRL;
        wait for 10 ns;

        -- Arithmetic Right Shift
        i_Data     <= x"F000000F"; -- MSB = 1
        i_ShiftAmt <= "00100";  -- shift by 4
        i_Mode     <= ALU_SRA;
        wait for 10 ns;

        -- Logical Left Shift
        i_Data     <= x"0000000F";
        i_ShiftAmt <= "00010";  -- shift by 2
        i_Mode     <= ALU_SLL;
        wait for 10 ns;

        wait;
    end process;
end testbench;
