library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_RISCV_Processor_HW is
end tb_RISCV_Processor_HW;

architecture testbench of tb_RISCV_Processor_HW is
    component RISCV_Processor
        generic(N : integer := 32);
        port(iCLK            : in std_logic;
             iRST            : in std_logic;
             iInstLd         : in std_logic;
             iInstAddr       : in std_logic_vector(31 downto 0);
             iInstExt        : in std_logic_vector(31 downto 0);
             oALUOut         : out std_logic_vector(31 downto 0));
    end component;

    signal iCLK      : std_logic := '0';
    signal iRST      : std_logic := '1';
    signal iInstLd   : std_logic := '0';
    signal iInstAddr : std_logic_vector(31 downto 0) := (others => '0');
    signal iInstExt  : std_logic_vector(31 downto 0) := (others => '0');
    signal oALUOut   : std_logic_vector(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    type instruction_array is array (0 to 15) of std_logic_vector(31 downto 0);
    signal test_program : instruction_array := (
        -- Test program for hardware-scheduled pipeline
        -- Tests data forwarding and hazard detection
        
        x"00100093", -- addi x1, x0, 1      (x1 = 1)
        x"00200113", -- addi x2, x0, 2      (x2 = 2)
        x"001101B3", -- add x3, x2, x1      (x3 = x2 + x1 = 3) - should forward from previous instructions
        x"40208233", -- sub x4, x1, x2      (x4 = x1 - x2 = -1) - should forward x1 and x2
        x"00118293", -- addi x5, x3, 1      (x5 = x3 + 1 = 4) - should forward x3
        x"00000313", -- addi x6, x0, 0      (x6 = 0, base address for memory)
        x"00532023", -- sw x5, 0(x6)        (store x5 to memory) - should forward x5 and x6
        x"00032383", -- lw x7, 0(x6)        (load from memory to x7) - should cause load-use hazard
        x"00738413", -- add x8, x7, x7      (x8 = x7 + x7) - LOAD-USE HAZARD: should stall pipeline
        x"008384B3", -- add x9, x7, x8      (x9 = x7 + x8) - should forward x8
        x"00940533", -- add x10, x8, x9     (x10 = x8 + x9) - should forward x8 and x9
        x"fff00593", -- addi x11, x0, -1    (x11 = -1)
        x"00B50633", -- add x12, x10, x11   (x12 = x10 + x11) - should forward x10 and x11
        x"00000073", -- wfi (halt)
        x"00000000", -- nop
        x"00000000"  -- nop
    );

    signal instruction_count : integer := 0;

begin
    uut: RISCV_Processor
        generic map(N => 32)
        port map (
            iCLK     => iCLK,
            iRST     => iRST,
            iInstLd  => iInstLd,
            iInstAddr => iInstAddr,
            iInstExt => iInstExt,
            oALUOut  => oALUOut
        );

    -- Clock generation
    clk_process: process
    begin
        iCLK <= '0';
        wait for CLK_PERIOD/2;
        iCLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Main test process
    test_process: process
    begin
        -- Reset processor
        iRST <= '1';
        iInstLd <= '0';
        wait for 20 ns;
        iRST <= '0';
        wait for 10 ns;

        -- Load test program into instruction memory
        iInstLd <= '1';
        for i in 0 to test_program'length-1 loop
            iInstAddr <= std_logic_vector(to_unsigned(i*4, 32));
            iInstExt <= test_program(i);
            wait for CLK_PERIOD;
        end loop;
        iInstLd <= '0';

        -- Run the processor for multiple cycles to test pipeline behavior
        -- This should test:
        -- 1. Data forwarding from EX/MEM and MEM/WB stages
        -- 2. Load-use hazard detection and pipeline stalling
        -- 3. Store data forwarding
        -- 4. Multiple forwarding scenarios
        
        report "Starting hardware-scheduled pipeline test...";
        
        -- Let the processor run for enough cycles to complete the program
        -- Expected behavior:
        -- - Instructions should execute without manual NOPs
        -- - Load-use hazard should cause automatic stall
        -- - Data forwarding should resolve most other hazards
        
        for cycle in 1 to 50 loop
            wait for CLK_PERIOD;
            
            -- Monitor key cycles for specific behaviors
            if cycle = 10 then
                report "Cycle 10: Should see data forwarding in action";
            elsif cycle = 15 then
                report "Cycle 15: Load-use hazard should cause stall here";
            elsif cycle = 25 then
                report "Cycle 25: Complex forwarding scenarios";
            end if;
            
        end loop;

        report "Hardware-scheduled pipeline test completed";
        report "Expected behaviors:";
        report "1. No manual NOPs required - hardware handles hazards";
        report "2. Automatic stalls for load-use hazards";
        report "3. Data forwarding for most other dependencies";
        report "4. Improved performance vs software-scheduled version";
        
        wait;
    end process;

    -- Monitor process for debugging
    monitor_process: process(iCLK)
    begin
        if rising_edge(iCLK) then
            if iRST = '0' and iInstLd = '0' then
                instruction_count <= instruction_count + 1;
                if instruction_count mod 5 = 0 then
                    report "Cycle " & integer'image(instruction_count) & 
                           ", ALU Output: " & integer'image(to_integer(signed(oALUOut)));
                end if;
            end if;
        end if;
    end process;

end testbench;