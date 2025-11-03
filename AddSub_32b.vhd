library IEEE;
use IEEE.std_logic_1164.all;

-- Ayr Nasser Neto
-- Normal AddSub, but with a nAdd_Sub extension of 1 bit. Functions the same.
entity AddSub_32b is 
    generic(N : integer := 32);
    port(i_A	  : in std_logic_vector(31 downto 0);
	 i_B	  : in std_logic_vector(31 downto 0);
	 nAdd_Sub : in std_logic_vector(1 downto 0);
	 o_Result : out std_logic_vector(31 downto 0);
	 o_CarryOut : out std_logic);
end AddSub_32b;

architecture structural of AddSub_32b is
    component OnesComp is
	port(i_A	: in std_logic_vector(31 downto 0);
	     o_O	: out std_logic_vector(31 downto 0));
    end component;

    component mux2t1_N is
	generic(N : integer := 32);
	port(i_S          : in std_logic;
       	     i_D0         : in std_logic_vector(31 downto 0);
             i_D1         : in std_logic_vector(31 downto 0);
             o_O          : out std_logic_vector(31 downto 0));
    end component;

    component Adder_N is
	port(i_A		: in std_logic_vector(31 downto 0);
             i_B		: in std_logic_vector(31 downto 0);
	     i_CarryIn	      	: in std_logic;
	     o_Sum		: out std_logic_vector(31 downto 0);
	     o_CarryOut		: out std_logic);
    end component;

    signal s_Inverter 	: std_logic_vector(31 downto 0);
    signal s_MUX	: std_logic_vector(31 downto 0);
    signal s_nAdd_Sub	: std_logic;


begin

    with nAdd_Sub select s_nAdd_Sub
	<= '0' when "00",
	'1' when others;

    g_Inverter : OnesComp
	port map(i_A	=> i_B,
		 o_O	=> s_Inverter);

    g_MUX : mux2t1_N
	port map(i_S	=> s_nAdd_Sub,
		 i_D0	=> i_B,
		 i_D1	=> s_Inverter,
		 o_O	=> s_MUX);

    g_Adder : Adder_N
	port map(i_A		=> i_A,
		 i_B		=> s_MUX,
		 i_CarryIn   	=> s_nAdd_Sub,
		 o_Sum		=> o_Result,
		 o_CarryOut	=> o_CarryOut);

end structural;











 