#include "loader.h"
#include "file_system.h"
#include "lib.h"
#include "system_call.h"

/* Magic number at the beginning of an executable file */
const uint8_t EXE_IDENTIFIER_TABLE[EXE_IDENTIFIER_SIZE] = {
    0x7F, 0x45, 0x4C, 0x46
};

/* NOTE Limitation of this loader is that it assumes that and executable is always smaller than 4MB, which is specified in the MP3.3 documentation. However, this loader can be more flexible with a more complexed paging initialization strategy. */

/* check_executable_validity
 * Purpose Check if an file is a valid executable image.
 * Inputs  fd   User program fd #
 * Outputs Error message when necessary.
 * Return  -1   when file is not a valid executable
 *         1    when file is a valid
 * Side Effects None
 * NOTE call before load_user_image
 */
int8_t check_executable_validity(uint8_t* filename) {
    /* Check if file opened */
    if (filename == NULL) {
        ERROR_MSG;
        printf("Filename is NULL.\n");
        return -1;
    }

    dentry_t dentry;
    if (read_dentry_by_name(filename, &dentry) == -1) {
        ERROR_MSG;
        printf("File does not exist.\n");
        return -1;
    }

    /* Read first four bytes of the file */
    int32_t nbytes = EXE_IDENTIFIER_SIZE;
    uint8_t file_identifier[EXE_IDENTIFIER_SIZE];

    if (read_data(dentry.inode_num, 0, file_identifier, nbytes) != EXE_IDENTIFIER_SIZE) {
        ERROR_MSG;
        printf("Fail to compare with identifier.\n");
        return -1;
    }

    /* Check if file is a valid executable */
    uint8_t i;
    for (i = 0; i < EXE_IDENTIFIER_SIZE; i++) {
        if (file_identifier[i] != EXE_IDENTIFIER_TABLE[i]) {
            ERROR_MSG;
            printf("File identifier %d doesn't match. %u instead of %u.", i, file_identifier[i], EXE_IDENTIFIER_TABLE[i]);
            printf("Not an executable image.\n");;
            return -1;
        }
    }
    return 1;
}

 /* load_user_image
  * Purpose Load an user executable image into proper memory location.
  * Inputs  fd  User program fd #
  * Outputs Error message when necessary.
  * Return  Starting Address of the executable if valid,
  *         NULL if invalid or error occured.
  * Side Effects None
  * NOTE call after check_executable_validity
  */
uint32_t* load_user_image(uint8_t* filename) {
    /* Get file length, check if it exceed maximum allowable image size */
    int32_t nbytes;
    dentry_t dentry;
    if (read_dentry_by_name(filename, &dentry) == -1) {
        ERROR_MSG;
        printf("File does not exist.\n");
        return NULL;
    }
    nbytes = ece391FileSystem.ece391_inodes[dentry.inode_num].length;

    if (nbytes > LOAD_EXE_MAX_SIZE) {
        ERROR_MSG;
        printf("Executable image size exceed maximum allowance. Size %dB, %dB allowed.\n", nbytes, LOAD_EXE_MAX_SIZE);
        return NULL;
    } else if (nbytes < 0) {
        ERROR_MSG;
        printf("Failed to get file length.\n");
        return NULL;
    }

    /* Read file data into proper location */
    uint8_t* buffer = (uint8_t*)LOAD_EXE_START_ADDR;
    int32_t read_bytes = read_data(dentry.inode_num, 0, buffer, nbytes);
    if (read_bytes != nbytes) {
        ERROR_MSG;
        printf("File read size does not match file size. Read %dB/%dB in file.\n", read_bytes, nbytes);
        return NULL;
    }

    /* Get program starting address */
    uint32_t* starting_addr = (uint32_t*) ((uint32_t*)buffer)[EXE_START_COUNT];
    /* Check if we got an starting address after EXE_START_ADDR, before the end of the page */
    if (((uint32_t)starting_addr < LOAD_EXE_START_ADDR) || (uint32_t)starting_addr > LOAD_PAGE_END_ADDR) {
        ERROR_MSG;
        printf("Executable image starting address(0x%#x) is invalid. Should be within 0x%#x - 0x%#x.\n", (uint32_t)starting_addr, LOAD_EXE_START_ADDR, LOAD_PAGE_END_ADDR);
        return NULL;
    }

    return starting_addr;
}
