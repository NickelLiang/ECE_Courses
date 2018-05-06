/* loader.h - Program loader
 * vim:ts=4 noexpandtab
 */
#ifndef LOADER_H
#define LOADER_H

#include "types.h"

#define LOAD_PAGE_START_ADDR    0x08000000  // Beginning of the 4MB block
#define LOAD_PAGE_END_ADDR      0x08400000  // End of the 4MB block
#define LOAD_EXE_START_ADDR     0x08048000  // Virtual addr of beginning of actual file data
#define LOAD_EXE_MAX_SIZE       (LOAD_PAGE_END_ADDR - LOAD_EXE_START_ADDR) // Maximum size of a program in bytes
#define EXE_IDENTIFIER_SIZE     4           // Four magic numbers to determine if a file is an executable
#define EXE_START_COUNT         (24/4)      // Byte 24-27 from the EXE start addr

/* Check if a file is a valid executable file */
extern int8_t check_executable_validity(uint8_t* filename);

/* Load the user executable image into proper memory location and return the starting address of the executable */
extern uint32_t* load_user_image(uint8_t* filename);

#endif
