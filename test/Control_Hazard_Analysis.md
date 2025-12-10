# Control Hazard Avoidance Analysis

## (i) Instructions with Non-Sequential PC Updates

| Instruction Type | Instructions | PC Update Stage | Target Calculation | Branch Resolution |
|-----------------|-------------|-----------------|-------------------|-------------------|
| **Unconditional Jumps** | JAL | ID | PC + immediate | Always taken (ID) |
| **Register Jumps** | JALR | ID | (rs1 + immediate) & ~1 | Always taken (ID) |
| **Conditional Branches** | BEQ, BNE | ID | PC + immediate | Conditional (ID) |
| **Conditional Branches** | BLT, BGE | ID | PC + immediate | Conditional (ID) |  
| **Conditional Branches** | BLTU, BGEU | ID | PC + immediate | Conditional (ID) |

### Detailed Control Hazard Analysis:

**JAL (Jump and Link)**
- **Target Calculation**: ID stage (`PC + sign_extend(immediate[20:1])`)
- **Branch Resolution**: ID stage (always taken)
- **Hazard**: 1 instruction in IF stage will be fetched incorrectly
- **Action**: Flush IF/ID register

**JALR (Jump and Link Register)**
- **Target Calculation**: ID stage (`(rs1 + sign_extend(immediate)) & ~1`)
- **Branch Resolution**: ID stage (always taken)
- **Hazard**: 1 instruction in IF stage will be fetched incorrectly
- **Action**: Flush IF/ID register
- **Note**: May have data dependency on rs1 register

**Conditional Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)**
- **Target Calculation**: ID stage (`PC + sign_extend(immediate[12:1])`)
- **Branch Resolution**: ID stage (conditional on comparison)
- **Hazard**: 1 instruction in IF stage may be fetched incorrectly
- **Action**: Flush IF/ID register if branch taken

## (ii) Stall and Flush Requirements

| Instruction | Stage | IF Stage | ID Stage | EX Stage | MEM Stage | WB Stage |
|-------------|-------|----------|----------|----------|-----------|----------|
| **JAL** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **JALR** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BEQ (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BEQ (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |
| **BNE (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BNE (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |
| **BLT (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BLT (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |
| **BGE (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BGE (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |
| **BLTU (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BLTU (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |
| **BGEU (taken)** | ID | **FLUSH** | Continue | Continue | Continue | Continue |
| **BGEU (not taken)** | ID | Continue | Continue | Continue | Continue | Continue |

### Control Hazard Resolution Strategy:

**1. No Branch Prediction (Simple Approach)**
- Assume all branches are NOT taken
- Continue fetching sequentially 
- Flush pipeline if branch actually taken
- **Penalty**: 1 cycle for taken branches/jumps

**2. Branch Resolution in ID Stage**
- Branch target calculation: ID stage
- Branch condition evaluation: ID stage  
- Branch decision: ID stage
- **Advantage**: Minimize flush penalty to 1 cycle

**3. Flush Implementation**
```vhdl
-- Control hazard detection
IF_Flush <= '1' when (Jump = '1') OR 
                     (Branch = '1' AND BranchTaken = '1') 
            else '0'

-- Branch decision logic (ID stage)
BranchTaken <= '1' when (BranchType = "000" AND CmpEq = '1') OR     -- BEQ
                        (BranchType = "001" AND CmpEq = '0') OR     -- BNE  
                        (BranchType = "100" AND CmpSignedLT = '1') OR   -- BLT
                        (BranchType = "101" AND CmpSignedGE = '1') OR   -- BGE
                        (BranchType = "110" AND CmpUnsignedLT = '1') OR -- BLTU
                        (BranchType = "111" AND CmpUnsignedGE = '1')    -- BGEU
               else '0'
```

## Control Hazard Impact on Pipeline Stages

### When Control Hazard Occurs (Branch/Jump in ID):

**Cycle N:** Branch/Jump instruction in ID stage
- **IF Stage**: Fetching wrong instruction (sequential)
- **Action**: Flush IF/ID register contents
- **Result**: Insert bubble (NOP) in ID stage next cycle

**Cycle N+1:** Branch/Jump continues to EX stage
- **IF Stage**: Fetching correct instruction (branch target)
- **ID Stage**: Bubble (flushed instruction becomes NOP)
- **EX Stage**: Branch/Jump instruction continues normally

### Control Hazard with Data Dependencies:

**Case 1: Branch depends on previous instruction**
```assembly
ADD x1, x2, x3    # Cycle 1: ID stage
BEQ x1, x4, label # Cycle 2: ID stage - needs x1 value
```
**Problem**: x1 not available in ID stage (still in EX stage)
**Solution**: Stall branch until x1 is available, OR forward to branch comparator

### Control Hazard Timing Diagram:

```
Instruction | Cycle 1 | Cycle 2 | Cycle 3 | Cycle 4 | Cycle 5
------------|---------|---------|---------|---------|--------
ADD x1,x2,x3|   IF    |   ID    |   EX    |  MEM    |   WB
BEQ x1,x4,L |         |   IF    | ID(eval)|   EX    |  MEM
target inst |         |         |   IF    | ID(new) |   EX
            |         |         | (flush) |         |
```

## Implementation in Hardware-Scheduled Pipeline:

**1. Branch Target Calculation (ID Stage)**
```vhdl
-- Branch target adder
BranchTarget <= PC + sign_extend(immediate)

-- JALR target calculation  
JALRTarget <= (ReadData1 + sign_extend(immediate)) AND x"FFFFFFFE"
```

**2. Branch Condition Evaluation (ID Stage)**
```vhdl
-- Comparison units
CmpEq <= '1' when ReadData1 = ReadData2 else '0'
CmpSignedLT <= '1' when signed(ReadData1) < signed(ReadData2) else '0'  
CmpUnsignedLT <= '1' when unsigned(ReadData1) < unsigned(ReadData2) else '0'
```

**3. PC Mux Control**
```vhdl
NextPC <= JumpTarget when Jump = '1' else
          BranchTarget when (Branch = '1' AND BranchTaken = '1') else  
          PC + 4
```

**4. Pipeline Flush Control**
```vhdl
IF_Flush <= '1' when (Jump = '1') OR (Branch = '1' AND BranchTaken = '1') else '0'
```

This control hazard resolution approach:
- Resolves all control hazards in ID stage
- Flushes only 1 instruction on taken branches/jumps  
- Uses simple "predict not taken" strategy
- Minimizes hardware complexity while maintaining correctness