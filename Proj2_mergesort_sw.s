# Software-scheduled mergesort variant for Project 2 pipeline
# Initial content duplicated from the Part 1 RARS mergesort for further rescheduling work.

.data
array:      .word 64, 34, 25, 12, 22, 11, 90, 5
aux_array:  .word 0, 0, 0, 0, 0, 0, 0, 0
array_size: .word 8

.text
.globl main

main:
	lui  sp, 0x7FFFF           # initialize stack pointer near default top
	lasw x10, array            # array base in a0
	lasw x8, aux_array         # keep aux base in s0 (x8)
	lasw t0, array_size        # pointer to array length word
	addi sp, sp, -264          # align with RARS expectation (0x7FFFEFF8)

	lw   x12, 0(t0)            # load element count
	addi x11, x0, 0            # left index = 0
	mv   t1, x8                # keep aux base cached while waiting on x12
	mv   t2, x10               # cache original array base
	addi x12, x12, -1          # right index = n - 1
	jal  x1, mergesort

	# pull sorted values into registers for inspection
	lasw x10, array            # refresh base pointer after recursion
	addi t0, x0, 0             # fill delay slot while la completes
	addi t1, x0, 0             # fill delay slot while la completes
	addi t2, x0, 0             # fill delay slot while la completes
	lw   x20, 0(x10)
	lw   x21, 4(x10)
	lw   x22, 8(x10)
	lw   x23, 12(x10)
	lw   x24, 16(x10)
	lw   x25, 20(x10)
	lw   x26, 24(x10)
	lw   x27, 28(x10)

	addi a7, x0, 10            # request RARS exit (set early for hazard spacing)
	lui  x31, 0xE              # completion marker 0xDEAD
	addi t0, x0, 0             # buffer instructions for hazard-free scheduling
	addi t1, x0, 0             # buffer instructions for hazard-free scheduling
halt:
	addi x31, x31, -339
	addi t2, x0, 0             # final buffer before system call
	ecall
	wfi                        # graceful shutdown for modelsim
	wfi

# mergesort(a0=array, a1=left, a2=right)
mergesort:
	bge  a1, a2, ms_return    # base case: single element
	addi x0, x0, 0            # branch delay slot 1
	addi x0, x0, 0            # branch delay slot 2
	addi x0, x0, 0            # branch delay slot 3

	addi sp, sp, -20          # frame layout: [mid][right][left][array][ra]
	sub  t0, a2, a1           # compute (right - left) while sp write settles
	srli t0, t0, 1            # divide by two (fills pipeline delay)
	add  a3, t0, a1           # mid = left + (right-left)/2

	sw   ra, 16(sp)           # store caller state
	sw   a0, 12(sp)
	sw   a1, 8(sp)
	sw   a2, 4(sp)
	sw   a3, 0(sp)

	addi t1, x0, 0            # spacing prior to using freshly stored values
	addi t2, x0, 0
	addi t3, x0, 0

	addi a2, a3, 0            # recurse on left half
	addi t4, x0, 0            # ensure a2 writeback clears hazards
	addi t5, x0, 0
	addi t6, x0, 0
	jal  ra, mergesort

	lw   a0, 12(sp)           # restore original bounds and pointers
	lw   a2, 4(sp)
	lw   a1, 8(sp)
	lw   a3, 0(sp)
	lw   t0, 16(sp)           # prefetch stored return address
	addi t1, x0, 0            # allow lw a3 writeback before use
	addi t2, x0, 0
	addi a1, a3, 1            # left = mid + 1 for right half
	addi t3, x0, 0            # delay before recursive call arguments consumed
	addi t4, x0, 0
	addi t5, x0, 0
	jal  ra, mergesort

	addi t6, x0, 0            # spacing after return to protect loaded values
	addi t1, x0, 0
	addi t2, x0, 0

	lw   a0, 12(sp)           # prepare merge arguments (array)
	addi t3, x0, 0
	addi t4, x0, 0
	addi a1, x8, 0            # aux base
	lw   a2, 8(sp)            # left index
	lw   a3, 0(sp)            # mid index
	lw   a4, 4(sp)            # right index
	addi t5, x0, 0            # fill delay to allow load writes to settle
	addi t6, x0, 0
	addi t1, x0, 0
	jal  ra, merge

	addi t2, x0, 0            # spacing for return register writeback
	addi t3, x0, 0
	addi t4, x0, 0

	lw   ra, 16(sp)
	addi t5, x0, 0            # ensure load result available before use
	addi t6, x0, 0
	addi t1, x0, 0
	addi sp, sp, 20          # release stack frame
	addi t2, x0, 0
	addi t3, x0, 0
	addi t4, x0, 0

ms_return:
    jalr x0, ra, 0

# merge(a0=array, a1=aux, a2=left, a3=mid, a4=right)
merge:
	addi sp, sp, -4
	sw   ra, 0(sp)

	addi t0, a2, 0            # i = left
	addi t1, a3, 1            # j = mid + 1
	addi t2, a2, 0            # k = left

	addi t3, a2, 0            # copy arr[left..right] into aux
copy_loop:
	blt  a4, t3, merge_loop
	slli t4, t3, 2
	add  t5, a0, t4
	lw   t6, 0(t5)

	addi t7, x0, 0            # ensure load data available before store addr reuse
	addi t8, x0, 0
	add  t5, a1, t4
	sw   t6, 0(t5)
	addi t3, t3, 1
	addi t7, x0, 0            # spacing before next iteration compares
	j    copy_loop

merge_loop:
	blt  a3, t0, copy_right   # left side exhausted?
	blt  a4, t1, copy_left    # right side exhausted?

	slli t4, t0, 2
	add  t5, a1, t4
	lw   t6, 0(t5)            # left value
	addi t7, x0, 0            # buffer to clear load-use
	addi t8, x0, 0
	slli t4, t1, 2
	add  t5, a1, t4
	lw   t5, 0(t5)            # right value

	addi t7, x0, 0            # spacing between loads and compare
	addi t8, x0, 0
	blt  t5, t6, take_right   # choose smaller element

take_left:
	slli t4, t2, 2
	add  t5, a0, t4
	addi t7, x0, 0
	sw   t6, 0(t5)
	addi t0, t0, 1
	addi t2, t2, 1
	addi t8, x0, 0
	j    merge_loop

take_right:
	slli t4, t2, 2
	add  t6, a0, t4
	addi t7, x0, 0
	sw   t5, 0(t6)
	addi t1, t1, 1
	addi t2, t2, 1
	addi t8, x0, 0
	j    merge_loop

copy_left:
	blt  a3, t0, merge_done
	slli t4, t0, 2
	add  t5, a1, t4
	lw   t6, 0(t5)
	addi t7, x0, 0
	addi t8, x0, 0
	slli t4, t2, 2
	add  t5, a0, t4
	sw   t6, 0(t5)
	addi t0, t0, 1
	addi t2, t2, 1
	addi t7, x0, 0
	j    copy_left

copy_right:
	blt  a4, t1, merge_done
	slli t4, t1, 2
	add  t5, a1, t4
	lw   t6, 0(t5)
	addi t7, x0, 0
	addi t8, x0, 0
	slli t4, t2, 2
	add  t5, a0, t4
	sw   t6, 0(t5)
	addi t1, t1, 1
	addi t2, t2, 1
	addi t7, x0, 0
	j    copy_right

merge_done:
	lw   ra, 0(sp)
	addi sp, sp, 4
	jalr x0, ra, 0
