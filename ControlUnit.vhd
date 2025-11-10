library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ControlUnit is
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
        o_ImmType    : out std_logic_vector(2 downto 0);
        o_ALUControl : out std_logic_vector(3 downto 0);
        o_LoadWidth  : out std_logic_vector(1 downto 0); -- 00=byte,01=half,10=word
        o_LoadSigned : out std_logic;                    -- 1=signed extend, 0=zero extend
        o_StoreWidth : out std_logic_vector(1 downto 0); -- matches o_LoadWidth encoding
        o_BranchType : out std_logic_vector(2 downto 0); -- pass through funct3 for branch unit
        o_Halt       : out std_logic                     -- asserted on wfi "halt" instruction
    );
end ControlUnit;

architecture Behavioral of ControlUnit is

    -- ALU control encoding
    constant ALU_AND : std_logic_vector(3 downto 0) := "0000";
    constant ALU_OR : std_logic_vector(3 downto 0) := "0001";
    constant ALU_ADD : std_logic_vector(3 downto 0) := "0010";
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0011";
    constant ALU_SLL : std_logic_vector(3 downto 0) := "0100";
    constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
    constant ALU_SUB : std_logic_vector(3 downto 0) := "0110";
    constant ALU_SLT : std_logic_vector(3 downto 0) := "0111";
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1000";
    constant ALU_SRA: std_logic_vector(3 downto 0) := "1001";
    constant ALU_PASSIMM : std_logic_vector(3 downto 0) := "1010"; -- for LUI
    constant ALU_NOR : std_logic_vector(3 downto 0) := "1100"; -- NOR

begin

    process(i_Opcode, i_funct3, i_funct7)
    begin
        -- Default values
        o_Branch     <= '0';
        o_Jump       <= '0';
        o_MemRead    <= '0';
        o_MemToReg   <= '0';
        o_MemWrite   <= '0';
        o_AndLink    <= '0';
        o_ALUSrc     <= '0';
        o_RegWrite   <= '0';
        o_ImmType    <= "000";
        o_ALUControl <= ALU_ADD;
        o_LoadWidth  <= "10";
        o_LoadSigned <= '1';
        o_StoreWidth <= "10";
        o_BranchType <= "000";
        o_Halt       <= '0';

        case i_Opcode is
            when "0110011" =>  -- R-type
                o_RegWrite <= '1';
                case i_funct3 is
                    when "000" =>
                        if i_funct7 = "0000000" then
                            o_ALUControl <= ALU_ADD;
                        elsif i_funct7 = "0100000" then
                            o_ALUControl <= ALU_SUB;
                        end if;
                    when "111" => o_ALUControl <= ALU_AND;
                    when "110" => o_ALUControl <= ALU_OR;
                    when "100" => o_ALUControl <= ALU_XOR;
                    when "001" => o_ALUControl <= ALU_SLL;
                    when "101" =>
                        if i_funct7 = "0000000" then
                            o_ALUControl <= ALU_SRL;
                        elsif i_funct7 = "0100000" then
                            o_ALUControl <= ALU_SRA;
                        end if;
                    when "010" => o_ALUControl <= ALU_SLT;
                    when "011" => o_ALUControl <= ALU_SLTU;
                    when others => null;
                end case;

            when "0010011" =>  -- I-type ALU immediate
                o_ALUSrc   <= '1';
                o_RegWrite <= '1';
                o_ImmType  <= "000";
                case i_funct3 is
                    when "000" => o_ALUControl <= ALU_ADD;   -- addi
                    when "111" => o_ALUControl <= ALU_AND;   -- andi
                    when "110" => o_ALUControl <= ALU_OR;    -- ori
                    when "100" => o_ALUControl <= ALU_XOR;   -- xori
                    when "001" => o_ALUControl <= ALU_SLL;   -- slli
                    when "101" =>
                        if i_funct7 = "0000000" then
                            o_ALUControl <= ALU_SRL;         -- srli
                        elsif i_funct7 = "0100000" then
                            o_ALUControl <= ALU_SRA;         -- srai
                        end if;
                    when "010" => o_ALUControl <= ALU_SLT;   -- slti
                    when "011" => o_ALUControl <= ALU_SLTU;  -- sltiu
                    when others => null;
                end case;

            when "0000011" =>  -- Load
                o_ALUSrc     <= '1';
                o_RegWrite   <= '1';
                o_MemRead    <= '1';
                o_MemToReg   <= '1';
                o_ImmType    <= "000";
                o_ALUControl <= ALU_ADD;
                case i_funct3 is
                    when "000" => -- lb
                        o_LoadWidth  <= "00";
                        o_LoadSigned <= '1';
                    when "001" => -- lh
                        o_LoadWidth  <= "01";
                        o_LoadSigned <= '1';
                    when "010" => -- lw
                        o_LoadWidth  <= "10";
                        o_LoadSigned <= '1';
                    when "100" => -- lbu
                        o_LoadWidth  <= "00";
                        o_LoadSigned <= '0';
                    when "101" => -- lhu
                        o_LoadWidth  <= "01";
                        o_LoadSigned <= '0';
                    when others => null;
                end case;

            when "0100011" =>  -- Store
                o_ALUSrc   <= '1';
                o_MemWrite <= '1';
                o_ImmType  <= "001";
                o_ALUControl <= ALU_ADD;
                case i_funct3 is
                    when "000" => -- sb
                        o_StoreWidth <= "00";
                    when "001" => -- sh
                        o_StoreWidth <= "01";
                    when "010" => -- sw
                        o_StoreWidth <= "10";
                    when others => null;
                end case;

            when "1100011" =>  -- Branches
                o_Branch    <= '1';
                o_ImmType   <= "010";
                o_ALUControl<= ALU_SUB;
                o_BranchType<= i_funct3;

            when "1101111" =>  -- JAL
                o_Jump      <= '1';
                o_AndLink   <= '1';
                o_RegWrite  <= '1';
                o_ImmType   <= "100";

            when "1100111" =>  -- JALR
                o_Jump      <= '1';
                o_AndLink   <= '1';
                o_RegWrite  <= '1';
                o_ALUSrc    <= '1';
                o_ALUControl<= ALU_ADD;
                o_ImmType   <= "000";

            when "0110111" =>  -- LUI
                o_ALUSrc     <= '1';
                o_RegWrite   <= '1';
                o_ALUControl <= ALU_PASSIMM;
                o_ImmType    <= "011";

            when "0010111" =>  -- AUIPC
                o_ALUSrc     <= '1';
                o_RegWrite   <= '1';
                o_ALUControl <= ALU_ADD;
                o_ImmType    <= "011";

            when "1110011" =>  -- SYSTEM (used for WFI/HALT)
                if i_funct7 = "0001000" and i_funct3 = "000" then
                    o_Halt <= '1';
                end if;

            when others =>
                null;
        end case;
    end process;

end Behavioral;