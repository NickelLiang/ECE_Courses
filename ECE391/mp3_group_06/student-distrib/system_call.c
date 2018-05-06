#include "system_call.h"
#include "file_system.h"
#include "rtc.h"
#include "terminal.h"
#include "paging.h"
#include "lib.h"
#include "loader.h"
#include "pcb.h"
#include "x86_desc.h"
#include "tests.h"  // Macro inserted from tests.h
#include "multi_terminal.h"  // access cur_ter_num
// these following variables act as function jumptables for different files; static is thus safe
static fileOperationTable_t inTable;    // 'stdin' jumptable
static fileOperationTable_t outTable;   // 'stdout' jumptable
static fileOperationTable_t rtcTable;   // 'rtc' jumptable
static fileOperationTable_t dirTable;   // directory jumptable
static fileOperationTable_t regTable;   // regular files jumptable
static int32_t halt_ret;

/*
 * open
 *   DESCRIPTION: this function will be called by system call wrapper,
                  open the file of the filename argument
 *   INPUTS: filename -- the filename of the file that needed to open
 *   OUTPUTS: none
 *   RETURN VALUE: fd -- the index of file array
 *   SIDE EFFECTS: change the file descriptor due to the index
 */
int32_t open(const uint8_t *filename) {
    int i;
    int fd = -1;
    dentry_t dentry;
    int8_t fullFlag;
    // check if the processManager has a process to run
    if (ece391_process_manager.curr_pid == -1) {
        ERROR_MSG;
        printf("No process is running.\n");
        return -1;
    }
    // check bad param
    if (filename == NULL) {
        ERROR_MSG;
        printf("Process open file has bad parameter.\n");
        return -1;
    }
    // check if the passed-in file exists in the file system
    if (read_dentry_by_name(filename, &dentry) == -1) {
        ERROR_MSG;
        printf("Process wants to open invalid file.\n");
        return -1;
    }
    // check if file status array has spare spot for new file to open
    fullFlag = 1;
    for (i = FD_PARAM_LOW; i <= FD_PARAM_UPPER; i ++) {
        // NOTE: (pid-1) is the index of this array, and this is a !pointer! array
        if((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[i].flags == STATUS_CLOSED) {
            fullFlag = 0;
            switch (dentry.filetype) {      //get the file type and set the operation table to the correct one
                case 0:
                    fd = (*(rtcTable.oFunc))(filename);
                    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table = &rtcTable;
                    break;
                case 1:
                    fd = (*(dirTable.oFunc))(filename);
                    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table = &dirTable;
                    break;
                case 2:
                    fd = (*(regTable.oFunc))(filename);
                    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table = &regTable;
                    break;
            }
            break;
        }
    }

    // if no space, then return on error
    if (fullFlag == 1) {
        ERROR_MSG;
        printf("Process file_array is full.\n");
        return -1;
    }
    return fd;
}

/*
 * close
 *   DESCRIPTION: this function will be called by system call wrapper,
                  close the file of the file array index
 *   INPUTS: fd -- the file array index of the file that needed to close
 *   OUTPUTS: 0 --sucess
              -1 -- fail
 *   RETURN VALUE: none
 *   SIDE EFFECTS: close the file of the file array index
 */
int32_t close(int32_t fd) {
    if(fd < FD_PARAM_LOW || fd > FD_PARAM_UPPER){       //check whether fd is valid
        ERROR_MSG;
        printf("Process close has bad parameter.\n");
        return -1;
    }
    if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags == STATUS_CLOSED) {        //check whether the file is already closed
        ERROR_MSG;
        printf("Process tries to close a already closed file.\n");
        return -1;
    }
    if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table == NULL){          //check whether the process has the right to close the file
        ERROR_MSG;
        printf("Process tries to close priviledged file.\n");
        return -1;
    }
    if(-1 == (*((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table->cFunc))(fd)){     //close function fails due to an unkown bug
        ERROR_MSG;
        printf("UNKOWN BUG IN CLOSE.\n");
        return -1;
    }
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table = NULL;            //reset the file descriptor in the file array
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].inode = 0xFFFF;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].filePos = 0;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags = STATUS_CLOSED;
    return 0;
}

/*
 * read
 *   DESCRIPTION: this function will be called by system call wrapper,
                  execute the correct read function decided by filetype
 *   INPUTS: fd -- the file array index of the file that needed to read
 *   OUTPUTS: 0 --sucess
              -1 -- fail
 *   RETURN VALUE: none
 *   SIDE EFFECTS: execute the correct read function decided by filetype
 */
int32_t read(int32_t fd, void *buf, int32_t nbytes) {
    if (ece391_process_manager.curr_pid == -1) {          //check whether this is process running
        ERROR_MSG;
        printf("No process is running.\n");
        *((int8_t*) buf) = '\0';
        return -1;
    }
    if (fd < 0 || fd > FD_PARAM_UPPER) {             //check whether the fd is valid
        ERROR_MSG;
        printf("Process read has bad parameter.\n");
        *((int8_t*) buf) = '\0';
        return -1;
    }
    if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags == STATUS_CLOSED) {            //check whether the file to read is open
        ERROR_MSG;
        printf("Process tries to read a already closed file. %d\n", fd);
        *((int8_t*) buf) = '\0';
        return -1;
    }
    if((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table->rFunc == NULL){            //check whether the process has the right to read the file
        ERROR_MSG;
        printf("File has no priviledge to read.\n");
        *((int8_t*) buf) = '\0';
        return -1;
    }
    {
        return (*((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table->rFunc))(fd, buf, nbytes);           //execute the right read function
    }
}

/*
 * write
 *   DESCRIPTION: this function will be called by system call wrapper,
                  execute the correct write function decided by filetype
 *   INPUTS: fd -- the file array index of the file that needed to write
 *   OUTPUTS: 0 --sucess
              -1 -- fail
 *   RETURN VALUE: none
 *   SIDE EFFECTS: execute the correct write function decided by filetype
 */
int32_t write(int32_t fd, const void *buf, int32_t nbytes) {
    if (ece391_process_manager.curr_pid == -1) {          //check whether this is process running
        ERROR_MSG;
        printf("No process is running.\n");
        return -1;
    }
    if (fd < 0 || fd > FD_PARAM_UPPER) {        //check whether the fd is valid
        ERROR_MSG;
        printf("Process write has bad parameter. %d\n", fd);
        return -1;
    }
    if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags == STATUS_CLOSED) {        //check whether the file to write is open
        ERROR_MSG;
        printf("Process tries to write to a already closed file.\n");
        return -1;
    }
    if((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table->wFunc == NULL){            //check whether the process has the right to write the file
        ERROR_MSG;
        printf("File has no priviledge to write.\n");
        return -1;
    }
    {
        return (*((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].table->wFunc))(fd, buf, nbytes);       //execute the right write function
    }
}

#define array_min_file  2
#define array_max_file  7
/*
 * halt
 *   DESCRIPTION: this function will be called by system call wrapper,
                  halt the current process
 *   INPUTS: status -- the status
 *   OUTPUTS: none
 *   RETURN VALUE: this function should never be returned
 *   SIDE EFFECTS: halt the current process
 */
int32_t halt(uint8_t status) {
    uint32_t f = ((ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1])->exc_flag);
    int i;
    if (ece391_process_manager.curr_pid == -1)
        return -1;

    // traverse to closed opened file
    for (i = array_min_file; i <= array_max_file; i++ ){
            if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[i].flags == STATUS_OPENED)
            close(i);
    }
    /* restore esp0 */
    if ((ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1])->parent_pid != -1) {
        tss.esp0 = (ece391_process_manager.process_position[(ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1])->parent_pid - 1])->esp;
    }

    /* Deallocate user video mapping if necessary */
    if (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->vidmap_flag == VIDMAP_EXIST) {
        /* Deallocate user video mapping */
        user_video_unmapping();
        ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->vidmap_flag = VIDMAP_NOT_EXIST;
    }

    user_page_unmapping(ece391_process_manager.curr_pid);
    halt_ret = ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->halt_ebp;
    pop_process();

    // if this process is a main process of the terminal 1, 2 then should jump back to terminal 0 immediately rather than halt
    if (ece391_process_manager.curr_pid == -1) {
        //ece391_multi_ter_info[(uint32_t)cur_ter_num].Parent_ter = 0;
        //ece391_multi_ter_status[(uint32_t)cur_ter_num] = TER_NOT_EXIST;
        // if (f != HALT_NORM) sti();
        // while(1);
        execute((void *)"shell");
        switch_terminal(TO_PARENT);
        ERROR_MSG;
        printf("TERMINAL FAIL TO RETURN TO PARENT");

    }

    /*if still have parent user process*/
    if (ece391_process_manager.curr_pid > 0) {
        user_page_mapping(ece391_process_manager.curr_pid);
    }

    ece391_multi_ter_info[cur_ter_num].executeFlag = 0;

    if ( f == HALT_NORM ){
        asm volatile("movzbl %%bl,%%ebx\n\t" : :);
        asm volatile("jmp EXE_RETURN" : :);
    }
    else {
        asm volatile("movl $256,%%ebx\n\t" : :);
        asm volatile("jmp EXE_RETURN" : :);
    }
    printf("error\n");
    return 0;       //prevent warning
}

#define clear_flag_mask 0x200
/*
 * execute
 *   DESCRIPTION: this function will be called by system call wrapper,
                  execute next process
 *   INPUTS: command -- the next process to be executed
 *   OUTPUTS: 0 - normally
              1 - 255 --error
              256 -- exception
 *   RETURN VALUE: none
 *   SIDE EFFECTS: execute the next process
 */
int32_t execute(const uint8_t* command) {
    cli();
    uint32_t new_falg;
    uint8_t filename[TERMINAL_BUFEER_SIZE];
    uint8_t argument[TERMINAL_BUFEER_SIZE];
    uint32_t idx = 0;
    uint32_t arg_idx = 0;
    uint32_t arg_begin;
    int16_t cur_ds;
    int32_t temp;
    int32_t temp_esp;
    /*check for bad input command*/
    if (command == NULL) {
        ERROR_MSG;
        printf("Command does not exist.\n");
        return -1;
    }

    // TODO following condition check is naive
    // if (ece391_process_manager.curr_pid == MAX_PROCESS_NUM) {
    //     ERROR_MSG;
    //     printf("Maximum process number reached. Max %d.\n", ece391_process_manager.curr_pid);
    //     return 0; // Program terminated abnormally
    // }


    // omit the space
    while (command[0] == ' ' && idx < TERMINAL_BUFEER_SIZE){
        command = command + 1;
        idx++;
    }
    // check if command only has space
    if (idx == TERMINAL_BUFEER_SIZE){
        ERROR_MSG;
        printf("Command does not exist.\n");
        return -1;
    }
    // init idx again
    idx = 0;
    while (command[idx] != ' ' && command[idx] != '\0')
        idx++;
    memcpy(filename, command, idx);
    filename[idx] = '\0';       /*set the last index as end of string*/
    // omit all the space
    while (command[idx] == ' '){
        idx++;
    }
    if (command[idx] != '\0') {      /*if there is argument*/
        arg_begin = idx;        /*save the beginning addr of the argument*/
        while (command[idx] != '\0') {
            idx ++;
            arg_idx ++;
        }
        memcpy(argument, command + arg_begin, arg_idx);     /*copy the argument into the right place*/
        argument[arg_idx] = '\0';       /*set the last index as end of string*/
    }
    else {
        argument[0] = '\0';
    }
    /*checks whether the file is executable*/
    if (check_executable_validity(filename) == -1) {
        ERROR_MSG;
        printf("The file specified is not an executable.\n");
        return -1;
    }

    /*stores current process ebp, esp into the process manager*/
    /*initialize a pcb for the current process, get the process number*/
    /*current esp, */

    int8_t pid = init_pcb(&ece391_process_manager, argument);
    // TEST_MSG;
    // printf("A Process wants to exe, raw cur pid is %d\n", pid);
    if (pid < 1) {
        ERROR_MSG;
        printf("Unable to create a new pcb.\n");
        return -1;
    }

    //ece391_process_manager.process_position[(ece391_process_manager.pid)-1]->parent_pid = par_pid;
    /*now cur_pid is the new pid*/
    push_process(pid);

    /*initialized user level paging*/
    user_page_mapping(pid);

    /*copy the user image to the user level page*/
    uint32_t* execute_start = load_user_image(filename);
    ece391_multi_ter_info[cur_ter_num].executeFlag = 1;
    #if (PAGE_TEST == 2)
    paging_test();
    #endif

    // esp
    asm volatile("movl %%esp,%0\n\t" :"=r" (temp_esp));
    asm volatile("movl %%ebp,%0\n\t" :"=r" (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->halt_ebp));

    /*code for context switch*/
    if((ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1])->parent_pid == -1 && cur_ter_num == 0){ // if it is the first process, maintain the current esp
        (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->esp )= temp_esp-4;
    }
    tss.esp0 = ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->esp;
    tss.ss0 = KERNEL_DS;

    asm volatile("pushfl");
    asm volatile("popl %0\n\t" :"=r"(new_falg));
    new_falg|=clear_flag_mask;
    /*code for setting up stack for iret*/
    //use the exexute_start to setup eip
    //asm volatile("movl %%ebp,%0\n\t" :"=r" (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->parent_ebp));
    //asm volatile("movl %%esp,%0\n\t" :"=r" (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->parent_esp));
    //ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->parent_pid = par_pid;
    asm volatile("movw %%ds,%0\n\t" :"=r" (cur_ds));
    asm volatile("movw %0,%%ax\n\t": :"g" (USER_DS));
    asm volatile("movw %%ax,%%ds\n\t": :);
    /* ss */
    asm volatile("pushl %0\n\t" : :"g" (USER_DS));
    /* esp */
    asm volatile("pushl %0\n\t" : :"g" (LOAD_PAGE_END_ADDR-1));
    /* eflags */
    asm volatile("pushl %0\n\t" : :"g"(new_falg));
    /* cs */
    asm volatile("pushl %0\n\t" : :"g" (USER_CS));
    /* eip*/
    asm volatile("pushl %0\n\t" : :"g" (execute_start));
    asm volatile("iret" : :);                               // Go IRET!
    asm volatile("EXE_RETURN:");                            // Come back from HALT
    asm volatile("movl %0, %%ebp\n\t": :"g" (halt_ret));    // Restore EBP
    asm volatile("movl %%ebx,%0\n\t" :"=r" (temp));         // Update return value
    return temp;
}

/*
 * getargs
 *   DESCRIPTION: this function will be called by system call wrapper,
                  get arguments after the executable name
 *   INPUTS: buf    which buffer to write to
 *           nbytes how long the argument is
 *   OUTPUTS: -1    Error
              0     Normal
 *   RETURN VALUE: none
 *   SIDE EFFECTS: none
 */
int32_t getargs(uint8_t* buf, int32_t nbytes) {
    int32_t arg_buff_len;
    if (buf == NULL) {
        ERROR_MSG;
        printf("Buffer is NULL.\n");
        return -1;
    }
    if (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->argument_buffer[0] == '\0') {       /*if there is no argumment*/
        ERROR_MSG;
        printf("Cannot get the argument.");
        return -1;
    }
    arg_buff_len = strlen((int8_t*) (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->argument_buffer));
    if (arg_buff_len >= nbytes) {       /* if the argument do not fit in the buffer */
        ERROR_MSG;
        printf("The size of argument do not fit in the buffer.");
        return -1;
    }
    memcpy(buf, (ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->argument_buffer), arg_buff_len);
    buf[arg_buff_len] = '\0';
    return 0;
}

/*
 * vidmap
 *   DESCRIPTION: this function will be called by system call wrapper,
                  set user space video mapping
 *   INPUTS: screen_start    pointer to the user space start pointer.
 *   OUTPUTS: -1    Error
              0     Normal
 *   RETURN VALUE: none
 *   SIDE EFFECTS: none
 */
int32_t vidmap(uint8_t** screen_start) {
    /* Check if argument is valid - Check if it falls into 4MB user page */
    if (USER_START_VIRTUAL > (uint32_t)screen_start || (uint32_t)screen_start >= (USER_START_VIRTUAL + _4MB)) {
        ERROR_MSG;
        printf("Vidmap screen start addr invalid. %#x\n", screen_start);
        return -1;
    }
    /* Find current pcb location */
    pcb_t* current_pcb = ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1];
    /* If we already set vidmap before, error */
    if (current_pcb->vidmap_flag == VIDMAP_EXIST) {
        ERROR_MSG;
        printf("Vidmap already exist.\n");
        return -1;
    }
    /* Allocate user video page */
    user_video_mapping();
    /* Set flag to exist */
    current_pcb->vidmap_flag = VIDMAP_EXIST; // Defined in pcb.h
    /* Set return value */
    *screen_start = (uint8_t*)USER_VIDEO; // Defined in paging.h
    /* Vidmap set success */
    return 0;
}

/* Following syscalls are not yet implemented */
int32_t set_handler(int32_t signum, void* handler_address) {
    return 0;
}
int32_t sigreturn(void) {
    return 0;
}

// this funcion initilize the file array, automatically open the
// terminal open/close
// this function is called by PCB
/*
 * init_fileArray
 *   DESCRIPTION: this function initialize the file array
 *   INPUTS: new_file_array -- the file array that need to be initialized
 *   OUTPUTS:none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: initialize the file array
 */
void init_fileArray(fileArray_t* new_file_array) {
    int32_t ii; // for traverse the file array
    // open stdin automatically
    new_file_array->files[0].table = &inTable;
    new_file_array->files[0].inode = 0xFFFF;  // no such file exist in
    new_file_array->files[0].filePos = 0;
    new_file_array->files[0].flags = STATUS_OPENED;
    // open stdout automatically
    new_file_array->files[1].table = &outTable;
    new_file_array->files[1].inode = 0xFFFF;  // no such file exist in
    new_file_array->files[1].filePos = 0;
    new_file_array->files[1].flags = STATUS_OPENED;
    // open terminal
    terminal_open((uint8_t *)"stdIO");
    // traverse array to set rest files' status
    for (ii = 2; ii < FA_SIZE; ii++)
        new_file_array->files[ii].flags = STATUS_CLOSED;
    // make sure that the all the drivers are interacting with the correct file array
}

// this function should be called once,
// NOTE can is called in function : void init_process_manager(process_manager_t* processManager)
/*
 * init_file_operation_jumptables
 *   DESCRIPTION: this function initialize the file operation jumptable
                  for terminal, rtc and file
 *   INPUTS: none
 *   OUTPUTS:none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: initialize the file operation jumptable
 */
void init_file_operation_jumptables(void) {
    // init the local jumptables
    // 'stdin' jumptable
    inTable.oFunc = &stdin_open;
    inTable.cFunc = &stdin_closed;
    inTable.rFunc = &terminal_read;
    inTable.wFunc = &stdin_write;
    // 'stdout' jumptable
    outTable.oFunc = &stdout_open;
    outTable.cFunc = &stdout_closed;
    outTable.rFunc = &stdout_read;
    outTable.wFunc = &terminal_write;
    // 'rtc' jumptable
    rtcTable.oFunc = &rtc_open;
    rtcTable.cFunc = &rtc_close;
    rtcTable.rFunc = &rtc_read;
    rtcTable.wFunc = &rtc_write;
    // directory jumptable
    dirTable.oFunc = &dir_open;
    dirTable.cFunc = &dir_close;
    dirTable.rFunc = &dir_read;
    dirTable.wFunc = &dir_write;
    // regular files jumptable
    regTable.oFunc = &file_open;
    regTable.cFunc = &file_close;
    regTable.rFunc = &file_read;
    regTable.wFunc = &file_write;
}
