# RISC-V Assembly Test Suite - Project 1
# Author: CPRE 381 Student
# Description: Simulation guide and expected results for the three test programs

## Test File Descriptions:

### 1. Proj1_base_test.s
**Purpose**: Tests all required arithmetic and logical instructions
**Instructions Covered**:
- R-Type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU  
- I-Type: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
- Memory: LW, SW, LB, LBU, LH, LHU, SB, SH
- Upper Immediate: LUI, AUIPC
- Control Flow: BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR

**Key Verification Points**:
- x6 = 150 (ADD result)
- x7 = 50 (SUB result)  
- x13-x18 = 1 (all branch tests passed)
- x20 = 1 (jump test passed)
- x31 = 0xDEAD (completion marker)

### 2. Proj1_cf_test.s  
**Purpose**: Tests control flow with nested function calls (depth >= 5)
**Call Stack**: main → level1 → level2 → level3 → level4 → level5
**Features**:
- 6 different branch instruction types tested
- Proper stack management with save/restore
- Parameter passing between functions
- Return address handling with JAL/JALR

**Key Verification Points**:
- x20-x25 = 1 (main function branch tests)
- x27-x29, x18, x31 = 2,3,4,5,6 (nested function branch tests)  
- x30 = 0x555 (max call depth reached)
- x26 = 0xABC (completion marker)

### 3. Proj1_mergesort.s
**Purpose**: Implements mergesort algorithm on 8-element array
**Input Array**: [64, 34, 25, 12, 22, 11, 90, 5]
**Expected Output**: [5, 11, 12, 22, 25, 34, 64, 90]
**Features**:
- Recursive divide-and-conquer algorithm
- Auxiliary array for merging
- Complex memory operations
- Multiple levels of function calls

**Key Verification Points**:
- x20 = 5 (arr[0])
- x21 = 11 (arr[1])  
- x22 = 12 (arr[2])
- x23 = 22 (arr[3])
- x24 = 25 (arr[4])
- x25 = 34 (arr[5])
- x26 = 64 (arr[6])
- x27 = 90 (arr[7])
- x31 = 0xDEAD (completion marker)

## Simulation Instructions:

### ModelSim/QuestaSim Workflow:
1. Compile all VHDL files:
   ```
   vcom -work work *.vhd
   ```

2. For each test, create appropriate memory initialization:
   - Convert .s file to machine code
   - Load into instruction memory
   
3. Run simulation:
   ```
   vsim -t ps work.tb_RISCV_Processor
   add wave -radix hex /tb_RISCV_Processor/*
   run -all
   ```

4. Verify results by checking register values at completion markers

### Expected Waveform Analysis:
- **Clock cycles**: Each instruction should complete in 1 cycle (single-cycle design)
- **PC progression**: Should increment by 4 each cycle except for branches/jumps
- **Register updates**: Verify destination registers receive correct values
- **Memory operations**: Check data memory reads/writes occur correctly
- **Control signals**: Verify control unit generates proper signals for each instruction type

## Comments for Writeup:
When documenting results, focus on:
1. Correct instruction decode (opcode → control signals)
2. ALU operation selection and execution
3. Memory address calculation and data transfer  
4. Branch condition evaluation and PC updates
5. Register file read/write operations
6. Overall datapath timing and control flow