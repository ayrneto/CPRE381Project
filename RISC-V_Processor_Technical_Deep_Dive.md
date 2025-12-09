# RISC-V Processor Technical Deep Dive
## Complete Signal Mapping and Connection Analysis

### Table of Contents
1. [Top-Level Entity Interface](#top-level-entity-interface)
2. [Signal Declarations and Naming Convention](#signal-declarations-and-naming-convention)
3. [Instruction Fetch (IF) Stage Connections](#instruction-fetch-if-stage-connections)
4. [IF/ID Pipeline Register Connections](#ifid-pipeline-register-connections)
5. [Instruction Decode (ID) Stage Connections](#instruction-decode-id-stage-connections)
6. [Hazard Detection Unit Connections](#hazard-detection-unit-connections)
7. [ID/EX Pipeline Register Connections](#idex-pipeline-register-connections)
8. [Execute (EX) Stage Connections](#execute-ex-stage-connections)
9. [Forwarding Logic Connections](#forwarding-logic-connections)
10. [EX/MEM Pipeline Register Connections](#exmem-pipeline-register-connections)
11. [Memory (MEM) Stage Connections](#memory-mem-stage-connections)
12. [MEM/WB Pipeline Register Connections](#memwb-pipeline-register-connections)
13. [Write Back (WB) Stage Connections](#write-back-wb-stage-connections)
14. [Control Flow and Branch Logic](#control-flow-and-branch-logic)
15. [Memory Subsystem Architecture](#memory-subsystem-architecture)

---

## Top-Level Entity Interface

### Input Ports
```vhdl
iCLK            : in std_logic;              -- Master clock signal
iRST            : in std_logic;              -- Global reset signal (active high)
iInstLd         : in std_logic;              -- Instruction load enable for memory initialization
iInstAddr       : in std_logic_vector(N-1 downto 0);  -- Address for instruction loading
iInstExt        : in std_logic_vector(N-1 downto 0);  -- External instruction data for loading
```

### Output Ports
```vhdl
oALUOut         : out std_logic_vector(N-1 downto 0); -- ALU output for synthesis optimization
```

**Purpose**: The `oALUOut` signal ensures that all processor components remain connected during synthesis, preventing optimization away of unused logic.

---

## Signal Declarations and Naming Convention

### Memory Interface Signals
```vhdl
s_DMemWr        : std_logic;                 -- Data memory write enable
s_DMemAddr      : std_logic_vector(N-1 downto 0);  -- Data memory address
s_DMemData      : std_logic_vector(N-1 downto 0);  -- Data memory write data
s_DMemOut       : std_logic_vector(N-1 downto 0);  -- Data memory read data
```

### Register File Interface Signals
```vhdl
s_RegWr         : std_logic;                 -- Register file write enable
s_RegWrAddr     : std_logic_vector(4 downto 0);     -- Destination register address
s_RegWrData     : std_logic_vector(N-1 downto 0);   -- Register write data
```

### Instruction Memory Interface Signals
```vhdl
s_IMemAddr      : std_logic_vector(N-1 downto 0);   -- Instruction memory address (internal)
s_NextInstAddr  : std_logic_vector(N-1 downto 0);   -- Next instruction address from PC
s_Inst          : std_logic_vector(N-1 downto 0);   -- Fetched instruction
```

### Control and Status Signals
```vhdl
s_Halt          : std_logic;                 -- Halt signal for program termination
s_Ovfl          : std_logic;                 -- Overflow exception flag
```

**Naming Convention**: 
- `s_` prefix indicates internal signals
- Stage prefixes: `s_IF_`, `s_ID_`, `s_EX_`, `s_MEM_`, `s_WB_`
- Signal suffixes indicate function: `_Flush`, `_Stall`, `_Write`, etc.

---

## Instruction Fetch (IF) Stage Connections

### Program Counter (PC) Component
```vhdl
ProgramCounter : PC
port map(
    i_CLK => iCLK,                          -- Clock input from top-level
    i_RST => iRST,                          -- Reset input from top-level
    i_WE  => s_PCWrite,                     -- Write enable from HazardDetectionUnit
    i_D   => s_PCInput,                     -- Next PC value (from branch/jump logic)
    o_Q   => s_NextInstAddr                 -- Current PC output to instruction memory
);
```

**Connection Analysis**:
- **`s_PCWrite`**: Controlled by `HazardDetectionUnit` to stall PC during load-use hazards
- **`s_PCInput`**: Selected from multiple sources based on control flow decisions
- **`s_NextInstAddr`**: Feeds instruction memory address and PC+4 calculation

### PC+4 Adder
```vhdl
Plus4Adder : AddSub_32b
port map(
    i_A       => s_NextInstAddr,            -- Current PC value
    i_B       => x"00000004",               -- Constant 4 for next sequential instruction
    nAdd_Sub  => "00",                      -- Addition operation
    o_CarryOut=> open,                      -- Carry output not used
    o_Result  => s_PCPlus4                  -- PC+4 for sequential execution
);
```

**Connection Analysis**:
- **Input A**: Current PC from `s_NextInstAddr`
- **Input B**: Fixed constant `0x00000004` for 32-bit instruction increment
- **nAdd_Sub**: Set to "00" for addition operation
- **Output**: `s_PCPlus4` used for sequential instruction flow and jump-and-link operations

### Instruction Memory
```vhdl
with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',  -- Normal operation: use PC
                  iInstAddr when others;    -- Initialization: use external address

IMem: mem
generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N
)
port map(
    clk  => iCLK,                           -- Clock input
    addr => s_IMemAddr(11 downto 2),        -- Word-aligned address (drop lower 2 bits)
    data => iInstExt,                       -- External instruction data for loading
    we   => iInstLd,                        -- Write enable for instruction loading
    q    => s_Inst                          -- Fetched instruction output
);
```

**Connection Analysis**:
- **Address Selection**: `iInstLd` multiplexer chooses between normal PC (`s_NextInstAddr`) and external address (`iInstAddr`)
- **Address Alignment**: `s_IMemAddr(11 downto 2)` provides word-aligned addressing (4-byte instructions)
- **Write Enable**: `iInstLd` enables instruction memory initialization
- **Data Output**: `s_Inst` carries the fetched instruction to the IF/ID register

---

## IF/ID Pipeline Register Connections

```vhdl
IF_ID_reg : IF_ID
port map(
    i_CLK   => iCLK,                        -- Clock input
    i_RST   => iRST,                        -- Reset input
    i_Stall => not s_IF_ID_Write,           -- Stall signal (inverted write enable)
    i_Flush => s_IF_Flush,                  -- Flush signal from branch logic
    i_PC    => s_NextInstAddr,              -- Current PC value
    i_PC4   => s_PCPlus4,                   -- PC+4 value
    i_inst  => s_Inst,                      -- Fetched instruction
    o_inst  => s_ID_Inst,                   -- Instruction to decode stage
    o_PC4   => s_ID_PC4,                    -- PC+4 to decode stage
    o_PC    => s_ID_PC                      -- PC to decode stage
);
```

**Connection Analysis**:
- **Stall Control**: `not s_IF_ID_Write` inverts the write enable from HazardDetectionUnit
- **Flush Control**: `s_IF_Flush` clears the register during branch mispredictions
- **Data Flow**: Captures IF stage outputs and presents them to ID stage
- **Timing**: All outputs are registered and available on the next clock cycle

---

## Instruction Decode (ID) Stage Connections

### Control Unit
```vhdl
Control : ControlUnit
port map(
    i_Opcode     => s_ID_Inst(6 downto 0),     -- Instruction opcode field
    i_funct3     => s_ID_Inst(14 downto 12),   -- Function 3 field
    i_funct7     => s_ID_Inst(31 downto 25),   -- Function 7 field
    o_Branch     => s_ID_Branch,               -- Branch instruction flag
    o_Jump       => s_ID_Jump,                 -- Jump instruction flag
    o_MemRead    => s_ID_MemRead,              -- Memory read enable
    o_MemToReg   => s_ID_MemToReg,             -- Memory to register mux control
    o_MemWrite   => s_ID_MemWrite,             -- Memory write enable
    o_AndLink    => s_ID_AndLink,              -- Jump and link flag
    o_ALUSrc     => s_ID_ALUSrc,               -- ALU source mux control
    o_RegWrite   => s_ID_RegWrite,             -- Register write enable
    o_ImmType    => s_ID_ImmType,              -- Immediate type for extension
    o_ALUControl => s_ID_ALUControl,           -- ALU operation control
    o_LoadWidth  => s_ID_LoadWidth,            -- Load operation width
    o_LoadSigned => s_ID_LoadSigned,           -- Load sign extension control
    o_StoreWidth => s_ID_StoreWidth,           -- Store operation width
    o_BranchType => s_ID_BranchType,           -- Branch condition type
    o_Halt       => s_ID_Halt                 -- Halt instruction flag
);
```

**Connection Analysis**:
- **Instruction Parsing**: Extracts specific fields from `s_ID_Inst` based on RISC-V encoding
- **Control Generation**: Produces all control signals needed by subsequent pipeline stages
- **Distributed Control**: Each output signal controls specific processor operations

### Register File
```vhdl
RegisterFile_inst : RegisterFile
port map(
    i_CLK       => iCLK,                       -- Clock input
    i_RST       => iRST,                       -- Reset input
    i_RegWrite  => s_RegWr,                    -- Write enable from WB stage
    i_ReadReg1  => s_ID_Inst(19 downto 15),   -- rs1 field (source register 1)
    i_ReadReg2  => s_ID_Inst(24 downto 20),   -- rs2 field (source register 2)
    i_WriteReg  => s_RegWrAddr,                -- rd field from WB stage
    i_WriteData => s_RegWrData,                -- Write data from WB stage
    o_ReadData1 => s_ID_ReadData1,             -- Read data 1 to EX stage
    o_ReadData2 => s_ID_ReadData2              -- Read data 2 to EX stage
);
```

**Connection Analysis**:
- **Read Ports**: Asynchronous reads using instruction fields `rs1` and `rs2`
- **Write Port**: Synchronous write controlled by WB stage signals
- **Write-Back Connection**: Write signals come from the final pipeline stage
- **x0 Special Case**: Register 0 is hardwired to zero in the RegisterFile implementation

### Immediate Extender
```vhdl
ImmExtender : Extender
port map(
    i_Inst => s_ID_Inst,                      -- Full instruction word
    i_Sel  => s_ID_ImmType,                    -- Immediate type from ControlUnit
    o_Out  => s_ID_Imm                         -- Sign-extended immediate value
);
```

**Connection Analysis**:
- **Input**: Full instruction word contains immediate bits in various formats
- **Selection**: `s_ID_ImmType` determines how to extract and extend the immediate
- **Output**: Properly formatted immediate for ALU operations

### Branch Comparison Logic
```vhdl
-- Comparison signals
s_ID_CmpEq         <= '1' when s_ID_ReadData1 = s_ID_ReadData2 else '0';
s_ID_CmpSignedLT   <= '1' when signed(s_ID_ReadData1) < signed(s_ID_ReadData2) else '0';
s_ID_CmpSignedGE   <= '1' when signed(s_ID_ReadData1) >= signed(s_ID_ReadData2) else '0';
s_ID_CmpUnsignedLT <= '1' when unsigned(s_ID_ReadData1) < unsigned(s_ID_ReadData2) else '0';
s_ID_CmpUnsignedGE <= '1' when unsigned(s_ID_ReadData1) >= unsigned(s_ID_ReadData2) else '0';

-- Branch decision logic
branch_decider : process(s_ID_BranchType, s_ID_CmpEq, s_ID_CmpSignedLT, s_ID_CmpSignedGE,
                         s_ID_CmpUnsignedLT, s_ID_CmpUnsignedGE)
begin
    case s_ID_BranchType is
        when "000" => s_ID_BranchTaken <= s_ID_CmpEq;        -- BEQ
        when "001" => s_ID_BranchTaken <= not s_ID_CmpEq;    -- BNE
        when "100" => s_ID_BranchTaken <= s_ID_CmpSignedLT;  -- BLT
        when "101" => s_ID_BranchTaken <= s_ID_CmpSignedGE;  -- BGE
        when "110" => s_ID_BranchTaken <= s_ID_CmpUnsignedLT;-- BLTU
        when "111" => s_ID_BranchTaken <= s_ID_CmpUnsignedGE;-- BGEU
        when others => s_ID_BranchTaken <= '0';
    end case;
end process;
```

**Connection Analysis**:
- **Comparison Inputs**: Register data from `s_ID_ReadData1` and `s_ID_ReadData2`
- **Branch Type**: `s_ID_BranchType` selects which comparison result to use
- **Early Resolution**: Branch decision made in ID stage to minimize pipeline bubbles

### Branch Target Calculation
```vhdl
s_ID_BranchImm <= s_ID_Imm;                    -- Branch offset from immediate

BranchingAdder : AddSub_32b
port map(
    i_A       => s_ID_PC,                      -- Current instruction PC
    i_B       => s_ID_BranchImm,               -- Branch offset immediate
    nAdd_Sub  => "00",                         -- Addition operation
    o_CarryOut=> open,                         -- Carry not used
    o_Result  => s_ID_BranchTarget             -- Branch target address
);

s_ID_JALRTarget <= std_logic_vector(unsigned(s_ID_ReadData1) + unsigned(s_ID_Imm));
```

**Connection Analysis**:
- **PC-Relative Branches**: Add PC to immediate for branch target
- **Register-Indirect Jumps**: Add register value to immediate for JALR target
- **Target Selection**: Different calculation methods for different instruction types

---

## Hazard Detection Unit Connections

```vhdl
HazardDetectionUnit_inst : HazardDetectionUnit
port map(
    ID_EX_MemRead => s_EX_MemRead,             -- Load instruction flag from EX stage
    ID_EX_rd      => s_EX_rd,                  -- Destination register from EX stage
    IF_ID_rs1     => s_ID_Inst(19 downto 15), -- Source register 1 from ID stage
    IF_ID_rs2     => s_ID_Inst(24 downto 20), -- Source register 2 from ID stage
    PCWrite       => s_PCWrite,                -- PC write enable output
    IF_ID_Write   => s_IF_ID_Write,            -- IF/ID register write enable
    FlushMux_Sel  => s_FlushMux_Sel            -- Control signal flush selection
);
```

**Connection Analysis**:
- **Hazard Detection**: Compares EX stage destination with ID stage sources
- **Load-Use Detection**: Only triggers on memory read instructions (`s_EX_MemRead`)
- **Pipeline Control**: Controls PC and IF/ID register updates during stalls
- **Control Flushing**: `s_FlushMux_Sel` zeros control signals during hazards

### Hazard Control Signal Modification
```vhdl
s_ID_RegWrite_Hazard <= '0' when s_FlushMux_Sel = '1' else s_ID_RegWrite;
s_ID_MemRead_Hazard  <= '0' when s_FlushMux_Sel = '1' else s_ID_MemRead;
s_ID_MemWrite_Hazard <= '0' when s_FlushMux_Sel = '1' else s_ID_MemWrite;
s_ID_MemToReg_Hazard <= '0' when s_FlushMux_Sel = '1' else s_ID_MemToReg;
s_ID_AndLink_Hazard  <= '0' when s_FlushMux_Sel = '1' else s_ID_AndLink;
```

**Connection Analysis**:
- **Signal Gating**: Converts control signals to NOPs during load-use hazards
- **Selective Flushing**: Only affects pipeline control, not data flow
- **Bubble Insertion**: Creates a pipeline bubble without affecting later instructions

---

## ID/EX Pipeline Register Connections

```vhdl
ID_EX_reg : ID_EX
port map(
    i_CLK       => iCLK,                       -- Clock input
    i_RST       => iRST,                       -- Reset input
    i_Stall     => '0',                        -- Stall control (unused)
    i_Flush     => s_ID_Flush,                 -- Flush control
    i_rd        => s_ID_Inst(11 downto 7),    -- Destination register field
    i_rs1       => s_ID_Inst(19 downto 15),   -- Source register 1 field
    i_rs2       => s_ID_Inst(24 downto 20),   -- Source register 2 field
    i_ReadData1 => s_ID_ReadData1,             -- Register file read data 1
    i_ReadData2 => s_ID_ReadData2,             -- Register file read data 2
    i_PC        => s_ID_PC,                    -- Instruction PC value
    i_PC4       => s_ID_PC4,                   -- PC+4 value
    i_imm       => s_ID_Imm,                   -- Extended immediate value
    i_Shamt     => s_ID_Shamt,                 -- Shift amount field
    i_ALUControl=> s_ID_ALUControl,            -- ALU operation control
    i_ALUSrc    => s_ID_ALUSrc,                -- ALU source mux control
    i_RegWrite  => s_ID_RegWrite_Hazard,       -- Register write enable (hazard-modified)
    i_MemToReg  => s_ID_MemToReg_Hazard,       -- Memory to register mux (hazard-modified)
    i_MemRead   => s_ID_MemRead_Hazard,        -- Memory read enable (hazard-modified)
    i_MemWrite  => s_ID_MemWrite_Hazard,       -- Memory write enable (hazard-modified)
    i_LoadWidth => s_ID_LoadWidth,             -- Load operation width
    i_LoadSigned=> s_ID_LoadSigned,            -- Load sign extension
    i_StoreWidth=> s_ID_StoreWidth,            -- Store operation width
    i_AndLink   => s_ID_AndLink_Hazard,        -- Jump and link flag (hazard-modified)
    i_AUIPC     => s_ID_AUIPC,                 -- Add upper immediate to PC flag
    i_Halt      => s_ID_Halt,                  -- Halt instruction flag
    -- Outputs to EX stage
    o_rd        => s_EX_rd,                    -- Destination register to EX
    o_rs1       => s_EX_rs1,                   -- Source register 1 to EX
    o_rs2       => s_EX_rs2,                   -- Source register 2 to EX
    o_ReadData1 => s_EX_ReadData1,             -- Read data 1 to EX
    o_ReadData2 => s_EX_ReadData2,             -- Read data 2 to EX
    o_PC        => s_EX_PC,                    -- PC to EX
    o_PC4       => s_EX_PC4,                   -- PC+4 to EX
    o_imm       => s_EX_Imm,                   -- Immediate to EX
    o_Shamt     => s_EX_Shamt,                 -- Shift amount to EX
    o_ALUControl=> s_EX_ALUControl,            -- ALU control to EX
    o_ALUSrc    => s_EX_ALUSrc,                -- ALU source control to EX
    o_RegWrite  => s_EX_RegWrite,              -- Register write to EX
    o_MemToReg  => s_EX_MemToReg,             -- Memory to register to EX
    o_MemRead   => s_EX_MemRead,               -- Memory read to EX
    o_MemWrite  => s_EX_MemWrite,              -- Memory write to EX
    o_LoadWidth => s_EX_LoadWidth,             -- Load width to EX
    o_LoadSigned=> s_EX_LoadSigned,            -- Load signed to EX
    o_StoreWidth=> s_EX_StoreWidth,            -- Store width to EX
    o_AndLink   => s_EX_AndLink,               -- Jump and link to EX
    o_AUIPC     => s_EX_AUIPC,                 -- AUIPC flag to EX
    o_Halt      => s_EX_Halt                   -- Halt flag to EX
);
```

**Connection Analysis**:
- **Register Address Propagation**: rs1, rs2, rd fields needed for forwarding logic
- **Data Propagation**: Register values and immediate carry forward to EX stage
- **Control Propagation**: All control signals needed for EX, MEM, WB stages
- **Hazard Integration**: Uses hazard-modified control signals to handle stalls

### Additional ID Stage Signal Generation
```vhdl
s_ID_Shamt <= s_ID_Inst(24 downto 20);        -- Shift amount from instruction
s_ID_AUIPC <= '1' when s_ID_Inst(6 downto 0) = "0010111" else '0'; -- AUIPC detection
```

**Connection Analysis**:
- **Shift Amount**: Extracted directly from instruction rs2 field
- **AUIPC Detection**: Special case where PC is used as ALU input instead of register

---

## Execute (EX) Stage Connections

### Shift Amount Selection
```vhdl
s_Shamt <= s_EX_Shamt when (s_EX_ALUSrc = '1' and (s_EX_ALUControl = ALU_SLL or 
                                                    s_EX_ALUControl = ALU_SRL or 
                                                    s_EX_ALUControl = ALU_SRA))
           else s_EX_ReadData2(4 downto 0);
```

**Connection Analysis**:
- **Immediate Shifts**: Use instruction immediate field for shift amount
- **Register Shifts**: Use lower 5 bits of register for variable shifts
- **ALU Control Dependency**: Selection based on specific shift operations

### Forwarding Mux A
```vhdl
ForwardMuxA_inst : ForwardMuxA
port map(
    ReadData1       => s_EX_ReadData1,         -- Original register data
    Mem_WB_Data     => s_WriteBack,            -- Data from WB stage
    EX_Mem_ALUResult => s_MEM_ALUResult,       -- Data from MEM stage
    Sel             => s_ForwardA,             -- Selection from ForwardingUnit
    ALU_InputA      => s_ALUInputA_Forward     -- Forwarded ALU input A
);
```

### Forwarding Mux B
```vhdl
ForwardMuxB_inst : ForwardMuxB
port map(
    ReadData2       => s_EX_ReadData2,         -- Original register data
    Mem_WB_Data     => s_WriteBack,            -- Data from WB stage
    EX_Mem_ALUResult => s_MEM_ALUResult,       -- Data from MEM stage
    Sel             => s_ForwardB,             -- Selection from ForwardingUnit
    ALU_InputB      => s_ALUInputB_Forward     -- Forwarded ALU input B
);
```

**Connection Analysis**:
- **Data Sources**: Three possible sources for each ALU input
- **Priority**: EX/MEM has priority over MEM/WB for most recent data
- **Bypass Path**: Direct data path from later stages to earlier computation

### ALU Input Selection
```vhdl
s_ALUInputA <= s_EX_PC when s_EX_AUIPC = '1' else s_ALUInputA_Forward;
s_ALUInputB <= s_EX_Imm when s_EX_ALUSrc = '1' else s_ALUInputB_Forward;
```

**Connection Analysis**:
- **Input A Selection**: PC for AUIPC instructions, otherwise forwarded register data
- **Input B Selection**: Immediate for I-type instructions, otherwise forwarded register data
- **Instruction Type Dependency**: Selection based on instruction encoding

### ALU Core
```vhdl
ALU_inst : ALU
port map(
    i_A         => s_ALUInputA,                -- ALU input A (from mux)
    i_B         => s_ALUInputB,                -- ALU input B (from mux)
    i_ALUControl=> s_EX_ALUControl,            -- Operation selection
    i_shamt     => s_Shamt,                    -- Shift amount
    o_ALUOut    => s_ALUResult,                -- ALU computation result
    o_Ovfl      => s_ALUOverflow               -- Overflow flag
);
```

**Connection Analysis**:
- **Input Sources**: Carefully selected and forwarded data
- **Operation Control**: From control unit via pipeline registers
- **Result Distribution**: ALU result used for addresses, write data, and final results

---

## Forwarding Logic Connections

```vhdl
ForwardingUnit_inst : ForwardingUnit
port map(
    ID_EX_rs1     => s_EX_rs1,                 -- Source register 1 from EX stage
    ID_EX_rs2     => s_EX_rs2,                 -- Source register 2 from EX stage
    EX_Mem_rd     => s_MEM_rd,                 -- Destination register from MEM stage
    EX_Mem_RegWrite => s_MEM_RegWrite,         -- Register write flag from MEM stage
    Mem_WB_rd     => s_WB_rd,                  -- Destination register from WB stage
    Mem_WB_RegWrite => s_WB_RegWrite,          -- Register write flag from WB stage
    ForwardA      => s_ForwardA,               -- Forward control for ALU input A
    ForwardB      => s_ForwardB                -- Forward control for ALU input B
);
```

**Connection Analysis**:
- **Source Tracking**: Monitors which registers are being read in EX stage
- **Destination Tracking**: Monitors which registers are being written in later stages
- **Write Enable Dependency**: Only forwards from instructions that actually write registers
- **Priority Logic**: EX/MEM stage has priority over MEM/WB stage for forwarding

### Forwarding Control Encoding
- **"00"**: No forwarding, use original register data
- **"01"**: Forward from MEM/WB stage (2 instructions ahead)
- **"10"**: Forward from EX/MEM stage (1 instruction ahead)

---

## EX/MEM Pipeline Register Connections

```vhdl
EX_Mem_reg : EX_Mem
port map(
    i_CLK       => iCLK,                       -- Clock input
    i_RST       => iRST,                       -- Reset input
    i_Stall     => '0',                        -- Stall control (unused)
    i_Flush     => '0',                        -- Flush control (unused)
    i_ALUResult => s_ALUResult,                -- ALU computation result
    i_StoreData => s_ALUInputB_Forward,        -- Store data (forwarded register value)
    i_rd        => s_EX_rd,                    -- Destination register
    i_RegWrite  => s_EX_RegWrite,              -- Register write enable
    i_MemToReg  => s_EX_MemToReg,             -- Memory to register control
    i_MemRead   => s_EX_MemRead,               -- Memory read enable
    i_MemWrite  => s_EX_MemWrite,              -- Memory write enable
    i_LoadWidth => s_EX_LoadWidth,             -- Load operation width
    i_LoadSigned=> s_EX_LoadSigned,            -- Load sign extension control
    i_StoreWidth=> s_EX_StoreWidth,            -- Store operation width
    i_AndLink   => s_EX_AndLink,               -- Jump and link flag
    i_PC4       => s_EX_PC4,                   -- PC+4 value
    i_Halt      => s_EX_Halt,                  -- Halt instruction flag
    -- Outputs to MEM stage
    o_ALUResult => s_MEM_ALUResult,            -- ALU result to MEM
    o_StoreData => s_MEM_StoreData,            -- Store data to MEM
    o_rd        => s_MEM_rd,                   -- Destination register to MEM
    o_RegWrite  => s_MEM_RegWrite,             -- Register write to MEM
    o_MemToReg  => s_MEM_MemToReg,             -- Memory to register to MEM
    o_MemRead   => s_MEM_MemRead,              -- Memory read to MEM
    o_MemWrite  => s_MEM_MemWrite,             -- Memory write to MEM
    o_LoadWidth => s_MEM_LoadWidth,            -- Load width to MEM
    o_LoadSigned=> s_MEM_LoadSigned,           -- Load signed to MEM
    o_StoreWidth=> s_MEM_StoreWidth,           -- Store width to MEM
    o_AndLink   => s_MEM_AndLink,              -- Jump and link to MEM
    o_PC4       => s_MEM_PC4,                  -- PC+4 to MEM
    o_Halt      => s_MEM_Halt                  -- Halt to MEM
);
```

**Connection Analysis**:
- **ALU Result**: Becomes memory address for load/store operations
- **Store Data**: Uses forwarded register value to handle data hazards
- **Memory Control**: All memory operation controls propagate to MEM stage
- **Write-Back Info**: Register destination and control signals continue to WB

---

## Memory (MEM) Stage Connections

### Data Memory Interface
```vhdl
DMem: mem
generic map(
    ADDR_WIDTH => ADDR_WIDTH,
    DATA_WIDTH => N
)
port map(
    clk  => iCLK,                              -- Clock input
    addr => s_DMemAddr(11 downto 2),           -- Word-aligned memory address
    data => s_DMemData,                        -- Data to write to memory
    we   => s_DMemWr,                          -- Write enable signal
    q    => s_DMemOut                          -- Data read from memory
);
```

**Connection Analysis**:
- **Address**: From ALU result, word-aligned by dropping lower 2 bits
- **Write Data**: Processed store data from store packer logic
- **Write Enable**: Directly from MEM stage memory write control
- **Read Data**: Raw memory output, processed by load unpacker

### Final Memory Control Assignments
```vhdl
s_DMemWr   <= s_MEM_MemWrite;                  -- Memory write enable
s_DMemAddr <= s_MEM_ALUResult;                 -- Memory address from ALU
```

### Store Data Packing Logic
```vhdl
store_packer : process(s_MEM_StoreData, s_DMemOut, s_MEM_StoreWidth, s_MEM_ByteOffset)
    variable v_word : std_logic_vector(31 downto 0);
    variable v_half : std_logic_vector(15 downto 0);
    variable v_byte : std_logic_vector(7 downto 0);
begin
    v_word := s_DMemOut;  -- Start with current memory contents
    case s_MEM_StoreWidth is
        when "00" =>  -- Store Byte
            v_byte := s_MEM_StoreData(7 downto 0);
            case s_MEM_ByteOffset is
                when "00" => v_word(7 downto 0)   := v_byte;   -- Byte 0
                when "01" => v_word(15 downto 8)  := v_byte;   -- Byte 1
                when "10" => v_word(23 downto 16) := v_byte;   -- Byte 2
                when others => v_word(31 downto 24) := v_byte; -- Byte 3
            end case;
        when "01" =>  -- Store Half-word
            v_half := s_MEM_StoreData(15 downto 0);
            if s_MEM_ByteOffset(1) = '0' then
                v_word(15 downto 0) := v_half;   -- Lower half
            else
                v_word(31 downto 16) := v_half;  -- Upper half
            end if;
        when others =>  -- Store Word
            v_word := s_MEM_StoreData;
    end case;
    s_DMemData <= v_word;
end process;
```

**Connection Analysis**:
- **Byte Offset**: From ALU result lower bits `s_MEM_ALUResult(1 downto 0)`
- **Read-Modify-Write**: Preserves unmodified bytes in memory word
- **Width Selection**: Handles byte, half-word, and word store operations
- **Alignment**: Places data in correct byte lanes based on address

### Load Data Unpacking Logic
```vhdl
load_unpacker : process(s_DMemOut, s_MEM_LoadWidth, s_MEM_LoadSigned, s_MEM_ByteOffset)
    variable v_result : std_logic_vector(31 downto 0);
    variable v_byte   : std_logic_vector(7 downto 0);
    variable v_half   : std_logic_vector(15 downto 0);
begin
    v_result := s_DMemOut;  -- Default to full word
    case s_MEM_LoadWidth is
        when "00" =>  -- Load Byte
            case s_MEM_ByteOffset is
                when "00" => v_byte := s_DMemOut(7 downto 0);   -- Byte 0
                when "01" => v_byte := s_DMemOut(15 downto 8);  -- Byte 1
                when "10" => v_byte := s_DMemOut(23 downto 16); -- Byte 2
                when others => v_byte := s_DMemOut(31 downto 24); -- Byte 3
            end case;
            if s_MEM_LoadSigned = '1' then
                v_result := std_logic_vector(resize(signed(v_byte), 32));
            else
                v_result := std_logic_vector(resize(unsigned(v_byte), 32));
            end if;
        when "01" =>  -- Load Half-word
            if s_MEM_ByteOffset(1) = '0' then
                v_half := s_DMemOut(15 downto 0);   -- Lower half
            else
                v_half := s_DMemOut(31 downto 16);  -- Upper half
            end if;
            if s_MEM_LoadSigned = '1' then
                v_result := std_logic_vector(resize(signed(v_half), 32));
            else
                v_result := std_logic_vector(resize(unsigned(v_half), 32));
            end if;
        when others =>  -- Load Word
            v_result := s_DMemOut;
    end case;
    s_MEM_LoadData <= v_result;
end process;
```

**Connection Analysis**:
- **Byte Extraction**: Selects correct bytes based on address alignment
- **Sign Extension**: Extends byte/half-word loads based on signed/unsigned flag
- **Zero Extension**: For unsigned loads, fills upper bits with zeros
- **Pass-Through**: Word loads use memory data directly

---

## MEM/WB Pipeline Register Connections

```vhdl
Mem_WB_reg : Mem_WB
port map(
    i_CLK      => iCLK,                        -- Clock input
    i_RST      => iRST,                        -- Reset input
    i_Stall    => '0',                         -- Stall control (unused)
    i_Flush    => '0',                         -- Flush control (unused)
    i_DMem     => s_MEM_LoadData,              -- Processed load data
    i_ALUResult=> s_MEM_ALUResult,             -- ALU result for computational instructions
    i_PC4      => s_MEM_PC4,                   -- PC+4 for jump-and-link
    i_rd       => s_MEM_rd,                    -- Destination register
    i_RegWrite => s_MEM_RegWrite,              -- Register write enable
    i_MemToReg => s_MEM_MemToReg,              -- Memory to register control
    i_AndLink  => s_MEM_AndLink,               -- Jump and link flag
    i_Halt     => s_MEM_Halt,                  -- Halt instruction flag
    -- Outputs to WB stage
    o_DMem     => s_WB_DMem,                   -- Load data to WB
    o_ALUResult=> s_WB_ALUResult,              -- ALU result to WB
    o_PC4      => s_WB_PC4,                    -- PC+4 to WB
    o_rd       => s_WB_rd,                     -- Destination register to WB
    o_RegWrite => s_WB_RegWrite,               -- Register write to WB
    o_MemToReg => s_WB_MemToReg,               -- Memory to register to WB
    o_AndLink  => s_WB_AndLink,                -- Jump and link to WB
    o_Halt     => s_WB_Halt                    -- Halt to WB
);
```

**Connection Analysis**:
- **Data Sources**: Three possible write-back data sources
- **Control Propagation**: Final control signals for register file write
- **Destination**: Register address for write-back operation

---

## Write Back (WB) Stage Connections

### Write-Back Data Selection
```vhdl
s_WriteBack <= s_WB_DMem when s_WB_MemToReg = '1' else s_WB_ALUResult;
s_RegWrData <= s_WB_PC4 when s_WB_AndLink = '1' else s_WriteBack;
```

**Connection Analysis**:
- **Primary Mux**: Selects between memory data and ALU result
- **Jump-and-Link Override**: PC+4 for JAL/JALR instructions takes priority
- **Final Data**: `s_RegWrData` is the actual data written to register file

### Register File Write Signals
```vhdl
s_RegWr     <= s_WB_RegWrite;                  -- Write enable to register file
s_RegWrAddr <= s_WB_rd;                        -- Write address to register file
```

### Final Output Assignments
```vhdl
oALUOut <= s_ALUResult;                        -- ALU output for synthesis
s_Halt  <= s_WB_Halt;                          -- Final halt signal
s_Ovfl  <= s_ALUOverflow;                      -- Final overflow flag
```

**Connection Analysis**:
- **Synthesis Output**: `oALUOut` prevents optimization of ALU and related logic
- **Program Termination**: `s_Halt` indicates when program execution completes
- **Exception Handling**: `s_Ovfl` signals arithmetic overflow conditions

---

## Control Flow and Branch Logic

### PC Input Selection
```vhdl
s_PCInput <= s_ID_JumpTarget when s_ID_Jump = '1' else
             s_ID_BranchTarget when (s_ID_Branch = '1' and s_ID_BranchTaken = '1') else
             s_PCPlus4;
```

**Connection Analysis**:
- **Priority**: Jump instructions have highest priority
- **Branch**: Taken branches have second priority
- **Sequential**: Default to PC+4 for normal instruction flow

### Jump Target Selection
```vhdl
s_ID_JumpTarget <= s_ID_BranchTarget when s_ID_ALUSrc = '0'    -- JAL (PC-relative)
                   else s_ID_JALRTarget(N-1 downto 1) & '0';  -- JALR (register+immediate)
```

**Connection Analysis**:
- **JAL Instructions**: Use PC + immediate (same calculation as branches)
- **JALR Instructions**: Use register + immediate, force LSB to 0 for alignment
- **ALUSrc Reuse**: Uses existing control signal to distinguish jump types

### Instruction Flush Control
```vhdl
s_IF_Flush <= '1' when (s_ID_Jump = '1') or (s_ID_Branch = '1' and s_ID_BranchTaken = '1') else '0';
s_ID_Flush <= '0';  -- Disabled to fix timing issues
```

**Connection Analysis**:
- **IF Stage Flush**: Clears incorrectly fetched instruction after control transfer
- **ID Stage Flush**: Disabled in this implementation for timing optimization
- **Branch Penalty**: One cycle penalty for taken branches and jumps

---

## Memory Subsystem Architecture

### Instruction Memory Characteristics
- **Address Width**: 12 bits (4KB capacity)
- **Word-Aligned Access**: Address bits [11:2] used, [1:0] ignored
- **Initialization**: External loading capability via `iInstLd` and `iInstExt`
- **Read-Only**: During normal operation, only reads instruction words

### Data Memory Characteristics
- **Address Width**: 12 bits (4KB capacity) 
- **Byte Addressable**: Supports byte, half-word, and word operations
- **Read-Modify-Write**: Store operations preserve unmodified bytes
- **Load Formatting**: Automatic alignment and sign/zero extension

### Address Space Layout
```
0x0000 - 0x0FFF: Instruction Memory (4KB)
0x0000 - 0x0FFF: Data Memory (4KB, separate address space)
```

**Connection Analysis**:
- **Harvard Architecture**: Separate instruction and data memories
- **Address Range**: Both memories use 12-bit addressing (4KB each)
- **Word Alignment**: Instructions always word-aligned, data supports byte-level access

---

## Summary of Critical Connection Points

### 1. **Forwarding Paths**
- EX/MEM → EX stage ALU inputs (1-cycle forward)
- MEM/WB → EX stage ALU inputs (2-cycle forward)
- Both paths bypass register file read delays

### 2. **Hazard Control Paths**
- EX stage → Hazard Detection Unit (load instruction detection)
- Hazard Detection → PC and IF/ID register (stall control)
- Hazard Detection → ID stage control signals (bubble insertion)

### 3. **Branch Control Paths**
- ID stage comparison → Branch decision logic
- Branch decision → IF stage flush control
- Jump/Branch targets → PC input selection

### 4. **Memory Interface Paths**
- ALU result → Data memory address
- Forwarded register data → Store data processing
- Memory output → Load data processing
- Processed load data → Write-back stage

### 5. **Register File Connections**
- ID stage → Register read (asynchronous)
- WB stage → Register write (synchronous)
- Write-back data from three sources (ALU, memory, PC+4)

This architecture demonstrates a complete 5-stage RISC-V pipeline with sophisticated hazard handling, efficient forwarding, and proper memory interface design.

---

## Detailed ALU Subsystem Architecture

### ALU Internal Component Connections

The ALU is implemented as a structural design with three main functional units:

#### AddSub Unit Connection
```vhdl
AddSub_Unit : AddSub_32b
port map(
    i_A => i_A,                                -- Direct connection to ALU input A
    i_B => i_B,                                -- Direct connection to ALU input B
    nAdd_Sub => s_AddSub_Control,              -- "01" for SUB, "00" for ADD
    o_Result => s_AddSub_Result,               -- 32-bit addition/subtraction result
    o_CarryOut => s_AddSub_CarryOut            -- Carry output (not used in RISC-V)
);
```

**Control Signal Generation:**
```vhdl
s_AddSub_Control <= "01" when (i_ALUControl = ALU_SUB) else "00";
```

#### Logic Unit Connection
```vhdl
Logic_Unit_inst : LogicUnit
port map(
    i_A => i_A,                                -- Direct connection to ALU input A
    i_B => i_B,                                -- Direct connection to ALU input B
    i_Sel => s_Logic_Control,                  -- 2-bit operation selection
    o_Out => s_Logic_Result                    -- 32-bit logical operation result
);
```

**Logic Control Encoding:**
```vhdl
s_Logic_Control <= "00" when (i_ALUControl = ALU_AND) else    -- AND operation
                   "01" when (i_ALUControl = ALU_OR) else     -- OR operation
                   "10" when (i_ALUControl = ALU_XOR) else    -- XOR operation
                   "11";                                      -- NOR operation
```

#### Barrel Shifter Connection
```vhdl
Shifter_Unit : BarrelShifter
port map(
    i_Data => i_A,                             -- Data to be shifted (always input A)
    i_ShiftAmt => i_shamt,                     -- 5-bit shift amount
    i_Mode => i_ALUControl,                    -- Reuses ALU control for shift type
    o_Result => s_Shift_Result                 -- 32-bit shift result
);
```

**Shift Mode Decoding (within BarrelShifter):**
- **ALU_SLL ("0100")**: Shift Left Logical
- **ALU_SRL ("0101")**: Shift Right Logical  
- **ALU_SRA ("1001")**: Shift Right Arithmetic

#### Comparison Operations
```vhdl
-- Type conversions for comparison
s_A_signed <= signed(i_A);
s_B_signed <= signed(i_B);
s_A_unsigned <= unsigned(i_A);
s_B_unsigned <= unsigned(i_B);

-- Set Less Than operations
s_SLT_Result <= x"00000001" when (s_A_signed < s_B_signed) else x"00000000";
s_SLTU_Result <= x"00000001" when (s_A_unsigned < s_B_unsigned) else x"00000000";
```

#### ALU Output Multiplexer
```vhdl
process(i_ALUControl, s_AddSub_Result, s_Logic_Result, s_Shift_Result, s_SLT_Result, s_SLTU_Result, i_B)
begin
    case i_ALUControl is
        when ALU_ADD | ALU_SUB =>
            o_ALUOut <= s_AddSub_Result;       -- Arithmetic operations
        when ALU_AND | ALU_OR | ALU_XOR | ALU_NOR =>
            o_ALUOut <= s_Logic_Result;        -- Logical operations
        when ALU_SLL | ALU_SRL | ALU_SRA =>
            o_ALUOut <= s_Shift_Result;        -- Shift operations
        when ALU_SLT =>
            o_ALUOut <= s_SLT_Result;          -- Signed comparison
        when ALU_SLTU =>
            o_ALUOut <= s_SLTU_Result;         -- Unsigned comparison
        when ALU_PASSIMM =>
            o_ALUOut <= i_B;                   -- Pass immediate (for LUI)
        when others =>
            o_ALUOut <= s_AddSub_Result;       -- Default to ADD
    end case;
end process;
```

---

## Pipeline Register Detailed Implementation

### IF/ID Register Internal Structure

```vhdl
process(i_CLK, i_RST)
begin
    if rising_edge(i_CLK) then
        if i_RST = '1' or i_Flush = '1' then
            o_inst <= (others => '0');         -- Clear instruction
            o_PC4 <= (others => '0');          -- Clear PC+4
            o_PC <= (others => '0');           -- Clear PC
        elsif i_Stall = '0' then               -- Only update when not stalled
            o_inst <= i_inst;                  -- Latch instruction
            o_PC4 <= i_PC4;                    -- Latch PC+4
            o_PC <= i_PC;                      -- Latch PC
        end if;
        -- When stalled (i_Stall = '1'), outputs maintain previous values
    end if;
end process;
```

**Timing Analysis:**
- **Setup Time**: Input data must be stable before rising clock edge
- **Hold Time**: Input data must remain stable after rising clock edge
- **Propagation Delay**: Outputs valid after clock-to-q delay
- **Stall Behavior**: Maintains outputs when stalled, creating pipeline bubble

### ID/EX Register Control Signal Propagation

**Data Signals (32-bit each):**
- `i_ReadData1 → o_ReadData1`: Register file read port 1 data
- `i_ReadData2 → o_ReadData2`: Register file read port 2 data
- `i_PC → o_PC`: Current instruction program counter
- `i_PC4 → o_PC4`: Next sequential instruction address
- `i_imm → o_imm`: Sign-extended immediate value

**Address Signals (5-bit each):**
- `i_rd → o_rd`: Destination register address
- `i_rs1 → o_rs1`: Source register 1 address (for forwarding)
- `i_rs2 → o_rs2`: Source register 2 address (for forwarding)

**Control Signals (1-bit each):**
- `i_RegWrite → o_RegWrite`: Enable register file write in WB stage
- `i_MemRead → o_MemRead`: Enable data memory read in MEM stage
- `i_MemWrite → o_MemWrite`: Enable data memory write in MEM stage
- `i_MemToReg → o_MemToReg`: Select memory data for register write
- `i_ALUSrc → o_ALUSrc`: Select immediate vs register for ALU input B
- `i_AndLink → o_AndLink`: Select PC+4 for register write (JAL/JALR)
- `i_AUIPC → o_AUIPC`: Select PC for ALU input A (AUIPC instruction)

**Multi-bit Control Signals:**
- `i_ALUControl → o_ALUControl` (4-bit): ALU operation selection
- `i_LoadWidth → o_LoadWidth` (2-bit): Load operation width (byte/half/word)
- `i_StoreWidth → o_StoreWidth` (2-bit): Store operation width
- `i_Shamt → o_Shamt` (5-bit): Shift amount for shift operations

---

## Forwarding Unit Detailed Logic

### Forwarding Priority Logic

```vhdl
process(ID_EX_rs1, ID_EX_rs2, EX_Mem_rd, EX_Mem_RegWrite, Mem_WB_rd, Mem_WB_RegWrite)
begin
    ForwardA <= "00";  -- Default: no forwarding
    ForwardB <= "00";  -- Default: no forwarding

    -- Forward to ALU Input A (rs1)
    if(EX_Mem_RegWrite = '1' AND EX_Mem_rd /= "00000" AND EX_Mem_rd = ID_EX_rs1) then
        ForwardA <= "10";    -- Forward from EX/MEM stage (highest priority)
    elsif(Mem_WB_RegWrite = '1' AND Mem_WB_rd /= "00000" AND Mem_WB_rd = ID_EX_rs1) then
        ForwardA <= "01";    -- Forward from MEM/WB stage (lower priority)
    end if;

    -- Forward to ALU Input B (rs2)
    if(EX_Mem_RegWrite = '1' AND EX_Mem_rd /= "00000" AND EX_Mem_rd = ID_EX_rs2) then
        ForwardB <= "10";    -- Forward from EX/MEM stage (highest priority)
    elsif(Mem_WB_RegWrite = '1' AND Mem_WB_rd /= "00000" AND Mem_WB_rd = ID_EX_rs2) then
        ForwardB <= "01";    -- Forward from MEM/WB stage (lower priority)
    end if;
end process;
```

**Forwarding Conditions:**
1. **Write Enable Check**: Source stage must be writing to a register
2. **Non-Zero Register**: Cannot forward to/from register x0 (hardwired zero)
3. **Address Match**: Source register must match destination register
4. **Priority Resolution**: EX/MEM has priority over MEM/WB

### Forward Mux Implementation

#### ForwardMuxA (ALU Input A Selection)
```vhdl
port map(
    ReadData1       => s_EX_ReadData1,         -- Original register file data
    Mem_WB_Data     => s_WriteBack,            -- Final write-back data
    EX_Mem_ALUResult => s_MEM_ALUResult,       -- ALU result from previous instruction
    Sel             => s_ForwardA,             -- 2-bit selection signal
    ALU_InputA      => s_ALUInputA_Forward     -- Forwarded ALU input
);
```

**Selection Logic:**
- **"00"**: Use original register data (`ReadData1`)
- **"01"**: Forward from WB stage (`Mem_WB_Data`)
- **"10"**: Forward from MEM stage (`EX_Mem_ALUResult`)

---

## Barrel Shifter Internal Architecture

### Shift Network Implementation

The barrel shifter implements a 5-stage shifting network where each stage can shift by powers of 2:

**Stage 0**: Shift by 0 or 1 positions
**Stage 1**: Shift by 0 or 2 positions  
**Stage 2**: Shift by 0 or 4 positions
**Stage 3**: Shift by 0 or 8 positions
**Stage 4**: Shift by 0 or 16 positions

### Bidirectional Shift Support

```vhdl
-- For left shifts, reverse input bits, perform right shift, reverse output
s_before <= reverse_bits(i_Data) when s_is_left = '1' else i_Data;
s_after <= reverse_bits(s_stage(5)) when s_is_left = '1' else s_stage(5);
```

**Connection Analysis:**
- **Left Shift Implementation**: Bit reversal transforms left shifts into right shifts
- **Arithmetic Support**: Sign bit propagation for arithmetic right shifts
- **Fill Bit Logic**: Zero fill for logical shifts, sign fill for arithmetic shifts

---

## Memory Access Width Handling

### Store Data Packing

The store packer handles sub-word writes by implementing read-modify-write operations:

#### Byte Store (Width = "00")
```vhdl
when "00" =>  -- Store Byte
    v_byte := s_MEM_StoreData(7 downto 0);    -- Extract byte to store
    case s_MEM_ByteOffset is
        when "00" => v_word(7 downto 0)   := v_byte;   -- Lane 0
        when "01" => v_word(15 downto 8)  := v_byte;   -- Lane 1
        when "10" => v_word(23 downto 16) := v_byte;   -- Lane 2
        when others => v_word(31 downto 24) := v_byte; -- Lane 3
    end case;
```

#### Half-Word Store (Width = "01")
```vhdl
when "01" =>  -- Store Half-word
    v_half := s_MEM_StoreData(15 downto 0);   -- Extract half-word to store
    if s_MEM_ByteOffset(1) = '0' then
        v_word(15 downto 0) := v_half;        -- Lower half-word
    else
        v_word(31 downto 16) := v_half;       -- Upper half-word
    end if;
```

### Load Data Unpacking

The load unpacker extracts and extends sub-word loads:

#### Signed vs Unsigned Extension
```vhdl
-- Byte load example
if s_MEM_LoadSigned = '1' then
    v_result := std_logic_vector(resize(signed(v_byte), 32));    -- Sign extend
else
    v_result := std_logic_vector(resize(unsigned(v_byte), 32)); -- Zero extend
end if;
```

**Extension Behavior:**
- **Signed Byte**: 0x80 → 0xFFFFFF80
- **Unsigned Byte**: 0x80 → 0x00000080
- **Signed Half**: 0x8000 → 0xFFFF8000  
- **Unsigned Half**: 0x8000 → 0x00008000

---

## Critical Timing Paths

### 1. Register File to ALU Path
**Path**: Register File → Forwarding Mux → ALU → EX/MEM Register
**Critical Elements**:
- Register file access time
- Forwarding mux delay
- ALU computation time
- Setup time for EX/MEM register

### 2. Memory Access Path  
**Path**: ALU → Address → Memory → Load Unpacker → MEM/WB Register
**Critical Elements**:
- ALU to memory address setup
- Memory access time
- Load unpacking logic delay
- Setup time for MEM/WB register

### 3. Branch Resolution Path
**Path**: Register File → Comparator → Branch Decision → PC Mux
**Critical Elements**:
- Register file access time
- Comparison logic delay
- Branch target calculation
- PC setup time

### 4. Hazard Detection Path
**Path**: EX/MEM Register → Hazard Unit → Pipeline Control
**Critical Elements**:
- Register output delay
- Hazard detection logic
- Control signal distribution

---

## Exception and Special Case Handling

### Register x0 (Zero Register) Implementation

**Register File Level**:
```vhdl
if idx = 0 then
    return ZERO_WORD;  -- Always return zero for register 0
else
    return regs(idx);  -- Return actual register value
end if;
```

**Write Protection**:
```vhdl
if idx /= 0 then
    s_regs(idx) <= i_WriteData;  -- Only write to non-zero registers
end if;
```

### Instruction Alignment Enforcement

**JALR Target Alignment**:
```vhdl
s_ID_JALRTarget(N-1 downto 1) & '0'  -- Force LSB to 0 for alignment
```

### Memory Address Alignment

**Instruction Memory**: Word-aligned access only
```vhdl
addr => s_IMemAddr(11 downto 2)  -- Drop lower 2 bits
```

**Data Memory**: Byte-addressable with alignment handling
```vhdl
s_MEM_ByteOffset <= s_MEM_ALUResult(1 downto 0);  -- Extract alignment offset
```

---

## Power and Area Optimizations

### Clock Gating Opportunities
- Pipeline registers could implement clock gating during stalls
- Unused functional units could be clock-gated based on instruction type

### Resource Sharing
- Single AddSub unit serves both ALU and address calculation
- Unified immediate extension logic serves multiple instruction types
- Shared comparison logic for branches and set-less-than operations

### Critical Path Optimization
- Forwarding logic runs in parallel with register file access
- Branch target calculation overlapped with comparison
- Memory address generation overlapped with store data preparation

This comprehensive analysis demonstrates the interconnected nature of all processor components and the careful consideration of timing, functionality, and optimization in the design.

---

## Complete Instruction Encoding and Control Signal Mapping

### RISC-V Instruction Format Decoding

#### R-Type Instructions (Register-Register Operations)
```
Opcode: 0110011
Instruction Format: [funct7][rs2][rs1][funct3][rd][opcode]
Example: ADD x1, x2, x3 → 0x003100B3
```

**Control Unit Response:**
```vhdl
when "0110011" =>  -- R-type
    o_RegWrite <= '1';           -- Enable register write
    o_ALUSrc <= '0';             -- Use register for ALU input B
    o_MemRead <= '0';            -- No memory read
    o_MemWrite <= '0';           -- No memory write
    o_MemToReg <= '0';           -- Use ALU result for write-back
```

**ALU Control Generation:**
```vhdl
case i_funct3 is
    when "000" =>
        if i_funct7 = "0000000" then
            o_ALUControl <= ALU_ADD;    -- ADD instruction
        elsif i_funct7 = "0100000" then
            o_ALUControl <= ALU_SUB;    -- SUB instruction
        end if;
    when "111" => o_ALUControl <= ALU_AND;  -- AND instruction
    when "110" => o_ALUControl <= ALU_OR;   -- OR instruction
    when "100" => o_ALUControl <= ALU_XOR;  -- XOR instruction
    -- ... other operations
end case;
```

#### I-Type Instructions (Immediate Operations)
```
Opcode: 0010011 (ALU immediate), 0000011 (loads), 1100111 (JALR)
Instruction Format: [imm[11:0]][rs1][funct3][rd][opcode]
Example: ADDI x1, x2, 100 → 0x06410093
```

**Immediate Extraction (ImmType = "000"):**
```vhdl
o_Out(11 downto 0) <= i_Inst(31 downto 20);    -- Extract immediate
o_Out(31 downto 12) <= (others => i_Inst(31)); -- Sign extend
```

**Load Instruction Control Signals:**
```vhdl
when "0000011" =>  -- Load instructions
    o_ALUSrc <= '1';             -- Use immediate for address calculation
    o_RegWrite <= '1';           -- Write loaded data to register
    o_MemRead <= '1';            -- Enable memory read
    o_MemToReg <= '1';           -- Select memory data for write-back
    o_ALUControl <= ALU_ADD;     -- Add base + offset
```

**Load Width Control:**
```vhdl
case i_funct3 is
    when "000" => -- LB (Load Byte)
        o_LoadWidth <= "00";
        o_LoadSigned <= '1';
    when "001" => -- LH (Load Halfword)
        o_LoadWidth <= "01";
        o_LoadSigned <= '1';
    when "010" => -- LW (Load Word)
        o_LoadWidth <= "10";
        o_LoadSigned <= '1';
    when "100" => -- LBU (Load Byte Unsigned)
        o_LoadWidth <= "00";
        o_LoadSigned <= '0';
    when "101" => -- LHU (Load Halfword Unsigned)
        o_LoadWidth <= "01";
        o_LoadSigned <= '0';
end case;
```

#### S-Type Instructions (Store Operations)
```
Opcode: 0100011
Instruction Format: [imm[11:5]][rs2][rs1][funct3][imm[4:0]][opcode]
Example: SW x1, 8(x2) → 0x00112423
```

**Immediate Extraction (ImmType = "001"):**
```vhdl
o_Out(11 downto 5) <= i_Inst(31 downto 25);    -- Upper immediate bits
o_Out(4 downto 0) <= i_Inst(11 downto 7);      -- Lower immediate bits
o_Out(31 downto 12) <= (others => i_Inst(31)); -- Sign extend
```

#### B-Type Instructions (Branch Operations)
```
Opcode: 1100011
Instruction Format: [imm[12|10:5]][rs2][rs1][funct3][imm[4:1|11]][opcode]
Example: BEQ x1, x2, label → Branch offset encoded in immediate
```

**Immediate Extraction (ImmType = "010"):**
```vhdl
o_Out(31 downto 12) <= (others => i_Inst(31)); -- Sign extend
o_Out(11) <= i_Inst(7);                        -- Immediate bit 11
o_Out(10 downto 5) <= i_Inst(30 downto 25);    -- Immediate bits 10:5
o_Out(4 downto 1) <= i_Inst(11 downto 8);      -- Immediate bits 4:1
o_Out(0) <= '0';                               -- LSB always 0 (half-word aligned)
```

**Branch Type Control:**
```vhdl
o_BranchType <= i_funct3;  -- Pass funct3 directly to branch unit

-- In branch decision logic:
case s_ID_BranchType is
    when "000" => s_ID_BranchTaken <= s_ID_CmpEq;        -- BEQ
    when "001" => s_ID_BranchTaken <= not s_ID_CmpEq;    -- BNE
    when "100" => s_ID_BranchTaken <= s_ID_CmpSignedLT;  -- BLT
    when "101" => s_ID_BranchTaken <= s_ID_CmpSignedGE;  -- BGE
    when "110" => s_ID_BranchTaken <= s_ID_CmpUnsignedLT;-- BLTU
    when "111" => s_ID_BranchTaken <= s_ID_CmpUnsignedGE;-- BGEU
end case;
```

#### U-Type Instructions (Upper Immediate)
```
Opcode: 0110111 (LUI), 0010111 (AUIPC)
Instruction Format: [imm[31:12]][rd][opcode]
Example: LUI x1, 0x12345 → 0x12345037
```

**Immediate Extraction (ImmType = "011"):**
```vhdl
o_Out(31 downto 12) <= i_Inst(31 downto 12);   -- Upper 20 bits
o_Out(11 downto 0) <= "000000000000";          -- Lower 12 bits zero
```

**LUI vs AUIPC Distinction:**
```vhdl
-- LUI (Load Upper Immediate)
when "0110111" =>
    o_ALUSrc <= '1';
    o_RegWrite <= '1';
    o_ALUControl <= ALU_PASSIMM;  -- Pass immediate through ALU

-- AUIPC (Add Upper Immediate to PC)
when "0010111" =>
    o_ALUSrc <= '1';
    o_RegWrite <= '1';
    o_ALUControl <= ALU_ADD;      -- Add immediate to PC
    -- s_ID_AUIPC <= '1' triggers PC selection for ALU input A
```

#### J-Type Instructions (Jump Operations)
```
Opcode: 1101111 (JAL)
Instruction Format: [imm[20|10:1|11|19:12]][rd][opcode]
Example: JAL x1, label → Jump offset encoded in immediate
```

**Immediate Extraction (ImmType = "100"):**
```vhdl
o_Out(31 downto 20) <= (others => i_Inst(31)); -- Sign extend
o_Out(19 downto 12) <= i_Inst(19 downto 12);   -- Immediate bits 19:12
o_Out(11) <= i_Inst(20);                       -- Immediate bit 11
o_Out(10 downto 1) <= i_Inst(30 downto 21);    -- Immediate bits 10:1
o_Out(0) <= '0';                               -- LSB always 0 (half-word aligned)
```

---

## Complete Signal Flow Analysis

### Instruction Fetch to Decode Data Flow

```
Clock Cycle N:
PC → Instruction Memory → s_Inst
PC → Plus4Adder → s_PCPlus4
s_Inst, s_PCPlus4, PC → IF/ID Register

Clock Cycle N+1:
IF/ID.o_inst → Control Unit Inputs
IF/ID.o_inst[31:25] → ControlUnit.i_funct7
IF/ID.o_inst[14:12] → ControlUnit.i_funct3
IF/ID.o_inst[6:0] → ControlUnit.i_opcode

IF/ID.o_inst[19:15] → RegisterFile.i_ReadReg1 (rs1)
IF/ID.o_inst[24:20] → RegisterFile.i_ReadReg2 (rs2)
IF/ID.o_inst → Extender.i_Inst
```

### Control Signal Generation and Propagation

```
Control Unit Outputs (ID Stage) → ID/EX Register Inputs:
o_RegWrite → i_RegWrite → [Pipeline] → EX/MEM → MEM/WB → RegisterFile.i_RegWrite
o_MemRead → i_MemRead → [Pipeline] → EX/MEM → DataMemory.we (inverted)
o_MemWrite → i_MemWrite → [Pipeline] → EX/MEM → DataMemory.we
o_ALUControl → i_ALUControl → [Pipeline] → ALU.i_ALUControl
o_ALUSrc → i_ALUSrc → [Pipeline] → ALU Input Selection Logic
```

### Data Forwarding Signal Flow

```
EX Stage Register Addresses → Forwarding Unit:
ID/EX.o_rs1 → ForwardingUnit.ID_EX_rs1
ID/EX.o_rs2 → ForwardingUnit.ID_EX_rs2

Later Stage Register Addresses → Forwarding Unit:
EX/MEM.o_rd → ForwardingUnit.EX_Mem_rd
MEM/WB.o_rd → ForwardingUnit.Mem_WB_rd

Forwarding Control Signals:
ForwardingUnit.ForwardA → ForwardMuxA.Sel
ForwardingUnit.ForwardB → ForwardMuxB.Sel

Forwarded Data Paths:
EX/MEM.o_ALUResult → ForwardMuxA.EX_Mem_ALUResult
EX/MEM.o_ALUResult → ForwardMuxB.EX_Mem_ALUResult
MEM/WB.WriteBack → ForwardMuxA.Mem_WB_Data
MEM/WB.WriteBack → ForwardMuxB.Mem_WB_Data
```

### Memory Interface Complete Signal Flow

```
Address Generation:
ALU.o_ALUOut → EX/MEM.i_ALUResult → EX/MEM.o_ALUResult → s_DMemAddr

Store Data Path:
ForwardMuxB.ALU_InputB → EX/MEM.i_StoreData → EX/MEM.o_StoreData → Store Packer

Store Packer Logic:
s_MEM_StoreData + s_MEM_StoreWidth + s_MEM_ByteOffset → s_DMemData

Load Data Path:
Memory.q → s_DMemOut → Load Unpacker → s_MEM_LoadData → MEM/WB.i_DMem

Load Unpacker Logic:
s_DMemOut + s_MEM_LoadWidth + s_MEM_LoadSigned + s_MEM_ByteOffset → s_MEM_LoadData
```

---

## Hazard Detection and Resolution Signal Flow

### Load-Use Hazard Detection
```
Current Instruction (ID Stage):
s_ID_Inst[19:15] → HazardDetectionUnit.IF_ID_rs1
s_ID_Inst[24:20] → HazardDetectionUnit.IF_ID_rs2

Previous Instruction (EX Stage):
ID/EX.o_MemRead → HazardDetectionUnit.ID_EX_MemRead
ID/EX.o_rd → HazardDetectionUnit.ID_EX_rd

Hazard Detection Output:
HazardDetectionUnit.PCWrite → PC.i_WE
HazardDetectionUnit.IF_ID_Write → IF/ID.i_Stall (inverted)
HazardDetectionUnit.FlushMux_Sel → Control Signal Flush Logic
```

### Control Signal Flush Logic
```
Original Control Signals → Hazard Flush Muxes:
s_ID_RegWrite → [FlushMux] → s_ID_RegWrite_Hazard → ID/EX.i_RegWrite
s_ID_MemRead → [FlushMux] → s_ID_MemRead_Hazard → ID/EX.i_MemRead
s_ID_MemWrite → [FlushMux] → s_ID_MemWrite_Hazard → ID/EX.i_MemWrite
s_ID_MemToReg → [FlushMux] → s_ID_MemToReg_Hazard → ID/EX.i_MemToReg
s_ID_AndLink → [FlushMux] → s_ID_AndLink_Hazard → ID/EX.i_AndLink

Flush Mux Selection:
s_FlushMux_Sel = '1' → Force control signals to '0' (NOP)
s_FlushMux_Sel = '0' → Pass original control signals
```

---

## Branch and Jump Resolution Signal Flow

### Branch Target Calculation
```
PC-Relative Branch Target:
s_ID_PC → BranchingAdder.i_A
s_ID_Imm → BranchingAdder.i_B
BranchingAdder.o_Result → s_ID_BranchTarget

Register-Indirect Jump Target (JALR):
s_ID_ReadData1 → [Addition] ← s_ID_Imm
Result → s_ID_JALRTarget
```

### Jump Target Selection
```
Jump Type Selection:
s_ID_ALUSrc = '0' → s_ID_BranchTarget (JAL - PC relative)
s_ID_ALUSrc = '1' → s_ID_JALRTarget (JALR - register + immediate)
Selection → s_ID_JumpTarget
```

### PC Update Logic
```
PC Input Priority:
1. s_ID_Jump = '1' → s_ID_JumpTarget
2. s_ID_Branch = '1' AND s_ID_BranchTaken = '1' → s_ID_BranchTarget
3. Default → s_PCPlus4 (sequential)

Final PC Input → PC.i_D
```

---

## Write-Back Stage Final Data Selection

### Three-Source Write-Back Mux
```
Primary Data Selection:
s_WB_MemToReg = '1' → s_WB_DMem (Load data)
s_WB_MemToReg = '0' → s_WB_ALUResult (Computation result)
Selection → s_WriteBack

Final Write Data Selection:
s_WB_AndLink = '1' → s_WB_PC4 (Jump-and-link address)
s_WB_AndLink = '0' → s_WriteBack (Primary mux output)
Selection → s_RegWrData → RegisterFile.i_WriteData
```

### Register File Write Control
```
Write Enable: s_WB_RegWrite → RegisterFile.i_RegWrite
Write Address: s_WB_rd → RegisterFile.i_WriteReg
Write Data: s_RegWrData → RegisterFile.i_WriteData
```

This completes the comprehensive technical deep dive, covering every signal connection, control path, and data flow in the RISC-V processor implementation. The document now provides the complete technical detail needed for a thorough understanding and demonstration of the processor architecture.