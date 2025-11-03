library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1_32b is
    port(i_A	: in std_logic_vector(31 downto 0);
	 i_B	: in std_logic_vector(31 downto 0);
	 i_Sel	: in std_logic;
	 o_Out	: out std_logic_vector(31 downto 0));
end mux2to1_32b;

architecture structural of mux2to1_32b is
    component mux2t1_N is
	generic(N : integer := 32);
  	port(i_S     : in std_logic;
       	i_D0         : in std_logic_vector(N-1 downto 0);
       	i_D1         : in std_logic_vector(N-1 downto 0);
       	o_O          : out std_logic_vector(N-1 downto 0));
    end component;

begin

    MUX : mux2t1_N
	port map(i_D0	=> i_A,
		 i_D1	=> i_B,
		 i_S	=> i_Sel,
		 o_O	=> o_Out);

end structural;