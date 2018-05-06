/* paging.c - Initialize paging
 * vim:ts=4 noexpandtab
 */
#include "paging.h"

/* Declaration of Global Page Directory/Table */
pde_t page_directory[PAGE_DIRECTORY_SIZE] __attribute__((aligned (_4KB)));
pte_t page_table_0[PAGE_TABLE_SIZE] __attribute__((aligned (_4KB)));
pte_t page_table_33[PAGE_TABLE_SIZE] __attribute__((aligned (_4KB)));

/* Static function definition */
static inline unsigned long read_cr0(void);
static inline unsigned long read_cr4(void);
static inline void write_cr0(unsigned long val);
static inline void write_cr4(unsigned long val);
static inline void set_in_cr0 (unsigned long mask);
// static inline void clear_in_cr0 (unsigned long mask);
static inline void set_in_cr4 (unsigned long mask);
static inline void clear_in_cr4 (unsigned long mask);

/* read_cr0
 * Purpose	Read in CR0 register value
 * Inputs	None
 * Outputs	CR0 value
 * Side Effects None
 */
static inline unsigned long read_cr0(void) {
    unsigned long val;
    asm volatile("movl %%cr0,%0\n\t" :"=r" (val));
    return val;
}

/* read_cr4
 * Purpose	Read in CR4 register value
 * Inputs	None
 * Outputs	CR4 value
 * Side Effects None
 */
static inline unsigned long read_cr4(void) {
    unsigned long val;
    asm volatile("movl %%cr4,%0\n\t" :"=r" (val));
    return val;
}

/* write_cr0
 * Purpose	Set CR0 register value
 * Inputs	CR0 value
 * Outputs	None
 * Side Effects CR0 value changed
 */
static inline void write_cr0(unsigned long val) {
    asm volatile("movl %0,%%cr0": :"r" (val));
}

/* write_cr3
 * Purpose	Set CR3 register value
 * Inputs	CR3 value
 * Outputs	None
 * Side Effects CR3 value changed
 */
inline void write_cr3(unsigned long val) {
    asm volatile("movl %0,%%cr3": :"r" (val));
}

/* write_cr4
 * Purpose	Set CR4 register value
 * Inputs	CR4 value
 * Outputs	None
 * Side Effects CR4 value changed
 */
static inline void write_cr4(unsigned long val) {
    asm volatile("movl %0,%%cr4": :"r" (val));
}

/* set_in_cr0
 * Purpose	Set CR0 register bit without change other bits
 * Inputs	Mask for bits want to set
 * Outputs	None
 * Side Effects CR0 value changed
 */
static inline void set_in_cr0(unsigned long mask) {
    unsigned long cr0;
    cr0 = read_cr0();
    cr0 |= mask;
    write_cr0(cr0);
}

// Does not use in this CP3.1, reserved for future use
/* clear_in_cr0
 * Purpose	Clear CR0 register bit without change other bits
 * Inputs	Mask for bits want to clear
 * Outputs	None
 * Side Effects CR0 value changed
 */
/*static inline void clear_in_cr0(unsigned long mask) {
    unsigned long cr0;
    cr0 = read_cr0();
    cr0 &= ~mask;
    write_cr0(cr0);
}*/

/* set_in_cr4
 * Purpose	Set CR4 register bit without change other bits
 * Inputs	Mask for bits want to set
 * Outputs	None
 * Side Effects CR4 value changed
 */
static inline void set_in_cr4(unsigned long mask) {
	unsigned long cr4;
	cr4 = read_cr4();
	cr4 |= mask;
	write_cr4(cr4);
}

/* clear_in_cr4
 * Purpose	Clear CR4 register bit without change other bits
 * Inputs	Mask for bits want to clear
 * Outputs	None
 * Side Effects CR4 value changed
 */
static inline void clear_in_cr4(unsigned long mask) {
	unsigned long cr4;
	cr4 = read_cr4();
	cr4 &= ~mask;
	write_cr4(cr4);
}

/* init_paging
 * Purpose	Turn on paging
 * Inputs	None
 * Outputs	None
 * Side Effects CR0,3,4 value changed, paging turned on
 */
void init_paging(void) {
	unsigned int i, j;
	/* Flush page directory */
    for (i = 0; i < PAGE_DIRECTORY_SIZE; i++) {
        page_directory[i] = 0x00000000;
    }

    /* Flush page table 0 */
    for (j = 0; j < PAGE_TABLE_SIZE; j++) {
        page_table_0[j] = 0x00000000;
    }

    /* Points to the page_table_0 */
    page_directory[0] = ((unsigned long)(page_table_0) & PTBA_MASK) | PRESENT_MASK | R_W_MASK;

    /* Points to the start of Video memory */
    page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
    /*3 terminal memory*/
    page_table_0[TERMINAL1_VIRTUAL] = TERMINAL1_START | R_W_MASK | PRESENT_MASK;
    page_table_0[TERMINAL2_VIRTUAL] = TERMINAL2_START | R_W_MASK | PRESENT_MASK;
    page_table_0[TERMINAL3_VIRTUAL] = TERMINAL3_START | R_W_MASK | PRESENT_MASK;
    /* Kernel 4MB page, present, R/W on */
    page_directory[1] = KERNEL_START | PAGE_SIZE_MASK | R_W_MASK | PRESENT_MASK;

    /* Set CR4 Flags */
    clear_in_cr4(CR4_PAE_FLAG);   /* PAE set to 0 */
	  set_in_cr4(CR4_PSE_FLAG);   /* PSE set to 1 */

	/* Set CR3 */
    write_cr3((unsigned long)page_directory);   /* This instruction flushed the tlb */

    /* Set CR0 bit 31*/
    set_in_cr0(CR0_PG_FLAG);    /* Assert Page Table is turned on */
}

/* user_page_mapping
 * Purpose	map the 128MB virtual address to the corresponding physical address
 * Inputs	pid(the current process number, the first program pid is 1)
 * Outputs	None
 * Side Effects flushes tlb
 */
void user_page_mapping(uint8_t pid) {
    pde_t page_128mb;
    if (pid >= 1) {
        page_128mb = ((pid + 1) * _4MB) | PAGE_SIZE_MASK | R_W_MASK | U_S_MASK | PRESENT_MASK;
        //map the virtual 128mb to the corresponding physical address
        page_directory[PDEIDX_128MB] = page_128mb;
        write_cr3((unsigned long)page_directory);   /* This instruction flushed the tlb */
    } else {
        ERROR_MSG;
        printf("Invalid PID.\n");
    }
}

/* user_page_unmapping
 * Purpose	unmap the 128MB virtual address of the process, used when halting the current process
 * Inputs	pid(the current process number, the first program pid is 1)
 * Outputs	None
 * Side Effects flushes tlb
 */
void user_page_unmapping(uint8_t pid) {
    if (pid >= 1) {
        //unmaps the virtual 128mb
        page_directory[PDEIDX_128MB] = 0;
        write_cr3((unsigned long)page_directory);   /* This instruction flushed the tlb */
    }
    else {
        ERROR_MSG;
        printf("Invalid PID.\n");
    }
}

/* user_video_mapping
 * Purpose	maps the 132mb+4kb address to the video memory physical address
 * Inputs none
 * Outputs	None
 * Side Effects flushes tlb
 */
void user_video_mapping() {
  pde_t page_132mb;
  pte_t page_132mb_4kb;
  /*set the correct pde and pte*/
  page_132mb = ((unsigned long)&(page_table_33[PTEIDX_132_4KB]) & PTBA_MASK) | U_S_MASK | R_W_MASK | PRESENT_MASK;
  page_132mb_4kb =  VIDEO_START | U_S_MASK | R_W_MASK | PRESENT_MASK;
  /*set value in the correct position*/
  page_directory[PDEIDX_132MB] = page_132mb;
  page_table_33[PTEIDX_132_4KB] = page_132mb_4kb;
  /* This instruction flushed the tlb */
  write_cr3((unsigned long)page_directory);
}

/* user_video_unmapping
 * Purpose	unmaps the 132mb+4kb address to the video memory physical address
 * Inputs none
 * Outputs	None
 * Side Effects flushes tlb
 */
void user_video_unmapping() {
  /*clean appropriate pde and pte*/
  page_table_33[PTEIDX_132_4KB] = 0;
  page_directory[PDEIDX_132MB] = 0;
  /* This instruction flushed the tlb */
  write_cr3((unsigned long)page_directory);
}

/* switch_terminal_video
 * Purpose	used to map actual video memory to the correct terminal, does not map round tasks
 * Inputs from: the current terminal; to: the terminal switching to.
 * Outputs	None
 * Side Effects None
 */
void switch_terminal_video(uint8_t from, uint8_t to) {
    if (from > 2 || to > 2) {
        ERROR_MSG;
        printf("Invalid terminal number.\n");
    }
    //save displayed video memory to temp, echo the temp to displayed video memory
    cli();
    pde_t page_temp = page_table_0[VIDEO_VIRTUAL];
    page_table_0[VIDEO_VIRTUAL] = VIDEO_START | R_W_MASK | PRESENT_MASK;
    write_cr3((unsigned long)page_directory);

    memcpy((char*)(TERMINAL1_START +  (uint32_t)from * _4KB), (char*)(VIDEO_START), _4KB);
    memcpy((char*)(VIDEO_START), (char*)(TERMINAL1_START + (uint32_t)to * _4KB), _4KB);

    page_table_0[VIDEO_VIRTUAL] = page_temp;
    write_cr3((unsigned long)page_directory);
    sti();
    //write_cr3((unsigned long)page_directory);   /* This instruction flushed the tlb */
}

/* switch_terminal_paging
 * Purpose	used to set up paging for the current process in the destination terminal, do not need if no
            //process exists in the destination terminal, because paging is set up by execute call in that case
 * Inputs destination_pid: the pid number of current process in the destination terminal
 * Outputs	None
 * Side Effects flushes tlb
 */
void switch_terminal_paging(int8_t destination_pid) {
    pde_t page_128mb;
    if (destination_pid >= 1) {
        page_128mb = ((destination_pid + 1) * _4MB) | PAGE_SIZE_MASK | R_W_MASK | U_S_MASK | PRESENT_MASK;
        //map the virtual 128mb to the corresponding physical address
        page_directory[PDEIDX_128MB] = page_128mb;
        write_cr3((unsigned long)page_directory);   /* This instruction flushed the tlb */
    } else {
        ERROR_MSG;
        printf("Invalid PID.\n");
    }
}

/* background_uservideo_paging
 * Purpose function used for switching user video mapping when running user program in background
 * Inputs display_terminal_num: terminal number of the current terminal in display;
          execute_terminal_num: terminal number of the terminal in which the user program is running;
 * Outputs	None
 * Side Effects flushes tlb
 */
//
extern void background_uservideo_paging(uint8_t display_terminal_num, uint8_t execute_terminal_num) {
    pde_t page_132mb_4kb;
    pde_t page_132mb_4kb_2;

    if (display_terminal_num == execute_terminal_num) {
        page_132mb_4kb =  VIDEO_START | U_S_MASK | R_W_MASK | PRESENT_MASK;
        page_table_33[PTEIDX_132_4KB] = page_132mb_4kb;
        page_132mb_4kb_2 =  VIDEO_START | R_W_MASK | PRESENT_MASK;
        page_table_0[VIDEO_VIRTUAL] = page_132mb_4kb_2;
    }
    else {
        page_132mb_4kb =  (TERMINAL1_START + execute_terminal_num * _4KB) | U_S_MASK | R_W_MASK | PRESENT_MASK;
        page_table_33[PTEIDX_132_4KB] = page_132mb_4kb;
        page_132mb_4kb_2 =  (TERMINAL1_START + execute_terminal_num * _4KB) | R_W_MASK | PRESENT_MASK;
        page_table_0[VIDEO_VIRTUAL] = page_132mb_4kb_2;
    }
    /* This instruction flushed the tlb */
    write_cr3((unsigned long)page_directory);
}

/* void clear_terminal_video(void);
 * Purpose: function to initialize tempory terminal video memory
 * Inputs: terminal_video: the video memory to initialize
 * Return Value: none */
void clear_terminal_video(char* terminal_video) {
    int32_t i;
    for (i = 0; i < NUM_ROWS * NUM_COLS; i ++) {
        *(uint8_t *)(terminal_video + (i << 1)) = ' ';
        *(uint8_t *)(terminal_video + (i << 1) + 1) = ATTRIB;
    }
}
