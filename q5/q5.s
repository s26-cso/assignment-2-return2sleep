.section .rodata
filename: .string "input.txt"
yes_msg: .string "Yes\n"
no_msg: .string "No\n"

.section .bss
lbuf: .space 1
rbuf: .space 1

.section .text
.global _start

_start:
    # Open input.txt (sys_openat: 56)
    li a7, 56
    li a0, -100     # AT_FDCWD
    la a1, filename
    li a2, 0        # O_RDONLY
    li a3, 0
    ecall
    bltz a0, not_palindrome # Exit if file can't be opened
    mv s0, a0       # s0 = file descriptor

    # Find file size (sys_lseek: 62)
    li a7, 62
    mv a0, s0
    li a1, 0
    li a2, 2        # SEEK_END
    ecall
    mv s1, a0       # s1 = total file size

    # Handle empty file or single char
    li t0, 1
    ble s1, t0, is_palindrome

    # Adjust for trailing newline if present
    li a7, 62
    mv a0, s0
    li a1, -1
    li a2, 2        # SEEK_END (1 byte back from end)
    ecall
    
    li a7, 63       # sys_read
    mv a0, s0
    la a1, rbuf
    li a2, 1
    ecall
    
    lb t0, rbuf
    li t1, 10       # ASCII newline
    bne t0, t1, init_pointers
    addi s1, s1, -1 # Exclude newline from palindrome check

init_pointers:
    li s2, 0        # s2 = Left pointer index
    addi s3, s1, -1 # s3 = Right pointer index (last valid char)

loop:
    bge s2, s3, is_palindrome

    # Read character at Left pointer
    li a7, 62
    mv a0, s0
    mv a1, s2
    li a2, 0        # SEEK_SET
    ecall

    li a7, 63
    mv a0, s0
    la a1, lbuf
    li a2, 1
    ecall
    lb s4, lbuf

    # Read character at Right pointer
    li a7, 62
    mv a0, s0
    mv a1, s3
    li a2, 0        # SEEK_SET
    ecall

    li a7, 63
    mv a0, s0
    la a1, rbuf
    li a2, 1
    ecall
    lb s5, rbuf

    # Compare characters
    bne s4, s5, not_palindrome

    addi s2, s2, 1
    addi s3, s3, -1
    j loop

is_palindrome:
    li a7, 64       # sys_write
    li a0, 1        # stdout
    la a1, yes_msg
    li a2, 4
    ecall
    j exit

not_palindrome:
    li a7, 64       # sys_write
    li a0, 1        # stdout
    la a1, no_msg
    li a2, 3
    ecall

exit:
    # Close file
    li a7, 57       # sys_close
    mv a0, s0
    ecall

    # Exit program
    li a7, 93       # sys_exit
    li a0, 0
    ecall