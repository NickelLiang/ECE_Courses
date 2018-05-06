/* types.h - Defines to use the familiar explicitly-sized types in this
 * OS (uint32_t, int8_t, etc.).  This is necessary because we don't want
 * to include <stdint.h> when building this OS
 * vim:ts=4 noexpandtab
 */

#ifndef _TYPES_H
#define _TYPES_H

#define NULL        0

#ifndef ASM

/* Types defined here just like in <stdint.h> */
typedef int int32_t;
typedef unsigned int uint32_t;

typedef short int16_t;
typedef unsigned short uint16_t;

typedef char int8_t;
typedef unsigned char uint8_t;

#endif /* ASM */

#define MSG_DETAIL  1   /* Set to 0 to turn off FILE, FUNCTION, LINE details. */

#define ERROR_MSG                                                           \
do {                                                                        \
    if (MSG_DETAIL)                                                         \
        printf("[ERROR at %s:%s:%d] ", __FILE__, __FUNCTION__, __LINE__);   \
    else                                                                    \
        printf("[ERROR] ");                                                 \
} while (0)

#define WARNING_MSG                                                         \
do {                                                                        \
    if (MSG_DETAIL)                                                         \
        printf("[WARNING at %s:%s:%d] ", __FILE__, __FUNCTION__, __LINE__); \
    else                                                                    \
        printf("[WARNING] ");                                               \
} while (0)

#define TEST_MSG                                                            \
    printf("[TEST at %s:%s:%d]\n", __FILE__, __FUNCTION__, __LINE__)

#define EXCEPTION_MSG                                                       \
    printf("[EXCEPTION] ")

#endif /* _TYPES_H */
