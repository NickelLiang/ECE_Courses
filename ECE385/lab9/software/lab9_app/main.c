/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "aes.h"
#include "aes_interface.h"

// Pointer to base address of AES module, make sure it matches Qsys
// volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c) {
    char hex = c;

    if (hex >= '0' && hex <= '9')
        hex -= '0';
    else if (hex >= 'A' && hex <= 'F') {
        hex -= 'A';
        hex += 10;
    } else if (hex >= 'a' && hex <= 'f') {
        hex -= 'a';
        hex += 10;
    }
    return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2) {
    char hex1 = charToHex(c1);
    char hex2 = charToHex(c2);
    return (hex1 << 4) + hex2;
}

void swap(uint8_t *a, uint8_t *b) {
    uint8_t tmp = *a;
    *a = *b;
    *b = tmp;
}

void endian_swap_16(uint16_t *val) {
    uint8_t *arr = (uint8_t*)val;
    swap(arr, arr+1);
}

void endian_swap_32(uint32_t *val) {
    uint8_t *arr = (uint8_t*)val;
    swap(arr, arr+3);
    swap(arr+1, arr+2);
}

void strings_to_bytes(uint8_t *data_ascii, uint8_t *bytes) {
    uint8_t i;
    for (i = 0; i < 16; ++i)
        bytes[i] = charsToHex(data_ascii[2*i], data_ascii[2*i+1]);
}

void shift_rows(uint8_t *bytes) {
    int8_t i;
    // shift 2nd row
    for (i = 0; i < 3; ++i)
        swap(bytes + 1+4*i, bytes + 1+4*(i+1)); // swap bytes[1, i] with bytes[1, i+1]
    // shift 3rd row
    for (i = 0; i < 2; ++i)
        swap(bytes + 2+4*i, bytes + 2+4*(i+2)); // swap bytes[2, i] with bytes[2, i+2]
    // shift 4th row
    for (i = 2; i >= 0; --i)
        swap(bytes + 3+4*i, bytes + 3+4*(i+1)); // swap bytes[3, i] with bytes[3, i+1]
}

void sub_bytes(uint8_t *bytes, uint8_t length) {
    uint8_t i;
    for (i = 0; i < length; ++i)
        bytes[i] = aes_sbox[bytes[i]];
}

void key_generate(uint32_t *key, uint8_t idx) {
    uint8_t i;
    uint32_t tmp;
    for (i = 0; i < 4; ++i) {
        if (i == 0) {
            tmp = key[3];
            tmp = (tmp >> 8) | (tmp << 24);
            sub_bytes((uint8_t*)&tmp, sizeof(tmp));
            tmp = tmp ^ Rcon[idx]; // Rcon is modified: see aes.h
        } else
            tmp = key[i-1];
        key[i] = key[i] ^ tmp;
    }
}

void add_roundkey(uint32_t *bytes, uint32_t *key) {
    uint8_t i;
    for (i = 0; i < 4; i++)
        bytes[i] = bytes[i] ^ key[i];
}

void mix_one_column(uint8_t *word) {
    uint8_t new_word[4];
    new_word[0] = gf_mul[word[0]][0] ^ gf_mul[word[1]][1] ^ word[2] ^ word[3];
    new_word[1] = word[0] ^ gf_mul[word[1]][0] ^ gf_mul[word[2]][1] ^ word[3];
    new_word[2] = word[0] ^ word[1] ^ gf_mul[word[2]][0] ^ gf_mul[word[3]][1];
    new_word[3] = gf_mul[word[0]][1] ^ word[1] ^ word[2] ^ gf_mul[word[3]][0];
    memcpy(word, new_word, sizeof(uint8_t)*4);
}

void mix_columns(uint32_t *bytes) {
    uint8_t i;
    for (i = 0; i < 4; ++i)
        mix_one_column((uint8_t*)(bytes+i));
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key) {
    strings_to_bytes(msg_ascii, (uint8_t*)msg_enc);
    strings_to_bytes(key_ascii, (uint8_t*)key);

    uint32_t roundkey[4];
    memcpy(roundkey, key, sizeof(uint32_t)*4);
    add_roundkey((uint32_t*)msg_enc, roundkey);

    uint8_t i;
    for (i = 1; i < 11; ++i) {
        sub_bytes((uint8_t*)msg_enc, 16);
        shift_rows((uint8_t*)msg_enc);
        if (i != 10)
            mix_columns((uint32_t*)msg_enc);
        key_generate((uint32_t*)roundkey, i);
        add_roundkey((uint32_t*)msg_enc, roundkey);
    }

    // // TODO: these endian swaps can be removed to increase performance, waiting for
    // //       instructor's confirmation on getting rid of them.
    for (i = 0; i < 4; ++i) {
        endian_swap_32((uint32_t*)(msg_enc+i));
        endian_swap_32((uint32_t*)(key+i));
    }
    // aes_write_key_all((uint32_t*)key);
    // aes_write_encrypt_msg_all((uint32_t*)msg_enc);

    // // TEST if write result is consistent
    // for (size_t i = 0; i < 4; i++) {
    //     if (aes_read_key(i) != key[i])
    //         printf("ERROR WRITE KEY\n");
    //     if (aes_read_encrypt_msg(i) != msg_enc[i])
    //         printf("ERROR WRITE ENCRYPTED MSG\n");
    // }
}

/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key) {
    aes_write_key_all((uint32_t*)key);
    aes_write_encrypt_msg_all((uint32_t*)msg_enc);

    aes_start();
    while (!aes_done());
    aes_read_decrypt_msg_all((uint32_t*)msg_dec);
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main() {
    // Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
    unsigned char msg_ascii[33];
    unsigned char key_ascii[33];
    // Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
    unsigned int key[4];
    unsigned int msg_enc[4];
    unsigned int msg_dec[4];

    while (1) {
        printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
        scanf("%d", &run_mode);
        if (run_mode == 0) {
            // Continuously Perform Encryption and Decryption
            while (1) {
                int i = 0;
                printf("\nEnter Message:\n");
                scanf("%s", msg_ascii);
                printf("\n");
                printf("\nEnter Key:\n");
                scanf("%s", key_ascii);
                printf("\n");
                encrypt(msg_ascii, key_ascii, msg_enc, key);
                printf("\nEncrpted message is: \n");
                for(i = 0; i < 4; i++) {
                    printf("%08x", msg_enc[i]);
                }
                printf("\n");
                decrypt(msg_enc, msg_dec, key);
                printf("\nDecrypted message is: \n");
                for(i = 0; i < 4; i++) {
                    printf("%08x", msg_dec[i]);
                }
                printf("\n");
            }
        } else {
            // Run the Benchmark
            int i = 0;
            int size_KB = 2;
            // Choose a random Plaintext and Key
            for (i = 0; i < 32; i++) {
                msg_ascii[i] = 'a';
                key_ascii[i] = 'b';
            }
            // Run Encryption
            clock_t begin = clock();
            for (i = 0; i < size_KB * 64; i++)
                encrypt(msg_ascii, key_ascii, msg_enc, key);
            clock_t end = clock();
            double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
            double speed = size_KB / time_spent;
            printf("Software Encryption Speed: %.12f KB/s \n", speed);
            // Run Decryption
            begin = clock();
            for (i = 0; i < size_KB * 64; i++)
                decrypt(msg_enc, msg_dec, key);
            end = clock();
            time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
            speed = size_KB / time_spent;
            printf("Hardware Decryption Speed: %.12f KB/s \n", speed);
        }
    }
    return 0;
}
