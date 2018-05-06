#ifndef FILE_SYSTEM
#define FILE_SYSTEM

#include "types.h"
//#include "system_call.h"
// dentry parameters
#define FILE_NAME_LEN           32
#define DENTRY_RESERVED         24
// boot_block parameters
#define BOOT_BLOCK_RESERVED     52
#define DIRENTRIES_NUM          63
// inode parameter
#define DATA_BLOCK_NUM_         1023
// data_block parameter
#define DATA_BLOCK_LEN_         4096
// file system parameter
#define FILESYS_IMG_LEN         0x7c000
#define BLOCK_SIZE_4KB          4096
// following functions are for system call
#define FD_LOW                  2 // user has no priviledge to close fd 0, 1 or non-exist file
#define FD_UPPER                7 // any fd is greater then 7 is invalid
// filetypes
#define RTC_FILE_TYPE           0
#define DIR_FILE_TYPE           1
#define REG_FILE_TPYE           2
#define FA_SIZE                 8
#define MAX_BLOCK_INDEX         1023        // in inodes' 4kB's memory has 1023 block numbers at large

/*  This is the data structure that holds the dentry for each regular file,
 *  directory, or RTC access file. ECE391 file system has 63 dentry
 *  in total. They are placed in the first block, boot_block, in the
 *  ece391 filesys.img.
 *
 *  note: 64B without padding
 */
struct dentry{
    int8_t filename[FILE_NAME_LEN];
    int32_t filetype;
    int32_t inode_num;
    int8_t reserved[DENTRY_RESERVED];
} __attribute((packed));
typedef struct dentry dentry_t;

/*  THis is the data structure that holds both the statistics of the file
 *  system and all the dentries. This is the first block of the
 *  ece391 file system.
 *
 *  note: 4kB without padding
 */
struct boot_block{
    int32_t dir_count;
    int32_t inode_count;
    int32_t data_count;
    int8_t reserved[BOOT_BLOCK_RESERVED];
    dentry_t direntries[DIRENTRIES_NUM];
}__attribute((packed));
typedef struct boot_block boot_block_t;

/*  This is the data structure that holds inode of each regular file in
 *  ece39 file system. An inode holds the information, not the data, of
 *  a file.
 *
 *  note: 4kB without padding
 */
struct inode{
    int32_t length;     /* in bytes */
    int32_t data_block_num[DATA_BLOCK_NUM_];
}__attribute((packed));
typedef struct inode inode_t;

/*  This is the data_block of the file system.
 *
 *  note: 4kB without padding*/
struct data_block{
    int8_t data_byte[DATA_BLOCK_LEN_];
}__attribute((packed));
typedef struct data_block data_block_t;

/*  This is the whole ece391 file system. This data structure contians three consecutive
 *  array pointers.
 *
 *  note: parse the file system
 */
struct ece391_file_system{
    boot_block_t* ece391_boot_block;
    inode_t*  ece391_inodes;
    data_block_t* ece391_data_blocks;
    int32_t dir_count;
    int32_t inode_count;
    int32_t data_count;
}__attribute((packed));
typedef struct ece391_file_system ece391_file_system_t;

// extern file system
extern ece391_file_system_t   ece391FileSystem;

// utility
/*Initializes the local ece391_file_system structure*/
extern void init_file_system(unsigned int addr_start, unsigned int addr_end);
/* copys dentry information of a file indicated by filename */
extern int32_t read_dentry_by_name(const uint8_t *fname, dentry_t* dentry);
/* copys dentry information of a file indicated by the file index in the boot block */
extern int32_t read_dentry_by_index(uint32_t index, dentry_t* dentry);
/* copys length bytes of information of a file from offset of the corresponding inode into buffer*/
extern int32_t read_data(uint32_t inode, uint32_t offset, uint8_t* buf, uint32_t length);
/*gets the file length by fd if*/
extern int32_t get_file_length(int32_t fd);

/* for check point 2
#define MAX_FILE_OPEN   17
#define STATUS_CLOSED   67      // 'C' indecates file closed
#define STATUS_OPENED   79      // 'O' indicates file opened

 This is the file array to record file open/close status.
 *
 *  note: only for check point 3.2

struct file_status_array{
  // files status
    dentry_t FILE_TO_OPEN[MAX_FILE_OPEN];
    uint8_t FILE_STATUS[MAX_FILE_OPEN];
    uint32_t FILE_OFFSET[MAX_FILE_OPEN];
    uint32_t CURRENT_DIR_IDX;
    uint8_t RTC_STATUS;
};
typedef struct file_status_array file_status_array_t;
extern file_status_array_t fileStatusArray;
 */

 // this file array pointer should points to current PCB's file array

// following functions are for system call
/*Initializes the local file_status_array*/
//extern void init_file_status_array(file_status_array_t* array);
/* A neat helper function that return the file descriptor of the file indicated by filename*/
// extern int32_t file_find    (const uint8_t* filename);

/* read function for non-directory files */
extern int32_t file_read    (int32_t fd, unsigned char* buf, int32_t nbytes);
/* write function for non-directory files */
extern int32_t file_write   (int32_t fd, const unsigned char* buf, int32_t nbytes);
/* open function for non-directory files */
extern int32_t file_open    (const uint8_t* filename);
/* close function for non-directory files */
extern int32_t file_close   (int32_t fd);
/* read function for directory files */
extern int32_t dir_read    (int32_t fd, unsigned char* buf, int32_t nbytes);
/* write function for directory files */
extern int32_t dir_write   (int32_t fd, const unsigned char* buf, int32_t nbytes);
/* open function for directory files */
extern int32_t dir_open    (const uint8_t* filename);
/* close function for directory files */
extern int32_t dir_close   (int32_t fd);
#endif
