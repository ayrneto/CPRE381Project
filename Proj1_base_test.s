# Proj1_base_test.s
# Author: Shobhit Singh
# Description: Comprehensive test of all required arithmetic and logical instructions
# This program demonstrates sequential execution of instructions while showing
# data flow through registers and memory operations.

# Test Plan:
# 1. R-Type Instructions: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
# 2. I-Type Instructions: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU
# 3. Memory Instructions: LW, SW, LB, LBU, LH, LHU, SB, SH
# 4. Upper Immediate: LUI, AUIPC
# 5. Control Flow: BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR

.text
.globl main

main:
    # ========== IMMEDIATE OPERATIONS (I-Type) ==========
    # Initialize base registers with immediate values
    addi x1, x0, 100       # x1 = 0 + 100 = 100 (base value)
    addi x2, x0, 50        # x2 = 0 + 50 = 50 (second operand)
    addi x3, x0, -25       # x3 = 0 + (-25) = -25 (negative test)
    addi x4, x0, 0x7FF     # x4 = 0 + 2047 = 2047 (max 12-bit positive)
    addi x5, x0, -2048     # x5 = 0 + (-2048) = -2048 (min 12-bit negative)

    # ========== ARITHMETIC OPERATIONS (R-Type) ==========
    # Test ADD instruction
    add x6, x1, x2         # x6 = x1 + x2 = 100 + 50 = 150
    
    # Test SUB instruction
    sub x7, x1, x2         # x7 = x1 - x2 = 100 - 50 = 50
    
    # Test with negative numbers
    add x8, x1, x3         # x8 = x1 + x3 = 100 + (-25) = 75
    sub x9, x3, x2         # x9 = x3 - x2 = (-25) - 50 = -75

    # ========== LOGICAL OPERATIONS (R-Type and I-Type) ==========
    # Initialize test patterns
    addi x10, x0, 0x0FF    # x10 = 255 (0x00FF) - test pattern 1
    addi x11, x0, 0x555    # x11 = 1365 (0x0555) - alternating bits
    
    # Test AND operations
    and x12, x10, x11      # x12 = x10 & x11 = 0x00FF & 0x0555 = 0x0055
    andi x13, x10, 0x0F0   # x13 = x10 & 0x0F0 = 0x00FF & 0x00F0 = 0x00F0
    
    # Test OR operations
    or x14, x10, x11       # x14 = x10 | x11 = 0x00FF | 0x0555 = 0x07FF
    ori x15, x10, 0xF00    # x15 = x10 | 0xF00 = 0x00FF | 0xF00 = 0xFFF
    
    # Test XOR operations
    xor x16, x10, x11      # x16 = x10 ^ x11 = 0x00FF ^ 0x0555 = 0x05AA
    xori x17, x10, 0xAAA   # x17 = x10 ^ 0xAAA = 0x00FF ^ 0xAAA = 0xA55

    # ========== SHIFT OPERATIONS ==========
    addi x18, x0, 0x100    # x18 = 256 (0x100) - base for shifts
    
    # Test Shift Left Logical
    sll x19, x18, x2       # x19 = x18 << (x2 & 0x1F) = 256 << 18 = very large
    slli x20, x18, 4       # x20 = x18 << 4 = 256 << 4 = 4096
    
    # Test Shift Right Logical
    addi x21, x0, -1       # x21 = 0xFFFFFFFF (all 1s)
    srl x22, x21, x2       # x22 = x21 >> (x2 & 0x1F) = logical shift
    srli x23, x21, 8       # x23 = x21 >> 8 = 0x00FFFFFF
    
    # Test Shift Right Arithmetic
    sra x24, x21, x2       # x24 = x21 >>> (x2 & 0x1F) = arithmetic shift (sign extend)
    srai x25, x21, 8       # x25 = x21 >>> 8 = 0xFFFFFFFF (sign extended)

    # ========== COMPARISON OPERATIONS ==========
    # Test Set Less Than (signed)
    slt x26, x3, x2        # x26 = (x3 < x2) ? 1 : 0 = (-25 < 50) ? 1 : 0 = 1
    slti x27, x3, 0        # x27 = (x3 < 0) ? 1 : 0 = (-25 < 0) ? 1 : 0 = 1
    
    # Test Set Less Than Unsigned
    sltu x28, x3, x2       # x28 = (x3 < x2) unsigned = (0xFFFFFFE7 < 50) ? 1 : 0 = 0
    sltiu x29, x3, 100     # x29 = (x3 < 100) unsigned = (0xFFFFFFE7 < 100) ? 1 : 0 = 0

    # ========== UPPER IMMEDIATE OPERATIONS ==========
    # Test Load Upper Immediate
    lui x30, 0x12345      # x30 = 0x12345000 (load upper 20 bits)
    
    # Test Add Upper Immediate to PC
    auipc x31, 0x1000     # x31 = PC + (0x1000 << 12) = PC + 0x1000000

    # ========== MEMORY OPERATIONS ==========
    # Set up memory base address
    lui x1, 0x1           # x1 = 0x1000 (memory base address)
    
    # Store operations - write test data to memory
    sw x6, 0(x1)          # Store word: MEM[0x1000] = x6 = 150
    sw x7, 4(x1)          # Store word: MEM[0x1004] = x7 = 50
    sw x8, 8(x1)          # Store word: MEM[0x1008] = x8 = 75
    sw x9, 12(x1)         # Store word: MEM[0x100C] = x9 = -75
    
    # Store halfwords and bytes
    sh x10, 16(x1)        # Store halfword: MEM[0x1010] = x10[15:0] = 0x00FF
    sb x11, 18(x1)        # Store byte: MEM[0x1012] = x11[7:0] = 0x55
    
    # Load operations - read back and verify
    lw x2, 0(x1)          # Load word: x2 = MEM[0x1000] = 150
    lw x3, 4(x1)          # Load word: x3 = MEM[0x1004] = 50
    lw x4, 8(x1)          # Load word: x4 = MEM[0x1008] = 75
    lw x5, 12(x1)         # Load word: x5 = MEM[0x100C] = -75
    
    # Load halfwords (signed and unsigned)
    lh x6, 16(x1)         # Load halfword signed: x6 = sign_extend(MEM[0x1010])
    lhu x7, 16(x1)        # Load halfword unsigned: x7 = zero_extend(MEM[0x1010])
    
    # Load bytes (signed and unsigned)
    lb x8, 18(x1)         # Load byte signed: x8 = sign_extend(MEM[0x1012])
    lbu x9, 18(x1)        # Load byte unsigned: x9 = zero_extend(MEM[0x1012])

    # ========== BRANCH OPERATIONS ==========
    # Initialize test values for branches
    addi x10, x0, 10      # x10 = 10
    addi x11, x0, 20      # x11 = 20
    addi x12, x0, 10      # x12 = 10 (equal to x10)
    
branch_test_beq:
    # Test Branch if Equal
    beq x10, x12, beq_taken    # Should branch (10 == 10)
    addi x13, x0, 999          # This should NOT execute
    j branch_test_bne

beq_taken:
    addi x13, x0, 1            # x13 = 1 (branch was taken correctly)

branch_test_bne:
    # Test Branch if Not Equal
    bne x10, x11, bne_taken    # Should branch (10 != 20)
    addi x14, x0, 999          # This should NOT execute
    j branch_test_blt

bne_taken:
    addi x14, x0, 1            # x14 = 1 (branch was taken correctly)

branch_test_blt:
    # Test Branch if Less Than (signed)
    blt x10, x11, blt_taken    # Should branch (10 < 20)
    addi x15, x0, 999          # This should NOT execute
    j branch_test_bge

blt_taken:
    addi x15, x0, 1            # x15 = 1 (branch was taken correctly)

branch_test_bge:
    # Test Branch if Greater or Equal (signed)
    bge x11, x10, bge_taken    # Should branch (20 >= 10)
    addi x16, x0, 999          # This should NOT execute
    j branch_test_bltu

bge_taken:
    addi x16, x0, 1            # x16 = 1 (branch was taken correctly)

branch_test_bltu:
    # Test Branch if Less Than Unsigned
    bltu x10, x11, bltu_taken  # Should branch (10 < 20 unsigned)
    addi x17, x0, 999          # This should NOT execute
    j branch_test_bgeu

bltu_taken:
    addi x17, x0, 1            # x17 = 1 (branch was taken correctly)

branch_test_bgeu:
    # Test Branch if Greater or Equal Unsigned
    bgeu x11, x10, bgeu_taken  # Should branch (20 >= 10 unsigned)
    addi x18, x0, 999          # This should NOT execute
    j jump_test

bgeu_taken:
    addi x18, x0, 1            # x18 = 1 (branch was taken correctly)

    # ========== JUMP OPERATIONS ==========
jump_test:
    # Test Jump and Link
    jal x19, jump_target       # x19 = return address, jump to jump_target
    addi x20, x0, 999          # This should NOT execute immediately
    
after_jal:
    # Test Jump and Link Register
    addi x21, x0, 100          # Set up test value
    jalr x22, x19, 0           # x22 = return address, jump to address in x19
    
jump_target:
    addi x20, x0, 1            # x20 = 1 (jumped successfully)
    j after_jal                # Return to after_jal

    # ========== VERIFICATION SECTION ==========
verification:
    # This section can be used to verify results
    # Expected values for verification:
    # x6 should be 150 (from ADD)
    # x7 should be 50 (from SUB)  
    # x13-x18 should all be 1 (branch tests passed)
    # x20 should be 1 (jump test passed)
    
    # Final instruction to indicate completion
    # Load 0xDEAD into x31 (completion marker)
    lui x31, 0xE              # x31 = 0xE000
    addi x31, x31, -339       # x31 = 0xE000 - 339 = 0xDEAD

    # Program termination (infinite loop for simulation)
end_program:
    j end_program              # Infinite loop to halt processor