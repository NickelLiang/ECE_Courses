#ifndef _AES_INTERFACE_H_
#define _AES_INTERFACE_H_

#include "system.h"
#include "types.h"
#include <stdlib.h>

#define AES_ADDR    (volatile int*)     AES_DECRYPTION_CORE_0_BASE

typedef struct {
    volatile uint32_t key[4];
    volatile uint32_t encrypt_msg[4];
    volatile uint32_t decrypt_msg[4];
    volatile uint32_t unused[2];
    volatile uint32_t start;
    volatile uint32_t done;
} aes_t;

extern aes_t* aes;

void aes_write_key(uint8_t reg, uint32_t content);
void aes_write_key_all(uint32_t *content);
uint32_t aes_read_key(uint8_t reg);

void aes_write_encrypt_msg(uint8_t reg, uint32_t content);
void aes_write_encrypt_msg_all(uint32_t *content);
uint32_t aes_read_encrypt_msg(uint8_t reg);

void aes_write_decrypt_msg(uint8_t reg, uint32_t content);
uint32_t aes_read_decrypt_msg(uint8_t reg);
void aes_read_decrypt_msg_all(uint32_t *buffer);

void aes_start(void);
uint8_t aes_done(void);

#endif
