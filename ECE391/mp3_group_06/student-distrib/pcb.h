#ifndef PCB_H
#define PCB_H

#include "types.h"

// total number of files a single PCB is holding
#define FA_SIZE                 8
#define STATUS_CLOSED           67      // 'C' indecates file closed
#define STATUS_OPENED           79      // 'O' indicates file opened
#define MAX_PROCESS_NUM         6       // for now, set the process number upper limit to 2
// following two are for ece391_process_manager.process_status
#define PROCESS_EXIST           1
#define PROCESS_NOT_EXIST       0
// constant for initialzing pcb
#define PCB_BASE_ADDR           0x800000    // the base address for storing PCB, 8MB
#define PCB_SEG_LENGTH          0x2000      // each segment should be offset from the base, 8KB
// signal for exception
#define HALT_NORM               0
#define HALT_EXC                1
// argument bufferlength
#define ARG_BUF_LEN             128     // argument buffer length
// flag signal for vidmap
#define VIDMAP_EXIST            1       // the flag for vidmap that is allocated
#define VIDMAP_NOT_EXIST        0       // the flag for vidmap that is deallocated

// the file operation table should be contained in each file struct in the file array
typedef struct fileOperationTable {
    // definition of file operation table function pointers, currently we only have four
    int32_t (*oFunc)(const uint8_t *filename);
    int32_t (*cFunc)(int32_t fd);
    int32_t (*rFunc)(int32_t fd, unsigned char *buf, int32_t nbytes);
    int32_t (*wFunc)(int32_t fd, const unsigned char *buf, int32_t nbytes);
} fileOperationTable_t;

// the file struct in the file array
typedef struct ece391_file {
    fileOperationTable_t *table;
    uint32_t  inode;
    uint32_t filePos;
    uint32_t flags;
} ece391_file_t;

// the file array should be used and initialze whenever a new PCB is init
typedef struct fileArray {
    ece391_file_t files[FA_SIZE];
    // reserved for other variables
} fileArray_t;

// make it packed to spare space for kernel stack
typedef struct process_control_block {
    /* the file array for each process */
    fileArray_t file_array;
    /* parent process statics */
    /*not needed*/
    //uint32_t parent_ebp;
    //uint32_t parent_esp;
    int8_t parent_pid;     // NOTE: for ece391 PCB, 0..127 pid is enough
    /* current process statics */
    uint32_t ebp;
    uint32_t esp;
    // int8_t pid;          NOTE: no need for store pid again
    /* reserved for paging info */
    /*noot needed*/
    //uint32_t page_directory_index;
    uint32_t halt_ebp;
    uint32_t exc_flag;
    /* the buffer for getarg system_call */
    uint8_t argument_buffer[ARG_BUF_LEN];
    /* flag for vidmap */
    uint8_t vidmap_flag;
} pcb_t;

/*initialized at boot time, stores pointer to pcbs, process status and current process id*/
typedef struct process_manager {
    // NOTE: (pid-1) is the index of this array, and this is a !pointer! array
    // each element points to the position of a PCB
    pcb_t* process_position[MAX_PROCESS_NUM];
    // This array indicates each process presents or not
    uint8_t process_status[MAX_PROCESS_NUM];
    // indicates current process, -1 on no process
    int8_t curr_pid;
} process_manager_t;

// this is the ece391 process/task manager, all the process info can be found in this data structure
extern process_manager_t ece391_process_manager;

/*called when halting a process. changes current process id*/
uint32_t pop_process();

/*called when executing a new process, changes current process id*/
uint32_t push_process(int8_t new_pid);

// this function initializes the ece391init_process_manager
void init_process_manager(process_manager_t* processManager);

// this function init a new process, return a pid and -1 on failure
int8_t init_pcb(process_manager_t* processManager, uint8_t* argument);

#endif
