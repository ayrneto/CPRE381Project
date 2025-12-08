# Software-scheduled pipeline variant of grendel
# Initial content duplicated from the Part 1 RARS adaptation for further rescheduling work.

.data
res:
	.word -1-1-1-1
nodes:
        .byte   97 # a
        .byte   98 # b
        .byte   99 # c
        .byte   100 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
	.byte 0 0 0 0
res_idx:
        .word   3
.text
        # NEW RISCV                # ORIGINAL MIPS
	li   sp, 0x10011000        # li $sp, 0x10011000
	li   fp, 0                 # li $fp, 0
        lasw ra, pump              # la $ra pump
	j    main
pump:
        j end
	ebreak                     # halt


main:
        addi t0,    sp, -40        # compute new stack pointer without immediate hazard
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # commit stack pointer update after delay slots
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   ra, 36(sp)            # save return address
        sw   fp, 32(sp)            # save old frame pointer
        add  fp,    sp, x0         # establish new frame pointer
        addi t0,    x0, 0
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   x0, 24(sp)            # zero loop index slot
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    main_loop_control

main_loop_body:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        lasw ra,    trucks         # la      $ra, trucks
        addi t0,    x0, 0          # ensure load completes before branch target uses t4
        addi t1,    x0, 0
        j    is_visited
trucks:

        xori t2,    t2, 1          # xori    $2,$2,0x1
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        beq  t2,    x0, kick       # beq     $2,$0,kick

        lw   t4, 24(fp)            # lw      $4,24($fp)
                                   # ; addi    $k0, $k0,1# breakpoint
        lasw ra,    billowy        # la      $ra, billowy
        j    topsort
billowy:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t3,  0(t2)            # lw      $3,0($2)
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2, 32(fp)            # reload pointer after delay
        addi t4,    x0, 0
        addi t5,    x0, 0
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t6,    x0, 0
        addi t0,    x0, 0
        mv   t5,    t2             # move    $5,$2
        addi t1,    x0, 0
        addi t2,    x0, 0
        mv   t4,    t3             # move    $4,$3
        addi t3,    x0, 0
        addi t4,    x0, 0
        lasw ra,    induce         # la      $ra,induce
        addi t5,    x0, 0
        addi t6,    x0, 0
        j    has_edge
        addi t5,    x0, 0
        beq  t2,    x0, quarter    # beq     $2,$0,quarter
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t4,    t2, 1          # addiu   $4,$2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        lw   t3, 32(fp)            # lw      $3,32($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   t4,  4(t3)            # sw      $4,4($3)
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    cynical
        slti t2,    t2, 4          # slti    $2,$2, 4
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t0,    x0, 0
        addi t1,    x0, 0
        addi t3,    t2, 1          # addiu   $3,$2,1
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        sw   t3,  4(t2)            # sw      $3,4($2)
hew:
        sw   x0, 28(fp)            # sw      $0,28($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        addi t2,    x0, 0
        j    welcome

wave:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        addi t3,    x0, 0
        addi t2,    t2, 1          # addiu   $2,$2,1
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   t2, 28(fp)            # sw      $2,28($fp)
welcome:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        addi t3,    x0, 0
        slti t2,    t2, 4          # slti    $2,$2,4
        addi t4,    x0, 0
        addi t5,    x0, 0
        xori t2,    t2, 1          # xori    $2,$2,1 # xori 1, beq to simulate bne where val in [0,1]
        addi t6,    x0, 0
        addi t0,    x0, 0
        addi t1,    x0, 0
        beq  t2,    x0, wave       # beq     $2,$0,wave

        mv   t2,    x0             # move    $2,$0
        mv   sp,    fp             # move    $sp,$fp
        lw   ra, 36(sp)            # lw      $31,36($sp)
        lw   fp, 32(sp)            # lw      $fp,32($sp)
        addi sp, sp, 40            # addiu   $sp,$sp,40
        jr   ra                    # jr      $ra
        
interest:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        lasw ra,    new            # la      $ra, new
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    is_visited
new:
        xori t2,    t2, 1          # xori    $2,$2,0x1
        addi t5,    x0, 0
        addi t6,    x0, 0
        andi t2,    t2, 0x0ff      # andi    $2,$2,0x00ff
        addi t0,    x0, 0
        addi t1,    x0, 0
        beq  t2,    x0, tasteful   # beq     $2,$0,tasteful

        lw   t4, 24(fp)            # lw      $4,24($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        lasw ra,    partner        # la      $ra, partner
        addi t5,    x0, 0
        addi t6,    x0, 0
        j    topsort
partner:

tasteful:
        addi t2,    fp, 28         # addiu   $2,$fp,28
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   t4,    t2             # move    $4,$2
        addi t3,    x0, 0
        addi t4,    x0, 0
        lasw ra,    badge          # la      $ra, badge
        addi t5,    x0, 0
        addi t6,    x0, 0
        j    next_edge
badge:
        sw   t2, 24(fp)            # sw      $2,24($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        
turkey:
        lw   t3, 24(fp)            # lw      $3,24($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        li   t2, -1                # li      $2,-1
        addi t4,    x0, 0
        addi t5,    x0, 0
        beq  t3,    t2, telling    # beq     $3,$2,telling # beq, j to simulate bne
        addi t6,    x0, 0
        addi t0,    x0, 0
        j    interest
telling:
        # NOTE: $v0 === $2
	lasw t2,    res_idx        # la      $v0, res_idx
	addi t3,    x0, 0
	addi t4,    x0, 0
	lw   t2,  0(t2)            # lw      $v0, 0($v0)
        addi t4,    t2, -1         # addiu   $4,$2,-1
	        lasw t3,    res_idx        # la      $3, res_idx
	        addi t5,    x0, 0
	        addi t6,    x0, 0
	        sw   t4,  0(t3)            # sw      $4, 0($3)
	        addi t0,    x0, 0
	        addi t1,    x0, 0
	        lasw t4,    res            # la      $4, res
                                   # ; lui     $3,%hi(res_idx)
                                   # ; sw      $4,%lo(res_idx)($3)
                                   # ; lui     $4,%hi(res)
        slli t3,    t2, 2          # sll     $3,$2,2
        srli t3,    t3, 1          # srl     $3,$3,1
        srai t3,    t3, 1          # sra     $3,$3,1
        slli t3,    t3, 2          # sll     $3,$3,2
       
       	xor  t6,    ra, t2         # xor     $at, $ra, $2 # does nothing 
        or   t6,    ra, t2         # nor     $at, $ra, $2 # does nothing 
        neg  t6,    t6
        
                lasw t2,    res            # la      $2, res
        li   a1,    0x0000ffff
        and  t6,    t2, a1         # andi    $at, $2, 0xffff # -1 will sign extend (according to assembler), but 0xffff won't
        add  t2,    t4, t6         # addu    $2, $4, $at
        add  t2,    t3, t2         # addu    $2,$3,$2
                lw   t3, 48(fp)            # lw      $3,48($fp)
                addi t5,    x0, 0
                addi t6,    x0, 0
                addi t0,    x0, 0
                sw   t3,  0(t2)            # sw      $3,0($2)
        mv   sp,    fp             # move    $sp,$fp
                addi t1,    x0, 0
                addi t2,    x0, 0
                lw   ra, 44(sp)            # lw      $31,44($sp)
                addi t3,    x0, 0
                addi t4,    x0, 0
                lw   fp, 40(sp)            # lw      $fp,40($sp)
                addi t5,    x0, 0
                addi t6,    x0, 0
                addi sp,    sp, 48         # addiu   $sp,$sp,48
        jr   ra                    # jr      $ra
   

topsort:
        addi t0,    sp, -48        # precompute new sp
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # commit stack pointer update
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   ra, 44(sp)            # sw      $31,44($sp)
        sw   fp, 40(sp)            # sw      $fp,40($sp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   fp,    sp             # move    $fp,$sp
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t4, 48(fp)            # sw      $4,48($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        lw   t4, 48(fp)            # lw      $4,48($fp)
        addi t6,    x0, 0
        addi t0,    x0, 0
        lasw ra,    verse          # la      $ra, verse
        addi t1,    x0, 0
        addi t2,    x0, 0
        j    mark_visited
verse:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        addi t3,    x0, 0
        addi t4,    x0, 0
        lw   t5, 48(fp)            # lw      $5,48($fp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        mv   t4,    t2             # move    $4,$2
        addi t0,    x0, 0
        addi t1,    x0, 0
        lasw ra,    joyous         # la      $ra, joyous
        addi t2,    x0, 0
        addi t3,    x0, 0
        j    iterate_edges
joyous:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        addi t4,    x0, 0
        addi t5,    x0, 0
        mv   t4,    t2             # move    $4,$2
        addi t6,    x0, 0
        addi t0,    x0, 0
        lasw ra,    whispering     # la      $ra, whispering
        addi t1,    x0, 0
        addi t2,    x0, 0
        j    next_edge
whispering:

        sw   t2, 24(fp)            # sw      $2,24($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    turkey

iterate_edges:
        addi t0,    sp, -24        # precompute child frame
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # push frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   fp, 20(sp)            # save caller fp
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   fp,    sp             # new fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        sub  t6,    fp, sp         # bookkeeping (nop-friendly)
        addi t4,    x0, 0
        addi t5,    x0, 0
        sw   t4, 24(fp)            # store adjacency pointer base
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t5, 28(fp)            # store adjacency row index
        addi t1,    x0, 0
        addi t2,    x0, 0
        lw   t2, 28(fp)            # load adjacency row
        addi t3,    x0, 0
        addi t4,    x0, 0
        sw   t2,  8(fp)            # write row pointer
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   x0, 12(fp)            # zero edge index
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t2, 24(fp)            # reload adjacency structure address
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t4,  8(fp)            # fetch row pointer
        addi t4,    x0, 0
        addi t5,    x0, 0
        lw   t3, 12(fp)            # fetch edge index
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t4,  0(t2)            # write pair struct
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   t3,  4(t2)            # write index
        addi t3,    x0, 0
        addi t4,    x0, 0
        lw   t2, 24(fp)            # reload for return value
        addi t5,    x0, 0
        addi t6,    x0, 0
        mv   sp,    fp             # pop frame pointer into sp shadow
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   fp, 20(sp)            # restore caller fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        addi sp,    sp, 24         # pop stack frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        jr   ra                    # jr      $ra
        
next_edge:
        addi t0,    sp, -32        # precompute new frame
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # push frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   ra, 28(sp)            # save ra
        addi t0,    x0, 0
        addi t1,    x0, 0
        sw   fp, 24(sp)            # save fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  fp,    x0, sp         # new fp
        addi t4,    x0, 0
        addi t5,    x0, 0
        sw   t4, 32(fp)            # store pointer block
        addi t6,    x0, 0
        addi t0,    x0, 0
        j    waggish

snail:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        lw   t3,  0(t2)            # lw      $3,0($2)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        lw   t2,  4(t2)            # lw      $2,4($2)
        mv   t5,    t2             # move    $5,$2
        mv   t4,    t3             # move    $4,$3
        lasw ra,    induce         # la      $ra,induce
        j    has_edge
induce:
        beq  t2,    x0, quarter    # beq     $2,$0,quarter
        lw   t2, 32(fp)            # lw      $2,32($fp)
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t4,    t2, 1          # addiu   $4,$2,1
        lw   t3, 32(fp)            # lw      $3,32($fp)
        sw   t4,  4(t3)            # sw      $4,4($3)
        j    cynical

quarter:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t3,    t2, 1          # addiu   $3,$2,1
        lw   t2, 32(fp)            # lw      $2,32($fp)
        sw   t3,  4(t2)            # sw      $3,4($2)

waggish:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t6,    x0, 0
        addi t0,    x0, 0
        lw   t2,  4(t2)            # lw      $2,4($2)
        addi t1,    x0, 0
        addi t2,    x0, 0
        slti t2,    t2, 4          # slti    $2,$2,4
        addi t3,    x0, 0
        addi t4,    x0, 0
        beq  t2,    x0, mark       # beq     $2,$zero,mark # beq, j to simulate bne 
        j    snail
mark:
        li   t2, -1                # li      $2,-1

cynical:
        mv   sp,    fp             # move    $sp,$fp
        lw   ra, 28(sp)            # lw      $31,28($sp)
        lw   fp, 24(sp)            # lw      $fp,24($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra                    # jr      $ra
has_edge:
        addi t0,    sp, -32        # precompute frame
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # push frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   fp, 28(sp)            # store caller fp
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   fp,    sp             # move    $fp,$sp
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t4, 32(fp)            # preserve current pointer
        addi t4,    x0, 0
        addi t5,    x0, 0
        sw   t5, 36(fp)            # store adjacency column
        addi t6,    x0, 0
        addi t0,    x0, 0
        lasw t2,    adjacencymatrix# la      $2,adjacencymatrix
        addi t1,    x0, 0
        addi t2,    x0, 0
        lw   t3, 32(fp)            # lw      $3,32($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        slli t3,    t3, 2          # sll     $3,$3,2
        addi t5,    x0, 0
        addi t6,    x0, 0
        add  t2,    t3, t2         # addu    $2,$3,$2
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t2,  0(t2)            # lw      $2,0($2)
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t2, 16(fp)            # sw      $2,16($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        li   t2,  1                # li      $2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2,  8(fp)            # sw      $2,8($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   x0, 12(fp)            # sw      $0,12($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    measley

look:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        slli t2,    t2, 1          # sll     $2,$2,1
        addi t0,    x0, 0
        addi t1,    x0, 0
        sw   t2,  8(fp)            # sw      $2,8($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2, 12(fp)            # lw      $2,12($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t2,    t2, 1          # addiu   $2,$2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2, 12(fp)            # sw      $2,12($fp)
measley:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        lw   t2, 36(fp)            # lw      $2,36($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        slt  t2,    t3, t2         # slt     $2,$3,$2
        addi t5,    x0, 0
        addi t6,    x0, 0
        beq  t2,    x0, experience # beq     $2,$0,experience # beq, j to simulate bne 
        j    look
experience:
        lw   t3,  8(fp)            # lw      $3,8($fp)
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t2, 16(fp)            # lw      $2,16($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        and  t2,    t3, t2         # and     $2,$3,$2
        addi t4,    x0, 0
        addi t5,    x0, 0
        slt  t2,    x0, t2         # slt     $2,$0,$2
        addi t6,    x0, 0
        addi t0,    x0, 0
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        addi t1,    x0, 0
        addi t2,    x0, 0
        mv   sp,    fp             # move    $sp,$fp
        addi t3,    x0, 0
        addi t4,    x0, 0
        lw   fp, 28(sp)            # lw      $fp,28($sp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra                    # jr      $ra
        
mark_visited:
        addi t0,    sp, -32        # precompute frame pointer update
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0         # push frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   fp, 28(sp)            # save caller fp
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   fp,    sp             # new fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t4, 32(fp)            # remember node index
        addi t4,    x0, 0
        addi t5,    x0, 0
        li   t2,  1                # li      $2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2,  8(fp)            # mark bit pattern base
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   x0, 12(fp)            # reset iteration counter
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    recast

example:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        slli t2,    t2, 8          # sll     $2,$2,8
        addi t0,    x0, 0
        addi t1,    x0, 0
        sw   t2,  8(fp)            # sw      $2,8($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2, 12(fp)            # lw      $2,12($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t2,    t2, 1          # addiu   $2,$2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2, 12(fp)            # sw      $2,12($fp)
recast:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        lw   t2, 32(fp)            # lw      $2,32($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        slt  t2,    t3, t2         # slt     $2,$3,$2
        addi t5,    x0, 0
        addi t6,    x0, 0
        beq  t2,    x0, pat        # beq     $2,$zero,pat # beq, j to simulate bne
        j    example
pat:

        lasw t2, visited             # la      $2, visited
                addi t0,    x0, 0
                addi t1,    x0, 0
                sw   t2, 16(fp)              # sw      $2,16($fp)
                addi t2,    x0, 0
                addi t3,    x0, 0
                lw   t2, 16(fp)              # lw      $2,16($fp)
                addi t4,    x0, 0
                addi t5,    x0, 0
                lw   t3,  0(t2)              # lw      $3,0($2)
                addi t6,    x0, 0
                addi t0,    x0, 0
                lw   t2,  8(fp)              # lw      $2,8($fp)
                addi t1,    x0, 0
                addi t2,    x0, 0
                or   t3,    t3, t2           # or      $3,$3,$2
                addi t3,    x0, 0
                addi t4,    x0, 0
                lw   t2, 16(fp)              # lw      $2,16($fp)
                addi t5,    x0, 0
                addi t6,    x0, 0
                sw   t3,  0(t2)              # sw      $3,0($2)
                addi t0,    x0, 0
                addi t1,    x0, 0
                mv   sp,    fp               # move    $sp,$fp
                addi t2,    x0, 0
                addi t3,    x0, 0
                lw   fp, 28(sp)              # lw      $fp,28($sp)
                addi t4,    x0, 0
                addi t5,    x0, 0
                addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        
is_visited:
        addi t0,    sp, -32          # precompute frame update
        addi t1,    x0, 0
        addi t2,    x0, 0
        addi t3,    x0, 0
        add  sp,    t0, x0           # push frame
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t6,    x0, 0
        sw   fp, 28(sp)              # save caller fp
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   fp,    sp               # new fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t4, 32(fp)              # store node index
        addi t4,    x0, 0
        addi t5,    x0, 0
        ori  t2,    x0, 1            # ori     $2,$zero,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2,  8(fp)              # initial bitmask
        addi t1,    x0, 0
        addi t2,    x0, 0
        sw   x0, 12(fp)              # iteration index
        addi t3,    x0, 0
        addi t4,    x0, 0
        j    evasive

justify:
        lw   t2,  8(fp)              # lw      $2,8($fp)
        addi t5,    x0, 0
        addi t6,    x0, 0
        slli t2,    t2, 8            # sll     $2,$2,8
        addi t0,    x0, 0
        addi t1,    x0, 0
        sw   t2,  8(fp)              # sw      $2,8($fp)
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   t2, 12(fp)              # lw      $2,12($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi t2,    t2, 1            # addiu   $2,$2,1
        addi t6,    x0, 0
        addi t0,    x0, 0
        sw   t2, 12(fp)              # sw      $2,12($fp)

evasive:
        lw   t3, 12(fp)              # lw      $3,12($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        lw   t2, 32(fp)              # lw      $2,32($fp)
        addi t3,    x0, 0
        addi t4,    x0, 0
        slt  t2,    t3, t2           # slt     $2,$3,$2
        addi t5,    x0, 0
        addi t6,    x0, 0
        beq  t2,    x0,representative# beq $2,$0,representitive # beq, j to simulate bne
        j    justify
representative:

        lasw t2,    visited          # la      $2,visited
        addi t0,    x0, 0
        addi t1,    x0, 0
        lw   t2,  0(t2)              # lw      $2,0($2)
        addi t2,    x0, 0
        addi t3,    x0, 0
        sw   t2, 16(fp)              # sw      $2,16($fp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        lw   t3, 16(fp)              # lw      $3,16($fp)
        addi t6,    x0, 0
        addi t0,    x0, 0
        lw   t2,  8(fp)              # lw      $2,8($fp)
        addi t1,    x0, 0
        addi t2,    x0, 0
        and  t2,    t3, t2           # and     $2,$3,$2
        addi t3,    x0, 0
        addi t4,    x0, 0
        slt  t2,    x0, t2           # slt     $2,$0,$2
        addi t5,    x0, 0
        addi t6,    x0, 0
        andi t2,    t2, 0xff         # andi    $2,$2,0x00ff
        addi t0,    x0, 0
        addi t1,    x0, 0
        mv   sp,    fp               # move    $sp,$fp
        addi t2,    x0, 0
        addi t3,    x0, 0
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi t4,    x0, 0
        addi t5,    x0, 0
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra

end:
        wfi
