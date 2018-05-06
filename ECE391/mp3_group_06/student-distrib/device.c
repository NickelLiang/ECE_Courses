/* device.c - Functions to initialize the devices and set up
their handler
 */
#include "device.h"
#include "i8259.h"
#include "tests.h"
#include "rtc.h"
#include "lib.h"
#include "multi_terminal.h"
#include "pcb.h"
#include "paging.h"

static uint8_t shiftFlag;       /* check whether the shiftkey is pressed */
static uint8_t ctrlFlag;
static uint8_t altFlag;
static uint8_t capsFlag;
static volatile uint8_t keyFlag;
static volatile uint8_t enterFlag;
static volatile uint8_t enterSignal;
static unsigned char keyBuffer[BUFF_SIZE + 1]; // +1 since we need to detect ENTER after filled
static int buffIdx = 0;

/*
 * keyboard_interrupt
 *   DESCRIPTION: this function will be called by the keyboard_wrapper
                  and print the pressed key onto the screen
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on no terminal shift
                   if need terminal shift, return the &(ece391_multi_ter_info[cur_ter_num])
 *   SIDE EFFECTS: print the pressed key onto the screen
 */
int32_t keyboard_interrupt() {
    // cli();                          /*clean the interrupt flag*/
    send_eoi(KEYBOARD_IRQ);         /*send the end of interrupt signal to PIC*/
    // sti();                          /*restore the interrupt flag*/
    unsigned char scancode = 0;     /*initialize scancode*/
    unsigned char pressedKey = 0;   /*initialize pressedKey*/
    scancode = inb(KEY_REG_DATA);
    if (scancode == LEFT_SHIFT_PRESS || scancode == RIGHT_SHIFT_PRESS) shiftFlag = 1; /* check whether the shift key is pressed */
    if (scancode == LEFT_SHIFT_REL || scancode == RIGHT_SHIFT_REL) shiftFlag = 0; /* check whether the shift key is released */
    if (scancode == CTRL_PRESS) ctrlFlag = 1; /*check whether the ctrl key is pressed*/
    if (scancode == CTRL_REL) ctrlFlag = 0; /*check whether the ctrl key is released*/
    if (scancode == ALT_PRESS) {
        altFlag = 1;  /*check whether the alt key is pressed*/
        keyFlag = 1;
    }
    if (scancode == ALT_REL) altFlag = 0;  /*check whether the alt key is released*/
    if (scancode == CAPS_PRESS) {         /*check whether the capslock key is pressed*/
        if (capsFlag == 0) capsFlag = 1;    /*if it in the case whrn capslock is off, set it to be on*/
        else capsFlag = 0;      /*otherwise set it to be off*/
    }
    /*the case of ctrl + l*/
    if (scancode == L_PRESS && ctrlFlag == 1) {
        // cli();
        pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
        page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
        write_cr3((unsigned long)page_directory);
        PRINT_TO_SCREEN = 1;

        clearScreen();    /*clear the screen*/

        PRINT_TO_SCREEN = 0;
        page_table_0[VIDEO_VIRTUAL] = page_temp;
        write_cr3((unsigned long)page_directory);
        // sti();

        ctrlFlag = 0;       /*reset the strl flag*/
        sti();
        return 0;
    }
    // cli();
    if (altFlag == 1) {
        switch(scancode) {
            case F_ONE:
            altFlag = 0;
            if (cur_ter_num == TER_ZERO) return 0;
            else {
                terminal_switch(TER_ZERO);
                return 0;
            }
            break;
            case F_TWO:
            altFlag = 0;
            if (cur_ter_num == TER_ONE) return 0;
            else {
                terminal_switch(TER_ONE);
                return 0;
            }
            break;
            case F_THREE:
            altFlag = 0;
            if (cur_ter_num == TER_TWO) return 0;
            else {
                terminal_switch(TER_TWO);
                return 0;
            }
            break;
        }
    }
    // sti();
    // if (pressedKey == 0) spKey(scancode);       /*if the key is not a normal key, check whether it is a special key*/
    if (scancode == BACKSPACE) {        /*if the backspace key is pressed, delete a char in the buffer*/
        // cli();
        pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
        page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
        write_cr3((unsigned long)page_directory);
        PRINT_TO_SCREEN = 1;

        spKey(scancode);

        PRINT_TO_SCREEN = 0;
        page_table_0[VIDEO_VIRTUAL] = page_temp;
        write_cr3((unsigned long)page_directory);
        // sti();

        if (buffIdx != 0) {
            keyBuffer[buffIdx] = '\0';
            buffIdx --; // This fix the PAGE FAULT problem
        }
    }
    if (scancode == LEFT_ARROW) {
        // cli();
        pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
        page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
        write_cr3((unsigned long)page_directory);
        PRINT_TO_SCREEN = 1;

        spKey(scancode);

        PRINT_TO_SCREEN = 0;
        page_table_0[VIDEO_VIRTUAL] = page_temp;
        write_cr3((unsigned long)page_directory);
        // sti();

        if (buffIdx != 0) {
            buffIdx --; // This fix the PAGE FAULT problem
        }
    }
    if (scancode == RIGHT_ARROW) {
        if ((keyBuffer[buffIdx] != '\0') && (buffIdx < BUFF_SIZE - 1)) {
            // cli();
            pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
            page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
            write_cr3((unsigned long)page_directory);
            PRINT_TO_SCREEN = 1;

            spKey(scancode);
            PRINT_TO_SCREEN = 0;
            page_table_0[VIDEO_VIRTUAL] = page_temp;
            write_cr3((unsigned long)page_directory);
            // sti();

            buffIdx ++;
        }
    }
    if (scancode == ENTER_REL) enterSignal = 0;
    /* if a key is pressed, decode it into the char that should be print on the screen */
    if (scancode > 0x00 && scancode < 0x81) pressedKey = KB_decode(scancode);
    /* if the key pressed value is known, print it */
    if (pressedKey != 0) {
        // cli();
        pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
        page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
        write_cr3((unsigned long)page_directory);
        PRINT_TO_SCREEN = 1;
        printf("%c", pressedKey);
        PRINT_TO_SCREEN = 0;
        page_table_0[VIDEO_VIRTUAL] = page_temp;
        write_cr3((unsigned long)page_directory);
        // sti();

        if (buffIdx < BUFF_SIZE) {      /*if the buffer is not full, put the char in to the buffer*/
            keyBuffer[buffIdx] = pressedKey;
        }
        buffIdx ++;
    }
    if (pressedKey == '\n') {
        buffIdx = BUFF_SIZE - 1; // This handle left arrow key
    }

    moveCursor();
    sti();
    return 0;
}

/*
 * key_pressed
 *   DESCRIPTION: this function will wait until key is pressed
 *   INPUTS: none
 *   RETURN VALUE: 1 when return
 *   SIDE EFFECTS: system will wait for a key stroke.
 */
int key_pressed() {
    while (keyFlag != 1) {}
    keyFlag = 0;
    return 1;
}

/*
 * KB_decode
 *   DESCRIPTION: decode the signal received by data and return
 *   INPUTS: scancode -- the signal received by data port of keyboard
 *   OUTPUTS: none
 *   RETURN VALUE: the char that should be displayed on the screen
 *   SIDE EFFECTS: none
 */
unsigned char KB_decode(unsigned char scancode) {
    switch(scancode) {
        case 0x1C: {
            if (enterSignal == 0) {
                enterSignal = 1;
                enterFlag = 1;
                return '\n';
            }
            return 0;
        }
        case 0x39: return ' ';
    }
    if (shiftFlag == 0) {       /*check whether the shift key is pressed*/
        switch(scancode) {          /*decode the scancode*/
            case 0x02: return '1';
            case 0x03: return '2';
            case 0x04: return '3';
            case 0x05: return '4';
            case 0x06: return '5';
            case 0x07: return '6';
            case 0x08: return '7';
            case 0x09: return '8';
            case 0x0A: return '9';
            case 0x0B: return '0';
            case 0x0C: return '-';
            case 0x0D: return '=';
            case 0x1A: return '[';
            case 0x1B: return ']';
            case 0x27: return ';';
            case 0x28: return '\'';
            case 0x29: return '`';
            case 0x2B: return '\\';
            case 0x33: return ',';
            case 0x34: return '.';
            case 0x35: return '/';
        }
    }
    else {
        switch(scancode) {          /*decode the scancode*/
            case 0x02: return '!';
            case 0x03: return '@';
            case 0x04: return '#';
            case 0x05: return '$';
            case 0x06: return '%';
            case 0x07: return '^';
            case 0x08: return '&';
            case 0x09: return '*';
            case 0x0A: return '(';
            case 0x0B: return ')';
            case 0x0C: return '_';
            case 0x0D: return '+';
            case 0x1A: return '{';
            case 0x1B: return '}';
            case 0x27: return ':';
            case 0x28: return '"';
            case 0x29: return '~';
            case 0x2B: return '|';
            case 0x33: return '<';
            case 0x34: return '>';
            case 0x35: return '?';
        }
    }
    if (shiftFlag ^ capsFlag) {         /*deal with alpha letter cases*/
        switch(scancode) {
            case 0x10: return 'Q';
            case 0x11: return 'W';
            case 0x12: return 'E';
            case 0x13: return 'R';
            case 0x14: return 'T';
            case 0x15: return 'Y';
            case 0x16: return 'U';
            case 0x17: return 'I';
            case 0x18: return 'O';
            case 0x19: return 'P';
            case 0x1E: return 'A';
            case 0x1F: return 'S';
            case 0x20: return 'D';
            case 0x21: return 'F';
            case 0x22: return 'G';
            case 0x23: return 'H';
            case 0x24: return 'J';
            case 0x25: return 'K';
            case 0x26: return 'L';
            case 0x2C: return 'Z';
            case 0x2D: return 'X';
            case 0x2E: return 'C';
            case 0x2F: return 'V';
            case 0x30: return 'B';
            case 0x31: return 'N';
            case 0x32: return 'M';
        }
    }
    else {
        switch(scancode) {
            case 0x10: return 'q';
            case 0x11: return 'w';
            case 0x12: return 'e';
            case 0x13: return 'r';
            case 0x14: return 't';
            case 0x15: return 'y';
            case 0x16: return 'u';
            case 0x17: return 'i';
            case 0x18: return 'o';
            case 0x19: return 'p';
            case 0x1E: return 'a';
            case 0x1F: return 's';
            case 0x20: return 'd';
            case 0x21: return 'f';
            case 0x22: return 'g';
            case 0x23: return 'h';
            case 0x24: return 'j';
            case 0x25: return 'k';
            case 0x26: return 'l';
            case 0x2C: return 'z';
            case 0x2D: return 'x';
            case 0x2E: return 'c';
            case 0x2F: return 'v';
            case 0x30: return 'b';
            case 0x31: return 'n';
            case 0x32: return 'm';
        }
    }
    return 0;                 /*if the pressed key is unkown, return 0*/
}

/*
 * init_keyboard
 *   DESCRIPTION: this function will be called in the kernel.c initializing
                  the keyboard and enable keyboard IRQ
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: initialize the keyboard and enable keyboard IRQ
 */
void init_keyboard() {
    shiftFlag = 0;              /*reset the shift flag*/
    PRINT_TO_SCREEN = 0;        /*set not to print to screen */
    enable_irq(KEYBOARD_IRQ);   /*enable keyboard IRQ*/
}

/*
 * rtc_interrupt
 *   DESCRIPTION: this function will be called by the rtc_wrapper execute
                  the interrupt of rtc
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS:  execute the interrupt of rtc
 */
void rtc_interrupt() {
    send_eoi(RTC_IRQ);          /*send the end of interrupt signal to PIC*/
    outb(SR_C, RTC_REG_NUM);    /*select register C*/
    inb(RTC_REG_DATA);          /*throw away contents*/
    #if (RTC_TEST == 1)
    test_interrupts();
    #endif
    // invoking ticks
    rtcFlag++;
    // make the rtcFlag in the proper range
    if (rtcFlag >= HIGHEST)
        rtcFlag = 0;
}

/*
 * init_rtc
 *   DESCRIPTION: this function will be called in the kernel.c, initializing
                  the rtc and enable rtc IRQ
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: initialize the rtc and enable rtc IRQ
 */
void init_rtc() {
    char prev;
    enable_irq(RTC_IRQ);        /*enable rtc IRQ*/
    outb(SR_B, RTC_REG_NUM);        /*select register B, and disable NMI*/
    prev = inb(RTC_REG_DATA);       /*read the current value of register B*/
    outb(SR_B, RTC_REG_NUM);        /*set the index again*/
    outb(prev | PERIOD, RTC_REG_DATA);      /*write the previous value ORed with 0x40. This turns on bit 6 of register B*/
    outb(SR_C, RTC_REG_NUM);        /*select register C*/
    inb(RTC_REG_DATA);      /*throw away contents*/
    set_rate(DEFAULT_RATE);     /*set the rate*/
}

/*
 * set_rate
 *   DESCRIPTION: change the rate of rtc freqency
 *   INPUTS: rate -- the new rate of rtc
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: change the rate of rtc freqency
 */
void set_rate(unsigned rate) {
    char prev;
    rate &= MAX_RATE;         /*rate must be above 2 and not over 15*/
    outb(SR_A, RTC_REG_NUM);      /*set index to register A, disable NMI*/
    prev = inb(RTC_REG_DATA);         /*get initial value of register A*/
    outb(SR_A, RTC_REG_NUM);      /*reset index to A*/
    outb((prev & 0xF0) | rate, RTC_REG_DATA);     /*write only our rate to A. Note, rate is the bottom 4 bits*/
}

uint32_t pit_interrupt() {
    send_eoi(PIT_IRQ);          /*send the end of interrupt signal to PIC*/

    // printf("P ");
    return scheduling();
}

/*
 * init_pit
 *   DESCRIPTION: this function is called by the kernel
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE:  the addr of the terminal struct that we want to store
                    the register information
 *   SIDE EFFECTS:  initialize the rtc and enable pit IRQ
 */

void init_pit(unsigned freqency) {
    enable_irq(PIT_IRQ);        //enable the irq of pit
    outb(PIT_RATE_MODE, PIT_REG_COM);       //choose the correct mode and channel for pit
    uint16_t rate = PIT_FREQUENCY / freqency;
    cur_exe_ter_num = 0;            //initialize the cur_ter_num;
    outb(rate & PIT_MASK, PIT_REG_DATA_ZERO);       //input the rate into port
    outb(rate >> PIT_SHIFT, PIT_REG_DATA_ZERO);
}

/*
 * scheduling
 *   DESCRIPTION: this function is called by pit interrupt handler
                  and execute the scheduling as the freqency of
                  PIT
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE:  the addr of the terminal struct that we want to store
                    the register information
 *   SIDE EFFECTS:  prepare for context switch and save the necessary information
 */

uint32_t scheduling() {
    // now try to process cur_exe_ter_num
    int exe_ter_num = cur_exe_ter_num;
    // update cur_exe_ter_num for next turn
    cur_exe_ter_num = (cur_exe_ter_num + 1) % TER_MAX;
    // pass-in the current processing terminal number
    context_switch(exe_ter_num);
    // pass in the old terminal number to process
    return (uint32_t)(&ece391_multi_ter_info[exe_ter_num]);
}

/*
 * getBuffer
 *   DESCRIPTION: get the keyboard buffer
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: the keyboard buffer
 *   SIDE EFFECTS: none
 */
unsigned char *getBuffer() {return keyBuffer;}

/*
 * getEnter
 *   DESCRIPTION: get the enter flag
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: the enter flag
 *   SIDE EFFECTS: none
 */
uint8_t getEnter() {
    cli();
    return enterFlag;
}

/*
 * resetEnter
 *   DESCRIPTION: reset the enter flag
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: reset the enter flag
 */
void resetEnter() {
    enterFlag = 0;
    buffIdx = 0;
}

/*
 * resetBuffer
 *   DESCRIPTION: reset the keyboard buffer
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: reset the keyboard buffer
 */
void resetBuffer() {
    int i;
    for (i = 0; i < BUFF_SIZE+1; i ++)
        keyBuffer[i] = '\0'; // +1 since we need to detect ENTER after filled
}

/*
 * getIdx
 *   DESCRIPTION: get the buffer idx
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: buffIdx
 *   SIDE EFFECTS: get the buffer idx
 */
int getIdx() {
    return buffIdx;
}
/*
 * getIdx
 *   DESCRIPTION: set the buffer idx
 *   INPUTS: new_buffIdx
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: set the buffer idx
 */
void setIdx(int new_buffIdx) {
    buffIdx = new_buffIdx;
}
/*
 * terminal_switch
 *   DESCRIPTION: this function save the information of current terminal
                  and get the information of next terminal(cursor, video memory)
 *   INPUTS: terNum -- the current terminal that is displayed
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: save the information of current terminal
                  and get the information of next terminal(cursor, video memory)
 */
void terminal_switch(int terNum) {
    //switch uservideo mapping
    //background_uservideo_paging(cur_ter_num, terNum);
    //store the old value
    // ece391_multi_ter_info[cur_ter_num].Dest_ter = terNum;
    // ece391_multi_ter_info[terNum].Parent_ter = cur_ter_num;
    // ece391_multi_ter_info[cur_ter_num].PID_num = ece391_process_manager.curr_pid;
    /*store the cursor information*/
    ece391_multi_ter_info[cur_ter_num].ter_screen_x = getScreen_x();
    ece391_multi_ter_info[cur_ter_num].ter_screen_y = getScreen_y();
    /*store the buffer information*/
    memcpy(ece391_multi_ter_info[cur_ter_num].ter_buffer, keyBuffer, BUFF_SIZE);
    ece391_multi_ter_info[cur_ter_num].ter_bufferIdx = buffIdx;
     /*switch the terminal video*/
    switch_terminal_video(cur_ter_num, terNum);

    background_uservideo_paging(terNum, cur_ter_num);
    /*get the buffer information*/
    memcpy(keyBuffer, ece391_multi_ter_info[terNum].ter_buffer, BUFF_SIZE);
    buffIdx = ece391_multi_ter_info[terNum].ter_bufferIdx;
     /*get the cursor information*/
    setScreen_x(ece391_multi_ter_info[terNum].ter_screen_x);
    setScreen_y(ece391_multi_ter_info[terNum].ter_screen_y);
    moveCursor();
    cur_ter_num = terNum;

}
/*
 * context_switch
 *   DESCRIPTION: this function save the information of current terminal
                  and get the information of next terminal(pid number)
 *   INPUTS: exe_ter_num -- the current terminal that is running
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: save the information of current terminal
                  and get the information of next terminal(pid number)
 */

// exe_ter_num is the old terminal Number
// cur_exe_ter_num have been updated for the this turn
void context_switch(int exe_ter_num) {
    ece391_multi_ter_info[exe_ter_num].TER_RTC_FLAG = rtcFlag;
    rtcFlag = ece391_multi_ter_info[cur_exe_ter_num].TER_RTC_FLAG ;
    //switch uservideo mapping
    background_uservideo_paging(cur_ter_num, cur_exe_ter_num);
    //set current destination terminal number
    ece391_multi_ter_info[exe_ter_num].Dest_ter = cur_exe_ter_num;
    // set current terminal's parent to the old terminal number
    ece391_multi_ter_info[cur_exe_ter_num].Parent_ter = exe_ter_num;
    // store the old terminal number's pid number to info table
    ece391_multi_ter_info[exe_ter_num].PID_num = ece391_process_manager.curr_pid;

}
