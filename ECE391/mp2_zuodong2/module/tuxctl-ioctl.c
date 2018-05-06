/*
 * tuxctl-ioctl.c
 *
 * Driver (skeleton) for the mp2 tuxcontrollers for ECE391 at UIUC.
 *
 * Mark Murphy 2006
 * Andrew Ofisher 2007
 * Steve Lumetta 12-13 Sep 2009
 * Puskar Naha 2013
 */

/* System Library */
#include <asm/current.h>
#include <asm/uaccess.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/fs.h>
#include <linux/sched.h>
#include <linux/file.h>
#include <linux/miscdevice.h>
#include <linux/kdev_t.h>
#include <linux/tty.h>
#include <linux/spinlock.h>

/* Custom Library */
#include "tuxctl-ld.h"
#include "tuxctl-ioctl.h"
#include "mtcp.h"

#define debug(str, ...) printk(KERN_DEBUG "%s: " str, __FUNCTION__, ## __VA_ARGS__)

/* 7-Seg LED Bitmap.  */
static char LED_bitmap[LED_DIGIT][LED_TYPE] = {
    {0xE7, 0xF7},   /* 0 / 0. */
    {0x06, 0x16},   /* 1 / 1. */
    {0xCB, 0xDB},   /* 2 / 2. */
    {0x8F, 0x9F},   /* 3 / 3. */
    {0x2E, 0x3E},   /* 4 / 4. */
    {0xAD, 0xBD},   /* 5 / 5. */
    {0xED, 0xFD},   /* 6 / 6. */
    {0x86, 0x96},   /* 7 / 7. */
    {0xEF, 0xFF},   /* 8 / 8. */
    {0xAE, 0xBE},   /* 9 / 9. */
    {0xEE, 0xFE},   /* A / A. */
    {0x6D, 0x7D},   /* b / b. */
    {0xE1, 0xF1},   /* C / C. */
    {0x4F, 0x5F},   /* d / d. */
    {0xE9, 0xF9},   /* E / E. */
    {0xE8, 0xF8},   /* F / F. */
    {0x00, 0x10}    /* (empty) / (empty). */
};

/* Lower 16 bits are four digits */
static unsigned long LED_digit_mask[LED_NUM] = {
    0x0000000F,     /* Digit 1 mask */
    0x000000F0,     /* Digit 2 mask */
    0x00000F00,     /* Digit 3 mask */
    0x0000F000      /* Digit 4 mask */
};

/* Lower 4 bits of third byte, digit show mask */
static unsigned long LED_show_mask[LED_NUM] = {
    0x00010000,     /* Show digit 1 mask */
    0x00020000,     /* Show digit 2 mask */
    0x00040000,     /* Show digit 3 mask */
    0x00080000      /* Show digit 4 mask */
};

/* Lower 4 bits of highest byte, decimal show mask */
static unsigned long LED_decimal_mask[LED_NUM] = {
    0x01000000,     /* Show decimal 1 mask */
    0x02000000,     /* Show decimal 2 mask */
    0x04000000,     /* Show decimal 3 mask */
    0x08000000      /* Show decimal 4 mask */
};

/* IOCTL_INIT command buffer */
static char ioctl_init_buffer[IOCTL_INIT_CMD] = {
    MTCP_LED_USR,   /* Allow user set LED */
    MTCP_BIOC_ON    /* Allow Interrupt */
};

static int ack_flag;    /* Received a command return */
static int put_ret;     /* Check ioctl_put return value */
static char ioctl_button_bufffer;   /* Button pressed value save here */
static char ioctl_LED_buffer[IOCTL_LED_CMD];    /* Save LED out value */

/************************ Protocol Implementation *************************/

/* tuxctl_handle_packet()
 * IMPORTANT : Read the header for tuxctl_ldisc_data_callback() in
 * tuxctl-ld.c. It calls this function, so all warnings there apply
 * here as well.
 */
void tuxctl_handle_packet (struct tty_struct* tty, unsigned char* packet) {
    unsigned a, b, c;

    a = packet[0]; /* Avoid printk() sign extending the 8-bit */
    b = packet[1]; /* values when printing them. */
    c = packet[2];

    switch (a) {
        case MTCP_ACK:  /* Successfully executed a command */
            ack_flag = 1;
            break;
        case MTCP_BIOC_EVENT:   /* A button is pressed */
            ioctl_button_bufffer |= b & BUTTON_CBAS;
            ioctl_button_bufffer |= (c & BUTTON_R) << BUTTON_R_SHIFT;
            ioctl_button_bufffer |= (c & BUTTON_D) << BUTTON_D_SHIFT;
            ioctl_button_bufffer |= (c & BUTTON_L) << BUTTON_L_SHIFT;
            ioctl_button_bufffer |= (c & BUTTON_U) << BUTTON_U_SHIFT;
            ioctl_button_bufffer = ~ioctl_button_bufffer;   /* Active low, invert */
            break;
        case MTCP_RESET:    /* Reset button pressed */
            ack_flag = 1;
            ioctl_button_bufffer = 0;
            tuxctl_ldisc_put(tty, ioctl_init_buffer, IOCTL_INIT_CMD);   /* Reset */
            tuxctl_ldisc_put(tty, ioctl_LED_buffer, IOCTL_LED_CMD);     /* Restore LED value */
            break;
        default:
            return;
    }
}

/* tuxctl_ioctl()
 * Actual implementation of tux related ioctl.
 */
int tuxctl_ioctl(struct tty_struct* tty, struct file* file, unsigned cmd, unsigned long arg) {
/******** IMPORTANT NOTE: READ THIS BEFORE IMPLEMENTING THE IOCTLS ************
 *                                                                            *
 * The ioctls should not spend any time waiting for responses to the commands *
 * they send to the controller. The data is sent over the serial line at      *
 * 9600 BAUD. At this rate, a byte takes approximately 1 millisecond to       *
 * transmit; this means that there will be about 9 milliseconds between       *
 * the time you request that the low-level serial driver send the             *
 * 6-byte SET_LEDS packet and the time the 3-byte ACK packet finishes         *
 * arriving. This is far too long a time for a system call to take. The       *
 * ioctls should return immediately with success if their parameters are      *
 * valid.                                                                     *
 *                                                                            *
 ******************************************************************************/
    int buffer_cnt;
    int led_cnt;
    int digit;
    int decimal;
    switch (cmd) {
        case TUX_INIT:  /* Initialize the tux */
            ack_flag = 1;
            ioctl_button_bufffer = 0;
            for (buffer_cnt = 0; buffer_cnt < IOCTL_LED_CMD; buffer_cnt++)
                ioctl_LED_buffer[buffer_cnt] = 0;
            put_ret = tuxctl_ldisc_put(tty, ioctl_init_buffer, IOCTL_INIT_CMD);
            return 0;
        case TUX_BUTTONS:   /* Pass button pressed value to user program */
            if (copy_to_user((unsigned long*)arg, &ioctl_button_bufffer, sizeof(ioctl_button_bufffer)) != 0) return -EINVAL;
            return 0;
        case TUX_SET_LED:   /* Set LED value */
            if (!ack_flag) return -EINVAL;
            ack_flag = 0;
            ioctl_LED_buffer[0] = MTCP_LED_SET;
            ioctl_LED_buffer[1] = LED_SHOW_MASK;    /* Consider all digits as show */
            for (led_cnt = 0; led_cnt < LED_NUM; led_cnt++) {
                if ((arg & LED_show_mask[led_cnt]) != 0) {  /* If the caller want to show the digit, display */
                    digit = (int)((arg & LED_digit_mask[led_cnt]) >> (led_cnt * LED_DIGIT_SHIFT));
                    decimal = (int)((arg & LED_decimal_mask[led_cnt]) >> (led_cnt + LED_DECIMAL_SHIFT));
                    ioctl_LED_buffer[IOCTL_LED_BASE_CMD+led_cnt] = LED_bitmap[digit][decimal];
                } else {    /* If passed in show value is 0, then show "empty" */
                    ioctl_LED_buffer[IOCTL_LED_BASE_CMD+led_cnt] = LED_bitmap[LED_DIGIT_NONE][LED_DECIMAL_NONE];
                }
            }
            put_ret = tuxctl_ldisc_put(tty, ioctl_LED_buffer, IOCTL_LED_CMD);
            return 0;
        default:
            return -EINVAL;
    }
}
