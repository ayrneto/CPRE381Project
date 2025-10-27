library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity BarrelShifter is
    port (
        i_Data     : in  std_logic_vector(31 downto 0);
        i_ShiftAmt : in  std_logic_vector(4 downto 0);
        i_Dir      : in  std_logic; -- '0' = left, '1' = right
        i_Arith    : in  std_logic; -- only matters when shifting right
        o_Result   : out std_logic_vector(31 downto 0)
    );
end BarrelShifter;

architecture Behavioral of BarrelShifter is
begin
    process(i_Data, i_ShiftAmt, i_Dir, i_Arith)
        variable data     : std_logic_vector(31 downto 0);
        variable shifted  : std_logic_vector(31 downto 0);
        variable amount   : integer range 0 to 31;
        variable fill_bit : std_logic;
    begin
        data := i_Data;
        amount := to_integer(unsigned(i_ShiftAmt));

        if i_Dir = '0' then  -- Shift Left
            shifted := std_logic_vector(shift_left(unsigned(data), amount));
        else                 -- Shift Right
            if i_Arith = '1' then
                fill_bit := data(31); -- sign extension
                shifted := std_logic_vector(shift_right(signed(data), amount));
            else
                shifted := std_logic_vector(shift_right(unsigned(data), amount));
            end if;
        end if;

        o_Result <= shifted;
    end process;
end Behavioral;

