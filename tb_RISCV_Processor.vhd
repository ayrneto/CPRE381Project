library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RISCV_Processor is
end tb_RISCV_Processor;

architecture sim of tb_RISCV_Processor is
  constant c_CLK_PERIOD : time := 10 ns;

  signal s_CLK      : std_logic := '0';
  signal s_RST      : std_logic := '1';
  signal s_InstLd   : std_logic := '0';
  signal s_InstAddr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_InstExt  : std_logic_vector(31 downto 0) := (others => '0');
  signal s_ALUOut   : std_logic_vector(31 downto 0);

  type t_program is array(natural range <>) of std_logic_vector(31 downto 0);
  constant c_program : t_program := (
    x"00500093", -- addi x1, x0, 5
    x"00600113", -- addi x2, x0, 6
    x"002081B3", -- add x3, x1, x2
    x"00000013", -- nop
    x"00000073"  -- ecall (acts as halt marker)
  );
begin
  clk_gen : process
  begin
    wait for c_CLK_PERIOD / 2;
    s_CLK <= not s_CLK;
  end process;

  dut : entity work.RISCV_Processor
    port map(
      iCLK      => s_CLK,
      iRST      => s_RST,
      iInstLd   => s_InstLd,
      iInstAddr => s_InstAddr,
      iInstExt  => s_InstExt,
      oALUOut   => s_ALUOut
    );

  stim : process
  begin
    -- load program words into instruction memory
    s_RST    <= '1';
    s_InstLd <= '1';
    for idx in c_program'range loop
      s_InstAddr <= std_logic_vector(to_unsigned(idx * 4, s_InstAddr'length));
      s_InstExt  <= c_program(idx);
      wait until rising_edge(s_CLK);
    end loop;

    s_InstLd   <= '0';
    s_InstAddr <= (others => '0');
    s_InstExt  <= (others => '0');
    wait until rising_edge(s_CLK);

    -- release reset and let the program execute
    s_RST <= '0';
    wait for 500 ns;

    assert false report "tb_RISCV_Processor completed" severity note;
    wait;
  end process;
end architecture sim;
