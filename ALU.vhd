library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity ALU is
    port(i_A        : in  std_logic_vector(31 downto 0);
         i_B        : in  std_logic_vector(31 downto 0);
         i_ALUControl : in  std_logic_vector(3 downto 0);
         i_shamt    : in  std_logic_vector(4 downto 0);
         o_ALUOut   : out std_logic_vector(31 downto 0));
end ALU;

architecture structural of ALU is

    component AddSub_32b is
        generic(N : integer := 32);
    port(i_A	  : in std_logic_vector(N-1 downto 0);
         i_B	  : in std_logic_vector(N-1 downto 0);
         nAdd_Sub 	  : in std_logic_vector(1 downto 0);
         o_Result 	  : out std_logic_vector(N-1 downto 0);
         o_CarryOut   : out std_logic);
    end component;

    component LogicUnit is
	port(i_A	: in std_logic_vector(31 downto 0);
	     i_B	: in std_logic_vector(31 downto 0);
	     i_Sel	: in std_logic_vector(1 downto 0);
	     o_Out	: out std_logic_vector(31 downto 0));
    end component;

    component BarrelShifter is
	port(i_Data     : in  std_logic_vector(31 downto 0);
	     i_ShiftAmt : in  std_logic_vector(4 downto 0);
	     i_Mode     : in  std_logic_vector(3 downto 0);
	     o_Result   : out std_logic_vector(31 downto 0));
    end component;

    -- ALU control encoding (matching ControlUnit.vhd)
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
    constant ALU_PASSIMM : std_logic_vector(3 downto 0) := "1010";
    constant ALU_NOR : std_logic_vector(3 downto 0) := "1100";

    -- Internal signals
    signal s_AddSub_Result : std_logic_vector(31 downto 0);
    signal s_AddSub_CarryOut : std_logic;
    signal s_Logic_Result : std_logic_vector(31 downto 0);
    signal s_Shift_Result : std_logic_vector(31 downto 0);
    signal s_SLT_Result : std_logic_vector(31 downto 0);
    signal s_SLTU_Result : std_logic_vector(31 downto 0);
    signal s_AddSub_Control : std_logic_vector(1 downto 0);
    signal s_Logic_Control : std_logic_vector(1 downto 0);
    signal s_A_signed : signed(31 downto 0);
    signal s_B_signed : signed(31 downto 0);
    signal s_A_unsigned : unsigned(31 downto 0);
    signal s_B_unsigned : unsigned(31 downto 0);

begin

    -- Convert inputs for comparison operations
    s_A_signed <= signed(i_A);
    s_B_signed <= signed(i_B);
    s_A_unsigned <= unsigned(i_A);
    s_B_unsigned <= unsigned(i_B);

    -- Control signal generation for AddSub unit
    s_AddSub_Control <= "01" when (i_ALUControl = ALU_SUB) else "00";

    -- Control signal generation for Logic unit
    s_Logic_Control <= "00" when (i_ALUControl = ALU_AND) else
                      "01" when (i_ALUControl = ALU_OR) else
                      "10" when (i_ALUControl = ALU_XOR) else
                      "11"; -- NOR

    -- AddSub unit instantiation
    AddSub_Unit : AddSub_32b
	port map(i_A => i_A,
		 i_B => i_B,
		 nAdd_Sub => s_AddSub_Control,
		 o_Result => s_AddSub_Result,
		 o_CarryOut => s_AddSub_CarryOut);

    -- Logic unit instantiation
    Logic_Unit_inst : LogicUnit
	port map(i_A => i_A,
		 i_B => i_B,
		 i_Sel => s_Logic_Control,
		 o_Out => s_Logic_Result);

    -- Barrel shifter instantiation
    Shifter_Unit : BarrelShifter
	port map(i_Data => i_A,
		 i_ShiftAmt => i_shamt,
		 i_Mode => i_ALUControl,
		 o_Result => s_Shift_Result);

    -- Set-less-than operations
    s_SLT_Result <= x"00000001" when (s_A_signed < s_B_signed) else x"00000000";
    s_SLTU_Result <= x"00000001" when (s_A_unsigned < s_B_unsigned) else x"00000000";

    -- Output multiplexer
    process(i_ALUControl, s_AddSub_Result, s_Logic_Result, s_Shift_Result, s_SLT_Result, s_SLTU_Result, i_B)
    begin
        case i_ALUControl is
            when ALU_ADD | ALU_SUB =>
                o_ALUOut <= s_AddSub_Result;
            when ALU_AND | ALU_OR | ALU_XOR | ALU_NOR =>
                o_ALUOut <= s_Logic_Result;
            when ALU_SLL | ALU_SRL | ALU_SRA =>
                o_ALUOut <= s_Shift_Result;
            when ALU_SLT =>
                o_ALUOut <= s_SLT_Result;
            when ALU_SLTU =>
                o_ALUOut <= s_SLTU_Result;
            when ALU_PASSIMM =>
                o_ALUOut <= i_B; -- Pass immediate for LUI
            when others =>
                o_ALUOut <= s_AddSub_Result; -- Default to ADD
        end case;
    end process;
end structural;
    

	 
