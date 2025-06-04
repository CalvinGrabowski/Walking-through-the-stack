.globl dump_backtrace
.type dump_backtrace, @function

.section .rodata
backtrace_format_str: .asciz "%3ld: [%lx] %s () %s\n"
unknown_sym: .asciz "??"
unknown_file: .asciz "??"

.section .text
dump_backtrace:
    # Function prologue
    pushq %rbp
    movq %rsp, %rbp
   
    # Save callee-saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15
   
    # Allocate 64 bytes on stack for Dl_info + alignment
    subq $64, %rsp
    
    # Initialize depth counter
    xorq %r12, %r12          # r12 = depth = 0
   
    # Start with current frame pointer
    movq %rbp, %r13          # r13 = current frame pointer

backtrace_loop:    
    # Check maximum depth limit (prevent runaway)
    cmpq $50, %r12
    jge backtrace_done
    
    # Check if frame pointer is valid
    testq %r13, %r13
    jz backtrace_done
    
    # Basic sanity check - frame pointer should be reasonable
    cmpq $0x1000, %r13       # minimum reasonable address
    jb backtrace_done
    
    # Get return address from current frame
    movq 8(%r13), %r14       # r14 = return address (at rbp + 8)
    
    # Check if return address is valid
    testq %r14, %r14
    jz backtrace_done        # Exit if no return address
    
    # Basic sanity check on return address
    cmpq $0x1000, %r14
    jb backtrace_done
   
    # Call dladdr(return_addr, &dl_info)
    movq %r14, %rdi          # first arg: return address
    leaq -64(%rbp), %rsi     # second arg: address of dl_info on stack
    call dladdr@PLT
   
    # Check if dladdr succeeded
    testq %rax, %rax
    jz print_unknown
   
    # Get symbol name (dli_sname is at offset 16 from dl_info)
    movq -48(%rbp), %r15     # r15 = dli_sname 
    testq %r15, %r15
    jnz got_symbol_name
    leaq unknown_sym(%rip), %r15
   
got_symbol_name:
    # Get filename (dli_fname is at offset 0 from dl_info)
    movq -64(%rbp), %rbx     # rbx = dli_fname
    testq %rbx, %rbx
    jnz print_entry
    leaq unknown_file(%rip), %rbx
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
   
    # Move to next frame
    movq (%r13), %r13        # r13 = next frame pointer (previous rbp)
    incq %r12                # increment depth
   
    # Continue loop
    jmp backtrace_loop

backtrace_done:
    # Clean up stack
    addq $64, %rsp
    
    # Restore callee-saved registers
    popq %r15
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    
    # Function epilogue
    movq %rbp, %rsp
    popq %rbp
    ret