/* i8259.h - Defines used in interactions with the 8259 interrupt
 * controller
 * vim:ts=4 noexpandtab
 */

#ifndef _I8259_H
#define _I8259_H
#include "lib.h"
#include "types.h"
// #include <linux/spinlock.h>

#define MASK_OFF            0xFF    /* mask off all the bits */
#define UNMASK_RTC          0x7F    /* unmask RTC from slave PIC */
#define UNMASK_KB           0xBF    /* unmask keyboard from master PIC */
#define PIC1                0x20    /* IO base address for master PIC */
#define PIC2                0xA0    /* IO base address for slave PIC */
#define PIC1_COMMAND        0x20    /* PIC1 command port */
#define PIC1_DATA           0x21    /* PIC1 data port */
#define PIC2_COMMAND        0xA0    /* PIC2 command port */
#define PIC2_DATA           0xA1    /* PIC2 data port */
#define PIC1_MAP_OFFSET     0x20    /* IR0-7 mapping offset */
#define PIC2_MAP_OFFSET     0x28    /* IR8-15 mapping offset */
#define PIC_INIT_CODE       0x11    /* PIC INIT code */
#define NORMAL_EOI          0x01    /* EOI normal */
#define SLAVE_MASK_         0x04    /* slave PIC mask */
#define SLAVE_BIT_          0x02    /* slave PIC bit */
#define IRQ_NUM_            8       /* number of IRQ in a PIC */
#define KEYBOARD_IRQ        1       /* #IRQ of keyboard */
#define RTC_IRQ             8       /* #IRQ of RTC */

/* Ports that each PIC sits on */
#define MASTER_8259_PORT    0x20
#define SLAVE_8259_PORT     0xA0

/* Initialization control words to init each PIC.
 * See the Intel manuals for details on the meaning
 * of each word */
#define ICW1                0x11
#define ICW2_MASTER         0x20
#define ICW2_SLAVE          0x28
#define ICW3_MASTER         0x04
#define ICW3_SLAVE          0x02
#define ICW4                0x01

/* End-of-interrupt byte.  This gets OR'd with
 * the interrupt number and sent out to the PIC
 * to declare the interrupt finished */
#define EOI                 0x60

/* Externally-visible functions */

/* Initialize both PICs */
void i8259_init(void);
/* Enable (unmask) the specified IRQ */
void enable_irq(uint32_t irq_num);
/* Disable (mask) the specified IRQ */
void disable_irq(uint32_t irq_num);
/* Send end-of-interrupt signal for the specified IRQ */
void send_eoi(uint32_t irq_num);

#endif /* _I8259_H */
