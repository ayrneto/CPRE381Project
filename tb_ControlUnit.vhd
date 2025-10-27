library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ControlUnit is
end tb_ControlUnit;

architecture testbench of tb_ControlUnit is
    component ControlUnit
        port (
            i_Opcode     : in  std_logic_vector(6 downto 0);
            i_funct3     : in  std_logic_vector(2 downto 0);
            i_funct7     : in  std_logic_vector(6 downto 0);
            o_Branch     : out std_logic;
            o_Jump       : out std_logic;
            o_MemRead    : out std_logic;
            o_MemToReg   : out std_logic;
            o_MemWrite   : out std_logic;
            o_AndLink    : out std_logic;
            o_ALUSrc     : out std_logic;
            o_RegWrite   : out std_logic;
            o_ImmType    : out std_logic_vector(1 downto 0);
            o_ALUControl : out std_logic_vector(3 downto 0)
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
    signal o_ImmType    : std_logic_vector(1 downto 0);
    signal o_ALUControl : std_logic_vector(3 downto 0);

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
            o_ALUControl => o_ALUControl
        );

    process
    begin
        -- Test ADD (R-type)
        i_Opcode  <= "0110011"; -- R-type
        i_funct3  <= "000";
        i_funct7  <= "0000000";
        wait for 10 ns;

        -- Test SUB (R-type)
        i_funct7  <= "0100000";
        wait for 10 ns;

        -- Test ADDI
        i_Opcode  <= "0010011";
        i_funct3  <= "000";
        wait for 10 ns;

        -- Test LW
        i_Opcode  <= "0000011";
        i_funct3  <= "010";
        wait for 10 ns;

        -- Test SW
        i_Opcode  <= "0100011";
        i_funct3  <= "010";
        wait for 10 ns;

        -- Test BEQ
        i_Opcode  <= "1100011";
        i_funct3  <= "000";
        wait for 10 ns;

        -- Test JAL
        i_Opcode  <= "1101111";
        wait for 10 ns;

        -- Test SLLI
        i_Opcode  <= "0010011";
        i_funct3  <= "001";
        i_funct7  <= "0000000";
        wait for 10 ns;

        wait;
    end process;
end testbench;
