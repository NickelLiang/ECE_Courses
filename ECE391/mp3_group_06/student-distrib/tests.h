#ifndef TESTS_H
#define TESTS_H

/* General Test Macro */
#define PASS 1
#define FAIL 0

/* General Test Function */
void launch_tests();

/* Checkpoint 1 Tests Macro and Functions */
/* TEST SWITCHES */
/* Test keyboard with everything set to 0 */
#define RTC_TEST                0           /* Set to 1 to run RTC test,
                                             * please do not set this now, its functionality loses after CP3.3 */
#define IDT_TEST                0           /* Set to 1 to run IDT test */
#define PAGE_TEST               0           /* Set to 1 to run paging test */
                                            /* Set to 2 to run paging test in system_call */
#define EXCEPTION_TEST          0           /* Set to 1 to get divide zero */
                                            /* Set to 2 to get invalid opcode */

/* CONSTANTS */
#define PAGE_TEST_ADDR_MASK     0x00000FFF  /* Mask out other flags */
#define PAGE_TEST_UNPRESENT     0x00012000  /* Random page address */
#define PAGE_TEST_KERNEL_ADDR   0x0040000F  /* Random address within kernel page */
#define PAGE_TEST_VIDEO_ADDR    0x000B800F  /* Random address within video page */
#define PAGE_TEST_USER_ADDR     0x08000001
#define PAGE_TEST_USER_ADDR1    0x08300000
#define PAGE_TEST_USER_ADDR2    0x083FFFFF

int idt_test();
int paging_test();
#if (EXCEPTION_TEST == 1)
int divide_zero_test();
#endif
int invalid_opcode_test();

/* Checkpoint 2 tests */
/* TEST SWITCHES */
#define RTC_TERMINAL_TEST       0           /* Set to 1 to run RTC & Terminal test*/
#define FILE_SYSTEM_TEST        0           /* Set to 1 to run file system test*/
#define PCB_TEST                0           /* Set to 1 to run file system test*/
/* CONSTANTS */
#define RTC_TEST_SEC_PER_FRQ    3           /* Print 3 seconds each */
#define RTC_TEST_MAX_MULTIPLIER 7           /* 1:4Hz, 2:8Hz, 3:16Hz, 4:32Hz, 5:64Hz, 6:128Hz, 7:256Hz, 8:512Hz, 9:1024Hzn */
#define RTC_TEST_INITIAL_FRQ    2           /* Initial RTC frequency in Hz*/
#define RTC_TEST_MAX_TICKS      2048        /* Maximum ticks to print '1' */
#define TERMINAL_TEST_BUFFER    256         /* Buffer of Terminal read/write */
/* rtc test */
int rtc_test();
/* terminal test */
int terminal_test();

/* Checkpoint 3 tests */
#define SHELL_TEST              0

/* Checkpoint 4 tests */
/* Checkpoint 5 tests */

#endif /* TESTS_H */
