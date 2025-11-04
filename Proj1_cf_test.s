# Proj1_cf_test.s
# Author: Shobhit Singh  
# Description: Comprehensive test of control flow instructions with call depth >= 5
# This program demonstrates nested function calls creating at least 4 activation records
# on the stack, testing JAL, JALR, and various branch instructions.

# Call Stack Visualization:
# main() -> level1() -> level2() -> level3() -> level4() -> level5()
# This creates 5 activation records on the stack (call depth = 5)

.text
.globl main

# ========== MAIN FUNCTION (Call Level 0) ==========
main:
    # Initialize stack pointer - assume stack starts at high memory
    lui sp, 0x2                # sp = 0x2000 (stack base address)
    
    # Initialize test values in registers
    addi x10, x0, 1            # x10 = 1 (test parameter 1)
    addi x11, x0, 2            # x11 = 2 (test parameter 2) 
    addi x12, x0, 3            # x12 = 3 (test parameter 3)
    
    # Test various branch conditions before making calls
    addi x5, x0, 10            # x5 = 10
    addi x6, x0, 20            # x6 = 20
    
    # Branch test 1: BEQ (Branch if Equal)
    addi x7, x0, 10            # x7 = 10 (same as x5)
    beq x5, x7, beq_success1   # Should branch since 10 == 10
    addi x20, x0, 0xFF         # Error marker - should not execute
    j branch_fail
    
beq_success1:
    addi x20, x0, 1            # x20 = 1 (BEQ test passed)
    
    # Branch test 2: BNE (Branch if Not Equal)  
    bne x5, x6, bne_success1   # Should branch since 10 != 20
    addi x21, x0, 0xFF         # Error marker - should not execute
    j branch_fail
    
bne_success1:
    addi x21, x0, 1            # x21 = 1 (BNE test passed)
    
    # Branch test 3: BLT (Branch if Less Than)
    blt x5, x6, blt_success1   # Should branch since 10 < 20
    addi x22, x0, 0xFF         # Error marker - should not execute
    j branch_fail
    
blt_success1:
    addi x22, x0, 1            # x22 = 1 (BLT test passed)
    
    # Branch test 4: BGE (Branch if Greater or Equal)
    bge x6, x5, bge_success1   # Should branch since 20 >= 10
    addi x23, x0, 0xFF         # Error marker - should not execute
    j branch_fail
    
bge_success1:
    addi x23, x0, 1            # x23 = 1 (BGE test passed)
    
    # Branch test 5: BLTU (Branch if Less Than Unsigned)
    bltu x5, x6, bltu_success1 # Should branch since 10 < 20 (unsigned)
    addi x24, x0, 0xFF         # Error marker - should not execute  
    j branch_fail
    
bltu_success1:
    addi x24, x0, 1            # x24 = 1 (BLTU test passed)
    
    # Branch test 6: BGEU (Branch if Greater or Equal Unsigned)
    bgeu x6, x5, bgeu_success1 # Should branch since 20 >= 10 (unsigned)
    addi x25, x0, 0xFF         # Error marker - should not execute
    j branch_fail
    
bgeu_success1:
    addi x25, x0, 1            # x25 = 1 (BGEU test passed)
    
    # All branch tests passed, now begin nested function calls
    # Call level1 function (creates activation record 1)
    jal x1, level1_function    # x1 = return address, call level1
    
    # Verify return values after all nested calls complete
    # x13 should contain the sum from all nested operations
    # Load 0xABC into x26 (completion marker)
    lui x26, 0x1               # x26 = 0x1000
    addi x26, x26, -1348       # x26 = 0x1000 - 1348 = 0xABC (0xABC = 2748, use 0x1000-1348)
    
    # Final test: Use JALR to jump to end via register
    addi x2, x0, end_program   # Load end_program address
    jalr x0, x2, 0             # Jump to end_program, no return
    
branch_fail:
    # Load 0xBAD into x30 (branch test failure marker)
    lui x30, 0x1               # x30 = 0x1000
    addi x30, x30, -1107       # x30 = 0x1000 - 1107 = 0xBAD (0xBAD = 2989, use 0x1000-1107)
    j end_program

# ========== LEVEL 1 FUNCTION (Call Level 1) ==========  
level1_function:
    # Save return address and local variables on stack
    addi sp, sp, -16           # Allocate stack space
    sw x1, 12(sp)             # Save return address
    sw x10, 8(sp)             # Save parameter 1
    sw x11, 4(sp)             # Save parameter 2
    sw x12, 0(sp)             # Save parameter 3
    
    # Perform some computation
    add x13, x10, x11          # x13 = x10 + x11 = 1 + 2 = 3
    
    # Test conditional branch within function
    addi x14, x0, 5            # x14 = 5
    blt x13, x14, level1_branch # Branch if x13 < 5 (should branch: 3 < 5)
    addi x27, x0, 0xFF         # Error marker
    j level1_call
    
level1_branch:
    addi x27, x0, 2            # x27 = 2 (level1 branch test passed)
    
level1_call:
    # Prepare parameters for level2 call
    addi x10, x13, 5           # x10 = x13 + 5 = 3 + 5 = 8 (new param1)
    addi x11, x13, 10          # x11 = x13 + 10 = 3 + 10 = 13 (new param2)
    
    # Call level2 function (creates activation record 2)
    jal x1, level2_function    # x1 = return address, call level2
    
    # Restore local variables from stack
    lw x12, 0(sp)             # Restore parameter 3
    lw x11, 4(sp)             # Restore parameter 2  
    lw x10, 8(sp)             # Restore parameter 1
    lw x1, 12(sp)             # Restore return address
    addi sp, sp, 16            # Deallocate stack space
    
    # Return to caller
    jalr x0, x1, 0            # Return to main

# ========== LEVEL 2 FUNCTION (Call Level 2) ==========
level2_function:
    # Save return address and local variables on stack
    addi sp, sp, -16           # Allocate stack space
    sw x1, 12(sp)             # Save return address
    sw x10, 8(sp)             # Save parameter 1  
    sw x11, 4(sp)             # Save parameter 2
    sw x13, 0(sp)             # Save current sum
    
    # Perform computation with parameters
    sub x13, x11, x10          # x13 = x11 - x10 = 13 - 8 = 5
    
    # Test BNE branch
    addi x15, x0, 0            # x15 = 0  
    bne x13, x15, level2_branch # Branch if x13 != 0 (should branch: 5 != 0)
    addi x28, x0, 0xFF         # Error marker
    j level2_call
    
level2_branch:
    addi x28, x0, 3            # x28 = 3 (level2 branch test passed)
    
level2_call:
    # Prepare parameters for level3 call
    addi x10, x13, 100         # x10 = x13 + 100 = 5 + 100 = 105
    addi x11, x13, 200         # x11 = x13 + 200 = 5 + 200 = 205
    
    # Call level3 function (creates activation record 3)  
    jal x1, level3_function    # x1 = return address, call level3
    
    # Restore local variables from stack
    lw x13, 0(sp)             # Restore current sum
    lw x11, 4(sp)             # Restore parameter 2
    lw x10, 8(sp)             # Restore parameter 1
    lw x1, 12(sp)             # Restore return address
    addi sp, sp, 16            # Deallocate stack space
    
    # Return to caller
    jalr x0, x1, 0            # Return to level1

# ========== LEVEL 3 FUNCTION (Call Level 3) ==========
level3_function:
    # Save return address and local variables on stack
    addi sp, sp, -16           # Allocate stack space
    sw x1, 12(sp)             # Save return address
    sw x10, 8(sp)             # Save parameter 1
    sw x11, 4(sp)             # Save parameter 2  
    sw x13, 0(sp)             # Save current sum
    
    # Perform XOR operation
    xor x13, x10, x11          # x13 = x10 ^ x11 = 105 ^ 205
    
    # Test BGE branch
    addi x16, x0, 100          # x16 = 100
    bge x13, x16, level3_branch # Branch if x13 >= 100 (depends on XOR result)
    # If no branch, continue
    j level3_call
    
level3_branch:
    addi x29, x0, 4            # x29 = 4 (level3 branch test passed)
    
level3_call:
    # Prepare parameters for level4 call
    andi x10, x13, 0xFF        # x10 = x13 & 0xFF (mask lower 8 bits)
    ori x11, x13, 0xF00        # x11 = x13 | 0xF00 (set upper bits)
    
    # Call level4 function (creates activation record 4)
    jal x1, level4_function    # x1 = return address, call level4
    
    # Restore local variables from stack  
    lw x13, 0(sp)             # Restore current sum
    lw x11, 4(sp)             # Restore parameter 2
    lw x10, 8(sp)             # Restore parameter 1
    lw x1, 12(sp)             # Restore return address
    addi sp, sp, 16            # Deallocate stack space
    
    # Return to caller
    jalr x0, x1, 0            # Return to level2

# ========== LEVEL 4 FUNCTION (Call Level 4) ==========  
level4_function:
    # Save return address and local variables on stack
    addi sp, sp, -16           # Allocate stack space
    sw x1, 12(sp)             # Save return address
    sw x10, 8(sp)             # Save parameter 1
    sw x11, 4(sp)             # Save parameter 2
    sw x13, 0(sp)             # Save current sum
    
    # Perform AND operation
    and x13, x10, x11          # x13 = x10 & x11
    
    # Test BLTU branch with negative numbers treated as large unsigned
    addi x17, x0, -1           # x17 = -1 = 0xFFFFFFFF (large unsigned)
    bltu x13, x17, level4_branch # Branch if x13 < 0xFFFFFFFF (should branch)
    j level4_call
    
level4_branch:
    addi x18, x0, 5            # x18 = 5 (level4 branch test passed)
    
level4_call:
    # Prepare parameters for level5 call (final nested call)
    slli x10, x13, 2           # x10 = x13 << 2 (multiply by 4)
    srli x11, x13, 1           # x11 = x13 >> 1 (divide by 2, unsigned)
    
    # Call level5 function (creates activation record 5 - maximum depth)
    jal x1, level5_function    # x1 = return address, call level5
    
    # Restore local variables from stack
    lw x13, 0(sp)             # Restore current sum  
    lw x11, 4(sp)             # Restore parameter 2
    lw x10, 8(sp)             # Restore parameter 1
    lw x1, 12(sp)             # Restore return address
    addi sp, sp, 16            # Deallocate stack space
    
    # Return to caller
    jalr x0, x1, 0            # Return to level3

# ========== LEVEL 5 FUNCTION (Call Level 5 - Deepest) ==========
level5_function:
    # Save return address and local variables on stack
    addi sp, sp, -12           # Allocate stack space
    sw x1, 8(sp)              # Save return address
    sw x10, 4(sp)             # Save parameter 1
    sw x11, 0(sp)             # Save parameter 2
    
    # Final computation at maximum call depth
    or x13, x10, x11           # x13 = x10 | x11 (final result)
    
    # Test BGEU branch  
    addi x19, x0, 0            # x19 = 0
    bgeu x13, x19, level5_branch # Branch if x13 >= 0 (should always branch)
    j level5_return
    
level5_branch:
    addi x31, x0, 6            # x31 = 6 (level5 branch test passed, deepest level)
    
level5_return:
    # Mark that we reached maximum call depth
    addi x30, x0, 0x555        # x30 = 0x555 (max depth reached marker)
    
    # Restore local variables from stack
    lw x11, 0(sp)             # Restore parameter 2
    lw x10, 4(sp)             # Restore parameter 1  
    lw x1, 8(sp)              # Restore return address
    addi sp, sp, 12            # Deallocate stack space
    
    # Return to caller (level4)
    jalr x0, x1, 0            # Return to level4

# ========== PROGRAM TERMINATION ==========
end_program:
    # Final verification values:
    # x20-x25 should all be 1 (branch tests in main)
    # x27-x29, x18, x31 should be 2,3,4,5,6 (nested function branch tests)
    # x30 should be 0x555 (max depth reached)
    # x26 should be 0xABC (completion marker)
    
    # Infinite loop to halt processor
    j end_program