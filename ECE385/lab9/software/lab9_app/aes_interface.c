#include "aes_interface.h"

aes_t *aes = (aes_t*)AES_ADDR;

void aes_write_key(uint8_t reg, uint32_t content) {
    aes->key[reg] = content;
}

void aes_write_key_all(uint32_t *content) {
    memcpy(aes->key, content, sizeof(uint32_t)*4);
}

uint32_t aes_read_key(uint8_t reg) {
    return aes->key[reg];
}

void aes_write_encrypt_msg(uint8_t reg, uint32_t content) {
    aes->encrypt_msg[reg] = content;
}

void aes_write_encrypt_msg_all(uint32_t *content) {
    memcpy(aes->encrypt_msg, content, sizeof(uint32_t)*4);
}

uint32_t aes_read_encrypt_msg(uint8_t reg) {
    return aes->encrypt_msg[reg];
}

void aes_write_decrypt_msg(uint8_t reg, uint32_t content) {
    aes->decrypt_msg[reg] = content;
}

uint32_t aes_read_decrypt_msg(uint8_t reg) {
    return aes->decrypt_msg[reg];
}

void aes_read_decrypt_msg_all(uint32_t *buffer) {
    memcpy(buffer, aes->decrypt_msg, sizeof(uint32_t)*4);
    aes->start = 0x0;
}

void aes_start(void) {
    aes->start = 0x1;
}

uint8_t aes_done(void) {
    return (uint8_t)(aes->done);
}
