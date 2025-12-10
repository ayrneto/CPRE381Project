# Test Program 2: Load-Use Hazard Testing
# Tests load-use hazards and automatic stall insertion

.text
.globl main

main:
    # Setup base pointer and test data
    addi x1, x0, 0         # x1 = 0 (base address)
    addi x2, x0, 42        # x2 = 42 (test value)
    addi x3, x0, 99        # x3 = 99 (test value)
    sw x2, 0(x1)           # Store 42 to memory[0]
    sw x3, 4(x1)           # Store 99 to memory[4]
    
    # Test 1: Basic load-use hazard (rs1)
    lw x4, 0(x1)           # Load 42 from memory[0]
    add x5, x4, x2         # x5 = 42 + 42 = 84 (HAZARD: should stall 1 cycle)
    
    # Test 2: Load-use hazard (rs2)  
    lw x6, 4(x1)           # Load 99 from memory[4]
    sub x7, x3, x6         # x7 = 99 - 99 = 0 (HAZARD: should stall 1 cycle)
    
    # Test 3: Load-use hazard (both operands)
    lw x8, 0(x1)           # Load 42 from memory[0] 
    add x9, x8, x8         # x9 = 42 + 42 = 84 (HAZARD: both operands)
    
    # Test 4: Load followed by branch (control hazard + load-use)
    lw x10, 0(x1)          # Load 42 from memory[0]
    beq x10, x2, branch_target  # Compare loaded value (HAZARD)
    addi x11, x0, -1       # Should not execute if branch taken
    j skip_branch
branch_target:
    addi x11, x0, 1        # x11 = 1 (should execute)
skip_branch:
    
    # Test 5: Load for store address
    addi x12, x0, 8        # x12 = 8 (offset)
    sw x12, 8(x1)          # Store 8 to memory[8]
    lw x13, 8(x1)          # Load address offset
    sw x2, 0(x13)          # Store using loaded address (HAZARD)
    
    # Test 6: Load for store data
    lw x14, 0(x1)          # Load 42 from memory[0]
    sw x14, 12(x1)         # Store loaded value (HAZARD)
    
    # Test 7: No hazard case (load with independent instruction)
    lw x15, 4(x1)          # Load 99 from memory[4]
    addi x16, x0, 777      # Independent instruction (NO HAZARD)
    add x17, x15, x16      # Now use loaded value (resolved by forwarding)
    
    # Test 8: Load to x0 (should not cause hazard)
    lw x0, 0(x1)           # Load to x0 (always zero)
    add x18, x0, x2        # Use x0 (NO HAZARD - x0 always 0)
    
    # Test 9: Multiple consecutive loads
    lw x19, 0(x1)          # Load 42
    lw x20, 4(x1)          # Load 99
    add x21, x19, x20      # x21 = 42 + 99 = 141 (should stall appropriately)
    
    # Expected Results:
    # x4 = 42, x5 = 84, x6 = 99, x7 = 0, x8 = 42, x9 = 84
    # x10 = 42, x11 = 1, x12 = 8, x13 = 8, x14 = 42
    # x15 = 99, x16 = 777, x17 = 876, x18 = 42, x19 = 42, x20 = 99, x21 = 141
    # memory[0] = 42, memory[4] = 99, memory[8] = 8, memory[12] = 42
    
    # Performance Note: This test should demonstrate automatic stall insertion
    # by hardware hazard detection unit, eliminating need for manual NOPs
    
    wfi