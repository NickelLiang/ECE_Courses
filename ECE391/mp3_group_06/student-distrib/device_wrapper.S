# device_wrapper.S - Set up the keyboard and rtc handler
# #include "multi_terminal.h"

.data
        # use to load runtime info to old
        # Useful offset constants for accessing members of a
        # struct MULTI_TER_INFO_t structure
        EBX_P = 0
        ECX_P = 4
        EDX_P = 8
        ESI_P = 12
        EDI_P = 16
        EBP_P = 20
        EAX_P = 24
        DS_P = 28
        ES_P = 32
        FS_P = 36
        old_EIP_P = 40
        CS_P = 44
        EFLAGS_P = 48
        ESP_P = 52
        SS_P = 56
        K_ESP_P = 60
.text
.globl keyboard_wrapper
.globl rtc_wrapper
.globl pit_wrapper


# the keyboard and rtc wrapper that will call their related handler
keyboard_wrapper:
    cli
    pushal
    call keyboard_interrupt
    popal
    iret

rtc_wrapper:
    cli
    pushal
    call rtc_interrupt
    popal
    iret

pit_wrapper:
    cli
    pushw %fs
    pushw $0
    pushw %es
    pushw $0
    pushw %ds
    pushw $0
    pushl %eax
    pushl %ebp
    pushl %edi
    pushl %esi
    pushl %edx
    pushl %ecx
    pushl %ebx
    pushl %esp


    call pit_interrupt
    cmpl $0, %eax
    je NO_CONTEXT_SHIFT
    # load K_ESP to info table
    leal K_ESP_P(%eax), %edi    # find K_ESP address in info table
    movl $0, %ebx               # find K_ESP offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load K_ESP value on the current stack to edx
    movl %edx, (%edi)           # store the K_ESP value from edx to info table
    # load EBX to info table
    leal EBX_P(%eax), %edi      # find ebx address in info table
    movl $1, %ebx               # find ebx offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load ebx value on the current stack to edx
    movl %edx, (%edi)           # store the ebx value from edx to info table
    # load ECX to info table
    leal ECX_P(%eax), %edi      # find ecx address in info table
    movl $2, %ebx               # find ecx offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load ecx value on the current stack to edx
    movl %edx, (%edi)           # store the ecx value from edx to info table
    # load EDX to info table
    leal EDX_P(%eax), %edi      # find edx address in info table
    movl $3, %ebx               # find edx offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load edx value on the current stack to edx
    movl %edx, (%edi)           # store the edx value from edx to info table
    # load ESI to info table
    leal ESI_P(%eax), %edi      # find esi address in info table
    movl $4, %ebx               # find esi offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load esi value on the current stack to edx
    movl %edx, (%edi)           # store the esi value from edx to info table
    # load EDI to info table
    leal EDI_P(%eax), %edi      # find edi address in info table
    movl $5, %ebx               # find edi offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load edi value on the current stack to edx
    movl %edx, (%edi)           # store the edi value from edx to info table
    # load EBP to info table
    leal EBP_P(%eax), %edi      # find ebp address in info table
    movl $6, %ebx               # find ebp offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load ebp value on the current stack to edx
    movl %edx, (%edi)           # store the ebp value from edx to info table
    # load EAX to info table
    leal EAX_P(%eax), %edi      # find eax address in info table
    movl $7, %ebx               # find eax offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load eax value on the current stack to edx
    movl %edx, (%edi)           # store the eax value from edx to info table
    # load DS to info table
    leal DS_P(%eax), %edi       # find ds address in info table
    movl $8, %ebx               # find ds offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load ds value on the current stack to edx
    movl %edx, (%edi)           # store the ds value from edx to info table
    # load ES to info table
    leal ES_P(%eax), %edi       # find es address in info table
    movl $9, %ebx               # find es offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load es value on the current stack to edx
    movl %edx, (%edi)           # store the es value from edx to info table
    # load FS to info table
    leal FS_P(%eax), %edi       # find fs address in info table
    movl $10, %ebx               # find fs offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load fs value on the current stack to edx
    movl %edx, (%edi)           # store the fs value from edx to info table
    # load old_EIP to info table
    leal old_EIP_P(%eax), %edi  # find old_EIP address in info table
    movl $11, %ebx              # find old_EIP offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load old_EIP value on the current stack to edx
    movl %edx, (%edi)           # store the old_EIP value from edx to info table
    # load CS to info table
    leal CS_P(%eax), %edi       # find cs address in info table
    movl $12, %ebx              # find cs offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load cs value on the current stack to edx
    movl %edx, (%edi)           # store the cs value from edx to info table
    # load EFLAGS to info table
    leal EFLAGS_P(%eax), %edi   # find EFLAGS address in info table
    movl $13, %ebx              # find EFLAGS offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load EFLAGS value on the current stack to edx
    movl %edx, (%edi)           # store the EFLAGS value from edx to info table
    # load ESP to info table
    leal ESP_P(%eax), %edi      # find ESP address in info table
    movl $14, %ebx              # find ESP offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load ESP value on the current stack to edx
    movl %edx, (%edi)           # store the ESP value from edx to info table
    # load SS to info table
    leal SS_P(%eax), %edi       # find SS address in info table
    movl $15, %ebx              # find SS offset on the current stack
    movl (%esp, %ebx, 4), %edx  # load SS value on the current stack to edx
    movl %edx, (%edi)           # store the SS value from edx to info table
    # tell switch_terminal to switch to Dest_ter
    pushl $0
    call switch_context
    # naive fault, after calling switch_terminal, it should never return, unless it failed
    popl %eax  # pop the parameter
    # return on normal keyboard interrupt
    NO_CONTEXT_SHIFT:
    popl %esp
    popl %ebx
    popl %ecx
    popl %edx
    popl %esi
    popl %edi
    popl %ebp
    popl %eax
    popw %ds
    popw %ds
    popw %es
    popw %es
    popw %fs
    popw %fs
    iret
