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

  signal s_PCInput : std_logic_vector(N-1 downto 0);
  signal s_Plus4Adder : std_logic_vector(N-1 downto 0);
  signal s_ShiftedImm : std_logic_vector(N-1 downto 0);
  signal s_BranchingAdder : std_logic_vector(N-1 downto 0);
  signal s_ImmType : std_logic_vector(2 downto 0);
  signal s_Extender : std_logic_vector(N-1 downto 0);
  signal s_PCSrc : std_logic;
  signal s_PCSrc_MUX : std_logic_vector(N-1 downto 0);
  signal s_ReadData1 : std_logic_vector(N-1 downto 0);
  signal s_ReadData2 : std_logic_vector(N-1 downto 0);
  signal s_Branch : std_logic;
  signal s_Jump : std_logic;
  signal s_MemRead : std_logic;
  signal s_MemToReg : std_logic;
  signal s_AndLink : std_logic;
  signal s_ALUSrc : std_logic;
  signal s_ALUControl : std_logic_vector(3 downto 0);
  signal s_ALUInputA : std_logic_vector(N-1 downto 0);
  signal s_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_ALUInputB : std_logic_vector(N-1 downto 0);
  signal s_WriteBack : std_logic_vector(N-1 downto 0);
  signal s_LinkData : std_logic_vector(N-1 downto 0);
  signal s_JumpTarget : std_logic_vector(N-1 downto 0);
  signal s_Shamt    : std_logic_vector(4 downto 0);
  signal s_AUIPC    : std_logic;
  signal s_LoadWidth  : std_logic_vector(1 downto 0);
  signal s_LoadSigned : std_logic;
  signal s_StoreWidth : std_logic_vector(1 downto 0);
  signal s_BranchType : std_logic_vector(2 downto 0);
  signal s_BranchTaken: std_logic;
  signal s_LoadData   : std_logic_vector(N-1 downto 0);
  signal s_StoreData  : std_logic_vector(N-1 downto 0);
  signal s_ByteOffset : std_logic_vector(1 downto 0);
  signal s_CmpEq       : std_logic;
  signal s_CmpSignedLT : std_logic;
  signal s_CmpSignedGE : std_logic;
  signal s_CmpUnsignedLT : std_logic;
  signal s_CmpUnsignedGE : std_logic;
  signal s_ALUOverflow : std_logic;
  signal s_ControlHalt : std_logic;
  signal s_JumpTargetJAL  : std_logic_vector(N-1 downto 0);
  signal s_JumpTargetJALR : std_logic_vector(N-1 downto 0);

  component AddSub_32b is
    generic(N : integer := 32);
    port(i_A      : in std_logic_vector(N-1 downto 0);
       i_B      : in std_logic_vector(N-1 downto 0);
       nAdd_Sub : in std_logic_vector(1 downto 0);
       o_Result : out std_logic_vector(N-1 downto 0);
       o_CarryOut : out std_logic);
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

  -- s_Halt and s_Ovfl are driven near the end of this architecture.

  -- Implement the rest of your processor below this comment! 
  -- PORT MAPPING:

  ProgramCounter : PC
    port map(i_CLK => iCLK,
         i_RST => iRST,
         i_WE  => '1',
         i_D   => s_PCInput,
         o_Q   => s_NextInstAddr);

  Plus4Adder : AddSub_32b
    port map(i_A       => s_NextInstAddr,
         i_B       => x"00000004",
         nAdd_Sub  => "00",
         o_CarryOut=> open,
         o_Result  => s_Plus4Adder);

  BranchingAdder : AddSub_32b
    port map(i_A       => s_NextInstAddr,
         i_B       => s_ShiftedImm,
         nAdd_Sub  => "00",
         o_CarryOut=> open,
         o_Result  => s_BranchingAdder);

    ImmExtender : Extender
	port map(i_Inst	=> s_Inst,
		 i_Sel	=> s_ImmType,
		 o_Out	=> s_Extender);

  s_ShiftedImm <= s_Extender(30 downto 0) & '0';

    PCSrc_MUX : mux2to1_32b
    port map(i_A   => s_Plus4Adder,
         i_B   => s_BranchingAdder,
         i_Sel => s_PCSrc,
         o_Out => s_PCSrc_MUX);

    Control : ControlUnit
    port map(i_Opcode    => s_Inst(6 downto 0),
         i_funct3    => s_Inst(14 downto 12),
         i_funct7    => s_Inst(31 downto 25),
         o_Branch    => s_Branch,
         o_Jump      => s_Jump,
         o_MemRead   => s_MemRead,
         o_MemToReg  => s_MemToReg,
         o_MemWrite  => s_DMemWr,
         o_AndLink   => s_AndLink,
         o_ALUSrc    => s_ALUSrc,
         o_RegWrite  => s_RegWr,
         o_ImmType   => s_ImmType,
         o_ALUControl=> s_ALUControl,
         o_LoadWidth => s_LoadWidth,
         o_LoadSigned=> s_LoadSigned,
         o_StoreWidth=> s_StoreWidth,
         o_BranchType=> s_BranchType,
         o_Halt      => s_ControlHalt);

  s_Shamt <= s_Inst(24 downto 20) when (s_ALUSrc = '1' and
                   (s_ALUControl = ALU_SLL or s_ALUControl = ALU_SRL or s_ALUControl = ALU_SRA))
              else s_ReadData2(4 downto 0);
  s_ALUInputB <= s_Extender when s_ALUSrc = '1' else s_ReadData2;

  ALU_inst : ALU
    port map(i_A         => s_ALUInputA,
         i_B         => s_ALUInputB,
         i_ALUControl=> s_ALUControl,
         i_shamt     => s_Shamt,
         o_ALUOut    => s_ALUResult,
         o_Ovfl      => s_ALUOverflow);

    s_RegWrAddr <= s_Inst(11 downto 7);

    g_RegisterFile : RegisterFile
    port map(i_CLK       => iCLK,
         i_RST       => iRST,
         i_RegWrite  => s_RegWr,
         i_ReadReg1  => s_Inst(19 downto 15),
         i_ReadReg2  => s_Inst(24 downto 20),
         i_WriteReg  => s_RegWrAddr,
         i_WriteData => s_RegWrData,
         o_ReadData1 => s_ReadData1,
         o_ReadData2 => s_ReadData2);

  s_AUIPC     <= '1' when s_Inst(6 downto 0) = "0010111" else '0';
  s_ALUInputA <= s_NextInstAddr when s_AUIPC = '1' else s_ReadData1;

  s_CmpEq        <= '1' when s_ReadData1 = s_ReadData2 else '0';
  s_CmpSignedLT  <= '1' when signed(s_ReadData1) < signed(s_ReadData2) else '0';
  s_CmpSignedGE  <= '1' when signed(s_ReadData1) >= signed(s_ReadData2) else '0';
  s_CmpUnsignedLT<= '1' when unsigned(s_ReadData1) < unsigned(s_ReadData2) else '0';
  s_CmpUnsignedGE<= '1' when unsigned(s_ReadData1) >= unsigned(s_ReadData2) else '0';

  -- Decode the branch funct3 to decide whether the current comparison warrants a redirect.
  branch_decider : process(s_BranchType, s_CmpEq, s_CmpSignedLT, s_CmpSignedGE,
                           s_CmpUnsignedLT, s_CmpUnsignedGE)
  begin
    case s_BranchType is
      when "000" => s_BranchTaken <= s_CmpEq;            -- beq
      when "001" => s_BranchTaken <= not s_CmpEq;       -- bne
      when "100" => s_BranchTaken <= s_CmpSignedLT;     -- blt
      when "101" => s_BranchTaken <= s_CmpSignedGE;     -- bge
      when "110" => s_BranchTaken <= s_CmpUnsignedLT;   -- bltu
      when "111" => s_BranchTaken <= s_CmpUnsignedGE;   -- bgeu
      when others => s_BranchTaken <= '0';
    end case;
  end process;

  s_PCSrc   <= s_Branch and s_BranchTaken;

  s_JumpTargetJAL  <= s_BranchingAdder;
  s_JumpTargetJALR <= s_ALUResult(N-1 downto 1) & '0'; -- enforce alignment for JALR
  s_JumpTarget     <= s_JumpTargetJAL when s_ALUSrc = '0' else s_JumpTargetJALR;
  s_PCInput        <= s_JumpTarget when s_Jump = '1' else s_PCSrc_MUX;
  s_LinkData   <= s_Plus4Adder;

  -- Capture the byte lane within the addressed word for load/store width handling.
  s_ByteOffset <= s_ALUResult(1 downto 0);

  -- Merge store data into the targeted byte/halfword lane before issuing the write.
  store_packer : process(s_ReadData2, s_DMemOut, s_StoreWidth, s_ByteOffset)
    variable v_word : std_logic_vector(31 downto 0);
    variable v_half : std_logic_vector(15 downto 0);
    variable v_byte : std_logic_vector(7 downto 0);
  begin
    v_word := s_DMemOut;
    case s_StoreWidth is
      when "00" =>  -- byte store
        v_byte := s_ReadData2(7 downto 0);
        case s_ByteOffset is
          when "00" => v_word(7 downto 0)   := v_byte;
          when "01" => v_word(15 downto 8)  := v_byte;
          when "10" => v_word(23 downto 16) := v_byte;
          when others => v_word(31 downto 24) := v_byte;
        end case;
      when "01" =>  -- halfword store
        v_half := s_ReadData2(15 downto 0);
        if s_ByteOffset(1) = '0' then
          v_word(15 downto 0) := v_half;
        else
          v_word(31 downto 16) := v_half;
        end if;
      when others => -- word store (default)
        v_word := s_ReadData2;
    end case;
    s_StoreData <= v_word;
  end process;

  -- Extract the correct slice from the memory word and apply sign/zero extension.
  load_unpacker : process(s_DMemOut, s_LoadWidth, s_LoadSigned, s_ByteOffset)
    variable v_result : std_logic_vector(31 downto 0);
    variable v_byte   : std_logic_vector(7 downto 0);
    variable v_half   : std_logic_vector(15 downto 0);
  begin
    v_result := s_DMemOut; -- default to word
    case s_LoadWidth is
      when "00" =>  -- byte load
        case s_ByteOffset is
          when "00" => v_byte := s_DMemOut(7 downto 0);
          when "01" => v_byte := s_DMemOut(15 downto 8);
          when "10" => v_byte := s_DMemOut(23 downto 16);
          when others => v_byte := s_DMemOut(31 downto 24);
        end case;
        if s_LoadSigned = '1' then
          v_result := std_logic_vector(resize(signed(v_byte), 32));
        else
          v_result := std_logic_vector(resize(unsigned(v_byte), 32));
        end if;
      when "01" =>  -- halfword load
        if s_ByteOffset(1) = '0' then
          v_half := s_DMemOut(15 downto 0);
        else
          v_half := s_DMemOut(31 downto 16);
        end if;
        if s_LoadSigned = '1' then
          v_result := std_logic_vector(resize(signed(v_half), 32));
        else
          v_result := std_logic_vector(resize(unsigned(v_half), 32));
        end if;
      when others =>
        v_result := s_DMemOut;
    end case;
    s_LoadData <= v_result;
  end process;

  s_WriteBack <= s_LoadData when s_MemToReg = '1' else s_ALUResult;
  s_RegWrData <= s_LinkData when s_AndLink = '1' else s_WriteBack;

  s_DMemAddr <= s_ALUResult;
  s_DMemData <= s_StoreData;

  oALUOut <= s_ALUResult;

  -- Surface halt/overflow information to the toolflow harness.
  s_Halt <= s_ControlHalt;
  s_Ovfl <= s_ALUOverflow;

end structure;

