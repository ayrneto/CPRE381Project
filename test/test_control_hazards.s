# Test Program 3: Control Hazard Testing  
# Tests all branch types and jump instructions

.text
.globl main

main:
    # Setup test values
    addi x1, x0, 10        # x1 = 10
    addi x2, x0, 20        # x2 = 20  
    addi x3, x0, 10        # x3 = 10 (equal to x1)
    addi x4, x0, -5        # x4 = -5 (negative)
    
    # Test 1: JAL (Jump and Link)
    addi x5, x0, 0         # x5 = 0 (marker)
    jal x6, jal_target     # Jump and link (x6 = return address)
    addi x5, x0, -1        # Should be skipped
    j after_jal
jal_target:
    addi x5, x0, 1         # x5 = 1 (executed)
    jalr x0, 0(x6)         # Return to x6 address
after_jal:
    
    # Test 2: JALR (Jump and Link Register)
    addi x7, x0, 0         # x7 = 0 (marker)
    la x8, jalr_target     # Load address of target (pseudo-instruction)
    jalr x9, 0(x8)         # Jump to x8 address, save return in x9
    addi x7, x0, -1        # Should be skipped
    j after_jalr
jalr_target:
    addi x7, x0, 2         # x7 = 2 (executed)
    jalr x0, 0(x9)         # Return
after_jalr:
    
    # Test 3: BEQ (Branch if Equal) - Taken
    addi x10, x0, 0        # x10 = 0 (marker)
    beq x1, x3, beq_taken  # x1 == x3 (10), should branch
    addi x10, x0, -1       # Should be skipped
    j after_beq_taken
beq_taken:
    addi x10, x0, 3        # x10 = 3 (executed)
after_beq_taken:
    
    # Test 4: BEQ (Branch if Equal) - Not Taken
    addi x11, x0, 0        # x11 = 0 (marker)  
    beq x1, x2, beq_not_taken  # x1 != x2, should not branch
    addi x11, x0, 4        # x11 = 4 (executed)
    j after_beq_not_taken
beq_not_taken:
    addi x11, x0, -1       # Should not execute
after_beq_not_taken:
    
    # Test 5: BNE (Branch if Not Equal) - Taken
    addi x12, x0, 0        # x12 = 0 (marker)
    bne x1, x2, bne_taken  # x1 != x2, should branch  
    addi x12, x0, -1       # Should be skipped
    j after_bne_taken
bne_taken:
    addi x12, x0, 5        # x12 = 5 (executed)
after_bne_taken:
    
    # Test 6: BNE (Branch if Not Equal) - Not Taken
    addi x13, x0, 0        # x13 = 0 (marker)
    bne x1, x3, bne_not_taken  # x1 == x3, should not branch
    addi x13, x0, 6        # x13 = 6 (executed)
    j after_bne_not_taken
bne_not_taken:
    addi x13, x0, -1       # Should not execute
after_bne_not_taken:
    
    # Test 7: BLT (Branch if Less Than) - Taken  
    addi x14, x0, 0        # x14 = 0 (marker)
    blt x4, x1, blt_taken  # -5 < 10, should branch
    addi x14, x0, -1       # Should be skipped
    j after_blt_taken
blt_taken:
    addi x14, x0, 7        # x14 = 7 (executed)
after_blt_taken:
    
    # Test 8: BLT (Branch if Less Than) - Not Taken
    addi x15, x0, 0        # x15 = 0 (marker)
    blt x2, x1, blt_not_taken  # 20 >= 10, should not branch
    addi x15, x0, 8        # x15 = 8 (executed)
    j after_blt_not_taken
blt_not_taken:
    addi x15, x0, -1       # Should not execute
after_blt_not_taken:
    
    # Test 9: BGE (Branch if Greater or Equal) - Taken
    addi x16, x0, 0        # x16 = 0 (marker)
    bge x2, x1, bge_taken  # 20 >= 10, should branch
    addi x16, x0, -1       # Should be skipped
    j after_bge_taken
bge_taken:
    addi x16, x0, 9        # x16 = 9 (executed)  
after_bge_taken:
    
    # Test 10: BGE (Branch if Greater or Equal) - Not Taken
    addi x17, x0, 0        # x17 = 0 (marker)
    bge x4, x1, bge_not_taken  # -5 < 10, should not branch
    addi x17, x0, 10       # x17 = 10 (executed)
    j after_bge_not_taken
bge_not_taken:
    addi x17, x0, -1       # Should not execute
after_bge_not_taken:
    
    # Test 11: BLTU (Branch if Less Than Unsigned) - Setup
    addi x18, x0, -1       # x18 = 0xFFFFFFFF (large unsigned)
    addi x19, x0, 0        # x19 = 0 (marker)
    bltu x1, x18, bltu_taken  # 10 < 0xFFFFFFFF (unsigned), should branch
    addi x19, x0, -1       # Should be skipped
    j after_bltu_taken
bltu_taken:
    addi x19, x0, 11       # x19 = 11 (executed)
after_bltu_taken:
    
    # Test 12: BGEU (Branch if Greater or Equal Unsigned) - Setup
    addi x20, x0, 0        # x20 = 0 (marker)
    bgeu x18, x1, bgeu_taken  # 0xFFFFFFFF >= 10 (unsigned), should branch
    addi x20, x0, -1       # Should be skipped
    j after_bgeu_taken
bgeu_taken:
    addi x20, x0, 12       # x20 = 12 (executed)
after_bgeu_taken:
    
    # Test 13: Branch with data dependency (should forward/stall appropriately)
    add x21, x1, x2        # x21 = 10 + 20 = 30
    beq x21, x1, dep_not_taken  # 30 != 10, should not branch
    addi x22, x0, 13       # x22 = 13 (executed - no branch)
    j after_dependency
dep_not_taken:
    addi x22, x0, -1       # Should not execute
after_dependency:
    
    # Expected Results:
    # x5 = 1, x6 = return_addr, x7 = 2, x8 = target_addr, x9 = return_addr
    # x10 = 3, x11 = 4, x12 = 5, x13 = 6, x14 = 7, x15 = 8
    # x16 = 9, x17 = 10, x18 = -1, x19 = 11, x20 = 12, x21 = 30, x22 = 13
    
    wfi

# Note: This program tests all control flow instructions and verifies
# that the hardware-scheduled pipeline correctly handles:
# 1. Control hazards with automatic flush of incorrect instructions
# 2. Branch target calculation in ID stage
# 3. Branch condition evaluation with proper forwarding
# 4. Jump and link functionality with return address generation