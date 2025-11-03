library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Ayr Nasser Neto
entity ALU is
    port(i_A	      : std_logic_vector(31 downto 0);
	 i_B   	      : std_logic_vector(31 downto 0);
	 i_ALUControl : std_logic_vector(3 downto 0);
	 i_shamt      : std_logic_vector(4 downto 0);
	 o_ALUOut     : std_logic_vector(31 downto 0));
end ALU;

architecture structural of ALU is

    component AddSub_32b is
	port(i_A	  : in std_logic_vector(31 downto 0);
	     i_B	  : in std_logic_vector(31 downto 0);
	     nAdd_Sub 	  : in std_logic;
	     o_Result 	  : out std_logic_vector(31 downto 0);
	     o_CarryOut   : out std_logic);
    end component;

    signal

begin

    
	 