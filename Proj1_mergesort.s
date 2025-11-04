# Proj1_mergesort.s
# Author: Shobhit Singh
# Description: Implementation of Mergesort algorithm in RISC-V assembly
# This program sorts an array of N=8 integers using the divide-and-conquer
# mergesort algorithm, demonstrating recursive function calls and memory operations.

# Algorithm Overview:
# 1. Divide array into halves recursively until size 1
# 2. Merge sorted subarrays back together
# 3. Uses auxiliary array for merging process

# Memory Layout (RARS-compatible addresses):
# 0x10010000: Original array (8 integers) - RARS data segment  
# 0x10010020: Auxiliary array (8 integers for merging)
# 0x7fffeffc: Stack base (RARS stack segment)

.text
.globl main

# ========== DATA SECTION (Embedded in code) ==========
setup_data:
    # Initialize memory base addresses (RARS-compatible)
    # Load 0x10010000 into x28 (original array base - RARS data segment)
    lui x28, 0x10010           # x28 = 0x10010000 (RARS data segment)
    
    # Load 0x10010020 into x29 (auxiliary array base)  
    lui x29, 0x10010           # x29 = 0x10010000
    addi x29, x29, 0x20        # x29 = 0x10010000 + 0x20 = 0x10010020
    
    # Load stack base into sp (RARS stack segment)
    lui sp, 0x7ffff            # sp = 0x7ffff000 (near RARS stack base)
    
    # Initialize test array with unsorted data
    # Array: [64, 34, 25, 12, 22, 11, 90, 5]
    addi x1, x0, 64            # arr[0] = 64
    sw x1, 0(x28)
    addi x1, x0, 34            # arr[1] = 34  
    sw x1, 4(x28)
    addi x1, x0, 25            # arr[2] = 25
    sw x1, 8(x28)
    addi x1, x0, 12            # arr[3] = 12
    sw x1, 12(x28)
    addi x1, x0, 22            # arr[4] = 22
    sw x1, 16(x28)
    addi x1, x0, 11            # arr[5] = 11
    sw x1, 20(x28)
    addi x1, x0, 90            # arr[6] = 90
    sw x1, 24(x28)
    addi x1, x0, 5             # arr[7] = 5
    sw x1, 28(x28)
    
    # Array size
    addi x30, x0, 8            # x30 = 8 (array size N)
    
    jalr x0, x1, 0             # Return to caller

# ========== MAIN FUNCTION ==========
main:
    # Setup data first
    jal x1, setup_data         # Initialize array and memory
    
    # Print original array (for simulation verification)
    # In a real system, this would be a print function call
    # Load 0xAAAA into x31 (original array marker)
    lui x31, 0xB               # x31 = 0xB000
    addi x31, x31, -1366       # x31 = 0xB000 - 1366 = 0xAAAA (0xAAA = 2730, use -1366 instead)
    
    # Call mergesort on entire array
    # Parameters: mergesort(arr, 0, n-1)
    add x10, x0, x28           # x10 = array base address
    add x11, x0, x0            # x11 = 0 (left index)
    addi x12, x30, -1          # x12 = n-1 = 7 (right index)
    
    jal x1, mergesort          # Call mergesort(arr, 0, 7)
    
    # Print sorted array (for simulation verification)
    # Load 0xBBBB into x31 (sorted array marker)
    lui x31, 0xC               # x31 = 0xC000
    addi x31, x31, -1093       # x31 = 0xC000 - 1093 = 0xBBBB (0xBBB = 3003, use -1093 instead)
    
    # Verification: Load sorted values for inspection
    lw x20, 0(x28)            # x20 = arr[0] (should be smallest: 5)
    lw x21, 4(x28)            # x21 = arr[1] (should be 11)
    lw x22, 8(x28)            # x22 = arr[2] (should be 12)
    lw x23, 12(x28)           # x23 = arr[3] (should be 22)
    lw x24, 16(x28)           # x24 = arr[4] (should be 25)
    lw x25, 20(x28)           # x25 = arr[5] (should be 34)
    lw x26, 24(x28)           # x26 = arr[6] (should be 64)
    lw x27, 28(x28)           # x27 = arr[7] (should be largest: 90)
    
    # Mark completion
    # Load 0xDEAD into x31 (completion marker)
    lui x31, 0xE               # x31 = 0xE000
    addi x31, x31, -339        # x31 = 0xE000 - 339 = 0xDEAD (0xEAD = 3757, use -339 instead)
    
    # Infinite loop to halt
    j end_program

# ========== MERGESORT FUNCTION ==========
# Parameters: x10 = array, x11 = left, x12 = right
# Local variables saved on stack
mergesort:
    # Check base case: if left >= right, return
    bge x11, x12, mergesort_return
    
    # Save registers on stack  
    addi sp, sp, -20           # Allocate stack frame
    sw x1, 16(sp)             # Save return address
    sw x10, 12(sp)            # Save array pointer
    sw x11, 8(sp)             # Save left index
    sw x12, 4(sp)             # Save right index
    sw x13, 0(sp)             # Save middle index
    
    # Calculate middle: mid = left + (right - left) / 2
    sub x13, x12, x11          # x13 = right - left
    srli x13, x13, 1           # x13 = (right - left) / 2
    add x13, x13, x11          # x13 = left + (right - left) / 2 = mid
    
    # Recursive call 1: mergesort(arr, left, mid)
    # x10 already contains array pointer
    # x11 already contains left
    add x12, x0, x13           # x12 = mid (new right)
    jal x1, mergesort          # Call mergesort(arr, left, mid)
    
    # Restore registers for second recursive call
    lw x13, 0(sp)             # Restore middle index
    lw x12, 4(sp)             # Restore right index  
    lw x11, 8(sp)             # Restore left index
    lw x10, 12(sp)            # Restore array pointer
    
    # Recursive call 2: mergesort(arr, mid+1, right)
    addi x11, x13, 1           # x11 = mid + 1 (new left)
    # x12 already contains original right
    jal x1, mergesort          # Call mergesort(arr, mid+1, right)
    
    # Restore all registers for merge call
    lw x13, 0(sp)             # Restore middle index
    lw x12, 4(sp)             # Restore right index
    lw x11, 8(sp)             # Restore left index  
    lw x10, 12(sp)            # Restore array pointer
    lw x1, 16(sp)             # Restore return address
    
    # Call merge to combine the two sorted halves
    # Parameters: merge(arr, left, mid, right)
    # x10, x11, x12, x13 are already set
    addi sp, sp, -4            # Save return address again
    sw x1, 0(sp)
    jal x1, merge              # Call merge(arr, left, mid, right)
    lw x1, 0(sp)              # Restore return address
    addi sp, sp, 4
    
    addi sp, sp, 20            # Deallocate stack frame
    
mergesort_return:
    jalr x0, x1, 0            # Return to caller

# ========== MERGE FUNCTION ==========
# Parameters: x10 = array, x11 = left, x12 = right, x13 = mid
# Merges arr[left..mid] and arr[mid+1..right] 
merge:
    # Save registers on stack
    addi sp, sp, -32           # Allocate stack frame
    sw x1, 28(sp)             # Save return address
    sw x10, 24(sp)            # Save array pointer
    sw x11, 20(sp)            # Save left
    sw x12, 16(sp)            # Save right  
    sw x13, 12(sp)            # Save mid
    sw x14, 8(sp)             # Save i (left array index)
    sw x15, 4(sp)             # Save j (right array index)
    sw x16, 0(sp)             # Save k (merged array index)
    
    # Initialize pointers
    add x14, x0, x11           # x14 = i = left (left subarray index)
    addi x15, x13, 1           # x15 = j = mid + 1 (right subarray index)
    add x16, x0, x11           # x16 = k = left (merged array index)
    
    # Copy data to auxiliary array first
    add x17, x0, x11           # x17 = index for copying
copy_to_aux:
    bgt x17, x12, merge_loop   # if index > right, start merging
    
    # Calculate source and dest addresses
    slli x18, x17, 2           # x18 = index * 4 (byte offset)
    add x19, x10, x18          # x19 = arr + offset (source)
    add x20, x29, x18          # x20 = aux + offset (dest)
    
    lw x21, 0(x19)            # Load from original array
    sw x21, 0(x20)            # Store to auxiliary array
    
    addi x17, x17, 1           # index++
    j copy_to_aux

merge_loop:
    # Check if left subarray is exhausted
    bgt x14, x13, copy_right_remaining
    # Check if right subarray is exhausted  
    bgt x15, x12, copy_left_remaining
    
    # Compare elements from left and right subarrays
    slli x17, x14, 2           # x17 = i * 4
    add x18, x29, x17          # x18 = aux + (i * 4)
    lw x19, 0(x18)            # x19 = aux[i]
    
    slli x17, x15, 2           # x17 = j * 4  
    add x18, x29, x17          # x18 = aux + (j * 4)
    lw x20, 0(x18)            # x20 = aux[j]
    
    # if aux[i] <= aux[j]
    bgt x19, x20, take_right
    
take_left:
    # arr[k] = aux[i]
    slli x17, x16, 2           # x17 = k * 4
    add x18, x10, x17          # x18 = arr + (k * 4)
    sw x19, 0(x18)            # arr[k] = aux[i]
    addi x14, x14, 1           # i++
    j merge_continue
    
take_right:
    # arr[k] = aux[j]
    slli x17, x16, 2           # x17 = k * 4
    add x18, x10, x17          # x18 = arr + (k * 4)  
    sw x20, 0(x18)            # arr[k] = aux[j]
    addi x15, x15, 1           # j++
    
merge_continue:
    addi x16, x16, 1           # k++
    j merge_loop

copy_left_remaining:
    # Copy remaining elements from left subarray
    bgt x14, x13, merge_done   # if i > mid, done
    
    slli x17, x14, 2           # x17 = i * 4
    add x18, x29, x17          # x18 = aux + (i * 4)
    lw x19, 0(x18)            # x19 = aux[i]
    
    slli x17, x16, 2           # x17 = k * 4
    add x18, x10, x17          # x18 = arr + (k * 4)
    sw x19, 0(x18)            # arr[k] = aux[i]
    
    addi x14, x14, 1           # i++
    addi x16, x16, 1           # k++
    j copy_left_remaining

copy_right_remaining:
    # Copy remaining elements from right subarray
    bgt x15, x12, merge_done   # if j > right, done
    
    slli x17, x15, 2           # x17 = j * 4  
    add x18, x29, x17          # x18 = aux + (j * 4)
    lw x19, 0(x18)            # x19 = aux[j]
    
    slli x17, x16, 2           # x17 = k * 4
    add x18, x10, x17          # x18 = arr + (k * 4)
    sw x19, 0(x18)            # arr[k] = aux[j]
    
    addi x15, x15, 1           # j++
    addi x16, x16, 1           # k++
    j copy_right_remaining

merge_done:
    # Restore registers from stack
    lw x16, 0(sp)             # Restore k
    lw x15, 4(sp)             # Restore j
    lw x14, 8(sp)             # Restore i
    lw x13, 12(sp)            # Restore mid
    lw x12, 16(sp)            # Restore right
    lw x11, 20(sp)            # Restore left
    lw x10, 24(sp)            # Restore array pointer
    lw x1, 28(sp)             # Restore return address
    addi sp, sp, 32            # Deallocate stack frame
    
    jalr x0, x1, 0            # Return to caller

# ========== PROGRAM TERMINATION ==========
end_program:
    # Expected final sorted array: [5, 11, 12, 22, 25, 34, 64, 90]
    # Verification registers:
    # x20 = 5, x21 = 11, x22 = 12, x23 = 22
    # x24 = 25, x25 = 34, x26 = 64, x27 = 90
    # x31 = 0xDEAD (completion marker)
    
    # Infinite loop to halt processor
    j end_program