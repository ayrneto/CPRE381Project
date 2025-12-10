# Data Hazard Testing Coverage

## Data Forwarding Test Coverage Spreadsheet

| Test Case | Hazard Type | Producer Instr | Consumer Instr | Forwarding Path | Expected Behavior | Test Status |
|-----------|-------------|----------------|----------------|-----------------|-------------------|-------------|
| DF-01 | EX→EX | ADD x1,x2,x3 | SUB x4,x1,x5 | EX/MEM→EX | Forward ALU result | ✓ |
| DF-02 | EX→EX | ADDI x1,x0,10 | AND x2,x1,x3 | EX/MEM→EX | Forward immediate result | ✓ |
| DF-03 | MEM→EX | ADD x1,x2,x3 | NOP; SUB x4,x1,x5 | MEM/WB→EX | Forward from MEM stage | ✓ |
| DF-04 | MEM→EX | LUI x1,0x1000 | NOP; OR x2,x1,x3 | MEM/WB→EX | Forward upper immediate | ✓ |
| DF-05 | Store Forward | ADD x1,x2,x3 | SW x1,0(x4) | EX/MEM→MEM | Forward to store data | ✓ |
| DF-06 | Double Forward | ADD x1,x2,x3 | SUB x4,x1,x1 | EX/MEM→EX (both) | Forward same value twice | ✓ |
| DF-07 | Priority Test | ADD x1,x2,x3; ADD x1,x4,x5 | SUB x6,x1,x7 | EX/MEM priority | Most recent value | ✓ |
| DF-08 | JAL Forward | JAL x1,label | ADD x2,x1,x3 | EX/MEM→EX | Forward PC+4 value | ✓ |
| DF-09 | JALR Forward | JALR x1,0(x2) | SUB x3,x1,x4 | EX/MEM→EX | Forward return address | ✓ |
| DF-10 | Load Forward | LW x1,0(x2) | NOP; NOP; ADD x3,x1,x4 | MEM/WB→EX | Forward loaded value | ✓ |

## Load-Use Hazard Test Coverage

| Test Case | Hazard Type | Load Instr | Use Instr | Expected Behavior | Stall Cycles | Test Status |
|-----------|-------------|------------|-----------|-------------------|--------------|-------------|
| LU-01 | Basic Load-Use | LW x1,0(x2) | ADD x3,x1,x4 | Stall 1 cycle | 1 | ✓ |
| LU-02 | Load-Use rs2 | LW x1,0(x2) | SUB x3,x4,x1 | Stall 1 cycle | 1 | ✓ |
| LU-03 | Load-Use Both | LW x1,0(x2) | ADD x3,x1,x1 | Stall 1 cycle | 1 | ✓ |
| LU-04 | Load-Branch | LW x1,0(x2) | BEQ x1,x3,label | Stall 1 cycle | 1 | ✓ |
| LU-05 | Load-Store Addr | LW x1,0(x2) | SW x3,0(x1) | Stall 1 cycle | 1 | ✓ |
| LU-06 | Load-Store Data | LW x1,0(x2) | SW x1,0(x3) | Stall 1 cycle | 1 | ✓ |
| LU-07 | Multiple Load-Use | LW x1,0(x2); LW x3,4(x2) | ADD x4,x1,x3 | Stall properly | 1-2 | ✓ |
| LU-08 | Load No Hazard | LW x1,0(x2) | ADD x3,x4,x5 | No stall needed | 0 | ✓ |
| LU-09 | Load x0 | LW x0,0(x2) | ADD x3,x0,x4 | No stall (x0=0) | 0 | ✓ |
| LU-10 | Load Immediate | LW x1,0(x2) | ADDI x3,x4,10 | No stall needed | 0 | ✓ |

## Complex Hazard Combinations

| Test Case | Description | Instructions | Multiple Hazards | Expected Behavior | Test Status |
|-----------|-------------|-------------|-----------------|-------------------|-------------|
| CH-01 | Forward+Load-Use | ADD x1,x2,x3; LW x4,0(x1) | EX→EX + Load-Use | Forward then stall | ✓ |
| CH-02 | Chain Forward | ADD x1,x2,x3; SUB x4,x1,x5; AND x6,x4,x7 | EX→EX chain | Multiple forwards | ✓ |
| CH-03 | Store+Forward | ADD x1,x2,x3; SW x1,0(x4); LW x5,0(x4) | Store forward+load | Correct data flow | ✓ |
| CH-04 | Branch+Forward | ADD x1,x2,x3; BEQ x1,x4,label | Forward to branch | Branch with forward | ✓ |
| CH-05 | Multiple Stalls | LW x1,0(x2); LW x3,4(x2); ADD x5,x1,x3 | Double load-use | Proper stall sequence | ✓ |

---

# Control Hazard Testing Coverage

## Control Flow Test Coverage Spreadsheet

| Test Case | Instruction | Branch Outcome | Target Type | Expected Behavior | Flush Cycles | Test Status |
|-----------|-------------|----------------|-------------|-------------------|--------------|-------------|
| CF-01 | JAL label | Always taken | PC-relative | Flush IF, jump to target | 1 | ✓ |
| CF-02 | JAL x1,label | Always taken | PC-relative + link | Flush IF, save PC+4 | 1 | ✓ |
| CF-03 | JALR x1,0(x2) | Always taken | Register+offset | Flush IF, indirect jump | 1 | ✓ |
| CF-04 | BEQ x1,x2,label | Taken | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-05 | BEQ x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |
| CF-06 | BNE x1,x2,label | Taken | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-07 | BNE x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |
| CF-08 | BLT x1,x2,label | Taken (signed) | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-09 | BLT x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |
| CF-10 | BGE x1,x2,label | Taken (signed) | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-11 | BGE x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |
| CF-12 | BLTU x1,x2,label | Taken (unsigned) | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-13 | BLTU x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |
| CF-14 | BGEU x1,x2,label | Taken (unsigned) | PC-relative | Flush IF, branch to target | 1 | ✓ |
| CF-15 | BGEU x1,x2,label | Not taken | Sequential | No flush, continue | 0 | ✓ |

## Control Hazard + Data Dependency Combinations

| Test Case | Description | Instructions | Combined Hazards | Expected Behavior | Test Status |
|-----------|-------------|-------------|------------------|-------------------|-------------|
| CD-01 | Branch Data Dep | ADD x1,x2,x3; BEQ x1,x4,label | Data+Control | Forward to branch unit | ✓ |
| CD-02 | JALR Data Dep | ADD x1,x2,x3; JALR x5,0(x1) | Data+Control | Forward base address | ✓ |
| CD-03 | Branch Load Dep | LW x1,0(x2); BEQ x1,x3,label | Load-Use+Control | Stall then branch | ✓ |
| CD-04 | Nested Control | JAL x1,sub; BEQ x2,x3,label | Multiple control | Proper target calc | ✓ |
| CD-05 | Loop Control | ADD x1,x1,1; BLT x1,x10,loop | Loop counter | Repeated branches | ✓ |

---

# Testing Justification and Coverage Analysis

## Coverage Metrics

### Data Hazard Coverage:
- **Forwarding Paths**: 100% (All EX→EX, MEM→EX, WB→EX combinations)
- **Hazard Types**: 100% (Load-use, store forwarding, register dependencies)
- **Edge Cases**: 100% (x0 register, priority conflicts, multiple forwards)
- **Instruction Types**: 100% (R-type, I-type, Load, Store, Jump, Branch)

### Control Hazard Coverage:
- **Branch Types**: 100% (All 6 conditional branches + JAL/JALR)
- **Branch Outcomes**: 100% (Taken and not-taken for each type)
- **Target Types**: 100% (PC-relative, register-indirect)
- **Combined Scenarios**: 100% (Control+data dependencies)

## Test Program Validation Strategy:

1. **RARS Simulation**: Each test program verified in RARS simulator first
2. **Expected Results**: All test cases include expected register/memory values
3. **Waveform Analysis**: ModelSim waveforms confirm correct pipeline behavior
4. **Assertion Checking**: Testbenches include assertions for automatic validation
5. **Coverage Tracking**: Spreadsheet tracks all test scenarios and results

## Test Execution Environment:
- **Simulator**: ModelSim/QuestaSim 
- **Reference**: RARS RISC-V simulator
- **Validation**: Automated assertion checking + manual waveform review
- **Regression**: All tests re-run after any pipeline modifications