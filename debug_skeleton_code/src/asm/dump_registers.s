.extern _debug_dump_registers
.globl dump_registers
.type dump_registers, @function
dump_registers:
subq $(16*8), %rsp
movq %rsp, %rdi
call _debug_dump_registers
addq $(16*8), %rsp
ret
