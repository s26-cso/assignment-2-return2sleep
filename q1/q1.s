.global make_node
make_node: 
    addi x2,x2,-16
    sw x1,12(x2)
    sw x10,8(x2) # saving val
    addi x10,x0,12 # 4 bytes for val 4 for node* left 4 for node* right
    call malloc
    lw x11,8(x2) # getting val back from stack
    sw x11,0(x10) # node->val=val
    sw x0,4(x10)  # node->left-NULL
    sw x0,8(x10) # node->right=NULL
    lw x1,12(x2) # getting the return address back
    addi x2,x2,16
    jalr x0,x1,0

.global insert
insert:
    addi x2,x2,-16
    sw x1,12(x2)
    sw x10,8(x2) # saving root
    sw x11,4(x2) # saving val
    bne x10,x0,insert_notnull

    addi x10,x11,0 
    call make_node
    beq  x0,x0,insert_done

insert_notnull:
    lw x12,0(x10) # root->val
    lw x11,4(x2) # getting val from stack
    blt x11,x12,insert_left
    blt x12,x11,insert_right
    beq x0,x0,insert_return_root # val==root->val
 
insert_left:
    lw x5,8(x2) # getting root from stack
    lw x10,4(x5) # root->left
    lw x11,4(x2) # val
    call insert
    lw x5,8(x2) # root
    sw x10,4(x5) # root->left=result
    beq x0,x0,insert_return_root
 
insert_right:
    lw x5,8(x2) # root
    lw x10,8(x5) # root->right
    lw x11,4(x2) # val
    call insert
    lw x5,8(x2) # root
    sw x10,8(x5) # root->right=result
 
insert_return_root:
    lw x10,8(x2) # return root
 
insert_done:
    lw x1,12(x2)
    addi x2,x2,16
    jalr x0,x1,0

.global get
get:
    addi x2,x2,-16
    sw x1,12(x2)
    sw x11,8(x2) 
    beq x10,x0,get_null # root==NULL
 
    lw x12,0(x10) # root->val
    lw x11,8(x2) # val
    beq x11,x12,get_done # found
 
    blt x11,x12,get_left
 
    # go right
    lw x10,8(x10) # root->right
    lw x11,8(x2) # val
    call get
    beq  x0,x0,get_done
 
get_left:
    lw x10,4(x10) # root->left
    lw x11,8(x2) # val
    call get
    beq x0,x0,get_done
 
get_null:
    addi x10,x0,0 # return NULL
 
get_done:
    lw x1,12(x2)
    addi x2,x2,16
    jalr x0,x1,0

.globl getAtMost
getAtMost:
    addi x2,x2,-16
    sw x1,12(x2)
    sw x10,8(x2) # saving val
    sw x11,4(x2) # saving root
 
    beq x11,x0,getatmost_null # root==NULL
 
    lw x12,0(x11) # root->val
    lw x10,8(x2) # val
 
    beq x10,x12,getatmost_exact # val==root->val
    blt x10,x12,getatmost_left # val<root->val
 
    # val>root->val
    lw x11,8(x11) # root->right
    lw x10,8(x2) # val
    call getAtMost
 
    addi x13,x0,-1
    bne x10,x13,getatmost_done # result!=-1
 
    lw x5,4(x2) # root
    lw x10,0(x5) # root->val
    beq x0,x0,getatmost_done
 
getatmost_left:
    lw x11,4(x11) # root->left
    lw x10,8(x2) # val
    call getAtMost
    beq x0,x0,getatmost_done
 
getatmost_exact:
    lw x10,8(x2) # return val
    beq x0,x0,getatmost_done
 
getatmost_null:
    addi x10,x0,-1 # return -1
 
getatmost_done:
    lw x1,12(x2)
    addi x2,x2,16
    jalr x0,x1,0
