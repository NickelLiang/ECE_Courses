#include "pcb.h"
#include "system_call.h"    // for init operation jumptables
#include "lib.h"            // call strncpy function
// this is the ece391 process/task manager, all the process info can be found in this data structure
process_manager_t ece391_process_manager;

/*
 * init_process_manager
 *   DESCRIPTION: Initializes the process manager structure, called during boot time.
 *   INPUTS: processmanager, pointer to the process manager to be initiated.
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: also initializes the file operation jumptables for different system calls.
 */
void init_process_manager(process_manager_t* processManager) {
    uint32_t ii; // for traverse array in processManager
    // check if the passed-in pointer is valid
    if (processManager == NULL)
        return;
    // no process is running when the processManager is initialized
    processManager->curr_pid = -1;
    // initialze the process_status in the processManager
    for (ii = 0; ii < MAX_PROCESS_NUM; ii++)
        processManager->process_status[ii] = PROCESS_NOT_EXIST;
    // NOTE just for convinience, call init_file_operation_jumptables here
    init_file_operation_jumptables();
}

/*
 * init_pcb
 *   DESCRIPTION: Initializes a new pcb block for the process ready to be executed.
 *   INPUTS: processmanager, pointer to the process manager to be initiated.
 *         : argument, the argument buffer pointer
 *   OUTPUTS: none.
 *   RETURN VALUE: the available process id allocated, -1 on failure.
 *   SIDE EFFECTS: none.
 */
// NOTE: this function should only be called when a current process wants to have a child process
// return the pid_number that is initialized or -1 on failure
int8_t init_pcb(process_manager_t* processManager, uint8_t* argument) {
    uint32_t ii; // for traverse array in processManager
    int8_t ret_pid = -1;    // init pid to be invalid
    uint32_t buf_len = strlen((int8_t*) argument);    // argument buffer length
    // check if the passed-in pointer is valid
    if (processManager == NULL)
        return ret_pid;
    for (ii = 0; ii < MAX_PROCESS_NUM; ii++) {
        // if there is a spare process position
        if (processManager->process_status[ii] == PROCESS_NOT_EXIST) {
            // set returned pid
            ret_pid = ii+1;
            // update the process position: PCB starts at 8MB – 8KB * pid
            processManager->process_position[ii] = (pcb_t*) (PCB_BASE_ADDR - ret_pid*PCB_SEG_LENGTH);
            // init the file_array
            init_fileArray(&(processManager->process_position[ii]->file_array));
            // update the kernel stack for this process
            processManager->process_position[ii]->ebp =  (PCB_BASE_ADDR - ii*PCB_SEG_LENGTH);
            processManager->process_position[ii]->esp =  (PCB_BASE_ADDR - ii*PCB_SEG_LENGTH);
            // load parent pid
            processManager->process_position[ii]->parent_pid = processManager->curr_pid;
            // check if to
            if (processManager->curr_pid == -1){
                /* reserved for load root PCB's parent info, esp or ebp, ... */
                break;
            }

            /* reserved for load PCB's parent info, esp or ebp, ... */

        // if there is a spare process position then no need to find next
        break;
        }
    }
    // if the array full, immediately return
    if (ret_pid == -1)
        return ret_pid;
    // else continue 
    processManager->process_position[ret_pid-1]->exc_flag = HALT_NORM;
    processManager->process_position[ret_pid-1]->vidmap_flag = VIDMAP_NOT_EXIST;
    // check input argument is bad pointer
    if (buf_len == 0) {
        processManager->process_position[ret_pid-1]->argument_buffer[0] = '\0';
    }
    // check if the passed-in buffer is too long
    else if (buf_len >= ARG_BUF_LEN) {
        strncpy((int8_t *)(processManager->process_position[ret_pid-1]->argument_buffer), (int8_t *) argument, ARG_BUF_LEN-1);
        processManager->process_position[ret_pid-1]->argument_buffer[ARG_BUF_LEN] = '\0';
    }
    // passed-in buff is good to process
    else {
        strncpy((int8_t *)(processManager->process_position[ret_pid-1]->argument_buffer), (int8_t *) argument, buf_len);
        processManager->process_position[ret_pid-1]->argument_buffer[buf_len] = '\0';
    }
    return ret_pid;
}

/*
 * pop_process
 *   DESCRIPTION: called when halting a process. changes current process id.
 *   INPUTS: none.
 *   OUTPUTS: none.
 *   RETURN VALUE: 0 on success, -1 on failure.
 *   SIDE EFFECTS: none.
 */
uint32_t pop_process() {
    if (ece391_process_manager.curr_pid == -1) return -1;
    ece391_process_manager.process_status[ece391_process_manager.curr_pid-1] = PROCESS_NOT_EXIST;
    ece391_process_manager.curr_pid = ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->parent_pid;
    return 0;
}

/*
 * push_process
 *   DESCRIPTION: called when executing a new process, changes current process id.
 *   INPUTS: new_pid, the new process id to be pushed.
 *   OUTPUTS: none.
 *   RETURN VALUE: 0 on success, -1 on failure.
 *   SIDE EFFECTS: none.
 */
uint32_t push_process(int8_t new_pid) {
    ece391_process_manager.process_status[new_pid-1] = PROCESS_EXIST;
    ece391_process_manager.curr_pid = new_pid;
    return 0;
}
