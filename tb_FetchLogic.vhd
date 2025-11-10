library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_FetchLogic is
end tb_FetchLogic;

architecture testbench of tb_FetchLogic is
    component PC
        port(i_CLK	: in std_logic;
             i_RST	: in std_logic;
	     i_WE	: in std_logic;
	     i_D	: in std_logic_vector(31 downto 0);
	     o_Q	: out std_logic_vector(31 downto 0));
    end component;
    
    component mux2to1_32b
        port(i_A	: in std_logic_vector(31 downto 0);
	     i_B	: in std_logic_vector(31 downto 0);
	     i_Sel	: in std_logic;
	     o_Out	: out std_logic_vector(31 downto 0));
    end component;

    -- Clock and reset signals
    signal i_CLK        : std_logic := '0';
    signal i_RST        : std_logic := '0';
    
    -- PC signals
    signal s_PC_WE      : std_logic;
    signal s_PC_Input   : std_logic_vector(31 downto 0);
    signal s_PC_Output  : std_logic_vector(31 downto 0);
    
    -- Adder signals for PC+4
    signal s_PC_Plus4   : std_logic_vector(31 downto 0);
    
    -- Branch/Jump signals
    signal s_Branch_Target : std_logic_vector(31 downto 0);
    signal s_PCSrc      : std_logic;
    signal s_Next_PC    : std_logic_vector(31 downto 0);
    
    -- Clock period
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Clock generation
    i_CLK <= not i_CLK after CLK_PERIOD / 2;

    -- PC instantiation
    PC_inst : PC
        port map (
            i_CLK => i_CLK,
            i_RST => i_RST,
            i_WE  => s_PC_WE,
            i_D   => s_PC_Input,
            o_Q   => s_PC_Output
        );

    -- PC+4 calculation (simple addition)
    s_PC_Plus4 <= std_logic_vector(unsigned(s_PC_Output) + 4);

    -- PC source multiplexer (chooses between PC+4 and branch target)
    PC_Mux : mux2to1_32b
        port map (
            i_A   => s_PC_Plus4,
            i_B   => s_Branch_Target,
            i_Sel => s_PCSrc,
            o_Out => s_Next_PC
        );

    -- Connect next PC to PC input
    s_PC_Input <= s_Next_PC;

    -- Test process
    process
    begin
        -- Initialize signals
        s_PC_WE <= '1'; -- PC write enable always on
        s_PCSrc <= '0'; -- Initially select PC+4
        s_Branch_Target <= x"00000000";
        
        -- Reset test
        i_RST <= '1';
        wait for 20 ns;
        i_RST <= '0';
        wait for 10 ns;
        
        -- Test sequential PC increments (PC+4)
        -- PC should start at 0, then increment by 4 each cycle
        for i in 0 to 5 loop
            wait for CLK_PERIOD;
            -- Check that PC increments by 4
            assert s_PC_Output = std_logic_vector(to_unsigned(i*4, 32))
                report "PC increment test failed at cycle " & integer'image(i)
                severity error;
        end loop;
        
        -- Test branch/jump (PCSrc = 1)
        s_Branch_Target <= x"00000100"; -- Jump to address 0x100
        s_PCSrc <= '1';
        wait for CLK_PERIOD;
        
        -- PC should now be at branch target
        assert s_PC_Output = x"00000100"
            report "Branch target test failed"
            severity error;
            
        -- Continue from branch target with PC+4
        s_PCSrc <= '0';
        wait for CLK_PERIOD;
        assert s_PC_Output = x"00000104"
            report "PC+4 after branch failed"
            severity error;
            
        -- Test another branch
        s_Branch_Target <= x"00002000";
        s_PCSrc <= '1';
        wait for CLK_PERIOD;
        assert s_PC_Output = x"00002000"
            report "Second branch test failed"
            severity error;
            
        -- Test PC write enable functionality
        s_PC_WE <= '0'; -- Disable PC updates
        s_PCSrc <= '0';  -- Try to go back to PC+4 mode
        wait for CLK_PERIOD;
        -- PC should remain the same since WE is disabled
        assert s_PC_Output = x"00002000"
            report "PC write enable test failed"
            severity error;
            
        -- Re-enable PC
        s_PC_WE <= '1';
        wait for CLK_PERIOD;
        assert s_PC_Output = x"00002004"
            report "PC re-enable test failed"
            severity error;
            
        -- Test reset during operation
        i_RST <= '1';
        wait for CLK_PERIOD;
        i_RST <= '0';
        wait for 5 ns;
        -- PC should be reset to 0
        assert s_PC_Output = x"00000000"
            report "Reset during operation test failed"
            severity error;

        report "Fetch logic testbench completed successfully";
        wait;
    end process;

end testbench;