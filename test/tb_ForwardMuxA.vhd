library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ForwardMuxA is
end tb_ForwardMuxA;

architecture testbench of tb_ForwardMuxA is
    component ForwardMuxA
        port(ReadData1       : in std_logic_vector(31 downto 0);
             Mem_WB_Data     : in std_logic_vector(31 downto 0);
             EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
             Sel             : in std_logic_vector(1 downto 0);
             ALU_InputA      : out std_logic_vector(31 downto 0));
    end component;

    signal ReadData1       : std_logic_vector(31 downto 0);
    signal Mem_WB_Data     : std_logic_vector(31 downto 0);
    signal EX_Mem_ALUResult : std_logic_vector(31 downto 0);
    signal Sel             : std_logic_vector(1 downto 0);
    signal ALU_InputA      : std_logic_vector(31 downto 0);

begin
    uut: ForwardMuxA
        port map (
            ReadData1       => ReadData1,
            Mem_WB_Data     => Mem_WB_Data,
            EX_Mem_ALUResult => EX_Mem_ALUResult,
            Sel             => Sel,
            ALU_InputA      => ALU_InputA
        );

    process
    begin
        -- Set up test data
        ReadData1 <= x"11111111";
        Mem_WB_Data <= x"22222222";
        EX_Mem_ALUResult <= x"33333333";

        -- Test 1: Select ReadData1 (no forwarding)
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputA = x"11111111" report "Test 1 failed - should select ReadData1" severity error;

        -- Test 2: Select Mem_WB_Data (forwarding from WB stage)
        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputA = x"22222222" report "Test 2 failed - should select Mem_WB_Data" severity error;

        -- Test 3: Select EX_Mem_ALUResult (forwarding from EX/MEM stage)
        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputA = x"33333333" report "Test 3 failed - should select EX_Mem_ALUResult" severity error;

        -- Test 4: Invalid selection (should default to ReadData1)
        Sel <= "11";
        wait for 10 ns;
        assert ALU_InputA = x"11111111" report "Test 4 failed - should default to ReadData1" severity error;

        -- Test 5: Change all inputs and test each selection again
        ReadData1 <= x"AAAAAAAA";
        Mem_WB_Data <= x"BBBBBBBB";
        EX_Mem_ALUResult <= x"CCCCCCCC";
        
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputA = x"AAAAAAAA" report "Test 5a failed" severity error;

        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputA = x"BBBBBBBB" report "Test 5b failed" severity error;

        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputA = x"CCCCCCCC" report "Test 5c failed" severity error;

        -- Test 6: Edge cases with all zeros and all ones
        ReadData1 <= x"00000000";
        Mem_WB_Data <= x"FFFFFFFF";
        EX_Mem_ALUResult <= x"12345678";
        
        Sel <= "00";
        wait for 10 ns;
        assert ALU_InputA = x"00000000" report "Test 6a failed" severity error;

        Sel <= "01";
        wait for 10 ns;
        assert ALU_InputA = x"FFFFFFFF" report "Test 6b failed" severity error;

        Sel <= "10";
        wait for 10 ns;
        assert ALU_InputA = x"12345678" report "Test 6c failed" severity error;

        report "All ForwardMuxA tests completed";
        wait;
    end process;

end testbench;