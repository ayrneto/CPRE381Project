library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_HazardDetectionUnit is
end tb_HazardDetectionUnit;

architecture testbench of tb_HazardDetectionUnit is
    component HazardDetectionUnit
        port(ID_EX_MemRead : in std_logic;
             ID_EX_rd      : in std_logic_vector(4 downto 0);
             IF_ID_rs1     : in std_logic_vector(4 downto 0);
             IF_ID_rs2     : in std_logic_vector(4 downto 0);
             PCWrite       : out std_logic;
             IF_ID_Write   : out std_logic;
             FlushMux_Sel  : out std_logic);
    end component;

    signal ID_EX_MemRead : std_logic;
    signal ID_EX_rd      : std_logic_vector(4 downto 0);
    signal IF_ID_rs1     : std_logic_vector(4 downto 0);
    signal IF_ID_rs2     : std_logic_vector(4 downto 0);
    signal PCWrite       : std_logic;
    signal IF_ID_Write   : std_logic;
    signal FlushMux_Sel  : std_logic;

begin
    uut: HazardDetectionUnit
        port map (
            ID_EX_MemRead => ID_EX_MemRead,
            ID_EX_rd      => ID_EX_rd,
            IF_ID_rs1     => IF_ID_rs1,
            IF_ID_rs2     => IF_ID_rs2,
            PCWrite       => PCWrite,
            IF_ID_Write   => IF_ID_Write,
            FlushMux_Sel  => FlushMux_Sel
        );

    process
    begin
        -- Test 1: No hazard - normal operation
        ID_EX_MemRead <= '0';  -- Not a load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00010";
        IF_ID_rs2 <= "00011";
        wait for 10 ns;
        assert PCWrite = '1' report "Test 1 PCWrite failed" severity error;
        assert IF_ID_Write = '1' report "Test 1 IF_ID_Write failed" severity error;
        assert FlushMux_Sel = '0' report "Test 1 FlushMux_Sel failed" severity error;

        -- Test 2: No hazard - load but no dependency
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00010";  -- Different registers
        IF_ID_rs2 <= "00011";
        wait for 10 ns;
        assert PCWrite = '1' report "Test 2 PCWrite failed" severity error;
        assert IF_ID_Write = '1' report "Test 2 IF_ID_Write failed" severity error;
        assert FlushMux_Sel = '0' report "Test 2 FlushMux_Sel failed" severity error;

        -- Test 3: Load-use hazard with rs1
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00001";  -- Same as load destination
        IF_ID_rs2 <= "00010";
        wait for 10 ns;
        assert PCWrite = '0' report "Test 3 PCWrite failed (should stall)" severity error;
        assert IF_ID_Write = '0' report "Test 3 IF_ID_Write failed (should stall)" severity error;
        assert FlushMux_Sel = '1' report "Test 3 FlushMux_Sel failed (should flush)" severity error;

        -- Test 4: Load-use hazard with rs2
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00010";
        IF_ID_rs2 <= "00001";  -- Same as load destination
        wait for 10 ns;
        assert PCWrite = '0' report "Test 4 PCWrite failed (should stall)" severity error;
        assert IF_ID_Write = '0' report "Test 4 IF_ID_Write failed (should stall)" severity error;
        assert FlushMux_Sel = '1' report "Test 4 FlushMux_Sel failed (should flush)" severity error;

        -- Test 5: Load-use hazard with both rs1 and rs2
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00001";  -- Same as load destination
        IF_ID_rs2 <= "00001";  -- Same as load destination
        wait for 10 ns;
        assert PCWrite = '0' report "Test 5 PCWrite failed (should stall)" severity error;
        assert IF_ID_Write = '0' report "Test 5 IF_ID_Write failed (should stall)" severity error;
        assert FlushMux_Sel = '1' report "Test 5 FlushMux_Sel failed (should flush)" severity error;

        -- Test 6: No hazard with x0 register
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00000";   -- Writing to x0 (always zero)
        IF_ID_rs1 <= "00000";  -- Reading from x0
        IF_ID_rs2 <= "00000";  -- Reading from x0
        wait for 10 ns;
        assert PCWrite = '1' report "Test 6 PCWrite failed (x0 should not cause hazard)" severity error;
        assert IF_ID_Write = '1' report "Test 6 IF_ID_Write failed (x0 should not cause hazard)" severity error;
        assert FlushMux_Sel = '0' report "Test 6 FlushMux_Sel failed (x0 should not cause hazard)" severity error;

        -- Test 7: Load followed by non-dependent instruction
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00002";  -- Different registers
        IF_ID_rs2 <= "00003";
        wait for 10 ns;
        assert PCWrite = '1' report "Test 7 PCWrite failed" severity error;
        assert IF_ID_Write = '1' report "Test 7 IF_ID_Write failed" severity error;
        assert FlushMux_Sel = '0' report "Test 7 FlushMux_Sel failed" severity error;

        -- Test 8: Non-load instruction, no hazard even with same registers
        ID_EX_MemRead <= '0';  -- Not a load instruction
        ID_EX_rd <= "00001";
        IF_ID_rs1 <= "00001";  -- Same register but no load-use hazard
        IF_ID_rs2 <= "00001";
        wait for 10 ns;
        assert PCWrite = '1' report "Test 8 PCWrite failed (ALU ops can be forwarded)" severity error;
        assert IF_ID_Write = '1' report "Test 8 IF_ID_Write failed (ALU ops can be forwarded)" severity error;
        assert FlushMux_Sel = '0' report "Test 8 FlushMux_Sel failed (ALU ops can be forwarded)" severity error;

        -- Test 9: Multiple different registers, load instruction
        ID_EX_MemRead <= '1';  -- Load instruction
        ID_EX_rd <= "11111";   -- Register 31
        IF_ID_rs1 <= "11110";  -- Register 30
        IF_ID_rs2 <= "11101";  -- Register 29
        wait for 10 ns;
        assert PCWrite = '1' report "Test 9 PCWrite failed" severity error;
        assert IF_ID_Write = '1' report "Test 9 IF_ID_Write failed" severity error;
        assert FlushMux_Sel = '0' report "Test 9 FlushMux_Sel failed" severity error;

        -- Test 10: Edge case - only rs1 matches
        ID_EX_MemRead <= '1';
        ID_EX_rd <= "01010";   -- Register 10
        IF_ID_rs1 <= "01010";  -- Same as destination
        IF_ID_rs2 <= "01011";  -- Different
        wait for 10 ns;
        assert PCWrite = '0' report "Test 10 PCWrite failed (should stall for rs1)" severity error;
        assert IF_ID_Write = '0' report "Test 10 IF_ID_Write failed (should stall for rs1)" severity error;
        assert FlushMux_Sel = '1' report "Test 10 FlushMux_Sel failed (should flush for rs1)" severity error;

        report "All HazardDetectionUnit tests completed";
        wait;
    end process;

end testbench;