#ifndef RTC_H
#define RTC_H

#include "types.h"

#define HIGHEST         1024
#define RTC_WRITE_MASK  0xF0

volatile unsigned int rtcFlag;              /* ticks in the frenquency of 1024Hz
                                             * add one whenever it ticks,
                                             * ranges from 1 to 1024
                                             * only in the read_rtc file rtcFlag can be set to zero
                                             */
volatile unsigned int rtcRelativeFreq;      /* rtc relative frenquency
                                             * must be lower than 1024
                                             * the true frenquency is (1024/rtcRelativeFreq)HZ
                                             */

/*rtc open function*/
int32_t rtc_open(const uint8_t *filename);

/*rtc close funciton*/
int32_t rtc_close(int32_t fd);

/*rtc read function*/
int32_t rtc_read(int32_t fd, unsigned char *buf, int32_t nbytes);

/*rtc write function*/
int32_t rtc_write(int32_t fd, const unsigned char *buf, int32_t nbytes);

#endif
