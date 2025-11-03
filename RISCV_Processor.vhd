-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment
  -- SIGNALS AND COMPONENTS:

    signal s_PCInput : std_logic_vector(31 downto 0); -- Signal to be used as the PC's input (after it comes out of the PCSrc MUX)
    signal s_Plus4Adder_COut : std_logic; -- Plus4Adder's Carry Out output
    signal s_Plus4Adder : std_logic_vector(31 downto 0);
    signal s_ShiftedImm : std_logic_vector(31 downto 0); -- Signal of the immediate after being extended and shifted left by 1 bit
    signal s_BranchCOut : std_logic; -- BranchingAdder's Carry Out
    signal s_BranchingAdder : std_logic_vector(31 downto 0);
    signal s_ImmType : std_logic_vector(2 downto 0); -- Signal from the Control Unit to select the Extender's behavior
    signal s_Extender : std_logic_vector(31 downto 0);
    signal s_PCSrc : std_logic;
    signal s_PCSrc_MUX : std_logic_vector(31 downto 0);
    signal s_ReadData1 : std_logic_vector(31 downto 0);
    signal s_ReadData2 : std_logic_vector(31 downto 0);
    signal s_Branch : std_logic;
    signal s_Jump : std_logic;
    signal s_MemRead : std_logic;
    signal s_MemToReg : std_logic;
    signal s_AndLink : std_logic;
    signal s_ALUSrc : std_logic;
    signal s_ImmType : std_logic_vector(2 downto 0);
    signal s_ALUControl : std_logic_vector(3 downto 0);



    component AddSub is
	port(i_A	: in std_logic_vector(31 downto 0);
	     i_B	: in std_logic_vector(31 downto 0);
	     nAdd_Sub	: in std_logic;
	     o_Result	: out std_logic_vector(31 downto 0);
	     o_CarryOut	: out std_logic);
    end component;

    component mux2to1_32b is
	port(i_A	: in std_logic_vector(31 downto 0);
	     i_B	: in std_logic_vector(31 downto 0);
	     i_Sel	: in std_logic;
	     o_Out	: out std_logic_vector(31 downto 0));
    end component;

    component PC is
    	port(i_CLK	: in std_logic;
         	i_RST	: in std_logic;
	 	i_WE	: in std_logic;
	 	i_D	: in std_logic_vector(31 downto 0);
	 	o_Q	: out std_logic_vector(31 downto 0));
    end component;

    component Extender is
    	port(    i_Inst	: in std_logic_vector(31 downto 0);
		 i_Sel	: in std_logic_vector(2 downto 0);
		 o_Out	: out std_logic_vector(31 downto 0));
    end component;

    component Control is
	port(	i_Opcode	: in std_logic_vector(6 downto 0);
	     	i_funct7	: in std_logic_vector(6 downto 0);
	     	i_funct3	: in std_logic_vector(2 downto 0);
		o_Branch	: out std_logic;
		o_Jump		: out std_logic;
		o_MemRead	: out std_logic;
		o_MemToReg	: out std_logic;
		o_MemWrite	: out std_logic;
		o_AndLink	: out std_logic;
		o_ALUSrc	: out std_logic;
		o_RegWrite	: out std_logic;
		o_ImmType	: out std_logic_vector(2 downto 0);
		o_ALUControl	: out std_logic_vector(3 downto 0));
    end component;

    component RegisterFile is
	port(	i_CLK        : in  std_logic;
        	i_RST        : in  std_logic;
        	i_RegWrite   : in  std_logic;
        	i_ReadReg1   : in  std_logic_vector(4 downto 0); -- rs1
        	i_ReadReg2   : in  std_logic_vector(4 downto 0); -- rs2
        	i_WriteReg   : in  std_logic_vector(4 downto 0); -- rd
        	i_WriteData  : in  std_logic_vector(31 downto 0);
        	o_ReadData1  : out std_logic_vector(31 downto 0);
        	o_ReadData2  : out std_logic_vector(31 downto 0));
    end component;

    component ControlUnit is
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
        o_ALUControl : out std_logic_vector(3 downto 0));
    end component;



begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- Implement the rest of your processor below this comment! 
  -- PORT MAPPING:

    ProgramCounter : PC
	port map(i_CLK	=> iCLK,
		 i_RST	=> iRST,
		 i_WE	=> '1',
		 i_D	=> s_PCInput,
		 o_Q	=> s_NextInstAddr);

    Plus4Adder : AddSub
	port map(i_A	=> s_NextInstAddr,
		 i_B	=> x"00000004",
		 nAdd_Sub => '0',
		 o_CarryOut => s_Plus4Adder_COut,
		 o_Result => s_Plus4Adder);

    BranchingAdder : AddSub
	port map(i_A	=> s_NextInstAddr,
		 i_B	=> s_ShiftedImm,
		 nAdd_Sub => '0',
		 o_CarryOut => s_BranchCOut,
		 o_Result => s_BranchingAdder);

    ImmExtender : Extender
	port map(i_Inst	=> s_Inst,
		 i_Sel	=> s_ImmType,
		 o_Out	=> s_Extender);

    s_ShiftedImm <= s_Extender(30 downto 0) & '0'; -- Shifts Extender output by 1 to the left

    PCSrc_MUX : mux2to1_32b
	port map(i_A	=> s_Plus4Adder,
		 i_B	=> s_BranchingAdder,
		 i_Sel	=> s_PCSrc,
		 o_Out	=> s_PCSrc_MUX);

    -- s_RegWr instead of s_RegWrite, s_DMemWr instead of s_MemWrite
    Control : ControlUnit
	port map(i_Opcode	=> s_Inst(6 downto 0),
		 i_funct3	=> s_Inst(14 downto 12),
		 i_funct7	=> s_Inst(31 downto 25),
		 o_Branch	=> s_Branch,
		 o_Jump		=> s_Jump,
		 o_MemRead	=> s_MemRead,
		 o_MemToReg	=> s_MemToReg,
		 o_MemWrite	=> s_DMemWr,
		 o_AndLink	=> s_AndLink,
		 o_ALUSrc	=> s_ALUSrc,
		 o_RegWrite	=> s_RegWr,
		 o_ImmType	=> s_ImmType,
		 o_ALUControl	=> s_ALUControl);
		 

    s_RegWrAddr <= s_Inst(11 downto 7);

    g_RegisterFile : RegisterFile
	port map(i_CLK		=> iCLK,
		 i_RST		=> iRST,
		 i_RegWrite	=> s_RegWr,
		 i_ReadReg1	=> s_Inst(19 downto 14),
		 i_ReadReg2	=> s_Inst(24 downto 20),
		 i_WriteReg	=> s_RegWrAddr,
		 i_WriteData	=> s_RegWrData,
		 o_ReadData1	=> s_ReadData1,
		 o_ReadData2	=> s_ReadData2);

    


end structure;

