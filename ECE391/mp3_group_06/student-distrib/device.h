/* device.h - Defines used in device interruption
 */

#ifndef DEVICE_H
#define DEVICE_H

#include "types.h"
#include "x86_desc.h"
#include "lib.h"
#include "terminal.h"

#define RTC_REG_NUM         0x70        /*rtc number register*/
#define RTC_REG_DATA        0x71        /*rtc data register*/
#define SR_A                0x8A        /*rtc status register a*/
#define SR_B                0x8B        /*rtc status register b*/
#define SR_C                0x0C        /*rtc status register c*/
#define PERIOD              0x40        /*the peorid constant*/
#define KEY_REG_STATUS      0x64        /*keyboard status register*/
#define KEY_REG_DATA        0x60        /*keyboard data register*/
#define MAX_RATE            0x0F        /*maximum rate*/
#define RATE                15          /*2Hz rate*/
#define DEFAULT_RATE        6           /*1024Hz rate*/
#define BUFF_SIZE           128         /*keyboard buffer size*/
#define LEFT_SHIFT_PRESS    0x2A
#define RIGHT_SHIFT_PRESS   0x36
#define LEFT_SHIFT_REL      0xAA
#define RIGHT_SHIFT_REL     0xB6
#define ALT_PRESS           0x38
#define ALT_REL             0xB8
#define CTRL_PRESS          0x1D
#define CTRL_REL            0x9D
#define CAPS_PRESS          0x3A
#define L_PRESS             0x26
#define ENTER_REL           0x9C
#define BACKSPACE           0x0E
#define F_ONE               0x3B
#define F_TWO               0x3C
#define F_THREE             0x3D
#define TER_ZERO            0
#define TER_ONE             1
#define TER_TWO             2
#define PIT_RATE_MODE       0x34
#define PIT_SQUARE_MODE     0x36
#define PIT_REG_COM         0x43
#define PIT_REG_DATA_ZERO   0x40
#define PIT_IRQ             0
#define PIT_FREQUENCY       1193182
#define PIT_MASK            0xFF
#define PIT_SHIFT           8
#define _20HZ               20

/*print the pressed key onto the screen*/
int32_t keyboard_interrupt(void);

/* Check if ALT key pressed */
int key_pressed();

/*decode the signal received by data and return*/
unsigned char KB_decode(unsigned char scancode);

/*initialize the keyboard and enable keyboard IRQ*/
void init_keyboard(void);

/*execute the interrupt of rtc*/
void rtc_interrupt(void);

/*initialize the rtc and enable rtc IRQ*/
void init_rtc(void);

/*change the rate of rtc freqency*/
void set_rate(unsigned rate);

/*pit interrupt handler*/
uint32_t pit_interrupt();

/*intialize the pit*/
void init_pit(unsigned rate);

/*prepare for scheduling*/
uint32_t scheduling();

/*get the keyboard buffer*/
unsigned char *getBuffer(void);

/*get the enter flag*/
uint8_t getEnter(void);

/*reset the enter flag*/
void resetEnter(void);

/*reset the keyboard buffer*/
void resetBuffer(void);

/*get the buffer idx*/
int getIdx(void);

/*set the buffer idx*/
void setIdx(int new_buffIdx);

/*terminal switch*/
void terminal_switch(int terNum);

/*context switch preparation*/
void context_switch(int terNum);
#endif
