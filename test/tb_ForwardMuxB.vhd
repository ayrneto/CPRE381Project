library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ForwardMuxB is
end tb_ForwardMuxB;

architecture testbench of tb_ForwardMuxB is
    component ForwardMuxB
        port(ReadData2       : in std_logic_vector(31 downto 0);
             Mem_WB_Data     : in std_logic_vector(31 downto 0);
             EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
             Sel             : in std_logic_vector(1 downto 0);
             ALU_InputB      : out std_logic_vector(31 downto 0));
    end component;

    signal ReadData2       : std_logic_vector(31 downto 0);
    signal Mem_WB_Data     : std_logic_vector(31 downto 0);
    signal EX_Mem_ALUResult : std_logic_vector(31 downto 0);
    signal Sel             : std_logic_vector(1 downto 0);
    signal ALU_InputB      : out std_logic_vector(31 downto 0);

begin
    uut: ForwardMuxB
        port map (
            ReadData2       => ReadData2,
            Mem_WB_Data     => Mem_WB_Data,
            EX_Mem_ALUResult => EX_Mem_ALUResult,
            Sel             => Sel,
            ALU_InputB      => ALU_InputB
        );

    process
    begin
        -- Set up test data
        ReadData2 <= x"44444444";
        Mem_WB_Data <= x"55555555";
        EX_Mem_ALUResult <= x"66666666";

        -- Test 1: Select ReadData2 (no forwarding)
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputB = x"44444444" report "Test 1 failed - should select ReadData2" severity error;

        -- Test 2: Select Mem_WB_Data (forwarding from WB stage)
        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputB = x"55555555" report "Test 2 failed - should select Mem_WB_Data" severity error;

        -- Test 3: Select EX_Mem_ALUResult (forwarding from EX/MEM stage)
        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputB = x"66666666" report "Test 3 failed - should select EX_Mem_ALUResult" severity error;

        -- Test 4: Invalid selection (should default to ReadData2)
        Sel <= "11";
        wait for 10 ns;
        assert ALU_InputB = x"44444444" report "Test 4 failed - should default to ReadData2" severity error;

        -- Test 5: Change all inputs and test each selection again
        ReadData2 <= x"DDDDDDDD";
        Mem_WB_Data <= x"EEEEEEEE";
        EX_Mem_ALUResult <= x"FFFFFFFF";
        
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputB = x"DDDDDDDD" report "Test 5a failed" severity error;

        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputB = x"EEEEEEEE" report "Test 5b failed" severity error;

        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputB = x"FFFFFFFF" report "Test 5c failed" severity error;

        -- Test 6: Edge cases with specific patterns
        ReadData2 <= x"01010101";
        Mem_WB_Data <= x"10101010";
        EX_Mem_ALUResult <= x"ABCDEF01";
        
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputB = x"01010101" report "Test 6a failed" severity error;

        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputB = x"10101010" report "Test 6b failed" severity error;

        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputB = x"ABCDEF01" report "Test 6c failed" severity error;

        -- Test 7: Test immediate switching between selections
        Sel <= "00"; wait for 5 ns;
        Sel <= "01"; wait for 5 ns;
        Sel <= "10"; wait for 5 ns;
        Sel <= "00"; wait for 5 ns;
        assert ALU_InputB = x"01010101" report "Test 7 failed - final selection" severity error;

        report "All ForwardMuxB tests completed";
        wait;
    end process;

end testbench;