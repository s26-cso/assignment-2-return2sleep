.global make_node
make_node: 
    addi x2,x2,-32
    sd x1,24(x2)
    sd x10,16(x2) # saving val
    addi x10,x0,24 # 4 bytes for val + 4 pad + 8 for node* left + 8 for node* right
    call malloc
    ld x11,16(x2) # getting val back from stack
    sw x11,0(x10) # node->val=val
    sd x0,8(x10)  # node->left=NULL
    sd x0,16(x10) # node->right=NULL
    ld x1,24(x2) # getting the return address back
    addi x2,x2,32
    jalr x0,x1,0

.global insert
insert:
    addi x2,x2,-32
    sd x1,24(x2)
    sd x10,16(x2) # saving root
    sd x11,8(x2) # saving val
    bne x10,x0,insert_notnull

    addi x10,x11,0 
    call make_node
    beq  x0,x0,insert_done

insert_notnull:
    lw x12,0(x10) # root->val
    ld x11,8(x2) # getting val from stack
    blt x11,x12,insert_left
    blt x12,x11,insert_right
    beq x0,x0,insert_return_root # val==root->val
 
insert_left:
    ld x5,16(x2) # getting root from stack
    ld x10,8(x5) # root->left
    ld x11,8(x2) # val
    call insert
    ld x5,16(x2) # root
    sd x10,8(x5) # root->left=result
    beq x0,x0,insert_return_root
 
insert_right:
    ld x5,16(x2) # root
    ld x10,16(x5) # root->right
    ld x11,8(x2) # val
    call insert
    ld x5,16(x2) # root
    sd x10,16(x5) # root->right=result
 
insert_return_root:
    ld x10,16(x2) # return root
 
insert_done:
    ld x1,24(x2)
    addi x2,x2,32
    jalr x0,x1,0

.global get
get:
    addi x2,x2,-32
    sd x1,24(x2)
    sd x11,16(x2) 
    beq x10,x0,get_null # root==NULL
 
    lw x12,0(x10) # root->val
    ld x11,16(x2) # val
    beq x11,x12,get_done # found
 
    blt x11,x12,get_left
 
    # go right
    ld x10,16(x10) # root->right
    ld x11,16(x2) # val
    call get
    beq  x0,x0,get_done
 
get_left:
    ld x10,8(x10) # root->left
    ld x11,16(x2) # val
    call get
    beq x0,x0,get_done
 
get_null:
    addi x10,x0,0 # return NULL
 
get_done:
    ld x1,24(x2)
    addi x2,x2,32
    jalr x0,x1,0

.globl getAtMost
getAtMost:
    addi x2,x2,-32
    sd x1,24(x2)
    sd x10,16(x2) # saving val
    sd x11,8(x2) # saving root
 
    beq x11,x0,getatmost_null # root==NULL
 
    lw x12,0(x11) # root->val
    ld x10,16(x2) # val
 
    beq x10,x12,getatmost_exact # val==root->val
    blt x10,x12,getatmost_left # val<root->val
 
    # val>root->val
    ld x11,8(x11) # root->right
    ld x10,16(x2) # val
    call getAtMost
 
    addi x13,x0,-1
    bne x10,x13,getatmost_done # result!=-1
 
    ld x5,8(x2) # root
    lw x10,0(x5) # root->val
    beq x0,x0,getatmost_done
 
getatmost_left:
    ld x11,8(x11) # root->left
    ld x10,16(x2) # val
    call getAtMost
    beq x0,x0,getatmost_done
 
getatmost_exact:
    ld x10,16(x2) # return val
    beq x0,x0,getatmost_done
 
getatmost_null:
    addi x10,x0,-1 # return -1
 
getatmost_done:
    ld x1,24(x2)
    addi x2,x2,32
    jalr x0,x1,0
