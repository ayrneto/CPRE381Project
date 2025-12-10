# Data Hazard Avoidance Analysis

## (i) Instructions that PRODUCE Values

| Instruction Type | Instructions | Pipeline Signals (Producer) | Pipeline Stage |
|-----------------|--------------|------------------------------|----------------|
| **R-Type ALU** | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU | s_ALUResult (EX), s_MEM_ALUResult (MEM), s_WriteBack (WB) | EX→MEM→WB |
| **I-Type ALU** | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU | s_ALUResult (EX), s_MEM_ALUResult (MEM), s_WriteBack (WB) | EX→MEM→WB |
| **Load Instructions** | LW, LH, LB, LHU, LBU | s_MEM_LoadData (MEM), s_WB_DMem (WB) | MEM→WB |
| **Upper Immediate** | LUI, AUIPC | s_ALUResult (EX), s_MEM_ALUResult (MEM), s_WriteBack (WB) | EX→MEM→WB |
| **Jump & Link** | JAL, JALR | s_EX_PC4 (EX), s_MEM_PC4 (MEM), s_WB_PC4 (WB) | EX→MEM→WB |

**Key Producer Signals:**
- `s_ALUResult` (EX stage) - ALU computation result
- `s_MEM_ALUResult` (MEM stage) - Forwarded ALU result
- `s_MEM_LoadData` (MEM stage) - Memory load result
- `s_WriteBack` (WB stage) - Final writeback value
- `s_EX_PC4`, `s_MEM_PC4`, `s_WB_PC4` - PC+4 for link instructions

## (ii) Instructions that CONSUME Values

| Instruction Type | Instructions | Pipeline Signals (Consumer) | Pipeline Stage |
|-----------------|--------------|------------------------------|----------------|
| **R-Type ALU** | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU | s_EX_ReadData1, s_EX_ReadData2 (ALU inputs) | EX |
| **I-Type ALU** | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU | s_EX_ReadData1 (ALU input A) | EX |
| **Load Instructions** | LW, LH, LB, LHU, LBU | s_EX_ReadData1 (base address calc) | EX |
| **Store Instructions** | SW, SH, SB | s_EX_ReadData1 (base addr), s_EX_ReadData2 (store data) | EX, MEM |
| **Branch Instructions** | BEQ, BNE, BLT, BGE, BLTU, BGEU | s_ID_ReadData1, s_ID_ReadData2 (comparison) | ID |
| **Jump Register** | JALR | s_ID_ReadData1 (target calculation) | ID |

**Key Consumer Signals:**
- `s_EX_ReadData1` - ALU input A (rs1 register)
- `s_EX_ReadData2` - ALU input B (rs2 register)  
- `s_ID_ReadData1`, `s_ID_ReadData2` - Branch comparison inputs
- `s_MEM_StoreData` - Store instruction data

## (iii) Generalized Data Dependencies & Forwarding Analysis

| Dependency Type | Producer Stage | Consumer Stage | Forwarding Path | Stall Required? |
|----------------|----------------|----------------|-----------------|-----------------|
| **EX→EX** | EX ALU Result | Next EX ALU Input | EX/MEM → EX mux | NO (forwarding) |
| **MEM→EX** | MEM ALU Result | EX ALU Input | MEM/WB → EX mux | NO (forwarding) |
| **WB→EX** | WB Write Data | EX ALU Input | WB → EX mux | NO (forwarding) |
| **MEM→MEM** | MEM Load Data | MEM Store Data | MEM → MEM direct | NO (forwarding) |
| **LOAD→EX** | MEM Load Data | Next EX ALU Input | Cannot forward | YES (1 cycle stall) |
| **EX→ID** | EX ALU Result | ID Branch Compare | Cannot forward | YES (2 cycle stall) |
| **MEM→ID** | MEM Load Data | ID Branch Compare | Cannot forward | YES (1 cycle stall) |

### Forwarding Paths Implementation:

**1. ALU Input Forwarding (EX Stage)**
```
ForwardA/B Control:
- "00": No forwarding (use register file)
- "01": Forward from MEM/WB stage 
- "10": Forward from EX/MEM stage
```

**2. Store Data Forwarding (MEM Stage)**
```
Store data can be forwarded from:
- EX/MEM ALU result
- MEM/WB write data
```

### Dependencies Requiring Stalls:

**1. Load-Use Hazard**
```
Cycle 1: LW x1, 0(x2)     # Load to x1
Cycle 2: ADD x3, x1, x4   # Use x1 immediately
→ STALL required: Load data not available until MEM stage
```

**2. Branch Hazards**
```
Cycle 1: ADD x1, x2, x3   # Produces x1
Cycle 2: BEQ x1, x4, label # Uses x1 for comparison
→ STALL required: Branch resolves in ID, value not ready
```

## (iv) Updated Pipeline Stage Requirements

| Pipeline Stage | Required Datapath Values | Additional Forwarding Controls |
|----------------|---------------------------|-------------------------------|
| **IF** | PC, PC+4, Instruction | - |
| **ID** | rs1, rs2, rd addresses, Immediate, Control signals | Branch forwarding controls |
| **EX** | rs1, rs2, rd addresses, ALU inputs, Control signals | ForwardA, ForwardB controls |
| **MEM** | rd address, ALU result, Store data, Control signals | Store forwarding controls |
| **WB** | rd address, Write data, RegWrite control | - |

**New Datapath Values Added for Forwarding:**
- `s_EX_rs1`, `s_EX_rs2` - Source register addresses in EX stage
- `s_MEM_rd` - Destination register address in MEM stage
- `s_WB_rd` - Destination register address in WB stage
- `s_ForwardA`, `s_ForwardB` - Forwarding control signals
- `s_PCWrite`, `s_IF_ID_Write` - Stall control signals
- `s_FlushMux_Sel` - Control signal flush for hazards

## (v) Forwarding and Hazard Detection Logic Equations

### Forwarding Unit Logic:
```vhdl
-- Forward A (ALU Input A)
if (EX_MEM_RegWrite = '1' AND EX_MEM_rd ≠ "00000" AND EX_MEM_rd = ID_EX_rs1) then
    ForwardA <= "10"  -- Forward from EX/MEM
elsif (MEM_WB_RegWrite = '1' AND MEM_WB_rd ≠ "00000" AND MEM_WB_rd = ID_EX_rs1) then
    ForwardA <= "01"  -- Forward from MEM/WB
else
    ForwardA <= "00"  -- No forwarding
end if

-- Forward B (ALU Input B) - Same logic for rs2
if (EX_MEM_RegWrite = '1' AND EX_MEM_rd ≠ "00000" AND EX_MEM_rd = ID_EX_rs2) then
    ForwardB <= "10"
elsif (MEM_WB_RegWrite = '1' AND MEM_WB_rd ≠ "00000" AND MEM_WB_rd = ID_EX_rs2) then
    ForwardB <= "01"
else
    ForwardB <= "00"
end if
```

### Hazard Detection Logic:
```vhdl
-- Load-Use Hazard Detection
if (ID_EX_MemRead = '1' AND 
    ((ID_EX_rd = IF_ID_rs1) OR (ID_EX_rd = IF_ID_rs2)) AND 
    ID_EX_rd ≠ "00000") then
    
    PCWrite <= '0'        -- Stall PC
    IF_ID_Write <= '0'    -- Stall IF/ID register
    FlushMux_Sel <= '1'   -- Flush ID/EX control signals
else
    PCWrite <= '1'        -- Normal operation
    IF_ID_Write <= '1'
    FlushMux_Sel <= '0'
end if
```

### Control Signal Flushing:
```vhdl
-- Flush critical control signals during hazards
RegWrite_Hazard <= '0' when FlushMux_Sel = '1' else RegWrite
MemRead_Hazard  <= '0' when FlushMux_Sel = '1' else MemRead
MemWrite_Hazard <= '0' when FlushMux_Sel = '1' else MemWrite
```

This creates a comprehensive forwarding and hazard detection system that:
- Resolves most data hazards through forwarding
- Stalls only when necessary (load-use hazards)
- Maintains correctness while maximizing performance