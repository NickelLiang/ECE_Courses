/* idt.h - Defines used in idt table initialization
 */

#ifndef IDT_H
#define IDT_H

#include "types.h"
#include "x86_desc.h"
#include "lib.h"

#define DE      0       /*Divide Error Exception*/
#define DB      1       /*Debug Exception*/
#define NMI     2       /*NMI Interrupt*/
#define BP      3       /*Breakpoint Exception*/
#define OF      4       /*Overflow Exception*/
#define BR      5       /*BOUND Range Exceeded Exception*/
#define UD      6       /*Invalid Opcode Exception*/
#define NM      7       /*Device Not Available Exception*/
#define DF      8       /*Double Fault Exception*/
#define CSO     9       /*Coprocessor Segment Overrun*/
#define TS      10      /*Invalid TSS Exception*/
#define NP      11      /*Segment Not Present*/
#define SS      12      /*Stack Fault Exception*/
#define GP      13      /*General Protection Exception*/
#define PF      14      /*Page-Fault Exception*/
#define UN      15      /*unkown interrupt*/
#define MF      16      /*x87 FPU Floating-Point Error*/
#define AC      17      /*Alignment Check Exception*/
#define MC      18      /*Machine-Check Exception*/
#define XF      19      /*SIMD Floating-Point Exception*/
#define PIT_INT 0x20    /*PIT*/
#define KB_INT  0x21    /*keyboard*/
#define RTC_INT 0x28    /*real time clock*/
#define SCV     0x80    /*system call vector*/
#define INT_GATE    0   /*interrupt gate descriptor*/
#define TRAP_GATE   1   /*trap gata descriptor*/
#define CALL_GATE   2   /*call gate descriptor*/
#define DPL_IE      0   /*Attempting  to  access  an  interrupt  or  exception
                        handler  through  an  interrupt  or  trap  gate from
                        virtual-8086 mode when the handler’s code segment DPL
                        is greater than 0.*/
#define DPL_SC      3   /*dpl of system call*/
#define IDT_SIZE    256 /* Size of IDT */

/*initialize all the entry with specific instruction*/
void idt_init_exceptions(void);

/*initialize the specific entry*/
void idt_init(unsigned index, unsigned gateType, void *handler);

/*execute the instruction of DE*/
void exception_DE(void);

/*execute the instruction of DB*/
void exception_DB(void);

/*execute the instruction of NMI*/
void exception_NMI(void);

/*execute the instruction of BP*/
void exception_BP(void);

/*execute the instruction ofOF*/
void exception_OF(void);

/*execute the instruction of BR*/
void exception_BR(void);

/*execute the instruction of UD*/
void exception_UD(void);

/*execute the instruction of NM*/
void exception_NM(void);

/*execute the instruction of DF*/
void exception_DF(void);

/*execute the instruction of CSO*/
void exception_CSO(void);

/*execute the instruction of TS*/
void exception_TS(void);

/*execute the instruction of NP*/
void exception_NP(void);

/*execute the instruction of SS*/
void exception_SS(void);

/*execute the instruction of GP*/
void exception_GP(void);

/*execute the instruction of PF*/
void exception_PF(void);

/*execute the instruction of MF*/
void exception_MF(void);

/*execute the instruction of AC*/
void exception_AC(void);

/*execute the instruction of MC*/
void exception_MC(void);

/*execute the instruction of XF*/
void exception_XF(void);

/*execute the instruction of unkown_int*/
void unkown_int(void);

/*keyboard_wrapper to call the related function to execute following instruction*/
extern void keyboard_wrapper(void);

/*rtc_wrapper to call the related function to execute following instruction*/
extern void rtc_wrapper(void);

extern void pit_wrapper(void);

/*DE_wrapper to call the related function to execute following instruction*/
extern void exception_DE_wrapper(void);

/*DB_wrapper to call the related function to execute following instruction*/
extern void exception_DB_wrapper(void);

/*NMI_wrapper to call the related function to execute following instruction*/
extern void exception_NMI_wrapper(void);

/*BP_wrapper to call the related function to execute following instruction*/
extern void exception_BP_wrapper(void);

/*OF_wrapper to call the related function to execute following instruction*/
extern void exception_OF_wrapper(void);

/*BR_wrapper to call the related function to execute following instruction*/
extern void exception_BR_wrapper(void);

/*UD_wrapper to call the related function to execute following instruction*/
extern void exception_UD_wrapper(void);

/*NM_wrapper to call the related function to execute following instruction*/
extern void exception_NM_wrapper(void);

/*DF_wrapper to call the related function to execute following instruction*/
extern void exception_DF_wrapper(void);

/*CSO_wrapper to call the related function to execute following instruction*/
extern void exception_CSO_wrapper(void);

/*TS_wrapper to call the related function to execute following instruction*/
extern void exception_TS_wrapper(void);

/*NP_wrapper to call the related function to execute following instruction*/
extern void exception_NP_wrapper(void);

/*SS_wrapper to call the related function to execute following instruction*/
extern void exception_SS_wrapper(void);

/*GP_wrapper to call the related function to execute following instruction*/
extern void exception_GP_wrapper(void);

/*PF_wrapper to call the related function to execute following instruction*/
extern void exception_PF_wrapper(void);

/*MF_wrapper to call the related function to execute following instruction*/
extern void exception_MF_wrapper(void);

/*AC_wrapper to call the related function to execute following instruction*/
extern void exception_AC_wrapper(void);

/*MC_wrapper to call the related function to execute following instruction*/
extern void exception_MC_wrapper(void);

/*XF_wrapper to call the related function to execute following instruction*/
extern void exception_XF_wrapper(void);

/*unkown_int_wrapper to call the related function to execute following instruction*/
extern void unkown_int_wrapper(void);

/* system_call_wrapper to jump to proper vector in system call jumptable */
extern void system_call_wrapper(void);

#endif
