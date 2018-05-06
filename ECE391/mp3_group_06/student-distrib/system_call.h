/* system_call.h.h - Defines used in system call
 */

#ifndef SYSTEM_CALL_H
#define SYSTEM_CALL_H

#include "types.h"
#include "file_system.h"
#include "pcb.h"

#define FD_PARAM_LOW   2 // user has no priviledge to close fd 0, 1 or non-exist file
#define FD_PARAM_UPPER  7 // any fd is greater then 7 is invalid

/*halt the current process*/
extern int32_t halt (uint8_t status);

/*execute next process*/
extern int32_t execute (const uint8_t* command);

/*execute the correct read function decided by filetype*/
extern int32_t read (int32_t fd, void* buf, int32_t nbytes);

/*execute the correct write function decided by filetype*/
extern int32_t write (int32_t fd, const void* buf, int32_t nbytes);

/*open the file of the filename argument*/
extern int32_t open (const uint8_t* filename);

/*close the file of the file array index*/
extern int32_t close (int32_t fd);

// the following funcions are not implemented
extern int32_t getargs (uint8_t* buf, int32_t nbytes);
extern int32_t vidmap (uint8_t** screen_start);
extern int32_t set_handler (int32_t signum, void* handler_address);
extern int32_t sigreturn (void);

// init the file array passed in by pointer
void init_fileArray(fileArray_t* new_file_array);

// this function should be called once,
// NOTE can is called in function : void init_process_manager(process_manager_t* processManager)
void init_file_operation_jumptables(void);

#endif
