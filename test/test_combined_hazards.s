# Test Program 4: Complex Combined Hazard Testing
# Tests combinations of data and control hazards

.text
.globl main

main:
    # Test 1: Load-use hazard with branch dependency
    addi x1, x0, 0         # Base address
    addi x2, x0, 42        # Test value
    sw x2, 0(x1)           # Store test value
    
    lw x3, 0(x1)           # Load value (42)
    beq x3, x2, load_branch_taken  # Compare loaded value with register
    addi x4, x0, -1        # Should be skipped
    j after_load_branch
load_branch_taken:
    addi x4, x0, 1         # x4 = 1 (should execute)
after_load_branch:
    
    # Test 2: Forwarding into branch comparison
    add x5, x1, x2         # x5 = 0 + 42 = 42
    beq x5, x2, forward_branch_taken  # Compare forwarded value
    addi x6, x0, -1        # Should be skipped  
    j after_forward_branch
forward_branch_taken:
    addi x6, x0, 2         # x6 = 2 (should execute)
after_forward_branch:
    
    # Test 3: JALR with data dependency
    addi x7, x0, jalr_target_addr & 0xFFF  # Low bits of target
    lui x8, (jalr_target_addr >> 12)       # High bits of target  
    add x9, x7, x8         # x9 = complete target address
    jalr x10, 0(x9)        # Jump to computed address
    addi x11, x0, -1       # Should be skipped
    j after_jalr_dep
jalr_target_addr:
    addi x11, x0, 3        # x11 = 3 (should execute)
    jalr x0, 0(x10)        # Return
after_jalr_dep:
    
    # Test 4: Loop with multiple hazards
    addi x12, x0, 0        # Loop counter
    addi x13, x0, 5        # Loop limit
    addi x14, x0, 0        # Accumulator
loop_start:
    add x14, x14, x12      # Accumulate counter (forwarding)
    addi x12, x12, 1       # Increment counter (forwarding)
    blt x12, x13, loop_start  # Continue if counter < limit (forwarding)
    
    # Test 5: Chain of dependencies with branches
    addi x15, x0, 10       # x15 = 10
    add x16, x15, x15      # x16 = 20 (forward x15)
    sub x17, x16, x15      # x17 = 10 (forward x16 and x15)
    beq x17, x15, chain_equal  # Compare forwarded values
    addi x18, x0, -1       # Should be skipped
    j after_chain
chain_equal:
    addi x18, x0, 4        # x18 = 4 (should execute)
after_chain:
    
    # Test 6: Store followed by load (memory dependency)
    addi x19, x0, 100      # Test value
    sw x19, 4(x1)          # Store value (forward x19)
    lw x20, 4(x1)          # Load same location 
    beq x20, x19, store_load_equal  # Should be equal
    addi x21, x0, -1       # Should be skipped
    j after_store_load
store_load_equal:
    addi x21, x0, 5        # x21 = 5 (should execute)
after_store_load:
    
    # Test 7: Nested function calls with dependencies
    addi x22, x0, 7        # Parameter
    jal x23, function_a    # Call function A
    j after_nested
    
function_a:
    add x24, x22, x22      # x24 = x22 + x22 (forward parameter)
    jal x25, function_b    # Call function B
    jalr x0, 0(x23)        # Return to caller
    
function_b:
    sub x26, x24, x22      # x26 = x24 - x22 (forward from function A)
    jalr x0, 0(x25)        # Return to function A
    
after_nested:
    
    # Test 8: Multiple forwarding paths simultaneously
    add x27, x1, x2        # x27 = 0 + 42 = 42
    sub x28, x2, x1        # x28 = 42 - 0 = 42
    and x29, x27, x28      # x29 = x27 & x28 = 42 (forward both)
    or x30, x29, x27       # x30 = x29 | x27 = 42 (forward both)
    
    # Expected Results:
    # x3 = 42, x4 = 1, x5 = 42, x6 = 2
    # x9 = target_addr, x10 = return_addr, x11 = 3
    # x12 = 5, x13 = 5, x14 = 10 (0+1+2+3+4)
    # x15 = 10, x16 = 20, x17 = 10, x18 = 4
    # x19 = 100, x20 = 100, x21 = 5  
    # x22 = 7, x24 = 14, x26 = 7
    # x27 = 42, x28 = 42, x29 = 42, x30 = 42
    
    wfi

# This comprehensive test validates:
# 1. Load-use hazards combined with control decisions  
# 2. Data forwarding into branch comparisons
# 3. Complex address calculations for indirect jumps
# 4. Loop structures with multiple dependency types
# 5. Chained dependencies through multiple instructions
# 6. Memory dependencies (store-to-load forwarding)
# 7. Function call overhead with parameter passing
# 8. Simultaneous multiple forwarding paths
#
# Performance comparison with software-scheduled version should show:
# - Significant reduction in cycle count
# - Elimination of manual NOP instructions
# - Automatic hazard resolution by hardware