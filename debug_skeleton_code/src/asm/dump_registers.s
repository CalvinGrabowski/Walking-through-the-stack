.extern _debug_dump_registers
.globl dump_registers
.type dump_registers, @function
dump_registers:

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
    push %r8            # Push the original RSP


    push %rbp
    push %rdi
    push %rsi
    push %rdx
    push %rcx
    push %rbx
    push %rax

    # this puts the stack pointer as the first and only argument for _debug_dump_registers
    movq %rsp, %rdi
    call _debug_dump_registers

    pop %rax
    pop %rbx
    pop %rcx
    pop %rdx
    pop %rsi
    pop %rdi
    pop %rbp
    pop %r8         # takes off the copy of the original rbp
    pop %r8         # takes off r8
    pop %r9
    pop %r10
    pop %r11
    pop %r12
    pop %r13
    pop %r14
    pop %r15

    ret