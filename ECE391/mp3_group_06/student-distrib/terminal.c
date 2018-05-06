#include "terminal.h"
#include "device.h"
#include "i8259.h"
#include "multi_terminal.h"

static volatile uint8_t terminalFlag = 0;

/*
 * terminal_open
 *   DESCRIPTION: terminal open function
 *   INPUTS: filename -- the file name of the terminal
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: open the terminal file
 */
int32_t terminal_open(const uint8_t *filename) {
    terminalFlag = 1;
    return 0;
}

/*
 * terminal_close
 *   DESCRIPTION: terminal close function
 *   INPUTS: fd -- file discriptor number for the flie array
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: close the terminal file
 */
int32_t terminal_close(int32_t fd) {
    if (terminalFlag == 0) {        /*check whether the terminal is closed*/
        ERROR_MSG;
        printf("Terminal has already closed.\n");
        return -1;
    }
    terminalFlag = 0;
    return 0;
}

/*
 * terminal_read
 *   DESCRIPTION: terminal read function, read the keyboard to
                  the target buffer
 *   INPUTS: fd -- file discriptor number for the flie array
             buf -- the keyboard buffer
             nbytes -- the number of bytes that need to be read in
 *   OUTPUTS: none
 *   RETURN VALUE: number of bytes that copied
 *   SIDE EFFECTS: read the keyboard to the target buffer
 */
int32_t terminal_read(int32_t fd, unsigned char *buf, int32_t nbytes) {
    if (terminalFlag == 0) {             /*check whether the terminal is open*/
        ERROR_MSG;
        printf("Terminal is not yet opened.\n");
        return -1;
    }
    if (buf == NULL)
        return -1;         /*check whether the buffer is valid*/
    if (nbytes < 0)
        return -1;          /*check whether nbytes is valid*/
    int i;
    unsigned char *keyBuffer;
    uint32_t buffLen;
    while (1) {
        keyBuffer = getBuffer();        /*get the key buffer*/
        if (keyBuffer != NULL) {
            sti();
            while ((!getEnter()) || (cur_ter_num != cur_exe_ter_num)) {sti();}      /*wait for enter*/
            cli();
            resetEnter();               /*reset the enter flag*/
            buffLen = strlen((int8_t *)keyBuffer);              /*get the length of the string*/
            for (i = 0; i < nbytes; i ++)
                buf[i] = '\0';        /*initialze the target buffer*/
            if (buffLen < nbytes)
                nbytes = buffLen;             /*check the length of the string that should be copied*/
            memcpy(buf, keyBuffer, nbytes);                     /*memory copy of the buffer*/
            resetBuffer();                                      /*reset the key buffer*/
            sti();
            return nbytes;                                      /*return the number of bytes that copied*/
        }
    }
    return -1;
}

/*
 * terminal_write
 *   DESCRIPTION: terminal write function, print the char in
                  target buffer onto the screen
 *   INPUTS: fd -- file discriptor number for the flie array
             buf -- the keyboard buffer
             nbytes -- the number of bytes that need to be read in
 *   OUTPUTS: the chars in the target buffer
 *   RETURN VALUE:  number of bytes printed
 *   SIDE EFFECTS: print the char in target buffer onto the screen
 */
int32_t terminal_write(int32_t fd, const unsigned char *buf, int32_t nbytes) {
    if (terminalFlag == 0) {             /*check whether the terminal is open*/
        ERROR_MSG;
        printf("Terminal is not yet opened.\n");
        return -1;
    }
    if (buf == NULL)
        return -1;         /*check whether the buffer is valid*/
    if (nbytes < 0)
        return -1;          /*check whether nbytes is valid*/
    int i;
    uint32_t buffLen = nbytes;               /*get the length of the string*/
    if (buffLen < nbytes)
        nbytes = buffLen;                 /*check the length of the string that should be copied*/

    // Special treatment for 391OS> to print in color text
    if (!strncmp((int8_t*)buf, "391OS> ", 7) && nbytes == 7) {
        printf("391OS> ");
        return nbytes;
    }

    for (i = 0; i < nbytes; i++) {
        // printf("%c", buf[i]);     /*print the string in the buffer onto screen*/
        putc(buf[i]);   // Any user level text will not be printed in color mode
    }
    if (strlen((int8_t*) buf) == TERMINAL_BUFEER_SIZE) {
        printf("\n");
    }
    return nbytes;                                          /*return the number of bytes printed*/
}

/*
 * stdin_open
 *   DESCRIPTION: stdin open function
 *   INPUTS: filename -- the file name of the terminal
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return on failure
 */
int32_t stdin_open(const uint8_t *filename){
    ERROR_MSG;
    printf("User no privilege open stdin file.\n");
    return -1;
}

/*
 * stdin_close
 *   DESCRIPTION: stdin close function
 *   INPUTS: fd -- file discriptor number for the flie array
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return on failure
 */
int32_t stdin_closed(int32_t fd){
    ERROR_MSG;
    printf("User no privilege close stdin file.\n");
    return -1;
}

/*
 * stdin_write
 *   DESCRIPTION: stdin write function
 *   INPUTS: fd -- file discriptor number for the flie array
             buf -- the keyboard buffer
             nbytes -- the number of bytes that need to be read in
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return failure
 */
int32_t stdin_write(int32_t fd, const unsigned char *buf, int32_t nbytes){
    ERROR_MSG;
    printf("User no privilege write stdin file.\n");
    return -1;
}

/*
 * stdout_open
 *   DESCRIPTION: stdout open function
 *   INPUTS: filename -- the file name of the terminal
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return failure
 */
int32_t stdout_open(const uint8_t *filename){
    ERROR_MSG;
    printf("User no privilege open stdout file.\n");
    return -1;
}

/*
 * stdout_close
 *   DESCRIPTION: stdout close function
 *   INPUTS: fd -- file discriptor number for the flie array
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return on failure
 */
int32_t stdout_closed(int32_t fd){
    ERROR_MSG;
    printf("User no privilege close stdout file.\n");
    return -1;
}

/*
 * stdout_read
 *   DESCRIPTION: stdout read function
 *   INPUTS: fd -- file discriptor number for the flie array
             buf -- the keyboard buffer
             nbytes -- the number of bytes that need to be read in
 *   OUTPUTS: none
 *   RETURN VALUE: -1
 *   SIDE EFFECTS: always return on failure
 */
int32_t stdout_read(int32_t fd, unsigned char *buf, int32_t nbytes){
    ERROR_MSG;
    printf("User no privilege read stdout file.\n");
    return -1;
}
