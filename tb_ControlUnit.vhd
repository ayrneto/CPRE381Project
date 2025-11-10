library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ControlUnit is
end tb_ControlUnit;

architecture testbench of tb_ControlUnit is
    component ControlUnit
        port (
            i_Opcode     : in  std_logic_vector(6 downto 0); -- opcode bits
            i_funct3     : in  std_logic_vector(2 downto 0); -- funct3 field
            i_funct7     : in  std_logic_vector(6 downto 0); -- funct7 field
            o_Branch     : out std_logic;                    -- branch enable
            o_Jump       : out std_logic;                    -- jump enable
            o_MemRead    : out std_logic;                    -- data memory read
            o_MemToReg   : out std_logic;                    -- write-back selects mem
            o_MemWrite   : out std_logic;                    -- data memory write
            o_AndLink    : out std_logic;                    -- link register write
            o_ALUSrc     : out std_logic;                    -- selects immediate to ALU
            o_RegWrite   : out std_logic;                    -- register write enable
            o_ImmType    : out std_logic_vector(2 downto 0); -- immediate decoder select
            o_ALUControl : out std_logic_vector(3 downto 0); -- ALU operation
            o_LoadWidth  : out std_logic_vector(1 downto 0); -- load width control
            o_LoadSigned : out std_logic;                    -- load sign/zero select
            o_StoreWidth : out std_logic_vector(1 downto 0); -- store width control
            o_BranchType : out std_logic_vector(2 downto 0); -- branch comparator select
            o_Halt       : out std_logic                     -- halt flag for WFI
        );
    end component;

    signal i_Opcode     : std_logic_vector(6 downto 0);
    signal i_funct3     : std_logic_vector(2 downto 0);
    signal i_funct7     : std_logic_vector(6 downto 0);
    signal o_Branch     : std_logic;
    signal o_Jump       : std_logic;
    signal o_MemRead    : std_logic;
    signal o_MemToReg   : std_logic;
    signal o_MemWrite   : std_logic;
    signal o_AndLink    : std_logic;
    signal o_ALUSrc     : std_logic;
    signal o_RegWrite   : std_logic;
    signal o_ImmType    : std_logic_vector(2 downto 0);
    signal o_ALUControl : std_logic_vector(3 downto 0);
    signal o_LoadWidth  : std_logic_vector(1 downto 0);
    signal o_LoadSigned : std_logic;
    signal o_StoreWidth : std_logic_vector(1 downto 0);
    signal o_BranchType : std_logic_vector(2 downto 0);
    signal o_Halt       : std_logic;

begin
    uut: ControlUnit
        port map (
            i_Opcode     => i_Opcode,
            i_funct3     => i_funct3,
            i_funct7     => i_funct7,
            o_Branch     => o_Branch,
            o_Jump       => o_Jump,
            o_MemRead    => o_MemRead,
            o_MemToReg   => o_MemToReg,
            o_MemWrite   => o_MemWrite,
            o_AndLink    => o_AndLink,
            o_ALUSrc     => o_ALUSrc,
            o_RegWrite   => o_RegWrite,
            o_ImmType    => o_ImmType,
            o_ALUControl => o_ALUControl,
            o_LoadWidth  => o_LoadWidth,
            o_LoadSigned => o_LoadSigned,
            o_StoreWidth => o_StoreWidth,
            o_BranchType => o_BranchType,
            o_Halt       => o_Halt
        );

    process
    begin
        -- Test 1: ADD (R-type)
        i_Opcode  <= "0110011"; -- R-type
        i_funct3  <= "000";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0010 (ADD)

        -- Test 2: SUB (R-type)
        i_funct7  <= "0100000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0110 (SUB)

        -- Test 3: AND (R-type)
        i_funct3  <= "111";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0000 (AND)

        -- Test 4: OR (R-type)
        i_funct3  <= "110";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0001 (OR)

        -- Test 5: XOR (R-type)
        i_funct3  <= "100";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0011 (XOR)

        -- Test 6: SLL (R-type)
        i_funct3  <= "001";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0100 (SLL)

        -- Test 7: SRL (R-type)
        i_funct3  <= "101";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0101 (SRL)

        -- Test 8: SRA (R-type)
        i_funct7  <= "0100000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=1001 (SRA)

        -- Test 9: SLT (R-type)
        i_funct3  <= "010";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=0111 (SLT)

        -- Test 10: SLTU (R-type)
        i_funct3  <= "011";
        wait for 10 ns;
        -- Expected: RegWrite=1, ALUControl=1000 (SLTU)

        -- Test 11: ADDI (I-type)
        i_Opcode  <= "0010011";
        i_funct3  <= "000";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0010

        -- Test 12: ANDI (I-type)
        i_funct3  <= "111";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0000

        -- Test 13: ORI (I-type)
        i_funct3  <= "110";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0001

        -- Test 14: XORI (I-type)
        i_funct3  <= "100";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0011

        -- Test 15: SLLI (I-type)
        i_funct3  <= "001";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0100

        -- Test 16: SRLI (I-type)
        i_funct3  <= "101";
        i_funct7  <= "0000000";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0101

        -- Test 17: SRAI (I-type)
        i_funct7  <= "0100000";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=1001

        -- Test 18: SLTI (I-type)
        i_funct3  <= "010";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=0111

        -- Test 19: SLTIU (I-type)
        i_funct3  <= "011";
        wait for 10 ns;
        -- Expected: ALUSrc=1, RegWrite=1, ImmType=000, ALUControl=1000

    -- Test 20: LW (Load)
    i_Opcode  <= "0000011";
    i_funct3  <= "010";
    wait for 10 ns;
    -- Expected: ALUSrc=1, RegWrite=1, MemRead=1, MemToReg=1, ImmType=000
    assert o_LoadWidth = "10" and o_LoadSigned = '1'
        report "Load control decode mismatch for LW" severity error;

    -- Test 21: SW (Store)
    i_Opcode  <= "0100011";
    i_funct3  <= "010";
    wait for 10 ns;
    -- Expected: ALUSrc=1, MemWrite=1, ImmType=001
    assert o_StoreWidth = "10"
        report "Store control decode mismatch for SW" severity error;

    -- Test 22: BEQ (Branch)
    i_Opcode  <= "1100011";
    i_funct3  <= "000";
    wait for 10 ns;
    -- Expected: Branch=1, ImmType=010, ALUControl=0110 (SUB for comparison)
    assert o_BranchType = "000"
        report "Branch control decode mismatch for BEQ" severity error;

    -- Test 23: JAL (Jump and Link)
    i_Opcode  <= "1101111";
    wait for 10 ns;
    -- Expected: Jump=1, AndLink=1, RegWrite=1, ImmType=100

    -- Test 24: JALR (Jump and Link Register)
    i_Opcode  <= "1100111";
    wait for 10 ns;
    -- Expected: Jump=1, AndLink=1, RegWrite=1, ALUSrc=1, ImmType=000

    -- Test 25: LUI (Load Upper Immediate)
    i_Opcode  <= "0110111";
    wait for 10 ns;
    -- Expected: ALUSrc=1, RegWrite=1, ALUControl=1010 (PASSIMM), ImmType=011

    -- Test 26: AUIPC (Add Upper Immediate to PC)
    i_Opcode  <= "0010111";
    wait for 10 ns;
    -- Expected: ALUSrc=1, RegWrite=1, ALUControl=0010 (ADD), ImmType=011

    -- Test 27: WFI (System Halt)
    i_Opcode  <= "1110011";
    i_funct3  <= "000";
    i_funct7  <= "0001000";
    wait for 10 ns;
    assert o_Halt = '1'
        report "Halt control not asserted for WFI" severity error;

    -- Test 28: Invalid opcode
    i_Opcode  <= "1111111";
    wait for 10 ns;
    -- Expected: Default values (all control signals should be 0 except ALUControl=0010)

        report "ControlUnit testbench completed";
        wait;
    end process;
end testbench;
