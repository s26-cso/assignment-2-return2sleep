.section .bss
arr: .space 8000        
result: .space 8000     
stk: .space 8000        
stk_top: .space 8       

.section .rodata
space_str: .string " "
newline_str: .string "\n"
minus1_str: .string "-1"

.section .text
.global _start

_start:
    mv s0, a0            # argc
    mv s1, a1            # argv
    addi s2, s0, -1      # s2 = number of elements (argc - 1)
    
    # If no arguments, just exit
    blez s2, exit_program

    # Convert arguments to integer array
    li s3, 0
read_loop:
    bge s3, s2, read_done
    addi t0, s3, 1        
    slli t0, t0, 3        # index * 8
    add t0, s1, t0
    ld a0, 0(t0)         
    call atoi           
    slli t1, s3, 3
    la t2, arr
    add t2, t2, t1
    sd a0, 0(t2)         
    addi s3, s3, 1
    j read_loop
read_done:

    # Initialize results with -1
    li s3, 0
fill_loop:
    bge s3, s2, fill_done
    slli t0, s3, 3
    la t1, result
    add t1, t1, t0
    li t2, -1
    sd t2, 0(t1)
    addi s3, s3, 1
    j fill_loop
fill_done:

    # Monotonic Stack Logic
    la t0, stk_top
    li t1, -1
    sd t1, 0(t0)        # stack_top = -1 (empty)

    addi s3, s2, -1     # i = n - 1
mono_loop:
    bltz s3, mono_done

pop_while:
    la t0, stk_top
    ld t1, 0(t0)
    bltz t1, pop_done   # stack empty

    # Get arr[stack.top()]
    slli t2, t1, 3
    la t3, stk
    add t3, t3, t2
    ld t2, 0(t3)        # t2 = index from stack
    slli t2, t2, 3
    la t3, arr
    add t3, t3, t2
    ld t2, 0(t3)        # t2 = arr[stack.top()]

    # Get arr[i]
    slli t3, s3, 3
    la t4, arr
    add t4, t4, t3
    ld t3, 0(t4)        # t3 = arr[i]

    # while (!stack.empty() && arr[stack.top()] <= arr[i])
    bgt t2, t3, pop_done
    la t0, stk_top
    ld t1, 0(t0)
    addi t1, t1, -1
    sd t1, 0(t0)        # pop()
    j pop_while
pop_done:

    # if (!stack.empty()) result[i] = stack.top()
    la t0, stk_top
    ld t1, 0(t0)
    bltz t1, push_current

    slli t2, t1, 3
    la t3, stk
    add t3, t3, t2
    ld t2, 0(t3)        # t2 = stack.top()
    slli t3, s3, 3
    la t4, result
    add t4, t4, t3
    sd t2, 0(t4)        # result[i] = t2

push_current:
    la t0, stk_top
    ld t1, 0(t0)
    addi t1, t1, 1
    sd t1, 0(t0)
    slli t2, t1, 3
    la t3, stk
    add t3, t3, t2
    sd s3, 0(t3)        # stack.push(i)

    addi s3, s3, -1
    j mono_loop
mono_done:

    # Printing output
    li s3, 0
print_loop:
    bge s3, s2, print_done
    beqz s3, skip_space
    li a7, 64
    li a0, 1
    la a1, space_str
    li a2, 1
    ecall
skip_space:
    slli t0, s3, 3
    la t1, result
    add t1, t1, t0
    ld a0, 0(t1)
    call print_int
    addi s3, s3, 1
    j print_loop
print_done:

    li a7, 64
    li a0, 1
    la a1, newline_str
    li a2, 1
    ecall

exit_program:
    li a7, 93
    li a0, 0
    ecall

atoi:
    mv t0, a0
    li a0, 0
atoi_loop:
    lb t1, 0(t0)
    beqz t1, atoi_ret
    li t2, 48
    blt t1, t2, atoi_ret
    li t2, 57
    bgt t1, t2, atoi_ret
    addi t1, t1, -48
    li t2, 10
    mul a0, a0, t2
    add a0, a0, t1
    addi t0, t0, 1
    j atoi_loop
atoi_ret:
    ret

print_int:
    addi sp, sp, -64
    sd ra, 56(sp)
    sd s0, 48(sp)
    sd s1, 40(sp)
    
    li t0, -1
    bne a0, t0, pos_print
    li a7, 64
    li a0, 1
    la a1, minus1_str
    li a2, 2
    ecall
    j print_exit

pos_print:
    mv s0, a0
    addi s1, sp, 32     # local buffer in stack
    li t2, 0            # length
    bnez s0, extract
    li t0, 48
    sb t0, 0(s1)
    li t2, 1
    j actual_write

extract:
    beqz s0, reverse_prep
    li t0, 10
    rem t1, s0, t0
    div s0, s0, t0
    addi t1, t1, 48
    add t3, s1, t2
    sb t1, 0(t3)
    addi t2, t2, 1
    j extract

reverse_prep:
    mv t3, s1           # start
    add t4, s1, t2
    addi t4, t4, -1     # end
rev_loop:
    bge t3, t4, actual_write
    lb t5, 0(t3)
    lb t6, 0(t4)
    sb t6, 0(t3)
    sb t5, 0(t4)
    addi t3, t3, 1
    addi t4, t4, -1
    j rev_loop

actual_write:
    li a7, 64
    li a0, 1
    mv a1, s1
    mv a2, t2
    ecall

print_exit:
    ld ra, 56(sp)
    ld s0, 48(sp)
    ld s1, 40(sp)
    addi sp, sp, 64
    ret