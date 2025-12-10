# Test Program 1: Basic Data Forwarding
# Tests EX->EX and MEM->EX forwarding scenarios

.text
.globl main

main:
    # Test 1: EX->EX forwarding (ADD followed by SUB)
    addi x1, x0, 10        # x1 = 10
    addi x2, x0, 5         # x2 = 5
    add x3, x1, x2         # x3 = x1 + x2 = 15 (produces value in EX)
    sub x4, x3, x2         # x4 = x3 - x2 = 10 (should forward x3 from EX/MEM)
    
    # Test 2: MEM->EX forwarding (with NOP spacing)
    addi x5, x0, 20        # x5 = 20
    nop                    # Create distance
    and x6, x5, x1         # x6 = x5 & x1 (should forward x5 from MEM/WB)
    
    # Test 3: Double forwarding (both operands forwarded)
    add x7, x1, x2         # x7 = x1 + x2 = 15
    add x8, x3, x4         # x8 = x3 + x4 = 25  
    add x9, x7, x8         # x9 = x7 + x8 = 40 (forward both from EX/MEM)
    
    # Test 4: Forwarding priority (EX/MEM over MEM/WB)
    addi x10, x0, 100      # x10 = 100 (will be in MEM/WB)
    addi x10, x0, 200      # x10 = 200 (will be in EX/MEM)
    add x11, x10, x1       # x11 = 200 + 10 = 210 (should use EX/MEM value)
    
    # Test 5: JAL link register forwarding
    jal x12, skip_label    # x12 = PC + 4 (return address)
    nop
skip_label:
    add x13, x12, x1       # x13 = return_addr + 10 (forward PC+4)
    
    # Test 6: Store data forwarding
    addi x14, x0, 1000     # x14 = 1000
    addi x15, x0, 0        # x15 = 0 (base address)
    sw x14, 0(x15)         # Store x14 to memory (should forward x14)
    
    # Expected Results:
    # x1 = 10, x2 = 5, x3 = 15, x4 = 10, x5 = 20
    # x6 = 0 (20 & 10 = 0), x7 = 15, x8 = 25, x9 = 40
    # x10 = 200, x11 = 210, x12 = return_addr, x13 = return_addr + 10
    # x14 = 1000, memory[0] = 1000
    
    # Halt
    wfi