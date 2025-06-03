.extern _debug_dump_registers
.globl dump_registers
.type dump_registers, @function
dump_registers:

movq $5, %rax
movq $27, %rbx

movq $24, %r10
movq $2, %rsi
movq $13, %r15

# push %rsp
#push %rbp and not use it later
push %r15
push %r14
push %r13
push %r12
push %r11
push %r10
push %r9
push %r8

# count this difference
#push %rsp
leaq (-64)(%rsp), %r8   
push %r8

push %rbp
push %rdi
push %rsi
push %rdx
push %rcx
push %rbx
push %rax


    
subq $(16*8), %rsp
movq %rsp, %rdi
call _debug_dump_registers
addq $(16*8), %rsp

pop %rax
pop %rbx
pop %rcx
pop %rdx
pop %rsi
pop %rdi
pop %rbp
pop %r8         # restore original rsp saved on stack
pop %r8         # restore r8 pushed earlier
pop %r9
pop %r10
pop %r11
pop %r12
pop %r13
pop %r14
pop %r15

ret