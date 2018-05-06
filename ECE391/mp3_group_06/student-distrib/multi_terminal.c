#include "multi_terminal.h"
#include "system_call.h"
#include "types.h"
#include "lib.h"
#include "pcb.h"
#include "device.h"

// // terminal busy flag
// uint8_t ter_flag;

// current terminal number
uint8_t cur_ter_num;

// for scheduler, the current terminal being executed
uint8_t cur_exe_ter_num;

// ece391 terminal info array
MULTI_TER_INFO_t ece391_multi_ter_info[TER_MAX];

// ece391 terminal status array
uint8_t ece391_multi_ter_status[TER_MAX];

// init multi-terminal
/*
 *  multi_terminal_init
 *   DESCRIPTION: this funciton initialize the terminal structure
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: initialize the terminal structure
 */

void multi_terminal_init(){
    uint8_t ii, i;
    for (ii = 0; ii < TER_MAX; ii++) {
        ece391_multi_ter_status[ii] = TER_NOT_EXIST;
        ece391_multi_ter_info[ii].ter_screen_x = TER_NOT_EXIST;
        ece391_multi_ter_info[ii].ter_screen_y = TER_NOT_EXIST;
        ece391_multi_ter_info[ii].ter_bufferIdx = TER_NOT_EXIST;
        ece391_multi_ter_info[ii].TER_RTC_FLAG = 0;
        ece391_multi_ter_info[ii].PID_num = -1;
        for (i = 0; i < ter_buffer_len+1; i ++)
            ece391_multi_ter_info[ii].ter_buffer[i] = '\0'; // +1 since we need to detect ENTER after filled
    }
    // open terminal 0
    cur_ter_num = 0;
    // ece391_multi_ter_status[cur_ter_num] = TER_EXIST;
    // ece391_multi_ter_info[cur_ter_num].Parent_ter = -1; // set Parent_ter to nonsense
    // ter_flag = TER_NOT_BUSY;
}

// switch_terminal function
/*
 *  switch_terminal
 *   DESCRIPTION: this function switch terminal when detect the signal from
                  keyboard
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: change the video memory that displayed on the screen
 */

void switch_terminal(uint32_t next_terminal) {
    int8_t next_ter_number, ii;

    // extract the terminal number to jump to
    if (next_terminal == TO_DESTI) {
        next_ter_number = ece391_multi_ter_info[(uint32_t)cur_ter_num].Dest_ter;
    }
    else if (next_terminal == TO_PARENT) {
        next_ter_number = ece391_multi_ter_info[(uint32_t)cur_ter_num].Parent_ter;
    }
    else {
        return;
    }
    // handle invalid terminal number
    if (next_ter_number < 0 || next_ter_number > 2) {
        ERROR_MSG;
        printf("INVALID TERMINAL NUMBER");
        while(1);
    }
    // handle the parent terminal not exist
    if(next_terminal == TO_PARENT && ece391_multi_ter_status[(uint32_t)next_ter_number] == TER_NOT_EXIST){
        // traverse the terminal list, assign whichever terminal exist to be its head
        for (ii = 0; ii < TER_MAX; ii ++){
            if(ece391_multi_ter_status[(uint32_t)ii] == TER_EXIST){
                ece391_multi_ter_info[cur_ter_num].Parent_ter = ii;
                switch_terminal(TO_PARENT);
                return;
            }
        }
        ERROR_MSG;
        printf("TERMINAL LOST HEAD TO RETURN");
        while(1);
    }
    // handle the destination terminal not exist
    if (next_terminal == TO_DESTI && ece391_multi_ter_status[(uint32_t)next_ter_number] == TER_NOT_EXIST){
        // TODO switch terminal and initiate to execute "shell"ˇ
        // ece391_multi_ter_info[(uint32_t)next_ter_number].Parent_ter = cur_ter_num; // assign the next_terminal's parent to be the current one
        /* TODO paging, cur_pid, */
        /*switch terminal video memory*/
        switch_terminal_video(cur_ter_num, next_ter_number);
        ece391_multi_ter_status[(uint32_t)next_ter_number] = TER_EXIST;
        /*change the current terminal to the next one */
        cur_ter_num = next_ter_number;
        // make new shell's parent be -1
        ece391_process_manager.curr_pid = -1;
        sti();
        clearScreen();
        execute((void *)"shell");

        ece391_multi_ter_status[(uint32_t)cur_ter_num] = TER_NOT_EXIST;
        switch_terminal(TO_PARENT);
        ERROR_MSG;
        printf("TERMINAL FAIL TO RETURN TO PARENT");
        while(1);
    }
    // handle the next_terminal that exists
    // TODO switch terminal and initiate to execute "shell"
    // ece391_multi_ter_info[(uint32_t)next_ter_number].Parent_ter = cur_ter_num;  // assign the next_terminal's parent to be the current one
    /* TODO paging, cur_pid, */
    /*switch terminal video memory*/
    switch_terminal_video(cur_ter_num, next_ter_number);
    //
    if (next_terminal == TO_PARENT){
        memcpy(getBuffer(), ece391_multi_ter_info[(uint32_t)next_ter_number].ter_buffer, BUFF_SIZE);
        setIdx(ece391_multi_ter_info[(uint32_t)next_ter_number].ter_bufferIdx);
        setScreen_x(ece391_multi_ter_info[(uint32_t)next_ter_number].ter_screen_x);
        setScreen_y(ece391_multi_ter_info[(uint32_t)next_ter_number].ter_screen_y);
        moveCursor();
    }

    /* update cur_pid */
    ece391_process_manager.curr_pid = ece391_multi_ter_info[(uint32_t)next_ter_number].PID_num;
    //printf("current pid is : %d\n", ece391_process_manager.curr_pid);
    /*change the current terminal to the next one */
    cur_ter_num = next_ter_number;
    /*switch destination terminal process user memory*/
    switch_terminal_paging(ece391_process_manager.curr_pid);
    /* gives the notification */

    printf("\n[ATTENTION] SWITCH TO TERMINAL(parent pid %d) %d\n391OS> ",ece391_process_manager.process_position[ece391_process_manager.curr_pid-1]->parent_pid, (uint32_t)cur_ter_num);


    printf("\nESP0: 0x%#x   SS0: 0x%#x\n", tss.esp0, tss.ss0);
    tss.esp0 = ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->esp;
    tss.ss0 = KERNEL_DS;

    /* ss */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].SS_reg));
    /* esp */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ESP_reg));
    /* eflags */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EFLAGS_reg));
    /* cs */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].CS_reg));
    /* eip*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].old_EIP_reg));
    /* fs*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].FS_reg));
    /* es*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ES_reg));
    /* ds*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].DS_reg));
    /* eax*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EAX_reg));
    /* ebp*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EBP_reg));
    /* edi*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EDI_reg));
    /* esi*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ESI_reg));
    /* edx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EDX_reg));
    /* ecx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ECX_reg));
    /* ebx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EBX_reg));
    /* esp*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].K_ESP_reg));
    // ter_flag = TER_NOT_BUSY;
    /* pop all the register just poped on the stack*/
    //asm volatile("popal" : :);
    asm volatile("popl %%esp" : :);
    asm volatile("popl %%ebx" : :);
    asm volatile("popl %%ecx" : :);
    asm volatile("popl %%edx" : :);
    asm volatile("popl %%esi" : :);
    asm volatile("popl %%edi" : :);
    asm volatile("popl %%ebp" : :);
    asm volatile("popl %%eax" : :);
    asm volatile("popw %%ds" : :);
    asm volatile("popw %%ds" : :);
    asm volatile("popw %%es" : :);
    asm volatile("popw %%es" : :);
    asm volatile("popw %%fs" : :);
    asm volatile("popw %%fs" : :);

    /* use iret to switch context */
    asm volatile("iret" : :);

}

// switch_context function
// exe current terminal number, if halt, exe a new shell
// this function should always be called with TO_DESTI
/*
 *  switch_context
 *   DESCRIPTION: this function switch context when when receiving signal
                  from pit interrupt
 *   INPUTS: none
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: change the process currently running
 */

void switch_context(uint32_t next_terminal) {
    int8_t next_ter_number;
    int i;
    // extract the terminal number to jump to
    if (next_terminal == TO_DESTI) {
        next_ter_number = cur_exe_ter_num;
    }
    else if (next_terminal == TO_PARENT) {
        ERROR_MSG;
        printf("ASK SCHEDULER TO FIND PARENT TERMINAL\n");
        while(1);
    }
    else {
        ERROR_MSG;
        printf("UNKNOWN COMMAND\n");
        return;
    }
    // handle invalid terminal number
    if (next_ter_number < 0 || next_ter_number > 2) {
        ERROR_MSG;
        printf("INVALID TERMINAL NUMBER");
        while(1);
    }
    // handle the destination terminal not exist
    if (ece391_multi_ter_status[(uint32_t)next_ter_number] == TER_NOT_EXIST) {
        ece391_multi_ter_status[(uint32_t)next_ter_number] = TER_EXIST;
        /*change the current terminal to the next one */
        // make new shell's parent be -1
        ece391_process_manager.curr_pid = -1;
        // clear scr
        clearScreen();
        // init terminal buffer
        ece391_multi_ter_info[(uint32_t)next_ter_number].ter_bufferIdx = TER_NOT_EXIST;
        ece391_multi_ter_info[(uint32_t)next_ter_number].PID_num = -1;
        for (i = 0; i < ter_buffer_len+1; i ++)
            ece391_multi_ter_info[(uint32_t)next_ter_number].ter_buffer[i] = '\0'; // +1 since we need to detect ENTER after filled
        execute((void *)"shell"); // QUESTION may be interrupted
        ERROR_MSG;
        printf("TERMINAL FAIL TO RETURN TO PARENT");
        while(1);
    }
    // handle the next_terminal that exists
    // TODO switch terminal and initiate to execute "shell"
    // ece391_multi_ter_info[(uint32_t)next_ter_number].Parent_ter = cur_ter_num;  // assign the next_terminal's parent to be the current one
    /* TODO paging, cur_pid, */
    /*switch terminal video memory*/
    //switch_terminal_video(cur_ter_num, next_ter_number);
    //

    /* update cur_pid */
    ece391_process_manager.curr_pid = ece391_multi_ter_info[(uint32_t)next_ter_number].PID_num;
    /*switch destination terminal process user memory*/
    switch_terminal_paging(ece391_process_manager.curr_pid);
    /* gives the notification */

    tss.esp0 = ece391_process_manager.process_position[(ece391_process_manager.curr_pid) - 1]->esp;
    tss.ss0 = KERNEL_DS;

    /* ss */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].SS_reg));
    /* esp */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ESP_reg));
    /* eflags */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EFLAGS_reg));
    /* cs */
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].CS_reg));
    /* eip*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].old_EIP_reg));
    /* fs*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].FS_reg));
    /* es*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ES_reg));
    /* ds*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].DS_reg));
    /* eax*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EAX_reg));
    /* ebp*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EBP_reg));
    /* edi*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EDI_reg));
    /* esi*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ESI_reg));
    /* edx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EDX_reg));
    /* ecx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].ECX_reg));
    /* ebx*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].EBX_reg));
    /* esp*/
    asm volatile("pushl %0\n\t" : :"g" (ece391_multi_ter_info[(uint32_t)next_ter_number].K_ESP_reg));

    /* pop all the register just poped on the stack*/
    //asm volatile("popal" : :);
    asm volatile("popl %%esp" : :);
    asm volatile("popl %%ebx" : :);
    asm volatile("popl %%ecx" : :);
    asm volatile("popl %%edx" : :);
    asm volatile("popl %%esi" : :);
    asm volatile("popl %%edi" : :);
    asm volatile("popl %%ebp" : :);
    asm volatile("popl %%eax" : :);
    asm volatile("popw %%ds" : :);
    asm volatile("popw %%ds" : :);
    asm volatile("popw %%es" : :);
    asm volatile("popw %%es" : :);
    asm volatile("popw %%fs" : :);
    asm volatile("popw %%fs" : :);
    sti();
    /* use iret to switch context */
    asm volatile("iret" : :);

}
