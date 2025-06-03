.globl dump_backtrace
.type dump_backtrace, @function
dump_backtrace:

.section .rodata
backtrace_format_str: .asciz "%3ld: [%lx] %s () %s\n"
unknown_sym: .asciz "??"
unknown_file: .asciz "??"

.section .text

dump_backtrace:
    # Function prologue
    pushq %rbp
    movq %rsp, %rbp
   
    # Allocate 64 bytes on stack (32 for Dl_info + 32 for alignment/safety)

   
    # Save callee-saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
   
    subq $(16*8), %rsp
    # Initialize depth counter
    xorq %r12, %r12          # r12 = depth = 0
   
    # Start with current frame pointer (don't skip caller)
    movq %rbp, %r13          # r13 = current frame pointer

backtrace_loop:    
   
    # Get return address from current frame
    movq 8(%r13), %r14      # r14 = return address (at rbp + 8)
    testq %r14, %r14
    jz print_entry
 
   
    # Call dladdr(return_addr, &dl_info)
    movq %r14, %rdi          # first arg: return address
    leaq -64(%rbp), %rsi     # second arg: address of dl_info on stack
    call dladdr@PLT
   
    # Check if dladdr succeeded
    testq %rax, %rax
    jz print_unknown
   
    # get symbol name
    movq -48(%rbp), %r15     # r15 = dli_sname (symbol name at offset 16 from dl_info)
    testq %r15, %r15
    jnz got_symbol_name
    leaq unknown_sym(%rip), %r15
   
got_symbol_name:
    #get filename
    movq -64(%rbp), %rbx     # rbx = dli_fname (file name at offset 0 from dl_info)
    testq %rbx, %rbx
    jnz got_file_name
    leaq unknown_file(%rip), %rbx
    jmp print_entry
   
got_file_name:
    jmp print_entry

print_unknown:
    # dladdr failed, use unknown symbols
    leaq unknown_sym(%rip), %r15
    leaq unknown_file(%rip), %rbx

print_entry:
    # Call printf with format: "%3ld: [%lx] %s () %s\n"
    leaq backtrace_format_str(%rip), %rdi  # format string
    movq %r12, %rsi                        # depth
    movq %r14, %rdx                        # return address
    movq %r15, %rcx                        # symbol name
    movq %rbx, %r8                         # file name
    xorq %rax, %rax                        # no vector registers used
    call printf@PLT
   
    # Move to next frame without printing
    movq (%r13), %r13            # r13 = next frame pointer
    incq %r12                    # increment depth
   
    jmp backtrace_loop

backtrace_done:
    # clean up stack
    addq $64, %rsp

    #restore callee-saved registers
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx

    # Function epilogue
    movq %rbp, %rsp
    popq %rbp
    ret