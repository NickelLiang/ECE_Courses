/*  @ brif This file parses the given ece391 file system image
 *          and contains basic APIs to interact with files.
 *
 */

#include "file_system.h"
#include "pcb.h"
#include "rtc.h"
#include "lib.h"
/* the hierarchy for ece391 file system */
ece391_file_system_t   ece391FileSystem;

// file_status_array_t fileStatusArray; this is only for CP_3.2
// this file array pointer should points to current PCB's file array

/*
 * init_file_system
 *   DESCRIPTION: initialized out own ece391_file_system structure
 *   INPUTS: addr_start -- starting address of the fileimg
             addr_end -- ending address of the fileimg
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: copys the information of the fileimg into local datastructure
 */
void init_file_system(unsigned int addr_start, unsigned int addr_end) {
    unsigned int addr;
    ece391FileSystem.dir_count = 0;
    ece391FileSystem.inode_count = 0;
    ece391FileSystem.data_count = 0;
    // check if pointer valid
    if (addr_start == 0 || addr_end <= addr_start) {
        ERROR_MSG;
        printf("ECE391 file system input address invalid.\n");
        ece391FileSystem.ece391_boot_block = NULL;
        ece391FileSystem.ece391_inodes = NULL;
        ece391FileSystem.ece391_data_blocks = NULL;
        return;
    }
    // parsing the boot block
    ece391FileSystem.ece391_boot_block = (boot_block_t*) addr_start;
    // check if boot statistic valid
    /* file system directory number*/
    if (ece391FileSystem.ece391_boot_block->dir_count > DIRENTRIES_NUM) {
        ERROR_MSG;
        printf("ECE391 file system directory number invalid.\n");
        ece391FileSystem.ece391_boot_block = NULL;
        ece391FileSystem.ece391_inodes = NULL;
        ece391FileSystem.ece391_data_blocks = NULL;
        return;
    }
    /* file inodes length plus data block length in bound */
    if ((ece391FileSystem.ece391_boot_block->inode_count + \
        ece391FileSystem.ece391_boot_block->data_count + 1) * BLOCK_SIZE_4KB  > addr_end - addr_start + 1) {
        ERROR_MSG;
        printf("ECE391 file system data out of boundary.\n");
        ece391FileSystem.ece391_boot_block = NULL;
        ece391FileSystem.ece391_inodes = NULL;
        ece391FileSystem.ece391_data_blocks = NULL;
        return;
    }
    // update the file system statistic
    ece391FileSystem.dir_count = ece391FileSystem.ece391_boot_block->dir_count;
    ece391FileSystem.inode_count = ece391FileSystem.ece391_boot_block->inode_count;
    ece391FileSystem.data_count = ece391FileSystem.ece391_boot_block->data_count;
    // printf("ece391FileSystem.dir_count %d\n", (unsigned long)ece391FileSystem.dir_count);
    // printf("ece391FileSystem.inode_count %d\n", (unsigned long)ece391FileSystem.inode_count);
    // printf("ece391FileSystem.data_count %d\n", (unsigned long)ece391FileSystem.data_count);

    // parsing the inodes
    addr = addr_start + BLOCK_SIZE_4KB;
    ece391FileSystem.ece391_inodes = (inode_t*) addr;
    // parsing the data blocks
    addr += BLOCK_SIZE_4KB * ece391FileSystem.ece391_boot_block->inode_count;
    ece391FileSystem.ece391_data_blocks = (data_block_t*) addr;
    return;
}

/*
 * read_dentry_by_name
 *   DESCRIPTION: finds the dentry corresponding to the filename
 *   INPUTS: fname -- filename we are searching for
             dentry -- the emtpy pre-allocated dentry pointer to copy information into
 *   OUTPUTS: none
 *   RETURN VALUE: 0 for success and -1 for fail
 *   SIDE EFFECTS: copys the dentry informaiton for the desired filename
 */
int32_t read_dentry_by_name(const uint8_t *fname, dentry_t* dentry) {
    unsigned int i, j;
    // Initialize find flag and index
    uint8_t find_flag = 0;
    uint32_t index = 0;
    // find name string's length
    uint32_t fname_len = strlen((int8_t *)fname);
    // check if the file system is initialized
    if (ece391FileSystem.ece391_boot_block == NULL || \
       ece391FileSystem.ece391_inodes == NULL ||\
       ece391FileSystem.ece391_data_blocks == NULL) {
        ERROR_MSG;
        printf("ECE391 file system is not valid. Please initialze it first.\n");
        return -1;
    }
    // check if input string name valid
    if (fname_len > FILE_NAME_LEN) {
        ERROR_MSG;
        printf("Input string too long.\n");
        printf("%s::::::\n", fname);
        return -1;
        fname_len = FILE_NAME_LEN;  // QUESTION what does this line do?
    }
    // search for the input fname
    for (i = 0; i < ece391FileSystem.dir_count; i++) {    /* traverse each directories */
        find_flag = 1;
        for (j = 0; j < fname_len; j++) {     /* traverse each directory's name character */
            if (find_flag==0)
                continue;
            if (fname[j]!=ece391FileSystem.ece391_boot_block->direntries[i].filename[j]) /* Need optimizing */
                find_flag = 0;
        }
        // check EOS
        if (fname_len != FILE_NAME_LEN && find_flag == 1) {
            if (ece391FileSystem.ece391_boot_block->direntries[i].filename[fname_len] != NULL)
                find_flag = 0;
        }
        // find the correct name
        if (find_flag == 1) {
            index = i;
            break;
        }
    }
    // name not found
    if (find_flag==0) {
        ERROR_MSG;
        printf("Directory not found.\n");
        return -1;
    }
    // pass found index to function read_dentry_by_index
    return read_dentry_by_index(index, dentry);
}

/*
 * read_dentry_by_index
 *   DESCRIPTION: finds the dentry corresponding to the index
 *   INPUTS: index -- index we are searching for
             dentry -- the emtpy pre-allocated dentry pointer to copy information into
 *   OUTPUTS: none
 *   RETURN VALUE: 0 for success and -1 for fail
 *   SIDE EFFECTS: copys the dentry informaiton for the desired index
 */
int32_t read_dentry_by_index(uint32_t index, dentry_t* dentry) {
    unsigned int i;
    // check if the file system is initialized
    if (ece391FileSystem.ece391_boot_block == NULL || \
       ece391FileSystem.ece391_inodes == NULL ||\
       ece391FileSystem.ece391_data_blocks == NULL) {
        ERROR_MSG;
        printf("ECE391 file system is not valid. Please initialze it first.\n");
        return -1;
    }
    // check if index is in bondary
    if (index >= ece391FileSystem.dir_count) {
        ERROR_MSG;
        printf("Input index outof bondary. \n");
        return -1;
    }
    // copy the dir name
    for (i = 0; i < FILE_NAME_LEN; i++) {
        dentry->filename[i] = ece391FileSystem.ece391_boot_block->direntries[index].filename[i]; /* Need optimizing */
    }
    // copy the file type
    dentry->filetype = ece391FileSystem.ece391_boot_block->direntries[index].filetype;
    // if filetype is regular then copy the inode
    if (dentry->filetype == 2)
        dentry->inode_num = ece391FileSystem.ece391_boot_block->direntries[index].inode_num;
    return 0;

}

/*
 * read_data
 *   DESCRIPTION: copys length bytes of information into the buffer
 *   INPUTS: inode -- inode containing the data
             offset -- offset to start reading from
             buf -- buffer to copy data into
             length -- number of bytes to copy
 *   OUTPUTS: none
 *   RETURN VALUE: -1 for fail and non-negative number for actual number of bytes read into buffer
 *   SIDE EFFECTS: none
 */
int32_t read_data(uint32_t inode, uint32_t offset, uint8_t* buf, uint32_t length) {
    uint32_t buf_index = 0;
    uint32_t data_block_index = 0;
    uint32_t data_byte_index = 0;
    uint32_t copy_position;
    // check if the file system is initialized
    if (ece391FileSystem.ece391_boot_block == NULL || \
       ece391FileSystem.ece391_inodes == NULL ||\
       ece391FileSystem.ece391_data_blocks == NULL) {
        ERROR_MSG;
        printf("ECE391 file system is not valid. Please initialze it first.\n");
        return -1;
    }

    // check if inode input is in boundary
    if (inode >= ece391FileSystem.inode_count) {
        ERROR_MSG;
        printf("Input inode out of bondary. \n");
        return -1;
    }

    // check if offset is in boundary
    if (offset >= ece391FileSystem.ece391_inodes[inode].length) {
        // WARNING_MSG; // This line cause interesting display BUG due to display refresh rate is limited to 256Hz.
        // printf("[WARNING] The file has reach its end, nothing to read.\n");
        return 0; // should return Zero
    }
    // start to copy the string
    copy_position = offset;
    data_block_index = offset / DATA_BLOCK_LEN_;
    data_byte_index = offset % DATA_BLOCK_LEN_;
    // if not reach end, keep copying
    while (copy_position < ece391FileSystem.ece391_inodes[inode].length) {
        if (data_byte_index == DATA_BLOCK_LEN_) {
            data_byte_index = 0;
            data_block_index ++;
        }
        // check if data_block_index is out of inodes' block boundary
        if (data_block_index >= MAX_BLOCK_INDEX) {
            ERROR_MSG;
            printf("Data block index is out of inode block boundary, failed to keep reading. \n");
            return -1;
        }
        // check if data block num is out of ece391 file system boundary
        if (ece391FileSystem.ece391_inodes[inode].data_block_num[data_block_index] >= ece391FileSystem.data_count) {
            WARNING_MSG;
            printf("Inode contains corrupted info and trys to access the memory that is out of the boundary of ece391 file syste, failed to keep reading.");
            return 0;
        }
        // copy this byte
        buf[buf_index] = ece391FileSystem.ece391_data_blocks[ece391FileSystem.ece391_inodes[inode].data_block_num[data_block_index]].data_byte[data_byte_index];
        // prepare to copy next byte
        length--;
        copy_position++;
        data_byte_index++;
        buf_index++;
        // copy finished
        if (length == 0)
            return buf_index;
    }
    // end of file is reached, return the number of bytes copyed
    return ece391FileSystem.ece391_inodes[inode].length - offset;
}
/*
 * get_file_length
 *   DESCRIPTION: get the filelength by fd
 *   INPUTS: fd: the file descriptor of the desire file
 *   OUTPUTS: none
 *   RETURN VALUE: filelength in bytes. -1 for fail
 *   SIDE EFFECTS: none
 */
extern int32_t get_file_length(int32_t fd) {
    int32_t ret_length;
    /*checks bad input fd*/
    if (fd < FD_LOW || fd > FD_UPPER) {
        ERROR_MSG;
        printf("Input fd out of range.\n");
        return -1;
    }
    /*checks if no process is opened*/
    if (ece391_process_manager.curr_pid == -1) {
        ERROR_MSG;
        printf("No process is opened.\n");
        return -1;
    }
    if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].inode == 0xFFFF) {
        ERROR_MSG;
        printf("Priviledged file, check length.\n");
        return -1;
    }

    ret_length = ece391FileSystem.ece391_inodes[((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].inode)].length;
    return ret_length;
}

// following are higher level APIs to interact with file system, these functions are expected to be called
/*
 * init_file_status_array
 *   DESCRIPTION: initialized the fileStatusArray structure
 *   INPUTS: array -- the fileStatusArray we want to initailize
 *   OUTPUTS: none
 *   RETURN VALUE: none
 *   SIDE EFFECTS: none

void init_file_status_array(file_status_array_t* array){
    uint32_t ii;    // traverse to initialize status file/dir array
    for(ii = 0; ii < MAX_FILE_OPEN; ii++){
        array->FILE_STATUS[ii] = STATUS_CLOSED;
        array->FILE_OFFSET[ii] = 0;
        array->CURRENT_DIR_IDX = 0;
        array->RTC_STATUS = STATUS_CLOSED;
    }
    return;
}
 */
// for SYSTEM CALL

/*
 * file_open
 *   DESCRIPTION: opens a non-directory file
 *   INPUTS: filename -- the file we want to open
 *   OUTPUTS: none
 *   RETURN VALUE: fd
 *   SIDE EFFECTS: none
 */
int32_t file_open(const uint8_t* filename) {
    int32_t ii;    // traverse to check status file/dir array
    int32_t new_fd = -1;  // if can open a file, this will record the fd
    dentry_t dentry;    // check dentry
    // traverse the open file array
    for (ii = FD_LOW; ii <= FD_UPPER; ii++) {
        // check each opened file
        if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[ii].flags == STATUS_CLOSED) {
            new_fd = ii;
            break;
        }
    }
    // copy to local dentry for init file in file_array
    read_dentry_by_name(filename, &dentry);
    // update the opened file's status
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].inode = dentry.inode_num;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].filePos = 0;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].flags = STATUS_OPENED;
    // assign jumptables in system_call
    return new_fd;
}

/*
 * file_close
 *   DESCRIPTION: closes a non-directory file
 *   INPUTS: fd -- the file index in the fileStatusArray of the file we want to close
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success
 *   SIDE EFFECTS: none
 */
int32_t file_close(int32_t fd) {
    if (fd < FD_LOW || fd > FD_UPPER) {
        ERROR_MSG;
        printf("Input fd out of range.\n");
        return -1;
    }
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags = STATUS_CLOSED;
    return 0;
}

/*
 * file_find
 *   DESCRIPTION: finds the fd for a file, used to find the correct fd to pass into file_read or dir_read function
 *   INPUTS: filename -- the file we want to find
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure and non-negative index of the fd we finded
 *   SIDE EFFECTS: none
 */
// int32_t file_find    (const uint8_t* filename){
//     int32_t ii;    // traverse to check status file/dir array
//     int32_t i;     // traverse to check name string
//     const int32_t file_name_length = strlen((int8_t*) filename);
//     int8_t already_open_flag = 0;
//     if (file_name_length > FILE_NAME_LEN ){
//         printf("Input string too long.\n");
//         return -1;
//     }
//     // traverse the open file array
//     for (ii = 0; ii < MAX_FILE_OPEN; ii++){
//         // check each opened file
//         if (fileStatusArray.FILE_STATUS[ii] == STATUS_OPENED){
//             already_open_flag = 1; // initialize as opened
//             // check if the name is the same
//             for (i = 0; i < file_name_length; i++){
//                 if (filename[i] != fileStatusArray.FILE_TO_OPEN[ii].filename[i]){
//                     already_open_flag = 0;
//                     break;
//                 }
//             }
//             // if it is the same return the fd index
//             if (already_open_flag == 1)
//                 return ii;
//         }
//     }
//     // return -1 if not found
//     return -1;
// }

/*
 * file_read
 *   DESCRIPTION: reads nbytes of informatin from the non-directory file into the buffer, redirects to rtc_read if the input file is rtx file
 *   INPUTS: fd -- the file index we want to read
             buf -- the buffer to copy information into
             nbytes -- number of bytes to read
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure and non-negative actual number of bytes we read
 *   SIDE EFFECTS: none
 */
int32_t file_read(int32_t fd, unsigned char* buf, int32_t nbytes) {
    int32_t file_inode_num;
    uint32_t new_offset;

    // check input buf pointer is valid
    if (buf == NULL) {
        ERROR_MSG;
        printf("Input buf is NULL.\n");
        return -1;
    }
    if (nbytes < 0) {
        ERROR_MSG;
        printf("Input nbytes is negative.\n");
        return -1;
    }
    file_inode_num = (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].inode;
    new_offset = read_data(file_inode_num,((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].filePos), (uint8_t*) buf, nbytes);
    // if fail to read
    if (new_offset == -1) {
        ERROR_MSG;
        printf("File read fail.\n");
        return -1;
    }
    // update the offset array in the status array
    ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].filePos) += new_offset;
    return new_offset;
}

/*
 * file_write
 *   DESCRIPTION: read-only filesystem, nothing to do
 *   INPUTS: fd -- the file index we want to write
             buf -- the buffer to write from
             nbytes -- number fo bytes to write
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure
 *   SIDE EFFECTS: none
 */
int32_t file_write(int32_t fd, const unsigned char *buf, int32_t nbytes) {
    return -1;
}


/*need header*/
/*
 * dir_open
 *   DESCRIPTION: opens a directory file
 *   INPUTS: filename -- the file we want to open
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success and -1 on failure
 *   SIDE EFFECTS: none
 */
int32_t dir_open(const uint8_t* filename) {
    int32_t ii;    // traverse to check status file/dir array
    int32_t new_fd = -1; // new fd to return
    dentry_t dentry;    // check dentry
    //check for nonexisting directory
    if (*filename != '.') {
        ERROR_MSG;
        printf("Not a directory.\n");
        return -1;
    }
    // traverse the open file array
    for (ii = FD_LOW; ii <= FD_UPPER; ii++) {
        // check each opened file
        if ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[ii].flags == STATUS_CLOSED) {
            new_fd = ii;
            break;
        }
    }
    // copy to local dentry for init file in file_array
    read_dentry_by_name(filename, &dentry);
    // update the opened file's status
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].inode = -1;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].filePos = 0;
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[new_fd].flags = STATUS_OPENED;
    // assign jumptables in system_call
    return new_fd;
}

/*
 * dir_close
 *   DESCRIPTION: closes a directory file
 *   INPUTS: fd -- the file index in the fileStatusArray of the file we want to close
 *   OUTPUTS: none
 *   RETURN VALUE: 0 on success and -1 on failure
 *   SIDE EFFECTS: none
 */
int32_t dir_close(int32_t fd) {
    if (fd < FD_LOW || fd > FD_UPPER) {
        ERROR_MSG;
        printf("Input fd out of range.\n");
        return -1;
    }
    (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].flags = STATUS_CLOSED;
    return 0;
}

/*
 * dir_read
 *   DESCRIPTION: reads nbytes of informatin from the directory file into the buffer
 *   INPUTS: fd -- the file index we want to read
             buf -- the buffer to copy information into
             nbytes -- number of bytes to read
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure and 0 on success
 *   SIDE EFFECTS: none
 */
int32_t dir_read(int32_t fd, unsigned char *buf, int32_t nbytes) {
    /*number of file directorys to be read into buffer*/
    int32_t nfile = nbytes / FILE_NAME_LEN;
    /*index to copy to buffer*/
    int32_t i;
    /*index for reading dentry*/
    int32_t ii;
    /*size of a particular file*/
    int32_t filesize;
    /*stores the current dentry*/
    dentry_t temp_dentry;
    /*offset to read dir*/
    uint32_t offset;
    /*check for bad pointer*/
    if (buf == NULL) {
        ERROR_MSG;
        printf("Input buf pointer is NULL.\n");
        return -1;
    }

    /*check whether reading 32 bytes*/
    if (nbytes < 0) {
        ERROR_MSG;
        printf("Input nbytes is negative.\n");
        return -1;
    }
    /*check whether buffer is too big*/
    nfile = (nfile > ece391FileSystem.dir_count) ? ece391FileSystem.dir_count : nfile;

    for (ii = 0; ii < nfile; ii++){
        /*current directory read to*/
        offset = (ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].filePos;

        /*read the next file*/
        if (offset >= ece391FileSystem.dir_count) {
            return 0;
        }

        /*read the current file and copy its dentry information*/
        if (read_dentry_by_index(offset, &temp_dentry) == -1) {
            ERROR_MSG;
            printf("Dentry read failed\n");
            return -1;
        }

        // update counter
        ((ece391_process_manager.process_position[ece391_process_manager.curr_pid-1])->file_array.files[fd].filePos)++;

        /*copy filename into the buffer*/
        for (i = ii * FILE_NAME_LEN; i < (ii+1) * FILE_NAME_LEN; i++) {
            ((int8_t*)buf)[i] = temp_dentry.filename[i - ii * FILE_NAME_LEN];
        }

        if (temp_dentry.filetype != 2)
            filesize = 0;
        else
            filesize = ece391FileSystem.ece391_inodes[temp_dentry.inode_num].length;
    }
    /*prints out the filename, filetype, and filesize of the current file in the directory*/
    // printf("Filename: ");
    //for (i = 0; i < FILE_NAME_LEN; i++) {
        //if (temp_dentry.filename[i] == '\0')
            //break;
        // printf("%c", temp_dentry.filename[i]);
    //}
    // printf(", Filetype: %d, Filesize: %dbytes.\n", temp_dentry.filetype, filesize);
    return nfile * FILE_NAME_LEN;
}

/*
 * dir_write
 *   DESCRIPTION: read-only filesystem, nothing to do
 *   INPUTS: fd -- the file index we want to write
             buf -- the buffer to write from
             nbytes -- number fo bytes to write
 *   OUTPUTS: none
 *   RETURN VALUE: -1 on failure
 *   SIDE EFFECTS: none
 */
int32_t dir_write(int32_t fd, const unsigned char* buf, int32_t nbytes) {
    return -1;
}
