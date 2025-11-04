library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Extender is
end tb_Extender;

architecture testbench of tb_Extender is
    component Extender
        port(i_Inst	: in std_logic_vector(31 downto 0);
	     i_Sel	: in std_logic_vector(2 downto 0);
	     o_Out	: out std_logic_vector(31 downto 0));
    end component;

    signal i_Inst : std_logic_vector(31 downto 0);
    signal i_Sel  : std_logic_vector(2 downto 0);
    signal o_Out  : std_logic_vector(31 downto 0);

begin
    uut: Extender
        port map (
            i_Inst => i_Inst,
            i_Sel  => i_Sel,
            o_Out  => o_Out
        );

    process
    begin
        -- Test I-Type immediate extension (i_Sel = "000")
        i_Inst <= x"FFF12345"; -- Negative immediate (bits 31:20 = 0xFFF)
        i_Sel <= "000";
        wait for 10 ns;
        -- Expected: 0xFFFFFFFF (sign extended)
        
        i_Inst <= x"12345678"; -- Positive immediate (bits 31:20 = 0x123)
        wait for 10 ns;
        -- Expected: 0x00000123
        
        -- Test S-Type immediate extension (i_Sel = "001")
        i_Inst <= x"FE000F80"; -- imm[11:5] = 0x7F, imm[4:0] = 0x00, MSB = 1
        i_Sel <= "001";
        wait for 10 ns;
        -- Expected: 0xFFFFFFF0 (sign extended)
        
        i_Inst <= x"02000080"; -- imm[11:5] = 0x01, imm[4:0] = 0x00, MSB = 0
        wait for 10 ns;
        -- Expected: 0x00000020
        
        -- Test B-Type immediate extension (i_Sel = "010")
        i_Inst <= x"80000080"; -- Negative branch offset
        i_Sel <= "010";
        wait for 10 ns;
        -- Expected: Negative sign extended value with LSB = 0
        
        i_Inst <= x"00000080"; -- Positive branch offset
        wait for 10 ns;
        -- Expected: Positive value with LSB = 0
        
        -- Test U-Type immediate (i_Sel = "011")
        i_Inst <= x"ABCDE000"; -- Upper 20 bits
        i_Sel <= "011";
        wait for 10 ns;
        -- Expected: 0xABCDE000 (upper bits preserved, lower 12 bits = 0)
        
        i_Inst <= x"12345000";
        wait for 10 ns;
        -- Expected: 0x12345000
        
        -- Test J-Type immediate extension (i_Sel = "100" or others)
        i_Inst <= x"80000000"; -- Negative jump offset
        i_Sel <= "100";
        wait for 10 ns;
        -- Expected: Negative sign extended value with LSB = 0
        
        i_Inst <= x"00012345"; -- Positive jump offset
        wait for 10 ns;
        -- Expected: Positive value with LSB = 0
        
        -- Test edge cases
        i_Inst <= x"00000000"; -- All zeros
        i_Sel <= "000";
        wait for 10 ns;
        -- Expected: 0x00000000
        
        i_Inst <= x"FFFFFFFF"; -- All ones
        wait for 10 ns;
        -- Expected: 0xFFFFFFFF
        
        -- Test different selector values
        i_Inst <= x"12345678";
        i_Sel <= "101"; -- Invalid selector (should default to J-Type)
        wait for 10 ns;
        
        i_Sel <= "110";
        wait for 10 ns;
        
        i_Sel <= "111";
        wait for 10 ns;

        report "Extender testbench completed";
        wait;
    end process;
end testbench;