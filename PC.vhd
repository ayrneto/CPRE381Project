library IEEE;
use IEEE.std_logic_1164.all;

-- PC (Program Counter): A register, that has Write Enable always on and holds the value of the next instruction's address as input, and outputs the current address
entity PC is
    port(i_CLK	: in std_logic;
         i_RST	: in std_logic;
	 i_WE	: in std_logic;
	 i_D	: in std_logic_vector(31 downto 0);
	 o_Q	: out std_logic_vector(31 downto 0));
    end PC;

architecture structural of PC is
    component NBitRegister is
	generic(N : integer := 32);
        port(   i_CLK	: in std_logic;
         	i_RST	: in std_logic;
	 	i_WE	: in std_logic;
	 	i_D	: in std_logic_vector(N-1 downto 0);
	 	o_Q	: out std_logic_vector(N-1 downto 0));
    end component;


begin

    PC_Reg : NBitRegister
	port map(i_CLK	=> i_CLK,
		 i_RST	=> i_RST,
		 i_WE	=> '1',
		 i_D	=> i_D,
		 o_Q	=> o_Q);

end structural;