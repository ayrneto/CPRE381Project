library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ForwardingUnit is
end tb_ForwardingUnit;

architecture testbench of tb_ForwardingUnit is
    component ForwardingUnit
        port(ID_EX_rs1      : in std_logic_vector(4 downto 0);
             ID_EX_rs2      : in std_logic_vector(4 downto 0);
             EX_Mem_rd      : in std_logic_vector(4 downto 0);
             EX_Mem_RegWrite : in std_logic;
             Mem_WB_rd      : in std_logic_vector(4 downto 0);
             Mem_WB_RegWrite : in std_logic;
             ForwardA       : out std_logic_vector(1 downto 0);
             ForwardB       : out std_logic_vector(1 downto 0));
    end component;

    signal ID_EX_rs1      : std_logic_vector(4 downto 0);
    signal ID_EX_rs2      : std_logic_vector(4 downto 0);
    signal EX_Mem_rd      : std_logic_vector(4 downto 0);
    signal EX_Mem_RegWrite : std_logic;
    signal Mem_WB_rd      : std_logic_vector(4 downto 0);
    signal Mem_WB_RegWrite : std_logic;
    signal ForwardA       : std_logic_vector(1 downto 0);
    signal ForwardB       : std_logic_vector(1 downto 0);

begin
    uut: ForwardingUnit
        port map (
            ID_EX_rs1      => ID_EX_rs1,
            ID_EX_rs2      => ID_EX_rs2,
            EX_Mem_rd      => EX_Mem_rd,
            EX_Mem_RegWrite => EX_Mem_RegWrite,
            Mem_WB_rd      => Mem_WB_rd,
            Mem_WB_RegWrite => Mem_WB_RegWrite,
            ForwardA       => ForwardA,
            ForwardB       => ForwardB
        );

    process
    begin
        -- Test 1: No forwarding needed
        ID_EX_rs1 <= "00001";  -- Register 1
        ID_EX_rs2 <= "00010";  -- Register 2
        EX_Mem_rd <= "00011";  -- Different register
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00100";  -- Different register
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "00" report "Test 1 ForwardA failed" severity error;
        assert ForwardB = "00" report "Test 1 ForwardB failed" severity error;

        -- Test 2: EX/MEM forwarding for rs1
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00001";  -- Same as rs1
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00100";
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "10" report "Test 2 ForwardA failed" severity error;
        assert ForwardB = "00" report "Test 2 ForwardB failed" severity error;

        -- Test 3: EX/MEM forwarding for rs2
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00010";  -- Same as rs2
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00100";
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "00" report "Test 3 ForwardA failed" severity error;
        assert ForwardB = "10" report "Test 3 ForwardB failed" severity error;

        -- Test 4: MEM/WB forwarding for rs1
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00011";  -- Different register
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00001";  -- Same as rs1
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "01" report "Test 4 ForwardA failed" severity error;
        assert ForwardB = "00" report "Test 4 ForwardB failed" severity error;

        -- Test 5: MEM/WB forwarding for rs2
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00011";
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00010";  -- Same as rs2
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "00" report "Test 5 ForwardA failed" severity error;
        assert ForwardB = "01" report "Test 5 ForwardB failed" severity error;

        -- Test 6: EX/MEM priority over MEM/WB
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00001";  -- Same as rs1
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00001";  -- Also same as rs1
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "10" report "Test 6 ForwardA failed (EX/MEM should have priority)" severity error;
        assert ForwardB = "00" report "Test 6 ForwardB failed" severity error;

        -- Test 7: No forwarding when RegWrite is 0
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00001";
        EX_Mem_RegWrite <= '0';  -- Not writing
        Mem_WB_rd <= "00001";
        Mem_WB_RegWrite <= '0';  -- Not writing
        wait for 10 ns;
        assert ForwardA = "00" report "Test 7 ForwardA failed" severity error;
        assert ForwardB = "00" report "Test 7 ForwardB failed" severity error;

        -- Test 8: No forwarding to register x0
        ID_EX_rs1 <= "00000";  -- Register x0
        ID_EX_rs2 <= "00000";  -- Register x0
        EX_Mem_rd <= "00000";  -- Writing to x0
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00000";  -- Writing to x0
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "00" report "Test 8 ForwardA failed (should not forward to x0)" severity error;
        assert ForwardB = "00" report "Test 8 ForwardB failed (should not forward to x0)" severity error;

        -- Test 9: Both inputs forwarded from different stages
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00010";
        EX_Mem_rd <= "00001";  -- Forward rs1 from EX/MEM
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00010";  -- Forward rs2 from MEM/WB
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "10" report "Test 9 ForwardA failed" severity error;
        assert ForwardB = "01" report "Test 9 ForwardB failed" severity error;

        -- Test 10: Both inputs forwarded from same stage
        ID_EX_rs1 <= "00001";
        ID_EX_rs2 <= "00001";  -- Same register
        EX_Mem_rd <= "00001";
        EX_Mem_RegWrite <= '1';
        Mem_WB_rd <= "00010";
        Mem_WB_RegWrite <= '1';
        wait for 10 ns;
        assert ForwardA = "10" report "Test 10 ForwardA failed" severity error;
        assert ForwardB = "10" report "Test 10 ForwardB failed" severity error;

        report "All ForwardingUnit tests completed";
        wait;
    end process;

end testbench;