.section .bss
arr: .space 8000        
result: .space 8000     
stk: .space 8000        
stk_top: .space 8       
digitbuf: .space 32     

.section .rodata
space_str: .string " "
newline_str: .string "\n"
minus1_str: .string "-1"

.section .text
.global _start

_start:
    # save the input arguments from the command line
    mv s0,a0            
    mv s1,a1            
    addi s2,s0,-1       # count how many numbers the user gave us

    # converting text arguments into a number array
    li s3,0
read_loop:
    bge s3,s2,read_done
    addi t0,s3,1        
    slli t0,t0,3        
    add t0,s1,t0
    ld a0,0(t0)         
    call atoi           
    slli t1,s3,3
    la t2,arr
    add t2,t2,t1
    sd a0,0(t2)         
    addi s3,s3,1
    j read_loop
read_done:

    # set every answer to -1
    li s3,0
fill_loop:
    bge s3,s2,fill_done
    slli t0,s3,3
    la t1,result
    add t1,t1,t0
    li t2,-1
    sd t2,0(t1)
    addi s3,s3,1
    j fill_loop
fill_done:

    # set up stack as empty
    la t0,stk_top
    li t1,-1
    sd t1,0(t0)

    addi s3,s2,-1       
mono_loop:
    bltz s3,mono_done

pop_while:
    # check if the stack is empty
    la t0,stk_top
    ld t1,0(t0)
    bltz t1,pop_done    

    # look at the number represented by the top of the stack
    slli t2,t1,3
    la t3,stk
    add t3,t3,t2
    ld t2,0(t3)         
    slli t2,t2,3
    la t3,arr
    add t3,t3,t2
    ld t2,0(t3)         

    # compare it to our current number
    slli t3,s3,3
    la t4,arr
    add t4,t4,t3
    ld t3,0(t4)         

    # if the stack number is smaller pop it
    bgt t2,t3,pop_done
    la t0,stk_top
    ld t1,0(t0)
    addi t1,t1,-1
    sd t1,0(t0)
    j pop_while
pop_done:

    # if we found a bigger number in the stack save its index as our answer
    la t0,stk_top
    ld t1,0(t0)
    bltz t1,just_push   

    slli t2,t1,3
    la t3,stk
    add t3,t3,t2
    ld t2,0(t3)         
    slli t3,s3,3
    la t4,result
    add t4,t4,t3
    sd t2,0(t4)         

just_push:
    # put the current number's index onto the stack
    la t0,stk_top
    ld t1,0(t0)
    addi t1,t1,1
    sd t1,0(t0)
    slli t2,t1,3
    la t3,stk
    add t3,t3,t2
    sd s3,0(t3)         

    addi s3,s3,-1       
    j mono_loop
mono_done:

    # Step 4: Print the results to the screen
    li s3,0
print_loop:
    bge s3,s2,print_done

    # Put a space between numbers (but not before the first one)
    beqz s3,skip_space  
    li a7,64
    li a0,1
    la a1,space_str
    li a2,1
    ecall
skip_space:

    slli t0,s3,3
    la t1,result
    add t1,t1,t0
    ld a0,0(t1)
    call print_int

    addi s3,s3,1
    j print_loop
print_done:

    # Finish with a newline and exit
    li a7,64
    li a0,1
    la a1,newline_str
    li a2,1
    ecall

    li a7,93
    li a0,0
    ecall

# Logic to turn a string like "123" into the actual integer 123
atoi:
    mv t0,a0
    li a0,0
atoi_loop:
    lb t1,0(t0)
    beqz t1,atoi_done
    addi t1,t1,-48      
    li t2,10
    mul a0,a0,t2        
    add a0,a0,t1        
    addi t0,t0,1
    j atoi_loop
atoi_done:
    ret

# Logic to turn a number back into text so it can be printed
print_int:
    addi sp,sp,-48
    sd ra,40(sp)
    sd s0,32(sp)
    sd s1,24(sp)

    li t0,-1
    bne a0,t0,not_neg1
    li a7,64
    li a0,1
    la a1,minus1_str
    li a2,2
    ecall
    j print_int_done

not_neg1:
    mv s0,a0
    addi s1,sp,0        
    li t2,0             

    bnez s0,build_digits
    li t0,48            
    sb t0,0(s1)
    li t2,1
    j do_print

build_digits:
    # Divide by 10 repeatedly to get each digit
digit_extract:
    beqz s0,digits_done
    li t0,10
    rem t1,s0,t0        
    div s0,s0,t0        
    addi t1,t1,48       
    add t3,s1,t2
    sb t1,0(t3)
    addi t2,t2,1
    j digit_extract
digits_done:

    # Flip the digits because they were extracted backwards
    mv t3,s1
    addi t4,s1,-1
    add t4,t4,t2
reverse:
    bge t3,t4,do_print
    lb t5,0(t3)
    lb t6,0(t4)
    sb t6,0(t3)
    sb t5,0(t4)
    addi t3,t3,1
    addi t4,t4,-1
    j reverse

do_print:
    li a7,64
    li a0,1
    mv a1,s1
    mv a2,t2
    ecall

print_int_done:
    ld ra,40(sp)
    ld s0,32(sp)
    ld s1,24(sp)
    addi sp,sp,48
    ret
