.globl dump_backtrace
.type dump_backtrace, @function
dump_backtrace:
ret


.section .rodata
backtrace_format_str:
.asciz "%3ld: [%lx] %s () %s\n"
