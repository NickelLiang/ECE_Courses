#include "rtc.h"
#include "device.h"
#include "i8259.h"
#include "file_system.h"
#include "pcb.h"

#define CHECK_FAIL      -1              /* this is the open/close-failed code indicates a failure on open a file */
#define RTC_NAME_LEN    4               /* rtc file name length  */
#define RTC_CLOSED      67              /* 'C' indecates file closed */
#define RTC_OPENED      79              /* 'O' indicates file opened */
// uint8_t RTC_STATUS;

/*
 * rtc_open
 *   DESCRIPTION: rtc open function, set the initial rate to 2Hz
                  and open the rtc irq
 *   INPUTS: filename -- the file name of the rtc
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: set the initial rate to 2Hz and open the rtc irq
 */
int32_t rtc_open(const uint8_t *filename) {
    int32_t ii;    // traverse to check status file/dir array
    int32_t new_fd = -1;  // if can open a file, this will record the fd
    dentry_t dentry;    // check dentry
    // traverse the open file array
    for (ii = FD_LOW; ii <= FD_UPPER; ii++) {
        // check each opened file
        if (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[ii].flags == STATUS_CLOSED) {
            new_fd = ii;
            break;
        }
    }
    // copy to local dentry for init file in file_array
    read_dentry_by_name(filename, &dentry);
    // update the opened file's status
    ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[new_fd].inode = 0xFFFF;
    ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[new_fd].filePos = HIGHEST / 2; /*set the rate to 2Hz*/
    ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[new_fd].flags = STATUS_OPENED;
    enable_irq(RTC_IRQ);
    return new_fd;
}

/*
 * rtc_close
 *   DESCRIPTION: rtc close function
 *   INPUTS: fd -- file discriptor number for the flie array
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: close the rtc file
 */
int32_t rtc_close(int32_t fd) {
    if (fd < FD_LOW || fd > FD_UPPER) {
        ERROR_MSG;
        printf("Input fd out of range.\n");
        return -1;
    }
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags = STATUS_CLOSED;
    return 0;
}

#define ter_num 3
/*
 * rtc_read
 *   DESCRIPTION: rtc read function, wait until a rtc interrupt
                  has completed
 *   INPUTS: fd -- file discriptor number for the flie array
             buffer -- the buffer contains the freqency
             bytes -- the number of bytes that need to be read in
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure, 0 on success
 *   SIDE EFFECTS: wait until a rtc interrupt has completed
 */
int32_t rtc_read(int32_t fd, unsigned char *buf, int32_t nbytes) {
    unsigned int rtcRelativeFreq = (unsigned int)(ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[fd].filePos);
    const unsigned int dest = (rtcFlag + rtcRelativeFreq/ter_num)%HIGHEST;
    unsigned flag = 0;   // make sure at least wait one tound of the while loop
    sti();
    while (rtcFlag != dest || flag == 0) {flag = 1;}    /*check whether a rtc interrupt completed*/
    return 0;
}

/*
 * rtc_write
 *   DESCRIPTION: rtc write function, set the rtc freqency to the
                  input one
 *   INPUTS: fd -- file discriptor number for the flie array
             buffer -- the buffer contains the freqency
             bytes -- the number of bytes that need to be read in
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: set the rtc freqency to the input one
 */
int32_t rtc_write(int32_t fd, const unsigned char *buf, int32_t nbytes) {
    // char prev;               should not use when virtulizing rtc
    // int rate = MAX_RATE;
    int32_t freqency;

    if (buf == NULL) return -1;      /*check whether the buffer is valid*/
    if (nbytes != 4) return -1;      /*the freqency is a 4 bytes int*/
    freqency = *buf;

    if (freqency > HIGHEST || freqency <= 1) return -1;     /*freqency is out of range*/
    if (freqency & (freqency - 1)) {        /*input is not power of 2*/
        printf("input is not power of 2");
        return -1;
    }
    ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->file_array.files[fd].filePos = HIGHEST / freqency;
    // while (freqency != 1) {         /*convert the freqency to rate*/
    //     freqency /= 2;
    //     rate --;
    // }
    // outb(SR_A, RTC_REG_NUM);      /*set index to register A, disable NMI*/
    // prev = inb(RTC_REG_DATA);         /*get initial value of register A*/
    // outb(SR_A, RTC_REG_NUM);      /*reset index to A*/
    // outb((prev & RTC_WRITE_MASK) | rate, RTC_REG_DATA);     /*write only our rate to A. Note, rate is the bottom 4 bits*/
    return nbytes;
}
