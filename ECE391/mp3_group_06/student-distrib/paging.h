/* paging.h - Initialize paging
 * vim:ts=4 noexpandtab
 */
#ifndef PAGE_H
#define PAGE_H

#include "lib.h"
#include "types.h"

/* Macros regards size */
#define PAGE_DIRECTORY_SIZE     1024
#define PAGE_TABLE_SIZE         1024
#define _4KB                    4096        /* 4KB = 4096Bytes, 2^12*/
#define _4MB                    4194304     /* 4MB = 1024*4096Bytes, 2^22*/

/* Mask for Paging Directory/Table entries */
#define PRESENT_MASK            0x00000001  /* Clear present will clear all other bits */
#define R_W_MASK                0x00000002  /* Need to turn on read/write */
#define U_S_MASK                0x00000004
#define PWT_MASK                0x00000008
#define PCD_MASK                0x00000010
#define ACCESSED_MASK           0x00000020  /* This bit will be set after access */
#define DIRTY_MASK              0x00000040  /* This bit will be set after content change */
#define PAGE_SIZE_MASK          0x00000080  /* 4KB page when 0, 4MB page when 1 */
#define AVAILABLE_MASK          0x00000E00
#define PTBA_MASK               0xFFFFF000  /* Page Table Base Addr, in Directory */
#define PBA_4K_MASK             0xFFFFF000  /* 4KB Page Base Addr, in Table */
#define PBA_4M_MASK             0xFFC00000  /* 4MB Page Base Addr, in Directory */

/* Kernel and Video addr */
#define KERNEL_START            0x00400000
#define VIDEO_START             0x000B8000
#define VIDEO_VIRTUAL           0xB8
#define TERMINAL1_START         0x000B9000
#define TERMINAL1_VIRTUAL       0xB9
#define TERMINAL2_START         0x000BA000
#define TERMINAL2_VIRTUAL       0xBA
#define TERMINAL3_START         0x000BB000
#define TERMINAL3_VIRTUAL       0xBB
#define USER_START_VIRTUAL      0x08000000
#define PDEIDX_128MB            32
#define USER_IMAGE_START        0x08048000
#define USER_VIDEO              (USER_START_VIRTUAL + _4MB + _4KB)
#define PDEIDX_132MB            33
#define PTEIDX_132_4KB          1

/* Control Registers' Flag Masks */
#define CR0_PG_FLAG             0x80000000
#define CR4_PSE_FLAG            0x00000010
#define CR4_PAE_FLAG            0x00000020
#define CR4_PGE_FLAG            0x00000080

/* Page Directory/Table Entry variable type */
typedef unsigned int pde_t;
typedef unsigned int pte_t;

/* Definition of Global Page Directory/Table */
extern pde_t page_directory[PAGE_DIRECTORY_SIZE];
extern pte_t page_table_0[PAGE_TABLE_SIZE];
extern pte_t page_table_33[PAGE_TABLE_SIZE];

extern void write_cr3(unsigned long val);
/* Global Function */
extern void init_paging(void);

//map the 128MB virtual address to the corresponding physical address
extern void user_page_mapping(uint8_t pid);

//unmaps the 128MB virtual address of the process
extern void user_page_unmapping(uint8_t pid);

//maps the 132mb+4kb address to the video memory physical address
extern void user_video_mapping();

//unmaps the 132mb+4kb address to the video memory physical address
extern void user_video_unmapping();

//used to map actual video memory to the correct terminal, does not map background tasks
extern void switch_terminal_video(uint8_t from, uint8_t to);

//used to set up paging for the current process in the destination terminal, do not need if no
//process exists in the destination terminal, because paging is set up by execute call in that case
extern void switch_terminal_paging(int8_t destination_pid);
//function to initialize tempory terminal video memory
extern void clear_terminal_video(char* terminal_video);
//function used for switching user video mapping when running user program in background
extern void background_uservideo_paging(uint8_t display_terminal_num, uint8_t execute_terminal_num);
#endif
