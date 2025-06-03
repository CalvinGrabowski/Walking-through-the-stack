.extern _debug_dump_registers
.globl dump_registers
.type dump_registers, @function
dump_registers:

movq $5, %rax
movq $7, %rbx
movq $3, %rcx
movq $-4, %rdx

movq $4, %r10
movq $2, %r8
movq $3, %r9
movq $11, %rsi
movq $-14, %r14
movq $15, %r15
movq $24, %rdi

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

# Current RSP + 8 bytes (for each register pushed) + 8 bytes (return address)
movq %rsp, %r8
addq $(8*8 + 8), %r8
push %r8            # Push original RSP


push %rbp
push %rdi
push %rsi
push %rdx
push %rcx
push %rbx
push %rax


    
#subq $(16*8), %rsp
movq %rsp, %rdi
call _debug_dump_registers
#addq $(16*8), %rsp

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