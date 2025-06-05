.globl dump_backtrace
.type dump_backtrace, @function

.section .rodata
backtrace_format_str: .asciz "%3ld: [%lx] %s () %s\n"
unknown_sym: .asciz "??"
unknown_file: .asciz "??"

.section .text
dump_backtrace:
    # stores base pointer
    pushq %rbp
    movq %rsp, %rbp
    
    
    # Allocate 64 bytes on stack for Dl_info + alignment
    subq $64, %rsp
    
    # Initialize depth counter
    xorq %r12, %r12          # r12 = depth = 0
    
    # Start with current frame pointer (don't skip caller)
    movq %rbp, %r13          # r13 = current frame pointer

backtrace_loop:    
    # Check if frame pointer is valid
    testq %r13, %r13
    jz backtrace_done
    
    # Get return address from current frame
    movq 8(%r13), %r14       # r14 = return address (at rbp + 8)
    
    # Check if return address is valid
    testq %r14, %r14
    jz backtrace_done        # Exit if no return address
    
    # Call dladdr(return_addr, &dl_info)
    movq %r14, %rdi          # first arg: return address
    leaq -64(%rbp), %rsi     # second arg: address of dl_info on stack
    call dladdr
    
    # get symbol name 
    movq -48(%rbp), %r15     # r15 = dli_sname (symbol name at offset 16 from dl_info)
    
    
get_file_name:
    # get filename 
    movq -64(%rbp), %rbx     # rbx = dli_fname (file name at offset 0 from dl info)
    testq %rbx, %rbx
    jnz print_entry
    leaq unknown_file(%rip), %rbx
    jmp print_entry
    

print_entry:
    # Call printf with format: "%3ld: [%lx] %s () %s\n"
    leaq backtrace_format_str(%rip), %rdi   # format string
    movq %r12, %rsi                         # depth
    movq %r14, %rdx                         # return address
    movq %r15, %rcx                         # symbol name
    movq %rbx, %r8                          # file name
    xorq %rax, %rax                         # no vector registers used
    call printf
    
    # Move to next frame w/o printing
    movq (%r13), %r13        # r13 = next frame pointer
    incq %r12                # increment depth
    
    # continue the looping
    jmp backtrace_loop

backtrace_done:
    # cleans up stack
    addq $64, %rsp
    
    # restores rbp and returns
    leave
    ret