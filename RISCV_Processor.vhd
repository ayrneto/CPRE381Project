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
use IEEE.numeric_std.all;

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
  constant ALU_SLL : std_logic_vector(3 downto 0) := "0100";
  constant ALU_SRL : std_logic_vector(3 downto 0) := "0101";
  constant ALU_SRA : std_logic_vector(3 downto 0) := "1001";

  signal s_PCInput      : std_logic_vector(N-1 downto 0);
  signal s_PCPlus4      : std_logic_vector(N-1 downto 0);

  signal s_IF_Flush     : std_logic;
  signal s_ID_Flush     : std_logic;

  signal s_ID_PC        : std_logic_vector(N-1 downto 0);
  signal s_ID_PC4       : std_logic_vector(N-1 downto 0);
  signal s_ID_Inst      : std_logic_vector(N-1 downto 0);
  signal s_ID_ReadData1 : std_logic_vector(N-1 downto 0);
  signal s_ID_ReadData2 : std_logic_vector(N-1 downto 0);
  signal s_ID_Imm       : std_logic_vector(N-1 downto 0);
  signal s_ID_Shamt     : std_logic_vector(4 downto 0);
  signal s_ID_AUIPC     : std_logic;
  signal s_ID_BranchImm : std_logic_vector(N-1 downto 0);

  signal s_ID_Branch    : std_logic;
  signal s_ID_Jump      : std_logic;
  signal s_ID_MemRead   : std_logic;
  signal s_ID_MemToReg  : std_logic;
  signal s_ID_MemWrite  : std_logic;
  signal s_ID_AndLink   : std_logic;
  signal s_ID_ALUSrc    : std_logic;
  signal s_ID_RegWrite  : std_logic;
  signal s_ID_ImmType   : std_logic_vector(2 downto 0);
  signal s_ID_ALUControl: std_logic_vector(3 downto 0);
  signal s_ID_LoadWidth : std_logic_vector(1 downto 0);
  signal s_ID_LoadSigned: std_logic;
  signal s_ID_StoreWidth: std_logic_vector(1 downto 0);
  signal s_ID_BranchType: std_logic_vector(2 downto 0);
  signal s_ID_Halt      : std_logic;

  signal s_ID_CmpEq        : std_logic;
  signal s_ID_CmpSignedLT  : std_logic;
  signal s_ID_CmpSignedGE  : std_logic;
  signal s_ID_CmpUnsignedLT: std_logic;
  signal s_ID_CmpUnsignedGE: std_logic;
  signal s_ID_BranchTaken  : std_logic;
  signal s_ID_BranchTarget : std_logic_vector(N-1 downto 0);
  signal s_ID_JumpTarget   : std_logic_vector(N-1 downto 0);
  signal s_ID_JALRTarget   : std_logic_vector(N-1 downto 0);

  signal s_EX_rd        : std_logic_vector(4 downto 0);
  signal s_EX_rs1       : std_logic_vector(4 downto 0);
  signal s_EX_rs2       : std_logic_vector(4 downto 0);
  signal s_EX_ReadData1 : std_logic_vector(N-1 downto 0);
  signal s_EX_ReadData2 : std_logic_vector(N-1 downto 0);
  signal s_EX_PC        : std_logic_vector(N-1 downto 0);
  signal s_EX_PC4       : std_logic_vector(N-1 downto 0);
  signal s_EX_Imm       : std_logic_vector(N-1 downto 0);
  signal s_EX_Shamt     : std_logic_vector(4 downto 0);
  signal s_EX_ALUControl: std_logic_vector(3 downto 0);
  signal s_EX_ALUSrc    : std_logic;
  signal s_EX_RegWrite  : std_logic;
  signal s_EX_MemToReg  : std_logic;
  signal s_EX_MemRead   : std_logic;
  signal s_EX_MemWrite  : std_logic;
  signal s_EX_LoadWidth : std_logic_vector(1 downto 0);
  signal s_EX_LoadSigned: std_logic;
  signal s_EX_StoreWidth: std_logic_vector(1 downto 0);
  signal s_EX_AndLink   : std_logic;
  signal s_EX_AUIPC     : std_logic;
  signal s_EX_Halt      : std_logic;

  signal s_Shamt        : std_logic_vector(4 downto 0);
  signal s_ALUInputA    : std_logic_vector(N-1 downto 0);
  signal s_ALUInputB    : std_logic_vector(N-1 downto 0);
  signal s_ALUResult    : std_logic_vector(N-1 downto 0);
  signal s_ALUOverflow  : std_logic;

  signal s_MEM_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_MEM_StoreData : std_logic_vector(N-1 downto 0);
  signal s_MEM_rd        : std_logic_vector(4 downto 0);
  signal s_MEM_RegWrite  : std_logic;
  signal s_MEM_MemToReg  : std_logic;
  signal s_MEM_MemRead   : std_logic;
  signal s_MEM_MemWrite  : std_logic;
  signal s_MEM_LoadWidth : std_logic_vector(1 downto 0);
  signal s_MEM_LoadSigned: std_logic;
  signal s_MEM_StoreWidth: std_logic_vector(1 downto 0);
  signal s_MEM_AndLink   : std_logic;
  signal s_MEM_PC4       : std_logic_vector(N-1 downto 0);
  signal s_MEM_Halt      : std_logic;

  signal s_MEM_ByteOffset: std_logic_vector(1 downto 0);
  signal s_MEM_LoadData  : std_logic_vector(N-1 downto 0);

  signal s_WB_DMem       : std_logic_vector(N-1 downto 0);
  signal s_WB_ALUResult  : std_logic_vector(N-1 downto 0);
  signal s_WB_PC4        : std_logic_vector(N-1 downto 0);
  signal s_WB_rd         : std_logic_vector(4 downto 0);
  signal s_WB_RegWrite   : std_logic;
  signal s_WB_MemToReg   : std_logic;
  signal s_WB_AndLink    : std_logic;
  signal s_WB_Halt       : std_logic;

  signal s_WriteBack     : std_logic_vector(N-1 downto 0);

  -- Forwarding Unit signals
  signal s_ForwardA      : std_logic_vector(1 downto 0);
  signal s_ForwardB      : std_logic_vector(1 downto 0);
  signal s_ALUInputA_Forward : std_logic_vector(N-1 downto 0);
  signal s_ALUInputB_Forward : std_logic_vector(N-1 downto 0);

  -- Hazard Detection Unit signals
  signal s_PCWrite       : std_logic;
  signal s_IF_ID_Write   : std_logic;
  signal s_FlushMux_Sel  : std_logic;
  signal s_ID_ControlMux : std_logic_vector(0 downto 0); -- Flush control word for ID/EX register
  
  -- Control signals for ID_EX with hazard flushing
  signal s_ID_RegWrite_Hazard  : std_logic;
  signal s_ID_MemRead_Hazard   : std_logic;
  signal s_ID_MemWrite_Hazard  : std_logic;

  component AddSub_32b is
    generic(N : integer := 32);
    port(i_A      : in std_logic_vector(N-1 downto 0);
       i_B      : in std_logic_vector(N-1 downto 0);
       nAdd_Sub : in std_logic_vector(1 downto 0);
       o_Result : out std_logic_vector(N-1 downto 0);
       o_CarryOut : out std_logic);
  end component;

    component PC is
    	port(i_CLK	: in std_logic;
         	i_RST	: in std_logic;
	 	i_WE	: in std_logic;
	 	i_D	: in std_logic_vector(31 downto 0);
	 	o_Q	: out std_logic_vector(31 downto 0));
    end component;

  component Extender is
    port( i_Inst : in std_logic_vector(31 downto 0);
        i_Sel  : in std_logic_vector(2 downto 0);
        o_Out  : out std_logic_vector(31 downto 0));
  end component;

  component ALU is
    port(
      i_A         : in  std_logic_vector(31 downto 0);
      i_B         : in  std_logic_vector(31 downto 0);
      i_ALUControl: in  std_logic_vector(3 downto 0);
      i_shamt     : in  std_logic_vector(4 downto 0);
      o_ALUOut    : out std_logic_vector(31 downto 0);
      o_Ovfl      : out std_logic);
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
    port(
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
      o_ALUControl : out std_logic_vector(3 downto 0);
      o_LoadWidth  : out std_logic_vector(1 downto 0);
      o_LoadSigned : out std_logic;
      o_StoreWidth : out std_logic_vector(1 downto 0);
      o_BranchType : out std_logic_vector(2 downto 0);
      o_Halt       : out std_logic);
  end component;

  component IF_ID is
    port(i_CLK   : in std_logic;
         i_RST   : in std_logic;
         i_Stall : in std_logic;
         i_Flush : in std_logic;
         i_PC    : in std_logic_vector(31 downto 0);
         i_PC4   : in std_logic_vector(31 downto 0);
         i_inst  : in std_logic_vector(31 downto 0);
         o_inst  : out std_logic_vector(31 downto 0);
         o_PC4   : out std_logic_vector(31 downto 0);
         o_PC    : out std_logic_vector(31 downto 0));
  end component;

  component ID_EX is
    port(i_CLK       : in std_logic;
         i_RST       : in std_logic;
         i_Stall     : in std_logic;
         i_Flush     : in std_logic;
         i_rd        : in std_logic_vector(4 downto 0);
         i_rs1       : in std_logic_vector(4 downto 0);
         i_rs2       : in std_logic_vector(4 downto 0);
         i_ReadData1 : in std_logic_vector(31 downto 0);
         i_ReadData2 : in std_logic_vector(31 downto 0);
         i_PC        : in std_logic_vector(31 downto 0);
         i_PC4       : in std_logic_vector(31 downto 0);
         i_imm       : in std_logic_vector(31 downto 0);
         i_Shamt     : in std_logic_vector(4 downto 0);
         i_ALUControl: in std_logic_vector(3 downto 0);
         i_ALUSrc    : in std_logic;
         i_RegWrite  : in std_logic;
         i_MemToReg  : in std_logic;
         i_MemRead   : in std_logic;
         i_MemWrite  : in std_logic;
         i_LoadWidth : in std_logic_vector(1 downto 0);
         i_LoadSigned: in std_logic;
         i_StoreWidth: in std_logic_vector(1 downto 0);
         i_AndLink   : in std_logic;
         i_AUIPC     : in std_logic;
         i_Halt      : in std_logic;
         o_rd        : out std_logic_vector(4 downto 0);
         o_rs1       : out std_logic_vector(4 downto 0);
         o_rs2       : out std_logic_vector(4 downto 0);
         o_ReadData1 : out std_logic_vector(31 downto 0);
         o_ReadData2 : out std_logic_vector(31 downto 0);
         o_PC        : out std_logic_vector(31 downto 0);
         o_PC4       : out std_logic_vector(31 downto 0);
         o_imm       : out std_logic_vector(31 downto 0);
         o_Shamt     : out std_logic_vector(4 downto 0);
         o_ALUControl: out std_logic_vector(3 downto 0);
         o_ALUSrc    : out std_logic;
         o_RegWrite  : out std_logic;
         o_MemToReg  : out std_logic;
         o_MemRead   : out std_logic;
         o_MemWrite  : out std_logic;
         o_LoadWidth : out std_logic_vector(1 downto 0);
         o_LoadSigned: out std_logic;
         o_StoreWidth: out std_logic_vector(1 downto 0);
         o_AndLink   : out std_logic;
         o_AUIPC     : out std_logic;
         o_Halt      : out std_logic);
  end component;

  component EX_Mem is
    port(i_CLK       : in std_logic;
         i_RST       : in std_logic;
         i_Stall     : in std_logic;
         i_Flush     : in std_logic;
         i_ALUResult : in std_logic_vector(31 downto 0);
         i_StoreData : in std_logic_vector(31 downto 0);
         i_rd        : in std_logic_vector(4 downto 0);
         i_RegWrite  : in std_logic;
         i_MemToReg  : in std_logic;
         i_MemRead   : in std_logic;
         i_MemWrite  : in std_logic;
         i_LoadWidth : in std_logic_vector(1 downto 0);
         i_LoadSigned: in std_logic;
         i_StoreWidth: in std_logic_vector(1 downto 0);
         i_AndLink   : in std_logic;
         i_PC4       : in std_logic_vector(31 downto 0);
         i_Halt      : in std_logic;
         o_ALUResult : out std_logic_vector(31 downto 0);
         o_StoreData : out std_logic_vector(31 downto 0);
         o_rd        : out std_logic_vector(4 downto 0);
         o_RegWrite  : out std_logic;
         o_MemToReg  : out std_logic;
         o_MemRead   : out std_logic;
         o_MemWrite  : out std_logic;
         o_LoadWidth : out std_logic_vector(1 downto 0);
         o_LoadSigned: out std_logic;
         o_StoreWidth: out std_logic_vector(1 downto 0);
         o_AndLink   : out std_logic;
         o_PC4       : out std_logic_vector(31 downto 0);
         o_Halt      : out std_logic);
  end component;

  component Mem_WB is
    port(i_CLK      : in std_logic;
         i_RST      : in std_logic;
         i_Stall    : in std_logic;
         i_Flush    : in std_logic;
         i_DMem     : in std_logic_vector(31 downto 0);
         i_ALUResult: in std_logic_vector(31 downto 0);
         i_PC4      : in std_logic_vector(31 downto 0);
         i_rd       : in std_logic_vector(4 downto 0);
         i_RegWrite : in std_logic;
         i_MemToReg : in std_logic;
         i_AndLink  : in std_logic;
         i_Halt     : in std_logic;
         o_DMem     : out std_logic_vector(31 downto 0);
         o_ALUResult: out std_logic_vector(31 downto 0);
         o_PC4      : out std_logic_vector(31 downto 0);
         o_rd       : out std_logic_vector(4 downto 0);
         o_RegWrite : out std_logic;
         o_MemToReg : out std_logic;
         o_AndLink  : out std_logic;
         o_Halt     : out std_logic);
  end component;

  component ForwardingUnit is
    port(ID_EX_rs1     : in std_logic_vector(4 downto 0);
         ID_EX_rs2     : in std_logic_vector(4 downto 0);
         EX_Mem_rd     : in std_logic_vector(4 downto 0);
         EX_Mem_RegWrite : in std_logic;
         Mem_WB_rd     : in std_logic_vector(4 downto 0);
         Mem_WB_RegWrite : in std_logic;
         ForwardA      : out std_logic_vector(1 downto 0);
         ForwardB      : out std_logic_vector(1 downto 0));
  end component;

  component HazardDetectionUnit is
    port(ID_EX_MemRead : in std_logic;
         ID_EX_rd      : in std_logic_vector(4 downto 0);
         IF_ID_rs1     : in std_logic_vector(4 downto 0);
         IF_ID_rs2     : in std_logic_vector(4 downto 0);
         PCWrite       : out std_logic;
         IF_ID_Write   : out std_logic;
         FlushMux_Sel  : out std_logic);
  end component;

  component ForwardMuxA is
    port(ReadData1       : in std_logic_vector(31 downto 0);
         Mem_WB_Data     : in std_logic_vector(31 downto 0);
         EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
         Sel             : in std_logic_vector(1 downto 0);
         ALU_InputA      : out std_logic_vector(31 downto 0));
  end component;

  component ForwardMuxB is
    port(ReadData2       : in std_logic_vector(31 downto 0);
         Mem_WB_Data     : in std_logic_vector(31 downto 0);
         EX_Mem_ALUResult : in std_logic_vector(31 downto 0);
         Sel             : in std_logic_vector(1 downto 0);
         ALU_InputB      : out std_logic_vector(31 downto 0));
  end component;



begin

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

  ProgramCounter : PC
    port map(i_CLK => iCLK,
             i_RST => iRST,
             i_WE  => s_PCWrite,
             i_D   => s_PCInput,
             o_Q   => s_NextInstAddr);

  Plus4Adder : AddSub_32b
    port map(i_A       => s_NextInstAddr,
             i_B       => x"00000004",
             nAdd_Sub  => "00",
             o_CarryOut=> open,
             o_Result  => s_PCPlus4);

  -- IF/ID register holds the fetch outputs for the decode stage.
  IF_ID_reg : IF_ID
    port map(i_CLK   => iCLK,
             i_RST   => iRST,
             i_Stall => not s_IF_ID_Write,
             i_Flush => s_IF_Flush,
             i_PC    => s_NextInstAddr,
             i_PC4   => s_PCPlus4,
             i_inst  => s_Inst,
             o_inst  => s_ID_Inst,
             o_PC4   => s_ID_PC4,
             o_PC    => s_ID_PC);

  -- Hazard Detection Unit for load-use hazard detection
  HazardDetectionUnit_inst : HazardDetectionUnit
    port map(ID_EX_MemRead => s_EX_MemRead,
             ID_EX_rd      => s_EX_rd,
             IF_ID_rs1     => s_ID_Inst(19 downto 15),
             IF_ID_rs2     => s_ID_Inst(24 downto 20),
             PCWrite       => s_PCWrite,
             IF_ID_Write   => s_IF_ID_Write,
             FlushMux_Sel  => s_FlushMux_Sel);

  Control : ControlUnit
    port map(i_Opcode    => s_ID_Inst(6 downto 0),
             i_funct3    => s_ID_Inst(14 downto 12),
             i_funct7    => s_ID_Inst(31 downto 25),
             o_Branch    => s_ID_Branch,
             o_Jump      => s_ID_Jump,
             o_MemRead   => s_ID_MemRead,
             o_MemToReg  => s_ID_MemToReg,
             o_MemWrite  => s_ID_MemWrite,
             o_AndLink   => s_ID_AndLink,
             o_ALUSrc    => s_ID_ALUSrc,
             o_RegWrite  => s_ID_RegWrite,
             o_ImmType   => s_ID_ImmType,
             o_ALUControl=> s_ID_ALUControl,
             o_LoadWidth => s_ID_LoadWidth,
             o_LoadSigned=> s_ID_LoadSigned,
             o_StoreWidth=> s_ID_StoreWidth,
             o_BranchType=> s_ID_BranchType,
             o_Halt      => s_ID_Halt);

  ImmExtender : Extender
    port map(i_Inst => s_ID_Inst,
             i_Sel  => s_ID_ImmType,
             o_Out  => s_ID_Imm);

  s_ID_Shamt <= s_ID_Inst(24 downto 20);
  s_ID_AUIPC <= '1' when s_ID_Inst(6 downto 0) = "0010111" else '0';

  RegisterFile_inst : RegisterFile
    port map(i_CLK       => iCLK,
             i_RST       => iRST,
             i_RegWrite  => s_RegWr,
             i_ReadReg1  => s_ID_Inst(19 downto 15),
             i_ReadReg2  => s_ID_Inst(24 downto 20),
             i_WriteReg  => s_RegWrAddr,
             i_WriteData => s_RegWrData,
             o_ReadData1 => s_ID_ReadData1,
             o_ReadData2 => s_ID_ReadData2);

  s_ID_CmpEq         <= '1' when s_ID_ReadData1 = s_ID_ReadData2 else '0';
  s_ID_CmpSignedLT   <= '1' when signed(s_ID_ReadData1) < signed(s_ID_ReadData2) else '0';
  s_ID_CmpSignedGE   <= '1' when signed(s_ID_ReadData1) >= signed(s_ID_ReadData2) else '0';
  s_ID_CmpUnsignedLT <= '1' when unsigned(s_ID_ReadData1) < unsigned(s_ID_ReadData2) else '0';
  s_ID_CmpUnsignedGE <= '1' when unsigned(s_ID_ReadData1) >= unsigned(s_ID_ReadData2) else '0';

  branch_decider : process(s_ID_BranchType, s_ID_CmpEq, s_ID_CmpSignedLT, s_ID_CmpSignedGE,
                           s_ID_CmpUnsignedLT, s_ID_CmpUnsignedGE)
  begin
    case s_ID_BranchType is
      when "000" => s_ID_BranchTaken <= s_ID_CmpEq;
      when "001" => s_ID_BranchTaken <= not s_ID_CmpEq;
      when "100" => s_ID_BranchTaken <= s_ID_CmpSignedLT;
      when "101" => s_ID_BranchTaken <= s_ID_CmpSignedGE;
      when "110" => s_ID_BranchTaken <= s_ID_CmpUnsignedLT;
      when "111" => s_ID_BranchTaken <= s_ID_CmpUnsignedGE;
      when others => s_ID_BranchTaken <= '0';
    end case;
  end process;

  s_ID_BranchImm <= s_ID_Imm;

  BranchingAdder : AddSub_32b
    port map(i_A       => s_ID_PC,
             i_B       => s_ID_BranchImm,
             nAdd_Sub  => "00",
             o_CarryOut=> open,
             o_Result  => s_ID_BranchTarget);

  s_ID_JALRTarget <= std_logic_vector(unsigned(s_ID_ReadData1) + unsigned(s_ID_Imm));

  -- Redirect fetch and kill the next instruction when a control transfer resolves.
  s_IF_Flush <= '1' when (s_ID_Jump = '1') or (s_ID_Branch = '1' and s_ID_BranchTaken = '1') else '0';
  -- Branch instructions become bubbles after their redirect decision.
  s_ID_Flush <= s_IF_Flush and s_ID_Branch;

  s_ID_JumpTarget <= s_ID_BranchTarget when s_ID_ALUSrc = '0'
                     else s_ID_JALRTarget(N-1 downto 1) & '0';

  s_PCInput <= s_ID_JumpTarget when s_ID_Jump = '1' else
               s_ID_BranchTarget when (s_ID_Branch = '1' and s_ID_BranchTaken = '1') else
               s_PCPlus4;

  -- Control signal muxes for hazard flushing
  s_ID_RegWrite_Hazard <= '0' when s_FlushMux_Sel = '1' else s_ID_RegWrite;
  s_ID_MemRead_Hazard  <= '0' when s_FlushMux_Sel = '1' else s_ID_MemRead;
  s_ID_MemWrite_Hazard <= '0' when s_FlushMux_Sel = '1' else s_ID_MemWrite;

  -- ID/EX register captures decode results and control bits for the execute stage.
  ID_EX_reg : ID_EX
    port map(i_CLK       => iCLK,
             i_RST       => iRST,
             i_Stall     => '0',
             i_Flush     => s_ID_Flush,
             i_rd        => s_ID_Inst(11 downto 7),
             i_rs1       => s_ID_Inst(19 downto 15),
             i_rs2       => s_ID_Inst(24 downto 20),
             i_ReadData1 => s_ID_ReadData1,
             i_ReadData2 => s_ID_ReadData2,
             i_PC        => s_ID_PC,
             i_PC4       => s_ID_PC4,
             i_imm       => s_ID_Imm,
             i_Shamt     => s_ID_Shamt,
             i_ALUControl=> s_ID_ALUControl,
             i_ALUSrc    => s_ID_ALUSrc,
             i_RegWrite  => s_ID_RegWrite_Hazard,
             i_MemToReg  => s_ID_MemToReg,
             i_MemRead   => s_ID_MemRead_Hazard,
             i_MemWrite  => s_ID_MemWrite_Hazard,
             i_LoadWidth => s_ID_LoadWidth,
             i_LoadSigned=> s_ID_LoadSigned,
             i_StoreWidth=> s_ID_StoreWidth,
             i_AndLink   => s_ID_AndLink,
             i_AUIPC     => s_ID_AUIPC,
             i_Halt      => s_ID_Halt,
             o_rd        => s_EX_rd,
             o_rs1       => s_EX_rs1,
             o_rs2       => s_EX_rs2,
             o_ReadData1 => s_EX_ReadData1,
             o_ReadData2 => s_EX_ReadData2,
             o_PC        => s_EX_PC,
             o_PC4       => s_EX_PC4,
             o_imm       => s_EX_Imm,
             o_Shamt     => s_EX_Shamt,
             o_ALUControl=> s_EX_ALUControl,
             o_ALUSrc    => s_EX_ALUSrc,
             o_RegWrite  => s_EX_RegWrite,
             o_MemToReg  => s_EX_MemToReg,
             o_MemRead   => s_EX_MemRead,
             o_MemWrite  => s_EX_MemWrite,
             o_LoadWidth => s_EX_LoadWidth,
             o_LoadSigned=> s_EX_LoadSigned,
             o_StoreWidth=> s_EX_StoreWidth,
             o_AndLink   => s_EX_AndLink,
             o_AUIPC     => s_EX_AUIPC,
             o_Halt      => s_EX_Halt);

  s_Shamt <= s_EX_Shamt when (s_EX_ALUSrc = '1' and (s_EX_ALUControl = ALU_SLL or s_EX_ALUControl = ALU_SRL or s_EX_ALUControl = ALU_SRA))
             else s_EX_ReadData2(4 downto 0);

  -- Forwarding muxes for ALU inputs
  ForwardMuxA_inst : ForwardMuxA
    port map(ReadData1       => s_EX_ReadData1,
             Mem_WB_Data     => s_WriteBack,
             EX_Mem_ALUResult => s_MEM_ALUResult,
             Sel             => s_ForwardA,
             ALU_InputA      => s_ALUInputA_Forward);

  ForwardMuxB_inst : ForwardMuxB
    port map(ReadData2       => s_EX_ReadData2,
             Mem_WB_Data     => s_WriteBack,
             EX_Mem_ALUResult => s_MEM_ALUResult,
             Sel             => s_ForwardB,
             ALU_InputB      => s_ALUInputB_Forward);

  s_ALUInputA <= s_EX_PC when s_EX_AUIPC = '1' else s_ALUInputA_Forward;
  s_ALUInputB <= s_EX_Imm when s_EX_ALUSrc = '1' else s_ALUInputB_Forward;

  ALU_inst : ALU
    port map(i_A         => s_ALUInputA,
             i_B         => s_ALUInputB,
             i_ALUControl=> s_EX_ALUControl,
             i_shamt     => s_Shamt,
             o_ALUOut    => s_ALUResult,
             o_Ovfl      => s_ALUOverflow);

  -- Forwarding Unit for data hazard detection
  ForwardingUnit_inst : ForwardingUnit
    port map(ID_EX_rs1     => s_EX_rs1,
             ID_EX_rs2     => s_EX_rs2,
             EX_Mem_rd     => s_MEM_rd,
             EX_Mem_RegWrite => s_MEM_RegWrite,
             Mem_WB_rd     => s_WB_rd,
             Mem_WB_RegWrite => s_WB_RegWrite,
             ForwardA      => s_ForwardA,
             ForwardB      => s_ForwardB);

  -- EX/MEM register transports the ALU result and memory controls into MEM.
  EX_Mem_reg : EX_Mem
    port map(i_CLK       => iCLK,
             i_RST       => iRST,
             i_Stall     => '0',
             i_Flush     => '0',
             i_ALUResult => s_ALUResult,
             i_StoreData => s_ALUInputB_Forward,
             i_rd        => s_EX_rd,
             i_RegWrite  => s_EX_RegWrite,
             i_MemToReg  => s_EX_MemToReg,
             i_MemRead   => s_EX_MemRead,
             i_MemWrite  => s_EX_MemWrite,
             i_LoadWidth => s_EX_LoadWidth,
             i_LoadSigned=> s_EX_LoadSigned,
             i_StoreWidth=> s_EX_StoreWidth,
             i_AndLink   => s_EX_AndLink,
             i_PC4       => s_EX_PC4,
             i_Halt      => s_EX_Halt,
             o_ALUResult => s_MEM_ALUResult,
             o_StoreData => s_MEM_StoreData,
             o_rd        => s_MEM_rd,
             o_RegWrite  => s_MEM_RegWrite,
             o_MemToReg  => s_MEM_MemToReg,
             o_MemRead   => s_MEM_MemRead,
             o_MemWrite  => s_MEM_MemWrite,
             o_LoadWidth => s_MEM_LoadWidth,
             o_LoadSigned=> s_MEM_LoadSigned,
             o_StoreWidth=> s_MEM_StoreWidth,
             o_AndLink   => s_MEM_AndLink,
             o_PC4       => s_MEM_PC4,
             o_Halt      => s_MEM_Halt);

  s_MEM_ByteOffset <= s_MEM_ALUResult(1 downto 0);

  -- Format the store payload based on the requested width and byte lane.
  store_packer : process(s_MEM_StoreData, s_DMemOut, s_MEM_StoreWidth, s_MEM_ByteOffset)
    variable v_word : std_logic_vector(31 downto 0);
    variable v_half : std_logic_vector(15 downto 0);
    variable v_byte : std_logic_vector(7 downto 0);
  begin
    v_word := s_DMemOut;
    case s_MEM_StoreWidth is
      when "00" =>
        v_byte := s_MEM_StoreData(7 downto 0);
        case s_MEM_ByteOffset is
          when "00" => v_word(7 downto 0)   := v_byte;
          when "01" => v_word(15 downto 8)  := v_byte;
          when "10" => v_word(23 downto 16) := v_byte;
          when others => v_word(31 downto 24) := v_byte;
        end case;
      when "01" =>
        v_half := s_MEM_StoreData(15 downto 0);
        if s_MEM_ByteOffset(1) = '0' then
          v_word(15 downto 0) := v_half;
        else
          v_word(31 downto 16) := v_half;
        end if;
      when others =>
        v_word := s_MEM_StoreData;
    end case;
    s_DMemData <= v_word;
  end process;

  -- Align and extend load results before they enter the WB path.
  load_unpacker : process(s_DMemOut, s_MEM_LoadWidth, s_MEM_LoadSigned, s_MEM_ByteOffset)
    variable v_result : std_logic_vector(31 downto 0);
    variable v_byte   : std_logic_vector(7 downto 0);
    variable v_half   : std_logic_vector(15 downto 0);
  begin
    v_result := s_DMemOut;
    case s_MEM_LoadWidth is
      when "00" =>
        case s_MEM_ByteOffset is
          when "00" => v_byte := s_DMemOut(7 downto 0);
          when "01" => v_byte := s_DMemOut(15 downto 8);
          when "10" => v_byte := s_DMemOut(23 downto 16);
          when others => v_byte := s_DMemOut(31 downto 24);
        end case;
        if s_MEM_LoadSigned = '1' then
          v_result := std_logic_vector(resize(signed(v_byte), 32));
        else
          v_result := std_logic_vector(resize(unsigned(v_byte), 32));
        end if;
      when "01" =>
        if s_MEM_ByteOffset(1) = '0' then
          v_half := s_DMemOut(15 downto 0);
        else
          v_half := s_DMemOut(31 downto 16);
        end if;
        if s_MEM_LoadSigned = '1' then
          v_result := std_logic_vector(resize(signed(v_half), 32));
        else
          v_result := std_logic_vector(resize(unsigned(v_half), 32));
        end if;
      when others =>
        v_result := s_DMemOut;
    end case;
    s_MEM_LoadData <= v_result;
  end process;

  -- MEM/WB register feeds the writeback mux and final halt indicator.
  Mem_WB_reg : Mem_WB
    port map(i_CLK      => iCLK,
             i_RST      => iRST,
             i_Stall    => '0',
             i_Flush    => '0',
             i_DMem     => s_MEM_LoadData,
             i_ALUResult=> s_MEM_ALUResult,
             i_PC4      => s_MEM_PC4,
             i_rd       => s_MEM_rd,
             i_RegWrite => s_MEM_RegWrite,
             i_MemToReg => s_MEM_MemToReg,
             i_AndLink  => s_MEM_AndLink,
             i_Halt     => s_MEM_Halt,
             o_DMem     => s_WB_DMem,
             o_ALUResult=> s_WB_ALUResult,
             o_PC4      => s_WB_PC4,
             o_rd       => s_WB_rd,
             o_RegWrite => s_WB_RegWrite,
             o_MemToReg => s_WB_MemToReg,
             o_AndLink  => s_WB_AndLink,
             o_Halt     => s_WB_Halt);

  s_WriteBack <= s_WB_DMem when s_WB_MemToReg = '1' else s_WB_ALUResult;
  s_RegWrData <= s_WB_PC4 when s_WB_AndLink = '1' else s_WriteBack;
  s_RegWr     <= s_WB_RegWrite;
  s_RegWrAddr <= s_WB_rd;

  s_DMemWr   <= s_MEM_MemWrite;
  s_DMemAddr <= s_MEM_ALUResult;

  oALUOut <= s_ALUResult;
  s_Halt  <= s_WB_Halt;
  s_Ovfl  <= s_ALUOverflow;

end structure;

