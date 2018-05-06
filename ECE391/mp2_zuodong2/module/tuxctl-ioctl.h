#ifndef TUXCTL_H
#define TUXCTL_H

#define TUX_SET_LED _IOR('E', 0x10, unsigned long)
#define TUX_READ_LED _IOW('E', 0x11, unsigned long*)
#define TUX_BUTTONS _IOW('E', 0x12, unsigned long*)
#define TUX_INIT _IO('E', 0x13)
#define TUX_LED_REQUEST _IO('E', 0x14)
#define TUX_LED_ACK _IO('E', 0x15)

#define LED_NUM             4       /* Number of digits we need to display */
#define LED_DIGIT           17      /* 0-9, A-F, empty = 10 + 6 + 1 = 17 */
#define LED_TYPE            2       /* 0: Without decimal; 1: With decimal */
#define BUTTON_NUM          8       /* CBASRDLU, 8 buttons in total */
#define IOCTL_INIT_CMD      2       /* Number of ioctl_init command required */
#define IOCTL_LED_CMD       6       /* Number of ioctl_led command required */
#define IOCTL_LED_BASE_CMD  2       /* Starting point of actual LED data */

#define LED_SHOW_MASK       0x0F    /* Display all four digits */
#define LED_DIGIT_NONE      (LED_DIGIT-1)   /* The "empty" bitmap location */
#define LED_DECIMAL_NONE    0       /* The "empty" with no decimal */
#define LED_DIGIT_SHIFT     4       /* Digit mask right shift to ensure corret display */
#define LED_DECIMAL_SHIFT   24      /* Decimal mask right shift to ensure corret display */

#define BUTTON_CBAS         0x0F    /* Mask to obtain CBAS */
#define BUTTON_R            0x08    /* Mask to obtain R */
#define BUTTON_R_SHIFT      4       /* R shift to ensure corret format */
#define BUTTON_D            0x04    /* Mask to obtain D */
#define BUTTON_D_SHIFT      3       /* D shift to ensure corret format */
#define BUTTON_L            0x02    /* Mask to obtain L */
#define BUTTON_L_SHIFT      5       /* L shift to ensure corret format */
#define BUTTON_U            0x01    /* Mask to obtain U  */
#define BUTTON_U_SHIFT      4       /* U shift to ensure corret format */

#define SECONDS_IN_MIN      60      /* 60 secs = 1 min */
#define MOD_10              10      /* Mod 10.. */
#define DISPLAY_SHOW_ALL    0x000F0000      /* Mask to show all digits */
#define DISPLAY_SHOW_THREE  0x00070000      /* Mask to show latter 3 digits */
#define DISPLAY_DECIMAL     0x04000000      /* Mask to show decimal point */
#define DISPLAY_SH_SHIFT    4       /* Second's higher number shift value */
#define DISPLAY_ML_SHIFT    8       /* Minute's lower number shift value */
#define DISPLAY_MH_SHIFT    12      /* Minute's higher number shift value */
#define BUTTON_U_INV        0x10    /* U mask after transform */
#define BUTTON_D_INV        0x20    /* D mask after transform */
#define BUTTON_L_INV        0x40    /* L mask after transform */
#define BUTTON_R_INV        0x80    /* R mask after transform */

#endif
