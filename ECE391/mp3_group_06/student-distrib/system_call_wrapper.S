# system_call_wrapper.S - Set up the system call linkage

.text
.globl system_call_wrapper

system_call_wrapper:
    cli
    cmpl $1, %eax
    jl fail
    cmpl $10, %eax
    jg fail             # check whether the system call number is valid
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %ebp
    pushl %esi
    pushl %edi
    pushw %ss
    pushw %ds
    pushw %es
    pushw %fs
    pushw %gs
    pushl %esp              # push the register
    pushfl
    pushl %edx
    pushl %ecx
    pushl %ebx              # push the argument
    call *system_call_jump_table(, %eax, 4)         # jump to the correct system call
    addl $12, %esp          # pop the argument
    popfl
    popl %esp
    popw %gs
    popw %fs
    popw %es
    popw %ds
    popw %ss
    popl %edi
    popl %esi
    popl %ebp
    popl %edx
    popl %ecx
    popl %ebx           # pop the register
    iret
fail:
    movl $-1, %eax
    iret
system_call_jump_table:
    .long 0, halt, execute, read, write, open, close, getargs, vidmap, set_handler, sigreturn
