.section .rodata
filename: .string "input.txt"
yes_msg: .string "Yes\n"
no_msg: .string "No\n"

.section .bss
lbuf: .space 1  # holds the left character
rbuf: .space 1  # holds the right character

.section .text
.global _start

_start:
    # open input.txt
    li a7,56
    li a0,-100
    la a1,filename
    li a2,0
    li a3,0
    ecall
    mv s0,a0  # save the file descriptor in s0

    # jump to the end of file
    li a7,62
    mv a0,s0
    li a1,0
    li a2,2         # seek end
    ecall
    mv s1,a0        # s1=file size

    beqz s1,is_palindrome   #trivial case

    # peek at the last character if it's a newline, ignore it
    addi t0,s1,-1
    li a7,62
    mv a0,s0
    mv a1,t0
    li a2,0
    ecall
    li a7,63
    mv a0,s0
    la a1,lbuf
    li a2,1
    ecall
    la t0,lbuf
    lb t1,0(t0)
    li t2,10        # '\n'
    bne t1,t2,set_ptrs
    addi s1,s1,-1   # chop off the newline

set_ptrs:
    li s2,0         # left pointer starts at the beginning
    addi s3,s1,-1   # right pointer starts at the end

loop:
    # pointers have met in the middle, everything matched
    bge s2,s3,is_palindrome

    # go to the left pointer and read one character
    li a7,62
    mv a0,s0
    mv a1,s2
    li a2,0
    ecall
    li a7,63
    mv a0,s0
    la a1,lbuf
    li a2,1
    ecall

    # go to the right pointer and read one character
    li a7,62
    mv a0,s0
    mv a1,s3
    li a2,0
    ecall
    li a7,63
    mv a0,s0
    la a1,rbuf
    li a2,1
    ecall

    # check if the two characters match
    la t0,lbuf
    lb s4,0(t0)
    la t0,rbuf
    lb s5,0(t0)

    bne s4,s5,not_palindrome   # mismatch found

    # move both pointers inward and check the next pair
    addi s2,s2,1
    addi s3,s3,-1
    j loop

is_palindrome:
    li a7,64
    li a0,1
    la a1,yes_msg
    li a2,4
    ecall
    j done

not_palindrome:
    li a7,64
    li a0,1
    la a1,no_msg
    li a2,3
    ecall

done:
    li a7,93 
    li a0,0
    ecall
