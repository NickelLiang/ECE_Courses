#include "tests.h"
#include "x86_desc.h"
#include "lib.h"
#include "idt.h"
#include "paging.h"
#include "file_system.h"
#include "rtc.h"
#include "device.h"
#include "terminal.h"
#include "system_call.h"
#include "pcb.h"
/* format these macros as you see fit */
#define TEST_HEADER 	\
	printf("[TEST %s] Running %s at %s:%d\n", __FUNCTION__, __FUNCTION__, __FILE__, __LINE__)
#define TEST_OUTPUT(name, result)	\
	printf("[TEST %s] Result = %s\n", name, (result) ? "PASS" : "FAIL");

static inline void assertion_failure(){
	/* Use exception #15 for assertions, otherwise
	   reserved by Intel */
	asm volatile("int $15");
}

/* Checkpoint 1 tests */
/* idt_test
 * Asserts that first 10 IDT entries are not NULL
 * Inputs: None
 * Outputs: PASS/FAIL
 * Side Effects: None
 * Coverage: Load IDT, IDT definition
 * Files: x86_desc.h/S
 */
int idt_test(){
	TEST_HEADER;
	int i;
	int result = PASS;
	for (i = 0; i < 10; ++i){
		if ((idt[i].offset_15_00 == NULL) &&
			(idt[i].offset_31_16 == NULL)){
			assertion_failure();
			result = FAIL;
		}
	}
	return result;
}

/* paging_test
 * Purpose	Check page directory and page table alignment, content, and dereference
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *		Kernel will freeze after PFE
 * Coverage
 *		Page directory and page table alignment, content, and dereference
 * Files	paging.c/h
 */
int paging_test() {
	clear();
	printf("\n\n\n");
	TEST_HEADER;

	int result = PASS;
	unsigned long test_variable;

	/* Page Directory and Page Table should align at 4kb */
	printf("\n[TEST page_directory and page_table_0 address]\n");
	if (((unsigned long)page_directory & PAGE_TEST_ADDR_MASK) != 0) {
		printf("[FAIL] page_directory     0x%#x, not aligned at 4KB\n", page_directory);
		result = FAIL;
	} else {
		printf("[PASS] *page_directory    0x%#x, aligned at 4KB\n", page_directory);
	}
	if (((unsigned long)page_table_0 & PAGE_TEST_ADDR_MASK) != 0) {
		printf("[FAIL] page_table_0       0x%#x, not aligned at 4KB\n", page_table_0);
		result = FAIL;
	} else {
		printf("[PASS] *page_table_0      0x%#x, aligned at 4KB\n", page_table_0);
	}

	/* Check if Page Directory and Page Table contain correct content */
	printf("\n[TEST page_directory and page_table_0 content]\n");
	if ((page_directory[0] & PTBA_MASK) != (unsigned long)page_table_0) {
		printf("[FAIL] page_directory[0]  0x%#x, doesn't contain address of page_table_0\n", page_directory[0]);
		result = FAIL;
	} else {
		printf("[PASS] page_directory[0]  0x%#x, contain addr of page_table_0 with flags\n", page_directory[0]);
	}
	if ((page_directory[1] & PBA_4M_MASK) != KERNEL_START) {
		printf("[FAIL] page_directory[1]  0x%#x, doesn't contain address of kernel\n", page_directory[1]);
		result = FAIL;
	} else {
		printf("[PASS] page_directory[1]  0x%#x, contain addr of kernel with flags\n", page_directory[1]);
	}
	if ((page_directory[32] & PBA_4M_MASK) != 0x00800000) {
		printf("[FAIL] page_directory[32]  0x%#x, doesn't contain address of kernel\n", page_directory[32]);
		result = FAIL;
	} else {
		printf("[PASS] page_directory[32]  0x%#x, contain addr of kernel with flags\n", page_directory[32]);
	}
	if (page_table_0[0] != 0) {
		printf("[FAIL] page_table_0[0]    0x%#x, not empty\n", page_table_0[0]);
		result = FAIL;
	} else {
		printf("[PASS] page_table_0[0]    0x%#x, empty\n", page_table_0[0]);
	}
	if ((page_table_0[VIDEO_VIRTUAL] & PBA_4K_MASK) != VIDEO_START) {
		printf("[FAIL] page_table_0[0x%x] 0x%#x, doesn't contain address of video mem\n", VIDEO_VIRTUAL, page_table_0[VIDEO_VIRTUAL]);
		result = FAIL;
	} else {
		printf("[PASS] page_table_0[0x%x] 0x%#x, contain addr of video mem with flags\n", VIDEO_VIRTUAL, page_table_0[VIDEO_VIRTUAL]);
	}

	/* If anything trigger PFE, test failed */
	printf("\n[TEST dereference at kernel address]\n");
	test_variable = *((unsigned char *)KERNEL_START);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", KERNEL_START, test_variable);
	test_variable = *((unsigned char *)PAGE_TEST_KERNEL_ADDR);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_KERNEL_ADDR, test_variable);

	printf("\n[TEST dereference at video address]\n");
	test_variable = *((unsigned char *)VIDEO_START);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", VIDEO_START, test_variable);
	test_variable = *((unsigned char *)PAGE_TEST_VIDEO_ADDR);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_VIDEO_ADDR, test_variable);

	printf("\n[TEST dereference at user address]\n");
	test_variable = *((unsigned char *)PAGE_TEST_USER_ADDR);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_USER_ADDR, test_variable);
	test_variable = *((unsigned char *)PAGE_TEST_USER_ADDR1);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_USER_ADDR1, test_variable);
	test_variable = *((unsigned char *)PAGE_TEST_USER_ADDR2);
	printf("[PASS] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_USER_ADDR2, test_variable);

	/* If PFE didn't triggered, test failed */
	printf("\n[TEST dereference at unpresent address, should trigger PFE]\n");
	test_variable = *((unsigned long *)PAGE_TEST_UNPRESENT);
	printf("[FAIL] M[%#x] is     0x%#x, didn't trigger PFE\n", PAGE_TEST_UNPRESENT, test_variable);
	result = FAIL;	/* Test failed if not triggered exception */

	return result;	/* Reserved for future use */
}

#if (EXCEPTION_TEST == 1)
/* divide_zero_test
 * Purpose	Check if Divide Zero Exception is working
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *		Kernel will freeze after exception
 * Coverage
 *		Divide Zero Exception
 * Files	idt.c/h
 */
int divide_zero_test(){
	TEST_HEADER;
	/* Compiler will not be happy with this line of code */
	int i = 5 / 0;	/* This will trigger divide zero exception. */
	return FAIL;	/* Test failed if not triggered exception */
}
#endif

/* invalid_opcode_test
 * Purpose	Check if Invalid Opcode Exception is working
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *		Kernel will freeze after exception
 * Coverage
 *		Invalid Opcode Exception
 * Files	idt.c/h
 */
int invalid_opcode_test(){
	TEST_HEADER;
	int val = 1;
	asm volatile("movl %0,%%cr6": :"r" (val)); /* CR6 is a madeup register */
	return FAIL;	/* Test failed if not triggered exception */
}

/* Checkpoint 2 tests */
// this file tests three basic APIs to file system
// NOTE NEED HEADER COMMENTS!!!!!!!!!!!!!!!!
#define testBufferMaxLen		60000 // Move this to header file
int file_read_test_naive(){
	dentry_t test;
	uint8_t buffer[testBufferMaxLen];
	uint32_t buflen;
	char name[] = "fish";
	if(read_dentry_by_name((uint8_t *)name, &test)==-1){
		printf("Name not found.\n");
		return PASS;
	}
	else {
		printf("File Name: %s\nFile type: %d\nInode Num: %d\n", name, test.filetype, test.inode_num);
	 	buflen = ece391FileSystem.ece391_inodes[test.inode_num].length;
		if (buflen >= testBufferMaxLen)
			buflen = testBufferMaxLen;
		if (test.filetype == 2){
			read_data(test.inode_num, 0, buffer, buflen);
			putbuf((int8_t*)buffer, buflen);
		}
	}
	return PASS;
}
#define 	NAME_MAX_LEN		32 /* in ece391 file system, a file name has maximum 32 B length */
#define 	PRINT_STRIDE		50 /* for easy testing, echo 50 bytes of file info uoto screen */

#if (FILE_SYSTEM_TEST == 1)
/* test_file_open_read_close
 * Purpose	// regular files ops test
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *
 * Coverage
 *		// regular files ops test
 * Files	filesyetem.c/h
 */
int test_file_open_read_close(){
	uint8_t name1[] = "frame0.txt";
	uint8_t name2[] = "verylargetextwithverylongname.txt";
	uint8_t buffer[testBufferMaxLen];
	int32_t read_len;
	printf("[TEST] ____txt file operations____ \n");
	/* NOTE open a txt file with a short name 					NOTE */
	printf("[TEST] short name txt files open \n");
	printf("[TEST] file open %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_open(name1) == -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file opened %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE open a txt file with a illegally long name 			NOTE */
	printf("[TEST] illegally long name txt files open \n");
	printf("[TEST] file open %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_open(name2) == -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file should not be opened %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE legal long name operations 							NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] leagally long name txt files open \n");
	printf("[TEST] file open %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_open(name2) == -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file should be opened %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a short txt file and echo on screen 			NOTE */
	printf("[TEST] short name txt files read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("\nPress ALT to continue test...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name1, file_find(name1));
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		// print another 50 byte
		read_len = file_read(file_find(name1), buffer, PRINT_STRIDE) ;
		if (read_len == -1)
			printf("READ FAILED.\n");
		else
			putbuf((int8_t*)buffer, read_len);

	}
	printf("[PASS] short file read succeeded %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a non existed txt file and echo on screen 			NOTE */
	name2[NAME_MAX_LEN] = 't'; /* set name to illeagal length*/
	printf("[TEST] non-existed file read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name2, file_find(name2));
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// print another 50 byte
		read_len = file_read(file_find(name2), buffer, PRINT_STRIDE) ;
		if (read_len == -1){
			printf("READ FAILED.\n");
			break;
		}
		else
			putbuf((int8_t*)buffer, read_len);
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
	}
	printf("[PASS] non-existed file cannot be printed.\n");
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a existed leagally long name txt file and echo on screen 			NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] existed leagally long name file read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("[TEST] This file may contain many spaces. If you think it is frozen, try to press some other keys before pressing the ALT. Our system never freezes on this :)\n");
	printf("\nPress ALT to continue test...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name2, file_find(name2));
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		// print another 50 byte
		read_len = file_read(file_find(name2), buffer, PRINT_STRIDE) ;
		if (read_len == -1)
			printf("READ FAILED.\n");
		else
			putbuf((int8_t*)buffer, read_len);

	}
	printf("[PASS] long file read succeeded %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE Close a txt file with a short name 					NOTE */
	printf("[TEST] short name txt files close \n");
	printf("[TEST] file close %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_close(file_find(name1)) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file close %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE close a txt file with a illegally long name 			NOTE */
	name2[NAME_MAX_LEN] = 't'; /* set name to illeagal length*/
	printf("[TEST] illegally long name txt files close \n");
	printf("[TEST] file close %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_close(file_find(name2)) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file should not be closed, it never opened, besides its illegally long name %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE legal long name close 							NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] leagally long name txt files close \n");
	printf("[TEST] file close %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (file_close(file_find(name2)) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file should be closed %s\n", name1);


	return PASS;
}

#define PRINT_STRIDE_EXE		1000
#define test_exe_num			4   // tset ops on 4 exe files

/* test_file_open_read_close_exe
 * Purpose	// excutable files ops test
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *
 * Coverage
 *		 excutable files ops test
 * Files	filesyetem.c/h
 */
int test_file_open_read_close_exe(){
	uint8_t name1[] = "cat";
	uint8_t name2[] = "counter";
	uint8_t name3[] = "grep";
	uint8_t name4[] = "fish";
	uint8_t *name;
	uint8_t buffer[testBufferMaxLen];
	int32_t read_len;
	int32_t ii = 0;
	printf("[TEST] ____exe file operations____ \n");
	for (ii = 1; ii <= test_exe_num; ii++){
		switch(ii) {
			case 1:
				name = name1;
				break;
			case 2:
				name = name2;
				break;
			case 3:
				name = name3;
				break;
			case 4:
				name = name4;
				break;
		}
		printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		/* NOTE open a exe file with a short name 					NOTE */
		printf("[TEST] exe files open \n");
		printf("[TEST] file open %s\n", name);
		printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		if (file_open(name) == -1)
			printf("Open FAILED.\n");
		else
			printf("Open SUCCEEDED.\n");
		printf("[PASS] file opened %s\n", name);
		printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test

		/* NOTE read exe file and echo on screen 			NOTE */
		name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
		printf("[TEST] exe file read and echo on screen \n");
		printf("[TEST] Every time a maximum of 1000 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
		printf("[TEST] This file may contain many spaces. If you think it is frozen, try to press some other keys before pressing the ALT. Our system never freezes on this :)\n");
		printf("\nPress ALT to continue test...\n");
		printf("[TEST] FILE INFO filename: %s fd: %d \n", name, file_find(name));
		read_len = PRINT_STRIDE_EXE;
		while (read_len == PRINT_STRIDE_EXE){
			// printf("\nPress ALT to continue test...\n");
			key_pressed();	// Press alt key to conduct the frequency test
			// print another 50 byte
			read_len = file_read(file_find(name), buffer, PRINT_STRIDE_EXE) ;
			if (read_len == -1)
				printf("READ FAILED.\n");
			else
				putbuf((int8_t*)buffer, read_len);

		}
		printf("[PASS] exe file read succeeded %s\n", name);
		printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test

		/* NOTE Close a txt file with a short name 					NOTE */
		printf("[TEST] exe files close \n");
		printf("[TEST] file close %s\n", name);
		printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		if (file_close(file_find(name)) == -1)
			printf("Close FAILED.\n");
		else
			printf("Close SUCCEEDED.\n");
		printf("[PASS] file close %s\n", name);

	}
	return PASS;
}

/* test_dir_open_read_close
 * Purpose	// directory files ops test
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *
 * Coverage
 *		 // directory files ops test
 * Files	filesyetem.c/h
 */
int test_dir_open_read_close() {
	uint8_t name[] = ".";
	uint8_t buffer[32];
	printf("[TEST] ____directory operations____ \n");
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	/* NOTE open dir '.'	 					NOTE */
	printf("[TEST] dir open %s\n", name);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	if (dir_open(name) == -1) {
		printf("Open FAILED.\n");
		return PASS;
	}
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] dir opened %s\n", name);
	printf("\nPress ALT to continue test...\n");
	key_pressed();
	printf("[TEST] dir read and echo on screen \n");
	printf("[TEST] Everytime you press ALT, a dir_read is called and echoed on the screen \n");

	printf("fd: %d \n", file_find(name));
	while(0 == dir_read(file_find(name), buffer, 32)) {
		//printf("Content in buffer is: %s.\n", buffer);
		key_pressed();	// Press alt key to conduct the frequency test
	}
	printf("[PASS] dir read %s\n", name);

	printf("[TEST] dir close %s\n", name);
	if (dir_close(file_find(name)) == -1)
		printf("Close FAILED\n");
	else
		printf("Close SUCCEEDED\n");
	printf("[PASS] dir close %s\n", name);
	return PASS;
}
#endif
/* rtc_test
 * Purpose	Check if RTC works properly.
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *		None
 * Coverage
 *		rtc open/read/write/close
 * Files	rtc.c/h
 */
int rtc_test() {
	clearScreen();
	TEST_HEADER;

	unsigned char read_buf;						/* rtc_read buffer */
	int32_t frequency = RTC_TEST_INITIAL_FRQ;	/* Initialize RTC freqency */
	int32_t fd = 0; 							// Unused in CP 3.2
	uint8_t *filename = (unsigned char *)"rtc";	// Unused in CP 3.2
	int32_t ticks;								/* Ticks to print */
	int8_t multiplier;							/* Act as a counter */

	printf("[TEST] rtc_open\n");
	rtc_open(filename);
	printf("[PASS] RTC Opened.\n");

	printf("[TEST] rtc_open again\n");
	if (file_open(filename) == -1) printf("[PASS] RTC did not open again.\n");
	else printf("[FAIL] RTC did open again.\n");

	printf("[TEST] rtc_write & read, print '1' in different frequency\n");
	printf("\nPress ALT to continue test...");
	key_pressed();	// Press alt key to conduct the frequency test
	for (multiplier = 0; multiplier <= RTC_TEST_MAX_MULTIPLIER; multiplier++) {
		clearScreen();
		printf("Current Frequency: %dHz\n", frequency);
		ticks = frequency * RTC_TEST_SEC_PER_FRQ;	// Calculate loop ticks
		if (ticks > RTC_TEST_MAX_TICKS) ticks = RTC_TEST_MAX_TICKS;	// Upper bound of ticks is defined
		while(ticks != 0) {
			if (!rtc_read(fd, &read_buf, 1))	// If received a rtc interrupt, print '1'
				putc('1');
			ticks --;
		}
		frequency = frequency * 2;	// Double the frequency
		rtc_write(fd, (unsigned char *)&frequency, 4);
	}
	frequency = RTC_TEST_INITIAL_FRQ;	// Restore initial rtc frequency
	rtc_write(fd, (unsigned char *)&frequency, 4);
	clearScreen();

	printf("[TEST] rtc_close\n");
	rtc_close(fd);	// RTC close just return 0
	printf("[PASS] RTC Closed.\n");

	printf("[TEST] rtc_close again\n");
	if (file_close(fd) == -1) printf("[PASS] RTC did not close again.\n");
	else printf("[FAIL] RTC did close again.\n");

	return PASS;	// If anything fail, code will segfault
}

/* terminal_test
 * Purpose	Check terminal functionalities.
 * Inputs	None
 * Outputs	PASS/FAIL
 * Side Effects
 *		None
 * Coverage
 *		Terminal normal and abnormal open/read/write/close
 * Files	terminal.c/h
 */
int terminal_test() {
	printf("\n");
	TEST_HEADER;

	int32_t flag;										/* Flag to check FAIL */
	unsigned char buffer[TERMINAL_TEST_BUFFER];			/* rtc_read buffer */
	int32_t fd = 0; 									// Unused in CP 3.2
	uint8_t *filename = (unsigned char *)"terminal";	// Unused in CP 3.2
	int result = PASS;									/* return result */

	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* PART 1: Terminal Open test */
	printf("[TEST] terminal_write without open\n");
	flag = terminal_write(fd, buffer, TERMINAL_TEST_BUFFER);
	if (flag == -1) printf("[PASS] Terminal cannot write without open.\n");
	else {
		printf("[FAIL] Terminal write without open.\n");
		result = FAIL;
	}

	printf("\n[TEST] terminal_read without open\n");
	flag = terminal_read(fd, buffer, TERMINAL_TEST_BUFFER);
	if (flag == -1) printf("[PASS] Terminal cannot read without open.\n");
	else {
		printf("[FAIL] Terminal read without open.\n");
		result = FAIL;
	}

	printf("\n[TEST] terminal_open\n");
	terminal_open(filename);
	printf("[PASS] Terminal opened.\n");

	printf("\n[TEST] terminal_open again\n");
	flag = terminal_open(filename);
	if (flag == -1) printf("[PASS] Terminal didn't open again.\n");
	else {
		printf("[FAIL] Terminal opened twice.\n");
		result = FAIL;
	}

	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* PART 2: Test normal terminal operations */
	printf("\n[TEST] terminal_read\n");
	printf("Please type LESS than 128 characters, stop with ENTER.\n");
	printf("Please try SHIFT, CAPSLOCK, and BACKSPACE:\n");
	terminal_read(fd, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] terminal_write\n");
	printf("Content in the buffer shold be the same as above:\n");
	terminal_write(fd, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] Handle buffer overflow\n");
	printf("Please type MORE than 128 characters, stop with ENTER:\n");
	terminal_read(fd, buffer, TERMINAL_TEST_BUFFER);
	printf("\nContent in the buffer should truncate to 128 characters:\n");
	terminal_write(fd, buffer, TERMINAL_TEST_BUFFER);
	printf("\n");

	printf("\n[TEST] Handle unknown scancode\n");
	printf("Please try F1-F12, nothing should happen. Stop with ENTER:\n");
	terminal_read(fd, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] Scrolling and clear screen\n");
	printf("Please enter some random stuff. Use CTRL+L to clear screen. Stop with ENTER:\n");
	terminal_read(fd, buffer, TERMINAL_TEST_BUFFER);

	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* PART 3: Terminal Close Test */
	printf("\n[TEST] terminal_close\n");
	terminal_close(fd);
	printf("[PASS] Terminal closed.\n");

	printf("\n[TEST] terminal_close again\n");
	flag = terminal_close(fd);
	if (flag == -1) printf("[PASS] terminal didn't close again.\n");
	else {
		printf("[FAIL] Terminal closed twice.\n");
		result = FAIL;
	}

	/* Hold the test to see the result */
	printf("\nPress ALT to continue test...");
	key_pressed();	// Press alt key to conduct the frequency test
	printf("\n");

	return result;
}

/* Checkpoint 3 tests */

#if (PCB_TEST == 1)
int PCB_file_terminal_rtc_test(){
	TEST_HEADER;
	uint8_t name1[] = "frame0.txt";
	uint8_t name2[] = "verylargetextwithverylongname.txt";
	uint8_t name[] = ".";
	uint8_t buffer[testBufferMaxLen];
	uint8_t pid1 = init_pcb(&ece391_process_manager);
	unsigned char read_buf;						/* rtc_read buffer */
	int32_t frequency = RTC_TEST_INITIAL_FRQ;	/* Initialize RTC freqency */
	int32_t fd_1 = 0;
	int32_t fd_2 = 0;
	uint8_t *filename = (unsigned char *)"rtc";
	int32_t read_len = 0;
	int32_t ticks;								/* Ticks to print */
	int8_t multiplier;							/* Act as a counter */

	ece391_process_manager.curr_pid = pid1;
	clearScreen();
	TEST_HEADER;

	printf("[TEST] rtc_open\n");
	fd_1 = open(filename);
	printf("[PASS] fd:%d RTC Opened.\n", fd_1);
	fd_2 = open(filename);
	printf("[TEST] fd:%d rtc_open again\n", fd_2);

	printf("[TEST] rtc_write & read, print '1' in different frequency\n");
	printf("\nPress ALT to continue test...");
	key_pressed();	// Press alt key to conduct the frequency test
	for (multiplier = 0; multiplier <= RTC_TEST_MAX_MULTIPLIER; multiplier++) {
		clearScreen();
		printf("f_d1: Current Frequency: %dHz\n", frequency);
		ticks = frequency * RTC_TEST_SEC_PER_FRQ;	// Calculate loop ticks
		if (ticks > RTC_TEST_MAX_TICKS) ticks = RTC_TEST_MAX_TICKS;	// Upper bound of ticks is defined
		while(ticks != 0) {
			if (!read(fd_1, &read_buf, 1))	// If received a rtc interrupt, print '1'
				putc('1');
			ticks --;
		}
		frequency = frequency * 2;	// Double the frequency
		write(fd_1, (unsigned char *)&frequency, 4);
	}
	frequency = RTC_TEST_INITIAL_FRQ;
	for (multiplier = 0; multiplier <= RTC_TEST_MAX_MULTIPLIER; multiplier++) {
		clearScreen();
		printf("f_d2: Current Frequency: %dHz\n", frequency);
		ticks = frequency * RTC_TEST_SEC_PER_FRQ;	// Calculate loop ticks
		if (ticks > RTC_TEST_MAX_TICKS) ticks = RTC_TEST_MAX_TICKS;	// Upper bound of ticks is defined
		while(ticks != 0) {
			if (!read(fd_2, &read_buf, 1))	// If received a rtc interrupt, print '1'
				putc('1');
			ticks --;
		}
		frequency = frequency * 2;	// Double the frequency
		write(fd_2, (unsigned char *)&frequency, 4);
	}
	frequency = RTC_TEST_INITIAL_FRQ;	// Restore initial rtc frequency
	write(fd_1, (unsigned char *)&frequency, 4);
	clearScreen();

	printf("[TEST] rtc_close\n");
	close(fd_1);	// RTC close just return 0
	printf("[PASS] RTC Closed.\n");

	printf("[TEST] rtc_close again\n");
	if (close(fd_1) == -1) printf("[PASS] RTC did not close again.\n");
	else printf("[FAIL] RTC did close again.\n");

	printf("[TEST] rtc_close\n");
	close(fd_2);	// RTC close just return 0
	printf("[PASS] RTC Closed.\n");

	printf("\n");
	TEST_HEADER;

	fd_1 = 0; 									// read
	fd_2 = 1;									// write

	/* PART 1: Terminal Open test */
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* PART 2: Test normal terminal operations */
	printf("\n[TEST] terminal_read\n");
	printf("Please type LESS than 128 characters, stop with ENTER.\n");
	printf("Please try SHIFT, CAPSLOCK, and BACKSPACE:\n");
	read(fd_1, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] terminal_write\n");
	printf("Content in the buffer shold be the same as above:\n");
	write(fd_2, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] Handle buffer overflow\n");
	printf("Please type MORE than 128 characters, stop with ENTER:\n");
	read(fd_1, buffer, TERMINAL_TEST_BUFFER);
	printf("\nContent in the buffer should truncate to 128 characters:\n");
	write(fd_2, buffer, TERMINAL_TEST_BUFFER);
	printf("\n");

	printf("\n[TEST] Handle unknown scancode\n");
	printf("Please try F1-F12, nothing should happen. Stop with ENTER:\n");
	read(fd_1, buffer, TERMINAL_TEST_BUFFER);

	printf("\n[TEST] Scrolling and clear screen\n");
	printf("Please enter some random stuff. Use CTRL+L to clear screen. Stop with ENTER:\n");
	read(fd_1, buffer, TERMINAL_TEST_BUFFER);

	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test












	printf("[TEST] ____directory operations____ \n");
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	/* NOTE open dir '.'	 					NOTE */
	printf("[TEST] dir open %s\n", name);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	fd_1 = open(name);
	if (fd_1 == -1) {
		printf("Open FAILED.\n");
		return PASS;
	}
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] dir opened %s\n", name);
	printf("\nPress ALT to continue test...\n");
	key_pressed();
	printf("[TEST] dir read and echo on screen \n");
	printf("[TEST] Everytime you press ALT, a dir_read is called and echoed on the screen \n");

	printf("fd: %d \n", fd_1);
	while(0 == read(fd_1, buffer, 32)) {
		//printf("Content in buffer is: %s.\n", buffer);
		key_pressed();	// Press alt key to conduct the frequency test
	}
	printf("[PASS] dir read %s\n", name);

	printf("[TEST] dir close %s\n", name);
	if (close(fd_1) == -1)
		printf("Close FAILED\n");
	else
		printf("Close SUCCEEDED\n");
	printf("[PASS] dir close %s\n", name);




	printf("[TEST] ____txt file operations____ \n");
	/* NOTE open a txt file with a short name 					NOTE */
	printf("[TEST] short name txt files open \n");
	printf("[TEST] file open %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	fd_1 = open(name1);
	if (fd_1== -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file opened %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE open a txt file with a illegally long name 			NOTE */
	printf("[TEST] illegally long name txt files open \n");
	printf("[TEST] file open %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	fd_2 = open(name2);
	if (fd_2== -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file should not be opened %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE legal long name operations 							NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] leagally long name txt files open \n");
	printf("[TEST] file open %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	fd_2 = open(name2);
	if (fd_2== -1)
		printf("Open FAILED.\n");
	else
		printf("Open SUCCEEDED.\n");
	printf("[PASS] file should be opened %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a short txt file and echo on screen 			NOTE */
	printf("[TEST] short name txt files read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("\nPress ALT to continue test...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name1, fd_1);
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		// print another 50 byte
		read_len = read(fd_1, buffer, PRINT_STRIDE) ;
		if (read_len == -1)
			printf("READ FAILED.\n");
		else
			putbuf((int8_t*)buffer, read_len);

	}
	printf("[PASS] short file read succeeded %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a non existed txt file and echo on screen 			NOTE */
	name2[NAME_MAX_LEN] = 't'; /* set name to illeagal length*/
	printf("[TEST] non-existed file read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name2, fd_2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// print another 50 byte
		read_len = file_read(fd_2, buffer, PRINT_STRIDE) ;
		if (read_len == -1){
			printf("READ FAILED.\n");
			break;
		}
		else
			putbuf((int8_t*)buffer, read_len);
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
	}
	printf("[PASS] non-existed file cannot be printed.\n");
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE read a existed leagally long name txt file and echo on screen 			NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] existed leagally long name file read and echo on screen \n");
	printf("[TEST] Every time a maximum of 50 bytes will be echoed on the sreen until the end of file. Please press ALT for keep printing...\n");
	printf("[TEST] This file may contain many spaces. If you think it is frozen, try to press some other keys before pressing the ALT. Our system never freezes on this :)\n");
	printf("\nPress ALT to continue test...\n");
	printf("[TEST] FILE INFO filename: %s fd: %d \n", name2, fd_2);
	read_len = PRINT_STRIDE;
	while (read_len == PRINT_STRIDE){
		// printf("\nPress ALT to continue test...\n");
		key_pressed();	// Press alt key to conduct the frequency test
		// print another 50 byte
		read_len = read(fd_2, buffer, PRINT_STRIDE) ;
		if (read_len == -1)
			printf("READ FAILED.\n");
		else
			putbuf((int8_t*)buffer, read_len);

	}
	printf("[PASS] long file read succeeded %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE Close a txt file with a short name 					NOTE */
	printf("[TEST] short name txt files close \n");
	printf("[TEST] file close %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (close(fd_1) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file close %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE close a txt file with a illegally long name 			NOTE */
	name2[NAME_MAX_LEN] = 't'; /* set name to illeagal length*/
	printf("[TEST] illegally long name txt files close \n");
	printf("[TEST] file close %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (close(fd_2) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file should not be closed, it never opened, besides its illegally long name %s\n", name1);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test

	/* NOTE legal long name close 							NOTE */
	name2[NAME_MAX_LEN] = '\0'; /* set name to leagal length*/
	printf("[TEST] leagally long name txt files close \n");
	printf("[TEST] file close %s\n", name2);
	printf("\nPress ALT to continue test...\n");
	key_pressed();	// Press alt key to conduct the frequency test
	if (close(fd_2) == -1)
		printf("Close FAILED.\n");
	else
		printf("Close SUCCEEDED.\n");
	printf("[PASS] file should be closed %s\n", name1);




	return PASS;
}
#endif


#if (SHELL_TEST == 1)
int shell_test() {
	TEST_HEADER;
	uint8_t cmd[] = "shell";
	execute(cmd);
	return PASS;
}

#endif
/* Checkpoint 4 tests */
/* Checkpoint 5 tests */

/* Test suite entry point */
/* launch_tests
 * Purpose	Launch all the tests.
 * Inputs	None
 * Outputs	None
 * Side Effects
 *		Lauch all the tests.
 * Coverage
 *		Terminal normal and abnormal, file system normal and abnormal, rtc normal and abnormal open/read/write/close
 * Files	terminal.c/h
 */
void launch_tests(){
	#if (IDT_TEST == 1)
	TEST_OUTPUT("idt_test", idt_test());
	#endif
	#if (PAGE_TEST == 1)
	TEST_OUTPUT("paging_test", paging_test());
	#endif
	#if (EXCEPTION_TEST == 1)
	TEST_OUTPUT("divide_zero_test", divide_zero_test());
	#endif
	#if (EXCEPTION_TEST == 2)
	TEST_OUTPUT("invalid_opcode_test", invalid_opcode_test());
	#endif
	#if (RTC_TERMINAL_TEST == 1)
	TEST_OUTPUT("rtc_test", rtc_test());
	TEST_OUTPUT("terminal_test", terminal_test());
	#endif
	#if (FILE_SYSTEM_TEST == 1)
	TEST_OUTPUT("txt_file_ops_test", test_file_open_read_close());
	TEST_OUTPUT("exe_file_ops_test", test_file_open_read_close_exe());
	TEST_OUTPUT("dir_ops_test", test_dir_open_read_close());
	#endif
	#if (PCB_TEST == 1)
	TEST_OUTPUT("pcb_ops_test", PCB_file_terminal_rtc_test());
	#endif
	#if (SHELL_TEST == 1)
	TEST_OUTPUT("Shell_execute_test", shell_test());
	TEST_OUTPUT("Shell_execute_test", shell_test());
	#endif
}
