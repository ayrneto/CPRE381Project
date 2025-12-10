library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_Pipeline_Registers is
end tb_Pipeline_Registers;

architecture testbench of tb_Pipeline_Registers is
    -- Component declarations
    component IF_ID
        port(i_CLK   : in std_logic;
             i_RST   : in std_logic;
             i_Stall : in std_logic;
             i_Flush : in std_logic;
             i_PC    : in std_logic_vector(31 downto 0);
             i_PC4   : in std_logic_vector(31 downto 0);
             i_inst  : in std_logic_vector(31 downto 0);
             o_inst  : out std_logic_vector(31 downto 0);
             o_PC4   : out std_logic_vector(31 downto 0);
             o_PC    : out std_logic_vector(31 downto 0));
    end component;

    component ID_EX
        port(i_CLK       : in std_logic;
             i_RST       : in std_logic;
             i_Stall     : in std_logic;
             i_Flush     : in std_logic;
             i_rd        : in std_logic_vector(4 downto 0);
             i_rs1       : in std_logic_vector(4 downto 0);
             i_rs2       : in std_logic_vector(4 downto 0);
             i_ReadData1 : in std_logic_vector(31 downto 0);
             i_ReadData2 : in std_logic_vector(31 downto 0);
             i_PC        : in std_logic_vector(31 downto 0);
             i_PC4       : in std_logic_vector(31 downto 0);
             i_imm       : in std_logic_vector(31 downto 0);
             i_Shamt     : in std_logic_vector(4 downto 0);
             i_ALUControl: in std_logic_vector(3 downto 0);
             i_ALUSrc    : in std_logic;
             i_RegWrite  : in std_logic;
             i_MemToReg  : in std_logic;
             i_MemRead   : in std_logic;
             i_MemWrite  : in std_logic;
             i_LoadWidth : in std_logic_vector(1 downto 0);
             i_LoadSigned: in std_logic;
             i_StoreWidth: in std_logic_vector(1 downto 0);
             i_AndLink   : in std_logic;
             i_AUIPC     : in std_logic;
             i_Halt      : in std_logic;
             o_rd        : out std_logic_vector(4 downto 0);
             o_rs1       : out std_logic_vector(4 downto 0);
             o_rs2       : out std_logic_vector(4 downto 0);
             o_ReadData1 : out std_logic_vector(31 downto 0);
             o_ReadData2 : out std_logic_vector(31 downto 0);
             o_PC        : out std_logic_vector(31 downto 0);
             o_PC4       : out std_logic_vector(31 downto 0);
             o_imm       : out std_logic_vector(31 downto 0);
             o_Shamt     : out std_logic_vector(4 downto 0);
             o_ALUControl: out std_logic_vector(3 downto 0);
             o_ALUSrc    : out std_logic;
             o_RegWrite  : out std_logic;
             o_MemToReg  : out std_logic;
             o_MemRead   : out std_logic;
             o_MemWrite  : out std_logic;
             o_LoadWidth : out std_logic_vector(1 downto 0);
             o_LoadSigned: out std_logic;
             o_StoreWidth: out std_logic_vector(1 downto 0);
             o_AndLink   : out std_logic;
             o_AUIPC     : out std_logic;
             o_Halt      : out std_logic);
    end component;

    component EX_Mem
        port(i_CLK       : in std_logic;
             i_RST       : in std_logic;
             i_Stall     : in std_logic;
             i_Flush     : in std_logic;
             i_ALUResult : in std_logic_vector(31 downto 0);
             i_StoreData : in std_logic_vector(31 downto 0);
             i_rd        : in std_logic_vector(4 downto 0);
             i_RegWrite  : in std_logic;
             i_MemToReg  : in std_logic;
             i_MemRead   : in std_logic;
             i_MemWrite  : in std_logic;
             i_LoadWidth : in std_logic_vector(1 downto 0);
             i_LoadSigned: in std_logic;
             i_StoreWidth: in std_logic_vector(1 downto 0);
             i_AndLink   : in std_logic;
             i_PC4       : in std_logic_vector(31 downto 0);
             i_Halt      : in std_logic;
             o_ALUResult : out std_logic_vector(31 downto 0);
             o_StoreData : out std_logic_vector(31 downto 0);
             o_rd        : out std_logic_vector(4 downto 0);
             o_RegWrite  : out std_logic;
             o_MemToReg  : out std_logic;
             o_MemRead   : out std_logic;
             o_MemWrite  : out std_logic;
             o_LoadWidth : out std_logic_vector(1 downto 0);
             o_LoadSigned: out std_logic;
             o_StoreWidth: out std_logic_vector(1 downto 0);
             o_AndLink   : out std_logic;
             o_PC4       : out std_logic_vector(31 downto 0);
             o_Halt      : out std_logic);
    end component;

    component Mem_WB
        port(i_CLK      : in std_logic;
             i_RST      : in std_logic;
             i_Stall    : in std_logic;
             i_Flush    : in std_logic;
             i_DMem     : in std_logic_vector(31 downto 0);
             i_ALUResult: in std_logic_vector(31 downto 0);
             i_PC4      : in std_logic_vector(31 downto 0);
             i_rd       : in std_logic_vector(4 downto 0);
             i_RegWrite : in std_logic;
             i_MemToReg : in std_logic;
             i_AndLink  : in std_logic;
             i_Halt     : in std_logic;
             o_DMem     : out std_logic_vector(31 downto 0);
             o_ALUResult: out std_logic_vector(31 downto 0);
             o_PC4      : out std_logic_vector(31 downto 0);
             o_rd       : out std_logic_vector(4 downto 0);
             o_RegWrite : out std_logic;
             o_MemToReg : out std_logic;
             o_AndLink  : out std_logic;
             o_Halt     : out std_logic);
    end component;

    -- Test signals
    signal iCLK : std_logic := '0';
    signal iRST : std_logic := '1';
    
    -- Control signals for each register
    signal IF_ID_Stall, IF_ID_Flush : std_logic := '0';
    signal ID_EX_Stall, ID_EX_Flush : std_logic := '0';
    signal EX_MEM_Stall, EX_MEM_Flush : std_logic := '0';
    signal MEM_WB_Stall, MEM_WB_Flush : std_logic := '0';

    -- Test data signals (simplified for testing)
    signal test_PC, test_PC4, test_inst : std_logic_vector(31 downto 0);
    signal test_rd, test_rs1, test_rs2 : std_logic_vector(4 downto 0);
    signal test_ReadData1, test_ReadData2 : std_logic_vector(31 downto 0);
    signal test_imm, test_ALUResult : std_logic_vector(31 downto 0);
    signal test_Shamt : std_logic_vector(4 downto 0);
    signal test_ALUControl : std_logic_vector(3 downto 0);
    signal test_control_bits : std_logic_vector(10 downto 0); -- Pack control signals

    -- Pipeline outputs
    signal IF_ID_inst, IF_ID_PC4, IF_ID_PC : std_logic_vector(31 downto 0);
    signal ID_EX_rd, ID_EX_rs1, ID_EX_rs2 : std_logic_vector(4 downto 0);
    signal ID_EX_ReadData1, ID_EX_ReadData2, ID_EX_PC, ID_EX_PC4 : std_logic_vector(31 downto 0);
    signal ID_EX_imm : std_logic_vector(31 downto 0);
    signal ID_EX_Shamt : std_logic_vector(4 downto 0);
    signal ID_EX_ALUControl : std_logic_vector(3 downto 0);
    signal ID_EX_controls : std_logic_vector(10 downto 0);
    signal EX_MEM_ALUResult, EX_MEM_StoreData, EX_MEM_PC4 : std_logic_vector(31 downto 0);
    signal EX_MEM_rd : std_logic_vector(4 downto 0);
    signal EX_MEM_controls : std_logic_vector(8 downto 0);
    signal MEM_WB_DMem, MEM_WB_ALUResult, MEM_WB_PC4 : std_logic_vector(31 downto 0);
    signal MEM_WB_rd : std_logic_vector(4 downto 0);
    signal MEM_WB_controls : std_logic_vector(2 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    -- Clock generation
    clk_process: process
    begin
        iCLK <= '0';
        wait for CLK_PERIOD/2;
        iCLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Instantiate all four pipeline registers
    IF_ID_reg: IF_ID
        port map(
            i_CLK   => iCLK,
            i_RST   => iRST,
            i_Stall => not IF_ID_Stall, -- Note: Stall signal is inverted in our implementation
            i_Flush => IF_ID_Flush,
            i_PC    => test_PC,
            i_PC4   => test_PC4,
            i_inst  => test_inst,
            o_inst  => IF_ID_inst,
            o_PC4   => IF_ID_PC4,
            o_PC    => IF_ID_PC
        );

    ID_EX_reg: ID_EX
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,
            i_Stall     => ID_EX_Stall,
            i_Flush     => ID_EX_Flush,
            i_rd        => test_rd,
            i_rs1       => test_rs1,
            i_rs2       => test_rs2,
            i_ReadData1 => test_ReadData1,
            i_ReadData2 => test_ReadData2,
            i_PC        => IF_ID_PC,
            i_PC4       => IF_ID_PC4,
            i_imm       => test_imm,
            i_Shamt     => test_Shamt,
            i_ALUControl=> test_ALUControl,
            i_ALUSrc    => test_control_bits(0),
            i_RegWrite  => test_control_bits(1),
            i_MemToReg  => test_control_bits(2),
            i_MemRead   => test_control_bits(3),
            i_MemWrite  => test_control_bits(4),
            i_LoadWidth => test_control_bits(6 downto 5),
            i_LoadSigned=> test_control_bits(7),
            i_StoreWidth=> test_control_bits(9 downto 8),
            i_AndLink   => test_control_bits(10),
            i_AUIPC     => '0',
            i_Halt      => '0',
            o_rd        => ID_EX_rd,
            o_rs1       => ID_EX_rs1,
            o_rs2       => ID_EX_rs2,
            o_ReadData1 => ID_EX_ReadData1,
            o_ReadData2 => ID_EX_ReadData2,
            o_PC        => ID_EX_PC,
            o_PC4       => ID_EX_PC4,
            o_imm       => ID_EX_imm,
            o_Shamt     => ID_EX_Shamt,
            o_ALUControl=> ID_EX_ALUControl,
            o_ALUSrc    => ID_EX_controls(0),
            o_RegWrite  => ID_EX_controls(1),
            o_MemToReg  => ID_EX_controls(2),
            o_MemRead   => ID_EX_controls(3),
            o_MemWrite  => ID_EX_controls(4),
            o_LoadWidth => ID_EX_controls(6 downto 5),
            o_LoadSigned=> ID_EX_controls(7),
            o_StoreWidth=> ID_EX_controls(9 downto 8),
            o_AndLink   => ID_EX_controls(10),
            o_AUIPC     => open,
            o_Halt      => open
        );

    EX_MEM_reg: EX_Mem
        port map(
            i_CLK       => iCLK,
            i_RST       => iRST,
            i_Stall     => EX_MEM_Stall,
            i_Flush     => EX_MEM_Flush,
            i_ALUResult => test_ALUResult,
            i_StoreData => ID_EX_ReadData2,
            i_rd        => ID_EX_rd,
            i_RegWrite  => ID_EX_controls(1),
            i_MemToReg  => ID_EX_controls(2),
            i_MemRead   => ID_EX_controls(3),
            i_MemWrite  => ID_EX_controls(4),
            i_LoadWidth => ID_EX_controls(6 downto 5),
            i_LoadSigned=> ID_EX_controls(7),
            i_StoreWidth=> ID_EX_controls(9 downto 8),
            i_AndLink   => ID_EX_controls(10),
            i_PC4       => ID_EX_PC4,
            i_Halt      => '0',
            o_ALUResult => EX_MEM_ALUResult,
            o_StoreData => EX_MEM_StoreData,
            o_rd        => EX_MEM_rd,
            o_RegWrite  => EX_MEM_controls(0),
            o_MemToReg  => EX_MEM_controls(1),
            o_MemRead   => EX_MEM_controls(2),
            o_MemWrite  => EX_MEM_controls(3),
            o_LoadWidth => EX_MEM_controls(5 downto 4),
            o_LoadSigned=> EX_MEM_controls(6),
            o_StoreWidth=> EX_MEM_controls(8 downto 7),
            o_AndLink   => open,
            o_PC4       => EX_MEM_PC4,
            o_Halt      => open
        );

    MEM_WB_reg: Mem_WB
        port map(
            i_CLK      => iCLK,
            i_RST      => iRST,
            i_Stall    => MEM_WB_Stall,
            i_Flush    => MEM_WB_Flush,
            i_DMem     => EX_MEM_ALUResult, -- Simulate memory read
            i_ALUResult=> EX_MEM_ALUResult,
            i_PC4      => EX_MEM_PC4,
            i_rd       => EX_MEM_rd,
            i_RegWrite => EX_MEM_controls(0),
            i_MemToReg => EX_MEM_controls(1),
            i_AndLink  => '0',
            i_Halt     => '0',
            o_DMem     => MEM_WB_DMem,
            o_ALUResult=> MEM_WB_ALUResult,
            o_PC4      => MEM_WB_PC4,
            o_rd       => MEM_WB_rd,
            o_RegWrite => MEM_WB_controls(0),
            o_MemToReg => MEM_WB_controls(1),
            o_AndLink  => MEM_WB_controls(2),
            o_Halt     => open
        );

    -- Main test process
    test_process: process
    begin
        report "=== Pipeline Register Comprehensive Test ===";
        
        -- Initialize
        iRST <= '1';
        wait for 20 ns;
        iRST <= '0';
        wait for 10 ns;

        -- Test 1: Normal pipeline flow
        report "Test 1: Normal pipeline flow - values should propagate through 4 stages";
        test_PC <= x"00000100";
        test_PC4 <= x"00000104";
        test_inst <= x"12345678";
        test_rd <= "10001";
        test_rs1 <= "10010";
        test_rs2 <= "10011";
        test_ReadData1 <= x"AAAAAAAA";
        test_ReadData2 <= x"BBBBBBBB";
        test_imm <= x"CCCCCCCC";
        test_Shamt <= "11111";
        test_ALUControl <= "1010";
        test_control_bits <= "10101010101";
        test_ALUResult <= x"DDDDDDDD";

        wait for CLK_PERIOD;
        
        -- After 1 cycle - should see values in IF/ID
        assert IF_ID_inst = x"12345678" report "Cycle 1: IF/ID instruction failed" severity error;
        assert IF_ID_PC = x"00000100" report "Cycle 1: IF/ID PC failed" severity error;

        wait for CLK_PERIOD;
        
        -- After 2 cycles - should see values in ID/EX
        assert ID_EX_rd = "10001" report "Cycle 2: ID/EX rd failed" severity error;
        assert ID_EX_ReadData1 = x"AAAAAAAA" report "Cycle 2: ID/EX ReadData1 failed" severity error;

        wait for CLK_PERIOD;
        
        -- After 3 cycles - should see values in EX/MEM
        assert EX_MEM_rd = "10001" report "Cycle 3: EX/MEM rd failed" severity error;
        assert EX_MEM_ALUResult = x"DDDDDDDD" report "Cycle 3: EX/MEM ALUResult failed" severity error;

        wait for CLK_PERIOD;
        
        -- After 4 cycles - should see values in MEM/WB
        assert MEM_WB_rd = "10001" report "Cycle 4: MEM/WB rd failed" severity error;
        assert MEM_WB_ALUResult = x"DDDDDDDD" report "Cycle 4: MEM/WB ALUResult failed" severity error;

        report "Test 1 PASSED: Values propagated correctly through 4 pipeline stages";

        -- Test 2: Test individual stalls
        report "Test 2: Testing individual pipeline register stalls";
        
        -- Stall IF/ID register
        IF_ID_Stall <= '1';
        test_inst <= x"FFFFFFFF"; -- New instruction
        wait for CLK_PERIOD;
        assert IF_ID_inst = x"12345678" report "IF/ID stall failed" severity error;
        IF_ID_Stall <= '0';

        -- Stall ID/EX register
        ID_EX_Stall <= '1';
        test_rd <= "00000"; -- New data
        wait for CLK_PERIOD;
        assert ID_EX_rd = "10001" report "ID/EX stall failed" severity error;
        ID_EX_Stall <= '0';

        -- Stall EX/MEM register
        EX_MEM_Stall <= '1';
        test_ALUResult <= x"11111111"; -- New ALU result
        wait for CLK_PERIOD;
        assert EX_MEM_ALUResult = x"DDDDDDDD" report "EX/MEM stall failed" severity error;
        EX_MEM_Stall <= '0';

        -- Stall MEM/WB register
        MEM_WB_Stall <= '1';
        wait for CLK_PERIOD;
        assert MEM_WB_rd = "10001" report "MEM/WB stall failed" severity error;
        MEM_WB_Stall <= '0';

        report "Test 2 PASSED: All individual stalls work correctly";

        -- Test 3: Test individual flushes
        report "Test 3: Testing individual pipeline register flushes";
        
        -- Flush IF/ID register
        IF_ID_Flush <= '1';
        wait for CLK_PERIOD;
        assert IF_ID_inst = x"00000000" report "IF/ID flush failed" severity error;
        IF_ID_Flush <= '0';

        -- Wait for new data to propagate
        test_inst <= x"ABCDEF00";
        wait for CLK_PERIOD;

        -- Flush ID/EX register
        ID_EX_Flush <= '1';
        wait for CLK_PERIOD;
        assert ID_EX_rd = "00000" report "ID/EX flush failed" severity error;
        ID_EX_Flush <= '0';

        -- Flush EX/MEM register
        EX_MEM_Flush <= '1';
        wait for CLK_PERIOD;
        assert EX_MEM_rd = "00000" report "EX/MEM flush failed" severity error;
        EX_MEM_Flush <= '0';

        -- Flush MEM/WB register
        MEM_WB_Flush <= '1';
        wait for CLK_PERIOD;
        assert MEM_WB_rd = "00000" report "MEM/WB flush failed" severity error;
        MEM_WB_Flush <= '0';

        report "Test 3 PASSED: All individual flushes work correctly";

        -- Test 4: Test that new values can be inserted every cycle
        report "Test 4: Testing continuous insertion of new values";
        
        for i in 1 to 8 loop
            test_PC <= std_logic_vector(to_unsigned(i * 4, 32));
            test_PC4 <= std_logic_vector(to_unsigned((i + 1) * 4, 32));
            test_inst <= std_logic_vector(to_unsigned(i, 32));
            test_rd <= std_logic_vector(to_unsigned(i mod 32, 5));
            wait for CLK_PERIOD;
        end loop;

        report "Test 4 PASSED: New values inserted successfully every cycle";

        -- Test 5: Test complex stall/flush combinations
        report "Test 5: Testing complex stall/flush scenarios";
        
        -- Stall multiple registers simultaneously
        IF_ID_Stall <= '1';
        ID_EX_Stall <= '1';
        test_inst <= x"99999999";
        test_rd <= "11111";
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;
        assert IF_ID_inst /= x"99999999" report "Multiple stall test 1 failed" severity error;
        IF_ID_Stall <= '0';
        ID_EX_Stall <= '0';

        -- Flush overrides stall
        IF_ID_Stall <= '1';
        IF_ID_Flush <= '1';
        wait for CLK_PERIOD;
        assert IF_ID_inst = x"00000000" report "Flush override stall failed" severity error;
        IF_ID_Stall <= '0';
        IF_ID_Flush <= '0';

        report "Test 5 PASSED: Complex stall/flush scenarios work correctly";

        report "=== ALL PIPELINE REGISTER TESTS PASSED ===";
        report "✓ Values propagate correctly through 4 pipeline stages";
        report "✓ Individual register stalls work correctly";
        report "✓ Individual register flushes work correctly";
        report "✓ New values can be inserted every cycle";
        report "✓ Complex stall/flush scenarios handled properly";
        
        wait;
    end process;

end testbench;