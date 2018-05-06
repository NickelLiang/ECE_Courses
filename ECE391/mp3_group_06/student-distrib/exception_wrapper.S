# exception_wrapper.S - Set up all the exception handler wrapper

.text
.globl exception_DE_wrapper
.globl exception_DB_wrapper
.globl exception_NMI_wrapper
.globl exception_BP_wrapper
.globl exception_OF_wrapper
.globl exception_BR_wrapper
.globl exception_UD_wrapper
.globl exception_NM_wrapper
.globl exception_DF_wrapper
.globl exception_CSO_wrapper
.globl exception_TS_wrapper
.globl exception_NP_wrapper
.globl exception_SS_wrapper
.globl exception_GP_wrapper
.globl exception_PF_wrapper
.globl exception_MF_wrapper
.globl exception_AC_wrapper
.globl exception_MC_wrapper
.globl exception_XF_wrapper
.globl unkown_int_wrapper

# wrappers to call the related functions to halt when exception or interruption happens

exception_DE_wrapper:
    pushal
    call exception_DE
    popal
    iret

exception_DB_wrapper:
    pushal
    call exception_DB
    popal
    iret

exception_NMI_wrapper:
    pushal
    call exception_NMI
    popal
    iret

exception_BP_wrapper:
    pushal
    call exception_BP
    popal
    iret

exception_OF_wrapper:
    pushal
    call exception_OF
    popal
    iret

exception_BR_wrapper:
    pushal
    call exception_BR
    popal
    iret

exception_UD_wrapper:
    pushal
    call exception_UD
    popal
    iret

exception_NM_wrapper:
    pushal
    call exception_NM
    popal
    iret

exception_DF_wrapper:
    pushal
    call exception_CSO
    popal
    iret

exception_CSO_wrapper:
    pushal
    call exception_CSO
    popal
    iret

exception_TS_wrapper:
    pushal
    call exception_TS
    popal
    iret

exception_NP_wrapper:
    pushal
    call exception_NP
    popal
    iret

exception_SS_wrapper:
    pushal
    call exception_SS
    popal
    iret

exception_GP_wrapper:
    pushal
    call exception_GP
    popal
    iret

exception_PF_wrapper:
    pushal
    call exception_PF
    popal
    iret

exception_MF_wrapper:
    pushal
    call exception_MF
    popal
    iret

exception_AC_wrapper:
    pushal
    call exception_AC
    popal
    iret

exception_MC_wrapper:
    pushal
    call exception_MC
    popal
    iret

exception_XF_wrapper:
    pushal
    call exception_XF
    popal
    iret

unkown_int_wrapper:
    pushal
    call unkown_int
    popal
    iret
