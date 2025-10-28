library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Logical right shifts (SRL) shift zeros into the MSB, arithmetic right shifts (SRA)
-- copy the sign bit so the signed value is preserved. RISC-V omits SLA because
-- logical left (SLL) already performs the same transform for both signed/unsigned.

entity BarrelShifter is
    port (
        i_Data     : in  std_logic_vector(31 downto 0);
        i_ShiftAmt : in  std_logic_vector(4 downto 0);
        i_Mode     : in  std_logic_vector(3 downto 0); -- reuse ALUControl codes
        o_Result   : out std_logic_vector(31 downto 0)
    );
end BarrelShifter;

architecture Structural of BarrelShifter is

    -- Match the ALU control encodings defined in ControlUnit.vhd / ALU.
    constant ALU_SLL : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SRL : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SRA : std_logic_vector(3 downto 0) := "0111";

    type stage_array is array (0 to 5) of std_logic_vector(31 downto 0);

    signal s_before    : std_logic_vector(31 downto 0);
    signal s_stage     : stage_array;
    signal s_after     : std_logic_vector(31 downto 0);
    signal s_is_left   : std_logic;
    signal s_is_arith  : std_logic;
    signal s_is_shift  : std_logic;
    signal s_fill      : std_logic;
    signal s_shift_amt : std_logic_vector(4 downto 0);

    -- Bit reversal lets the same right-shift network implement left shifts.
    function reverse_bits(d : std_logic_vector(31 downto 0)) return std_logic_vector is
        variable result : std_logic_vector(31 downto 0);
    begin
        for i in 0 to 31 loop
            result(i) := d(31 - i);
        end loop;
        return result;
    end function;

begin
    -- Decode the requested shift mode from the ALUControl word.
    s_is_left  <= '1' when i_Mode = ALU_SLL else '0';
    s_is_arith <= '1' when i_Mode = ALU_SRA else '0';
    s_is_shift <= '1' when (i_Mode = ALU_SLL or i_Mode = ALU_SRL or i_Mode = ALU_SRA) else '0';

    -- Mask the shift amount whenever the ALU is executing a non-shift instruction.
    s_shift_amt <= i_ShiftAmt when s_is_shift = '1' else (others => '0');

    -- Feed left shifts through a reversed bit order so the mux tree stays identical.
    s_before    <= reverse_bits(i_Data) when (s_is_left = '1' and s_is_shift = '1') else i_Data;
    s_stage(0)  <= s_before;
    -- Arithmetic right shifts replicate the sign bit, logical shifts zero-fill.
    s_fill      <= i_Data(31) when (s_is_shift = '1' and s_is_left = '0' and s_is_arith = '1') else '0';

    -- Cascaded 2:1 multiplexers implement shifts by 1, 2, 4, 8, and 16 bits.
    stage_gen : for stage in 0 to 4 generate
        bit_gen : for bit in 0 to 31 generate
        begin
            shift_path : if bit + (2**stage) <= 31 generate
            begin
                s_stage(stage + 1)(bit) <= s_stage(stage)(bit) when s_shift_amt(stage) = '0'
                    else s_stage(stage)(bit + (2**stage));
            end generate;

            fill_path : if bit + (2**stage) > 31 generate
            begin
                s_stage(stage + 1)(bit) <= s_stage(stage)(bit) when s_shift_amt(stage) = '0'
                    else s_fill;
            end generate;
        end generate;
    end generate;

    s_after  <= s_stage(5);
    o_Result <= i_Data when s_is_shift = '0'
        else reverse_bits(s_after) when s_is_left = '1'
        else s_after;

end Structural;

