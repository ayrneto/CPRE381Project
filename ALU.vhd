library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity ALU is
    port(i_A	      : in std_logic_vector(31 downto 0);
	 i_B   	      : in std_logic_vector(31 downto 0);
	 i_ALUControl : in std_logic_vector(3 downto 0);
	 i_shamt      : in std_logic_vector(4 downto 0);
	 o_ALUOut     : out std_logic_vector(31 downto 0);
	 o_Zero       : out std_logic);

end ALU;

architecture structural of ALU is

    component AddSub_32b is
	port(i_A	  : in std_logic_vector(31 downto 0);
	     i_B	  : in std_logic_vector(31 downto 0);
	     nAdd_Sub 	  : in std_logic_vector(1 downto 0);
	     o_Result 	  : out std_logic_vector(31 downto 0);
	     o_CarryOut   : out std_logic);
    end component;

    component ALUDecoder is
	port(i_ALUControl : in std_logic_vector(3 downto 0);
	     o_Out	  : out std_logic_vector(1 downto 0));
    end component;

    component LogicUnit is
	port(i_A	: in std_logic_vector(31 downto 0);
	     i_B	: in std_logic_vector(31 downto 0);
	     i_Sel	: in std_logic_vector(1 downto 0);
	     o_Out	: out std_logic_vector(31 downto 0));
    end component;

    component BarrelShifter is
	port(i_Data	: in std_logic_vector(31 downto 0);
	     i_ShiftAmt : in std_logic_vector(4 downto 0);
	     i_Mode	: in std_logic_vector(3 downto 0);
	     o_Result	: out std_logic_vector(31 downto 0));
    end component;


    signal s_ALUDecoder : std_logic_vector(1 downto 0);
    signal s_AddSub_32b : std_logic_vector(31 downto 0);
    signal s_LogicUnit : std_logic_vector(31 downto 0);
    signal s_BarrelShifter : std_logic_vector(31 downto 0);


begin

    AddSub : AddSub_32b
	port map(i_A	=> i_A,
		 i_B	=> i_B,
		 nAdd_Sub => s_ALUDecoder,
		 o_Result => s_AddSub_32b);

    Decoder : ALUDecoder
	port map(i_ALUControl	=> i_ALUControl,
		 o_Out		=> s_ALUDecoder);

    Logic : LogicUnit
	port map(i_A	=> i_A,
		 i_B	=> i_B,
		 i_Sel	=> s_ALUDecoder,
		 o_Out	=> s_LogicUnit);

    Shifter : BarrelShifter
	port map(i_Data		=> i_B,
		 i_ShiftAmt	=> i_shamt,
		 i_Mode		=> i_ALUControl,
		 o_Result	=> s_BarrelShifter);

    with i_ALUControl select
	o_ALUOut <=	s_AddSub_32b when "0010" | "0110" | "0111" | "1000",
			s_LogicUnit when "0000" | "0001" | "0011" | "1100",
			s_BarrelShifter when others;

    process(o_ALUOut)
	begin
	if(o_ALUOut = x"00000000") then
	    o_Zero <= '1';

	else
	    o_Zero <= '0';

	end if;
    end process;
end structural;

    
	













    
	 